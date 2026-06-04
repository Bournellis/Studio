# DraxosMobile Hardening Done: backend-schema - Bosque V2 Guidance Persistence

## Metadata

- data: `2026-06-04`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `backend-schema`
- mode_scope: `openworld`
- branch: `codex/draxos-mobile/bosque-v2-backend`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-v2-backend`
- cleanup: worktree removida em `2026-06-04`; branch preservada como ref nao ancestral/superseded.

## Objetivo

Persistir estado leve de guidance do Bosque Mecanico Basico v2 no save normal, com evento idempotente `guidance_update` e inclusao em snapshot/patch/state/resume sem alterar recompensa, economia ou autoridade de conclusao.

## Latest Context

- latest Arena loop package: `Track 21 - Arena Loop Unlock And Friction Pass`
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`

## Base Lida

- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/data/definitions/openworld/forest_ruleset_v1.json`

## Escopo

- Incluir:
  - migration server/supabase para normalizar guidance em `game_saves.snapshot.openworld.forest.guidance`;
  - wiring server/supabase de `guidance_update` em Openworld modes;
  - testes backend relevantes de Openworld/modes.
- Fora do escopo:
  - cliente Godot;
  - docs/produto fora deste card/handoff;
  - worktrees de outros agentes;
  - remote mutation/publicacao;
  - `supabase db push`;
  - tuning, economia, PVP ou conteudo novo sem decisao explicita.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/server/schema/migrations/*`
- `Projetos/draxos-mobile/supabase/migrations/*`
- `Projetos/draxos-mobile/server/functions/modes/*`
- `Projetos/draxos-mobile/supabase/functions/modes/*`
- `Projetos/draxos-mobile/server/tests/*`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-04_codex_draxos-mobile_bosque-v2-backend.md`
- `08_Coordenacao_Agentes/Handoffs/2026-06-04_codex_draxos-mobile_bosque-v2-backend.md`

## Validation Plan

- `git diff --check`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- targeted Deno tests for Openworld/modes contracts

## Handoff Point

Handoff quando migrations, mirrors, handlers e testes estiverem alinhados e commitados, com nota para a lane de client/guidance consumir `guidance` no snapshot/patch/state/resume sem depender de persistence especial fora do save normal.
