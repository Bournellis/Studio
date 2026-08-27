from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

TOOLS = Path(__file__).resolve().parents[1]
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

from estudio_governance import (  # noqa: E402
    _expected_portfolio_groups,
    check_studio_core_bindings,
)


def git(root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(root), *args],
        text=True,
        encoding="utf-8",
        errors="replace",
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr or result.stdout)
    return result.stdout.strip()


class StudioCoreBindingTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.local = self.root / "Estudio/Projetos/P/STUDIO_CORE.md"
        self.local.parent.mkdir(parents=True)
        self.local.write_text(
            "# Binding\n\n## Binding\n\n"
            "- project_id: `p`\n"
            "- core_revision: `lore.v2`\n"
            "- universe_binding: `shared`\n"
            "- adopted_domains: `[shared_foundation, draxos]`\n",
            encoding="utf-8",
        )
        self.registry_payload = {
            "schema": "studio.core.projects.v2",
            "core_revision": "lore.v2",
            "projects": [{
                "id": "p",
                "workspace": "estudio",
                "kind": "game",
                "project_path": r"D:\Estudio\Projetos\P",
                "local_binding": "STUDIO_CORE.md",
                "universe_binding": "shared",
                "adopted_domains": ["shared_foundation", "draxos"],
            }],
        }
        self.core = self.root / "Studio Core"
        self.registry = self.core / "bindings/PROJECTS.json"
        self.registry.parent.mkdir(parents=True)
        self.registry.write_text(json.dumps(self.registry_payload), encoding="utf-8")
        self.remote = self.root / "Studio-Core.git"
        subprocess.run(["git", "init", "--bare", "-q", str(self.remote)], check=True)
        subprocess.run(["git", "init", "-q", "-b", "main", str(self.core)], check=True)
        git(self.core, "config", "user.email", "tests@estudio.local")
        git(self.core, "config", "user.name", "Estudio Tests")
        git(self.core, "add", "bindings/PROJECTS.json")
        git(self.core, "commit", "-qm", "registry")
        git(self.core, "remote", "add", "origin", str(self.remote.resolve()))
        git(self.core, "push", "-q", "-u", "origin", "main")
        self.config = {
            "projects": [{
                "id": "P",
                "root": "Projetos/P",
                "studio_core_binding": "Projetos/P/STUDIO_CORE.md",
            }],
        }

    def tearDown(self) -> None:
        self.temp.cleanup()

    def check(self, registry: Path | None = None, **kwargs: object):
        return check_studio_core_bindings(
            self.root / "Estudio",
            self.config,
            registry or self.registry,
            expected_core_root=self.core,
            expected_origin_url=str(self.remote.resolve()),
            **kwargs,
        )

    def commit_registry(self, message: str = "registry update", *, push: bool = True) -> None:
        git(self.core, "add", "bindings/PROJECTS.json")
        git(self.core, "commit", "-qm", message)
        if push:
            git(self.core, "push", "-q", "origin", "main")

    def test_matching_binding_passes_without_mutating_inputs(self) -> None:
        before = (self.local.read_bytes(), self.registry.read_bytes())
        report = self.check()
        self.assertFalse(report.failed, report.issues)
        self.assertEqual(1, report.metrics["bindings_checked"])
        self.assertEqual(0, report.metrics["core_git"]["ahead"])
        self.assertEqual(before, (self.local.read_bytes(), self.registry.read_bytes()))

    def test_clean_head_ahead_with_unchanged_registry_passes(self) -> None:
        (self.core / "README.md").write_text("unrelated\n", encoding="utf-8")
        git(self.core, "add", "README.md")
        git(self.core, "commit", "-qm", "unrelated")
        report = self.check()
        self.assertFalse(report.failed, report.issues)
        self.assertEqual(1, report.metrics["core_git"]["ahead"])

    def test_head_ahead_with_changed_registry_fails(self) -> None:
        payload = json.loads(self.registry.read_text(encoding="utf-8"))
        payload["updated_at"] = "future"
        self.registry.write_text(json.dumps(payload), encoding="utf-8")
        self.commit_registry(push=False)
        report = self.check()
        self.assertTrue(any(issue.code == "STUDIO_CORE_REGISTRY_TRACKING_DRIFT" for issue in report.issues))

    def test_dirty_core_fails_before_semantic_use(self) -> None:
        (self.core / "untracked.txt").write_text("dirty\n", encoding="utf-8")
        report = self.check()
        self.assertTrue(any(issue.code == "STUDIO_CORE_GIT_DIRTY" for issue in report.issues))
        self.assertNotIn("bindings_checked", report.metrics)

    def test_modified_working_registry_fails_blob_proof(self) -> None:
        self.registry.write_text(
            self.registry.read_text(encoding="utf-8") + "\n",
            encoding="utf-8",
        )
        report = self.check()
        codes = {issue.code for issue in report.issues}
        self.assertIn("STUDIO_CORE_GIT_DIRTY", codes)
        self.assertIn("STUDIO_CORE_REGISTRY_WORKTREE_DRIFT", codes)

    def test_noncanonical_registry_root_fails(self) -> None:
        alternate = self.root / "Other Core/bindings/PROJECTS.json"
        alternate.parent.mkdir(parents=True)
        alternate.write_bytes(self.registry.read_bytes())
        report = self.check(alternate)
        codes = {issue.code for issue in report.issues}
        self.assertIn("STUDIO_CORE_ROOT_NOT_CANONICAL", codes)
        self.assertIn("STUDIO_CORE_REGISTRY_NOT_CANONICAL", codes)

    def test_wrong_branch_and_origin_fail(self) -> None:
        git(self.core, "switch", "-q", "-c", "other")
        git(self.core, "remote", "set-url", "origin", "https://example.invalid/wrong.git")
        report = self.check()
        codes = {issue.code for issue in report.issues}
        self.assertIn("STUDIO_CORE_GIT_BRANCH", codes)
        self.assertIn("STUDIO_CORE_ORIGIN", codes)

    def test_missing_main_tracking_fails(self) -> None:
        git(self.core, "branch", "--unset-upstream")
        report = self.check()
        self.assertTrue(any(issue.code == "STUDIO_CORE_TRACKING" for issue in report.issues))

    def test_domain_comparison_is_set_based(self) -> None:
        text = self.local.read_text(encoding="utf-8").replace(
            "[shared_foundation, draxos]", "[draxos, shared_foundation]"
        )
        self.local.write_text(text, encoding="utf-8")
        report = self.check()
        self.assertFalse(report.failed, report.issues)

    def test_duplicate_or_malformed_local_domain_fails(self) -> None:
        text = self.local.read_text(encoding="utf-8").replace(
            "[shared_foundation, draxos]", "[draxos, draxos]"
        )
        self.local.write_text(text, encoding="utf-8")
        report = self.check()
        self.assertTrue(any(issue.code == "STUDIO_CORE_DOMAINS_DUPLICATE" for issue in report.issues))

    def test_non_hashable_central_domain_fails_structurally(self) -> None:
        payload = json.loads(self.registry.read_text(encoding="utf-8"))
        payload["projects"][0]["adopted_domains"] = ["shared_foundation", {"invalid": "domain"}]
        self.registry.write_text(json.dumps(payload), encoding="utf-8")
        self.commit_registry()
        report = self.check()
        self.assertTrue(report.failed)
        self.assertTrue(any(issue.code == "STUDIO_CORE_CENTRAL_DOMAINS" for issue in report.issues))

    def test_domain_drift_fails(self) -> None:
        text = self.local.read_text(encoding="utf-8").replace(
            "[shared_foundation, draxos]", "[shared_foundation]"
        )
        self.local.write_text(text, encoding="utf-8")
        report = self.check()
        self.assertTrue(any(issue.code == "STUDIO_CORE_DOMAINS_DRIFT" for issue in report.issues))

    def test_revision_and_universe_drift_fail(self) -> None:
        text = self.local.read_text(encoding="utf-8")
        text = text.replace("core_revision: `lore.v2`", "core_revision: `lore.v1`")
        text = text.replace("universe_binding: `shared`", "universe_binding: `none`")
        self.local.write_text(text, encoding="utf-8")
        report = self.check()
        codes = {issue.code for issue in report.issues}
        self.assertIn("STUDIO_CORE_REVISION_DRIFT", codes)
        self.assertIn("STUDIO_CORE_UNIVERSE_DRIFT", codes)

    def test_central_path_and_project_set_drift_fail(self) -> None:
        payload = json.loads(self.registry.read_text(encoding="utf-8"))
        payload["projects"][0]["project_path"] = r"D:\Estudio\Projetos\Wrong"
        payload["projects"].append({
            "id": "extra",
            "workspace": "estudio",
            "kind": "game",
            "project_path": r"D:\Estudio\Projetos\Extra",
            "local_binding": "STUDIO_CORE.md",
            "universe_binding": "none",
            "adopted_domains": [],
        })
        self.registry.write_text(json.dumps(payload), encoding="utf-8")
        self.commit_registry()
        report = self.check()
        codes = {issue.code for issue in report.issues}
        self.assertIn("STUDIO_CORE_PATH_DRIFT", codes)
        self.assertIn("STUDIO_CORE_LOCAL_SET_DRIFT", codes)

    def test_missing_registry_fails_closed(self) -> None:
        report = self.check(self.core / "bindings/missing.json")
        self.assertTrue(any(issue.code == "STUDIO_CORE_REGISTRY_LOAD" for issue in report.issues))

    def test_isolated_ci_can_defer_only_a_missing_registry(self) -> None:
        report = self.check(self.core / "bindings/missing.json", allow_missing_registry=True)
        self.assertFalse(report.failed, report.issues)
        self.assertTrue(any(issue.code == "STUDIO_CORE_REGISTRY_UNAVAILABLE" for issue in report.issues))

    def test_portfolio_statuses_define_execution_groups(self) -> None:
        config = {"projects": [
            {"id": "A", "root": "Projetos/A"},
            {"id": "B", "root": "Projetos/B"},
            {"id": "C", "root": "Projetos/C"},
        ]}
        rows = {
            "Projetos/A": "P2_IMPLEMENTACAO",
            "Projetos/B": "PAUSADO_TEMPORARIO",
            "Projetos/C": "AGUARDANDO_DECISAO",
        }
        self.assertEqual({"Active": {"A"}, "Paused": {"B"}}, _expected_portfolio_groups(config, rows))


if __name__ == "__main__":
    unittest.main()
