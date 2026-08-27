from __future__ import annotations

import json
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


class StudioCoreBindingTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.local = self.root / "Projetos/P/STUDIO_CORE.md"
        self.local.parent.mkdir(parents=True)
        self.local.write_text(
            "# Binding\n\n## Binding\n\n"
            "- project_id: `p`\n"
            "- core_revision: `lore.v2`\n"
            "- universe_binding: `shared`\n"
            "- adopted_domains: `[shared_foundation, draxos]`\n",
            encoding="utf-8",
        )
        self.registry = self.root / "PROJECTS.json"
        self.registry.write_text(json.dumps({
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
        }), encoding="utf-8")
        self.config = {
            "projects": [{
                "id": "P",
                "root": "Projetos/P",
                "studio_core_binding": "Projetos/P/STUDIO_CORE.md",
            }],
        }

    def tearDown(self) -> None:
        self.temp.cleanup()

    def test_matching_binding_passes_without_mutating_inputs(self) -> None:
        before = (self.local.read_bytes(), self.registry.read_bytes())
        report = check_studio_core_bindings(self.root, self.config, self.registry)
        self.assertFalse(report.failed, report.issues)
        self.assertEqual(1, report.metrics["bindings_checked"])
        self.assertEqual(before, (self.local.read_bytes(), self.registry.read_bytes()))

    def test_domain_drift_fails(self) -> None:
        text = self.local.read_text(encoding="utf-8").replace(
            "[shared_foundation, draxos]", "[shared_foundation]"
        )
        self.local.write_text(text, encoding="utf-8")
        report = check_studio_core_bindings(self.root, self.config, self.registry)
        self.assertTrue(any(issue.code == "STUDIO_CORE_DOMAINS_DRIFT" for issue in report.issues))

    def test_revision_and_universe_drift_fail(self) -> None:
        text = self.local.read_text(encoding="utf-8")
        text = text.replace("core_revision: `lore.v2`", "core_revision: `lore.v1`")
        text = text.replace("universe_binding: `shared`", "universe_binding: `none`")
        self.local.write_text(text, encoding="utf-8")
        report = check_studio_core_bindings(self.root, self.config, self.registry)
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
        report = check_studio_core_bindings(self.root, self.config, self.registry)
        codes = {issue.code for issue in report.issues}
        self.assertIn("STUDIO_CORE_PATH_DRIFT", codes)
        self.assertIn("STUDIO_CORE_LOCAL_SET_DRIFT", codes)

    def test_missing_registry_fails_closed(self) -> None:
        report = check_studio_core_bindings(self.root, self.config, self.root / "missing.json")
        self.assertTrue(any(issue.code == "STUDIO_CORE_REGISTRY_LOAD" for issue in report.issues))

    def test_isolated_ci_can_defer_only_a_missing_registry(self) -> None:
        report = check_studio_core_bindings(
            self.root, self.config, self.root / "missing.json", allow_missing_registry=True
        )
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
