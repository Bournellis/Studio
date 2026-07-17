#!/usr/bin/env python3
"""Build deterministic Documentation Lite v2 ledgers and cleanup manifests.

The builder is deliberately non-destructive: it reads historical sources from
one Git commit and can write only ledgers, manifests, the manifest index and a
pending authorization file. It never removes sources, creates tags, stages,
commits or contacts a remote.
"""
from __future__ import annotations

import argparse
import fnmatch
import hashlib
import json
import re
import subprocess
import unicodedata
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

from documentation_lite import _cat_blobs, _ls_tree, _tag_commit


REGISTER = "08_Coordenacao_Agentes/Registers/documentation-lite-v2"
AUTHORIZATION = f"{REGISTER}/authorization.json"
INDEX = f"{REGISTER}/index.json"
RECEIPTS = "08_Coordenacao_Agentes/Receipts/DocumentationLite"
RECOVERY_PREFIX = "recovery/estudio-documentation-lite/v2/"
MAX_BATCH_FILES = 150
MAX_BATCH_BYTES = 2 * 1024 * 1024
DATE_RE = re.compile(r"(20\d{2}-\d{2}-\d{2})")


@dataclass(frozen=True)
class ProjectSpec:
    key: str
    project: str
    root: str
    history: str
    qa: str
    release_history: str = ""


PROJECTS = (
    ProjectSpec(
        "jogodacopa", "JogoDaCopa", "Projetos/JogoDaCopa",
        "Projetos/JogoDaCopa/implementation/history.md",
        "Projetos/JogoDaCopa/qa/QA_INDEX.md",
        "Projetos/JogoDaCopa/docs/release-history.md",
    ),
    ProjectSpec(
        "fpsplayground", "FpsPlayground", "Projetos/FpsPlayground",
        "Projetos/FpsPlayground/implementation/history.md",
        "Projetos/FpsPlayground/qa/QA_INDEX.md",
    ),
    ProjectSpec(
        "draxosmobile", "DraxosMobile", "Projetos/draxos-mobile",
        "Projetos/draxos-mobile/implementation/history.md",
        "Projetos/draxos-mobile/qa/QA_INDEX.md",
        "Projetos/draxos-mobile/docs/release-history.md",
    ),
    ProjectSpec(
        "roguelike", "Draxos Roguelike", "Projetos/draxos-roguelike-cardgame",
        "Projetos/draxos-roguelike-cardgame/implementation/history.md",
        "Projetos/draxos-roguelike-cardgame/qa/QA_INDEX.md",
    ),
    ProjectSpec(
        "rpgisometrico", "RPG Isometrico", "Projetos/rpg-isometrico",
        "Projetos/rpg-isometrico/implementation/history.md",
        "Projetos/rpg-isometrico/qa/QA_INDEX.md",
    ),
    ProjectSpec(
        "rpgturnos", "RPG Turnos", "Projetos/rpg-turnos",
        "Projetos/rpg-turnos/implementation/history.md",
        "Projetos/rpg-turnos/qa/QA_INDEX.md",
    ),
)
PROJECT_BY_KEY = {item.key: item for item in PROJECTS}


SUPPORT_SOURCES = {
    "08_Coordenacao_Agentes/Docs_Status_Slimming_Plan.md",
    "08_Coordenacao_Agentes/Lifecycle_Cleanup_Audit_2026-06-29.md",
}


def _git(root: Path, *args: str) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(["git", *args], cwd=root, capture_output=True, check=False)


def _head(root: Path) -> str:
    proc = _git(root, "rev-parse", "HEAD")
    if proc.returncode:
        raise RuntimeError(proc.stderr.decode("utf-8", errors="replace").strip())
    return proc.stdout.decode("ascii").strip()


def _json_bytes(value: Any) -> bytes:
    return (json.dumps(value, indent=2, ensure_ascii=False) + "\n").encode("utf-8")


def _slug(value: str, limit: int = 64) -> str:
    normalized = unicodedata.normalize("NFKD", value).encode("ascii", "ignore").decode("ascii")
    result = re.sub(r"[^a-z0-9]+", "_", normalized.casefold()).strip("_")
    return (result or "record")[:limit].rstrip("_")


