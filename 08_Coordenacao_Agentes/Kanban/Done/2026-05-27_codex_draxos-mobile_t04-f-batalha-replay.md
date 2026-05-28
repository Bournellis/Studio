# T04-F - DraxosMobile Batalha/Replay

- Data: `2026-05-27`
- Agente sugerido: `Codex`
- Branch sugerida: `codex/draxos-mobile/t04-batalha-replay`
- Worktree sugerida: `D:\Estudio-worktrees\draxos-mobile--codex--t04-batalha-replay`
- Status: `DONE_INTEGRATED`

## Objetivo

Extrair renderizacao e controles da aba Batalha para presenter render-only.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/boot.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/`
- Testes client de batalha/replay, se precisar cobrir a superficie extraida.

## Guardrails

- Preservar `BattleLogPresenter`, `BattleVisualMockup` e `BattleStage2D`.
- Nao alterar battle simulator, reward, `battle_log_v1` ou endpoints `battle/*`.

## Validacao Planejada

- `tools/smoke_battle_replay.gd`
- GUT de battle visual/stage
- `git diff --check`

## Proximo Handoff

Entregar Batalha/Replay render-only sem regressao no replay server-authoritative.
