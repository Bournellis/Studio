# T04 - DraxosMobile Console Warning Cleanup

- Data: `2026-05-27`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/t04-console-warnings`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t04-console-warnings`
- Status: `DONE_READY_TO_MERGE`

## Objetivo

Remover warnings de console introduzidos pela integracao dos presenters Track 04: parametro nao usado em presenter de Base e codigo inalcancavel em delegates de `boot.gd`.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/boot.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/base_surface_presenter.gd`
- Este registro Doing.

## Guardrails

- Nao alterar comportamento, endpoints, schema, economia ou simulador.
- Manter presenters render-only e `boot.gd` como orquestrador.

## Validacao Planejada

- `tools/validate.gd`
- `tools/smoke_session_shell.gd`
- `tools/smoke_battle_replay.gd`
- `git diff --check`

## Resultado

- `base_surface_presenter.gd`: parametro `host` nao usado renomeado para `_host`.
- `boot.gd`: blocos legados inalcancaveis removidos dos delegates para presenters.
- `tools/validate.gd`: OK, 60/60 testes, 417 asserts.
- `tools/smoke_session_shell.gd`: OK.
- `tools/smoke_battle_replay.gd`: OK.
- `git diff --check`: OK.

## Proximo Handoff

Merge/fast-forward no `master` se os warnings sumirem e a validacao seguir verde.
