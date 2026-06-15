# JogoDaCopa - Track 09B Web Loading Controller V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/footballroot-web-loading-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--footballroot-web-loading-v1`
- Status: `LOCAL_VALIDADO`

## Resultado

- Extraido `modes/football/football_web_loading_controller.gd`.
- `FootballRoot` agora delega loading overlay, progresso, warmup Web de primeiro render, warmup de primeiros usos e settle probes.
- `FootballRoot` medido nesta base: `2078 -> 1739` linhas.
- Sem alteracao de gameplay, input, fisica, bot, regras de partida, assets ou publicacao remota.
- Teste do overlay Web retargetado para o helper novo.

## Validacao

- `tools/validate.gd`: PASS, `104` testes, `1825` asserts, `50` fontes.
- Web export release: PASS.
- `tools/validate.gd` com build Web presente: PASS, Web gzip `30.58 MiB / 50.00 MiB`.
- Web boot local via Chrome/CDP: PASS, `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.

## Evidencias

- `Projetos/JogoDaCopa/implementation/tracks/track-09b-footballroot-web-loading-controller-v1/current-status.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09b-data/09b-local-web-boot.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09b-data/09b-local-web-boot.png`
- `08_Coordenacao_Agentes/Handoffs/2026-06-15_codex_jogodacopa_track09b-web-loading-controller-v1.md`

## Handoff

- Proxima reducao recomendada: extrair outra fatia estreita de orquestracao do `FootballRoot`, mantendo gameplay e assets intactos.
- Publicacao remota nao executada nesta track.
- PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
