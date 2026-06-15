# Track 09G - Football Match Resolution Controller V1

- Data: `2026-06-15`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/jogodacopa/football-match-resolution-controller-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--football-match-resolution-controller-v1`
- Status: `LOCAL_VALIDADO`

## Resumo

Extraiu a orquestracao de resolucao da partida do `FootballRoot` para `football_match_resolution_controller.gd`, mantendo o root como fachada para APIs de teste/debug e call sites existentes.

## Resultado

- `FootballRoot`: `1295 -> 1178` linhas nesta base.
- Novo helper: `Projetos/JogoDaCopa/modes/football/football_match_resolution_controller.gd` (`174` linhas).
- Escopo extraido: restart de partida, match mode, goal reset timer, deteccao/registro de gol, scoring side effects, timer/golden goal, fim de partida e stats de chute/gol.
- Sem alteracao de gameplay, input, bot, fisica, scoring, tuning, assets, HUD visual ou publicacao.
- URL publica permanece `Super Campeao v1.2.1+a75cfe57`; a 09G e local validada e ainda nao publicada.

## Validacao

- Import Godot headless: PASS.
- `tools/validate.gd`: PASS, `104` testes, `1826` asserts, `55` fontes verificadas.
- Web export release: PASS.
- `tools/validate.gd` com build Web presente: PASS, Web gzip `30.60 MiB / 50.00 MiB`, raw `63.06 MiB`, `9` arquivos.
- Chrome boot local: PASS, `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Evidencia: `Projetos/JogoDaCopa/docs/playtest-reports/track-09g-data/09g-local-web-boot.json` e `.png`.

## Proximo Passo

Review/decidir publish da 09G ou planejar a proxima reducao estreita do `FootballRoot`.
