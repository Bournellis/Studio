# Track 09D - Football Match Flow Controller V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/football-match-flow-controller-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--football-match-flow-controller-v1`
- Status: `LOCAL_VALIDADO`

## Objetivo

Continuar a reducao do `FootballRoot` sem alterar gameplay, fisica, input, bot, scoring, assets ou comportamento publico. A etapa 09D isolou o fluxo de partida/kickoff/reset/countdown em helper dedicado.

## Mudancas

- Novo helper: `modes/football/football_match_flow_controller.gd`.
- O helper passou a cuidar de:
  - reset do play e alternancia de kickoff apos gol;
  - calculo de spawns de player, bot e bola no kickoff;
  - facing visual inicial dos avatares no kickoff;
  - lock/unlock de input durante countdown;
  - HUD/audio do countdown;
  - marcador visual de kickoff;
  - liberacao do hold defensivo do bot no primeiro toque do player;
  - registro de touch stats e ocultacao do marcador apos toque.
- `football_root.gd` ficou como fachada para os pontos ainda usados por testes, capturas e helpers.
- `FootballRoot` medido nesta base: `1588 -> 1472` linhas.

## Validacao

- Import Godot headless: PASS.
- `tools/validate.gd`: PASS, `104` testes, `1826` asserts, `52` fontes verificadas.
- Web export release: PASS.
- `tools/validate.gd` com build Web presente: PASS, Web gzip `30.60 MiB / 50.00 MiB`.
- Web boot local via Chrome/CDP: PASS, `event.visible_match_start` visto, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Evidencia: `docs/playtest-reports/track-09d-data/09d-local-web-boot.json` e `.png`.

## Risco Residual

- Mudanca e estrutural, nao funcional. O risco principal era quebrar reset/kickoff/countdown, travas de input, alternancia de saque ou liberacao do bot no primeiro toque; coberto por compile/GUT, validate, Web export e boot local.
- URL publica segue em `v1.2.1+ff9cb389`; a 09D ainda nao foi publicada remotamente.
