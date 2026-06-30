#!/usr/bin/env python
"""Generate FABIO_DASHBOARD.html from FABIO_DASHBOARD.md.

The Markdown file is the human-editable source. The HTML file is a generated
local browser view. Use --check in validators to fail if the checked-in HTML is
stale.
"""
from __future__ import annotations

import argparse
import difflib
import html
import os
import re
from pathlib import Path

MARKER = "Generated from FABIO_DASHBOARD.md by tools/generate_fabio_dashboard.py. Do not edit HTML directly."


def slugify(text: str) -> str:
    text = re.sub(r"<[^>]+>", "", text)
    text = re.sub(r"[^a-zA-Z0-9]+", "-", text.strip().lower()).strip("-")
    return text or "section"


def find_existing_link(root: Path, html_dir: Path, code: str) -> str | None:
    if any(ch in code for ch in "<>|*"):
        return None
    if not re.search(r"\.(md|html|ps1|py)$", code, flags=re.I):
        return None
    raw = code.replace("\\", "/")
    candidates = []
    if raw.startswith("../"):
        candidates.append((html_dir / raw).resolve())
    else:
        candidates.append((root / raw).resolve())
        candidates.append((html_dir / raw).resolve())
    for candidate in candidates:
        if candidate.exists():
            return Path(os.path.relpath(candidate, html_dir)).as_posix()
    return None


def inline_markup(text: str, root: Path, html_dir: Path) -> str:
    placeholders: list[str] = []
    def stash(value: str) -> str:
        placeholders.append(value)
        return f"\u0000{len(placeholders)-1}\u0000"
    def md_link(match: re.Match[str]) -> str:
        label = html.escape(match.group(1))
        href = html.escape(match.group(2).strip())
        return stash(f'<a href="{href}">{label}</a>')
    text = re.sub(r"\[([^\]\n]+)\]\(([^)\n]+)\)", md_link, text)
    def code_span(match: re.Match[str]) -> str:
        value = match.group(1)
        href = find_existing_link(root, html_dir, value)
        escaped = html.escape(value)
        if href:
            return stash(f'<a class="code-link" href="{html.escape(href)}"><code>{escaped}</code></a>')
        return stash(f"<code>{escaped}</code>")
    text = re.sub(r"`([^`]+)`", code_span, text)
    text = html.escape(text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"\*([^*]+)\*", r"<em>\1</em>", text)
    for i, value in enumerate(placeholders):
        text = text.replace(f"\u0000{i}\u0000", value)
    return text


def render_table(lines: list[str], root: Path, html_dir: Path) -> str:
    rows = []
    for line in lines:
        stripped = line.strip().strip("|")
        cells = [cell.strip() for cell in stripped.split("|")]
        rows.append(cells)
    if len(rows) >= 2 and all(re.fullmatch(r":?-{3,}:?", c.replace(" ", "")) for c in rows[1]):
        header = rows[0]
        body = rows[2:]
    else:
        header = []
        body = rows
    out = ["<div class=\"table-wrap\"><table>"]
    if header:
        out.append("<thead><tr>" + "".join(f"<th>{inline_markup(c, root, html_dir)}</th>" for c in header) + "</tr></thead>")
    out.append("<tbody>")
    for row in body:
        out.append("<tr>" + "".join(f"<td>{inline_markup(c, root, html_dir)}</td>" for c in row) + "</tr>")
    out.append("</tbody></table></div>")
    return "\n".join(out)


