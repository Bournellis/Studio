from __future__ import annotations

import json
import os
import sys
import tempfile
import unittest
from pathlib import Path

TOOLS = Path(__file__).resolve().parents[1]
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

from execution_lock import ExecutionLock  # noqa: E402
from run_validation import _contract_hash, _isolated_environment, _parse_structured_result, _runner_resources  # noqa: E402


class ExecutionIsolationTests(unittest.TestCase):
    def test_powershell_and_python_use_the_same_mutex_name(self) -> None:
        module = (TOOLS / "estudio_execution_lock.psm1").read_text(encoding="utf-8")
        self.assertIn('"Local\\Estudio.$Resource.v1"', module)

    def test_named_resource_is_stable_and_rejects_injection(self) -> None:
        lock = ExecutionLock("GodotQA", 0)
        self.assertEqual("Local\\Estudio.GodotQA.v1", lock.name)
        with self.assertRaises(ValueError):
            ExecutionLock("GodotQA; Remove-Item", 0)

    def test_runner_resource_inference_is_typed(self) -> None:
        self.assertEqual(
            ["GodotQA"],
            _runner_resources({"runner": "gut_scripts", "lane": "godot", "entrypoint": "res://gut.gd", "args": []}),
        )

    def test_fast_contract_hash_includes_execution_policy(self) -> None:
        manifest = {
            "runners": [
                {
                    "id": "rules", "category": "fast", "runner": "gut_scripts", "lane": "godot",
                    "entrypoint": "res://gut.gd", "args": [],
                }
            ]
        }
        isolated = {"qa": {"user_data_mode_default": "isolated"}}
        shared = {"qa": {"user_data_mode_default": "shared_locked"}}
        self.assertNotEqual(_contract_hash(manifest, isolated), _contract_hash(manifest, shared))
        self.assertEqual(
            ["AndroidQA", "GodotQA"],
            _runner_resources(
                {
                    "runner": "powershell", "lane": "android",
                    "entrypoint": "tools/validate_foundation.ps1", "args": [],
                }
            ),
        )
        self.assertEqual(
            ["AndroidQA"],
            _runner_resources(
                {
                    "runner": "python", "lane": "backend", "entrypoint": "safe.py", "args": [],
                    "execution_resources": ["AndroidQA"],
                }
            ),
        )
        self.assertEqual(
            ["AndroidQA", "GodotQA"],
            _runner_resources(
                {
                    "runner": "gut_scripts", "lane": "godot", "entrypoint": "res://gut.gd", "args": [],
                    "execution_resources": ["AndroidQA"],
                }
            ),
        )

    def test_isolated_environment_redirects_godot_user_roots(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            env = _isolated_environment(root, "JogoDaCopa", "rules_fast")
            for key in ("APPDATA", "LOCALAPPDATA", "GODOT_USER_HOME"):
                self.assertTrue(Path(env[key]).resolve().is_relative_to(root.resolve()))
            self.assertEqual("isolated", env["ESTUDIO_QA_USER_DATA_MODE"])
            self.assertEqual(os.environ.get("PATH"), env.get("PATH"))


class StructuredResultTests(unittest.TestCase):
    def setUp(self) -> None:
        self.runner = {
            "result_contract": {
                "marker": "ESTUDIO_JSON:", "contract": "rules_fast",
                "schema_version": 1, "required": True,
            }
        }

    def test_valid_contract_is_parsed(self) -> None:
        payload = {"contract": "rules_fast", "schema_version": 1, "ok": True, "metrics": {"tests": 3}}
        result, error = _parse_structured_result("noise\nESTUDIO_JSON:" + json.dumps(payload), self.runner)
        self.assertEqual("", error)
        self.assertEqual(3, result["metrics"]["tests"])

    def test_required_contract_cannot_be_missing_or_false(self) -> None:
        self.assertEqual("STRUCTURED_RESULT_MISSING", _parse_structured_result("noise", self.runner)[1])
        payload = {"contract": "rules_fast", "schema_version": 1, "ok": False}
        self.assertEqual(
            "STRUCTURED_RESULT_NOT_OK",
            _parse_structured_result("ESTUDIO_JSON:" + json.dumps(payload), self.runner)[1],
        )

    def test_contract_and_schema_must_match(self) -> None:
        payload = {"contract": "other", "schema_version": 1, "ok": True}
        self.assertIn("STRUCTURED_RESULT_CONTRACT", _parse_structured_result("ESTUDIO_JSON:" + json.dumps(payload), self.runner)[1])


if __name__ == "__main__":
    unittest.main()
