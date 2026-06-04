# DraxosMobile Hardening Doing: mode-scaffolds/platform-v1/client-shell - Bosque v2 Guidance

## Metadata

- data: `2026-06-04`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `mode-scaffolds | platform-v1 | backend-schema | client-shell | validation-release`
- mode_scope: `openworld`
- branch: `codex/draxos-mobile/bosque-v2-guidance`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-v2-guidance`

## Objetivo

Implementar Bosque Mecanico Basico v2 como modo livre e relaxante, com tutorial leve persistido no save normal, fogueira visual permanente, recursos fixos suficientes para Bolsa + Fogueira e validacao local sem publicacao remota.

## Latest Context

- latest Arena loop package: `Track 21 - Arena Loop Unlock And Friction Pass`
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`
- Openworld source: `docs/minigames/openworld.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/data/definitions/openworld/forest_ruleset_v1.json`

## Escopo

- Incluir:
  - documentacao viva do Bosque livre sem objetivo obrigatorio;
  - persistencia de guidance em save normal;
  - evento `guidance_update` no Mode Platform/Openworld;
  - HUD guidance discreto e reabertura pelo sheet;
  - `Encerrar visita` com resumo leve;
  - fogueira visual bloqueante persistente;
  - novos resource nodes fixos para Bolsa Simples I + Fogueira Estavel I;
  - testes client/server e smokes locais.
- Fora do escopo:
  - publicacao remota ou remote mutation;
  - inimigos, NPCs, quests, combate, cidade ou novo mapa;
  - respawn/procedural generation;
  - economia ampla, tuning numerico amplo, PVP, social ou nova recompensa.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/docs/minigames/openworld-objectives.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/data/definitions/openworld/forest_ruleset_v1.json`
- `Projetos/draxos-mobile/modes/openworld/*.gd`
- `Projetos/draxos-mobile/server/schema/migrations/*.sql`
- `Projetos/draxos-mobile/supabase/migrations/*.sql`
- `Projetos/draxos-mobile/server/functions/modes/*`
- `Projetos/draxos-mobile/supabase/functions/modes/*`
- `Projetos/draxos-mobile/tests/client/test_openworld_*.gd`
- `Projetos/draxos-mobile/server/tests/*openworld*`

## Validation Plan

- `git diff --check`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ModePlatform`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_openworld_forest.gd`

## Handoff Point

Handoff quando client, backend, docs e testes estiverem integrados na branch final, com validacoes locais registradas. Publicacao remota fica fora deste pacote ate aprovacao explicita.
