#!/usr/bin/env python3
"""Recoverable Documentation Lite cutover for D:\\Estudio.

Audit, Prepare and Verify are read-only. Execute removes only literal paths from
an approved index and writes a deterministic receipt; it never stages, commits,
tags, restores or contacts a remote.
"""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import re
import subprocess
from pathlib import Path, PurePosixPath
from typing import Any, Iterable

from estudio_governance import CheckReport, emit, load_governance, read_json


DISPOSITIONS = {
    "preserve_live", "preserve_reference", "preserve_evidence",
    "remove_with_ledger", "blocked_semantic_review",
}
SENSITIVE = {"decision", "human_gate", "publication_release", "security", "incident", "technical_contract"}
MODES = {"Audit", "Prepare", "Execute", "Verify"}
SHA40_RE = re.compile(r"^[0-9a-f]{40}$")
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
ID_RE = re.compile(r"^[a-z][a-z0-9_-]+$")
GLOB_CHARS = set("*?[]{}")


def _json_sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _git(root: Path, *args: str, input_bytes: bytes | None = None) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["git", *args], cwd=root, input=input_bytes, capture_output=True,
        text=False, check=False,
    )


def _git_text(root: Path, *args: str) -> tuple[int, str, str]:
    proc = _git(root, *args)
    return (
        proc.returncode,
        proc.stdout.decode("utf-8", errors="replace"),
        proc.stderr.decode("utf-8", errors="replace"),
    )


def _safe_rel(value: Any) -> str | None:
    if not isinstance(value, str) or not value or "\\" in value or any(char in value for char in GLOB_CHARS):
        return None
    path = PurePosixPath(value)
    if path.is_absolute() or ".." in path.parts or value.startswith("./") or value.endswith("/"):
        return None
    return path.as_posix()


def _ls_tree(root: Path, commit: str) -> dict[str, str]:
    code, stdout, stderr = _git_text(root, "ls-tree", "-r", "--full-tree", commit)
    if code:
        raise RuntimeError(f"git ls-tree failed for {commit}: {stderr.strip()}")
    result: dict[str, str] = {}
    for line in stdout.splitlines():
        meta, sep, path = line.partition("\t")
        fields = meta.split()
        if sep and len(fields) == 3 and fields[1] == "blob":
            result[path] = fields[2]
    return result


def _cat_blobs(root: Path, oids: Iterable[str]) -> dict[str, bytes]:
    ordered = sorted(set(oids))
    if not ordered:
        return {}
    payload = ("\n".join(ordered) + "\n").encode("ascii")
    proc = _git(root, "cat-file", "--batch", input_bytes=payload)
    if proc.returncode:
        raise RuntimeError(proc.stderr.decode("utf-8", errors="replace").strip())
    data = proc.stdout
    cursor = 0
    result: dict[str, bytes] = {}
    for requested in ordered:
        newline = data.find(b"\n", cursor)
        if newline < 0:
            raise RuntimeError("truncated git cat-file batch header")
        header = data[cursor:newline].decode("ascii", errors="replace").split()
        cursor = newline + 1
        if len(header) == 2 and header[1] == "missing":
            raise RuntimeError(f"missing Git blob: {requested}")
        if len(header) != 3 or header[1] != "blob":
            raise RuntimeError(f"unexpected git cat-file header: {' '.join(header)}")
        size = int(header[2])
        blob = data[cursor:cursor + size]
        cursor += size
        if cursor >= len(data) or data[cursor:cursor + 1] != b"\n":
            raise RuntimeError(f"truncated Git blob payload: {requested}")
        cursor += 1
        result[requested] = blob
    return result


def _tag_commit(root: Path, tag: str) -> str | None:
    code, stdout, _ = _git_text(root, "rev-parse", f"refs/tags/{tag}^{{commit}}")
    return stdout.strip() if code == 0 else None


def _current_sha(root: Path) -> str:
    code, stdout, stderr = _git_text(root, "rev-parse", "HEAD")
    if code:
        raise RuntimeError(stderr.strip())
    return stdout.strip()


def _tracked_status(root: Path) -> list[str]:
    code, stdout, stderr = _git_text(root, "status", "--porcelain=v1", "--untracked-files=all")
    if code:
        raise RuntimeError(stderr.strip())
    return [line for line in stdout.splitlines() if line]


