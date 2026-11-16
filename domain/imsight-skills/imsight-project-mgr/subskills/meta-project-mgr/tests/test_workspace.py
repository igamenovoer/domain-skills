"""Verify the shipped template against local Git fixtures, never live projects."""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "assets/workspace.py"
SPEC = importlib.util.spec_from_file_location("workspace_template", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class WorkspaceTests(unittest.TestCase):
    """Exercise identity, source isolation, and resource behavior with native Git."""

    def setUp(self) -> None:
        """Create one meta repository and two independent local submodules."""

        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.seed = self.root / "seed"
        self.seed.mkdir()
        self.run_git(self.seed, "init", "--initial-branch=main")
        for path, body in {
            "src/product.py": 'IDENTITY = "main"\n',
            "extern/tracked/dep/src/dependency.py": 'IDENTITY = "main-dep"\n',
            "pyproject.toml": '[project]\nname = "fixture"\nversion = "0.1"\n',
        }.items():
            target = self.seed / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(body)
        self.run_git(self.seed, "add", ".")
        self.run_git(self.seed, "commit", "-m", "Seed")
        self.meta = self.root / "meta"
        self.meta.mkdir()
        self.run_git(self.meta, "init", "--initial-branch=metaproj")
        self.run_git(
            self.meta,
            "-c",
            "protocol.file.allow=always",
            "submodule",
            "add",
            "-b",
            "main",
            str(self.seed),
            "realworks/main",
        )
        self.run_git(self.seed, "switch", "-c", "feature/example")
        (self.seed / "src/product.py").write_text('IDENTITY = "feature"\n')
        (self.seed / "extern/tracked/dep/src/dependency.py").write_text(
            'IDENTITY = "feature-dep"\n'
        )
        self.run_git(self.seed, "add", ".")
        self.run_git(self.seed, "commit", "-m", "Feature")
        self.run_git(
            self.meta,
            "-c",
            "protocol.file.allow=always",
            "submodule",
            "add",
            "-b",
            "feature/example",
            str(self.seed),
            "realworks/feature/example",
        )
        (self.meta / "meta_configs").mkdir()
        (self.meta / "meta_configs/workspace.toml").write_text(
            '[workspace]\nprefix = "EXAMPLE"\nmanifest = "pixi.toml"\n'
            'source_paths = ["src", "."]\n'
            'dependency_paths = ["extern/tracked/dep/src"]\n'
            '[resources]\nCONTEXT_ROOT = "context"\n'
        )
        (self.meta / "pixi.toml").write_text('[workspace]\nname = "fixture"\n')
        self.run_git(self.meta, "add", ".")
        self.run_git(self.meta, "commit", "-m", "Register fixture checkouts")
        self.main = self.meta / "realworks/main"
        self.feature = self.meta / "realworks/feature/example"

    @staticmethod
    def run_git(root: Path, *args: str) -> str:
        """Execute Git without modifying user configuration."""

        return subprocess.check_output(
            [
                "git",
                "-C",
                str(root),
                "-c",
                "user.name=Fixture",
                "-c",
                "user.email=fixture@example.invalid",
                *args,
            ],
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()

    def run_template(self, *args: str) -> subprocess.CompletedProcess[str]:
        """Execute the template with an explicit meta root and no installation."""

        return subprocess.run(
            [sys.executable, str(SCRIPT), "--meta-root", str(self.meta), *args],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_selection_rejects_ambiguous_or_wrong_checkouts(self) -> None:
        """Reject omitted, traversing, mismatched, and nonregistered targets."""

        records = MODULE._registrations(self.meta)
        for key in ("../seed", "feature/../main", "/main", "missing"):
            with self.assertRaises(MODULE.WorkspaceError):
                MODULE._select(self.meta, key, records)
        self.assertNotEqual(self.run_template("--direct", "--", "true").returncode, 0)
        self.run_git(self.main, "switch", "-c", "wrong")
        with self.assertRaises(MODULE.WorkspaceError):
            MODULE._select(self.meta, "main", records)

    def test_detached_pin_and_read_only_listing(self) -> None:
        """Accept the recorded detached commit and report local state without writes."""

        records = MODULE._registrations(self.meta)
        self.run_git(self.main, "switch", "--detach")
        self.assertEqual(MODULE._select(self.meta, "main", records), self.main)
        before = self.run_git(self.meta, "status", "--porcelain")
        result = self.run_template("--list")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(json.loads(result.stdout)), 2)
        self.assertEqual(self.run_git(self.meta, "status", "--porcelain"), before)

    def test_resources_precedence_and_nested_identity(self) -> None:
        """Resolve relative defaults from checkout roots and preserve explicit values."""

        (self.meta / ".env").write_text('EXAMPLE_DEV_CONTEXT_ROOT="../../meta-input"\n')
        (self.feature / ".env").write_text("EXAMPLE_DEV_CONTEXT_ROOT=../../../feature-input\n")
        config = MODULE._load_config(self.meta)
        env, _ = MODULE._environment(self.meta, self.feature, "feature/example", config, {})
        self.assertEqual(
            (self.feature / env["EXAMPLE_DEV_CONTEXT_ROOT"]).resolve(), self.meta / "feature-input"
        )
        self.assertEqual(env["EXAMPLE_DEV_TMP_ROOT"], "../../../tmp/feature/example")
        override, _ = MODULE._environment(
            self.meta,
            self.feature,
            "feature/example",
            config,
            {"EXAMPLE_DEV_CONTEXT_ROOT": "/explicit"},
        )
        self.assertEqual(override["EXAMPLE_DEV_CONTEXT_ROOT"], "/explicit")
        first, _ = MODULE._environment(self.meta, self.main, "main", config, {})
        second, _ = MODULE._environment(self.meta, self.feature, "feature/example", config, first)
        self.assertEqual(second["EXAMPLE_DEV_TMP_ROOT"], "../../../tmp/feature/example")

    def test_missing_dependency_and_external_symlink_rejected(self) -> None:
        """Never substitute another checkout's dependency source or outside tree."""

        (self.main / "extern/tracked/dep/src").rename(self.main / "extern/tracked/dep/moved")
        with self.assertRaises(MODULE.WorkspaceError):
            MODULE._environment(self.meta, self.main, "main", MODULE._load_config(self.meta), {})
        (self.feature / "src/product.py").unlink()
        (self.feature / "src").rmdir()
        (self.feature / "src").symlink_to(self.seed / "src", target_is_directory=True)
        with self.assertRaises(MODULE.WorkspaceError):
            MODULE._environment(
                self.meta, self.feature, "feature/example", MODULE._load_config(self.meta), {}
            )

    def test_absolute_source_configuration_is_rejected(self) -> None:
        """Keep configured source roots portable and checkout-relative."""

        with self.assertRaisesRegex(MODULE.WorkspaceError, "relative to its owner"):
            MODULE._paths(self.main, [str(self.main / "src")])

    def test_dry_run_creates_no_state_and_prints_no_secret(self) -> None:
        """Keep dry-run inspection free of outputs and environment values."""

        (self.main / ".env").write_text("EXAMPLE_SECRET=never-print-this\n")
        result = self.run_template("--worktree", "main", "--dry-run", "--", "echo", "ok")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("never-print-this", result.stdout + result.stderr)
        self.assertFalse((self.meta / "tmp").exists())

    def test_concurrent_commands_import_their_own_sources(self) -> None:
        """Run both product/dependency identities in the same interpreter environment."""

        code = "import json,os,product,dependency; print(json.dumps([product.IDENTITY,dependency.IDENTITY,os.getcwd(),os.environ['TMPDIR']]))"
        processes = [
            subprocess.Popen(
                [
                    sys.executable,
                    str(SCRIPT),
                    "--meta-root",
                    str(self.meta),
                    "--worktree",
                    key,
                    "--direct",
                    "--",
                    sys.executable,
                    "-c",
                    code,
                ],
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            for key in ("main", "feature/example")
        ]
        results = []
        for process in processes:
            stdout, stderr = process.communicate(timeout=20)
            self.assertEqual(process.returncode, 0, stderr)
            results.append(json.loads(stdout))
        self.assertEqual(results[0][:2], ["main", "main-dep"])
        self.assertEqual(results[1][:2], ["feature", "feature-dep"])
        self.assertEqual(results[0][2], str(self.main))
        self.assertEqual(results[1][2], str(self.feature))
        self.assertNotEqual(results[0][3], results[1][3])

    def test_activation_cannot_replace_source_selection(self) -> None:
        """Restore cwd and source paths after a fake Pixi activation alters both."""

        fake = self.root / "fake-pixi"
        fake.write_text(
            f"#!{sys.executable}\nimport os,sys\n"
            "assert os.path.isdir(os.environ['TMPDIR'])\n"
            "os.chdir('/')\nos.environ['PYTHONPATH']='/wrong/source'\n"
            "args=sys.argv[sys.argv.index('--executable')+1:]\n"
            "args[0]=sys.executable\nos.execvpe(args[0],args,os.environ)\n"
        )
        fake.chmod(0o755)
        code = "import os,product; print(product.IDENTITY); print(os.getcwd())"
        result = self.run_template(
            "--worktree", "feature/example", "--pixi", str(fake), "--", sys.executable, "-c", code
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), ["feature", str(self.feature)])

    def test_uninitialized_checkout_remains_listed(self) -> None:
        """List recorded identity without adopting an absent checkout."""

        self.run_git(self.meta, "submodule", "deinit", "--", "realworks/main")
        result = self.run_template("--list")
        self.assertEqual(result.returncode, 0, result.stderr)
        main = next(row for row in json.loads(result.stdout) if row["key"] == "main")
        self.assertIn("unavailable", main)
        self.assertIn("pin", main)

    def test_linked_worktree_cannot_impersonate_a_submodule(self) -> None:
        """Reject shared worktree administration even if a gitlink names the path."""

        path = self.meta / "realworks/linked"
        self.run_git(self.seed, "worktree", "add", "--detach", str(path), "main")
        self.run_git(
            self.meta, "config", "-f", ".gitmodules", "submodule.linked.path", "realworks/linked"
        )
        self.run_git(self.meta, "config", "-f", ".gitmodules", "submodule.linked.branch", "main")
        self.run_git(
            self.meta,
            "update-index",
            "--add",
            "--cacheinfo",
            "160000",
            self.run_git(self.seed, "rev-parse", "main"),
            "realworks/linked",
        )
        with self.assertRaisesRegex(MODULE.WorkspaceError, "independent submodule"):
            MODULE._select(self.meta, "linked", MODULE._registrations(self.meta))

    def test_direct_mode_propagates_exit_without_requiring_pixi(self) -> None:
        """Use the provided environment without an irrelevant Pixi manifest."""

        (self.meta / "pixi.toml").unlink()
        result = self.run_template(
            "--worktree", "main", "--direct", "--", sys.executable, "-c", "raise SystemExit(7)"
        )
        self.assertEqual(result.returncode, 7, result.stderr)

    def test_same_repository_bootstrap_and_safe_removal(self) -> None:
        """Exercise the documented one-repository branch/submodule lifecycle."""

        project = self.root / "self-project"
        project.mkdir()
        self.run_git(project, "init", "--initial-branch=main")
        (project / "src").mkdir()
        (project / "src/product.py").write_text('IDENTITY = "product"\n')
        self.run_git(project, "add", ".")
        self.run_git(project, "commit", "-m", "Functional seed")
        seed = self.run_git(project, "rev-parse", "HEAD")
        self.run_git(project, "switch", "-c", "metaproj")
        self.run_git(project, "rm", "-r", "src")
        self.run_git(
            project,
            "clone",
            "--no-hardlinks",
            "--branch",
            "main",
            "--no-checkout",
            str(project),
            "realworks/main",
        )
        self.run_git(project / "realworks/main", "switch", "main")
        self.run_git(
            project,
            "-c",
            "protocol.file.allow=always",
            "submodule",
            "add",
            "-b",
            "main",
            str(project),
            "realworks/main",
        )
        self.run_git(project, "submodule", "absorbgitdirs", "--", "realworks/main")
        self.run_git(project, "commit", "-am", "Register main")
        registered = MODULE._registrations(project)
        self.assertEqual(registered["main"]["pin"], seed)
        self.assertEqual(MODULE._select(project, "main", registered), project / "realworks/main")
        self.assertFalse((project / "src").exists())
        self.assertTrue((project / "realworks/main/src/product.py").is_file())
        self.run_git(project, "submodule", "deinit", "--", "realworks/main")
        self.run_git(project, "rm", "--", "realworks/main")
        self.assertTrue((project / ".git/modules/realworks/main").is_dir())
        self.assertEqual(self.run_git(project, "rev-parse", "main"), seed)


if __name__ == "__main__":
    unittest.main()
