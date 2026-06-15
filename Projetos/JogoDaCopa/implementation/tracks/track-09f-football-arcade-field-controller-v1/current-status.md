# Track 09F - Football Arcade Field Controller V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/football-arcade-field-controller-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--football-arcade-field-controller-v1`
- Status: `LOCAL_VALIDADO`

## Objetivo

Continuar a reducao do `FootballRoot` sem alterar gameplay, fisica, input, bot, scoring, tuning, assets ou comportamento publico. A etapa 09F isolou os sistemas de campo arcade em helper dedicado.

## Mudancas

- Novo helper: `modes/football/football_arcade_field_controller.gd`.
- O helper passou a cuidar de:
  - coleta e reset de boost pads;
  - respawn e restauracao de stamina dos boost pads;
  - cooldown e launch dos jump pads;
  - repasse de targets de boost pad para o bot;
  - visibilidade/metadados ativos dos pads.
- `football_root.gd` ficou como fachada para os pontos ainda usados por testes, debug API e chamadas internas.
- `FootballRoot` medido nesta base: `1362 -> 1295` linhas.

## Validacao

- Import Godot headless: PASS.
- `tools/validate.gd`: PASS, `104` testes, `1826` asserts, `54` fontes verificadas.
- Web export release: PASS.
- `tools/validate.gd` com build Web presente: PASS, Web gzip `30.59 MiB / 50.00 MiB`.
- Web boot local via Chrome/CDP: PASS, `event.visible_match_start` visto, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Evidencia: `docs/playtest-reports/track-09f-data/09f-local-web-boot.json` e `.png`.

## Risco Residual

- Mudanca e estrutural, nao funcional. O risco principal era quebrar coleta/respawn de boost pads, coleta do bot ou launch/cooldown de jump pads; coberto por compile/GUT, validate, Web export e boot local.
- URL publica segue em `v1.2.1+ff9cb389`; a 09F ainda nao foi publicada remotamente.