def render_markdown(md: str, root: Path, html_dir: Path) -> tuple[str, str]:
    lines = md.splitlines()
    title = "Painel Fabio"
    out: list[str] = []
    in_ul = False
    in_ol = False
    paragraph: list[str] = []
    def close_para() -> None:
        nonlocal paragraph
        if paragraph:
            out.append(f"<p>{inline_markup(' '.join(paragraph), root, html_dir)}</p>")
            paragraph = []
    def close_lists() -> None:
        nonlocal in_ul, in_ol
        if in_ul:
            out.append("</ul>"); in_ul = False
        if in_ol:
            out.append("</ol>"); in_ol = False
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        if not stripped:
            close_para(); close_lists(); i += 1; continue
        if stripped.startswith("|") and i + 1 < len(lines) and lines[i + 1].strip().startswith("|"):
            close_para(); close_lists()
            table_lines = []
            while i < len(lines) and lines[i].strip().startswith("|"):
                table_lines.append(lines[i]); i += 1
            out.append(render_table(table_lines, root, html_dir)); continue
        h = re.match(r"^(#{1,6})\s+(.+)$", stripped)
        if h:
            close_para(); close_lists()
            level = len(h.group(1)); content = h.group(2).strip()
            if level == 1:
                title = re.sub(r"`", "", content)
                i += 1; continue
            anchor = slugify(content)
            out.append(f'<h{level} id="{anchor}">{inline_markup(content, root, html_dir)}</h{level}>')
            i += 1; continue
        item = re.match(r"^-\s+(.+)$", stripped)
        if item:
            close_para()
            if in_ol:
                out.append("</ol>"); in_ol = False
            if not in_ul:
                out.append("<ul>"); in_ul = True
            out.append(f"<li>{inline_markup(item.group(1), root, html_dir)}</li>")
            i += 1; continue
        item = re.match(r"^\d+\.\s+(.+)$", stripped)
        if item:
            close_para()
            if in_ul:
                out.append("</ul>"); in_ul = False
            if not in_ol:
                out.append("<ol>"); in_ol = True
            out.append(f"<li>{inline_markup(item.group(1), root, html_dir)}</li>")
            i += 1; continue
        paragraph.append(stripped); i += 1
    close_para(); close_lists()
    return title, "\n".join(out)


def indent(text: str, spaces: int) -> str:
    pad = " " * spaces
    return "\n".join(pad + line if line else line for line in text.splitlines())


def wrap_sections(body: str) -> str:
    parts = re.split(r"(?=<h2\b)", body)
    rendered = []
    intro = parts[0].strip()
    if intro:
        rendered.append("      <section>\n" + indent(intro, 8) + "\n      </section>")
    for part in parts[1:]:
        rendered.append("      <section>\n" + indent(part.strip(), 8) + "\n      </section>")
    return "\n".join(rendered)


