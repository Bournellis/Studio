# DraxosMobile Hardening Doing: <lane> - <titulo>

## Metadata

- data: `<YYYY-MM-DD>`
- agente: `Codex | Claude | Outro`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `coord-docs | backend-schema | session-data | client-shell | mode-scaffolds | platform-v1 | validation-release`
- mode_scope: `none | basebuilder | autobattler | openworld | towerdefense | cardgame | multi-mode`
- branch: `<branch>`
- worktree: `<absolute-path>`

## Objetivo

Descreva o resultado esperado em uma frase.

## Latest Context

- Current published package: `<package name + status + release root>`
- Current local implemented stage: `<stage name + local/published status>`
- Preserved Arena context: `Arena PVE remains the first approved core; see docs below`
- Open decision: `<decision id or explicit none>`
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `<lane docs>`

## Escopo

- Incluir:
  - `<arquivos/sistemas pretendidos>`
- Fora do escopo:
  - runtime fora da lane;
  - worktrees de outros agentes;
  - remote mutation/publicacao;
  - tuning, economia, PVP ou conteudo novo sem decisao explicita.

## Arquivos Pretendidos

- `path/to/file`

## Validation Plan

- `git diff --check`
- Validation profile: `<DocsOnly | ClientQuick | ModePlatform | ReleaseSafety | other>`
- `<lane-specific command>`

## Remote Mutation / Publication

- remote mutation/publication run: `yes/no`
- if yes, evidence: `<release root, preview, command summaries>`
- if no, preserved boundary: `no deploy, no Supabase/Cloudflare mutation, no export/publication`

## Handoff Point

Explique quando outro agente/Fabio deve assumir e quais evidencias faltam.
