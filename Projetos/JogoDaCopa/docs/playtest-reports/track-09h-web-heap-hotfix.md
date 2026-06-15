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

## Interpretacao

- O bug remoto da 09G nao se manifestou como vazamento de nodes, objetos Godot, caches de material/mesh ou memoria de video.
- A 09H removeu uma alocacao repetida por frame no clock do timer, que era uma fonte real de churn e deixava a margem Web dependente demais do ritmo de GC.
- O resultado local 5min voltou a ficar dentro do limite, mas a publicacao segue pendente: a confirmacao definitiva exige uma candidata remota 09H.

## Proximo Gate

Antes de qualquer nova reducao de `FootballRoot`, publicar/retestar a 09H como candidata e exigir:

- menu remoto PASS;
- primeiro minuto remoto PASS;
- estabilidade remota 5min PASS;
- luma remota PASS.
