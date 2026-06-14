# Handoff - JogoDaCopa Track 08A Super Campeao Publicado

## Contexto

- Projeto: `Projetos/JogoDaCopa`
- Release publico: `Super Campeao v1.2.1+6ef3074c`
- URL publica: `https://copa-arena-futebol.pages.dev/`
- Release root: `web/v1-copa-arena-futebol-20260614-6ef3074c`
- Deploy final: `https://3ad7e578.copa-arena-futebol.pages.dev`

## Resultado Tecnico

- Track 08A corrigiu o hitch remoto da tentativa Track 08 sem mudar gameplay.
- Hotfix: no Web, contatos da bola nao tentam audio 3D ja desativado; UI SFX silenciam sem telemetria enquanto audio do navegador esta bloqueado; confetti Web de gol foi reduzido para marcador visual leve.
- `tools/validate.gd`: PASS (`104` testes / `1825` asserts).
- Web export/package/publicacao Cloudflare Pages: PASS.
- Menu remoto: PASS, root conferiu, rodape visivel `Super Campeao v1.2.1+6ef3074c`.
- Primeiro minuto remoto: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Estabilidade remota 5min: PASS, heap retido `+7.34%`, counters/caches estaveis, `pageErrors=0`, `consoleErrorCount=0`.
- Luminancia noturna remota: PASS, `luma_0_255=6.525 < 90`.

## Evidencias

- `Projetos/JogoDaCopa/docs/playtest-reports/track-08a-data/08a-publication-report-6ef3074c.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-08a-data/08a-remote-menu-6ef3074c.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-08a-data/08a-remote-first-minute-6ef3074c.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-08a-data/08a-remote-stability-5min-6ef3074c.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-08a-data/08a-remote-night-luma-gate-6ef3074c.json`

## Pedido De Retest Humano

Fabio + tester externo devem retestar na URL publica:

- Tela inicial/loading: apenas `Super Campeao` e barra.
- Menu principal: nome `Super Campeao`, botao `Jogar`, seletores e uniformes sem textos removidos.
- Menu ESC: controles/confirmacao de reinicio/volumes/qualidade.
- HUD/scorebug durante partida.
- Primeiro minuto de jogo real, incluindo primeiro gol e feedback visual leve.

## Proximo Passo

Track 08 so encerra funcionalmente apos veredito humano do Fabio + tester externo.
