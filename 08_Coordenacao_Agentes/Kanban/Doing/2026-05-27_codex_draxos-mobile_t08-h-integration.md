# T08-H - Integracao Track 08 Foundation Review And Hardening

- Data: `2026-05-27`
- Agente: `codex`
- Projeto: `draxos-mobile`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t08-integration`
- Branch: `codex/draxos-mobile/t08-integration`
- Base: `master` apos `T08-A` (`bd395cf`)
- Status: `DOING`

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

Entregar branch integrada, status/portfolio atualizados, validacao final registrada e worktree limpa ou com pendencias explicitamente listadas.
