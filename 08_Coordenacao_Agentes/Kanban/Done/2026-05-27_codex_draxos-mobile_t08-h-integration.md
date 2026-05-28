# T08-H - Integracao Track 08 Foundation Review And Hardening

- Data: `2026-05-27`
- Agente: `codex`
- Projeto: `draxos-mobile`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t08-integration`
- Branch: `codex/draxos-mobile/t08-integration`
- Base: `master` apos `T08-A` (`bd395cf`)
- Status: `DONE`

## Objetivo

Integrar as entregas `T08-B` a `T08-F`, criar o harness final `T08-G`, resolver conflitos e fechar a Track 08 como fundacao endurecida antes das proximas features/assets/servicos.

## Branches De Entrada

- `codex/draxos-mobile/t08-app-shell-lifecycle`
- `codex/draxos-mobile/t08-session-save-boundary`
- `codex/draxos-mobile/t08-mobile-ui-contract`
- `codex/draxos-mobile/t08-battle-mode-contract`
- `codex/draxos-mobile/t08-service-asset-contracts`

## Arquivos Previstos

- `Projetos/draxos-mobile/modes/boot/`
- `Projetos/draxos-mobile/online/`
- `Projetos/draxos-mobile/tests/client/`
- `Projetos/draxos-mobile/tools/`
- `Projetos/draxos-mobile/server/tests/`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/`
- `08_Coordenacao_Agentes/`
- `Projetos/README.md`

## Validacao Planejada

- `tools/validate.gd`
- GUT completo `res://tests/client`
- `tools/smoke_session_shell.gd`
- `tools/smoke_runtime_config.gd`
- `tools/smoke_mobile_presentation.gd`
- `tools/smoke_foundation_hardening.gd`
- `tools/smoke_foundation_surfaces.gd`
- `tools/smoke_battle_replay.gd`
- `tools/smoke_exports.gd`
- checks Deno quando aplicavel
- `git diff --check`

## Handoff

Branch integrada em `codex/draxos-mobile/t08-integration`, status/portfolio atualizados e validacao final registrada.

## Validacao Final

- `tools/validate.gd`: passou com GUT integrado `95/95` testes e `1114` asserts.
- GUT completo `res://tests/client`: passou com `95/95` testes e `1114` asserts.
- `tools/smoke_session_shell.gd`: passou.
- `tools/smoke_runtime_config.gd`: passou.
- `tools/smoke_mobile_presentation.gd`: passou.
- `tools/smoke_foundation_hardening.gd`: passou.
- `tools/smoke_foundation_surfaces.gd`: passou.
- `tools/smoke_battle_replay.gd`: passou com `BATTLE_FUNCTION_URL=http://127.0.0.1:8000` apos servir a funcao `battle` atual localmente.
- `tools/smoke_exports.gd`: passou.
- Checks Deno de `supabase/functions`, `server/functions` e `server/tests/foundation_contracts_test.ts`: passaram.
- `git diff --check`: passou.

## Observacao

A Edge Runtime local padrao em `127.0.0.1:54321` ainda estava servindo uma funcao `battle` antiga sem `/battle/history`; para o smoke de replay final, a funcao atual foi servida isoladamente e encerrada apos o teste.
