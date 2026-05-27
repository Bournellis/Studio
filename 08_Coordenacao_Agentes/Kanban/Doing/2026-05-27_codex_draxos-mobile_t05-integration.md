# T05-H - DraxosMobile Track 05 Integration

- Data: `2026-05-27`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/t05-integration`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t05-integration`
- Status: `IN_PROGRESS`

## Objetivo

Integrar as entregas T05-B a T05-G da Track 05, resolver conflitos, validar a fundacao completa e atualizar status sem alterar gameplay, economia, schema, assets finais ou servicos novos.

## Branches De Entrada

- `codex/draxos-mobile/t05-validation-matrix`
- `codex/draxos-mobile/t05-hub-foundation`
- `codex/draxos-mobile/t05-service-contracts`
- `codex/draxos-mobile/t05-asset-pipeline`
- `codex/draxos-mobile/t05-progression-human-pack`
- `codex/draxos-mobile/t05-release-ops`

## Validacao Planejada

- `tools/validate.gd`
- GUT client completo
- `tools/smoke_session_shell.gd`
- `tools/smoke_battle_replay.gd`
- `tools/smoke_dev_labs.gd`
- `tools/smoke_dev_lab_ui.gd`
- `tools/smoke_exports.gd`
- `tools/smoke_foundation_surfaces.gd`
- Deno checks de `supabase/functions` e `server/functions`
- `deno check`/`deno lint` de `release_artifacts_remote_smoke.ts`
- `git diff --check`

## Guardrails

- Manter `players.save_type`.
- Nao criar migration `account_profiles` + `game_saves`.
- Nao alterar contratos HTTP, economia, ranking, simulador, monetizacao real, assets finais ou servicos novos.
- Registrar qualquer bloqueio de validacao em vez de esconder falha.
