from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

TOOLS = Path(__file__).resolve().parents[1]
ROOT = TOOLS.parent
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

from estudio_governance import (  # noqa: E402
    check_text,
    load_governance,
    parse_metadata,
    validate_governance,
    validate_qa_manifest,
)
from estudio_repository_checks import check_uids, git_snapshot  # noqa: E402
from run_validation import _runner_command  # noqa: E402


def git(cwd: Path, *args: str) -> None:
    subprocess.run(["git", *args], cwd=cwd, check=True, capture_output=True)


class GovernanceContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.config = load_governance(ROOT)

    def test_real_config_is_valid(self) -> None:
        self.assertEqual([], [item for item in validate_governance(self.config, ROOT) if item.severity == "fail"])

    def test_every_schema_is_json(self) -> None:
        for path in (TOOLS / "schemas").glob("*.json"):
            with self.subTest(path=path.name):
                self.assertIsInstance(json.loads(path.read_text(encoding="utf-8")), dict)

    def test_metadata_exact_section_and_none_values(self) -> None:
        metadata = parse_metadata(
            "# Doc\n\n## Metadata\n\n- status: `active`\n- authority: `router`\n"
            "- last_verified: `2026-07-16`\n- review_when: `n/a`\n"
            "- supersedes: `none`\n- superseded_by: `none`\n\n## Body\n"
        )
        self.assertEqual("router", metadata["authority"])
        self.assertEqual("n/a", metadata["review_when"])

    def test_safe_qa_manifest_and_remote_rejection(self) -> None:
        project = next(item for item in self.config["projects"] if item["id"] == "DraxosMobile")
        runner = {
            "id": "server_quick", "category": "fast", "tier": "QA", "lane": "backend",
            "runner": "powershell", "entrypoint": "tools/validate_foundation.ps1",
            "args": ["-Profile", "ServerQuick", "-NoProjectWrites"],
            "profiles": ["FastSuite", "Runtime", "FullLocal"], "timeout_seconds": 30,
            "environments": ["local"], "output_policy": "temporary_only", "local_only": True,
        }
        manifest = {
            "schema_version": 1, "project": "DraxosMobile", "runners": [runner],
            "critical_journey": [{"id": "server_authority", "status": "covered", "runner_ids": ["server_quick"], "evidence": "runner"}],
        }
        report = validate_qa_manifest(manifest, project, self.config, "qa.json", True)
        self.assertFalse(report.failed, report.issues)
        manifest["runners"][0]["args"] += ["-IncludeRemoteReadOnly"]
        report = validate_qa_manifest(manifest, project, self.config, "qa.json", True)
        self.assertTrue(any(item.code == "QA_FORBIDDEN_OPERATION" for item in report.issues))

    def test_runner_command_rejects_publication(self) -> None:
        project = next(item for item in self.config["projects"] if item["id"] == "DraxosMobile")
        runner = {
            "runner": "powershell", "entrypoint": "tools/publish_internal_alpha.ps1",
            "args": [], "local_only": True, "environments": ["local"],
        }
        with self.assertRaises(ValueError):
            _runner_command(ROOT, project, runner, self.config, None)


class RepositoryFixtureTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        git(self.root, "init", "-q")
        git(self.root, "config", "user.email", "tests@estudio.local")
        git(self.root, "config", "user.name", "Estudio Tests")

    def tearDown(self) -> None:
        self.temp.cleanup()

    def _commit_all(self) -> None:
        git(self.root, "add", ".")
        git(self.root, "commit", "-qm", "fixture")

    def test_text_checker_detects_null_byte(self) -> None:
        (self.root / "bad.md").write_bytes(b"hello\x00world")
        self._commit_all()
        config = {"documentation": {"text_extensions": [".md"]}}
        report = check_text(self.root, config)
        self.assertTrue(any(item.code == "TEXT_NULL_BYTE" for item in report.issues))

    def test_uid_checker_accepts_tracked_pair(self) -> None:
        project_root = self.root / "Projetos/P"
        project_root.mkdir(parents=True)
        (project_root / "a.gd").write_text("extends Node\n", encoding="utf-8")
        (project_root / "a.gd.uid").write_text("uid://abc123\n", encoding="utf-8")
        self._commit_all()
        config = {"projects": [{"id": "P", "root": "Projetos/P"}]}
        report = check_uids(self.root, config, {"P"})
        self.assertFalse(report.failed, report.issues)

    def test_uid_duplicates_are_scoped_to_each_godot_project(self) -> None:
        for project in ["P", "Q"]:
            project_root = self.root / f"Projetos/{project}"
            project_root.mkdir(parents=True)
            (project_root / "same.gd").write_text("extends Node\n", encoding="utf-8")
            (project_root / "same.gd.uid").write_text("uid://vendorcopy\n", encoding="utf-8")
        self._commit_all()
        config = {"projects": [{"id": "P", "root": "Projetos/P"}, {"id": "Q", "root": "Projetos/Q"}]}
        report = check_uids(self.root, config, {"P", "Q"})
        self.assertFalse(report.failed, report.issues)

    def test_git_snapshot_is_stable_without_changes(self) -> None:
        (self.root / "tracked.txt").write_text("stable\n", encoding="utf-8")
        self._commit_all()
        self.assertEqual(git_snapshot(self.root), git_snapshot(self.root))


if __name__ == "__main__":
    unittest.main()
