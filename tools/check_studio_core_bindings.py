#!/usr/bin/env python3
"""Read-only parity check for local Estudio and Studio Core bindings."""
from __future__ import annotations

import argparse
from pathlib import Path

from estudio_governance import check_studio_core_bindings, emit, load_governance


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=str(Path(__file__).resolve().parent.parent))
    parser.add_argument("--config", default="tools/estudio_governance.json")
    parser.add_argument("--registry", default=r"D:\Studio Core\bindings\PROJECTS.json")
    parser.add_argument("--audit-only", action="store_true")
    parser.add_argument("--report-path")
    args = parser.parse_args(argv)
    root = Path(args.root).resolve()
    try:
        config = load_governance(root, args.config)
        report = check_studio_core_bindings(root, config, Path(args.registry))
    except Exception as exc:
        from estudio_governance import CheckReport

        report = CheckReport("studio_core_bindings")
        report.fail("STUDIO_CORE_CHECK_ERROR", str(exc))
    return emit(report, args.audit_only, args.report_path)


if __name__ == "__main__":
    raise SystemExit(main())