def _overlap_with_other_worktrees(root: Path, candidate_paths: set[str]) -> list[str]:
    code, stdout, stderr = _git_text(root, "worktree", "list", "--porcelain")
    if code:
        raise RuntimeError(stderr.strip())
    current = root.resolve()
    overlaps: list[str] = []
    for line in stdout.splitlines():
        if not line.startswith("worktree "):
            continue
        other = Path(line[9:]).resolve()
        if other == current or not other.is_dir():
            continue
        code, status, _ = _git_text(other, "status", "--porcelain=v1", "--untracked-files=all")
        if code:
            continue
        for row in status.splitlines():
            raw = row[3:] if len(row) >= 4 else ""
            path = raw.split(" -> ")[-1].replace("\\", "/")
            if path in candidate_paths:
                overlaps.append(f"{other}:{path}")
    return sorted(overlaps)


def _validate_authorization(report: CheckReport, root: Path, index: dict[str, Any], index_sha: str) -> dict[str, Any] | None:
    rel = _safe_rel(index.get("authorization_path"))
    if not rel:
        report.fail("DOCLITE_AUTH_PATH", "index authorization_path must be a safe literal path")
        return None
    path = root / rel
    if not path.is_file():
        report.fail("DOCLITE_AUTH_MISSING", "authorization file is missing", rel)
        return None
    try:
        auth = read_json(path)
    except (OSError, json.JSONDecodeError) as exc:
        report.fail("DOCLITE_AUTH_JSON", str(exc), rel)
        return None
    if auth.get("schema_version") != 1 or auth.get("status") not in {"pending", "approved"}:
        report.fail("DOCLITE_AUTH_SCHEMA", "authorization must be v1 pending or approved", rel)
    if auth.get("status") == "approved":
        if auth.get("index_sha256") != index_sha:
            report.fail("DOCLITE_AUTH_HASH", "approved authorization does not match the current index", rel)
        if not auth.get("approved_by") or not auth.get("approved_at") or not auth.get("evidence"):
            report.fail("DOCLITE_AUTH_EVIDENCE", "approved authorization needs approver, timestamp and evidence", rel)
    return auth


