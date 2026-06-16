# Track 09H - Web Heap Hotfix

Data: `2026-06-15`

## Objetivo

Validar um hotfix curto para recuperar margem de heap apos a publicacao candidata 09G falhar duas vezes no gate remoto de estabilidade 5min.

## Mudanca Testada

- `football_match_resolution_controller.gd`: `update_match_clock()` deixou de chamar `resolve_timer_state()` a cada frame do timer.
- O caminho de fim do tempo agora usa diretamente `match_time_remaining`, `player_score`, `bot_score` e `golden_goal_active`, preservando a mesma regra: empate entra em `golden_goal`; vencedor por placar encerra a partida.
- Nenhuma mudanca intencional em gameplay, bot, fisica, scoring, tuning, HUD, assets ou publicacao.

## Gates Locais

| Gate | Resultado |
| --- | --- |
| Import Godot headless | PASS |
| `tools/validate.gd` | PASS, `104` testes / `1826` asserts, `55` fontes |
| Web export release | PASS |
| `tools/validate.gd` pos-export | PASS, Web gzip `30.60 MiB / 50.00 MiB`, raw `63.06 MiB`, `9` arquivos |
| Chrome short stability 120s | PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`, heap final `+0.26%` |
| Chrome stability 5min | PASS, heap final `+6.81%` contra limite `10%`, pico transitorio `+12.73%`, counters/caches Godot estaveis, pior janela 5s `140.2 FPS` |

## Evidencias

- `docs/playtest-reports/track-09h-data/09h-local-short-stability.json`
- `docs/playtest-reports/track-09h-data/09h-local-short-stability.png`
- `docs/playtest-reports/track-09h-data/09h-local-stability-5min.json`
- `docs/playtest-reports/track-09h-data/09h-local-stability-5min.png`
- `docs/playtest-reports/track-09h-data/09h-publication-report-4a323fab.json`
- `docs/playtest-reports/track-09h-data/09h-remote-menu-4a323fab.json`
- `docs/playtest-reports/track-09h-data/09h-remote-first-minute-4a323fab.json`
- `docs/playtest-reports/track-09h-data/09h-remote-stability-5min-4a323fab.json`
- `docs/playtest-reports/track-09h-data/09h-remote-night-luma-gate-4a323fab.json`

## Interpretacao

- O bug remoto da 09G nao se manifestou como vazamento de nodes, objetos Godot, caches de material/mesh ou memoria de video.
- A 09H removeu uma alocacao repetida por frame no clock do timer, que era uma fonte real de churn e deixava a margem Web dependente demais do ritmo de GC.
- O resultado local 5min voltou a ficar dentro do limite e a publicacao remota 09H confirmou a correcao sem reabrir os gates da 09G.
- A margem remota ficou verde, mas apertada: heap final `+9.97%` contra limite `<10%`; manter a estabilidade 5min obrigatoria para cada publicacao.

## Publicacao Remota

Track 09H foi publicada como `Super Campeao v1.2.1+4a323fab`, release root `web/v1-copa-arena-futebol-20260615-4a323fab`, preview `https://7f8dcde1.copa-arena-futebol.pages.dev`.

| Gate remoto | Resultado |
| --- | --- |
| Menu | PASS, release root conferiu, `menu.ready.end`, erros `0` |
| Primeiro minuto | PASS, `event.visible_match_start`, `firstMinuteHitches=0`, erros `0` |
| Stability 5min | PASS, heap `43,664,158 -> 48,016,205` bytes (`+9.97%`), counters/caches estaveis, pior janela 5s `129.8 FPS` |
| Luma noturna | PASS, `luma_0_255=6.525 < 90` |

## Proximo Gate

Antes de qualquer nova reducao de `FootballRoot`, fazer reteste humano da build publica 09H.
