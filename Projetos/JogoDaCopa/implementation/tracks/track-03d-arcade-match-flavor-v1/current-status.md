# Track 03D - Arcade Match Flavor V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_TRACK_03D_ARCADE_MATCH_FLAVOR_V1_COMPLETE`
- Branch: `codex/jogodacopa/track03-arcade-series-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03-arcade-series-v1`

## Goal

Adicionar climax de partida arcade com announcer visual, modo timer, golden goal, vale-2 e emote pos-gol, mantendo o modo `3 gols` inalterado e regras de placar/fim centralizadas em helper puro.

## Delivered

- Menu principal ganhou seletor de modo com default `3 minutos` e opcao `3 gols`.
- `FootballMatchRules` concentra valor de gol, vale-2, golden goal e encerramento por timer.
- `FootballRoot` controla relogio de 180s, ativa golden goal em empate no fim do tempo e encerra por placar quando ha lider.
- Gol nos ultimos 30s do modo timer vale 2; modo `3 gols` continua primeiro a 3.
- HUD mostra `MM:SS`, destaca ultimos 30s/golden goal e tem announcer visual com fila sem sobreposicao.
- `T` dispara emote pos-gol; bot provoca automaticamente quando marca; feedback usa confete procedural.
- Testes cobrem input `arcade_emote`, menu timer default, golden goal, vale-2 so no modo timer/janela final e regressao do modo `3 gols`.

## Validation

- `tools/validate.gd`: PASS, 45 tests, 403 asserts.
- Known noise: GUT UID/text-path warnings during validation.

## Out Of Scope

- Toon look experiment.
- Assets externos ou audio authored.
- Power-ups classicos de campo.

## Next Step

Implementar `Track 03E - Toon Look Experiment V1`.
