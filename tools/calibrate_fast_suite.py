#!/usr/bin/env python3
"""Explicit FastSuite calibration; never called by validation or close helpers."""
from __future__ import annotations

import argparse
import datetime as dt
import json
import statistics
import subprocess
from pathlib import Path

from estudio_governance import load_governance, read_json, resolve_projects
from run_validation import (
    _contract_hash,
    _godot_executable,
    _godot_import_ready,
    _needs_godot_import,
    _runner_command,
    _run_checked,
    _warm_godot_import,
)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=str(Path(__file__).resolve().parent.parent))
    parser.add_argument("--config", default="tools/estudio_governance.json")
    parser.add_argument("--project", required=True)
    parser.add_argument("--godot-exe")
    parser.add_argument("--write-baseline", action="store_true", help="Required to mutate the tracked baseline file.")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    config = load_governance(root, args.config)
    projects = resolve_projects(config, args.project)
    if len(projects) != 1:
        raise SystemExit("Calibration requires one explicit project, not a group.")
    project = projects[0]
    manifest = read_json(root / project["qa_manifest"])
    runners = [item for item in manifest.get("runners", []) if item.get("category") == "fast"]
    if not runners:
        raise SystemExit(f"No fast runners configured for {project['id']}.")
    godot_exe = _godot_executable(root, config, args.godot_exe)
    godot_version = None
    if godot_exe:
        proc = subprocess.run([godot_exe, "--version"], text=True, capture_output=True, check=False)
        godot_version = proc.stdout.strip().splitlines()[0] if proc.stdout.strip() else None
    commands = {runner["id"]: _runner_command(root, project, runner, config, godot_exe) for runner in runners}
    if _needs_godot_import(runners) and not _godot_import_ready(root, project):
        if not godot_exe:
            raise SystemExit("Godot executable is required for import warm-up.")
        import_result = _warm_godot_import(root, project, godot_exe, False)
        if import_result["status"] != "pass":
            raise SystemExit(f"Godot import warm-up failed: {import_result['reason']}")
    warmups = int(config["fast_suite"]["warmup_runs"])
    runs = int(config["fast_suite"]["runs"])
    measured: dict[str, dict[str, float]] = {}
    for runner in runners:
        for _ in range(warmups):
            result = _run_checked(root, project, runner, commands[runner["id"]], False)
            if result["status"] != "pass":
                raise SystemExit(f"Warm-up failed for {runner['id']}: {result['reason']}")
        durations: list[float] = []
        for _ in range(runs):
            result = _run_checked(root, project, runner, commands[runner["id"]], False)
            if result["status"] != "pass":
                raise SystemExit(f"Calibration failed for {runner['id']}: {result['reason']}")
            durations.append(float(result["duration_seconds"]))
        median = statistics.median(durations)
        measured[runner["id"]] = {
            "median_seconds": round(median, 3),
            "budget_seconds": int(runner["timeout_seconds"]),
            "samples_seconds": durations,
        }
    payload = {
        "project": project["id"],
        "godot_version": godot_version,
        "contract_hash": _contract_hash(manifest),
        "source_sha": subprocess.run(["git", "rev-parse", "HEAD"], cwd=root, text=True, capture_output=True, check=True).stdout.strip(),
        "runners": measured,
    }
    print(json.dumps(payload, indent=2))
    if not args.write_baseline:
        print("DRY RUN: pass --write-baseline to accept this explicit calibration.")
        return 0
    baseline_path = root / config["fast_suite"]["baseline"]
    baseline = read_json(baseline_path)
    baseline["generated_at"] = dt.datetime.now(dt.timezone.utc).isoformat()
    baseline["projects"][project["id"]] = {"status": "measured", **payload}
    baseline["projects"][project["id"]].pop("project", None)
    baseline_path.write_text(json.dumps(baseline, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Updated {baseline_path.relative_to(root)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
