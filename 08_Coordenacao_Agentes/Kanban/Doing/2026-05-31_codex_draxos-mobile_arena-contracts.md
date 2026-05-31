# Multi-Agent Doing: DraxosMobile Arena Contracts And Content

## Metadata

- data: `2026-05-31`
- agente: `Codex worker`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/arena-contracts`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-contracts`

## Objetivo

Definir contratos, docs e dados de conteudo para Arena PVE v1 antes de backend/client definitivo.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`

## Escopo

- Incluir: `docs/pve-arena-v1.md`, contratos de API/content/battle-log/database/ruleset e dados `pve_arenas`, `pve_enemies`, `arena_buffs`, `arena_rewards`.
- Fora do escopo: Edge Functions, SQL de runtime e UI Godot.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/docs/`
- `Projetos/draxos-mobile/docs/contracts/`
- `Projetos/draxos-mobile/data/definitions/`
- `Projetos/draxos-mobile/tools/generate_foundation_ruleset.ts`
- `Projetos/draxos-mobile/server/tests/foundation_ruleset_test.ts`

## Plano De Commit

- `docs: define pve arena v1`
- `data: add pve arena content definitions`
- `test: include arena data in ruleset`

## Validacao

- `git diff --check`
- `npx -y deno test --allow-read server/tests/foundation_ruleset_test.ts`

## Proximo Handoff

Entregar contratos e dados para backend, cliente e labs consumirem sem redefinir schema por conta propria.
