#!/usr/bin/env python3
"""Validate Estudio gates v3 and opt-in lifecycle receipts.

Pre-cutover cards remain valid with the original v3 fields. New cards created
from the v2.1 templates opt into ``estudio_lifecycle_v1`` and are required to
carry a commit-reachable, locally closed receipt in Review/Done.
"""
from __future__ import annotations

import argparse
import re
import subprocess
from pathlib import Path
from typing import Iterable

from estudio_governance import CheckReport, emit, load_governance, parse_metadata, resolve_projects

LANES = ("Backlog", "Doing", "Review", "Done")
CORE_FIELDS = (
    "closure_protocol", "technical_status", "human_gate_required",
    "human_gate_status", "human_gate_scope", "human_gate_evidence",
    "publication_status", "blocking_decision", "execution_mode",
    "delegated_scope", "branch", "worktree", "base_ref", "merge_status",
    "worktree_status", "branch_cleanup", "validation_tier",
    "validation_result", "global_sync_needed",
)
RECEIPT_FIELDS = (
    "closure_contract", "closure_mode", "commit", "merged_to",
    "merge_strategy", "post_merge_validation", "closure_summary",
)
NONE_VALUES = {"", "none", "n/a", "not_applicable", "not applicable"}
PENDING_RE = re.compile(r"(?i)\b(pending|pendente|todo|tbd|a definir|awaiting)\b")
SHA_RE = re.compile(r"^[0-9a-fA-F]{7,40}$")


def _none(value: str) -> bool:
    return value.strip().casefold() in NONE_VALUES


def _none_scope(value: str) -> bool:
    normalized = value.strip().casefold()
    return (
        normalized in NONE_VALUES
        or normalized.startswith(("none;", "none para", "nenhum", "nenhuma"))
        or (normalized.startswith("existing ") and "independent" in normalized)
    )


def _boolean_metadata(value: str) -> str:
    return value.strip().casefold().split(";", 1)[0].strip()


def _pending(value: str) -> bool:
    return not value.strip() or bool(PENDING_RE.search(value))


def _tracked_markdown(directory: Path) -> Iterable[Path]:
    if not directory.is_dir():
        return ()
    return (
        path for path in sorted(directory.glob("*.md"))
        if path.name.casefold() != "readme.md"
    )


def iter_cards(root: Path, config: dict, selected: set[str], include_global: bool = True) -> Iterable[tuple[Path, str]]:
    roots: list[Path] = []
    if include_global:
        roots.append(root / "08_Coordenacao_Agentes/Kanban")
    for project in config["projects"]:
        if project["id"] in selected:
            roots.append(root / project["coordination_root"] / "Kanban")
    for kanban in roots:
        for lane in LANES:
            for path in _tracked_markdown(kanban / lane):
                yield path, lane


def iter_handoffs(root: Path, config: dict, selected: set[str], include_global: bool = True) -> Iterable[Path]:
    roots: list[Path] = []
    if include_global:
        roots.append(root / "08_Coordenacao_Agentes/Handoffs")
    roots.extend(
        root / project["coordination_root"] / "Handoffs"
        for project in config["projects"] if project["id"] in selected
    )
    for directory in roots:
        yield from _tracked_markdown(directory)


def _git_success(root: Path, *args: str) -> bool:
    return subprocess.run(
        ["git", *args], cwd=root, text=True, capture_output=True, check=False,
    ).returncode == 0


def _reachable(root: Path, sha: str) -> bool:
    return bool(SHA_RE.fullmatch(sha)) and _git_success(root, "merge-base", "--is-ancestor", sha, "HEAD")


def _merged_to_sha(value: str, base_branch: str) -> str:
    match = re.fullmatch(rf"{re.escape(base_branch)}@([0-9a-fA-F]{{7,40}})", value.strip())
    return match.group(1) if match else ""


def _require(report: CheckReport, metadata: dict[str, str], fields: Iterable[str], rel: str) -> None:
    for field in fields:
        if not metadata.get(field, "").strip():
            report.fail("CLOSURE_FIELD_MISSING", f"missing metadata field: {field}", rel)


