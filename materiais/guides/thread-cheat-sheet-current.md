# Thread Cheat Sheet - Current

## Metadata

- status: `active`
- authority: `runbook`
- last_verified: `2026-07-17`
- review_when: `scope taxonomy, routing or closure contracts change`
- supersedes: `thread-cheat-sheet-current.md before Documentation Lite`
- superseded_by: `none`

Use these prompt shapes for new agent tasks in `D:\Estudio`.

## Project-Local Work

```text
Projeto: <official project from Projetos/README.md>
Tipo: Implementation | Documentation | Validation | Review
Objetivo: <one sentence>
Autoridade: read AGENTS.md, Prioridades_Estudio.md and local current-status.md
Escopo: Projetos/<project>/<paths>
Fora do escopo: product/priority/remote/publication unless explicitly authorized
Validacao: smallest profile from qa/QA_INDEX.md and qa_manifest.json
```

## Operations-Local Work

```text
Projeto: <official project>
Tipo: QA | Build preparation | Evidence | Release preparation
Objetivo: <one sentence>
Rota: local coordination; no portfolio hot-file edits
Boundaries: no remote, publication, signing or physical-device authority
Validacao: <typed local runner/profile>
```

## Portfolio Or Governance Work

```text
Projeto: estudio
Tipo: portfolio_sync | global_governance | documentation_alignment
Objetivo: <one sentence>
Rota: dedicated global writer and current authority documents
Escopo: <explicit shared paths>
Validacao: DocsOnly AllOfficial + focused contract checks
```

## Paused Project Consultation Or Integrity

```text
Projeto: <paused project | migration>
Tipo: Historical | Integrity
Objetivo: <question or bounded repair>
Rota: portfolio permission first
Regra: no product resumption or new track without an explicit decision
```

## Review

```text
Projeto: <target>
Tipo: Review
Objetivo: review changed files for bugs, risks, regressions and missing tests
Rota: read status, diff, validation evidence and touched docs
Saida: findings first, file/line references, residual risk
```

## Real Handoff

```text
Projeto: <target>
From/To: <agent> -> <agent/user>
Branch/worktree: <branch> / <absolute path>
Commit/merged_to: <sha> / main@<sha>
Validacao: <commands and PASS/FAIL/NOT RUN>
Cleanup: <worktree removed; branch deleted or exact reason>
Proximo passo: <smallest safe next action>
```