def _validate_batch_shape(report: CheckReport, root: Path, batch: Any, rel: str) -> tuple[list[dict[str, Any]], dict[str, dict[str, Any]]]:
    if not isinstance(batch, dict) or batch.get("schema_version") != 2:
        report.fail("DOCLITE_BATCH_SCHEMA", "batch must be an object with schema_version 2", rel)
        return [], {}
    batch_id = batch.get("batch_id")
    if not isinstance(batch_id, str) or not ID_RE.fullmatch(batch_id):
        report.fail("DOCLITE_BATCH_ID", f"invalid batch id: {batch_id!r}", rel)
    if not SHA40_RE.fullmatch(str(batch.get("baseline_commit", ""))):
        report.fail("DOCLITE_BASELINE", "baseline_commit must be a full 40-character SHA", rel)
    tag = batch.get("recovery_tag")
    if not isinstance(tag, str) or not tag.startswith("recovery/estudio-documentation-lite/v2/"):
        report.fail("DOCLITE_TAG", "invalid recovery_tag", rel)
    auth_ref = _safe_rel(batch.get("authorization_ref"))
    if not auth_ref or not (root / auth_ref).is_file():
        report.fail("DOCLITE_AUTH_REF", "authorization_ref must name the shared authorization file", rel)
    entries = batch.get("entries")
    records = batch.get("records")
    if not isinstance(entries, list) or not isinstance(records, list):
        report.fail("DOCLITE_BATCH_ARRAYS", "entries and records must be arrays", rel)
        return [], {}
    record_map: dict[str, dict[str, Any]] = {}
    source_owners: dict[str, str] = {}
    for record in records:
        if not isinstance(record, dict):
            report.fail("DOCLITE_RECORD_TYPE", "record must be an object", rel)
            continue
        record_id = record.get("record_id")
        if not isinstance(record_id, str) or not ID_RE.fullmatch(record_id) or record_id in record_map:
            report.fail("DOCLITE_RECORD_ID", f"invalid or duplicate record_id: {record_id!r}", rel)
            continue
        source_paths = record.get("source_paths")
        if not isinstance(source_paths, list) or not source_paths or record.get("source_count") != len(source_paths):
            report.fail("DOCLITE_RECORD_COUNT", f"source_count mismatch for {record_id}", rel)
            continue
        for field in ("date", "scope", "outcome", "human_gate", "technical_result_ref", "validation", "evidence", "ledger_path"):
            if not isinstance(record.get(field), str) or not record[field].strip():
                report.fail("DOCLITE_RECORD_FIELD", f"{record_id} needs {field}", rel)
        ledger = _safe_rel(record.get("ledger_path"))
        if not ledger or not (root / ledger).is_file():
            report.fail("DOCLITE_LEDGER", f"ledger missing for {record_id}: {record.get('ledger_path')}", rel)
        for source in source_paths:
            safe = _safe_rel(source)
            if not safe:
                report.fail("DOCLITE_RECORD_PATH", f"unsafe source path in {record_id}: {source!r}", rel)
            elif safe in source_owners:
                report.fail("DOCLITE_RECORD_BIJECTION", f"{safe} belongs to multiple records", rel)
            else:
                source_owners[safe] = record_id
        record_map[record_id] = record
    paths: list[str] = []
    for entry in entries:
        if not isinstance(entry, dict):
            report.fail("DOCLITE_ENTRY_TYPE", "entry must be an object", rel)
            continue
        path = _safe_rel(entry.get("path"))
        if not path:
            report.fail("DOCLITE_ENTRY_PATH", f"unsafe literal path: {entry.get('path')!r}", rel)
            continue
        paths.append(path)
        if entry.get("disposition") not in DISPOSITIONS:
            report.fail("DOCLITE_DISPOSITION", f"invalid disposition for {path}", rel)
        record_id = entry.get("record_id")
        if record_id not in record_map or source_owners.get(path) != record_id:
            report.fail("DOCLITE_ENTRY_RECORD", f"{path} is not bijectively linked to {record_id}", rel)
        authorities = entry.get("retained_authorities")
        if not isinstance(authorities, list) or not authorities:
            report.fail("DOCLITE_AUTHORITY", f"{path} needs retained_authorities", rel)
        else:
            for authority in authorities:
                safe = _safe_rel(authority)
                if not safe or not (root / safe).is_file():
                    report.fail("DOCLITE_AUTHORITY_MISSING", f"retained authority is missing: {authority}", path)
                if safe == path:
                    report.fail("DOCLITE_AUTHORITY_SELF", "removed path cannot retain itself", path)
        if entry.get("disposition") == "remove_with_ledger":
            allowed = {"absorbed", "none"}
            if entry.get("unique_content_status") not in allowed:
                report.fail("DOCLITE_UNIQUE_CONTENT", f"{path} has unresolved unique content", rel)
            if entry.get("classification") in SENSITIVE and entry.get("unique_content_status") != "absorbed":
                report.fail("DOCLITE_SENSITIVE_ABSORPTION", f"sensitive content must be absorbed: {path}", rel)
        for key, regex in (("source_blob", re.compile(r"^[0-9a-f]{40,64}$")), ("source_sha256", SHA256_RE)):
            if not regex.fullmatch(str(entry.get(key, ""))):
                report.fail("DOCLITE_ENTRY_HASH", f"invalid {key} for {path}", rel)
        if not isinstance(entry.get("byte_count"), int) or not isinstance(entry.get("line_count"), int):
            report.fail("DOCLITE_ENTRY_COUNT", f"invalid counts for {path}", rel)
    if paths != sorted(paths) or len(paths) != len(set(paths)):
        report.fail("DOCLITE_ENTRY_ORDER", "entry paths must be sorted and unique", rel)
    if set(paths) != set(source_owners):
        report.fail("DOCLITE_BATCH_BIJECTION", "entries and record source_paths differ", rel)
    return entries, record_map