def _check_gate(report: CheckReport, metadata: dict[str, str], lane: str, rel: str) -> None:
    required = metadata.get("human_gate_required", "").casefold()
    status = metadata.get("human_gate_status", "").casefold()
    scope = metadata.get("human_gate_scope", "")
    evidence = metadata.get("human_gate_evidence", "")
    blocking = metadata.get("blocking_decision", "")

    if required not in {"yes", "no"}:
        report.fail("CLOSURE_GATE_REQUIRED", "human_gate_required must be yes or no", rel)
    if status not in {"pending", "approved", "rejected", "not_required", "superseded"}:
        report.fail("CLOSURE_GATE_STATUS", f"invalid human_gate_status: {status}", rel)
    if status == "not_required":
        if required != "no" or not _none_scope(scope) or _pending(evidence):
            report.fail("CLOSURE_GATE_NOT_REQUIRED", "not_required requires human_gate_required=no, a none-like scope and non-pending evidence", rel)
    elif status == "pending":
        if required != "yes" or _none(scope):
            report.fail("CLOSURE_GATE_PENDING", "pending requires human_gate_required=yes and a concrete scope", rel)
    elif status in {"approved", "rejected", "superseded"}:
        if required != "yes" or _none(scope) or _none(evidence) or _pending(evidence):
            report.fail("CLOSURE_GATE_RESOLVED", "resolved gate requires yes, concrete scope and evidence", rel)

    if lane == "Review":
        if status != "pending":
            report.fail("CLOSURE_REVIEW_GATE", "Review accepts only human_gate_status=pending", rel)
        if _none(blocking) or _pending(blocking):
            report.fail("CLOSURE_REVIEW_DECISION", "Review requires a concrete blocking_decision", rel)
    if lane == "Done" and status == "pending":
        report.fail("CLOSURE_DONE_PENDING", "Done rejects a pending human gate", rel)


def _check_receipt(report: CheckReport, root: Path, metadata: dict[str, str], lane: str, rel: str, base_branch: str) -> None:
    _require(report, metadata, RECEIPT_FIELDS, rel)
    if metadata.get("closure_contract") != "estudio_lifecycle_v1":
        report.fail("CLOSURE_RECEIPT_CONTRACT", "closure_contract must be estudio_lifecycle_v1", rel)
        return

    if lane not in {"Review", "Done"}:
        return
    commit = metadata.get("commit", "")
    merged_to = metadata.get("merged_to", "")
    merged_sha = _merged_to_sha(merged_to, base_branch)
    if not _reachable(root, commit):
        report.fail("CLOSURE_COMMIT_UNREACHABLE", f"commit is not reachable from HEAD: {commit}", rel)
    if not merged_sha or not _reachable(root, merged_sha):
        report.fail("CLOSURE_MERGED_TO", f"merged_to must be reachable {base_branch}@<sha>: {merged_to}", rel)
    elif SHA_RE.fullmatch(commit) and not _git_success(root, "merge-base", "--is-ancestor", commit, merged_sha):
        report.fail("CLOSURE_COMMIT_NOT_MERGED", f"commit {commit} is not an ancestor of {merged_to}", rel)
    if metadata.get("merge_strategy", "").casefold() != "ff-only":
        report.fail("CLOSURE_MERGE_STRATEGY", "closed lifecycle receipts require merge_strategy=ff-only", rel)
    if not metadata.get("merge_status", "").casefold().startswith("merged"):
        report.fail("CLOSURE_MERGE_STATUS", "closed lifecycle receipt requires merge_status=merged...", rel)
    if metadata.get("worktree_status", "").casefold() != "removed":
        report.fail("CLOSURE_WORKTREE_STATUS", "closed lifecycle receipt requires worktree_status=removed", rel)
    if metadata.get("branch_cleanup", "").casefold() != "deleted":
        report.fail("CLOSURE_BRANCH_CLEANUP", "closed lifecycle receipt requires branch_cleanup=deleted", rel)
    if _none(metadata.get("post_merge_validation", "")) or _pending(metadata.get("post_merge_validation", "")):
        report.fail("CLOSURE_POST_MERGE_VALIDATION", "post_merge_validation must be final", rel)
    if _none(metadata.get("closure_summary", "")) or _pending(metadata.get("closure_summary", "")):
        report.fail("CLOSURE_SUMMARY", "closure_summary must be final", rel)

    gate_status = metadata.get("human_gate_status", "").casefold()
    expected_mode = "merged_pending_human_review" if lane == "Review" else f"merged_{gate_status}_done"
    if metadata.get("closure_mode", "").casefold() != expected_mode:
        report.fail("CLOSURE_MODE", f"expected closure_mode={expected_mode}", rel)