def _first_heading(path: str, blob: bytes) -> str:
    text = blob.decode("utf-8", errors="replace")
    for line in text.splitlines():
        heading = re.match(r"^#{1,6}\s+(.+?)\s*$", line)
        if heading:
            return re.sub(r"\s+", " ", heading.group(1)).strip()
    return Path(path).stem.replace("-", " ").replace("_", " ")


def _last_dates(root: Path, baseline: str, candidates: set[str]) -> dict[str, str]:
    proc = _git(root, "log", "--format=@@%cs%x00", "--name-only", "-z", baseline)
    if proc.returncode:
        raise RuntimeError(proc.stderr.decode("utf-8", errors="replace").strip())
    current = ""
    result: dict[str, str] = {}
    for raw in proc.stdout.split(b"\x00"):
        token = raw.decode("utf-8", errors="replace").strip("\r\n")
        if token.startswith("@@"):
            current = token[2:]
        elif token in candidates and token not in result and current:
            result[token] = current
        if len(result) == len(candidates):
            break
    return result


def _date_for(path: str, blob: bytes, last_dates: dict[str, str]) -> str:
    match = DATE_RE.search(Path(path).name)
    if match:
        return match.group(1)
    match = DATE_RE.search(blob.decode("utf-8", errors="replace"))
    if match:
        return match.group(1)
    return last_dates.get(path, "2026-07-17")


def _project_for_global(path: str, blob: bytes) -> str:
    filename = Path(path).name.casefold()
    strong_rules = (
        ("rpgturnos", ("rpg-turnos", "rpg_turnos")),
        ("rpgisometrico", ("rpg-isometrico", "rpg_isometrico")),
        ("jogodacopa", ("jogodacopa", "jogo-da-copa")),
        ("fpsplayground", ("fpsplayground", "fpsshooter")),
        ("draxosmobile", ("draxos-mobile", "draxosmobile")),
        ("roguelike", ("draxos-roguelike", "roguelike-cardgame", "card-impact", "design-lab")),
    )
    if any(token in filename for token in ("_estudio_", "active-games", "modes-integrated", "playground_split")):
        return "estudio"
    for key, needles in strong_rules:
        if any(needle in filename for needle in needles):
            return key
    if "_draxos_" in filename or "_draxos-" in filename:
        return "roguelike"
    value = blob[:4096].decode("utf-8", errors="ignore").casefold()
    rules = (
        ("rpgturnos", ("rpg-turnos", "rpg_turnos", "rpg turnos")),
        ("rpgisometrico", ("rpg-isometrico", "rpg_isometrico", "rpg isometrico", "isométrico")),
        ("jogodacopa", ("jogodacopa", "jogo da copa", "copa arena", "super campeao", "super campeão")),
        ("fpsplayground", ("fpsplayground", "fpsshooter", "fps playground")),
        ("draxosmobile", ("draxos-mobile", "draxosmobile")),
        ("roguelike", ("draxos-roguelike", "roguelike-cardgame", "card impact", "design lab")),
    )
    for key, needles in rules:
        if any(needle in value for needle in needles):
            return key
    return "estudio"


