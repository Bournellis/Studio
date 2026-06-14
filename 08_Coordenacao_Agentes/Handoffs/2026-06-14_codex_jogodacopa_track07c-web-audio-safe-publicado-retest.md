# Handoff - JogoDaCopa Track 07C Web Audio Safe Publicado

- Data: 2026-06-14
- Agente: Codex
- Projeto: `Projetos/JogoDaCopa`
- Branch/merge local: `main` em `fa82cb7d`
- Release publicado: `v1.2.0+fa82cb7d`
- URL publica: `https://copa-arena-futebol.pages.dev/`
- Release root: `web/v1-copa-arena-futebol-20260614-fa82cb7d`

## Resultado

Track 07C publicada com sucesso. A hotfix restaurou o fallback Web Audio seguro no pacote publicado e adiou o carregamento dos streams reais de audio no Web ate a ativacao do navegador. Sem mudanca de gameplay.

## Gates

- `tools/validate.gd`: PASS, `103` testes / `1844` asserts.
- Menu remoto: PASS operacional, `menu.ready.end` visto, release root conferiu, `pageErrors=0`, `consoleErrorCount=0`, rodape `v1.2.0+fa82cb7d`.
- Primeiro minuto remoto: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Estabilidade remota 5min: PASS, heap retido `44,847,036 -> 48,303,228` bytes (`+7.71%`, limite `<10%`), counters/caches estaveis, pior janela 5s `130.2 FPS`.
- Luminancia noturna: PASS, `luma_0_255=6.69 < 90`.

## Evidencias

- `Projetos/JogoDaCopa/docs/playtest-reports/track-07c-data/07c-publication-report.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-07c-data/07c-remote-menu-user-url-fa82cb7d.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-07c-data/07c-remote-first-minute-fa82cb7d.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-07c-data/07c-remote-stability-5min-fa82cb7d.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-07c-data/07c-remote-night-luma-gate-fa82cb7d.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-07c-web-audio-safe-hotfix.md`

## Pedido De Retest Humano

Fabio + tester externo devem retestar a URL publica `https://copa-arena-futebol.pages.dev/`:

- Menu broadcast e rodape `v1.2.0+fa82cb7d`.
- ESC completo, incluindo restart com confirmacao.
- HUD scorebug, STAMINA/SUPER e legibilidade durante a partida.
- Primeiro minuto de jogo no navegador real.
- Sensacao geral do visual polish v1.2.0, sem regressao de audio/menus.

`PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`
