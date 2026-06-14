# Handoff - JogoDaCopa Track 06G Countdown Direto E Restart Confirmado V1

- Data: `2026-06-13`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/JogoDaCopa/track06g-countdown-restart-flow-v1`
- Main final: `be453dc3`
- Release publico: `v1.1.0+be453dc3`
- Release root: `web/v1-copa-arena-futebol-20260613-be453dc3`
- URL publica: `https://copa-arena-futebol.pages.dev/`
- Status: `PUBLICADO_RETEST_HUMANO_PENDENTE`

## Entrega

- Countdown de kickoff direto: `3 -> 2 -> 1 -> VAI!`.
- Restart direto por `R` removido.
- Reinicio agora exige ESC/pause menu + `Reiniciar partida...` + `Confirmar reinicio`.
- Sem mudanca de fisica, bot, camera, scoring ou tuning de gameplay.

## Gates Finais

- `tools/validate.gd`: PASS, `103` testes / `1842` asserts.
- Primeiro minuto remoto: `docs/playtest-reports/track-06g-data/06g-remote-first-minute-be453dc3.json`, PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Estabilidade remota 5min: `docs/playtest-reports/track-06g-data/06g-remote-stability-5min-be453dc3.json`, PASS, heap `+9.03%`, nodes/caches estaveis.
- Menu URL real: `docs/playtest-reports/track-06g-data/06g-remote-menu-user-url-be453dc3.json`, PASS, `pageErrors=0`, root `be453dc3`.
- Luminancia noturna: `docs/playtest-reports/track-06g-data/06g-remote-night-luma-gate-be453dc3.json`, PASS, `17.413 < 90`.

## Retest Humano Pedido

Fabio + tester externo devem retestar na URL publica:

- menu broadcast e rodape `v1.1.0+be453dc3`;
- ESC menu completo;
- restart com confirmacao;
- countdown direto no kickoff inicial e pos-gol;
- HUD scorebug;
- primeiro minuto jogavel.

## Git

`PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`
