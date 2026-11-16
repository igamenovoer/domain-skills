"""Select an explicit functional submodule in a shared development environment.

Classification: utility. Copy into the target metaproj's meta_src/ when needed.
Configuration belongs in meta_configs/workspace.toml; no DSGen dependency exists.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path, PurePosixPath
import re
import subprocess
import sys
import tomllib
from typing import Any, Mapping, Sequence


class WorkspaceError(ValueError):
    """Report a configuration or checkout identity problem without repairing it."""


def _git(root: Path, *arguments: str) -> str:
    """Run read-only Git inspection at an explicit repository root."""

    result = subprocess.run(
        ["git", "-C", str(root), *arguments], capture_output=True, text=True, check=False
    )
    if result.returncode:
        raise WorkspaceError(f"Git inspection failed at {root}: {result.stderr.strip()}")
    return result.stdout.rstrip("\n")


def _checkout_key(value: str) -> str:
    """Validate a portable path below realworks without accepting traversal."""

    path = PurePosixPath(value)
    if (
        not value
        or path.is_absolute()
        or "\\" in value
        or any(part in {"", ".", ".."} for part in value.split("/"))
    ):
        raise WorkspaceError("Checkout key must be a relative path below realworks")
    return path.as_posix()


def _inside(root: Path, relative: str, *, must_exist: bool = True) -> Path:
    """Resolve a configured path while rejecting escapes through symlinks."""

    if Path(relative).is_absolute():
        raise WorkspaceError(f"Configured path must be relative to its owner: {relative}")
    candidate = (root / relative).resolve()
    if not candidate.is_relative_to(root.resolve()):
        raise WorkspaceError(f"Configured path escapes its owner: {relative}")
    if must_exist and not candidate.exists():
        raise WorkspaceError(f"Required path is missing: {candidate}")
    return candidate


def _registrations(meta: Path) -> dict[str, dict[str, str]]:
    """Read branch mappings and staged gitlinks, including uninitialized entries."""

    config = meta / ".gitmodules"
    if not config.is_file():
        raise WorkspaceError("No .gitmodules; initialize or migrate the meta workspace first")
    result = subprocess.run(
        ["git", "config", "--file", str(config), "--get-regexp", r"^submodule\..*\.path$"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode not in {0, 1}:
        raise WorkspaceError(result.stderr.strip())
    records: dict[str, dict[str, str]] = {}
    for row in result.stdout.splitlines():
        field, path = row.split(None, 1)
        if not path.startswith("realworks/"):
            continue
        key = _checkout_key(path.removeprefix("realworks/"))
        if key in records:
            raise WorkspaceError(f"Duplicate realwork registration: {key}")
        module = field.removeprefix("submodule.").removesuffix(".path")
        branch = _git(meta, "config", "--file", str(config), "--get", f"submodule.{module}.branch")
        if not branch or branch == ".":
            raise WorkspaceError(f"Realwork {key} needs a concrete branch mapping")
        staged = _git(meta, "ls-files", "--stage", "-z", "--", path).split("\0")
        entries = [entry for entry in staged if entry]
        if len(entries) != 1:
            raise WorkspaceError(f"Realwork {key} needs one unconflicted staged gitlink")
        mode, pin, stage = entries[0].split("\t", 1)[0].split()
        if mode != "160000" or stage != "0":
            raise WorkspaceError(f"Realwork {key} is not an unconflicted gitlink")
        records[key] = {"path": path, "branch": branch, "pin": pin}
    return records


def _select(meta: Path, key: str, records: Mapping[str, Mapping[str, str]]) -> Path:
    """Require an initialized, independent, branch-matching registered checkout."""

    key = _checkout_key(key)
    if key not in records:
        raise WorkspaceError(f"Unknown realwork: {key}")
    meta = meta.resolve()
    root = _inside(meta, records[key]["path"])
    if root != meta / records[key]["path"]:
        raise WorkspaceError(f"Realwork path must not alias another directory: {key}")
    if not (root / ".git").is_file():
        raise WorkspaceError(f"Initialize and absorb the registered submodule first: {key}")
    if Path(_git(root, "rev-parse", "--show-toplevel")).resolve() != root:
        raise WorkspaceError(f"Realwork root does not match Git identity: {key}")
    git_dir = Path(_git(root, "rev-parse", "--absolute-git-dir")).resolve()
    common = (root / _git(root, "rev-parse", "--git-common-dir")).resolve()
    meta_git = Path(_git(meta, "rev-parse", "--absolute-git-dir")).resolve()
    if git_dir != common or not git_dir.is_relative_to(meta_git / "modules"):
        raise WorkspaceError(f"Realwork must be an absorbed independent submodule: {key}")
    branch = _git(root, "branch", "--show-current")
    if branch and branch != records[key]["branch"]:
        raise WorkspaceError(f"Branch mismatch for {key}: expected {records[key]['branch']}")
    if not branch and _git(root, "rev-parse", "HEAD") != records[key]["pin"]:
        raise WorkspaceError(f"Detached realwork {key} does not match its recorded pin")
    return root


def _read_dotenv(path: Path) -> dict[str, str]:
    """Read literal dotenv assignments without shell or variable evaluation."""

    values: dict[str, str] = {}
    if not path.is_file():
        return values
    for number, raw in enumerate(path.read_text().splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("export "):
            line = line[7:].lstrip()
        name, separator, value = line.partition("=")
        name = name.strip()
        if not separator or not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name):
            raise WorkspaceError(f"Invalid dotenv assignment at {path}:{number}")
        value = value.strip()
        if value.startswith(("'", '"')):
            if len(value) < 2 or value[-1] != value[0]:
                raise WorkspaceError(f"Unclosed dotenv quote at {path}:{number}")
            value = value[1:-1]
        values[name] = value
    return values


def _load_config(meta: Path) -> dict[str, Any]:
    """Read the meta-owned launcher configuration."""

    with (meta / "meta_configs/workspace.toml").open("rb") as stream:
        config: dict[str, Any] = tomllib.load(stream)
    workspace = config.get("workspace", {})
    if not isinstance(workspace, dict):
        raise WorkspaceError("workspace must be a TOML table")
    prefix = workspace.get("prefix")
    if not isinstance(prefix, str) or not re.fullmatch(r"[A-Z][A-Z0-9_]*", prefix):
        raise WorkspaceError("workspace.prefix must be an uppercase project identifier")
    return config


def _paths(root: Path, values: Any) -> list[Path]:
    """Resolve required Python import directories inside the selected checkout."""

    if not isinstance(values, list) or not all(isinstance(value, str) for value in values):
        raise WorkspaceError("Source/dependency paths must be arrays of relative strings")
    resolved = [_inside(root, value) for value in values]
    if any(not path.is_dir() for path in resolved):
        raise WorkspaceError("Python source/dependency paths must be directories")
    return resolved


def _environment(
    meta: Path,
    root: Path,
    key: str,
    config: Mapping[str, Any],
    inherited: Mapping[str, str],
    *,
    include_meta: bool = False,
) -> tuple[dict[str, str], list[Path]]:
    """Compose per-process selection and literal resource defaults."""

    workspace = config["workspace"]
    prefix = workspace["prefix"]
    marker = f"{prefix}_WORKSPACE_DEFAULTS"
    original = dict(inherited)
    try:
        previous_defaults = json.loads(original.pop(marker, "{}"))
    except json.JSONDecodeError as error:
        raise WorkspaceError("Invalid inherited workspace default metadata") from error
    if isinstance(previous_defaults, dict):
        for name, value in previous_defaults.items():
            if original.get(name) == value:
                original.pop(name)
    values = _read_dotenv(meta / ".env")
    values.update(_read_dotenv(root / ".env"))
    values.update(original)
    defaults: dict[str, str] = {}
    resources = dict(config.get("resources", {}))
    resources["TMP_ROOT"] = f"tmp/{key}"
    for purpose, location in resources.items():
        if not re.fullmatch(r"[A-Z][A-Z0-9_]*", purpose) or not isinstance(location, str):
            raise WorkspaceError("Resources need uppercase purposes and relative path defaults")
        if Path(location).is_absolute():
            raise WorkspaceError("Use an environment override for absolute resource locations")
        destination = _inside(meta, location, must_exist=False)
        name = f"{prefix}_DEV_{purpose}"
        if not values.get(name, "").strip():
            values[name] = os.path.relpath(destination, root)
            defaults[name] = values[name]
    selected_paths = _paths(root, workspace.get("source_paths", ["src", "."]))
    selected_paths += _paths(root, workspace.get("dependency_paths", []))
    if include_meta:
        selected_paths.insert(0, meta)
    values["PYTHONPATH"] = os.pathsep.join(str(path) for path in dict.fromkeys(selected_paths))
    values["PYTHONNOUSERSITE"] = "1"
    values[f"{prefix}_META_ROOT"] = str(meta)
    values[f"{prefix}_WORKTREE_ROOT"] = str(root)
    values[f"{prefix}_WORKTREE_KEY"] = key
    temp_root = Path(values[f"{prefix}_DEV_TMP_ROOT"])
    if not temp_root.is_absolute():
        temp_root = root / temp_root
    values["TMPDIR"] = str(temp_root.resolve() / "temporary")
    values["PYTEST_DEBUG_TEMPROOT"] = str(temp_root.resolve() / "pytest")
    values[marker] = json.dumps(defaults)
    return values, selected_paths


EXEC_SHIM = """import json,os,pathlib,sys
os.chdir(sys.argv[1])
os.environ.update(json.loads(os.environ.pop('IMSIGHT_WORKSPACE_RESTORE')))
for name in ('TMPDIR','PYTEST_DEBUG_TEMPROOT'):
    pathlib.Path(os.environ[name]).mkdir(parents=True,exist_ok=True)
