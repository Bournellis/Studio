#!/usr/bin/env python3
"""Validate the local-first Portfolio Sync queue without redefining state."""
from __future__ import annotations

import argparse
import datetime as dt
import re
from pathlib import Path

from estudio_governance import CheckReport, emit, load_governance, parse_metadata

QUEUE_PATH = "08_Coordenacao_Agentes/PortfolioSync_QUEUE.md"


def _section(text: str, name: str) -> str:
    match = re.search(rf"(?ms)^##\s+{re.escape(name)}\s*$\n(.*?)(?=^##\s|\Z)", text)
    return match.group(1) if match else ""


def _clean_cell(value: str) -> str:
    value = value.strip()
    return value[1:-1].strip() if len(value) >= 2 and value.startswith("`") and value.endswith("`") else value


def parse_tables(section: str) -> list[dict[str, str]]:
    lines = [line.strip() for line in section.splitlines() if line.strip().startswith("|")]
    if len(lines) < 2:
        return []
    headers = [_clean_cell(cell) for cell in lines[0].strip("|").split("|")]
    if not all(re.fullmatch(r":?-+:?", cell.strip()) for cell in lines[1].strip("|").split("|")):
        return []
    rows: list[dict[str, str]] = []
    for line in lines[2:]:
        cells = [_clean_cell(cell) for cell in line.strip("|").split("|")]
        if len(cells) == len(headers):
            rows.append(dict(zip(headers, cells)))
    return rows


def _valid_projects(config: dict) -> set[str]:
    values = {"AllOfficial", "Active", "Paused", "estudio"}
    for project in config["projects"]:
        values.update([project["id"], project["name"], *project.get("aliases", [])])
    return {value.casefold() for value in values}


def _live_local_sync_cards(root: Path, config: dict) -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    for project in config["projects"]:
        kanban = root / project["coordination_root"] / "Kanban"
        for lane in ("Doing", "Review"):
            for path in sorted((kanban / lane).glob("*.md")) if (kanban / lane).is_dir() else ():
                if path.name.casefold() == "readme.md":
                    continue
                metadata = parse_metadata(path.read_text(encoding="utf-8", errors="strict"))
                if metadata.get("global_sync_needed", "").casefold() == "yes":
                    result.append((metadata.get("id", path.stem), path.relative_to(root).as_posix()))
    return result


def check_queue(root: Path, config: dict, *, now: dt.datetime | None = None, max_pending_hours: int = 48) -> CheckReport:
    report = CheckReport("portfolio_sync_queue")
    path = root / QUEUE_PATH
    if not path.is_file():
        report.fail("PORTFOLIO_QUEUE_MISSING", "Portfolio Sync queue is missing", QUEUE_PATH)
        return report
    text = path.read_text(encoding="utf-8", errors="strict")
    metadata = parse_metadata(text)
    if metadata.get("authority") != "portfolio_snapshot":
        report.fail("PORTFOLIO_QUEUE_AUTHORITY", "queue authority must be portfolio_snapshot", QUEUE_PATH)

    pending_section = _section(text, "Pending")
    reflected_section = _section(text, "Reflected")
    if not pending_section:
        report.fail("PORTFOLIO_QUEUE_PENDING_SECTION", "missing Pending section", QUEUE_PATH)
    if not reflected_section:
        report.fail("PORTFOLIO_QUEUE_REFLECTED_SECTION", "missing Reflected section", QUEUE_PATH)
    pending = parse_tables(pending_section)
    reflected = parse_tables(reflected_section)
    if not pending and pending_section and not re.search(r"(?i)nenhuma\s+entrada\s+pendente|no\s+pending\s+entries", pending_section):
        report.fail("PORTFOLIO_QUEUE_PENDING_FORMAT", "Pending must contain a queue table or an explicit empty marker", QUEUE_PATH)

    valid_projects = _valid_projects(config)
    seen: dict[str, str] = {}
    allowed_terminal = {"reflected", "deferred", "superseded"}
    required_common = {"id", "project", "source", "fields", "state"}
    current = now or dt.datetime.now(dt.timezone.utc)
    for lane, rows in (("Pending", pending), ("Reflected", reflected)):
        for index, row in enumerate(rows, 1):
            missing = sorted(required_common - set(row))
            if missing:
                report.fail("PORTFOLIO_QUEUE_FIELDS", f"{lane} row {index} missing columns: {', '.join(missing)}", QUEUE_PATH)
                continue
            item_id = row.get("id", "").strip()
            if not item_id:
                report.fail("PORTFOLIO_QUEUE_ID", f"{lane} row {index} has an empty id", QUEUE_PATH)
            elif item_id in seen:
                report.fail("PORTFOLIO_QUEUE_DUPLICATE", f"duplicate id {item_id} in {seen[item_id]} and {lane}", QUEUE_PATH)
            else:
                seen[item_id] = lane
            if row.get("project", "").casefold() not in valid_projects:
                report.fail("PORTFOLIO_QUEUE_PROJECT", f"unknown project selector: {row.get('project', '')}", QUEUE_PATH)
            state = row.get("state", "").casefold()
            if lane == "Pending" and state != "pending":
                report.fail("PORTFOLIO_QUEUE_STATE", f"Pending row {item_id} must have state=pending", QUEUE_PATH)
            if lane == "Reflected" and state not in allowed_terminal:
                report.fail("PORTFOLIO_QUEUE_STATE", f"Reflected row {item_id} has invalid terminal state={state}", QUEUE_PATH)

            date_field = "requested_at" if lane == "Pending" else "reflected_at"
            value = row.get(date_field, "")
            if not value:
                report.fail("PORTFOLIO_QUEUE_DATE", f"{lane} row {item_id} is missing {date_field}", QUEUE_PATH)
            else:
                try:
                    parsed = dt.datetime.combine(dt.date.fromisoformat(value), dt.time(), tzinfo=dt.timezone.utc)
                    if lane == "Pending" and (current - parsed).total_seconds() > max_pending_hours * 3600:
                        report.warn("PORTFOLIO_QUEUE_STALE", f"pending entry {item_id} exceeds {max_pending_hours} hours", QUEUE_PATH)
                except ValueError:
                    report.fail("PORTFOLIO_QUEUE_DATE", f"invalid {date_field} for {item_id}: {value}", QUEUE_PATH)

    queue_keys = set(seen)
    queue_sources = {row.get("source", "") for row in [*pending, *reflected]}
    for card_id, rel in _live_local_sync_cards(root, config):
        if card_id not in queue_keys and card_id not in queue_sources:
            report.fail("PORTFOLIO_QUEUE_CARD_MISSING", f"live local card requests global sync but is not queued: {card_id}", rel)

    report.metrics.update(pending=len(pending), reflected=len(reflected), local_sync_cards=len(_live_local_sync_cards(root, config)))
    return report


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=str(Path(__file__).resolve().parent.parent))
    parser.add_argument("--config", default="tools/estudio_governance.json")
    parser.add_argument("--max-pending-hours", type=int, default=48)
    parser.add_argument("--audit-only", action="store_true")
    parser.add_argument("--report-path")
    args = parser.parse_args(argv)
    root = Path(args.root).resolve()
    try:
        config = load_governance(root, args.config)
        report = check_queue(root, config, max_pending_hours=args.max_pending_hours)
    except Exception as exc:
        report = CheckReport("portfolio_sync_queue")
        report.fail("PORTFOLIO_QUEUE_ERROR", str(exc))
    return emit(report, args.audit_only, args.report_path)


if __name__ == "__main__":
    raise SystemExit(main())