def _local_candidates(spec: ProjectSpec, paths: set[str], blobs_by_path: dict[str, bytes]) -> set[str]:
    prefix = spec.root + "/"
    result = {
        path for path in paths
        if path.startswith(prefix + "08_Coordenacao/")
        and ("/Kanban/Done/" in path or "/Handoffs/" in path)
        and path.endswith(".md")
        and Path(path).name.casefold() != "readme.md"
    }
    result.update(
        path for path in paths
        if path.startswith(prefix + "08_Coordenacao/Kanban/Doing/")
        and "documentation-lite" in Path(path).name.casefold()
        and path.endswith(".md")
    )
    tracks = prefix + "implementation/tracks/"
    result.update(path for path in paths if path.startswith(tracks) and path.endswith(".md"))
    if spec.key == "jogodacopa":
        result.update(path for path in paths if fnmatch.fnmatch(path, prefix + "docs/code-review-*.md"))
        reports = prefix + "docs/playtest-reports/"
        result.update(
            path for path in paths
            if path.startswith(reports) and path.endswith(".md") and "/" not in path[len(reports):]
        )
        result.update(prefix + "docs/" + name for name in (
            "arcade-upgrade-plan.md", "codebase-audit-track05.md", "next-series-options.md",
            "process-hardening-agents-addendum.md", "quality-upgrade-plan.md", "release-plan.md",
            "reuse-map.md", "series-06-broadcast-polish-plan.md",
        ) if prefix + "docs/" + name in paths)
    elif spec.key == "fpsplayground":
        result.update(prefix + "docs/" + name for name in (
            "arena-shooter-future-roadmap.md", "codebase-audit-track05.md",
            "refactor-hardening-roadmap.md",
        ) if prefix + "docs/" + name in paths)
    elif spec.key == "draxosmobile":
        index_path = prefix + "docs/history/documentation-index-pre-governance-v2-2026-07-16.md"
        text = blobs_by_path.get(index_path, b"").decode("utf-8", errors="replace")
        for line in text.splitlines():
            if "`HISTORICO`" not in line:
                continue
            match = re.search(r"`(docs/[^`]+)`", line)
            if match and prefix + match.group(1) in paths:
                result.add(prefix + match.group(1))
    elif spec.key == "roguelike":
        result.update(prefix + name for name in (
            "docs/reuse-map.md", "docs/foundation-closeout.md", "docs/design-early-game.md",
            "docs/encounters/README.md", "docs/encounters/encontro-02-ondas.md",
            "docs/encounters/encontro-01-limpar-board.md",
            "docs/design-proposals/sessao-b-cartas-novas.md",
            "docs/design-proposals/sessao-a-keywords.md",
            "docs/design-proposals/rota-29-mapas.md",
        ) if prefix + name in paths)
    elif spec.key == "rpgisometrico":
        result.update(
            path for path in paths
            if any(path.startswith(prefix + f"implementation/phase-g{number}/") for number in range(1, 5))
            and path.endswith(".md")
        )
        result.update(
            path for path in paths
            if path.startswith(prefix + "implementation/checkpoints/") and path.endswith(".md")
        )
        result.update(prefix + name for name in (
            "implementation/execution-log.md", "docs/campaign-framework-smoke.md",
            "docs/g4-shared-mode-foundation-smoke.md", "docs/first-slice-smoke.md",
            "docs/canonical-product-foundation-smoke.md",
        ) if prefix + name in paths)
    elif spec.key == "rpgturnos":
        result.update(prefix + name for name in (
            "implementation/roadmap.md", "docs/cardgame-core-experiments.md", "docs/project-brief.md",
            "docs/lore-content-migration.md", "docs/open-gaps.md", "docs/first-playable-slice-smoke.md",
        ) if prefix + name in paths)
    return result


def discover_candidates(tree: dict[str, str], blobs_by_path: dict[str, bytes]) -> dict[str, str]:
    """Return source path -> owning project key; Review is intentionally absent."""
    paths = set(tree)
    result: dict[str, str] = {}
    for spec in PROJECTS:
        for path in _local_candidates(spec, paths, blobs_by_path):
            result[path] = spec.key
    for path in sorted(paths):
        if path.startswith("08_Coordenacao_Agentes/Kanban/Done/") and path.endswith(".md"):
            result[path] = _project_for_global(path, blobs_by_path[path])
        elif path.startswith("08_Coordenacao_Agentes/Handoffs/") and path.endswith(".md"):
            result[path] = _project_for_global(path, blobs_by_path[path])
        elif path == "08_Coordenacao_Agentes/Kanban/Doing/2026-07-17_codex_estudio-documentation-lite-v2.md":
            result[path] = "estudio"
        elif path.startswith("migration/") and path.endswith(".md"):
            result[path] = "estudio"
        elif path.startswith("07_Aprendizados/") and path.endswith(".md"):
            result[path] = "estudio"
        elif path in SUPPORT_SOURCES:
            result[path] = "estudio"
    review_sources = [path for path in result if "/Kanban/Review/" in path]
    if review_sources:
        raise RuntimeError(f"protected Review source selected: {review_sources[0]}")
    return result


