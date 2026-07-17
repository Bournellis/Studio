#!/usr/bin/env python3
"""Dependency-free governance, text, documentation and QA contract checks.

The JSON schema files are the public contracts.  This module performs the
runtime checks without requiring a package installation in local worktrees or
the first Windows CI lane.
"""
from __future__ import annotations

import argparse
import dataclasses
import datetime as dt
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any, Iterable


@dataclasses.dataclass(frozen=True)
class Issue:
    severity: str
    code: str
    message: str
    path: str = ""


class CheckReport:
    def __init__(self, name: str) -> None:
        self.name = name
        self.issues: list[Issue] = []
        self.metrics: dict[str, Any] = {}

    def fail(self, code: str, message: str, path: str = "") -> None:
        self.issues.append(Issue("fail", code, message, path))

    def warn(self, code: str, message: str, path: str = "") -> None:
        self.issues.append(Issue("warn", code, message, path))

    @property
    def failed(self) -> bool:
        return any(item.severity == "fail" for item in self.issues)

    def as_dict(self, audit_only: bool = False) -> dict[str, Any]:
        status = "audit_fail" if audit_only and self.failed else "fail" if self.failed else "warn" if self.issues else "pass"
        return {
            "check": self.name,
            "status": status,
            "metrics": self.metrics,
            "issues": [dataclasses.asdict(item) for item in self.issues],
        }


def repo_root_from(script: Path | None = None) -> Path:
    anchor = script or Path(__file__)
    return anchor.resolve().parent.parent


def read_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def git(root: Path, *args: str, check: bool = True) -> str:
    proc = subprocess.run(
        ["git", *args], cwd=root, text=True, encoding="utf-8", errors="replace",
        capture_output=True, check=False,
    )
    if check and proc.returncode != 0:
        raise RuntimeError(f"git {' '.join(args)} failed: {proc.stderr.strip()}")
    return proc.stdout


def tracked_files(root: Path) -> list[str]:
    return [line for line in git(root, "ls-files").splitlines() if line]


def load_governance(root: Path, config_path: str = "tools/estudio_governance.json") -> dict[str, Any]:
    path = (root / config_path).resolve()
    config = read_json(path)
    issues = validate_governance(config, root)
    failures = [item for item in issues if item.severity == "fail"]
    if failures:
        raise ValueError("; ".join(f"{item.code}: {item.message}" for item in failures))
    return config