def check_closure(root: Path, config: dict, selected: set[str], *, include_global: bool = True, require_receipt: bool = False) -> CheckReport:
    report = CheckReport("agent_closure_protocol")
    base_branch = config.get("multiagent", {}).get("base_branch", "main")
    cards = receipts = legacy_closed = handoffs = 0
    for path, lane in iter_cards(root, config, selected, include_global):
        rel = path.relative_to(root).as_posix()
        metadata = parse_metadata(path.read_text(encoding="utf-8", errors="strict"))
        protocol = metadata.get("closure_protocol", "")
        if lane == "Review" and protocol != "agent_local_merge_v3":
            report.fail("CLOSURE_REVIEW_PROTOCOL", "live Review card must use agent_local_merge_v3", rel)
        if protocol != "agent_local_merge_v3":
            continue
        cards += 1
        _require(report, metadata, CORE_FIELDS, rel)
        _check_gate(report, metadata, lane, rel)
        if _boolean_metadata(metadata.get("global_sync_needed", "")) not in {"yes", "no"}:
            report.fail("CLOSURE_GLOBAL_SYNC", "global_sync_needed must be yes or no", rel)
        declared = metadata.get("status", "")
        if declared and declared.casefold() != lane.casefold():
            report.fail("CLOSURE_LANE_STATUS", f"status={declared} but card is in {lane}", rel)
        opted_in = metadata.get("closure_contract") == "estudio_lifecycle_v1" or any(metadata.get(field) for field in RECEIPT_FIELDS[1:])
        if require_receipt and lane in {"Review", "Done"}:
            opted_in = True
        if opted_in:
            receipts += 1
            _check_receipt(report, root, metadata, lane, rel, base_branch)
        elif lane in {"Review", "Done"}:
            legacy_closed += 1

    for path in iter_handoffs(root, config, selected, include_global):
        metadata = parse_metadata(path.read_text(encoding="utf-8", errors="strict"))
        if metadata.get("closure_protocol") != "agent_local_merge_v3":
            continue
        handoffs += 1
        rel = path.relative_to(root).as_posix()
        _require(report, metadata, CORE_FIELDS, rel)
        _check_gate(report, metadata, "", rel)
        if metadata.get("closure_contract") == "estudio_lifecycle_v1":
            _check_receipt(report, root, metadata, "Done" if metadata.get("status", "").casefold() == "closed" else "", rel, base_branch)

    report.metrics.update(cards_checked=cards, lifecycle_receipts=receipts, legacy_closed_cards=legacy_closed, handoffs_checked=handoffs)
    return report


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=str(Path(__file__).resolve().parent.parent))
    parser.add_argument("--config", default="tools/estudio_governance.json")
    parser.add_argument("--project", default="AllOfficial")
    parser.add_argument("--local-only", action="store_true")
    parser.add_argument("--require-lifecycle-receipt", action="store_true")
    parser.add_argument("--audit-only", action="store_true")
    parser.add_argument("--report-path")
    args = parser.parse_args(argv)
    root = Path(args.root).resolve()
    try:
        config = load_governance(root, args.config)
        selected = {item["id"] for item in resolve_projects(config, args.project)}
        report = check_closure(
            root, config, selected, include_global=not args.local_only,
            require_receipt=args.require_lifecycle_receipt,
        )
    except Exception as exc:  # CLI contract: configuration errors are findings.
        report = CheckReport("agent_closure_protocol")
        report.fail("CLOSURE_CHECK_ERROR", str(exc))
    return emit(report, args.audit_only, args.report_path)


if __name__ == "__main__":
    raise SystemExit(main())
