#!/usr/bin/env python3
"""Repository-level governance checks for Estudio.

All policies are prospective. Historical files are measured from explicit
baselines; this module never rewrites, deletes or restores repository content.
"""
from __future__ import annotations

import argparse
import datetime as dt
import fnmatch
import hashlib
import json
import os
import re
import subprocess
from itertools import combinations
from pathlib import Path
from typing import Any

from estudio_governance import CheckReport, emit, git, load_governance, read_json, resolve_projects, tracked_files


UID_RE = re.compile(r"^uid://[a-z0-9]+$")


def _rel(path: Path, root: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def check_uids(root: Path, config: dict[str, Any], selected: set[str]) -> CheckReport:
    report = CheckReport("godot_uid_sidecars")
    tracked = set(tracked_files(root))
    scripts: set[str] = set()
    script_projects: dict[str, str] = {}
    sidecars: set[str] = set()
    for project in config["projects"]:
        if project["id"] not in selected:
            continue
        project_root = root / project["root"]
        if not project_root.is_dir():
            report.fail("UID_PROJECT_MISSING", "project root is missing", project["root"])
            continue
        for path in project_root.rglob("*.gd"):
            rel = _rel(path, root)
            if "/.godot/" in f"/{rel}/" or "/build/" in f"/{rel}/" or "/cache/" in f"/{rel}/":
                continue
            if rel in tracked:
                scripts.add(rel)
                script_projects[rel] = project["id"]
        for path in project_root.rglob("*.gd.uid"):
            rel = _rel(path, root)
            if "/.godot/" in f"/{rel}/" or "/build/" in f"/{rel}/" or "/cache/" in f"/{rel}/":
                continue
            sidecars.add(rel)

    # Godot UID namespaces are project-local. Vendored addons legitimately keep
    # the same UID when copied into several independent projects.
    values: dict[tuple[str, str], list[str]] = {}
    for script in sorted(scripts):
        sidecar = f"{script}.uid"
        path = root / sidecar
        if not path.is_file():
            report.fail("UID_MISSING", "script has no .gd.uid sidecar", script)
            continue
        if sidecar not in tracked:
            report.fail("UID_UNTRACKED", "sidecar exists but is not tracked", sidecar)
        ignored = subprocess.run(
            ["git", "check-ignore", "--no-index", "--quiet", "--", sidecar],
            cwd=root, check=False,
        ).returncode == 0
        if ignored:
            report.fail("UID_IGNORED", "sidecar is matched by .gitignore", sidecar)
        value = path.read_text(encoding="utf-8", errors="replace").strip()
        if not UID_RE.fullmatch(value):
            report.fail("UID_INVALID", "sidecar must contain one uid://[a-z0-9]+ value", sidecar)
            continue
        values.setdefault((script_projects[script], value), []).append(sidecar)
    for sidecar in sorted(sidecars):
        script = sidecar[:-4]
        if script not in scripts:
            report.fail("UID_ORPHAN", "sidecar has no tracked .gd script", sidecar)
    for (project_id, value), paths in sorted(values.items()):
        if len(paths) > 1:
            report.fail("UID_DUPLICATE", f"{value} is reused inside {project_id} by {len(paths)} sidecars: {paths}")
    report.metrics.update({"scripts": len(scripts), "sidecars": len(sidecars), "unique_uids": len(values)})
    return report


def _excluded(rel: str, patterns: list[str]) -> bool:
    normalized = rel.replace("\\", "/")
    return any(fnmatch.fnmatch(normalized, pattern) for pattern in patterns)


def check_health(root: Path, config: dict[str, Any], selected: set[str]) -> CheckReport:
    report = CheckReport("engineering_health")
    policy = config["engineering_health"]
    warning = int(policy["warning_lines"])
    failure = int(policy["failure_lines"])
    baseline_data = read_json(root / policy["baseline"])
    baseline = {entry["path"]: entry for entry in baseline_data.get("large_files", [])}
    project_roots = [project["root"].rstrip("/") + "/" for project in config["projects"] if project["id"] in selected]
    scanned = 0
    large = 0
    for rel in tracked_files(root):
        if not rel.endswith(".gd") or not any(rel.startswith(prefix) for prefix in project_roots):
            continue
        if _excluded(rel, policy.get("exclude_patterns", [])):
            continue
        path = root / rel
        try:
            lines = len(path.read_text(encoding="utf-8", errors="strict").splitlines())
        except UnicodeDecodeError:
            continue
        scanned += 1
        if lines > warning:
            large += 1
            report.warn("HEALTH_LARGE_FILE", f"{lines} lines exceeds warning threshold {warning}", rel)
        if lines > failure:
            entry = baseline.get(rel)
            if entry is None:
                report.fail("HEALTH_UNBASELINED", f"{lines} lines exceeds hard threshold {failure} without baseline", rel)
            elif lines > int(entry["baseline_lines"]):
                report.fail("HEALTH_GROWTH", f"grew from baseline {entry['baseline_lines']} to {lines} lines", rel)
            if entry is not None and (not entry.get("reason") or not entry.get("review_when")):
                report.fail("HEALTH_BASELINE_METADATA", "baseline requires reason and review_when", rel)
    report.metrics.update({"files_scanned": scanned, "large_files": large, "baseline_entries": len(baseline)})
    return report


def _merge_base(root: Path, base_ref: str) -> str:
    return git(root, "merge-base", "HEAD", base_ref).strip()


def _changed_added(root: Path, base_ref: str) -> set[str]:
    merge_base = _merge_base(root, base_ref)
    added = set(git(root, "diff", "--diff-filter=A", "--name-only", f"{merge_base}..HEAD").splitlines())
    added.update(git(root, "ls-files", "--others", "--exclude-standard").splitlines())
    return {path for path in added if path}


def _lfs_tracked(root: Path, rel: str) -> bool:
    value = git(root, "check-attr", "filter", "--", rel, check=False)
    return value.rstrip().endswith(": lfs")


def check_storage(root: Path, config: dict[str, Any], base_ref: str) -> CheckReport:
    report = CheckReport("repository_storage")
    policy = config["repository_storage"]
    binary_ext = {item.casefold() for item in policy["binary_extensions"]}
    exceptions = {item.get("path") for item in policy.get("exceptions", [])}
    added = _changed_added(root, base_ref)
    added_binaries = [rel for rel in added if (root / rel).is_file() and (root / rel).suffix.casefold() in binary_ext]
    all_binary_hashes: dict[str, list[str]] = {}
    min_duplicate = int(policy["duplicate_min_bytes"])
    tracked = set(tracked_files(root))
    for rel in tracked:
        path = root / rel
        if path.is_file() and path.suffix.casefold() in binary_ext and path.stat().st_size >= min_duplicate:
            all_binary_hashes.setdefault(_sha256(path), []).append(rel)
    for rel in added_binaries:
        path = root / rel
        if rel not in tracked and path.stat().st_size >= min_duplicate:
            all_binary_hashes.setdefault(_sha256(path), []).append(rel)
    for rel in sorted(added_binaries):
        path = root / rel
        size = path.stat().st_size
        if size > int(policy["warning_binary_bytes"]):
            report.warn("STORAGE_LARGE_BINARY", f"new binary is {size} bytes", rel)
        if size > int(policy["failure_binary_bytes"]) and rel not in exceptions and not _lfs_tracked(root, rel):
            report.fail("STORAGE_LFS_REQUIRED", "new binary over hard limit requires literal LFS tracking or exception", rel)
        if size >= min_duplicate:
            duplicates = all_binary_hashes.get(_sha256(path), [])
            allowed = any(rel == item.get("path") for item in policy.get("duplicate_exceptions", []))
            if len(duplicates) > 1 and not allowed:
                report.fail("STORAGE_NEW_DUPLICATE", f"new binary duplicates: {duplicates}", rel)
    lfs_proc = subprocess.run(["git", "lfs", "version"], cwd=root, text=True, capture_output=True, check=False)
    if lfs_proc.returncode != 0:
        report.fail("STORAGE_GIT_LFS", "Git LFS is unavailable")
    report.metrics.update({"added_files": len(added), "added_binaries": len(added_binaries)})
    return report


def _safe_manifest_path(value: str) -> bool:
    path = Path(value)
    return bool(value) and not path.is_absolute() and ".." not in path.parts and not re.match(r"^[A-Za-z]:", value)


def _validate_evidence_manifest(bundle: Path, manifest: Path, config: dict[str, Any], report: CheckReport, rel_manifest: str) -> None:
    try:
        data = read_json(manifest)
    except (OSError, json.JSONDecodeError) as exc:
        report.fail("EVIDENCE_MANIFEST_JSON", str(exc), rel_manifest)
        return
    policy = config["evidence"]
    allowed_root = {"schema", "project", "task_id", "source_sha", "environment", "exception", "files"}
    unexpected_root = sorted(set(data) - allowed_root)
    if unexpected_root:
        report.fail("EVIDENCE_UNEXPECTED_FIELD", f"unexpected manifest fields: {unexpected_root}", rel_manifest)
    serialized = json.dumps(data, ensure_ascii=False).casefold()
    for token in ["service_role", "sb_secret_", "database_password", "keystore_password", "authorization: bearer"]:
        if token in serialized:
            report.fail("EVIDENCE_SECRET", f"secret-like token is forbidden: {token}", rel_manifest)
    if data.get("schema") != policy["schema"]:
        report.fail("EVIDENCE_SCHEMA", f"schema must be {policy['schema']}", rel_manifest)
    for field in ["project", "task_id", "source_sha", "environment", "files"]:
        if field not in data:
            report.fail("EVIDENCE_REQUIRED", f"missing field: {field}", rel_manifest)
    files = data.get("files", [])
    if not isinstance(files, list):
        report.fail("EVIDENCE_FILES", "files must be an array", rel_manifest)
        return
    total_bytes = 0
    canonical: dict[str, int] = {}
    seen: set[str] = set()
    for entry in files:
        if not isinstance(entry, dict):
            report.fail("EVIDENCE_FILE_ENTRY", "each file entry must be an object", rel_manifest)
            continue
        allowed_entry = {"path", "role", "bytes", "sha256", "canonical"}
        missing_entry = sorted(allowed_entry - set(entry))
        unexpected_entry = sorted(set(entry) - allowed_entry)
        if missing_entry:
            report.fail("EVIDENCE_FILE_REQUIRED", f"file entry missing: {missing_entry}", rel_manifest)
        if unexpected_entry:
            report.fail("EVIDENCE_FILE_FIELD", f"unexpected file fields: {unexpected_entry}", rel_manifest)
        value = str(entry.get("path", ""))
        if not _safe_manifest_path(value):
            report.fail("EVIDENCE_PATH", f"unsafe relative path: {value!r}", rel_manifest)
            continue
        if value in seen:
            report.fail("EVIDENCE_PATH_DUPLICATE", f"duplicate file entry: {value}", rel_manifest)
        seen.add(value)
        path = bundle / value
        if not path.is_file():
            report.fail("EVIDENCE_FILE_MISSING", f"manifested file is missing: {value}", rel_manifest)
            continue
        size = path.stat().st_size
        digest = _sha256(path)
        if entry.get("role") not in {"image", "metrics", "stdout", "video", "report", "other"}:
            report.fail("EVIDENCE_ROLE", f"invalid role for {value}: {entry.get('role')}", rel_manifest)
        if not isinstance(entry.get("canonical"), bool):
            report.fail("EVIDENCE_CANONICAL", f"canonical must be boolean for {value}", rel_manifest)
        if entry.get("bytes") != size:
            report.fail("EVIDENCE_BYTES", f"size mismatch for {value}: expected {entry.get('bytes')}, got {size}", rel_manifest)
        if entry.get("sha256") != digest:
            report.fail("EVIDENCE_HASH", f"SHA256 mismatch for {value}", rel_manifest)
        total_bytes += size
        if entry.get("canonical"):
            role = str(entry.get("role", "other"))
            canonical[role] = canonical.get(role, 0) + 1
    exception = str(data.get("exception", "")).strip()
    if len(files) > int(policy["normal_max_files"]) or total_bytes > int(policy["normal_max_bytes"]):
        report.warn("EVIDENCE_BUDGET_WARNING", f"bundle has {len(files)} files and {total_bytes} bytes", rel_manifest)
    if (len(files) > int(policy["warning_max_files"]) or total_bytes > int(policy["warning_max_bytes"])) and not exception:
        report.fail("EVIDENCE_BUDGET_EXCEPTION", "bundle above warning budget requires exception", rel_manifest)
    for role, maximum in policy["canonical_limits"].items():
        if canonical.get(role, 0) > int(maximum):
            report.fail("EVIDENCE_CANONICAL_BUDGET", f"canonical {role} count {canonical[role]} exceeds {maximum}", rel_manifest)


def check_evidence(root: Path, config: dict[str, Any], selected: set[str], base_ref: str) -> CheckReport:
    report = CheckReport("evidence_budget")
    added = _changed_added(root, base_ref)
    manifest_name = config["evidence"]["manifest_name"]
    bundles: set[tuple[str, str]] = set()
    for project in config["projects"]:
        if project["id"] not in selected:
            continue
        for evidence_root in project["evidence_roots"]:
            prefix = evidence_root.rstrip("/") + "/"
            for rel in added:
                if not rel.startswith(prefix):
                    continue
                remainder = rel[len(prefix):]
                task_id = remainder.split("/", 1)[0]
                if task_id:
                    bundles.add((evidence_root, task_id))
    for evidence_root, task_id in sorted(bundles):
        bundle = root / evidence_root / task_id
        manifest = bundle / manifest_name
        rel_manifest = f"{evidence_root}/{task_id}/{manifest_name}"
        if not manifest.is_file():
            report.fail("EVIDENCE_MANIFEST_MISSING", "new evidence bundle requires manifest.json", rel_manifest)
            continue
        _validate_evidence_manifest(bundle, manifest, config, report, rel_manifest)
    report.metrics["new_bundles"] = len(bundles)
    return report


def _worktree_records(root: Path) -> list[dict[str, str]]:
    raw = git(root, "worktree", "list", "--porcelain")
    records: list[dict[str, str]] = []
    current: dict[str, str] = {}
    for line in raw.splitlines() + [""]:
        if not line:
            if current:
                records.append(current)
                current = {}
            continue
        key, _, value = line.partition(" ")
        current[key] = value
    return records


def _dirty_worktree_changes(path: Path) -> set[str]:
    changes: set[str] = set()
    changes.update(git(path, "diff", "--cached", "--name-only", check=False).splitlines())
    changes.update(git(path, "diff", "--name-only", check=False).splitlines())
    changes.update(git(path, "ls-files", "--others", "--exclude-standard", check=False).splitlines())
    return {item for item in changes if item}


def _branch_changes_since(root: Path, branch: str, base: str) -> set[str]:
    return set(git(root, "diff", "--name-only", f"{base}..{branch}", check=False).splitlines())


def _overlap_allowed(branch_a: str, branch_b: str, path: str, config: dict[str, Any]) -> bool:
    today = dt.date.today()
    for exception in config["multiagent"].get("overlap_exceptions", []):
        patterns = exception.get("branch_patterns", [])
        if len(patterns) != 2:
            continue
        direct = fnmatch.fnmatch(branch_a, patterns[0]) and fnmatch.fnmatch(branch_b, patterns[1])
        inverse = fnmatch.fnmatch(branch_b, patterns[0]) and fnmatch.fnmatch(branch_a, patterns[1])
        if not (direct or inverse) or not path.startswith(str(exception.get("path_prefix", "")).casefold()):
            continue
        expires = exception.get("expires")
        if expires and dt.date.fromisoformat(expires) < today:
            continue
        if exception.get("reason") and exception.get("review_when"):
            return True
    return False


def check_worktrees(root: Path, config: dict[str, Any], base_ref: str) -> CheckReport:
    report = CheckReport("worktree_overlap")
    records = [item for item in _worktree_records(root) if "branch" in item and Path(item["worktree"]).exists()]
    state: list[tuple[str, Path, set[str]]] = []
    for record in records:
        branch = record["branch"].removeprefix("refs/heads/")
        path = Path(record["worktree"])
        state.append((branch, path, _dirty_worktree_changes(path)))
    overlaps = 0
    for (branch_a, path_a, dirty_a), (branch_b, path_b, dirty_b) in combinations(state, 2):
        merge_proc = subprocess.run(
            ["git", "merge-base", branch_a, branch_b], cwd=root,
            text=True, capture_output=True, check=False,
        )
        if merge_proc.returncode != 0:
            report.fail("WORKTREE_MERGE_BASE", f"cannot resolve merge-base for {branch_a} and {branch_b}")
            continue
        pair_base = merge_proc.stdout.strip()
        raw_a = _branch_changes_since(root, branch_a, pair_base) | dirty_a
        raw_b = _branch_changes_since(root, branch_b, pair_base) | dirty_b
        changes_a = {item.casefold(): item for item in raw_a}
        changes_b = {item.casefold(): item for item in raw_b}
        for normalized in sorted(set(changes_a) & set(changes_b)):
            if _overlap_allowed(branch_a, branch_b, normalized, config):
                continue
            overlaps += 1
            report.fail(
                "WORKTREE_OVERLAP",
                f"{branch_a} ({path_a}) overlaps {branch_b} ({path_b})",
                changes_a[normalized],
            )
    report.metrics.update({"worktrees": len(records), "overlaps": overlaps})
    return report


def _git_bytes(root: Path, *args: str) -> bytes:
    proc = subprocess.run(["git", *args], cwd=root, capture_output=True, check=False)
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.decode("utf-8", errors="replace"))
    return proc.stdout


