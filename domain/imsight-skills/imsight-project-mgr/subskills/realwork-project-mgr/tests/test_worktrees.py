"""Verify project topology detection and temporary in-repo worktree scripts."""

from __future__ import annotations

import json
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPTS_DIR = Path(__file__).resolve().parents[1] / "scripts"
DETECT_SCRIPT = SCRIPTS_DIR / "detect_project_kind.sh"
CREATE_WORKTREE_SCRIPT = SCRIPTS_DIR / "create_in_repo_worktree.sh"
CREATE_IMPL_SCRIPT = SCRIPTS_DIR / "create_impl_in_repo_worktree.sh"


class RealworkWorktreeTests(unittest.TestCase):
    """Exercise meta-vs-realwork detection and temporary worktree creation."""

    def setUp(self) -> None:
        """Create a clean temporary root for Git fixture repositories."""

        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)

    @staticmethod
    def run_git(repo: Path, *args: str) -> str:
        """Run Git inside a fixture repository with an isolated author identity."""

        return subprocess.check_output(
            [
                "git",
                "-C",
                str(repo),
                "-c",
                "user.name=Fixture",
                "-c",
                "user.email=fixture@example.invalid",
                *args,
            ],
            text=True,
            stderr=subprocess.PIPE,
        ).strip()

    @staticmethod
    def run_script(script: Path, *args: str) -> subprocess.CompletedProcess[str]:
        """Execute a bundled Bash helper and capture stdout and stderr."""

        return subprocess.run(
            ["bash", str(script), *args],
            text=True,
            capture_output=True,
            check=False,
        )

    @staticmethod
    def parse_kv(output: str) -> dict[str, list[str]]:
        """Parse KEY=VALUE lines into a list-valued mapping."""

        parsed: dict[str, list[str]] = {}
        for line in output.splitlines():
            if "=" not in line:
                continue
            key, value = line.split("=", 1)
            parsed.setdefault(key, []).append(value)
        return parsed

    def init_standalone_repo(self, name: str = "standalone") -> Path:
        """Create a committed standalone realwork repository with local ignore rules."""

        repo = self.root / name
        repo.mkdir()
        self.run_git(repo, "init", "--initial-branch=main")
        self.run_git(repo, "config", "user.name", "Fixture")
        self.run_git(repo, "config", "user.email", "fixture@example.invalid")
        (repo / "src").mkdir()
        (repo / "src/app.py").write_text('VALUE = "ok"\n')
        (repo / "pyproject.toml").write_text(
            '[project]\nname = "demo"\nversion = "0.1.0"\n[tool.pixi.workspace]\n'
        )
        (repo / ".gitignore").write_text(".pixi/\n.claude/\n.imsight-arts/worktrees/\n")
        self.run_git(repo, "add", ".")
        self.run_git(repo, "commit", "-m", "Initial commit")
        return repo

    def init_metaproj_repo(self) -> tuple[Path, Path]:
        """Create a metaproj workspace with an absorbed realworks/main submodule."""

        seed = self.init_standalone_repo("seed")
        meta = self.root / "meta"
        meta.mkdir()
        self.run_git(meta, "init", "--initial-branch=metaproj")
        self.run_git(
            meta,
            "-c",
            "protocol.file.allow=always",
            "submodule",
            "add",
            "-b",
            "main",
            str(seed),
            "realworks/main",
        )
        (meta / "meta_configs").mkdir()
        (meta / "meta_configs/workspace.toml").write_text('[workspace]\nprefix = "DEMO"\n')
        self.run_git(meta, "add", ".")
        self.run_git(meta, "commit", "-m", "Initialize metaproj")
        return meta, meta / "realworks/main"

    def test_detects_standalone_realwork_even_with_generic_dirs(self) -> None:
        """Ignore generic dirs like context/openspec/skillset when classifying realworks."""

        repo = self.init_standalone_repo("combined-realwork")
        for dirname in ("context", "openspec", "docs", "skillset", "extern/orphan"):
            (repo / dirname).mkdir(parents=True, exist_ok=True)
        (repo / "pixi.toml").write_text('[workspace]\nname = "demo"\n')
        (repo / "pixi.lock").write_text("version: 6\n")

        result = self.run_script(DETECT_SCRIPT, "--repo", str(repo), "--json")
        self.assertEqual(result.returncode, 0, result.stderr)
        payload = json.loads(result.stdout)
        self.assertEqual(payload["project_kind"], "standalone-realwork")
        self.assertTrue(payload["temp_worktree_allowed"])
        self.assertFalse(payload["is_linked_worktree"])
        self.assertEqual(payload["meta_signatures"], [])
        self.assertEqual(payload["recommended_route"], "realwork-project-mgr")

    def test_detects_meta_project_and_attached_realwork(self) -> None:
        """Distinguish a metaproj root and an attached realworks/main submodule."""

        meta, attached = self.init_metaproj_repo()

        meta_res = self.run_script(DETECT_SCRIPT, "--repo", str(meta), "--json")
        self.assertEqual(meta_res.returncode, 0, meta_res.stderr)
        meta_json = json.loads(meta_res.stdout)
        self.assertEqual(meta_json["project_kind"], "meta-project")
        self.assertFalse(meta_json["temp_worktree_allowed"])
        self.assertIn("realworks_submodules", meta_json["meta_signatures"])
        self.assertIn("meta_configs_workspace_toml", meta_json["meta_signatures"])
        self.assertEqual(meta_json["recommended_route"], "meta-project-mgr")

        attached_res = self.run_script(DETECT_SCRIPT, "--repo", str(attached), "--json")
        self.assertEqual(attached_res.returncode, 0, attached_res.stderr)
        attached_json = json.loads(attached_res.stdout)
        self.assertEqual(attached_json["project_kind"], "attached-realwork")
        self.assertFalse(attached_json["temp_worktree_allowed"])
        self.assertEqual(Path(attached_json["superproject_root"]), meta.resolve())
        self.assertEqual(attached_json["recommended_route"], "meta-project-mgr")

    def test_detects_meta_src_without_realworks_and_ambiguous_hybrid(self) -> None:
        """Classify meta_src-only as meta-project and meta+src as ambiguous."""

        meta_only = self.root / "meta-only"
        meta_only.mkdir()
        self.run_git(meta_only, "init", "--initial-branch=main")
        (meta_only / "meta_src").mkdir()
        (meta_only / "meta_src/tool.py").write_text("x = 1\n")
        self.run_git(meta_only, "add", ".")
        self.run_git(meta_only, "commit", "-m", "Meta tools")

        res_meta = self.run_script(DETECT_SCRIPT, "--repo", str(meta_only))
        self.assertEqual(res_meta.returncode, 0, res_meta.stderr)
        kv_meta = self.parse_kv(res_meta.stdout)
        self.assertEqual(kv_meta["PROJECT_KIND"], ["meta-project"])
        self.assertEqual(kv_meta["TEMP_WORKTREE_ALLOWED"], ["false"])

        hybrid = self.init_standalone_repo("hybrid")
        (hybrid / "meta_configs").mkdir()
        (hybrid / "meta_configs/workspace.toml").write_text('[workspace]\nprefix = "HYB"\n')
        res_hybrid = self.run_script(DETECT_SCRIPT, "--repo", str(hybrid))
        self.assertEqual(res_hybrid.returncode, 0, res_hybrid.stderr)
        kv_hybrid = self.parse_kv(res_hybrid.stdout)
        self.assertEqual(kv_hybrid["PROJECT_KIND"], ["ambiguous"])
        self.assertEqual(kv_hybrid["TEMP_WORKTREE_ALLOWED"], ["false"])
        self.assertEqual(kv_hybrid["RECOMMENDED_ROUTE"], ["clarify-workspace"])

        partial = self.init_standalone_repo("partial-realworks")
        (partial / "realworks").mkdir()
        res_partial = self.run_script(DETECT_SCRIPT, "--repo", str(partial))
        self.assertEqual(res_partial.returncode, 0, res_partial.stderr)
        kv_partial = self.parse_kv(res_partial.stdout)
        self.assertEqual(kv_partial["PROJECT_KIND"], ["ambiguous"])
        self.assertEqual(kv_partial["META_SIGNATURES"], ["realworks_dir"])

    def test_create_in_repo_worktree_links_state_and_rejects_meta(self) -> None:
        """Create temporary clean worktrees on standalone repos and block metaproj."""

        repo = self.init_standalone_repo("clean-wt")
        (repo / ".claude").mkdir()
        (repo / ".pixi").mkdir()
        self.run_git(repo, "branch", "feature/other")

        detached = self.run_script(CREATE_WORKTREE_SCRIPT, "--repo", str(repo))
        self.assertEqual(detached.returncode, 0, detached.stderr)
        kv_detached = self.parse_kv(detached.stdout)
        wt_path = Path(kv_detached["WORKTREE"][0])
        self.assertEqual(kv_detached["PROJECT_KIND"], ["standalone-realwork"])
        self.assertEqual(kv_detached["CHECKOUT_MODE"], ["detached"])
        self.assertEqual(kv_detached["PIXI_MODE"], ["shared"])
        self.assertTrue((wt_path / ".claude").is_symlink())
        self.assertTrue((wt_path / ".pixi").is_symlink())

        # Detection inside the linked worktree marks IS_LINKED_WORKTREE=true, and nesting is blocked.
        nested_detect = self.parse_kv(self.run_script(DETECT_SCRIPT, "--repo", str(wt_path)).stdout)
        self.assertEqual(nested_detect["IS_LINKED_WORKTREE"], ["true"])
        nested_create = self.run_script(CREATE_WORKTREE_SCRIPT, "--repo", str(wt_path))
        self.assertNotEqual(nested_create.returncode, 0)
        self.assertIn("already a linked Git worktree", nested_create.stderr)

        branch_wt = self.run_script(
            CREATE_WORKTREE_SCRIPT,
            "--repo",
            str(repo),
            "--branch",
            "feature/other",
            "--path",
            ".imsight-arts/worktrees/other",
        )
        self.assertEqual(branch_wt.returncode, 0, branch_wt.stderr)
        kv_branch = self.parse_kv(branch_wt.stdout)
        self.assertEqual(kv_branch["CHECKOUT_MODE"], ["branch"])
        self.assertEqual(kv_branch["BRANCH"], ["feature/other"])

        meta, attached = self.init_metaproj_repo()
        meta_fail = self.run_script(CREATE_WORKTREE_SCRIPT, "--repo", str(meta))
        self.assertNotEqual(meta_fail.returncode, 0)
        self.assertIn("meta-project-mgr->manage-realworks()", meta_fail.stderr)

        attached_fail = self.run_script(CREATE_WORKTREE_SCRIPT, "--repo", str(attached))
        self.assertNotEqual(attached_fail.returncode, 0)
        self.assertIn("attached realwork", attached_fail.stderr)

    def test_create_impl_worktree_snapshots_dirty_state_and_blocks_meta(self) -> None:
        """Snapshot uncommitted edits into isolated branch without mutating primary repo."""

        repo = self.init_standalone_repo("impl-wt")
        (repo / ".claude").mkdir()
        (repo / ".pixi").mkdir()
        (repo / "src/app.py").write_text('VALUE = "dirty"\n')
        (repo / "src/extra.py").write_text("EXTRA = 1\n")

        res = self.run_script(
            CREATE_IMPL_SCRIPT,
            "--repo",
            str(repo),
            "--topic",
            "My Feature!",
            "--kind",
            "feature",
        )
        self.assertEqual(res.returncode, 0, res.stderr)
        kv = self.parse_kv(res.stdout)
        self.assertEqual(kv["PROJECT_KIND"], ["standalone-realwork"])
        self.assertEqual(kv["IMPL_BRANCH"], ["feature/my-feature"])
        self.assertEqual(kv["PIXI_MODE"], ["shared"])

        wt_path = Path(kv["WORKTREE"][0])
        self.assertEqual((wt_path / "src/app.py").read_text(), 'VALUE = "dirty"\n')
        self.assertEqual((wt_path / "src/extra.py").read_text(), "EXTRA = 1\n")
        self.assertTrue((wt_path / ".claude").is_symlink())
        self.assertTrue((wt_path / ".pixi").is_symlink())
        self.assertEqual(self.run_git(repo, "branch", "--show-current"), "main")
        self.assertIn(".imsight-arts/impl-branches/", (repo / ".gitignore").read_text())

        meta, attached = self.init_metaproj_repo()
        self.assertNotEqual(
            self.run_script(
                CREATE_IMPL_SCRIPT, "--repo", str(meta), "--topic", "blocked"
            ).returncode,
            0,
        )
        self.assertNotEqual(
            self.run_script(
                CREATE_IMPL_SCRIPT, "--repo", str(attached), "--topic", "blocked"
            ).returncode,
            0,
        )


if __name__ == "__main__":
    unittest.main()