def generate(root: Path) -> str:
    md_path = root / "08_Coordenacao_Agentes" / "FABIO_DASHBOARD.md"
    html_path = root / "08_Coordenacao_Agentes" / "FABIO_DASHBOARD.html"
    md = md_path.read_text(encoding="utf-8")
    title, body = render_markdown(md, root, html_path.parent)
    return f'''<!doctype html>
<!-- {MARKER} -->
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{html.escape(title)}</title>
  <style>
    :root {{ --bg: #0b1020; --panel: rgba(255,255,255,.075); --line: rgba(255,255,255,.14); --text: #f5f7fb; --muted: #aeb8cf; --soft: #d8def0; --blue: #60a5fa; --green: #34d399; --amber: #fbbf24; --purple: #a78bfa; --shadow: 0 18px 60px rgba(0,0,0,.35); --radius: 22px; }}
    * {{ box-sizing: border-box; }}
    body {{ margin: 0; min-height: 100vh; color: var(--text); background: radial-gradient(circle at 12% 8%, rgba(167,139,250,.26), transparent 28%), radial-gradient(circle at 78% 18%, rgba(96,165,250,.18), transparent 28%), linear-gradient(135deg, #090d1a 0%, #11182d 48%, #08111f 100%); font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; line-height: 1.5; }}
    a {{ color: #bfdbfe; text-decoration: none; font-weight: 700; }} a:hover {{ text-decoration: underline; }}
    .page {{ width: min(1160px, calc(100% - 32px)); margin: 0 auto; padding: 34px 0 56px; }}
    .hero, section {{ border: 1px solid var(--line); border-radius: var(--radius); background: var(--panel); box-shadow: var(--shadow); backdrop-filter: blur(18px); }}
    .hero {{ padding: clamp(22px, 4vw, 36px); margin-bottom: 18px; }}
    .eyebrow {{ color: var(--green); font-weight: 900; text-transform: uppercase; letter-spacing: .12em; font-size: 12px; }}
    h1 {{ margin: 8px 0 12px; font-size: clamp(34px, 6vw, 62px); line-height: .96; letter-spacing: -.055em; }}
    .source-note {{ margin-top: 16px; padding: 12px 14px; border: 1px solid rgba(251,191,36,.32); border-radius: 16px; background: rgba(251,191,36,.09); color: #ffe7a3; font-size: 13px; }}
    .content {{ display: grid; gap: 18px; }} section {{ padding: 22px; }} section > h2:first-child {{ margin-top: 0; }}
    h2 {{ margin: 0 0 14px; color: #eef4ff; font-size: 25px; letter-spacing: -.035em; }} h3 {{ margin: 18px 0 8px; color: #dbeafe; }}
    p {{ color: var(--soft); margin: 0 0 12px; }} ul, ol {{ color: var(--soft); margin: 8px 0 0; padding-left: 22px; }} li {{ margin: 6px 0; }}
    code {{ color: #dbeafe; background: rgba(96,165,250,.13); border: 1px solid rgba(96,165,250,.22); padding: 2px 6px; border-radius: 8px; }} .code-link code {{ border-color: rgba(52,211,153,.34); background: rgba(52,211,153,.10); }}
    .table-wrap {{ overflow-x: auto; margin: 12px 0; border: 1px solid var(--line); border-radius: 16px; }} table {{ width: 100%; border-collapse: collapse; min-width: 640px; }} th, td {{ padding: 12px 14px; border-bottom: 1px solid var(--line); vertical-align: top; }} th {{ text-align: left; color: #dbeafe; background: rgba(255,255,255,.06); }} tr:last-child td {{ border-bottom: 0; }}
    .footer {{ margin-top: 18px; color: var(--muted); font-size: 13px; text-align: center; }} @media (max-width: 760px) {{ .page {{ width: min(100% - 20px, 1160px); padding-top: 20px; }} section {{ padding: 18px; }} }}
  </style>
</head>
<body>
  <main class="page">
    <article class="hero">
      <div class="eyebrow">Painel Fabio · gerado do Markdown</div>
      <h1>{html.escape(title)}</h1>
      <div class="source-note">Este HTML e gerado automaticamente de <a href="FABIO_DASHBOARD.md">FABIO_DASHBOARD.md</a>. Edite o Markdown; nao edite o HTML diretamente.</div>
    </article>
    <div class="content">
{wrap_sections(body)}
    </div>
    <div class="footer">{html.escape(MARKER)}</div>
  </main>
</body>
</html>
'''


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--check", action="store_true", help="Fail if FABIO_DASHBOARD.html is stale")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    html_path = root / "08_Coordenacao_Agentes" / "FABIO_DASHBOARD.html"
    generated = generate(root)
    if args.check:
        current = html_path.read_text(encoding="utf-8") if html_path.exists() else ""
        if current != generated:
            print("FABIO_DASHBOARD_GENERATED_CHECK_FAIL")
            diff = difflib.unified_diff(current.splitlines(), generated.splitlines(), fromfile=str(html_path), tofile="generated", lineterm="")
            for line in list(diff)[:120]:
                print(line)
            return 1
        print("FABIO_DASHBOARD_GENERATED_CHECK_PASS")
        return 0
    html_path.write_text(generated, encoding="utf-8", newline="\n")
    print(f"FABIO_DASHBOARD_GENERATED {html_path}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