def validate_governance(config: Any, root: Path) -> list[Issue]:
    report = CheckReport("governance")
    required = {
        "schema_version", "authority_documents", "toolchain", "groups", "projects",
        "documentation", "qa", "engineering_health", "evidence",
        "repository_storage", "multiagent", "fast_suite",
    }
    if not isinstance(config, dict):
        return [Issue("fail", "CONFIG_TYPE", "governance root must be an object")]
    if config.get("schema_version") != 1:
        report.fail("CONFIG_SCHEMA_VERSION", "schema_version must be 1")
    missing = sorted(required - set(config))
    if missing:
        report.fail("CONFIG_REQUIRED", f"missing sections: {', '.join(missing)}")
        return report.issues

    projects = config.get("projects")
    if not isinstance(projects, list) or not projects:
        report.fail("CONFIG_PROJECTS", "projects must be a non-empty array")
        return report.issues
    ids: list[str] = []
    roots: list[str] = []
    aliases: dict[str, str] = {}
    project_required = {
        "id", "name", "aliases", "root", "portfolio_key", "current_status",
        "coordination_root", "qa_manifest", "qa_index", "lanes",
        "supported_profiles", "evidence_roots",
    }
    for project in projects:
        if not isinstance(project, dict):
            report.fail("CONFIG_PROJECT_TYPE", "each project must be an object")
            continue
        absent = sorted(project_required - set(project))
        project_id = str(project.get("id", "<missing>"))
        if absent:
            report.fail("CONFIG_PROJECT_REQUIRED", f"{project_id} missing: {', '.join(absent)}")
        ids.append(project_id)
        roots.append(str(project.get("root", "")).casefold())
        for alias in [project_id, project.get("name", ""), *project.get("aliases", [])]:
            normalized = str(alias).strip().casefold()
            if normalized in aliases and aliases[normalized] != project_id:
                report.fail("CONFIG_ALIAS_DUPLICATE", f"alias {alias!r} maps to multiple projects")
            aliases[normalized] = project_id
    if len(ids) != len(set(ids)):
        report.fail("CONFIG_PROJECT_DUPLICATE", "project ids must be unique")
    if len(roots) != len(set(roots)):
        report.fail("CONFIG_ROOT_DUPLICATE", "project roots must be unique")

    all_official = config.get("groups", {}).get("AllOfficial", [])
    if set(all_official) != set(ids):
        report.fail("CONFIG_GROUP_ALL", "groups.AllOfficial must contain every project exactly once")
    if set(config.get("groups", {}).get("Active", [])) & set(config.get("groups", {}).get("Paused", [])):
        report.fail("CONFIG_GROUP_OVERLAP", "Active and Paused must be disjoint")
    for group, members in config.get("groups", {}).items():
        unknown = sorted(set(members) - set(ids))
        if unknown:
            report.fail("CONFIG_GROUP_UNKNOWN", f"{group} references unknown projects: {unknown}")

    allowed_authorities = set(config.get("documentation", {}).get("allowed_authorities", []))
    for entry in config.get("documentation", {}).get("live_documents", []):
        if entry.get("authority") not in allowed_authorities:
            report.fail("CONFIG_AUTHORITY", f"invalid authority for {entry.get('path')}: {entry.get('authority')}")
    for rel in [
        "tools/schemas/estudio_governance.schema.json",
        config.get("qa", {}).get("manifest_schema", ""),
        config.get("engineering_health", {}).get("baseline", ""),
        config.get("fast_suite", {}).get("baseline", ""),
    ]:
        if rel and not (root / rel).is_file():
            report.fail("CONFIG_REFERENCE_MISSING", f"referenced file is missing: {rel}", rel)
        elif rel:
            try:
                read_json(root / rel)
            except (OSError, json.JSONDecodeError) as exc:
                report.fail("CONFIG_REFERENCE_JSON", f"invalid JSON: {exc}", rel)
    return report.issues


def check_config(root: Path, config_path: str) -> CheckReport:
    report = CheckReport("governance")
    try:
        config = read_json(root / config_path)
    except (OSError, json.JSONDecodeError) as exc:
        report.fail("CONFIG_LOAD", str(exc), config_path)
        return report
    report.issues.extend(validate_governance(config, root))
    report.metrics["projects"] = len(config.get("projects", [])) if isinstance(config, dict) else 0
    return report


def check_text(root: Path, config: dict[str, Any]) -> CheckReport:
    report = CheckReport("text_integrity")
    extensions = {item.casefold() for item in config["documentation"]["text_extensions"]}
    scanned = 0
    for rel in tracked_files(root):
        path = root / rel
        if path.suffix.casefold() not in extensions or not path.is_file():
            continue
        scanned += 1
        raw = path.read_bytes()
        if b"\x00" in raw:
            report.fail("TEXT_NULL_BYTE", f"contains {raw.count(bytes([0]))} null byte(s)", rel)
        if raw.startswith(b"\xef\xbb\xbf"):
            report.warn("TEXT_UTF8_BOM", "UTF-8 BOM is discouraged", rel)
        try:
            raw.decode("utf-8", errors="strict")
        except UnicodeDecodeError as exc:
            report.fail("TEXT_INVALID_UTF8", f"invalid UTF-8 at byte {exc.start}", rel)
    report.metrics["files_scanned"] = scanned
    return report


METADATA_RE = re.compile(r"^-\s*([a-z_]+):\s*`?([^`\n]+?)`?\s*$")


def parse_metadata(text: str) -> dict[str, str]:
    lines = text.splitlines()
    try:
        start = next(i for i, line in enumerate(lines) if line.strip() == "## Metadata") + 1
    except StopIteration:
        return {}
    result: dict[str, str] = {}
    for line in lines[start:]:
        if line.startswith("## "):
            break
        match = METADATA_RE.match(line.strip())
        if match:
            result[match.group(1)] = match.group(2).strip()
    return result


def _without_metadata_section(text: str) -> str:
    """Exclude required governance metadata from pointer-state checks."""
    return re.sub(r"(?ms)^## Metadata\s*\n.*?(?=^##\s|\Z)", "", text)