os.execvpe(sys.argv[2],sys.argv[2:],os.environ)
"""


def main(argv: Sequence[str] | None = None) -> int:
    """Inspect or execute one explicit realwork.

    Parameters
    ----------
    argv
        Command-line arguments, or ``None`` to read the process arguments.

    Returns
    -------
    int
        Zero after inspection, or two for a configuration error. Execution
        replaces the process and preserves the child command's exit status.
    """

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--meta-root", type=Path, required=True)
    selection = parser.add_mutually_exclusive_group(required=True)
    selection.add_argument("--list", action="store_true")
    selection.add_argument("--worktree")
    parser.add_argument("--environment", default="default")
    parser.add_argument("--pixi", default="pixi")
    parser.add_argument(
        "--direct", action="store_true", help="Use an already provisioned environment"
    )
    parser.add_argument(
        "--meta-code", action="store_true", help="Expose meta imports for an explicit meta tool"
    )
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args(argv)
    try:
        meta = args.meta_root.resolve()
        records = _registrations(meta)
        if args.list:
            report = []
            for key, record in records.items():
                row = {"key": key, **record}
                try:
                    root = _select(meta, key, records)
                    row.update(
                        head=_git(root, "rev-parse", "HEAD"),
                        checked_out_branch=_git(root, "branch", "--show-current"),
                        dirty=str(bool(_git(root, "status", "--porcelain"))),
                    )
                except WorkspaceError as error:
                    row["unavailable"] = str(error)
                report.append(row)
            print(json.dumps(report, indent=2))
            return 0
        root = _select(meta, args.worktree, records)
        config = _load_config(meta)
        env, sources = _environment(
            meta, root, args.worktree, config, os.environ, include_meta=args.meta_code
        )
        command = args.command[1:] if args.command[:1] == ["--"] else args.command
        if not command:
            raise WorkspaceError("Supply a command after --")
        manifest = None
        if not args.direct:
            manifest = _inside(meta, config["workspace"].get("manifest", "pixi.toml"))
            if manifest.name not in {"pixi.toml", "pyproject.toml"}:
                raise WorkspaceError("Pixi needs a supported manifest filename")
        if args.dry_run:
            print(
                json.dumps(
                    {
                        "worktree": args.worktree,
                        "cwd": str(root),
                        "source_paths": [str(p) for p in sources],
                        "environment": args.environment,
                        "command": command,
                    },
                    indent=2,
                )
            )
            return 0
        prefix = config["workspace"]["prefix"]
        restored = {
            name: value
            for name, value in env.items()
            if name.startswith(f"{prefix}_")
            or name in {"PYTHONPATH", "PYTHONNOUSERSITE", "TMPDIR", "PYTEST_DEBUG_TEMPROOT"}
        }
        env["IMSIGHT_WORKSPACE_RESTORE"] = json.dumps(restored)
        shim = ["python", "-c", EXEC_SHIM, str(root), *command]
        for name in ("TMPDIR", "PYTEST_DEBUG_TEMPROOT"):
            Path(env[name]).mkdir(parents=True, exist_ok=True)
        if args.direct:
            os.execvpe(sys.executable, [sys.executable, *shim[1:]], env)
        invocation = [
            args.pixi,
            "run",
            "--manifest-path",
            str(manifest),
            "--environment",
            args.environment,
            "--locked",
            "--executable",
            *shim,
        ]
        os.execvpe(args.pixi, invocation, env)
    except (OSError, ValueError, KeyError) as error:
        print(f"workspace: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