def _validate_source_snapshot(report: CheckReport, root: Path, batch: dict[str, Any], entries: list[dict[str, Any]], rel: str) -> dict[str, bytes]:
    baseline = str(batch.get("baseline_commit", ""))
    try:
        tree = _ls_tree(root, baseline)
        oids = [tree.get(entry.get("path"), "") for entry in entries]
        blobs = _cat_blobs(root, [oid for oid in oids if oid])
    except RuntimeError as exc:
        report.fail("DOCLITE_RECOVERY_READ", str(exc), rel)
        return {}
    result: dict[str, bytes] = {}
    for entry in entries:
        path = str(entry.get("path", ""))
        oid = tree.get(path)
        if not oid:
            report.fail("DOCLITE_SOURCE_BASELINE", "source path is absent from baseline", path)
            continue
        blob = blobs.get(oid)
        if blob is None:
            report.fail("DOCLITE_SOURCE_BLOB", "source blob could not be read", path)
            continue
        if oid != entry.get("source_blob"):
            report.fail("DOCLITE_BLOB_MISMATCH", f"expected {entry.get('source_blob')}, got {oid}", path)
        digest = hashlib.sha256(blob).hexdigest()
        if digest != entry.get("source_sha256"):
            report.fail("DOCLITE_SHA_MISMATCH", f"expected {entry.get('source_sha256')}, got {digest}", path)
        if len(blob) != entry.get("byte_count") or len(blob.splitlines()) != entry.get("line_count"):
            report.fail("DOCLITE_COUNT_MISMATCH", "byte or line count differs from baseline", path)
        result[path] = blob
    return result


def _validate_receipt(
    report: CheckReport, root: Path, index_sha: str, manifest_sha: str,
    batch: dict[str, Any], entries: list[dict[str, Any]], records: dict[str, dict[str, Any]], receipt_rel: str,
) -> bool:
    receipt_path = root / receipt_rel
    if not receipt_path.is_file():
        return False
    try:
        receipt = read_json(receipt_path)
    except (OSError, json.JSONDecodeError) as exc:
        report.fail("DOCLITE_RECEIPT_JSON", str(exc), receipt_rel)
        return True
    expected = {
        "schema_version": 2,
        "batch_id": batch.get("batch_id"),
        "baseline_commit": batch.get("baseline_commit"),
        "recovery_tag": batch.get("recovery_tag"),
        "index_sha256": index_sha,
        "manifest_sha256": manifest_sha,
    }
    for key, value in expected.items():
        if receipt.get(key) != value:
            report.fail("DOCLITE_RECEIPT_HEADER", f"{key} mismatch", receipt_rel)
    receipt_entries = receipt.get("entries")
    if not isinstance(receipt_entries, list):
        report.fail("DOCLITE_RECEIPT_ENTRIES", "receipt entries must be an array", receipt_rel)
        return True
    by_path = {item.get("path"): item for item in receipt_entries if isinstance(item, dict)}
    if len(by_path) != len(receipt_entries) or set(by_path) != {entry.get("path") for entry in entries}:
        report.fail("DOCLITE_RECEIPT_BIJECTION", "receipt paths differ from manifest", receipt_rel)
    for entry in entries:
        path = entry.get("path")
        item = by_path.get(path, {})
        record = records.get(str(entry.get("record_id")), {})
        checks = {
            "sha256": entry.get("source_sha256"),
            "git_blob": entry.get("source_blob"),
            "record_id": entry.get("record_id"),
            "ledger_path": record.get("ledger_path"),
            "retained_authorities": entry.get("retained_authorities"),
        }
        for key, value in checks.items():
            if item.get(key) != value:
                report.fail("DOCLITE_RECEIPT_ENTRY", f"{key} mismatch", str(path))
        if (root / str(path)).exists():
            report.fail("DOCLITE_SOURCE_REINCIDENT", "cutover source is present in HEAD", str(path))
    return True


def _selected(batch: dict[str, Any], selector: str) -> bool:
    normalized = selector.casefold()
    if normalized in {"allofficial", "all"}:
        return True
    return normalized in {str(batch.get("project", "")).casefold(), str(batch.get("scope", "")).casefold()}


