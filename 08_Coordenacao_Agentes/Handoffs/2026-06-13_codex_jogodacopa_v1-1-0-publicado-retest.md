# Handoff - JogoDaCopa v1.1.0 Publicado / Retest Humano

- Data: `2026-06-13`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa`
- Status: `PUBLICADO_RETEST_HUMANO_PENDENTE`
- URL publica: `https://copa-arena-futebol.pages.dev/`
- Versao publica: `v1.1.0+22850c06`
- Release root: `web/v1-copa-arena-futebol-20260613-22850c06`

## Resumo

06F foi aprovada, mergeada em `main` e republicada pela decisao Cloudflare com `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260613-22850c06 -ConfirmRemoteMutation`. A regressao remota da 06E foi corrigida sem mudanca de gameplay.

## Gates Remotos

- Primeiro minuto: `docs/playtest-reports/track-06f-data/06f-remote-first-minute-22850c06.json`, PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Estabilidade 5min: `docs/playtest-reports/track-06f-data/06f-remote-stability-5min-22850c06.json`, PASS, heap retido `+1.14%`, nodes/caches estaveis, pior janela 5s `105.2 FPS`.
- Luminancia: `docs/playtest-reports/track-06f-data/06f-remote-night-luma-gate-22850c06.json`, PASS, `10.3 < 90`.
- Rodape do menu: `docs/playtest-reports/track-06f-data/06f-remote-menu-footer-22850c06.png`, mostra `Copa Arena Futebol v1.1.0+22850c06 | sem logos oficiais`.

## Pedido De Retest

Fabio + tester externo devem testar a URL publica `v1.1.0`, focando:

- menu broadcast e seletores;
- ESC completo com controles/audio/video/sensibilidade;
- HUD scorebug, relogio, badges, STAMINA/SUPER;
- primeiro minuto de partida, kickoff/countdown, input, chute, gol e sensacao geral.

06E/06F so encerram subjetivamente apos esse veredito humano.

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin
