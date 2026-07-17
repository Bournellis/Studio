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

from build_documentation_lite_manifests import (  # noqa: E402
    INDEX,
    _project_for_global,
    build_artifacts,
    write_artifacts,
)
from documentation_lite import check_documentation_lite  # noqa: E402


def run(root: Path, *args: str) -> str:
    result = subprocess.run(args, cwd=root, text=True, capture_output=True, check=False)
    if result.returncode:
        raise AssertionError(f"{' '.join(args)} failed: {result.stderr}")
    return result.stdout.strip()


class ManifestBuilderFixture(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        run(self.root, "git", "init", "-q")
        run(self.root, "git", "config", "user.email", "test@example.com")
        run(self.root, "git", "config", "user.name", "Test")
        self._write("AGENTS.md", "# Contract\n")
        self._write(
            "08_Coordenacao_Agentes/Decisoes/2026-07-17_estudio_documentation-lite-v2-cutover-recuperavel.md",
            "# Decision\n",
        )
        self._write("08_Coordenacao_Agentes/Runbooks/DOCUMENTATION_LITE_LIFECYCLE.md", "# Runbook\n")
        self._write("Projetos/JogoDaCopa/implementation/history.md", "# Durable project history\n")
        self._write("Projetos/JogoDaCopa/qa/QA_INDEX.md", "# QA\n")

    def tearDown(self) -> None:
        self.temp.cleanup()

    def _write(self, relative: str, content: str) -> None:
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    def _commit_and_tag(self) -> tuple[str, str]:
        run(self.root, "git", "add", ".")
        run(self.root, "git", "commit", "-qm", "fixture baseline")
        baseline = run(self.root, "git", "rev-parse", "HEAD")
        tag = "recovery/estudio-documentation-lite/v2/fixture"
        run(self.root, "git", "tag", "-a", tag, baseline, "-m", "fixture recovery")
        return baseline, tag


class ManifestBuilderTests(ManifestBuilderFixture):
    def test_global_filename_ownership_wins_over_incidental_content(self) -> None:
        self.assertEqual(
            _project_for_global(
                "08_Coordenacao_Agentes/Kanban/Done/2026-06-09_codex_estudio_doc-drift-fix-v1.md",
                b"RPG Isometrico appeared in the audit.",
            ),
            "estudio",
        )

    def test_dry_run_is_deterministic_and_excludes_review(self) -> None:
        track = "Projetos/JogoDaCopa/implementation/tracks/track-00.md"
        done = "08_Coordenacao_Agentes/Kanban/Done/2026-07-17_codex_jogodacopa_done.md"
        review = "Projetos/JogoDaCopa/08_Coordenacao/Kanban/Review/2026-07-17_gate.md"
        self._write(track, "# Track 00 result\n")
        self._write(done, "# JogoDaCopa technical closeout\n")
        self._write(review, "# Pending human gate\n\nhuman_gate_status: pending\n")
        baseline, tag = self._commit_and_tag()

        first, first_summary = build_artifacts(self.root, baseline, tag)
        second, second_summary = build_artifacts(self.root, baseline, tag)

        self.assertEqual(first, second)
        self.assertEqual(first_summary, second_summary)
        self.assertEqual(first_summary["candidate_count"], 2)
        self.assertFalse((self.root / INDEX).exists(), "dry-run must not write")
        payload = b"\n".join(first.values())
        self.assertIn(track.encode(), payload)
        self.assertIn(done.encode(), payload)
        self.assertNotIn(review.encode(), payload)

    def test_written_artifacts_match_index_and_pass_audit(self) -> None:
        self._write("Projetos/JogoDaCopa/implementation/tracks/track-00.md", "# Track 00 result\n")
        baseline, tag = self._commit_and_tag()
        artifacts, summary = build_artifacts(self.root, baseline, tag)
        write_artifacts(self.root, artifacts)

        index = json.loads((self.root / INDEX).read_text(encoding="utf-8"))
        self.assertEqual(summary["index_sha256"], hashlib.sha256((self.root / INDEX).read_bytes()).hexdigest())
        for descriptor in index["batches"]:
            manifest = self.root / descriptor["manifest"]
            self.assertEqual(descriptor["manifest_sha256"], hashlib.sha256(manifest.read_bytes()).hexdigest())
        report = check_documentation_lite(
            self.root,
            {"documentation_lite": {"manifest_index": INDEX}},
            mode="Audit",
        )
        self.assertFalse(report.failed, report.issues)

    def test_nine_hundred_sources_split_without_deadlock(self) -> None:
        for index in range(900):
            self._write(
                f"08_Coordenacao_Agentes/Kanban/Done/2026-07-17_codex_estudio_fixture-{index:04d}.md",
                f"# Fixture outcome {index:04d}\n\nhuman_gate_required: no\n",
            )
        baseline, tag = self._commit_and_tag()
        artifacts, summary = build_artifacts(self.root, baseline, tag)

        self.assertEqual(summary["candidate_count"], 900)
        self.assertEqual(summary["batch_count"], 6)
        manifests = [
            json.loads(payload)
            for path, payload in artifacts.items()
            if "/batches/" in path
        ]
        self.assertEqual(sum(len(batch["entries"]) for batch in manifests), 900)
        self.assertTrue(all(len(batch["entries"]) <= 150 for batch in manifests))


if __name__ == "__main__":
    unittest.main()
