# DraxosMobile Done: multi-mode - Bosque Fogueira Potion Crafting v1

## Metadata

- data: `2026-06-06`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `backend-schema + client-shell + validation-release`
- mode_scope: `multi-mode`
- branch: `codex/draxos-mobile/bosque-fogueira-potion-crafting-v1`
- worktree: `D:\Estudio-worktrees\draxos-mobile--validation--bosque-fogueira-potion-v1`
- status: `PRE_RELEASE_VALIDATED`

## Objetivo

Implementar Bosque Fogueira Potion Crafting v1, transformando a Fogueira Estavel I em estacao server-authoritative para pocoes globais sem quebrar o Bosque offline-first.

## Latest Context

- latest mobile package: `Bosque Durable Bau Mochila v1`
- openworld policy source: `docs/minigames/openworld.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v0.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/behavior-potion-crafting-v1.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`

## Escopo

- Incluir:
  - station craft backend/RPC/Edge Function;
  - potion definitions and mixed-domain recipes;
  - Bosque Fogueira UI and checkpoint-before-craft client flow;
  - Arena potion equip/simulation generalization;
  - contracts, docs, validation, release package.
- Fora do escopo:
  - PVP;
  - mapa novo;
  - inimigos ou combate no Bosque;
  - economia premium;
  - tuning amplo fora das receitas simples aprovadas.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/data/definitions/`
- `Projetos/draxos-mobile/server/`
- `Projetos/draxos-mobile/supabase/`
- `Projetos/draxos-mobile/modes/openworld/`
- `Projetos/draxos-mobile/modes/boot/`
- `Projetos/draxos-mobile/online/`
- `Projetos/draxos-mobile/tests/`
- `Projetos/draxos-mobile/docs/`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Validation Plan

- `npx -y deno task --cwd server/functions check`
- targeted server tests for crafting/modes/battle
- Godot GUT Openworld/Arena targeted tests
- `tools/validate.gd`
- `tools/validate_foundation.ps1 -Profile ServerQuick`
- `tools/validate_foundation.ps1 -Profile ClientQuick`
- `tools/validate_foundation.ps1 -Profile ReleaseDryRun -RequireClean`
- `git diff --check`

## Validation Evidence

- `tools/check_foundation_expansion_readiness.ps1 -ProjectDir .`: PASS.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`: PASS.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: PASS, including `tools/validate.gd`, GUT client, runtime/config/layout/mode/export smokes.
- `ReleaseDryRun`: pending rerun after moving this card out of `Doing`.

## Handoff Point

Handoff final apos commits logicos, merge em `main`, publicacao Web/APK Internal Alpha e registro de evidencias no current status/portfolio.
