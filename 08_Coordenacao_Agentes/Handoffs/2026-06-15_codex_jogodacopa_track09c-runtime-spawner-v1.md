# Handoff - JogoDaCopa Track 09C Runtime Spawner V1

## Contexto

- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/jogodacopa/football-runtime-spawner-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--football-runtime-spawner-v1`
- Base publica preservada: `Super Campeao v1.2.1+ff9cb389`
- Status: `LOCAL_VALIDADO`

## Resultado

- `FootballRoot` teve a criacao/wiring de runtime extraida para `modes/football/football_runtime_spawner.gd`.
- O helper agora cria `RuntimeRoot`, player/controller, avatar do player, bola, marcador de kickoff, chase camera, bot/controller, avatar do bot, feedback controller e HUD.
- O helper tambem conecta os sinais iniciais, aplica sensibilidade inicial e coleta boost/jump pads para manter o contrato de bootstrap.
- `FootballRoot` medido nesta base caiu de `1739` para `1588` linhas.
- Nenhuma mudanca de gameplay, fisica, input, bot, regras de partida, assets ou publicacao remota.
- Teste de boot passou a validar `RuntimeRoot/KickoffMarker`.

## Validacao

- Import Godot headless: PASS.
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`: PASS, `104` testes, `1826` asserts, `51` fontes.
- Web export release: PASS.
- `tools/validate.gd` com build Web presente: PASS, Web gzip `30.59 MiB / 50.00 MiB`.
- Web boot local: PASS, `event.visible_match_start` visto, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.

## Evidencias

- `Projetos/JogoDaCopa/implementation/tracks/track-09c-footballroot-runtime-spawner-v1/current-status.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09c-data/09c-local-web-boot.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09c-data/09c-local-web-boot.png`

## Proximo Passo

- Fazer merge local se aprovado e decidir entre publish da 09C ou continuar a serie de reducao do `FootballRoot`.
- Publicacao remota nao executada nesta track.
- PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
