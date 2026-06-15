# Handoff - JogoDaCopa Track 09A Publicado

## Contexto

- Projeto: `Projetos/JogoDaCopa`
- Release publico: `Super Campeao v1.2.1+ff9cb389`
- URL publica: `https://copa-arena-futebol.pages.dev/`
- Release root: `web/v1-copa-arena-futebol-20260615-ff9cb389`
- Deploy final: `https://17ea99ce.copa-arena-futebol.pages.dev`

## Resultado Tecnico

- Track 09A foi mergeada e publicada sem mudanca de gameplay, fisica, input, bot, regras de partida ou assets.
- `FootballRoot` ficou menor (`2280 -> 1862` linhas) apos extrair ambiente noturno, capture director, placares do estadio e perf scenario para helpers dedicados.
- `tools/validate.gd`: PASS (`104` testes / `1825` asserts).
- Web export/package/publicacao Cloudflare Pages: PASS; Web gzip `30.58 MiB / 50.00 MiB`.
- Menu remoto: PASS, root conferiu, `menu.ready.end` visto, `pageErrors=0`, `consoleErrorCount=0`.
- Primeiro minuto remoto: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Estabilidade remota 5min: PASS, heap retido `+8.37%`, counters/caches estaveis, pior janela 5s `116.8 FPS`.
- Luminancia noturna remota: PASS, `luma_0_255=6.525 < 90`.

## Evidencias

- `Projetos/JogoDaCopa/docs/playtest-reports/track-09a-data/09a-publication-report-ff9cb389.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09a-data/09a-remote-menu-ff9cb389.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09a-data/09a-remote-first-minute-ff9cb389.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09a-data/09a-remote-stability-5min-ff9cb389.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09a-data/09a-remote-night-luma-gate-ff9cb389.json`

## Pedido De Retest Humano

Fabio + tester externo devem retestar na URL publica:

- Tela inicial/loading e footer `Super Campeao v1.2.1+ff9cb389`.
- Menu principal, seletores e uniformes.
- Menu ESC, confirmacao de reinicio, volumes e qualidade.
- HUD/scorebug durante partida.
- Primeiro minuto de jogo real, incluindo primeiro gol e feedback visual leve.

## Proximo Passo

Track 09A fica funcionalmente pendente apenas do veredito humano na URL publica.

