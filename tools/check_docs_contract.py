#!/usr/bin/env python3
"""Run the authoritative documentation, closure and Portfolio Sync contracts."""
from __future__ import annotations

import argparse
from pathlib import Path

from check_agent_closure_protocol import check_closure
from check_portfolio_sync_queue import check_queue
from estudio_governance import CheckReport, check_docs, emit, load_governance, resolve_projects


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=str(Path(__file__).resolve().parent.parent))
    parser.add_argument("--config", default="tools/estudio_governance.json")
    parser.add_argument("--project", default="AllOfficial")
    parser.add_argument("--audit-only", action="store_true")
    parser.add_argument("--report-path")
    args = parser.parse_args(argv)
    root = Path(args.root).resolve()
    combined = CheckReport("documentation_contract_v21")
    try:
        config = load_governance(root, args.config)
        selected = {item["id"] for item in resolve_projects(config, args.project)}
        checks = [
            check_docs(root, config),
            check_closure(root, config, selected),
            check_queue(root, config),
        ]
        for check in checks:
            combined.issues.extend(check.issues)
            combined.metrics[check.name] = check.metrics
    except Exception as exc:
        combined.fail("DOCS_CONTRACT_ERROR", str(exc))
    return emit(combined, args.audit_only, args.report_path)


if __name__ == "__main__":
    raise SystemExit(main())
