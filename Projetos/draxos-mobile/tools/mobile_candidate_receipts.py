#!/usr/bin/env python3
"""Prepare and verify immutable local mobile QA receipts.

The helper never builds, exports, installs, publishes, invokes a subprocess, or
accesses the network. Every mutating command is a dry-run unless --write is set.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath
from typing import Any, Iterable


CANDIDATE_SCHEMA = "draxos_mobile_candidate_receipt_v1"
QUALIFICATION_SCHEMA = "draxos_mobile_qualification_receipt_v1"
PROMOTION_SCHEMA = "draxos_mobile_promotion_receipt_v1"
HELPER_VERSION = "mobile_candidate_receipts.py/v1"
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
SOURCE_SHA_RE = re.compile(r"^[0-9a-f]{40,64}$")
ID_RE = re.compile(r"^[a-z][a-z0-9_]+$")
UTC_RE = re.compile(r"^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$")


class ReceiptError(ValueError):
    """Raised when receipt integrity or a local-only boundary is violated."""


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def receipt_bytes(payload: dict[str, Any]) -> bytes:
    return (json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n").encode("utf-8")


def now_utc() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).strftime("%Y-%m-%dT%H:%M:%SZ")


def require_utc(value: str) -> str:
    if not UTC_RE.fullmatch(value):
        raise ReceiptError("created_at_utc must use YYYY-MM-DDTHH:MM:SSZ")
    datetime.strptime(value, "%Y-%m-%dT%H:%M:%SZ")
    return value


def require_sha256(value: Any, label: str) -> str:
    text = str(value)
    if not SHA256_RE.fullmatch(text):
        raise ReceiptError(f"{label} must be a lowercase SHA256")
    return text


def require_id(value: str, label: str) -> str:
    if not ID_RE.fullmatch(value):
        raise ReceiptError(f"{label} must match {ID_RE.pattern}")
    return value


def require_exact_keys(payload: dict[str, Any], expected: set[str], label: str) -> None:
    actual = set(payload)
    if actual != expected:
        raise ReceiptError(
            f"{label} keys differ; missing={sorted(expected - actual)}, extra={sorted(actual - expected)}"
        )


def project_root(path: str | Path) -> Path:
    root = Path(path).resolve()
    if not root.is_dir():
        raise ReceiptError(f"project root does not exist: {root}")
    return root


def path_under(root: Path, path: str | Path, *, must_exist: bool = True) -> Path:
    candidate = Path(path)
    if not candidate.is_absolute():
        candidate = root / candidate
    resolved = candidate.resolve()
    try:
        resolved.relative_to(root)
    except ValueError as exc:
        raise ReceiptError(f"path is outside project root: {resolved}") from exc
    if must_exist and not resolved.is_file():
        raise ReceiptError(f"required file does not exist: {resolved}")
    return resolved


def relative_path(root: Path, path: Path) -> str:
    value = path.resolve().relative_to(root).as_posix()
    parsed = PurePosixPath(value)
    if parsed.is_absolute() or ".." in parsed.parts:
        raise ReceiptError(f"receipt path is not project-relative: {value}")
    return value


def output_root(root: Path, value: str | Path) -> Path:
    return path_under(root, value, must_exist=False)


def load_json(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise ReceiptError(f"invalid receipt JSON: {path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise ReceiptError(f"receipt root must be an object: {path}")
    return payload


def parse_named_files(root: Path, values: Iterable[str], label: str) -> list[dict[str, str]]:
    records: list[dict[str, str]] = []
    seen: set[str] = set()
    for value in values:
        if "=" not in value:
            raise ReceiptError(f"{label} must use id=path")
        record_id, raw_path = value.split("=", 1)
        require_id(record_id, f"{label} id")
        if record_id in seen:
            raise ReceiptError(f"duplicate {label} id: {record_id}")
        seen.add(record_id)
        file_path = path_under(root, raw_path)
        records.append(
            {
                "id": record_id,
                "relative_path": relative_path(root, file_path),
                "sha256": sha256_file(file_path),
            }
        )
    if not records:
        raise ReceiptError(f"at least one {label} is required")
    return records


def verify_stored_file(root: Path, relative: str, expected_sha256: str, label: str) -> Path:
    _validate_stored_relative_path(relative)
    file_path = path_under(root, relative)
    actual_sha256 = sha256_file(file_path)
    if actual_sha256 != require_sha256(expected_sha256, f"{label} sha256"):
        raise ReceiptError(f"{label} no longer matches receipt: {relative}")
    return file_path


def immutable_write(target: Path, payload: dict[str, Any], write: bool) -> bool:
    content = receipt_bytes(payload)
    if not write:
        return False
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        if target.read_bytes() == content:
            return False
        raise ReceiptError(f"immutable receipt already exists with different content: {target}")
    target.write_bytes(content)
    return True


def validate_candidate(payload: dict[str, Any]) -> None:
    require_exact_keys(
        payload,
        {
            "receipt_schema", "created_at_utc", "project", "channel", "source_sha",
            "artifact", "android", "toolchain", "validation", "git_snapshot_sha256",
            "remote_mutation", "published", "human_product_gate_approved",
        },
        "candidate receipt",
    )
    if payload["receipt_schema"] != CANDIDATE_SCHEMA or payload["project"] != "DraxosMobile":
        raise ReceiptError("candidate receipt schema/project mismatch")
    require_utc(str(payload["created_at_utc"]))
    if payload["channel"] != "internal_alpha":
        raise ReceiptError("candidate channel must be internal_alpha")
    if not SOURCE_SHA_RE.fullmatch(str(payload["source_sha"])):
        raise ReceiptError("source_sha must be a lowercase 40-64 character Git SHA")
    require_sha256(payload["git_snapshot_sha256"], "git_snapshot_sha256")
    if any(payload[key] is not False for key in ("remote_mutation", "published", "human_product_gate_approved")):
        raise ReceiptError("candidate safety flags must remain false")

    artifact = payload["artifact"]
    if not isinstance(artifact, dict):
        raise ReceiptError("candidate artifact must be an object")
    require_exact_keys(
        artifact,
        {"kind", "relative_path", "bytes", "sha256", "export_preset", "export_mode", "release_keystore_mode"},
        "candidate artifact",
    )
    if artifact["kind"] != "android_apk" or artifact["export_preset"] != "Android Alpha":
        raise ReceiptError("candidate must use the DraxosMobile Android Alpha APK preset")
    if artifact["export_mode"] not in {"release", "debug_fallback"}:
        raise ReceiptError("invalid Android export_mode")
    if artifact["release_keystore_mode"] != artifact["export_mode"]:
        raise ReceiptError("export_mode and release_keystore_mode must match")
    if not isinstance(artifact["bytes"], int) or artifact["bytes"] < 1:
        raise ReceiptError("candidate artifact bytes must be positive")
    require_sha256(artifact["sha256"], "artifact.sha256")
    _validate_stored_relative_path(str(artifact["relative_path"]))

    android = payload["android"]
    if not isinstance(android, dict):
        raise ReceiptError("candidate android field must be an object")
    require_exact_keys(
        android,
        {"resolved_min_sdk", "resolved_target_sdk", "resolved_compile_sdk", "architectures", "orientation"},
        "candidate android",
    )
    sdk_values = [android["resolved_min_sdk"], android["resolved_target_sdk"], android["resolved_compile_sdk"]]
    if any(not isinstance(value, int) or value < 1 for value in sdk_values):
        raise ReceiptError("resolved Android SDK values must be positive integers")
    if not sdk_values[0] <= sdk_values[1] <= sdk_values[2]:
        raise ReceiptError("resolved SDK order must be min <= target <= compile")
    if android["architectures"] != ["arm64-v8a"] or android["orientation"] != "portrait":
        raise ReceiptError("candidate must preserve arm64-v8a portrait contract")

    toolchain = payload["toolchain"]
    if not isinstance(toolchain, dict):
        raise ReceiptError("candidate toolchain must be an object")
    require_exact_keys(toolchain, {"godot_version", "receipt_helper"}, "candidate toolchain")
    if not str(toolchain["godot_version"]).strip() or toolchain["receipt_helper"] != HELPER_VERSION:
        raise ReceiptError("candidate toolchain identity is incomplete")

    validation = payload["validation"]
    if not isinstance(validation, list) or not validation:
        raise ReceiptError("candidate requires validation reports")
    ids: set[str] = set()
    for item in validation:
        if not isinstance(item, dict):
            raise ReceiptError("candidate validation entry must be an object")
        require_exact_keys(item, {"id", "result", "report_relative_path", "report_sha256"}, "validation entry")
        require_id(str(item["id"]), "validation id")
        if item["id"] in ids or item["result"] != "pass":
            raise ReceiptError("candidate validation IDs must be unique and pass")
        ids.add(item["id"])
        _validate_stored_relative_path(str(item["report_relative_path"]))
        require_sha256(item["report_sha256"], "validation report sha256")


def validate_qualification(payload: dict[str, Any]) -> None:
    require_exact_keys(
        payload,
        {
            "receipt_schema", "created_at_utc", "project", "candidate_receipt_relative_path",
            "candidate_receipt_sha256", "artifact_sha256", "artifact_reverified_sha256",
            "qualification_kind", "result", "profile_ids", "performed_by", "evidence",
            "rebuild_performed", "publication_executed", "remote_mutation",
        },
        "qualification receipt",
    )
    if payload["receipt_schema"] != QUALIFICATION_SCHEMA or payload["project"] != "DraxosMobile":
        raise ReceiptError("qualification receipt schema/project mismatch")
    require_utc(str(payload["created_at_utc"]))
    _validate_stored_relative_path(str(payload["candidate_receipt_relative_path"]))
    require_sha256(payload["candidate_receipt_sha256"], "candidate receipt sha256")
    artifact_sha = require_sha256(payload["artifact_sha256"], "artifact sha256")
    if require_sha256(payload["artifact_reverified_sha256"], "reverified artifact sha256") != artifact_sha:
        raise ReceiptError("qualification artifact hash changed")
    if payload["qualification_kind"] not in {"visual_check", "android_check", "physical_gate"}:
        raise ReceiptError("invalid qualification kind")
    if payload["result"] not in {"pass", "fail", "blocked"}:
        raise ReceiptError("invalid qualification result")
    profiles = payload["profile_ids"]
    if not isinstance(profiles, list) or not profiles or len(profiles) != len(set(profiles)):
        raise ReceiptError("qualification requires unique profile IDs")
    for profile_id in profiles:
        require_id(str(profile_id), "profile id")
    if not str(payload["performed_by"]).strip():
        raise ReceiptError("qualification performed_by is required")
    evidence = payload["evidence"]
    if not isinstance(evidence, list) or not evidence:
        raise ReceiptError("qualification requires evidence")
    evidence_ids: set[str] = set()
    for item in evidence:
        require_exact_keys(item, {"id", "relative_path", "sha256"}, "qualification evidence")
        require_id(str(item["id"]), "evidence id")
        if item["id"] in evidence_ids:
            raise ReceiptError("qualification evidence IDs must be unique")
        evidence_ids.add(item["id"])
        _validate_stored_relative_path(str(item["relative_path"]))
        require_sha256(item["sha256"], "evidence sha256")
    if (
        payload["qualification_kind"] == "physical_gate"
        and str(payload["performed_by"]).strip().casefold()
        in {"agent", "automation", "codex", "hermes", "system"}
    ):
        raise ReceiptError("physical_gate must identify a human tester")
    if any(payload[key] is not False for key in ("rebuild_performed", "publication_executed", "remote_mutation")):
        raise ReceiptError("qualification safety flags must remain false")


def validate_promotion(payload: dict[str, Any]) -> None:
    require_exact_keys(
        payload,
        {
            "receipt_schema", "created_at_utc", "project", "candidate_receipt_relative_path",
            "candidate_receipt_sha256", "artifact_sha256", "artifact_reverified_sha256",
            "qualification_receipts", "decision_reference", "authorized_by", "promotion_target",
            "record_status", "rebuild_performed", "publication_executed", "remote_mutation",
            "supersedes_receipt_sha256",
        },
        "promotion receipt",
    )
    if payload["receipt_schema"] != PROMOTION_SCHEMA or payload["project"] != "DraxosMobile":
        raise ReceiptError("promotion receipt schema/project mismatch")
    require_utc(str(payload["created_at_utc"]))
    _validate_stored_relative_path(str(payload["candidate_receipt_relative_path"]))
    require_sha256(payload["candidate_receipt_sha256"], "candidate receipt sha256")
    artifact_sha = require_sha256(payload["artifact_sha256"], "artifact sha256")
    if require_sha256(payload["artifact_reverified_sha256"], "reverified artifact sha256") != artifact_sha:
        raise ReceiptError("promotion artifact hash changed")
    qualifications = payload["qualification_receipts"]
    if not isinstance(qualifications, list) or not qualifications:
        raise ReceiptError("promotion requires qualification receipts")
    qualification_kinds: set[str] = set()
    for item in qualifications:
        require_exact_keys(item, {"relative_path", "sha256", "qualification_kind", "result"}, "promotion qualification")
        _validate_stored_relative_path(str(item["relative_path"]))
        require_sha256(item["sha256"], "qualification receipt sha256")
        if item["qualification_kind"] not in {"visual_check", "android_check", "physical_gate"} or item["result"] != "pass":
            raise ReceiptError("promotion accepts only passing qualification receipts")
        if item["qualification_kind"] in qualification_kinds:
            raise ReceiptError("promotion qualification kinds must be unique")
        qualification_kinds.add(item["qualification_kind"])
    if not {"android_check", "physical_gate"}.issubset(qualification_kinds):
        raise ReceiptError("promotion requires passing android_check and physical_gate receipts")
    decision = str(payload["decision_reference"]).strip()
    if not decision or decision.casefold() in {"none", "pending", "n/a"}:
        raise ReceiptError("promotion requires a resolved decision reference")
    authorized_by = str(payload["authorized_by"]).strip()
    if not authorized_by or authorized_by.casefold() in {"agent", "automation", "codex", "hermes", "system"}:
        raise ReceiptError("promotion authorization must identify a human decision owner")
    require_id(str(payload["promotion_target"]), "promotion target")
    if payload["record_status"] != "recorded_local_only":
        raise ReceiptError("promotion record must remain local-only")
    if any(payload[key] is not False for key in ("rebuild_performed", "publication_executed", "remote_mutation")):
        raise ReceiptError("promotion safety flags must remain false")
    supersedes = payload["supersedes_receipt_sha256"]
    if supersedes is not None:
        require_sha256(supersedes, "supersedes receipt sha256")


def _validate_stored_relative_path(value: str) -> None:
    parsed = PurePosixPath(value)
    if not value or parsed.is_absolute() or ".." in parsed.parts or "\\" in value:
        raise ReceiptError(f"receipt path must be a normalized project-relative path: {value}")


def candidate_receipt(
    root: Path,
    artifact_path: Path,
    *,
    source_sha: str,
    export_mode: str,
    min_sdk: int,
    target_sdk: int,
    compile_sdk: int,
    godot_version: str,
    git_snapshot_sha256: str,
    validation_reports: Iterable[str],
    created_at_utc: str,
) -> dict[str, Any]:
    artifact = path_under(root, artifact_path)
    if artifact.suffix.casefold() != ".apk" or artifact.stat().st_size < 1:
        raise ReceiptError("candidate artifact must be a non-empty APK")
    if not SOURCE_SHA_RE.fullmatch(source_sha):
        raise ReceiptError("source_sha must be a lowercase 40-64 character Git SHA")
    require_sha256(git_snapshot_sha256, "git snapshot sha256")
    reports = parse_named_files(root, validation_reports, "validation report")
    payload = {
        "receipt_schema": CANDIDATE_SCHEMA,
        "created_at_utc": require_utc(created_at_utc),
        "project": "DraxosMobile",
        "channel": "internal_alpha",
        "source_sha": source_sha,
        "artifact": {
            "kind": "android_apk",
            "relative_path": relative_path(root, artifact),
            "bytes": artifact.stat().st_size,
            "sha256": sha256_file(artifact),
            "export_preset": "Android Alpha",
            "export_mode": export_mode,
            "release_keystore_mode": export_mode,
        },
        "android": {
            "resolved_min_sdk": min_sdk,
            "resolved_target_sdk": target_sdk,
            "resolved_compile_sdk": compile_sdk,
            "architectures": ["arm64-v8a"],
            "orientation": "portrait",
        },
        "toolchain": {"godot_version": godot_version, "receipt_helper": HELPER_VERSION},
        "validation": [
            {
                "id": report["id"],
                "result": "pass",
                "report_relative_path": report["relative_path"],
                "report_sha256": report["sha256"],
            }
            for report in reports
        ],
        "git_snapshot_sha256": git_snapshot_sha256,
        "remote_mutation": False,
        "published": False,
        "human_product_gate_approved": False,
    }
    validate_candidate(payload)
    return payload


def load_candidate_with_artifact(root: Path, candidate_path: Path, artifact_path: Path | None = None) -> tuple[dict[str, Any], Path]:
    candidate_file = path_under(root, candidate_path)
    candidate = load_json(candidate_file)
    validate_candidate(candidate)
    receipt_artifact = path_under(root, candidate["artifact"]["relative_path"])
    if artifact_path is not None and path_under(root, artifact_path) != receipt_artifact:
        raise ReceiptError("artifact path does not match candidate receipt")
    actual_sha = sha256_file(receipt_artifact)
    if actual_sha != candidate["artifact"]["sha256"] or receipt_artifact.stat().st_size != candidate["artifact"]["bytes"]:
        raise ReceiptError("candidate artifact no longer matches receipt")
    for report in candidate["validation"]:
        verify_stored_file(
            root,
            report["report_relative_path"],
            report["report_sha256"],
            f"validation report {report['id']}",
        )
    return candidate, candidate_file


def qualification_receipt(
    root: Path,
    candidate_path: Path,
    artifact_path: Path,
    *,
    qualification_kind: str,
    result: str,
    profile_ids: list[str],
    performed_by: str,
    evidence_reports: Iterable[str],
    created_at_utc: str,
) -> dict[str, Any]:
    candidate, candidate_file = load_candidate_with_artifact(root, candidate_path, artifact_path)
    evidence = parse_named_files(root, evidence_reports, "evidence report")
    payload = {
        "receipt_schema": QUALIFICATION_SCHEMA,
        "created_at_utc": require_utc(created_at_utc),
        "project": "DraxosMobile",
        "candidate_receipt_relative_path": relative_path(root, candidate_file),
        "candidate_receipt_sha256": sha256_file(candidate_file),
        "artifact_sha256": candidate["artifact"]["sha256"],
        "artifact_reverified_sha256": sha256_file(path_under(root, artifact_path)),
        "qualification_kind": qualification_kind,
        "result": result,
        "profile_ids": profile_ids,
        "performed_by": performed_by,
        "evidence": evidence,
        "rebuild_performed": False,
        "publication_executed": False,
        "remote_mutation": False,
    }
    validate_qualification(payload)
    return payload


def load_qualification(root: Path, path: Path, candidate: dict[str, Any], candidate_file: Path) -> tuple[dict[str, Any], Path]:
    qualification_file = path_under(root, path)
    qualification = load_json(qualification_file)
    validate_qualification(qualification)
    if qualification["candidate_receipt_relative_path"] != relative_path(root, candidate_file):
        raise ReceiptError("qualification references a different candidate receipt")
    if qualification["candidate_receipt_sha256"] != sha256_file(candidate_file):
        raise ReceiptError("qualification candidate receipt hash changed")
    if qualification["artifact_sha256"] != candidate["artifact"]["sha256"]:
        raise ReceiptError("qualification references a different artifact hash")
    for evidence in qualification["evidence"]:
        verify_stored_file(
            root,
            evidence["relative_path"],
            evidence["sha256"],
            f"qualification evidence {evidence['id']}",
        )
    return qualification, qualification_file


def promotion_receipt(
    root: Path,
    candidate_path: Path,
    artifact_path: Path,
    *,
    qualification_paths: Iterable[Path],
    decision_reference: str,
    authorized_by: str,
    promotion_target: str,
    supersedes_receipt_sha256: str | None,
    created_at_utc: str,
) -> dict[str, Any]:
    candidate, candidate_file = load_candidate_with_artifact(root, candidate_path, artifact_path)
    qualification_records: list[dict[str, str]] = []
    for qualification_path in qualification_paths:
        qualification, qualification_file = load_qualification(root, qualification_path, candidate, candidate_file)
        qualification_records.append(
            {
                "relative_path": relative_path(root, qualification_file),
                "sha256": sha256_file(qualification_file),
                "qualification_kind": qualification["qualification_kind"],
                "result": qualification["result"],
            }
        )
    payload = {
        "receipt_schema": PROMOTION_SCHEMA,
        "created_at_utc": require_utc(created_at_utc),
        "project": "DraxosMobile",
        "candidate_receipt_relative_path": relative_path(root, candidate_file),
        "candidate_receipt_sha256": sha256_file(candidate_file),
        "artifact_sha256": candidate["artifact"]["sha256"],
        "artifact_reverified_sha256": sha256_file(path_under(root, artifact_path)),
        "qualification_receipts": qualification_records,
        "decision_reference": decision_reference,
        "authorized_by": authorized_by,
        "promotion_target": promotion_target,
        "record_status": "recorded_local_only",
        "rebuild_performed": False,
        "publication_executed": False,
        "remote_mutation": False,
        "supersedes_receipt_sha256": supersedes_receipt_sha256,
    }
    validate_promotion(payload)
    return payload


def target_for(out_root: Path, payload: dict[str, Any]) -> Path:
    schema = payload["receipt_schema"]
    artifact_sha = payload["artifact"]["sha256"] if schema == CANDIDATE_SCHEMA else payload["artifact_sha256"]
    if schema == CANDIDATE_SCHEMA:
        return out_root / "candidates" / artifact_sha / "candidate-receipt.json"
    payload_sha = hashlib.sha256(receipt_bytes(payload)).hexdigest()
    if schema == QUALIFICATION_SCHEMA:
        return out_root / "qualifications" / artifact_sha / payload["qualification_kind"] / f"{payload_sha}.json"
    return out_root / "promotions" / artifact_sha / payload["promotion_target"] / f"{payload_sha}.json"


def verify_receipt(root: Path, receipt_path: Path) -> str:
    receipt_file = path_under(root, receipt_path)
    payload = load_json(receipt_file)
    schema = payload.get("receipt_schema")
    if schema == CANDIDATE_SCHEMA:
        candidate, _ = load_candidate_with_artifact(root, receipt_file)
        return candidate["artifact"]["sha256"]
    if schema == QUALIFICATION_SCHEMA:
        validate_qualification(payload)
        candidate_path = path_under(root, payload["candidate_receipt_relative_path"])
        candidate, candidate_file = load_candidate_with_artifact(root, candidate_path)
        qualification, _ = load_qualification(root, receipt_file, candidate, candidate_file)
        return qualification["artifact_sha256"]
    if schema == PROMOTION_SCHEMA:
        validate_promotion(payload)
        candidate_path = path_under(root, payload["candidate_receipt_relative_path"])
        candidate, candidate_file = load_candidate_with_artifact(root, candidate_path)
        for item in payload["qualification_receipts"]:
            qualification_path = path_under(root, item["relative_path"])
            qualification, qualification_file = load_qualification(root, qualification_path, candidate, candidate_file)
            if (
                sha256_file(qualification_file) != item["sha256"]
                or qualification["qualification_kind"] != item["qualification_kind"]
                or qualification["result"] != item["result"]
            ):
                raise ReceiptError("promotion qualification reference is invalid")
        return payload["artifact_sha256"]
    raise ReceiptError(f"unknown receipt_schema: {schema}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    candidate = subparsers.add_parser("candidate", help="prepare a candidate receipt; dry-run by default")
    _common_root_output(candidate)
    candidate.add_argument("--artifact", required=True)
    candidate.add_argument("--source-sha", required=True)
    candidate.add_argument("--export-mode", choices=("release", "debug_fallback"), required=True)
    candidate.add_argument("--resolved-min-sdk", type=int, required=True)
    candidate.add_argument("--resolved-target-sdk", type=int, required=True)
    candidate.add_argument("--resolved-compile-sdk", type=int, required=True)
    candidate.add_argument("--godot-version", required=True)
    candidate.add_argument("--git-snapshot-sha256", required=True)
    candidate.add_argument("--validation-report", action="append", required=True, metavar="ID=PATH")
    candidate.add_argument("--created-at-utc", default=None)

    qualify = subparsers.add_parser("qualify", help="record a same-hash qualification; dry-run by default")
    _common_root_output(qualify)
    qualify.add_argument("--candidate-receipt", required=True)
    qualify.add_argument("--artifact", required=True)
    qualify.add_argument("--qualification-kind", choices=("visual_check", "android_check", "physical_gate"), required=True)
    qualify.add_argument("--result", choices=("pass", "fail", "blocked"), required=True)
    qualify.add_argument("--profile-id", action="append", required=True)
    qualify.add_argument("--performed-by", required=True)
    qualify.add_argument("--evidence-report", action="append", required=True, metavar="ID=PATH")
    qualify.add_argument("--created-at-utc", default=None)

    promotion = subparsers.add_parser("promotion", help="record a local-only same-hash promotion; dry-run by default")
    _common_root_output(promotion)
    promotion.add_argument("--candidate-receipt", required=True)
    promotion.add_argument("--artifact", required=True)
    promotion.add_argument("--qualification-receipt", action="append", required=True)
    promotion.add_argument("--decision-reference", required=True)
    promotion.add_argument("--authorized-by", required=True)
    promotion.add_argument("--promotion-target", required=True)
    promotion.add_argument("--supersedes-receipt-sha256")
    promotion.add_argument("--created-at-utc", default=None)

    verify = subparsers.add_parser("verify", help="verify a receipt and every local reference without writes")
    verify.add_argument("--project-root", default=".")
    verify.add_argument("--receipt", required=True)
    return parser
def _common_root_output(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--project-root", default=".")
    parser.add_argument("--output-root", default="build/qa/mobile")
    parser.add_argument("--write", action="store_true", help="write append-only receipt; default is dry-run")
def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        root = project_root(args.project_root)
        if args.command == "verify":
            artifact_sha = verify_receipt(root, Path(args.receipt))
            print(json.dumps({"verified": True, "artifact_sha256": artifact_sha}, indent=2))
            return 0

        created_at = args.created_at_utc or now_utc()
        out_root = output_root(root, args.output_root)
        if args.command == "candidate":
            payload = candidate_receipt(
                root,
                Path(args.artifact),
                source_sha=args.source_sha,
                export_mode=args.export_mode,
                min_sdk=args.resolved_min_sdk,
                target_sdk=args.resolved_target_sdk,
                compile_sdk=args.resolved_compile_sdk,
                godot_version=args.godot_version,
                git_snapshot_sha256=args.git_snapshot_sha256,
                validation_reports=args.validation_report,
                created_at_utc=created_at,
            )
        elif args.command == "qualify":
            payload = qualification_receipt(
                root,
                Path(args.candidate_receipt),
                Path(args.artifact),
                qualification_kind=args.qualification_kind,
                result=args.result,
                profile_ids=args.profile_id,
                performed_by=args.performed_by,
                evidence_reports=args.evidence_report,
                created_at_utc=created_at,
            )
        else:
            payload = promotion_receipt(
                root,
                Path(args.candidate_receipt),
                Path(args.artifact),
                qualification_paths=[Path(value) for value in args.qualification_receipt],
                decision_reference=args.decision_reference,
                authorized_by=args.authorized_by,
                promotion_target=args.promotion_target,
                supersedes_receipt_sha256=args.supersedes_receipt_sha256,
                created_at_utc=created_at,
            )
        target = target_for(out_root, payload)
        wrote = immutable_write(target, payload, args.write)
        print(
            json.dumps(
                {
                    "dry_run": not args.write,
                    "write_performed": wrote,
                    "target_relative_path": relative_path(root, target),
                    "receipt_sha256": hashlib.sha256(receipt_bytes(payload)).hexdigest(),
                    "receipt": payload,
                },
                indent=2,
                sort_keys=True,
                ensure_ascii=False,
            )
        )
        return 0
    except ReceiptError as exc:
        print(f"MOBILE_RECEIPT_ERROR: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
