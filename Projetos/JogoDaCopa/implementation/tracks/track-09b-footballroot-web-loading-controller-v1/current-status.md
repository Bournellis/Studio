# Track 09B - FootballRoot Web Loading Controller V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/footballroot-web-loading-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--footballroot-web-loading-v1`
- Status: `LOCAL_VALIDADO`

## Objetivo

Reduzir o tamanho do `FootballRoot` sem alterar gameplay, fisica, input, bot, regras de partida, assets ou comportamento publico. A etapa 09B isolou o fluxo Web de loading/warmup em helper dedicado.

## Mudancas

- Novo helper: `modes/football/football_web_loading_controller.gd`.
- O helper passou a cuidar de:
  - overlay de loading Web;
  - progresso do loading;
  - warmup de primeiro render;
  - warmup de primeiros usos de feedback;
  - espera de estabilidade/settle do loading;
  - classificacao e coleta de buckets de warmup.
- `football_root.gd` ficou como orquestrador do fluxo Web e passou a delegar para o helper.
- Teste existente `test_web_loading_overlay_keeps_public_label_fixed` foi retargetado para o novo contrato.
- `FootballRoot` medido nesta base: `2078 -> 1739` linhas.

## Validacao

- `tools/validate.gd`: PASS, `104` testes, `1825` asserts, `50` fontes verificadas.
- Web export release: PASS.
- `tools/validate.gd` com build Web presente: PASS, Web gzip `30.58 MiB / 50.00 MiB`.
- Web boot local via Chrome/CDP: PASS, `event.visible_match_start` visto, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Evidencia: `docs/playtest-reports/track-09b-data/09b-local-web-boot.json` e `.png`.

## Risco Residual

- Mudanca e estrutural, nao funcional. O risco principal era quebrar o fluxo Web async; coberto por compile/GUT, validate, Web export e smoke local do loading.
- URL publica segue em `v1.2.1+ff9cb389`; a 09B ainda nao foi publicada remotamente.
