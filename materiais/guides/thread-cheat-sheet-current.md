# Thread Cheat Sheet - Current

Use these prompt shapes for new agent threads in `D:\Estudio`.

## P0 Roguelike Implementation

```text
Projeto: draxos-roguelike-cardgame
Tipo: Implementation | Validation | Review
Objetivo: <one sentence>
Rota: Fast Lane if local; no canon changes unless requested
Escopo: Projetos/draxos-roguelike-cardgame/<paths>
Validacao: tools/validate.gd and focused lab gates as risk requires
```

## P2 DraxosMobile Work

```text
Projeto: draxos-mobile
Tipo: Docs | Client | Backend | Validation | Release
Objetivo: <one sentence>
Rota: follow AGENTS.md + docs/agent-operating-manual.md
Escopo: Projetos/draxos-mobile/<paths>
Boundaries: no remote mutation/publication unless explicit; no tuning/economy/PVP/content without decision
Validacao: validate_foundation.ps1 profile or focused docs checks
```

## Docs-Only Portfolio Cleanup

```text
Projeto: estudio
Tipo: DocsOnly
Objetivo: align portfolio/coordinator docs with current project status
Rota: portfolio authority first
Escopo: README.md, AGENTS.md, Projetos/README.md, 08_Coordenacao_Agentes/
Validacao: git diff --check + targeted rg drift checks
```

## Historical Consultation

```text
Projeto: rpg-isometrico | rpg-turnos | migration
Tipo: Historical
Objetivo: answer <question>
Rota: read-only historical path
Regra: do not treat historical notes as current canon or implementation permission
```

## Review

```text
Projeto: <target>
Tipo: Review
Objetivo: review changed files for bugs, risks, regressions and missing tests
Rota: read status, diff, validation evidence and touched docs
Saida: findings first, file/line references, residual risk
```

## Multiagent Handoff

```text
Projeto: <target>
Tipo: Handoff
From/To: <agent> -> <agent/user>
Branch/worktree: <branch> / <absolute path>
Estado preservado: <package/stage>
Validacao: <commands and PASS/FAIL/NOT RUN>
Proximo passo: <smallest safe next action>
```
