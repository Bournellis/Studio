#!/usr/bin/env python3
"""Local-only Estudio validation orchestrator.

Runner commands are constructed from typed manifest fields.  The manifest can
never provide a shell command, and every execution is protected by an exact Git
snapshot comparison.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import signal
import statistics
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Any

from estudio_governance import (
    CheckReport,
    check_config,
    check_docs,
    check_qa,
    check_text,
    load_governance,
    read_json,
    resolve_projects,
)
from estudio_repository_checks import (
    check_evidence,
    check_health,
    check_storage,
    check_uids,
    check_worktrees,
    git_snapshot,
)


PROFILES = {"DocsOnly", "FastSuite", "Runtime", "Build", "FullLocal"}
LANES = {"Auto", "Godot", "Web", "Backend", "Android", "Lab"}


def _result(name: str, status: str, duration: float, **extra: Any) -> dict[str, Any]:
    return {"name": name, "status": status, "duration_seconds": round(duration, 3), **extra}


def _run_process(command: list[str], cwd: Path, timeout: int) -> tuple[int, float, str, str]:
    started = time.monotonic()
    creationflags = subprocess.CREATE_NEW_PROCESS_GROUP if os.name == "nt" else 0
    process = subprocess.Popen(
        command,
        cwd=cwd,
        text=True,
        encoding="utf-8",
        errors="replace",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        creationflags=creationflags,
        start_new_session=os.name != "nt",
    )
    try:
        stdout, stderr = process.communicate(timeout=timeout)
        return process.returncode, time.monotonic() - started, stdout, stderr
    except subprocess.TimeoutExpired as exc:
        _terminate_process_tree(process)
        stdout, stderr = process.communicate()
        if not stdout and isinstance(exc.stdout, str):
            stdout = exc.stdout
        if not stderr and isinstance(exc.stderr, str):
            stderr = exc.stderr
        return 124, time.monotonic() - started, stdout, stderr + f"\ntimeout after {timeout}s"


def _terminate_process_tree(process: subprocess.Popen[str]) -> None:
    """Terminate the exact timed-out runner tree, including Windows wrappers."""
    if os.name == "nt":
        subprocess.run(
            ["taskkill", "/PID", str(process.pid), "/T", "/F"],
            text=True,
            capture_output=True,
            check=False,
        )
        if process.poll() is None:
            process.kill()
        return
    try:
        os.killpg(process.pid, signal.SIGKILL)
    except ProcessLookupError:
        pass


def _godot_executable(root: Path, config: dict[str, Any], explicit: str | None) -> str | None:
    candidates = [explicit] if explicit else []
    candidates += [str(root / item) if not Path(item).is_absolute() else item for item in config["toolchain"]["godot_candidates"]]
    candidates += [os.environ.get("GODOT4_CONSOLE"), os.environ.get("GODOT4"), shutil.which("godot4"), shutil.which("godot")]
    for candidate in candidates:
        if candidate and Path(candidate).is_file():
            return str(Path(candidate).resolve())
    return None


def _safe_project_path(project_root: Path, value: str) -> Path:
    if not value or Path(value).is_absolute() or ".." in Path(value).parts or value.startswith("res://"):
        raise ValueError(f"unsafe local entrypoint: {value!r}")
    path = (project_root / value).resolve()
    path.relative_to(project_root.resolve())
    if not path.is_file():
        raise ValueError(f"entrypoint does not exist: {value}")
    return path


def _runner_command(
    root: Path, project: dict[str, Any], runner: dict[str, Any], config: dict[str, Any], godot_exe: str | None
) -> list[str]:
    project_root = root / project["root"]
    runner_type = runner["runner"]
    entrypoint = str(runner["entrypoint"])
    args = [str(item) for item in runner.get("args", [])]
    surface = " ".join([entrypoint, *args]).casefold()
    for token in config["qa"]["forbidden_tokens"]:
        if token.casefold() in surface:
            raise ValueError(f"forbidden remote/publication token: {token}")
    if not runner.get("local_only", False):
        raise ValueError("runner must declare local_only=true")
    environments = {str(item).casefold() for item in runner.get("environments", [])}
    if any("remote" in item or "physical" in item or "publish" in item for item in environments):
        raise ValueError(f"non-local environment is forbidden: {sorted(environments)}")
    if runner_type == "godot_script":
        if not godot_exe:
            raise FileNotFoundError("Godot executable was not found")
        if not entrypoint.startswith("res://") or ".." in entrypoint:
            raise ValueError("godot_script entrypoint must be a safe res:// path")
        command = [godot_exe, "--headless", "--path", str(project_root), "-s", entrypoint]
        if args:
            command += ["--", *args]
        return command
    if runner_type == "gut_scripts":
        if not godot_exe:
            raise FileNotFoundError("Godot executable was not found")
        gut = entrypoint or "res://addons/gut/gut_cmdln.gd"
        if not gut.startswith("res://") or ".." in gut:
            raise ValueError("gut_scripts entrypoint must be a safe res:// path")
        test_paths = [str(item) for item in runner.get("paths", [])]
        gut_args = ["-gexit"]
        if test_paths or any(item.startswith("-gtest") for item in args):
            # Without this override GUT combines explicit tests with .gutconfig
            # directories and silently executes the entire suite.
            gut_args.append("-gconfig=")
        for test_path in test_paths:
            if not str(test_path).startswith("res://") or ".." in str(test_path):
                raise ValueError(f"unsafe GUT path: {test_path}")
            gut_args.append(f"-gtest={test_path}")
        return [godot_exe, "--headless", "--path", str(project_root), "-s", gut, "--", *gut_args, *args]
    path = _safe_project_path(project_root, entrypoint)
    if runner_type == "powershell":
        return ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(path), *args]
    if runner_type == "python":
        return [sys.executable, str(path), *args]
    if runner_type == "deno":
        deno = shutil.which("deno")
        if not deno:
            raise FileNotFoundError("deno was not found")
        return [deno, "run", str(path), *args]
    if runner_type == "node":
        node = shutil.which("node")
        if not node:
            raise FileNotFoundError("node was not found")
        return [node, str(path), *args]
    raise ValueError(f"unsupported runner type: {runner_type}")


def _contract_hash(manifest: dict[str, Any]) -> str:
    runners = [runner for runner in manifest.get("runners", []) if runner.get("category") == "fast"]
    payload = json.dumps(runners, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def _baseline_issue(
    baseline: dict[str, Any], project: dict[str, Any], manifest: dict[str, Any], runner: dict[str, Any],
    duration: float, godot_version: str | None,
) -> tuple[str | None, str | None]:
    entry = baseline.get("projects", {}).get(project["id"], {})
    if entry.get("status") != "measured":
        return "FAST_BASELINE_UNMEASURED", f"FastSuite baseline for {project['id']} is not measured"
    contract = _contract_hash(manifest)
    if entry.get("contract_hash") != contract:
        return "FAST_BASELINE_STALE", f"FastSuite contract changed for {project['id']}"
    if godot_version and entry.get("godot_version") != godot_version:
        return "FAST_BASELINE_STALE", f"Godot version changed for {project['id']}"
    measured = entry.get("runners", {}).get(runner["id"], {})
    median = measured.get("median_seconds")
    budget = measured.get("budget_seconds")
    if median is None:
        return "FAST_BASELINE_UNMEASURED", f"runner {runner['id']} has no measured median"
    ratio = duration / float(median) if float(median) else float("inf")
    if (budget is not None and duration > float(budget)) or ratio >= 1.4:
        return "FAST_BUDGET_FAIL", f"{runner['id']} took {duration:.2f}s (baseline {median:.2f}s, ratio {ratio:.2f})"
    if ratio >= 1.2:
        return "FAST_BUDGET_WARN", f"{runner['id']} took {duration:.2f}s (baseline {median:.2f}s, ratio {ratio:.2f})"
    return None, None


def _run_checked(
    root: Path, project: dict[str, Any], runner: dict[str, Any], command: list[str], audit_only: bool
) -> dict[str, Any]:
    before = git_snapshot(root)
    code, duration, stdout, stderr = _run_process(command, root / project["root"], int(runner["timeout_seconds"]))
    after = git_snapshot(root)
    side_effects = [key for key in ["head", "status_sha256", "index_diff_sha256", "worktree_diff_sha256", "untracked"] if before.get(key) != after.get(key)]
    status = "pass"
    reason = ""
    if code != 0:
        status = "audit_fail" if audit_only else "fail"
        reason = f"runner exited with code {code}"
    if code == 0 and runner["runner"] == "gut_scripts" and not _gut_output_has_tests(stdout + "\n" + stderr):
        status = "audit_fail" if audit_only else "fail"
        reason = "GUT_NO_TESTS: runner exited zero without a non-empty Run Summary"
    if side_effects:
        status = "audit_fail" if audit_only else "fail"
        reason = f"VALIDATOR_SIDE_EFFECT changed {', '.join(side_effects)}"
    if stdout:
        print(stdout, end="" if stdout.endswith("\n") else "\n")
    if stderr:
        print(stderr, file=sys.stderr, end="" if stderr.endswith("\n") else "\n")
    return _result(
        f"{project['id']}:{runner['id']}", status, duration, reason=reason,
        exit_code=code, side_effects=side_effects, runner_type=runner["runner"], lane=runner["lane"],
    )


def _gut_output_has_tests(output: str) -> bool:
    return "Run Summary" in output and re.search(r"(?m)^\s*Tests\s+([1-9][0-9]*)\s*$", output) is not None


def _existing_script_step(root: Path, name: str, args: list[str], audit_only: bool) -> dict[str, Any]:
    path = root / args[0]
    if not path.is_file():
        return _result(name, "audit_fail" if audit_only else "fail", 0, reason=f"missing {args[0]}")
    command = [sys.executable, str(path), *args[1:]]
    code, duration, stdout, stderr = _run_process(command, root, 120)
    if stdout:
        print(stdout, end="" if stdout.endswith("\n") else "\n")
    if stderr:
        print(stderr, file=sys.stderr, end="" if stderr.endswith("\n") else "\n")
    status = "pass" if code == 0 else "audit_fail" if audit_only else "fail"
    if code == 0 and re.search(r"(?:^|_)WARN(?:\s|$)", stdout, re.MULTILINE):
        status = "warn"
    return _result(name, status, duration, exit_code=code, reason="" if code == 0 else f"exit {code}")


def run_validation(args: argparse.Namespace) -> dict[str, Any]:
    root = Path(args.root).resolve()
    config = load_governance(root, args.config)
    selector = args.project or ("AllOfficial" if args.profile == "DocsOnly" else "Active")
    projects = resolve_projects(config, selector)
    selected = {project["id"] for project in projects}
    report: dict[str, Any] = {
        "schema": "estudio_validation_report_v1",
        "source_sha": subprocess.run(["git", "rev-parse", "HEAD"], cwd=root, text=True, capture_output=True, check=True).stdout.strip(),
        "profile": args.profile,
        "project_selector": selector,
        "projects": sorted(selected),
        "lane": args.lane,
        "audit_only": args.audit_only,
        "toolchain": {
            "python": sys.version.split()[0],
            "godot_expected": config["toolchain"]["godot_expected"],
            "godot_executable": None,
            "godot_actual": None,
        },
        "steps": [],
    }
    started = time.monotonic()
    check_reports = [
        check_config(root, args.config),
        check_text(root, config),
        check_docs(root, config),
        check_qa(root, config, selected),
        check_uids(root, config, selected),
        check_health(root, config, selected),
        check_storage(root, config, args.base_ref),
        check_evidence(root, config, selected, args.base_ref),
        check_worktrees(root, config, args.base_ref),
    ]
    for item in check_reports:
        payload = item.as_dict(audit_only=args.audit_only)
        report["steps"].append(_result(item.name, payload["status"], 0, issues=payload["issues"], metrics=payload["metrics"]))
    report["steps"].append(_existing_script_step(root, "dashboard_generated", ["tools/generate_fabio_dashboard.py", "--root", str(root), "--check"], args.audit_only))
    report["steps"].append(_existing_script_step(root, "local_doc_links", ["tools/check_local_doc_links.py", "--root", str(root), "--workspace", "estudio"], args.audit_only))
    report["steps"].append(_existing_script_step(root, "docs_health", ["tools/check_docs_health.py", "--root", str(root), "--workspace", "estudio"], args.audit_only))

    if args.profile != "DocsOnly":
        godot_exe = _godot_executable(root, config, args.godot_exe)
        godot_version = None
        if godot_exe:
            proc = subprocess.run([godot_exe, "--version"], text=True, capture_output=True, check=False)
            godot_version = proc.stdout.strip().splitlines()[0] if proc.stdout.strip() else None
        report["toolchain"]["godot_executable"] = godot_exe
        report["toolchain"]["godot_actual"] = godot_version
        baseline = read_json(root / config["fast_suite"]["baseline"])
        specific_project = selector not in config["groups"]
        for project in projects:
            if args.profile not in project["supported_profiles"]:
                status = "audit_fail" if args.audit_only else "fail" if specific_project else "skip"
                report["steps"].append(_result(f"{project['id']}:{args.profile}", status, 0, reason="PROFILE_NOT_CONFIGURED"))
                continue
            manifest_path = root / project["qa_manifest"]
            if not manifest_path.is_file():
                status = "audit_fail" if args.audit_only else "fail"
                report["steps"].append(_result(f"{project['id']}:manifest", status, 0, reason="QA manifest missing"))
                continue
            manifest = read_json(manifest_path)
            runners = [runner for runner in manifest.get("runners", []) if args.profile in runner.get("profiles", [])]
            if args.lane != "Auto":
                runners = [runner for runner in runners if runner.get("lane", "").casefold() == args.lane.casefold()]
            if not runners:
                status = "audit_fail" if args.audit_only else "fail" if specific_project else "skip"
                report["steps"].append(_result(f"{project['id']}:{args.profile}", status, 0, reason="PROFILE_NOT_CONFIGURED"))
                continue
            for runner in runners:
                try:
                    command = _runner_command(root, project, runner, config, godot_exe)
                except (ValueError, FileNotFoundError) as exc:
                    status = "audit_fail" if args.audit_only else "fail"
                    report["steps"].append(_result(f"{project['id']}:{runner.get('id')}", status, 0, reason=str(exc)))
                    continue
                result = _run_checked(root, project, runner, command, args.audit_only)
                if runner.get("category") == "fast" and result["status"] == "pass":
                    code, message = _baseline_issue(baseline, project, manifest, runner, float(result["duration_seconds"]), godot_version)
                    if code:
                        result["budget_code"] = code
                        result["reason"] = message
                        if code.endswith("WARN"):
                            result["status"] = "warn"
                        else:
                            result["status"] = "audit_fail" if args.audit_only else "fail"
                report["steps"].append(result)

    failures = [step for step in report["steps"] if step["status"] in {"fail", "audit_fail"}]
    warnings = [step for step in report["steps"] if step["status"] == "warn"]
    report["duration_seconds"] = round(time.monotonic() - started, 3)
    report["summary"] = {
        "status": "audit_fail" if args.audit_only and failures else "fail" if failures else "warn" if warnings else "pass",
        "passed": sum(step["status"] == "pass" for step in report["steps"]),
        "warnings": len(warnings),
        "failed": len(failures),
        "skipped": sum(step["status"] == "skip" for step in report["steps"]),
    }
    return report


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=str(Path(__file__).resolve().parent.parent))
    parser.add_argument("--config", default="tools/estudio_governance.json")
    parser.add_argument("--profile", choices=sorted(PROFILES), default="DocsOnly")
    parser.add_argument("--project")
    parser.add_argument("--lane", choices=sorted(LANES), default="Auto")
    parser.add_argument("--godot-exe")
    parser.add_argument("--base-ref", default="main")
    parser.add_argument("--report-path")
    parser.add_argument("--audit-only", action="store_true")
    args = parser.parse_args(argv)
    try:
        report = run_validation(args)
    except Exception as exc:  # keep CLI failures machine-readable
        report = {
            "schema": "estudio_validation_report_v1", "profile": args.profile,
            "audit_only": args.audit_only, "steps": [],
            "summary": {"status": "audit_fail" if args.audit_only else "fail", "failed": 1},
            "fatal_error": str(exc),
        }
    print(json.dumps(report, indent=2, ensure_ascii=False))
    if args.report_path:
        target = Path(args.report_path)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return 0 if args.audit_only or report["summary"]["status"] not in {"fail", "audit_fail"} else 1


if __name__ == "__main__":
    raise SystemExit(main())