def _is_none(value: str) -> bool:
    return value.strip().casefold() in {"none", "n/a"}


def _portfolio_rows(text: str) -> dict[str, str]:
    rows: dict[str, str] = {}
    for line in text.splitlines():
        if not line.startswith("|") or "`Projetos/" not in line:
            continue
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if len(cells) < 5:
            continue
        path_match = re.search(r"`(Projetos/[^`]+)`", cells[2])
        status_match = re.search(r"`([A-Z0-9_]+)`", cells[3])
        if path_match and status_match:
            rows[path_match.group(1).rstrip("/")] = status_match.group(1)
    return rows


def check_docs(root: Path, config: dict[str, Any]) -> CheckReport:
    report = CheckReport("documentation_contract")
    docs = config["documentation"]
    required_fields = docs["metadata_fields"]
    allowed_authorities = set(docs["allowed_authorities"])
    warn_len = int(docs["warn_line_length"])
    fail_len = int(docs["fail_line_length"])
    for entry in docs["live_documents"]:
        rel = entry["path"]
        path = root / rel
        if not path.is_file():
            report.fail("DOC_LIVE_MISSING", "listed live document is missing", rel)
            continue
        try:
            text = path.read_text(encoding="utf-8", errors="strict")
        except UnicodeDecodeError:
            continue
        metadata = parse_metadata(text)
        if not metadata:
            report.fail("DOC_METADATA_SECTION", "missing exact '## Metadata' section", rel)
        for field in required_fields:
            if field not in metadata or not metadata[field].strip():
                report.fail("DOC_METADATA_FIELD", f"missing metadata field: {field}", rel)
        authority = metadata.get("authority", "")
        if authority and authority not in allowed_authorities:
            report.fail("DOC_AUTHORITY", f"unknown authority: {authority}", rel)
        expected = entry.get("authority")
        if authority and authority != expected:
            report.fail("DOC_AUTHORITY_MISMATCH", f"expected {expected}, got {authority}", rel)
        verified = metadata.get("last_verified", "")
        if verified and not _is_none(verified):
            try:
                dt.date.fromisoformat(verified)
            except ValueError:
                report.fail("DOC_LAST_VERIFIED", "last_verified must be YYYY-MM-DD, none or n/a", rel)
        lines = text.splitlines()
        max_lines = int(entry.get("max_lines", 0))
        if max_lines and len(lines) > max_lines:
            report.fail("DOC_LINE_BUDGET", f"{len(lines)} lines exceeds maximum {max_lines}", rel)
        in_code = False
        for number, line in enumerate(lines, 1):
            if line.lstrip().startswith("```"):
                in_code = not in_code
                continue
            if in_code or line.lstrip().startswith("|"):
                continue
            if len(line) > fail_len:
                report.fail("DOC_PROSE_LINE_HARD", f"line {number} has {len(line)} chars (max {fail_len})", rel)
            elif len(line) > warn_len:
                report.warn("DOC_PROSE_LINE_WARN", f"line {number} has {len(line)} chars (target {warn_len})", rel)

    for rel in docs["pointer_documents"]:
        path = root / rel
        if not path.is_file():
            report.fail("DOC_POINTER_MISSING", "pointer document is missing", rel)
            continue
        text = _without_metadata_section(path.read_text(encoding="utf-8", errors="replace"))
        for pattern in docs["pointer_forbidden_patterns"]:
            if re.search(pattern, text, re.MULTILINE):
                report.fail("DOC_POINTER_STATE", f"matches forbidden operational-state pattern: {pattern}", rel)

    portfolio_path = root / config["authority_documents"]["portfolio"]
    if portfolio_path.is_file():
        rows = _portfolio_rows(portfolio_path.read_text(encoding="utf-8", errors="replace"))
        for project in config["projects"]:
            root_key = project["root"].rstrip("/")
            if root_key not in rows:
                report.fail("PORTFOLIO_PROJECT_MISSING", "official project is missing from portfolio table", root_key)
    report.metrics["live_documents"] = len(docs["live_documents"])
    return report


