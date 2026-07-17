"""Regression tests for the local-only DraxosMobile receipt helper."""

from __future__ import annotations

import copy
import importlib.util
import io
import json
import sys
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path


MODULE_PATH = Path(__file__).resolve().parents[1] / "mobile_candidate_receipts.py"
SPEC = importlib.util.spec_from_file_location("mobile_candidate_receipts", MODULE_PATH)
assert SPEC and SPEC.loader
RECEIPTS = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = RECEIPTS
SPEC.loader.exec_module(RECEIPTS)


class MobileCandidateReceiptTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = Path(self.temp_dir.name)
        (self.root / "build").mkdir()
        (self.root / "reports").mkdir()
        (self.root / "evidence").mkdir()
        self.artifact = self.root / "build" / "candidate.apk"
        self.validation = self.root / "reports" / "docsonly.json"
        self.android_evidence = self.root / "evidence" / "android.json"
        self.physical_evidence = self.root / "evidence" / "physical.json"
        self.artifact.write_bytes(b"fixed candidate bytes")
        self.validation.write_text('{"result":"pass"}\n', encoding="utf-8")
        self.android_evidence.write_text('{"emulator":"pass"}\n', encoding="utf-8")
        self.physical_evidence.write_text('{"device":"pass","serial":"redacted"}\n', encoding="utf-8")
        self.out_root = self.root / "build" / "qa" / "mobile"

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def make_candidate(self, *, created_at: str = "2026-07-17T12:00:00Z") -> dict:
        return RECEIPTS.candidate_receipt(
            self.root,
            self.artifact,
            source_sha="a" * 40,
            export_mode="release",
            min_sdk=24,
            target_sdk=35,
            compile_sdk=35,
            godot_version="4.6.2-stable",
            git_snapshot_sha256="b" * 64,
            validation_reports=["docs_check=reports/docsonly.json"],
            created_at_utc=created_at,
        )

    def write_receipt(self, payload: dict) -> Path:
        target = RECEIPTS.target_for(self.out_root, payload)
        self.assertTrue(RECEIPTS.immutable_write(target, payload, True))
        return target

    def make_qualification(self, candidate_path: Path, kind: str) -> dict:
        evidence = self.android_evidence if kind == "android_check" else self.physical_evidence
        profile = "android_reference_target" if kind == "android_check" else "physical_reference"
        return RECEIPTS.qualification_receipt(
            self.root,
            candidate_path,
            self.artifact,
            qualification_kind=kind,
            result="pass",
            profile_ids=[profile],
            performed_by="Fabio",
            evidence_reports=[f"{kind}={evidence.relative_to(self.root).as_posix()}"],
            created_at_utc="2026-07-17T13:00:00Z",
        )

    def test_cli_is_dry_run_by_default(self) -> None:
        stdout = io.StringIO()
        with redirect_stdout(stdout):
            result = RECEIPTS.main(
                [
                    "candidate",
                    "--project-root", str(self.root),
                    "--artifact", "build/candidate.apk",
                    "--source-sha", "a" * 40,
                    "--export-mode", "release",
                    "--resolved-min-sdk", "24",
                    "--resolved-target-sdk", "35",
                    "--resolved-compile-sdk", "35",
                    "--godot-version", "4.6.2-stable",
                    "--git-snapshot-sha256", "b" * 64,
                    "--validation-report", "docs_check=reports/docsonly.json",
                    "--created-at-utc", "2026-07-17T12:00:00Z",
                ]
            )
        output = json.loads(stdout.getvalue())
        self.assertEqual(0, result)
        self.assertTrue(output["dry_run"])
        self.assertFalse(output["write_performed"])
        self.assertFalse((self.out_root / "candidates").exists())

    def test_candidate_write_is_append_only(self) -> None:
        payload = self.make_candidate()
        target = self.write_receipt(payload)
        self.assertFalse(RECEIPTS.immutable_write(target, payload, True))
        changed = copy.deepcopy(payload)
        changed["created_at_utc"] = "2026-07-17T12:00:01Z"
        with self.assertRaisesRegex(RECEIPTS.ReceiptError, "immutable receipt"):
            RECEIPTS.immutable_write(target, changed, True)

    def test_artifact_or_validation_mutation_invalidates_candidate(self) -> None:
        candidate_path = self.write_receipt(self.make_candidate())
        self.artifact.write_bytes(b"mutated candidate")
        with self.assertRaisesRegex(RECEIPTS.ReceiptError, "artifact no longer matches"):
            RECEIPTS.load_candidate_with_artifact(self.root, candidate_path)

        self.artifact.write_bytes(b"fixed candidate bytes")
        self.validation.write_text('{"result":"changed"}\n', encoding="utf-8")
        with self.assertRaisesRegex(RECEIPTS.ReceiptError, "validation report"):
            RECEIPTS.load_candidate_with_artifact(self.root, candidate_path)

    def test_physical_gate_rejects_agent_identity(self) -> None:
        candidate_path = self.write_receipt(self.make_candidate())
        with self.assertRaisesRegex(RECEIPTS.ReceiptError, "human tester"):
            RECEIPTS.qualification_receipt(
                self.root,
                candidate_path,
                self.artifact,
                qualification_kind="physical_gate",
                result="pass",
                profile_ids=["physical_reference"],
                performed_by="Codex",
                evidence_reports=["physical_gate=evidence/physical.json"],
                created_at_utc="2026-07-17T13:00:00Z",
            )

    def test_promotion_requires_same_hash_android_and_physical_passes(self) -> None:
        candidate_path = self.write_receipt(self.make_candidate())
        android_path = self.write_receipt(self.make_qualification(candidate_path, "android_check"))
        physical_path = self.write_receipt(self.make_qualification(candidate_path, "physical_gate"))

        with self.assertRaisesRegex(RECEIPTS.ReceiptError, "android_check and physical_gate"):
            RECEIPTS.promotion_receipt(
                self.root,
                candidate_path,
                self.artifact,
                qualification_paths=[android_path],
                decision_reference="FABIO-2026-07-17-01",
                authorized_by="Fabio",
                promotion_target="internal_alpha_review",
                supersedes_receipt_sha256=None,
                created_at_utc="2026-07-17T14:00:00Z",
            )

        promotion = RECEIPTS.promotion_receipt(
            self.root,
            candidate_path,
            self.artifact,
            qualification_paths=[android_path, physical_path],
            decision_reference="FABIO-2026-07-17-01",
            authorized_by="Fabio",
            promotion_target="internal_alpha_review",
            supersedes_receipt_sha256=None,
            created_at_utc="2026-07-17T14:00:00Z",
        )
        promotion_path = self.write_receipt(promotion)
        self.assertEqual(self.make_candidate()["artifact"]["sha256"], RECEIPTS.verify_receipt(self.root, promotion_path))
        self.assertFalse(promotion["publication_executed"])
        self.assertEqual("recorded_local_only", promotion["record_status"])

    def test_promotion_rejects_agent_authorization(self) -> None:
        candidate_path = self.write_receipt(self.make_candidate())
        android_path = self.write_receipt(self.make_qualification(candidate_path, "android_check"))
        physical_path = self.write_receipt(self.make_qualification(candidate_path, "physical_gate"))
        with self.assertRaisesRegex(RECEIPTS.ReceiptError, "human decision owner"):
            RECEIPTS.promotion_receipt(
                self.root,
                candidate_path,
                self.artifact,
                qualification_paths=[android_path, physical_path],
                decision_reference="FABIO-2026-07-17-01",
                authorized_by="Codex",
                promotion_target="internal_alpha_review",
                supersedes_receipt_sha256=None,
                created_at_utc="2026-07-17T14:00:00Z",
            )


if __name__ == "__main__":
    unittest.main()
