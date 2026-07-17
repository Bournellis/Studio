from __future__ import annotations

import hashlib
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

TOOLS = Path(__file__).resolve().parents[1]
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

from documentation_lite import check_documentation_lite  # noqa: E402


def run(root: Path, *args: str) -> str:
    result = subprocess.run(args, cwd=root, text=True, capture_output=True, check=False)
    if result.returncode:
        raise AssertionError(f"{' '.join(args)} failed: {result.stderr}")
    return result.stdout.strip()


class DocumentationLiteFixture(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        run(self.root, "git", "init", "-q")
        run(self.root, "git", "config", "user.email", "test@example.com")
        run(self.root, "git", "config", "user.name", "Test")
        self.register = self.root / "08_Coordenacao_Agentes/Registers/documentation-lite-v2"
        self.register.mkdir(parents=True)
        (self.root / "08_Coordenacao_Agentes/History").mkdir(parents=True)
        (self.root / "08_Coordenacao_Agentes/History/2026-07.md").write_text("# History\n\n| record_id | outcome |\n|---|---|\n| record_a | absorbed |\n", encoding="utf-8")
        (self.root / "authority.md").write_text("# Durable authority\n", encoding="utf-8")
        (self.root / "source.md").write_text("# Historical source\n\nUnique detail.\n", encoding="utf-8")
        self.auth_path = self.register / "authorization.json"
        self.auth_path.write_text(json.dumps({
            "schema_version": 1, "status": "pending", "approved_by": "",
            "approved_at": "", "index_sha256": "", "evidence": "approval pending",
        }, indent=2) + "\n", encoding="utf-8")
        run(self.root, "git", "add", ".")
        run(self.root, "git", "commit", "-qm", "baseline")
        self.baseline = run(self.root, "git", "rev-parse", "HEAD")
        self.tag = "recovery/estudio-documentation-lite/v2/test"
        run(self.root, "git", "tag", "-a", self.tag, self.baseline, "-m", "recovery")
        self.config = {
            "documentation_lite": {
                "manifest_index": "08_Coordenacao_Agentes/Registers/documentation-lite-v2/index.json"
            }
        }

    def tearDown(self) -> None:
        self.temp.cleanup()

    def prepare(self, *, approved: bool = False, path: str = "source.md", corrupt_hash: bool = False) -> str:
        data = subprocess.run(
            ["git", "show", f"{self.baseline}:source.md"], cwd=self.root,
            capture_output=True, check=True,
        ).stdout
        blob = run(self.root, "git", "rev-parse", f"{self.baseline}:source.md")
        digest = hashlib.sha256(data).hexdigest()
        if corrupt_hash:
            digest = "0" * 64
        record = {
            "record_id": "record_a", "date": "2026-07-17", "scope": "test",
            "outcome": "Unique detail absorbed", "human_gate": "not_required",
            "technical_result_ref": f"{self.baseline}:source.md", "validation": "fixture",
            "evidence": "authority.md", "source_count": 1,
            "ledger_path": "08_Coordenacao_Agentes/History/2026-07.md",
            "source_paths": [path],
        }
        entry = {
            "path": path, "kind": "historical_document", "classification": "technical_contract",
            "byte_count": len(data), "line_count": len(data.splitlines()), "source_blob": blob,
            "source_sha256": digest, "disposition": "remove_with_ledger",
            "unique_content_status": "absorbed", "record_id": "record_a",
            "retained_authorities": ["authority.md"],
        }
        batch = {
            "schema_version": 2, "batch_id": "test_batch", "scope": "test", "project": "Test",
            "baseline_commit": self.baseline, "recovery_tag": self.tag,
            "authorization_ref": "08_Coordenacao_Agentes/Registers/documentation-lite-v2/authorization.json",
            "entries": [entry], "records": [record],
        }
        batch_path = self.register / "test_batch.json"
        batch_path.write_text(json.dumps(batch, indent=2) + "\n", encoding="utf-8")
        manifest_sha = hashlib.sha256(batch_path.read_bytes()).hexdigest()
        index = {
            "schema_version": 2, "enforcement_mode": "audit",
            "authorization_path": "08_Coordenacao_Agentes/Registers/documentation-lite-v2/authorization.json",
            "batches": [{
                "batch_id": "test_batch", "manifest": "08_Coordenacao_Agentes/Registers/documentation-lite-v2/test_batch.json",
                "receipt": "08_Coordenacao_Agentes/Receipts/DocumentationLite/test_batch.json",
                "manifest_sha256": manifest_sha,
            }],
        }
        index_path = self.register / "index.json"
        index_path.write_text(json.dumps(index, indent=2) + "\n", encoding="utf-8")
        index_sha = hashlib.sha256(index_path.read_bytes()).hexdigest()
        if approved:
            self.auth_path.write_text(json.dumps({
                "schema_version": 1, "status": "approved", "approved_by": "Fabio",
                "approved_at": "2026-07-17T12:00:00-03:00", "index_sha256": index_sha,
                "evidence": f"Fabio approved {index_sha}",
            }, indent=2) + "\n", encoding="utf-8")
        run(self.root, "git", "add", ".")
        run(self.root, "git", "commit", "-qm", "prepared manifest")
        return index_sha


class DocumentationLiteTests(DocumentationLiteFixture):
    def test_audit_accepts_prepared_batch_and_reports_pending_authorization(self) -> None:
        self.prepare()
        report = check_documentation_lite(self.root, self.config)
        self.assertFalse(report.failed, report.issues)
        self.assertTrue(any(item.code == "DOCLITE_AUTH_PENDING" for item in report.issues))

    def test_traversal_is_rejected(self) -> None:
        self.prepare(path="../source.md")
        report = check_documentation_lite(self.root, self.config)
        self.assertTrue(any(item.code in {"DOCLITE_ENTRY_PATH", "DOCLITE_RECORD_PATH"} for item in report.issues))

    def test_source_hash_drift_is_rejected(self) -> None:
        self.prepare(corrupt_hash=True)
        report = check_documentation_lite(self.root, self.config)
        self.assertTrue(any(item.code == "DOCLITE_SHA_MISMATCH" for item in report.issues))

    def test_execute_requires_exact_approval(self) -> None:
        index_sha = self.prepare()
        report = check_documentation_lite(
            self.root, self.config, mode="Execute", batch_id="test_batch",
            confirm_manifest_hash=index_sha,
        )
        self.assertTrue(any(item.code == "DOCLITE_EXECUTE_AUTH" for item in report.issues))
        self.assertTrue((self.root / "source.md").is_file())

    def test_execute_and_verify_are_recoverable_and_verify_is_idempotent(self) -> None:
        index_sha = self.prepare(approved=True)
        report = check_documentation_lite(
            self.root, self.config, mode="Execute", batch_id="test_batch",
            confirm_manifest_hash=index_sha,
        )
        self.assertFalse(report.failed, report.issues)
        self.assertFalse((self.root / "source.md").exists())
        receipt = self.root / "08_Coordenacao_Agentes/Receipts/DocumentationLite/test_batch.json"
        self.assertTrue(receipt.is_file())
        first = check_documentation_lite(self.root, self.config, mode="Verify", batch_id="test_batch")
        second = check_documentation_lite(self.root, self.config, mode="Verify", batch_id="test_batch")
        self.assertFalse(first.failed, first.issues)
        self.assertEqual(first.as_dict(), second.as_dict())
        recovered = subprocess.run(
            ["git", "show", f"{self.baseline}:source.md"], cwd=self.root,
            capture_output=True, check=True,
        ).stdout
        self.assertEqual(hashlib.sha256(recovered).hexdigest(), json.loads(receipt.read_text())["entries"][0]["sha256"])

    def test_execute_is_not_silently_repeatable(self) -> None:
        index_sha = self.prepare(approved=True)
        first = check_documentation_lite(
            self.root, self.config, mode="Execute", batch_id="test_batch",
            confirm_manifest_hash=index_sha,
        )
        self.assertFalse(first.failed, first.issues)
        run(self.root, "git", "add", ".")
        run(self.root, "git", "commit", "-qm", "cutover")
        second = check_documentation_lite(
            self.root, self.config, mode="Execute", batch_id="test_batch",
            confirm_manifest_hash=index_sha,
        )
        self.assertTrue(any(item.code == "DOCLITE_ALREADY_APPLIED" for item in second.issues))

    def test_wrong_tag_target_is_rejected(self) -> None:
        self.prepare()
        run(self.root, "git", "tag", "-f", "-a", self.tag, "HEAD", "-m", "wrong")
        report = check_documentation_lite(self.root, self.config)
        self.assertTrue(any(item.code == "DOCLITE_TAG_COMMIT" for item in report.issues))


if __name__ == "__main__":
    unittest.main()
