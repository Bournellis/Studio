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

from check_agent_closure_protocol import check_closure  # noqa: E402
from check_local_doc_links import iter_files  # noqa: E402
from check_portfolio_sync_queue import check_queue  # noqa: E402
from estudio_governance import load_governance  # noqa: E402


def run(cwd: Path, *args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(args, cwd=cwd, text=True, encoding="utf-8", errors="replace", capture_output=True, check=check)


class GitFixture(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        run(self.root, "git", "init", "-q", "-b", "main")
        run(self.root, "git", "config", "user.email", "tests@estudio.local")
        run(self.root, "git", "config", "user.name", "Estudio Tests")
        (self.root / "base.txt").write_text("base\n", encoding="utf-8")
        run(self.root, "git", "add", "base.txt")
        run(self.root, "git", "commit", "-qm", "base")
        self.base_sha = run(self.root, "git", "rev-parse", "HEAD").stdout.strip()
        self.config = {
            "projects": [{
                "id": "P", "name": "Project P", "aliases": ["p"],
                "root": "Projetos/P", "coordination_root": "Projetos/P/08_Coordenacao",
            }],
            "groups": {"AllOfficial": ["P"]},
            "multiagent": {"base_branch": "main"},
        }

    def tearDown(self) -> None:
        self.temp.cleanup()

    def write_card(self, lane: str, *, gate_status: str = "not_required", receipt: bool = False, blocking: str = "none") -> Path:
        path = self.root / f"Projetos/P/08_Coordenacao/Kanban/{lane}/card.md"
        path.parent.mkdir(parents=True, exist_ok=True)
        required = "yes" if gate_status != "not_required" else "no"
        scope = "visual" if required == "yes" else "none"
        evidence = "evidence.md" if gate_status in {"approved", "rejected", "superseded"} else "n/a"
        lines = [
            "# Card", "", "## Metadata", "",
            "- closure_protocol: `agent_local_merge_v3`",
            "- technical_status: `pass`",
            f"- human_gate_required: `{required}`",
            f"- human_gate_status: `{gate_status}`",
            f"- human_gate_scope: `{scope}`",
            f"- human_gate_evidence: `{evidence}`",
            "- publication_status: `not_authorized`",
            f"- blocking_decision: `{blocking}`",
            "- execution_mode: `single_agent`",
            "- delegated_scope: `none`",
            "- branch: `codex/p/test`",
            "- worktree: `D:\\Estudio-worktrees\\p--codex--test`",
            f"- base_ref: `main@{self.base_sha[:8]}`",
            "- merge_status: `merged`",
            "- worktree_status: `removed`",
            "- branch_cleanup: `deleted`",
            "- validation_tier: `Docs`",
            "- validation_result: `PASS`",
            "- global_sync_needed: `no`",
        ]
        if receipt:
            mode = "merged_pending_human_review" if lane == "Review" else f"merged_{gate_status}_done"
            lines += [
                "- closure_contract: `estudio_lifecycle_v1`",
                f"- closure_mode: `{mode}`",
                f"- commit: `{self.base_sha}`",
                f"- merged_to: `main@{self.base_sha}`",
                "- merge_strategy: `ff-only`",
                "- post_merge_validation: `PASS - DocsOnly`",
                "- closure_summary: `closed locally without remote mutation`",
            ]
        path.write_text("\n".join(lines) + "\n", encoding="utf-8")
        return path

    def write_queue(self, reflected: bool = False) -> None:
        path = self.root / "08_Coordenacao_Agentes/PortfolioSync_QUEUE.md"
        path.parent.mkdir(parents=True, exist_ok=True)
        reflected_row = "| `sync-1` | `P` | `card` | `2026-07-17` | `2026-07-17` | `baseline` | `reflected` |" if reflected else ""
        path.write_text(
            "# Queue\n\n## Metadata\n\n- status: `active`\n- authority: `portfolio_snapshot`\n"
            "- last_verified: `2026-07-17`\n- review_when: `pending`\n- supersedes: `none`\n- superseded_by: `none`\n\n"
            "## Pending\n\nNenhuma entrada pendente.\n\n## Reflected\n\n"
            "| id | project | source | requested_at | reflected_at | fields | state |\n"
            "|---|---|---|---|---|---|---|\n" + reflected_row + "\n\n## Rules\n\n- local first\n",
            encoding="utf-8",
        )


class ClosureContractTests(GitFixture):
    def test_done_rejects_pending_human_gate(self) -> None:
        self.write_card("Done", gate_status="pending", blocking="Fabio decide")
        report = check_closure(self.root, self.config, {"P"}, include_global=False)
        self.assertTrue(any(issue.code == "CLOSURE_DONE_PENDING" for issue in report.issues))

    def test_lifecycle_receipt_accepts_reachable_commit(self) -> None:
        self.write_card("Done", receipt=True)
        report = check_closure(self.root, self.config, {"P"}, include_global=False)
        self.assertFalse(report.failed, report.issues)
        self.assertEqual(1, report.metrics["lifecycle_receipts"])

    def test_review_requires_concrete_blocking_decision(self) -> None:
        self.write_card("Review", gate_status="pending", receipt=True)
        report = check_closure(self.root, self.config, {"P"}, include_global=False)
        self.assertTrue(any(issue.code == "CLOSURE_REVIEW_DECISION" for issue in report.issues))

    def test_none_like_scope_and_boolean_annotation_are_compatible(self) -> None:
        card = self.write_card("Done")
        text = card.read_text(encoding="utf-8")
        text = text.replace("human_gate_scope: `none`", "human_gate_scope: `nenhum novo; gates existentes permanecem independentes`")
        text = text.replace("global_sync_needed: `no`", "global_sync_needed: `no; coordinator owns the program closeout`")
        card.write_text(text, encoding="utf-8")
        report = check_closure(self.root, self.config, {"P"}, include_global=False)
        self.assertFalse(report.failed, report.issues)


class PortfolioQueueTests(GitFixture):
    def test_empty_queue_is_valid(self) -> None:
        self.write_queue()
        report = check_queue(self.root, self.config)
        self.assertFalse(report.failed, report.issues)

    def test_live_local_sync_card_requires_queue_entry(self) -> None:
        self.write_queue()
        card = self.write_card("Doing")
        text = card.read_text(encoding="utf-8").replace("global_sync_needed: `no`", "global_sync_needed: `yes`")
        card.write_text(text, encoding="utf-8")
        report = check_queue(self.root, self.config)
        self.assertTrue(any(issue.code == "PORTFOLIO_QUEUE_CARD_MISSING" for issue in report.issues))


class RealWorkspaceTests(unittest.TestCase):
    def test_real_docs_closure_and_queue_contracts_pass(self) -> None:
        config = load_governance(ROOT)
        selected = set(config["groups"]["AllOfficial"])
        self.assertFalse(check_closure(ROOT, config, selected).failed)
        self.assertFalse(check_queue(ROOT, config).failed)

    def test_live_link_scan_uses_governance_registry(self) -> None:
        files = {path.relative_to(ROOT).as_posix() for path in iter_files(ROOT, "estudio")}
        self.assertIn("materiais/guides/estudio-agent-workflow-current.md", files)
        self.assertIn("Projetos/rpg-turnos/qa/QA_INDEX.md", files)

    def test_paused_lane_placeholders_are_not_fake_cards(self) -> None:
        for project in ("rpg-isometrico", "rpg-turnos"):
            for lane in ("Backlog", "Doing", "Review", "Done"):
                directory = ROOT / f"Projetos/{project}/08_Coordenacao/Kanban/{lane}"
                self.assertFalse((directory / "README.md").exists())
                self.assertTrue((directory / ".gitkeep").exists())

    def test_documentation_lite_search_patterns_are_versioned(self) -> None:
        text = (ROOT / ".rgignore").read_text(encoding="utf-8")
        for pattern in ("**/Handoffs/**", "**/Kanban/Done/**", "**/archive/**", "**/Historico/**"):
            self.assertIn(pattern, text)


@unittest.skipUnless(sys.platform == "win32", "PowerShell helper contracts are Windows-only")
class PowerShellHelperTests(GitFixture):
    def test_commit_helper_dry_run_does_not_stage(self) -> None:
        (self.root / "base.txt").write_text("changed\n", encoding="utf-8")
        before = run(self.root, "git", "rev-parse", "HEAD").stdout
        result = run(
            self.root, "powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
            str(TOOLS / "git_commit_powershell.ps1"), "-WorktreePath", str(self.root),
            "-Message", "test: dry run", "-Paths", "base.txt", "-ExpectedBranch", "main", "-DryRun",
        )
        self.assertIn("no staging or commit", result.stdout)
        self.assertEqual(before, run(self.root, "git", "rev-parse", "HEAD").stdout)
        self.assertEqual("", run(self.root, "git", "diff", "--cached", "--name-only").stdout)

    def test_worktree_lifecycle_emits_json_without_mutation(self) -> None:
        worktree_root = self.root / "worktrees"
        result = run(
            self.root, "powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
            str(TOOLS / "check_worktree_lifecycle.ps1"), "-Root", str(self.root),
            "-WorktreeRoot", str(worktree_root), "-BaseBranch", "main", "-Json",
        )
        report = json.loads(result.stdout)
        self.assertEqual("estudio_worktree_lifecycle_v1", report["schema"])
        self.assertEqual("pass", report["status"])
        self.assertEqual(1, len(report["worktrees"]))

    def test_close_helper_dry_run_preserves_branch_and_worktree(self) -> None:
        tools = self.root / "tools"
        tools.mkdir()
        (tools / "validate_estudio.ps1").write_text("exit 0\n", encoding="utf-8")
        (tools / "check_worktree_overlap.py").write_text("raise SystemExit(0)\n", encoding="utf-8")
        run(self.root, "git", "add", "tools")
        run(self.root, "git", "commit", "-qm", "test tooling")
        target = self.root.parent / f"{self.root.name}-dryrun-worktree"
        try:
            run(self.root, "git", "worktree", "add", "-q", "-b", "codex/p/dryrun", str(target))
            result = run(
                self.root, "powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
                str(TOOLS / "close_worktree_powershell.ps1"), "-WorktreePath", str(target),
                "-Branch", "codex/p/dryrun", "-BaseBranch", "main", "-MergeFfOnly",
                "-ValidationTier", "Docs", "-ValidationProject", "P", "-DeleteBranch", "-Prune", "-DryRun",
            )
            self.assertIn("not merged", result.stdout)
            self.assertTrue(target.is_dir())
            branches = run(self.root, "git", "branch", "--format=%(refname:short)").stdout.splitlines()
            self.assertIn("codex/p/dryrun", branches)
        finally:
            if target.exists():
                run(self.root, "git", "worktree", "remove", "--force", str(target), check=False)
            run(self.root, "git", "branch", "-D", "codex/p/dryrun", check=False)


if __name__ == "__main__":
    unittest.main()