def _unique_ids(items: Iterable[dict[str, Any]], report: CheckReport, path: str, kind: str) -> set[str]:
    ids: list[str] = [str(item.get("id", "")) for item in items]
    empty = [value for value in ids if not re.fullmatch(r"[a-z][a-z0-9_]+", value)]
    for value in empty:
        report.fail("QA_ID", f"invalid {kind} id: {value!r}", path)
    if len(ids) != len(set(ids)):
        report.fail("QA_ID_DUPLICATE", f"duplicate {kind} id", path)
    return set(ids)


def validate_qa_manifest(data: Any, project: dict[str, Any], config: dict[str, Any], path: str, active: bool) -> CheckReport:
    report = CheckReport("qa_contract")
    if not isinstance(data, dict) or data.get("schema_version") != 1:
        report.fail("QA_SCHEMA", "manifest must be an object with schema_version 1", path)
        return report
    if data.get("project") != project["id"]:
        report.fail("QA_PROJECT", f"project must be {project['id']}", path)
    runners = data.get("runners")
    journeys = data.get("critical_journey")
    if not isinstance(runners, list) or not isinstance(journeys, list):
        report.fail("QA_REQUIRED", "runners and critical_journey must be arrays", path)
        return report
    runner_ids = _unique_ids(runners, report, path, "runner")
    journey_ids = _unique_ids(journeys, report, path, "capability")
    allowed_runners = set(config["qa"]["allowed_runner_types"])
    allowed_categories = set(config["qa"]["allowed_categories"])
    allowed_profiles = {"FastSuite", "Runtime", "Build", "FullLocal"}
    allowed_tiers = {"QA", "Runtime", "Build"}
    allowed_outputs = {"ignored_cache_only", "temporary_only", "read_only"}
    forbidden = [token.casefold() for token in config["qa"]["forbidden_tokens"]]
    for runner in runners:
        missing = sorted({"id", "category", "tier", "lane", "runner", "entrypoint", "args", "profiles", "timeout_seconds", "environments", "output_policy", "local_only"} - set(runner))
        if missing:
            report.fail("QA_RUNNER_REQUIRED", f"{runner.get('id')} missing: {', '.join(missing)}", path)
            continue
        if not isinstance(runner["runner"], str) or runner["runner"] not in allowed_runners:
            report.fail("QA_RUNNER_TYPE", f"unsafe or unknown runner type: {runner['runner']}", path)
        if not isinstance(runner["category"], str) or runner["category"] not in allowed_categories:
            report.fail("QA_CATEGORY", f"unknown category: {runner['category']}", path)
        if not isinstance(runner["tier"], str) or runner["tier"] not in allowed_tiers:
            report.fail("QA_TIER", f"unknown tier: {runner['tier']}", path)
        if not isinstance(runner["lane"], str) or runner["lane"] not in project["lanes"]:
            report.fail("QA_LANE", f"lane {runner['lane']} is not enabled for {project['id']}", path)
        if not isinstance(runner["output_policy"], str) or runner["output_policy"] not in allowed_outputs:
            report.fail("QA_OUTPUT_POLICY", f"unknown output policy: {runner['output_policy']}", path)
        if not runner["local_only"]:
            report.fail("QA_LOCAL_ONLY", "all global-orchestrator runners must set local_only=true", path)
        profiles = runner.get("profiles", [])
        if not isinstance(profiles, list) or not profiles or not all(isinstance(item, str) for item in profiles) or not set(profiles) <= allowed_profiles:
            report.fail("QA_PROFILES", f"invalid profiles for {runner.get('id')}: {profiles}", path)
        if not isinstance(runner.get("entrypoint"), str) or not runner["entrypoint"]:
            report.fail("QA_ENTRYPOINT", f"runner {runner.get('id')} needs a string entrypoint", path)
        if not isinstance(runner.get("args"), list) or not all(isinstance(item, str) for item in runner["args"]):
            report.fail("QA_ARGS", f"runner {runner.get('id')} args must be strings", path)
        if not isinstance(runner.get("environments"), list) or not all(isinstance(item, str) for item in runner["environments"]):
            report.fail("QA_ENVIRONMENTS", f"runner {runner.get('id')} environments must be strings", path)
        timeout = runner.get("timeout_seconds")
        if not isinstance(timeout, int) or timeout < 1 or timeout > 3600:
            report.fail("QA_TIMEOUT", f"invalid timeout for {runner.get('id')}: {timeout}", path)
        resources = runner.get("execution_resources", [])
        if (
            not isinstance(resources, list)
            or ("execution_resources" in runner and not resources)
            or not all(item in {"GodotQA", "AndroidQA"} for item in resources)
        ):
            report.fail("QA_EXECUTION_RESOURCES", f"invalid resources for {runner.get('id')}: {resources}", path)
        user_data_mode = runner.get("user_data_mode", config["qa"].get("user_data_mode_default", "isolated"))
        if user_data_mode not in {"isolated", "shared_locked"}:
            report.fail("QA_USER_DATA_MODE", f"invalid user data mode for {runner.get('id')}: {user_data_mode}", path)
        surface_for_lock = " ".join([str(runner.get("entrypoint", "")), *map(str, runner.get("args", []))]).casefold()
        args_for_lock = [str(item).casefold() for item in runner.get("args", [])]
        profile_for_lock = ""
        if "-profile" in args_for_lock and args_for_lock.index("-profile") + 1 < len(args_for_lock):
            profile_for_lock = args_for_lock[args_for_lock.index("-profile") + 1]
        inferred_lock = (
            runner.get("runner") in {"godot_script", "gut_scripts"}
            or runner.get("lane") == "android"
            or "run_gut_short.ps1" in surface_for_lock
            or ("validate_foundation.ps1" in surface_for_lock and profile_for_lock in {"clientquick", "modeplatform"})
        )
        if user_data_mode == "shared_locked" and not resources and not inferred_lock:
            report.fail("QA_SHARED_DATA_UNLOCKED", f"shared user data needs a typed execution resource for {runner.get('id')}", path)
        result_contract = runner.get("result_contract")
        if result_contract is not None:
            valid_contract = (
                isinstance(result_contract, dict)
                and re.fullmatch(r"[a-z][a-z0-9_]+", str(result_contract.get("contract", "")))
                and isinstance(result_contract.get("schema_version"), int)
                and result_contract.get("schema_version", 0) >= 1
                and isinstance(result_contract.get("required"), bool)
                and result_contract.get("marker", "ESTUDIO_JSON:") == "ESTUDIO_JSON:"
            )
            if not valid_contract:
                report.fail("QA_RESULT_CONTRACT", f"invalid result contract for {runner.get('id')}", path)
        command_surface = " ".join([str(runner.get("entrypoint", "")), *map(str, runner.get("args", []))]).casefold()
        for token in forbidden:
            if token in command_surface:
                report.fail("QA_FORBIDDEN_OPERATION", f"runner {runner.get('id')} contains forbidden token {token}", path)
    allowed_statuses = set(config["qa"]["allowed_journey_statuses"])
    for journey in journeys:
        status = journey.get("status")
        if not isinstance(status, str) or status not in allowed_statuses:
            report.fail("QA_JOURNEY_STATUS", f"invalid status for {journey.get('id')}: {status}", path)
        journey_runners = journey.get("runner_ids", [])
        if not isinstance(journey_runners, list) or not all(isinstance(item, str) for item in journey_runners):
            report.fail("QA_JOURNEY_RUNNER_TYPE", f"{journey.get('id')} runner_ids must be strings", path)
            journey_runners = []
        unknown = set(journey_runners) - runner_ids
        if unknown:
            report.fail("QA_JOURNEY_RUNNER", f"{journey.get('id')} references unknown runners: {sorted(unknown)}", path)
        if status == "covered" and not journey_runners:
            report.fail("QA_JOURNEY_COVERAGE", f"covered capability {journey.get('id')} has no runner", path)
        if active and status == "gap":
            exception = journey.get("exception")
            if not isinstance(exception, dict) or not exception.get("reason") or not exception.get("review_when"):
                report.fail("QA_ACTIVE_GAP", f"active-project gap {journey.get('id')} requires reason and review_when", path)
    report.metrics.update({"runners": len(runner_ids), "capabilities": len(journey_ids)})
    return report


