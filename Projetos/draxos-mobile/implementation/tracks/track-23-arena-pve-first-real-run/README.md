# Track 23 - Arena PVE First Real Run + Update Recovery

- Status: `IMPLEMENTED_LOCAL`
- Data: `2026-06-05`
- Projeto: `draxos-mobile`
- Branch: `codex/draxos-mobile/arena-pve-first-real-run`
- Escopo: client Arena PVE, recovery de tentativa ativa antiga, primeira arena real de 3 duelos, docs e publicacao Internal Alpha.

## Objetivo

Fechar a proxima fase da Arena PVE sem expandir PVP ou Openworld:

- manter o tutorial como 1 duelo;
- preservar a primeira arena real como 3 duelos com buff entre vitorias;
- impedir que uma tentativa ativa antiga bloqueie o jogador depois de updates;
- oferecer caminhos explicitos de `Retomar tentativa`, `Abandonar tentativa` e `Encerrar tentativa antiga`;
- manter recompensas server-authoritative e sem economia no abandono.

## Entrega Local

- `ACTION_ARENA_RESUME_ATTEMPT` e `ACTION_ARENA_ABANDON_ATTEMPT` entram no contrato de shell.
- `arena/pve/abandon` entra no roteador de mutacoes idempotentes.
- Dispatcher/facade chamam `resume_attempt` e `abandon_attempt`.
- Lifecycle:
  - roteia tentativa ativa para active/buff/summary conforme estado;
  - detecta tentativa incompatavel ou sem proximo passo valido;
  - barra start local quando existe tentativa ativa;
  - chama `SupabaseClient.abandon_arena_attempt` com `request_id/request_hash`.
- Presenter:
  - selecao bloqueia nova arena quando existe tentativa ativa;
  - mostra painel `ArenaActiveAttemptPanel` para retomar/abandonar;
  - mostra painel `ArenaAttemptRecoveryPanel` para encerrar tentativa antiga;
  - adiciona abandono nas telas active e buff.
- Dev fixture passa a simular abandono terminal sem recompensa.

## Validacao Local

- `deno test --allow-read server/tests/arena_loop_unlock_friction_test.ts`: PASS, 6 tests.
- `Godot GUT client suite`: PASS, 229 tests.
- `validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ModePlatform -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: PASS after moving the active Doing card to Done, as required by release safety.

## Publicacao

Pendente ate merge em `master` e execucao do pipeline Internal Alpha aprovado pelo usuario.
