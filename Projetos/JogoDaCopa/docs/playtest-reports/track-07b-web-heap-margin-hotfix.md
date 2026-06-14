# Track 07B - Web Heap Margin Hotfix

Data: `2026-06-14`

## Objetivo

Recuperar margem real no gate remoto de heap JS/WASM da Track 07 sem mudar gameplay. A publicacao `v1.2.0+138cf4f7` falhou por heap retido `+10.34%` contra limite `<10%`, apesar de menu, primeiro minuto, erros, nodes, caches, video memory e FPS estarem estaveis.

## Mudancas

- `tools/publish_web.ps1`: preserva o AudioWorklet global quando o navegador oferece suporte e aplica fallback silencioso apenas ao position worklet se `addModule()` falhar.
- `football_ball.gd`: a sombra extra de leitura da bola nao e criada no Web, retornando o contador de nodes Web ao perfil da baseline publica.
- `football_hud.gd`: cacheia a flag Web e os estilos do state badge para reduzir pequenas alocacoes repetidas em atualizacoes de HUD.

## Gates Locais

| Gate | Resultado |
| --- | --- |
| `tools/validate.gd` | PASS, `103` testes / `1844` asserts, source integrity `46` fontes |
| Menu Web local 30s | PASS, `pageErrors=0`, `consoleErrorCount=0`, `menu.ready.end` visto |
| Primeiro minuto Web local | PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0` |
| Estabilidade Web local 5min | PASS com limite interno `8%`; heap `45,682,151 -> 48,319,740` bytes (`+5.77%`), nodes `816 -> 816`, video memory estavel |

## Evidencias Locais

- `docs/playtest-reports/track-07b-data/07b-local-menu-audio-worklet.json`
- `docs/playtest-reports/track-07b-data/07b-local-first-minute.json`
- `docs/playtest-reports/track-07b-data/07b-local-stability-5min-margin.json`

## Proximo Gate

Commitar a hotfix, mergear em `main`, regenerar o pacote com o hash definitivo, publicar via `tools/publish_web.ps1 -Mode FullPublish -ConfirmRemoteMutation` e repetir menu remoto, primeiro minuto remoto, estabilidade remota 5min e luminancia noturna. Se qualquer gate remoto falhar, rollback imediato para `v1.1.0+be453dc3`.