def _kind(path: str) -> str:
    if "/Kanban/Done/" in path:
        return "done_card"
    if "/Handoffs/" in path:
        return "handoff"
    if "/implementation/tracks/" in path:
        return "track"
    if "/implementation/phase-" in path:
        return "phase"
    if "/implementation/checkpoints/" in path:
        return "checkpoint"
    return "historical_document"


def _classification(path: str, blob: bytes) -> str:
    value = (path + "\n" + blob.decode("utf-8", errors="ignore")).casefold()
    if any(word in value for word in ("credential", "secret", "keystore", "security", "segredo")):
        return "security"
    if any(word in value for word in ("incident", "corruption", "byte nulo", "nul byte")):
        return "incident"
    if any(word in value for word in ("human_gate_status: pending", "aguardando decis", "rejeitad", "aprovad")):
        return "human_gate"
    if any(word in value for word in ("publication", "publicaç", "release", "rollback", "deploy")):
        return "publication_release"
    if any(word in value for word in ("decision", "decisão", "decisao")):
        return "decision"
    if any(word in value for word in ("contract", "contrato", "schema", "authority")):
        return "technical_contract"
    if any(word in value for word in ("evidence", "evidência", "playtest", "smoke")):
        return "evidence_summary"
    if _kind(path) in {"track", "phase", "checkpoint"}:
        return "technical_history"
    return "coordination_duplicate"


def _human_gate(blob: bytes) -> str:
    value = blob.decode("utf-8", errors="ignore").casefold()
    if "human_gate_status: pending" in value or "aguardando_decisao" in value or "aguardando decisão" in value:
        return "pending gate preserved in retained authority; no decision inferred"
    if "human_gate_status: approved" in value or "human_approved" in value or "aprovado por fabio" in value:
        return "historical human approval preserved; no new approval inferred"
    if "human_gate_required: no" in value or "not_required" in value:
        return "not required by the historical record"
    return "not inferred from historical narrative"


def _ledger_path(owner: str, month: str) -> str:
    if owner == "estudio":
        return f"08_Coordenacao_Agentes/History/{month}.md"
    spec = PROJECT_BY_KEY[owner]
    return f"{spec.root}/implementation/history-ledger/{month}.md"


def _retained_authorities(owner: str, classification: str, ledger: str) -> list[str]:
    if owner == "estudio":
        return sorted({
            ledger, "AGENTS.md",
            "08_Coordenacao_Agentes/Decisoes/2026-07-17_estudio_documentation-lite-v2-cutover-recuperavel.md",
            "08_Coordenacao_Agentes/Runbooks/DOCUMENTATION_LITE_LIFECYCLE.md",
        })
    spec = PROJECT_BY_KEY[owner]
    result = {ledger, spec.history, spec.qa}
    if classification == "publication_release" and spec.release_history:
        result.add(spec.release_history)
    return sorted(result)


def _record_id(path: str) -> str:
    digest = hashlib.sha256(path.encode("utf-8")).hexdigest()[:10]
    return f"rec_{_slug(Path(path).stem, 45)}_{digest}"


def _group(owner: str, date: str, path: str) -> str:
    month = date[:7]
    if path.startswith("08_Coordenacao_Agentes/"):
        return f"coord_{owner}_{month.replace('-', '')}"
    if owner == "estudio":
        return f"support_{month.replace('-', '')}"
    return f"local_{owner}"


def _split_groups(items: list[dict[str, Any]]) -> list[tuple[str, list[dict[str, Any]]]]:
    grouped: dict[str, list[dict[str, Any]]] = {}
    for item in items:
        grouped.setdefault(item["group"], []).append(item)
    result: list[tuple[str, list[dict[str, Any]]]] = []
    for base_id in sorted(grouped):
        chunks: list[list[dict[str, Any]]] = []
        current: list[dict[str, Any]] = []
        current_bytes = 0
        for item in sorted(grouped[base_id], key=lambda value: value["entry"]["path"]):
            size = item["entry"]["byte_count"]
            if current and (len(current) >= MAX_BATCH_FILES or current_bytes + size > MAX_BATCH_BYTES):
                chunks.append(current)
                current = []
                current_bytes = 0
            current.append(item)
            current_bytes += size
        if current:
            chunks.append(current)
        for index, chunk in enumerate(chunks, 1):
            suffix = f"_{index:02d}" if len(chunks) > 1 else ""
            result.append((base_id + suffix, chunk))
    return result


