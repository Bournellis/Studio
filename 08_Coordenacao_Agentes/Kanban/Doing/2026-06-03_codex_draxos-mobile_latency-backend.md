# DraxosMobile Hardening Doing: backend-schema - latency backend

## Metadata

- data: `2026-06-03`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `backend-schema`
- mode_scope: `multi-mode`
- branch: `codex/draxos-mobile/latency-backend`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--latency-backend`

## Objetivo

Reduzir latencia percebida nos endpoints de estado do DraxosMobile por paralelizacao segura de leituras independentes, payloads leves e metadata de timing sem alterar autoridade server-side.

## Latest Context

- latest Arena loop package: `Track 21 - Arena Loop Unlock And Friction Pass`
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`

## Base Lida

- `D:\Estudio\AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `canon/canon-brief.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/contracts/api-endpoints.md`
- `Projetos/draxos-mobile/docs/contracts/database-schema.md`

## Escopo

- Incluir:
  - `Projetos/draxos-mobile/server/functions/**`
  - `Projetos/draxos-mobile/supabase/functions/**`
  - `Projetos/draxos-mobile/server/tests/**`
  - `Projetos/draxos-mobile/docs/contracts/api-endpoints.md` e `database-schema.md` somente se houver mudanca contratual
- Fora do escopo:
  - client shell, presenters, `modes/boot`, `online/*.gd` e testes client;
  - worktrees de outros agentes;
  - remote mutation, publicacao, upload, deploy ou `supabase db push`;
  - tuning, economia, PVP ou conteudo novo sem decisao explicita.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/server/functions/account/**`
- `Projetos/draxos-mobile/server/functions/arena/**`
- `Projetos/draxos-mobile/server/functions/modes/**`
- `Projetos/draxos-mobile/server/functions/base/**`
- `Projetos/draxos-mobile/server/functions/build/**`
- `Projetos/draxos-mobile/server/functions/crafting/**`
- `Projetos/draxos-mobile/server/functions/social/**`
- `Projetos/draxos-mobile/server/functions/competition/**`
- `Projetos/draxos-mobile/server/functions/monetization/**`
- mirrors equivalentes em `Projetos/draxos-mobile/supabase/functions/**`
- testes Deno direcionados em `Projetos/draxos-mobile/server/tests/**`

## Validation Plan

- `git diff --check`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- testes Deno direcionados para endpoints/contratos alterados, se existentes

## Handoff Point

Entregar resumo dos endpoints otimizados, riscos de contrato/API, comandos de validacao e qualquer necessidade descoberta para os agentes client-shell, mutations/deltas ou telemetry antes de integracao.
