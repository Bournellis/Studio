# Track 07 - Visual Polish & Web-Safe Broadcast Pass

Data: `2026-06-14`

## Objetivo

Executar uma track visual grande sem pesar o Web: reduzir estouro de brilho/neon, melhorar leitura de bola/arena, fortalecer hero shot do menu, compactar HUD/pause/result e manter a experiencia dentro dos gates remotos ja usados pela familia 06.

## Mudancas

- Render profile: bloom/exposure/emissoes reduzidos em desktop e Web, mantendo Compatibility sem threads/shared array buffer.
- Arena: vidro mais transparente e menos emissivo, gramado mais escuro com vinheta, metas e frames menos estourados.
- Bola: shader dos paineis mais claro e sombra discreta de leitura no piso.
- HUD: scorebug mais compacto, aviso de gol com punch, painel de resultado menor e pausa/restart com confirmacao mais clara.
- Menu: preview 3D reposicionado como hero shot, avatar/bola mais presentes, luzes menos agressivas e versao publica promovida para `v1.2.0`.
- Publicacao: `tools/publish_web.ps1` passa a escrever evidencias em `docs/playtest-reports/track-07-data/`, injeta `v1.2.0+<hash>` e aplica patch de fallback Web Audio no export `index.js`.

## Gates Locais

| Gate | Resultado |
| --- | --- |
| `tools/validate.gd` | PASS, `103` testes / `1844` asserts, source integrity `46` fontes |
| Capturas `1920x1080`, `1366x768`, `1280x720` | PASS, menu/kickoff/goal/result/play/pause/restart confirmados |
| Luminancia noturna local | PASS, max `71.6 < 90` |
| Clique real | Coberto por `test_bootstrap.gd`, `test_menu_visual.gd` e `test_pause_menu.gd` |

## Evidencia Local

- Relatorio JSON: `docs/screenshots/track-07-visual-polish-web-safe/track07-visual-polish-report.json`.
- Menu: `track07-menu-hero-1920x1080.png`, `track07-menu-hero-1366x768.png`, `track07-menu-hero-1280x720.png`.
- Partida: `track07-kickoff-*`, `track07-goal-*`, `track07-play-*`, `track07-result-*`.
- Pausa/restart: `track07-pause-controls-*`, `track07-pause-restart-confirm-*`.

## Resultado De Publicacao

- Candidato `v1.2.0+138cf4f7` mergeado localmente em `main`.
- Menu remoto da URL publica: PASS, root `web/v1-copa-arena-futebol-20260614-138cf4f7`, `pageErrors=0`, `consoleErrorCount=0`.
- Primeiro minuto remoto: PASS, root correto, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Estabilidade remota 5min: FAIL por heap JS/WASM retido `+10.34%` contra limite `<10%`; contadores Godot, caches, memoria de video e FPS passaram.
- Rollback executado para `v1.1.0+be453dc3`; a URL publica nao deve ser retestada como `v1.2.0` ate um hotfix de heap passar o gate remoto.
