#!/usr/bin/env python
"""Create a schema-compatible Estudio evidence manifest; dry-run by default."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
MANIFEST_NAME = "manifest.json"
ROLES = {"image", "metrics", "stdout", "video", "report", "other"}
IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp", ".gif"}
VIDEO_EXTENSIONS = {".mp4", ".webm", ".mov"}
METRIC_EXTENSIONS = {".json", ".csv", ".tsv"}
REPORT_EXTENSIONS = {".md", ".html", ".pdf"}
GLOB_CHARS = set("*?[]{}")


class ManifestError(ValueError):
    """A safe, user-facing manifest construction error."""


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def literal_relative(value: str, label: str) -> str:
    if not value or any(ord(char) < 32 for char in value):
        raise ManifestError(f"{label} must be a non-empty literal relative path")
    if any(char in GLOB_CHARS for char in value):
        raise ManifestError(f"{label} rejects glob syntax")
    if re.match(r"^[A-Za-z][A-Za-z0-9+.-]*://", value) or ":" in value:
        raise ManifestError(f"{label} rejects URLs and drive-qualified paths")
    normalized = value.replace("\\", "/")
    while normalized.startswith("./"):
        normalized = normalized[2:]
    path = Path(normalized)
    if path.is_absolute() or path.drive:
        raise ManifestError(f"{label} must be relative")
    parts = path.parts
    if not parts or any(part in {"", ".", "..", ".git"} for part in parts):
        raise ManifestError(f"{label} contains an unsafe path segment")
    return Path(*parts).as_posix()


def literal_directory(root: Path, value: str) -> Path:
    relative = literal_relative(value, "bundle")
    target = (root / relative).resolve()
    try:
        target.relative_to(root)
    except ValueError as exc:
        raise ManifestError("bundle escapes the workspace") from exc
    if not target.is_dir():
        raise ManifestError(f"bundle does not exist: {relative}")
    return target


def reject_reparse_chain(base: Path, target: Path, label: str) -> None:
    cursor = base / target.relative_to(base)
    while cursor != base:
        if cursor.is_symlink():
            raise ManifestError(f"{label} rejects symlinks or reparse points")
        cursor = cursor.parent


def literal_file(base: Path, value: str, label: str) -> tuple[str, Path]:
    relative = literal_relative(value, label)
    unresolved = base / relative
    target = unresolved.resolve()
    try:
        target.relative_to(base)
    except ValueError as exc:
        raise ManifestError(f"{label} escapes the bundle") from exc
    if not target.is_file():
        raise ManifestError(f"{label} does not exist: {relative}")
    reject_reparse_chain(base, unresolved, label)
    return relative, target


def infer_role(path: Path) -> str:
    suffix = path.suffix.casefold()
    name = path.name.casefold()
    if suffix in IMAGE_EXTENSIONS:
        return "image"
    if suffix in VIDEO_EXTENSIONS:
        return "video"
    if "stdout" in name or suffix in {".log", ".txt"}:
        return "stdout"
    if suffix in METRIC_EXTENSIONS:
        return "metrics"
    if suffix in REPORT_EXTENSIONS:
        return "report"
    return "other"


def parse_roles(values: list[str]) -> dict[str, str]:
    roles: dict[str, str] = {}
    for value in values:
        path_value, separator, role = value.rpartition("=")
        if not separator or role not in ROLES:
            raise ManifestError("role must use literal/path=allowed_role")
        relative = literal_relative(path_value, "role path")
        if relative in roles:
            raise ManifestError(f"duplicate role override: {relative}")
        roles[relative] = role
    return roles


def load_policy() -> tuple[set[str], dict[str, object]]:
    config_path = TOOLS / "estudio_governance.json"
    config = json.loads(config_path.read_text(encoding="utf-8"))
    projects = {str(project["id"]) for project in config["projects"]}
    return projects, config["evidence"]


def source_sha(root: Path, explicit: str | None) -> str:
    if explicit:
        value = explicit.casefold()
    else:
        process = subprocess.run(
            ["git", "-C", str(root), "rev-parse", "HEAD"],
            text=True,
            capture_output=True,
            check=False,
        )
        if process.returncode != 0:
            raise ManifestError("source SHA is required outside a Git worktree")
        value = process.stdout.strip().casefold()
    if not re.fullmatch(r"[0-9a-f]{7,64}", value):
        raise ManifestError("source SHA must be 7-64 hexadecimal characters")
    return value


def safe_field(value: str, label: str) -> str:
    clean = value.strip()
    if not clean or any(ord(char) < 32 for char in clean) or len(clean) > 200:
        raise ManifestError(f"{label} must be a short single-line value")
    return clean


def enforce_budgets(files: list[dict[str, object]], exception: str, policy: dict[str, object]) -> list[str]:
    total_bytes = sum(int(item["bytes"]) for item in files)
    canonical: dict[str, int] = {}
    for item in files:
        if item["canonical"]:
            role = str(item["role"])
            canonical[role] = canonical.get(role, 0) + 1
    for role, maximum in dict(policy["canonical_limits"]).items():
        if canonical.get(str(role), 0) > int(maximum):
            raise ManifestError(f"canonical {role} limit exceeded")
    warnings: list[str] = []
    if len(files) > int(policy["normal_max_files"]) or total_bytes > int(policy["normal_max_bytes"]):
        warnings.append(f"normal evidence budget exceeded: files={len(files)} bytes={total_bytes}")
    if (len(files) > int(policy["warning_max_files"]) or total_bytes > int(policy["warning_max_bytes"])) and not exception:
        raise ManifestError("warning evidence budget exceeded without --exception")
    return warnings


def build_manifest(args: argparse.Namespace) -> tuple[Path, dict[str, object], list[str]]:
    root = Path(args.root).resolve()
    if not root.is_dir():
        raise ManifestError("root must be an existing directory")
    bundle = literal_directory(root, args.bundle)
    projects, policy = load_policy()
    project = safe_field(args.project, "project")
    if project not in projects:
        raise ManifestError(f"unknown official project: {project}")
    if not args.file:
        raise ManifestError("at least one explicit --file is required")

    role_overrides = parse_roles(args.role)
    canonical_values = {literal_relative(value, "canonical path") for value in args.canonical}
    file_map: dict[str, Path] = {}
    for value in args.file:
        relative, target = literal_file(bundle, value, "file")
        if relative == MANIFEST_NAME:
            raise ManifestError("manifest.json cannot manifest itself")
        if relative in file_map:
            raise ManifestError(f"duplicate file: {relative}")
        file_map[relative] = target
    unknown_roles = sorted(set(role_overrides) - set(file_map))
    unknown_canonical = sorted(canonical_values - set(file_map))
    if unknown_roles or unknown_canonical:
        raise ManifestError("role and canonical paths must also be declared with --file")

    files: list[dict[str, object]] = []
    for relative in sorted(file_map):
        path = file_map[relative]
        files.append(
            {
                "path": relative,
                "role": role_overrides.get(relative, infer_role(path)),
                "bytes": path.stat().st_size,
                "sha256": sha256(path),
                "canonical": relative in canonical_values,
            }
        )
    exception = args.exception.strip()
    warnings = enforce_budgets(files, exception, policy)
    manifest: dict[str, object] = {
        "schema": str(policy["schema"]),
        "project": project,
        "task_id": safe_field(args.task_id, "task ID"),
        "source_sha": source_sha(root, args.source_sha),
        "environment": safe_field(args.environment, "environment"),
        "files": files,
    }
    if exception:
        manifest["exception"] = safe_field(exception, "exception")
    return bundle, manifest, warnings


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=".")
    parser.add_argument("--bundle", required=True, help="Literal bundle directory relative to root")
    parser.add_argument("--project", required=True)
    parser.add_argument("--task-id", required=True)
    parser.add_argument("--source-sha")
    parser.add_argument("--environment", default="local")
    parser.add_argument("--file", action="append", default=[], help="Literal file path relative to bundle")
    parser.add_argument("--role", action="append", default=[], help="Override as literal/path=role")
    parser.add_argument("--canonical", action="append", default=[], help="Canonical file also declared by --file")
    parser.add_argument("--exception", default="")
    parser.add_argument("--write", action="store_true", help="Write a new manifest.json; never overwrites")
    args = parser.parse_args()
    try:
        bundle, manifest, warnings = build_manifest(args)
        output = json.dumps(manifest, indent=2, ensure_ascii=False, sort_keys=False) + "\n"
        if args.write:
            target = bundle / MANIFEST_NAME
            if target.exists():
                raise ManifestError("manifest.json already exists; overwrite is not supported")
            target.write_text(output, encoding="utf-8", newline="\n")
        print(output, end="")
        for warning in warnings:
            print(f"EVIDENCE_MANIFEST_WARNING {warning}", file=sys.stderr)
        mode = "write" if args.write else "dry-run"
        print(f"EVIDENCE_MANIFEST_PASS mode={mode}", file=sys.stderr)
        return 0
    except (ManifestError, OSError, json.JSONDecodeError) as exc:
        print(f"EVIDENCE_MANIFEST_FAIL {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