def check_qa(root: Path, config: dict[str, Any], selected: set[str] | None = None) -> CheckReport:
    report = CheckReport("qa_contract")
    active = set(config["groups"]["Active"])
    checked = 0
    for project in config["projects"]:
        if selected is not None and project["id"] not in selected:
            continue
        manifest_rel = project["qa_manifest"]
        index_rel = project["qa_index"]
        manifest_path = root / manifest_rel
        index_path = root / index_rel
        if not manifest_path.is_file():
            report.fail("QA_MANIFEST_MISSING", "QA manifest is missing", manifest_rel)
            continue
        if not index_path.is_file():
            report.fail("QA_INDEX_MISSING", "QA index is missing", index_rel)
            continue
        try:
            data = read_json(manifest_path)
        except (OSError, json.JSONDecodeError) as exc:
            report.fail("QA_MANIFEST_JSON", str(exc), manifest_rel)
            continue
        child = validate_qa_manifest(data, project, config, manifest_rel, project["id"] in active)
        report.issues.extend(child.issues)
        text = index_path.read_text(encoding="utf-8", errors="replace")
        documented_runners = set(re.findall(r"^-\s*runner_id:\s*`([^`]+)`", text, re.MULTILINE))
        documented_capabilities = set(re.findall(r"^-\s*capability_id:\s*`([^`]+)`", text, re.MULTILINE))
        runner_ids = {str(item.get("id")) for item in data.get("runners", [])}
        capability_ids = {str(item.get("id")) for item in data.get("critical_journey", [])}
        if documented_runners != runner_ids:
            report.fail("QA_INDEX_RUNNERS", f"runner ids differ; manifest_only={sorted(runner_ids - documented_runners)}, index_only={sorted(documented_runners - runner_ids)}", index_rel)
        if documented_capabilities != capability_ids:
            report.fail("QA_INDEX_CAPABILITIES", f"capability ids differ; manifest_only={sorted(capability_ids - documented_capabilities)}, index_only={sorted(documented_capabilities - capability_ids)}", index_rel)
        checked += 1
    report.metrics["projects_checked"] = checked
    return report