def check_documentation_lite(
    root: Path, config: dict[str, Any], *, mode: str = "Audit", batch_id: str = "",
    project: str = "AllOfficial", confirm_manifest_hash: str = "", ci: bool = False,
) -> CheckReport:
    report = CheckReport("documentation_lite")
    if mode not in MODES:
        report.fail("DOCLITE_MODE", f"unknown mode: {mode}")
        return report
    section = config.get("documentation_lite", {})
    index_rel = _safe_rel(section.get("manifest_index"))
    if not index_rel:
        report.fail("DOCLITE_CONFIG", "documentation_lite.manifest_index is invalid")
        return report
    index_path = root / index_rel
    if not index_path.is_file():
        report.fail("DOCLITE_INDEX_MISSING", "manifest index is missing", index_rel)
        return report
    try:
        index = read_json(index_path)
    except (OSError, json.JSONDecodeError) as exc:
        report.fail("DOCLITE_INDEX_JSON", str(exc), index_rel)
        return report
    if index.get("schema_version") != 2 or index.get("enforcement_mode") not in {"audit", "strict"}:
        report.fail("DOCLITE_INDEX_SCHEMA", "index must be v2 with audit or strict enforcement", index_rel)
        return report
    index_sha = _json_sha(index_path)
    auth = _validate_authorization(report, root, index, index_sha)
    descriptors = index.get("batches")
    if not isinstance(descriptors, list):
        report.fail("DOCLITE_INDEX_BATCHES", "index batches must be an array", index_rel)
        return report
    ids: set[str] = set()
    selected_count = cutover_count = source_count = 0
    execute_targets: list[tuple[dict[str, Any], str, str, list[dict[str, Any]], dict[str, dict[str, Any]]]] = []
    for descriptor in descriptors:
        if not isinstance(descriptor, dict):
            report.fail("DOCLITE_INDEX_ENTRY", "batch descriptor must be an object", index_rel)
            continue
        current_id = descriptor.get("batch_id")
        if not isinstance(current_id, str) or current_id in ids:
            report.fail("DOCLITE_INDEX_ID", f"invalid or duplicate batch id: {current_id!r}", index_rel)
            continue
        ids.add(current_id)
        manifest_rel = _safe_rel(descriptor.get("manifest"))
        receipt_rel = _safe_rel(descriptor.get("receipt"))
        if not manifest_rel or not receipt_rel:
            report.fail("DOCLITE_INDEX_PATH", f"unsafe manifest or receipt for {current_id}", index_rel)
            continue
        manifest_path = root / manifest_rel
        if not manifest_path.is_file():
            report.fail("DOCLITE_MANIFEST_MISSING", "batch manifest is missing", manifest_rel)
            continue
        manifest_sha = _json_sha(manifest_path)
        if descriptor.get("manifest_sha256") != manifest_sha:
            report.fail("DOCLITE_MANIFEST_HASH", "index hash differs from batch file", manifest_rel)
        try:
            batch = read_json(manifest_path)
        except (OSError, json.JSONDecodeError) as exc:
            report.fail("DOCLITE_MANIFEST_JSON", str(exc), manifest_rel)
            continue
        if batch.get("batch_id") != current_id:
            report.fail("DOCLITE_MANIFEST_ID", "descriptor and manifest batch ids differ", manifest_rel)
        if not _selected(batch, project) or (batch_id and batch_id != current_id):
            continue
        selected_count += 1
        entries, records = _validate_batch_shape(report, root, batch, manifest_rel)
        source_count += len(entries)
        _validate_source_snapshot(report, root, batch, entries, manifest_rel)
        receipt_exists = _validate_receipt(
            report, root, index_sha, manifest_sha, batch, entries, records, receipt_rel,
        )
        if receipt_exists:
            cutover_count += 1
        else:
            for entry in entries:
                if entry.get("disposition") == "remove_with_ledger" and not (root / str(entry.get("path"))).is_file():
                    report.fail("DOCLITE_SOURCE_MISSING", "prepared source is absent before receipt", str(entry.get("path")))
            if mode == "Verify":
                report.fail("DOCLITE_RECEIPT_MISSING", "Verify requires a removal receipt", receipt_rel)
            if index.get("enforcement_mode") == "strict":
                report.fail("DOCLITE_STRICT_PENDING", "strict mode requires every selected batch cut over", manifest_rel)
        if not ci:
            resolved = _tag_commit(root, str(batch.get("recovery_tag", "")))
            if resolved is None:
                report.warn("DOCLITE_TAG_LOCAL_MISSING", "local recovery tag is absent; commit-base recovery remains canonical", manifest_rel)
            elif resolved != batch.get("baseline_commit"):
                report.fail("DOCLITE_TAG_COMMIT", f"tag resolves to {resolved}, expected {batch.get('baseline_commit')}", manifest_rel)
        execute_targets.append((batch, manifest_rel, receipt_rel, entries, records))
    if batch_id and batch_id not in ids:
        report.fail("DOCLITE_BATCH_UNKNOWN", f"unknown batch: {batch_id}")
    if mode == "Execute":
        if not execute_targets:
            report.fail("DOCLITE_EXECUTE_EMPTY", "Execute selected no batch")
        if len(execute_targets) != 1:
            report.fail("DOCLITE_EXECUTE_SCOPE", "Execute requires exactly one batch")
        if auth is None or auth.get("status") != "approved":
            report.fail("DOCLITE_EXECUTE_AUTH", "Execute requires approved exact-index authorization")
        if confirm_manifest_hash != index_sha:
            report.fail("DOCLITE_EXECUTE_CONFIRM", f"ConfirmManifestHash must equal {index_sha}")
        status = _tracked_status(root)
        if status:
            report.fail("DOCLITE_EXECUTE_DIRTY", f"Execute requires a clean tree: {status[:5]}")
        if not report.failed and len(execute_targets) == 1:
            batch, manifest_rel, receipt_rel, entries, records = execute_targets[0]
            if (root / receipt_rel).exists():
                report.fail("DOCLITE_ALREADY_APPLIED", "ALREADY_APPLIED", receipt_rel)
            removable = [entry for entry in entries if entry.get("disposition") == "remove_with_ledger"]
            overlaps = _overlap_with_other_worktrees(root, {str(entry["path"]) for entry in removable})
            if overlaps:
                report.fail("DOCLITE_WORKTREE_OVERLAP", "; ".join(overlaps[:10]), manifest_rel)
            if not report.failed:
                for entry in removable:
                    (root / entry["path"]).unlink()
                receipt_path = root / receipt_rel
                receipt_path.parent.mkdir(parents=True, exist_ok=True)
                manifest_sha = _json_sha(root / manifest_rel)
                receipt = {
                    "schema_version": 2,
                    "receipt_id": f"receipt_{batch['batch_id']}",
                    "batch_id": batch["batch_id"],
                    "baseline_commit": batch["baseline_commit"],
                    "recovery_tag": batch["recovery_tag"],
                    "generated_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
                    "index_sha256": index_sha,
                    "manifest_sha256": manifest_sha,
                    "entries": [
                        {
                            "path": entry["path"],
                            "sha256": entry["source_sha256"],
                            "git_blob": entry["source_blob"],
                            "record_id": entry["record_id"],
                            "ledger_path": records[entry["record_id"]]["ledger_path"],
                            "retained_authorities": entry["retained_authorities"],
                        }
                        for entry in removable
                    ],
                }
                receipt_path.write_text(json.dumps(receipt, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
                report.metrics["executed_batch"] = batch["batch_id"]
                report.metrics["removed_paths"] = len(removable)
    if auth is not None and auth.get("status") == "pending" and mode in {"Audit", "Prepare"}:
        report.warn("DOCLITE_AUTH_PENDING", f"exact index approval pending: {index_sha}", index_rel)
    report.metrics.update(
        enforcement_mode=index.get("enforcement_mode"), index_sha256=index_sha,
        batches_selected=selected_count, batches_cutover=cutover_count, source_paths=source_count,
    )
    return report


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=str(Path(__file__).resolve().parent.parent))
    parser.add_argument("--config", default="tools/estudio_governance.json")
    parser.add_argument("--mode", choices=sorted(MODES), default="Audit")
    parser.add_argument("--batch", default="")
    parser.add_argument("--project", default="AllOfficial")
    parser.add_argument("--confirm-manifest-hash", default="")
    parser.add_argument("--ci", action="store_true")
    parser.add_argument("--audit-only", action="store_true")
    parser.add_argument("--report-path")
    args = parser.parse_args(argv)
    root = Path(args.root).resolve()
    try:
        config = load_governance(root, args.config)
        report = check_documentation_lite(
            root, config, mode=args.mode, batch_id=args.batch, project=args.project,
            confirm_manifest_hash=args.confirm_manifest_hash, ci=args.ci,
        )
    except Exception as exc:
        report = CheckReport("documentation_lite")
        report.fail("DOCLITE_ERROR", str(exc))
    return emit(report, args.audit_only, args.report_path)


if __name__ == "__main__":
    raise SystemExit(main())