def git_snapshot(root: Path) -> dict[str, Any]:
    status = _git_bytes(root, "status", "--porcelain=v2", "-z", "--untracked-files=all")
    index_diff = _git_bytes(root, "diff", "--cached", "--binary", "--no-ext-diff")
    worktree_diff = _git_bytes(root, "diff", "--binary", "--no-ext-diff")
    untracked = git(root, "ls-files", "--others", "--exclude-standard").splitlines()
    return {
        "schema": "estudio_git_snapshot_v1",
        "head": git(root, "rev-parse", "HEAD").strip(),
        "status_sha256": hashlib.sha256(status).hexdigest(),
        "index_diff_sha256": hashlib.sha256(index_diff).hexdigest(),
        "worktree_diff_sha256": hashlib.sha256(worktree_diff).hexdigest(),
        "untracked": {rel: _sha256(root / rel) for rel in sorted(untracked) if (root / rel).is_file()},
    }


def check_clean(root: Path) -> CheckReport:
    report = CheckReport("clean_tree")
    status = git(root, "status", "--porcelain=v1", "--untracked-files=all")
    if status.strip():
        for line in status.splitlines():
            report.fail("GIT_DIRTY", line)
    report.metrics["dirty_entries"] = len(status.splitlines())
    return report


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=["uids", "health", "storage", "evidence", "worktrees", "clean", "snapshot", "compare", "all"])
    parser.add_argument("--root", default=str(Path(__file__).resolve().parent.parent))
    parser.add_argument("--config", default="tools/estudio_governance.json")
    parser.add_argument("--project", default="AllOfficial")
    parser.add_argument("--base-ref", default="main")
    parser.add_argument("--audit-only", action="store_true")
    parser.add_argument("--report-path")
    parser.add_argument("--output")
    parser.add_argument("--before")
    args = parser.parse_args(argv)
    root = Path(args.root).resolve()
    if args.command == "snapshot":
        payload = git_snapshot(root)
        text = json.dumps(payload, indent=2) + "\n"
        if not args.output:
            print(text, end="")
        else:
            target = Path(args.output)
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(text, encoding="utf-8")
        return 0
    if args.command == "compare":
        report = CheckReport("validator_side_effect")
        if not args.before:
            report.fail("SNAPSHOT_REQUIRED", "--before is required")
        else:
            before = read_json(Path(args.before))
            after = git_snapshot(root)
            for key in ["head", "status_sha256", "index_diff_sha256", "worktree_diff_sha256", "untracked"]:
                if before.get(key) != after.get(key):
                    report.fail("VALIDATOR_SIDE_EFFECT", f"Git snapshot changed: {key}")
        return emit(report, args.audit_only, args.report_path)
    try:
        config = load_governance(root, args.config)
        selected = {project["id"] for project in resolve_projects(config, args.project)}
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        report = CheckReport(args.command)
        report.fail("CONFIG_LOAD", str(exc), args.config)
        return emit(report, args.audit_only, args.report_path)
    checks: list[CheckReport] = []
    if args.command in {"uids", "all"}:
        checks.append(check_uids(root, config, selected))
    if args.command in {"health", "all"}:
        checks.append(check_health(root, config, selected))
    if args.command in {"storage", "all"}:
        checks.append(check_storage(root, config, args.base_ref))
    if args.command in {"evidence", "all"}:
        checks.append(check_evidence(root, config, selected, args.base_ref))
    if args.command in {"worktrees", "all"}:
        checks.append(check_worktrees(root, config, args.base_ref))
    if args.command == "clean":
        checks.append(check_clean(root))
    combined = CheckReport(args.command)
    for check in checks:
        combined.issues.extend(check.issues)
        combined.metrics[check.name] = check.metrics
    return emit(combined, args.audit_only, args.report_path)


if __name__ == "__main__":
    raise SystemExit(main())
