# Track 09F - Football Arcade Field Controller V1

- Data: `2026-06-15`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/jogodacopa/football-arcade-field-controller-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--football-arcade-field-controller-v1`
- Status: `LOCAL_VALIDADO`

## Resumo

Extraiu coleta, reset e update de boost pads e jump pads do `FootballRoot` para `football_arcade_field_controller.gd`, mantendo o root como fachada para testes, debug API e chamadas internas existentes.

## Resultado

- `FootballRoot`: `1362 -> 1295` linhas nesta base.
- Novo helper: `Projetos/JogoDaCopa/modes/football/football_arcade_field_controller.gd`.
- Sem alteracao de gameplay, input, bot, fisica, scoring, tuning ou assets.
- URL publica permanece `Super Campeao v1.2.1+ff9cb389`; a 09F e local validada e ainda nao publicada.

## Validacao

- Import Godot headless: PASS.
- `tools/validate.gd`: PASS, `104` testes, `1826` asserts, `54` fontes verificadas.
- Web export release: PASS.
- `tools/validate.gd` com build Web presente: PASS, Web gzip `30.59 MiB / 50.00 MiB`.
- Chrome boot local: PASS, `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Evidencia: `Projetos/JogoDaCopa/docs/playtest-reports/track-09f-data/09f-local-web-boot.json` e `.png`.

## Proximo Passo

Decidir publish da 09F ou seguir com a proxima reducao estreita do `FootballRoot`.