def resolve_projects(config: dict[str, Any], selector: str) -> list[dict[str, Any]]:
    if selector in config["groups"]:
        wanted = set(config["groups"][selector])
        return [project for project in config["projects"] if project["id"] in wanted]
    normalized = selector.strip().casefold()
    matches = []
    for project in config["projects"]:
        names = [project["id"], project["name"], *project["aliases"]]
        if normalized in {str(item).casefold() for item in names}:
            matches.append(project)
    if len(matches) != 1:
        raise ValueError(f"unknown or ambiguous project selector: {selector}")
    return matches


def emit(report: CheckReport, audit_only: bool, report_path: str | None = None) -> int:
    payload = report.as_dict(audit_only=audit_only)
    print(f"[{report.name}] {payload['status'].upper()} issues={len(report.issues)}")
    for issue in report.issues:
        location = f" {issue.path}" if issue.path else ""
        print(f" - {issue.severity.upper()} {issue.code}{location}: {issue.message}")
    if report_path:
        target = Path(report_path)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return 0 if audit_only or not report.failed else 1


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=["config", "text", "docs", "qa", "all"])
    parser.add_argument("--root", default=str(repo_root_from()))
    parser.add_argument("--config", default="tools/estudio_governance.json")
    parser.add_argument("--project", default="AllOfficial")
    parser.add_argument("--audit-only", action="store_true")
    parser.add_argument("--report-path")
    args = parser.parse_args(argv)
    root = Path(args.root).resolve()
    if args.command == "config":
        return emit(check_config(root, args.config), args.audit_only, args.report_path)
    try:
        config = load_governance(root, args.config)
        selected = {project["id"] for project in resolve_projects(config, args.project)}
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        report = CheckReport(args.command)
        report.fail("CONFIG_LOAD", str(exc), args.config)
        return emit(report, args.audit_only, args.report_path)
    checks: list[CheckReport] = []
    if args.command in {"text", "all"}:
        checks.append(check_text(root, config))
    if args.command in {"docs", "all"}:
        checks.append(check_docs(root, config))
    if args.command in {"qa", "all"}:
        checks.append(check_qa(root, config, selected))
    combined = CheckReport(args.command)
    for check in checks:
        combined.issues.extend(check.issues)
        combined.metrics[check.name] = check.metrics
    return emit(combined, args.audit_only, args.report_path)


if __name__ == "__main__":
    raise SystemExit(main())
