# DraxosMobile - Openworld Sync Stability

- Data: 2026-06-03
- Agente: Codex
- Lane: mode-scaffolds / platform-v1 / backend-schema / client-shell / validation-release
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/openworld-sync-stability`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--openworld-sync-stability`
- Objetivo: corrigir rollback e desencontro client/server do Openworld Bosque, revisar o contrato generico de ACK de eventos de modos e validar que o mesmo padrao nao seja herdado por modos futuros.

## Contexto

- Latest published package: `FIRST_ACCESS_RUNTIME_PUBLISHED_INTERNAL_ALPHA`.
- Latest release root: `internal-alpha/v0-first-access-runtime-20260602-4608977`.
- Previous runtime fix package: `Integrated Runtime Fix` (`ab5834c`).
- Openworld active ruleset: `openworld_forest_ruleset_v1`.
- Platform/modes source: `docs/contracts/minigame-platform-v1.md`.
- Openworld source: `docs/minigames/openworld.md`.

## Escopo Entregue

- Contrato generico diferencia snapshot de estado, ACK de evento e resultado de complete.
- `POST /modes/session/event` agora retorna `mode_event_ack` com `snapshot_patch`, `revision_after`, campos autoritativos e autoridade visual explicita.
- ACK de evento nao hidrata mais snapshot completo durante gameplay ativo, evitando snapback de posicao e cancelamento visual de coleta em andamento.
- Client Bosque aplica patch autoritativo apenas para inventario/economia/recompensa/campos derivados; posicao local continua mandando durante a sessao ativa.
- Coleta confirmada pelo servidor limpa pendencias somente quando o node aparece em `collected_nodes`.
- Conflito stale/resync usa mensagem discreta de produto.
- Mirrors `server/` e `supabase/` foram mantidos identicos para `modes` e `_shared/mode_domain.ts`.
- Testes de contrato e GUT cobrem ACK atrasado, rollback de posicao, coleta em andamento e pending visual ate ACK.
- Publicacao remota, upload, deploy, manifest remoto, migration remota e `-ConfirmRemoteMutation` nao foram executados.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `08_Coordenacao_Agentes/Templates/DraxosMobile_Hardening_Doing_TEMPLATE.md`

## Arquivos Alterados

- `Projetos/draxos-mobile/docs/contracts/minigame-platform-v1.md`
- `Projetos/draxos-mobile/docs/contracts/minigame-integration.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/server/functions/_shared/mode_domain.ts`
- `Projetos/draxos-mobile/server/functions/modes/mode_handler.ts`
- `Projetos/draxos-mobile/supabase/functions/_shared/mode_domain.ts`
- `Projetos/draxos-mobile/supabase/functions/modes/mode_handler.ts`
- `Projetos/draxos-mobile/server/tests/modes_domain_test.ts`
- `Projetos/draxos-mobile/server/tests/modes_platform_schema_test.ts`
- `Projetos/draxos-mobile/modes/openworld/openworld_forest_screen.gd`
- `Projetos/draxos-mobile/modes/openworld/openworld_forest_model.gd`
- `Projetos/draxos-mobile/tests/client/test_openworld_mode_dev.gd`

## Validacao

- `git diff --check`: PASS.
- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- `npx -y deno test --allow-read server/tests/modes_domain_test.ts server/tests/modes_platform_schema_test.ts`: PASS.
- `Godot --headless --import`: PASS.
- GUT `test_openworld_mode_dev`: PASS, `25/25`, `107` asserts.
- `tools/smoke_openworld_forest.gd`: PASS.
- `tools/smoke_modes_visual_layout.gd`: PASS.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: PASS on rerun; first run had a known unrelated navigation flake in `tools/validate.gd`, while the same run's GUT matrix passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`: PASS.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ModePlatform`: PASS.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: PASS.

## Handoff

Handoff final registrado em `08_Coordenacao_Agentes/Handoffs/2026-06-03_codex_draxos-mobile_openworld-sync-stability.md`.
