# Track 09D - Football Match Flow Controller V1

- Data: `2026-06-15`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/jogodacopa/football-match-flow-controller-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--football-match-flow-controller-v1`
- Status: `LOCAL_VALIDADO`

## Resumo

Extraiu o fluxo de reset/kickoff/countdown/input lock/touch kickoff do `FootballRoot` para `football_match_flow_controller.gd`, mantendo o root como fachada para testes, capturas e helpers existentes.

## Resultado

- `FootballRoot`: `1588 -> 1472` linhas nesta base.
- Novo helper: `Projetos/JogoDaCopa/modes/football/football_match_flow_controller.gd`.
- Sem alteracao de gameplay, input, bot, fisica, scoring ou assets.
- URL publica permanece `Super Campeao v1.2.1+ff9cb389`; a 09D e local validada e ainda nao publicada.

## Validacao

- Import Godot headless: PASS.
- `tools/validate.gd`: PASS, `104` testes, `1826` asserts, `52` fontes verificadas.
- Web export release: PASS.
- `tools/validate.gd` com build Web presente: PASS, Web gzip `30.60 MiB / 50.00 MiB`.
- Chrome boot local: PASS, `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Evidencia: `Projetos/JogoDaCopa/docs/playtest-reports/track-09d-data/09d-local-web-boot.json` e `.png`.

## Proximo Passo

Decidir publish da 09D ou seguir com a proxima reducao estreita do `FootballRoot`.
