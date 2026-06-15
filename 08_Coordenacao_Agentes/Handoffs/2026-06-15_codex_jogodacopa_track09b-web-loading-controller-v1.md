# Handoff - JogoDaCopa Track 09B Web Loading Controller

## Contexto

- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/jogodacopa/footballroot-web-loading-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--footballroot-web-loading-v1`
- Base publica preservada: `Super Campeao v1.2.1+ff9cb389`
- Status: `LOCAL_VALIDADO`

## Resultado

- `FootballRoot` teve o bloco Web loading/warmup extraido para `modes/football/football_web_loading_controller.gd`.
- O root agora delega overlay, progresso, warmup de primeiro render, warmup de primeiros usos, settle probes e buckets de warmup.
- `FootballRoot` medido nesta base caiu de `2078` para `1739` linhas.
- Nenhuma mudanca de gameplay, fisica, input, bot, regras de partida, assets ou publicacao remota.
- Teste `test_web_loading_overlay_keeps_public_label_fixed` atualizado para validar o helper novo.

## Validacao

- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`: PASS, `104` testes, `1825` asserts, `50` fontes.
- Web export release: PASS.
- `tools/validate.gd` com build Web presente: PASS, Web gzip `30.58 MiB / 50.00 MiB`.
- Web boot local: PASS, `event.visible_match_start` visto, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.

## Evidencias

- `Projetos/JogoDaCopa/implementation/tracks/track-09b-footballroot-web-loading-controller-v1/current-status.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09b-data/09b-local-web-boot.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09b-data/09b-local-web-boot.png`

## Proximo Passo

- Fazer merge local se aprovado e continuar a serie de reducao do `FootballRoot` com outra extracao estreita.
- Publicacao remota nao executada nesta track.
- PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
