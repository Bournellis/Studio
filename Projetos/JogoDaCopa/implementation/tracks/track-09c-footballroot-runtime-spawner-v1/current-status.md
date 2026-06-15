# Track 09C - FootballRoot Runtime Spawner V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/football-runtime-spawner-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--football-runtime-spawner-v1`
- Status: `LOCAL_VALIDADO`

## Objetivo

Continuar a reducao do `FootballRoot` sem alterar gameplay, fisica, input, bot, regras de partida, assets ou comportamento publico. A etapa 09C isolou a criacao e wiring dos nos de runtime em helper dedicado.

## Mudancas

- Novo helper: `modes/football/football_runtime_spawner.gd`.
- O helper passou a cuidar de:
  - criacao de `RuntimeRoot`;
  - player/controller, avatar do player e sensibilidade inicial;
  - bola e marcador de kickoff;
  - chase camera;
  - bot/controller e avatar do bot;
  - feedback controller;
  - HUD e conexoes de sinais;
  - coleta inicial de boost/jump pads e material count probe.
- `football_root.gd` ficou como fachada/orquestrador do ciclo da cena e delega o spawn completo do runtime.
- Teste de boot passou a validar tambem `RuntimeRoot/KickoffMarker`.
- `FootballRoot` medido nesta base: `1739 -> 1588` linhas.

## Validacao

- Import Godot headless: PASS.
- `tools/validate.gd`: PASS, `104` testes, `1826` asserts, `51` fontes verificadas.
- Web export release: PASS.
- `tools/validate.gd` com build Web presente: PASS, Web gzip `30.59 MiB / 50.00 MiB`.
- Web boot local via Chrome/CDP: PASS, `event.visible_match_start` visto, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Evidencia: `docs/playtest-reports/track-09c-data/09c-local-web-boot.json` e `.png`.

## Risco Residual

- Mudanca e estrutural, nao funcional. O risco principal era quebrar o wiring inicial de player/bot/bola/camera/HUD; coberto por compile/GUT, validate, Web export e boot local.
- URL publica segue em `v1.2.1+ff9cb389`; a 09C ainda nao foi publicada remotamente.
