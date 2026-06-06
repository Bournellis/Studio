# DraxosMobile Hardening Doing: client-shell - Bosque Offline-First Checkpoint v1

## Metadata

- data: `2026-06-05`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `client-shell`
- mode_scope: `openworld`
- branch: `codex/draxos-mobile/bosque-checkpoint-client`
- worktree: `D:\Estudio-worktrees\draxos-mobile--client--bosque-checkpoint-v1`

## Objetivo

Tornar o Bosque client-owned durante o gameplay e server-owned apenas para checkpoints, reward e conclusao, sem rollback visual por ACK/resync tardio.

## Latest Context

- latest published package: `Bosque Sync Responsiveness v1`
- current stage: `BOSQUE_SYNC_RESPONSIVENESS_V1_PUBLISHED_INTERNAL_ALPHA`
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- openworld source: `docs/minigames/openworld.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/docs/foundation-app-v0-audit.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`

## Escopo

- Incluir:
  - Bridge/checkpoint client do Openworld Bosque.
  - Cache local por save/session/ruleset usando SessionStore ou cache seguro local.
  - HUD/status/tooltips para salvo localmente, salvando checkpoint e recompensa pendente.
  - Testes client focados em Openworld.
- Fora do escopo:
  - worktrees de outros agentes;
  - server/migrations/docs de contrato, salvo se indispensavel;
  - remote mutation/publicacao;
  - tuning, economia, PVP, conteudo novo ou expansao ampla do Openworld.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/openworld/*.gd`
- `Projetos/draxos-mobile/online/session_store.gd`
- `Projetos/draxos-mobile/online/session/*`
- `Projetos/draxos-mobile/online/supabase_client.gd`
- `Projetos/draxos-mobile/tests/client/test_openworld*.gd`

## Validation Plan

- `git diff --check`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/client/test_openworld_integrated_session_bridge.gd -gtest=res://tests/client/test_openworld_mode_dev.gd -gexit`

## Handoff Point

Entregue e integrado na branch final `codex/draxos-mobile/bosque-offline-first-checkpoint-v1`, depois publicado em `main`.

## Resultado

- Bridge Openworld passou a checkpoint/offline-first durante gameplay normal.
- Cache local do Bosque persistido em `SessionStore.openworld_local_state`.
- Coleta, deposito, craft, guidance e posicao ficam locais durante a visita.
- ACK/resync tardio da mesma sessao nao transforma o mundo renderizado.
- `Encerrar visita` exige checkpoint aceito para reward.
- Validacao focada de client Openworld: PASS.
