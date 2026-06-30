#!/usr/bin/env python
"""Warning-only docs health check for living coordination documentation.

Exit code is always 0. This script reports drift risks without blocking routine docs validation.
"""
from __future__ import annotations

import argparse
import datetime as dt
import re
from pathlib import Path


def warn(warnings: list[str], message: str) -> None:
    warnings.append(message)


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""


def scan_stale_next_review_dates(root: Path, warnings: list[str]) -> None:
    today = dt.date.today()
    for path in root.rglob("*.md"):
        rel = path.relative_to(root).as_posix()
        # Skip large historical archives where dates are evidence, not live review metadata.
        if any(part in rel for part in ["/Handoffs/", "/Decisoes/", "/Kanban/Done/", "documentation-index.archive.md"]):
            continue
        text = read(path)
        for line_no, line in enumerate(text.splitlines(), 1):
            if "next_review_date" not in line:
                continue
            for value in re.findall(r"next_review_date\s*[:|]\s*`?([0-9]{4}-[0-9]{2}-[0-9]{2}|a definir pelo usuario|a definir pelo Fabio)", line):
                if value.startswith("20"):
                    date_value = dt.date.fromisoformat(value)
                    if date_value < today:
                        warn(warnings, f"stale next_review_date: {rel}:{line_no} -> {value}")


def scan_minigame_review_triage(root: Path, warnings: list[str]) -> None:
    coord_dirs = list(root.glob("03_Jogos/Producao/*/08_Coordenacao")) + list(root.glob("06_Operacoes/*/08_Coordenacao"))
    for coord in coord_dirs:
        review_dir = coord / "Kanban/Review"
        if not review_dir.exists():
            continue
        cards = sorted(p.name for p in review_dir.glob("*.md"))
        if not cards:
            continue
        triage = coord / "TRIAGE.md"
        triage_text = read(triage)
        if not triage.exists():
            warn(warnings, f"Review has {len(cards)} card(s) but missing TRIAGE.md: {coord.relative_to(root).as_posix()}")
            continue
        for card in cards:
            if card not in triage_text:
                warn(warnings, f"Review card not listed in local TRIAGE.md: {(review_dir / card).relative_to(root).as_posix()}")


def scan_dashboard_contract(root: Path, warnings: list[str]) -> None:
    md = root / "08_Coordenacao_Agentes/FABIO_DASHBOARD.md"
    html = root / "08_Coordenacao_Agentes/FABIO_DASHBOARD.html"
    if not md.exists() or not html.exists():
        warn(warnings, "FABIO_DASHBOARD.md/html pair is incomplete")
        return
    md_text = read(md).lower()
    html_text = read(html).lower()
    if "nao e fonte tecnica de verdade" not in md_text and "não é fonte técnica de verdade" not in md_text:
        warn(warnings, "FABIO_DASHBOARD.md does not clearly state it is not a technical source of truth")
    if "fabio_dashboard.md" not in html_text:
        warn(warnings, "FABIO_DASHBOARD.html does not link back to FABIO_DASHBOARD.md")
    if "generated from" not in html_text and "gerado" not in html_text:
        warn(warnings, "FABIO_DASHBOARD.html is not marked as generated; Markdown/HTML drift risk remains")


def scan_live_agent_refs(root: Path, workspace: str, warnings: list[str]) -> None:
    live_files = [root / "AGENTS.md", root / "CODEX.md", root / "08_Coordenacao_Agentes/Estado_Atual.md"]
    if workspace == "estudio":
        live_files += list((root / "08_Coordenacao_Agentes/Templates").glob("*.md"))
    for path in live_files:
        if not path.exists():
            continue
        for line_no, line in enumerate(read(path).splitlines(), 1):
            if re.search(r"owner:\s*`?Claude|to:\s*`?[^`\n]*Claude|from:\s*`?[^`\n]*Claude|decisor:\s*`?[^`\n]*Claude|agente:\s*`?[^`\n]*Claude", line):
                warn(warnings, f"live/template doc still offers Claude as current actor: {path.relative_to(root).as_posix()}:{line_no}")
            if "OpenClaw" in line and "historico/deprecated" not in line:
                warn(warnings, f"live doc mentions OpenClaw outside deprecated wording: {path.relative_to(root).as_posix()}:{line_no}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--workspace", choices=["minigame", "estudio", "auto"], default="auto")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    workspace = args.workspace
    if workspace == "auto":
        workspace = "minigame" if (root / "08_Coordenacao_Agentes/Prioridades_MinigameStudio.md").exists() else "estudio"

    warnings: list[str] = []
    scan_stale_next_review_dates(root, warnings)
    scan_dashboard_contract(root, warnings)
    scan_live_agent_refs(root, workspace, warnings)
    if workspace == "minigame":
        scan_minigame_review_triage(root, warnings)

    if warnings:
        print(f"DOCS_HEALTH_WARN warnings={len(warnings)}")
        for item in warnings:
            print(f" - {item}")
    else:
        print("DOCS_HEALTH_OK warnings=0")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
