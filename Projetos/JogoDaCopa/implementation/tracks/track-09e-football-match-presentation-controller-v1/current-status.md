# Track 09E - Football Match Presentation Controller V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/football-match-presentation-controller-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--football-match-presentation-controller-v1`
- Status: `LOCAL_VALIDADO`

## Objetivo

Continuar a reducao do `FootballRoot` sem alterar gameplay, fisica, input, bot, scoring, assets ou comportamento publico. A etapa 09E isolou a apresentacao de partida em helper dedicado.

## Mudancas

- Novo helper: `modes/football/football_match_presentation_controller.gd`.
- O helper passou a cuidar de:
  - snapshot de HUD;
  - cadence de refresh do HUD e placares do estadio;
  - snapshot de resultado;
  - formatacao das estatisticas finais;
  - conversao de `country_kit_id` para codigo curto de uniforme.
- `football_root.gd` ficou como fachada para os pontos ainda usados por testes, capturas e helpers.
- `FootballRoot` medido nesta base: `1472 -> 1362` linhas.

## Validacao

- Import Godot headless: PASS.
- `tools/validate.gd`: PASS, `104` testes, `1826` asserts, `53` fontes verificadas.
- Web export release: PASS.
- `tools/validate.gd` com build Web presente: PASS, Web gzip `30.59 MiB / 50.00 MiB`.
- Web boot local via Chrome/CDP: PASS, `event.visible_match_start` visto, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Evidencia: `docs/playtest-reports/track-09e-data/09e-local-web-boot.json` e `.png`.

## Risco Residual

- Mudanca e estrutural, nao funcional. O risco principal era quebrar HUD, scoreboards, snapshot de resultado ou textos de estatistica; coberto por compile/GUT, validate, Web export e boot local.
- URL publica segue em `v1.2.1+ff9cb389`; a 09E ainda nao foi publicada remotamente.
