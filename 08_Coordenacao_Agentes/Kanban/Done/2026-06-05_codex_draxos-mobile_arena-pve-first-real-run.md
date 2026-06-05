# Done - DraxosMobile Arena PVE First Real Run

## Metadata

- data: `2026-06-05`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/arena-pve-first-real-run`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-pve-first-real-run`
- base: `master` @ `fa59157`
- status: `READY_FOR_COMMIT_MERGE_PUBLICATION`
- pacote: `Track 23 - Arena PVE First Real Run + Update Recovery`
- publicacao_remota: `APROVADA_PELO_USUARIO_NESTE_PEDIDO`

## Objetivo

Implementar a proxima fase da Arena PVE como primeira run real de 3 duelos, com fluxo de tentativa completo e recuperacao segura quando um update deixa uma arena aberta incompativel ou inacessivel.

## Entregue

- Contrato do shell com `arena_resume_attempt` e `arena_abandon_attempt`.
- Roteamento idempotente para `/arena/pve/abandon`.
- Dispatcher/facade/lifecycle com retomar tentativa, abandono e guarda local antes de iniciar nova arena.
- Selecao de Arena bloqueia nova tentativa quando existe `active_attempt` e oferece `Retomar tentativa`, `Abandonar tentativa` ou `Encerrar tentativa antiga`.
- Tentar resolver duelo em tentativa antiga/incompativel volta para recovery em vez de manter o jogador preso.
- Dev fixture simula abandono terminal sem recompensa de conclusao.
- Testes client/server cobrem recovery, abandono e primeira arena real de 3 duelos.

## Validacao Local

- `git diff --check`: PASS.
- `deno test --allow-read server/tests/arena_loop_unlock_friction_test.ts`: PASS, 6 tests.
- `Godot GUT client suite`: PASS, 229 tests.
- `validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ModePlatform -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: primeira tentativa BLOCKED somente por card Doing ativo; card movido para Done para repetir.

## Handoff

Pronto para commit, merge em `master`, export/package/upload/deploy/manifest e validacao remota na URL principal.
