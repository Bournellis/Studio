#!/usr/bin/env python
"""Check local Markdown/HTML links in living documentation files.

Exit code 0 = pass, 1 = broken local links found.
This intentionally checks files, not anchors, to keep the gate lightweight.
"""
from __future__ import annotations

import argparse
import html.parser
import re
import sys
from pathlib import Path
from urllib.parse import unquote

URL_PREFIXES = ("http:", "https:", "mailto:", "tel:", "data:", "javascript:")

MINIGAME_PATTERNS = [
    "README.md",
    "AGENTS.md",
    "CODEX.md",
    "08_Coordenacao_Agentes/FABIO_DASHBOARD.html",
    "08_Coordenacao_Agentes/FABIO_DASHBOARD.md",
    "08_Coordenacao_Agentes/documentation-index.md",
    "08_Coordenacao_Agentes/Estado_Atual.md",
    "08_Coordenacao_Agentes/Prioridades_MinigameStudio.md",
    "03_Jogos/Producao/*/08_Coordenacao/Estado.md",
    "03_Jogos/Producao/*/08_Coordenacao/TRIAGE.md",
    "06_Operacoes/*/08_Coordenacao/Estado.md",
    "06_Operacoes/*/08_Coordenacao/TRIAGE.md",
]

ESTUDIO_PATTERNS = [
    "README.md",
    "AGENTS.md",
    "Projetos/README.md",
    "08_Coordenacao_Agentes/FABIO_DASHBOARD.html",
    "08_Coordenacao_Agentes/FABIO_DASHBOARD.md",
    "08_Coordenacao_Agentes/documentation-index.md",
    "08_Coordenacao_Agentes/Estado_Atual.md",
    "08_Coordenacao_Agentes/Prioridades_Estudio.md",
    "Projetos/*/implementation/current-status.md",
]

class LinkHTMLParser(html.parser.HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.hrefs: list[str] = []

    def handle_starttag(self, tag: str, attrs):
        if tag.lower() != "a":
            return
        for key, value in attrs:
            if key.lower() == "href" and value:
                self.hrefs.append(value)


def workspace_patterns(workspace: str) -> list[str]:
    if workspace == "minigame":
        return MINIGAME_PATTERNS
    if workspace == "estudio":
        return ESTUDIO_PATTERNS
    return MINIGAME_PATTERNS + ESTUDIO_PATTERNS


def iter_files(root: Path, workspace: str) -> list[Path]:
    seen: set[Path] = set()
    files: list[Path] = []
    for pattern in workspace_patterns(workspace):
        for path in root.glob(pattern):
            if path.is_file() and path not in seen:
                seen.add(path)
                files.append(path)
    return sorted(files)


def markdown_links(text: str) -> list[str]:
    links: list[str] = []
    # Standard inline Markdown links/images. Avoid matching bare brackets inside code blocks perfectly; this is a lightweight checker.
    for match in re.finditer(r"!?\[[^\]\n]*\]\(([^)\n]+)\)", text):
        target = match.group(1).strip()
        if target.startswith("<") and target.endswith(">"):
            target = target[1:-1].strip()
        links.append(target)
    return links


def html_links(text: str) -> list[str]:
    parser = LinkHTMLParser()
    parser.feed(text)
    return parser.hrefs


def should_skip(href: str) -> bool:
    href = href.strip()
    return not href or href.startswith("#") or href.lower().startswith(URL_PREFIXES)


def resolve_target(source: Path, href: str) -> Path | None:
    href = href.strip().split("#", 1)[0]
    if should_skip(href) or not href:
        return None
    href = unquote(href)
    # Ignore deliberately templated placeholders.
    if "<" in href or ">" in href:
        return None
    return (source.parent / href).resolve()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--workspace", choices=["minigame", "estudio", "auto"], default="auto")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    workspace = args.workspace
    if workspace == "auto":
        workspace = "minigame" if (root / "08_Coordenacao_Agentes/Prioridades_MinigameStudio.md").exists() else "estudio"

    files = iter_files(root, workspace)
    broken: list[tuple[str, str, str]] = []
    checked_links = 0
    for path in files:
        text = path.read_text(encoding="utf-8", errors="replace")
        links = html_links(text) if path.suffix.lower() in {".html", ".htm"} else markdown_links(text)
        for href in links:
            target = resolve_target(path, href)
            if target is None:
                continue
            checked_links += 1
            if not target.exists():
                broken.append((str(path.relative_to(root)), href, str(target)))

    if broken:
        print(f"LOCAL_DOC_LINK_CHECK_FAIL files_scanned={len(files)} links_checked={checked_links} broken={len(broken)}")
        for source, href, target in broken:
            print(f" - {source}: {href} -> {target}")
        return 1

    print(f"LOCAL_DOC_LINK_CHECK_PASS files_scanned={len(files)} links_checked={checked_links}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