def build_artifacts(root: Path, baseline: str, recovery_tag: str) -> tuple[dict[str, bytes], dict[str, Any]]:
    if not re.fullmatch(r"[0-9a-f]{40}", baseline):
        raise RuntimeError("baseline must be a full 40-character Git commit")
    if not recovery_tag.startswith(RECOVERY_PREFIX):
        raise RuntimeError(f"recovery tag must start with {RECOVERY_PREFIX}")
    resolved = _tag_commit(root, recovery_tag)
    if resolved != baseline:
        raise RuntimeError(f"recovery tag resolves to {resolved!r}, expected {baseline}")
    tree = _ls_tree(root, baseline)
    content_seeds = {
        path for path in tree
        if (
            (path.startswith("08_Coordenacao_Agentes/Kanban/Done/") and path.endswith(".md"))
            or (path.startswith("08_Coordenacao_Agentes/Handoffs/") and path.endswith(".md"))
            or path == "Projetos/draxos-mobile/docs/history/documentation-index-pre-governance-v2-2026-07-16.md"
        )
    }
    seed_blobs = _cat_blobs(root, (tree[path] for path in content_seeds))
    blobs_by_path = {path: seed_blobs[tree[path]] for path in content_seeds}
    owners = discover_candidates(tree, blobs_by_path)
    candidate_blobs = _cat_blobs(root, (tree[path] for path in owners))
    blobs_by_path = {path: candidate_blobs[tree[path]] for path in owners}
    dates = _last_dates(root, baseline, set(owners))
    items: list[dict[str, Any]] = []
    ledger_rows: dict[str, list[dict[str, str]]] = {}
    for path in sorted(owners):
        owner = owners[path]
        blob = blobs_by_path[path]
        date = _date_for(path, blob, dates)
        month = date[:7]
        classification = _classification(path, blob)
        ledger = _ledger_path(owner, month)
        authorities = _retained_authorities(owner, classification, ledger)
        outcome = _first_heading(path, blob)
        record_id = _record_id(path)
        digest = hashlib.sha256(blob).hexdigest()
        record = {
            "record_id": record_id,
            "date": date,
            "scope": owner,
            "outcome": outcome,
            "human_gate": _human_gate(blob),
            "technical_result_ref": f"{baseline}:{path}",
            "validation": "Git blob, SHA-256, byte count and line count verified at the cutover baseline",
            "evidence": f"sha256:{digest}; retained:{';'.join(authorities)}",
            "source_count": 1,
            "ledger_path": ledger,
            "source_paths": [path],
        }
        entry = {
            "path": path,
            "kind": _kind(path),
            "classification": classification,
            "byte_count": len(blob),
            "line_count": len(blob.splitlines()),
            "source_blob": tree[path],
            "source_sha256": digest,
            "disposition": "remove_with_ledger",
            "unique_content_status": "absorbed",
            "record_id": record_id,
            "retained_authorities": authorities,
        }
        item = {"group": _group(owner, date, path), "owner": owner, "entry": entry, "record": record}
        items.append(item)
        ledger_rows.setdefault(ledger, []).append({
            "record_id": record_id, "date": date, "scope": owner, "outcome": outcome,
            "human_gate": record["human_gate"], "validation": record["validation"],
            "evidence": record["evidence"], "source": f"{baseline}:{path}",
        })
    artifacts: dict[str, bytes] = {}
    for ledger, rows in sorted(ledger_rows.items()):
        lines = [
            f"# Documentation Lite history ledger — {Path(ledger).stem}", "",
            "## Metadata", "", "- status: `active`", "- authority: `historical_record`",
            "- last_verified: `2026-07-17`",
            "- review_when: `a receipt, retained authority or recovery reference changes`",
            "- supersedes: `resolved narrative sources listed below`", "- superseded_by: `none`", "",
            "Each row preserves one resolved source without defining current status, priority, next work or a new human decision.", "",
            "| record_id | date | scope | outcome | human gate | validation | evidence | recoverable source |",
            "|---|---|---|---|---|---|---|---|",
        ]
        for row in sorted(rows, key=lambda value: (value["date"], value["record_id"])):
            escaped = [str(row[key]).replace("|", "\\|").replace("\n", " ") for key in (
                "record_id", "date", "scope", "outcome", "human_gate", "validation", "evidence", "source",
            )]
            lines.append("| " + " | ".join(escaped) + " |")
        artifacts[ledger] = ("\n".join(lines) + "\n").encode("utf-8")
    descriptors: list[dict[str, str]] = []
    batch_sizes: dict[str, int] = {}
    for batch_id, chunk in _split_groups(items):
        owners_in_batch = sorted({item["owner"] for item in chunk})
        project = PROJECT_BY_KEY[owners_in_batch[0]].project if len(owners_in_batch) == 1 and owners_in_batch[0] != "estudio" else "Estudio"
        manifest = {
            "schema_version": 2,
            "batch_id": batch_id,
            "scope": owners_in_batch[0] if len(owners_in_batch) == 1 else "estudio",
            "project": project,
            "baseline_commit": baseline,
            "recovery_tag": recovery_tag,
            "authorization_ref": AUTHORIZATION,
            "entries": [item["entry"] for item in chunk],
            "records": [item["record"] for item in chunk],
        }
        manifest_path = f"{REGISTER}/batches/{batch_id}.json"
        payload = _json_bytes(manifest)
        artifacts[manifest_path] = payload
        receipt = f"{RECEIPTS}/{batch_id}.json"
        descriptors.append({
            "batch_id": batch_id, "manifest": manifest_path, "receipt": receipt,
            "manifest_sha256": hashlib.sha256(payload).hexdigest(),
        })
        batch_sizes[batch_id] = sum(item["entry"]["byte_count"] for item in chunk)
    index = {
        "schema_version": 2,
        "enforcement_mode": "strict",
        "authorization_path": AUTHORIZATION,
        "batches": descriptors,
    }
    artifacts[INDEX] = _json_bytes(index)
    artifacts[AUTHORIZATION] = _json_bytes({
        "schema_version": 1, "status": "pending", "approved_by": "", "approved_at": "",
        "index_sha256": "", "evidence": "Fabio must approve the exact index SHA-256 before Execute",
    })
    summary = {
        "baseline_commit": baseline,
        "recovery_tag": recovery_tag,
        "candidate_count": len(items),
        "candidate_bytes": sum(item["entry"]["byte_count"] for item in items),
        "batch_count": len(descriptors),
        "ledger_count": len(ledger_rows),
        "index_sha256": hashlib.sha256(artifacts[INDEX]).hexdigest(),
        "batches": batch_sizes,
        "projects": {
            owner: sum(1 for item in items if item["owner"] == owner)
            for owner in sorted({item["owner"] for item in items})
        },
    }
    return artifacts, summary


def write_artifacts(root: Path, artifacts: dict[str, bytes]) -> None:
    for relative, payload in sorted(artifacts.items()):
        path = root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(payload)


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=str(Path(__file__).resolve().parent.parent))
    parser.add_argument("--baseline", default="HEAD")
    parser.add_argument("--recovery-tag", required=True)
    parser.add_argument("--write", action="store_true")
    parser.add_argument("--report-path")
    args = parser.parse_args(list(argv) if argv is not None else None)
    root = Path(args.root).resolve()
    baseline = args.baseline
    if baseline == "HEAD":
        baseline = _head(root)
    else:
        proc = _git(root, "rev-parse", f"{baseline}^{{commit}}")
        if proc.returncode:
            raise SystemExit(proc.stderr.decode("utf-8", errors="replace").strip())
        baseline = proc.stdout.decode("ascii").strip()
    artifacts, summary = build_artifacts(root, baseline, args.recovery_tag)
    if args.write:
        write_artifacts(root, artifacts)
    output = _json_bytes(summary).decode("utf-8")
    if args.report_path:
        report = Path(args.report_path)
        if not report.is_absolute():
            report = root / report
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(output, encoding="utf-8")
    print(output, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
