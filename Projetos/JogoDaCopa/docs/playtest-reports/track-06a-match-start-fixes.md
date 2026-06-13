# Track 06A - Match Start Fixes V1

- Data: `2026-06-13`
- Branch: `codex/jogodacopa/track06a-match-start-fixes-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track06a`
- Objetivo: corrigir kickoff inicial/pos-gol, remover hints/crosshair do HUD em jogo e preservar a mira funcional existente.

## Escopo

- Countdown: um unico disparo por kickoff inicial e por kickoff pos-gol.
- Facing: player e bot iniciam olhando para o oponente no primeiro frame jogavel, no kickoff inicial e apos gol.
- HUD: `HintLabel` e `FootballCrosshair` removidos da partida; comandos preservados em `FootballHud.CONTROL_HINTS`.
- Gameplay preservado: sem mudanca em fisica da bola, movimento, camera, kick assist, input de chute ou contratos de tap/hold.

## Causa Raiz Do Countdown

Teste vermelho inicial mediu:

| Caso | Esperado | Medido antes do fix |
| --- | ---: | ---: |
| Kickoff inicial | `1` | `2` |
| Kickoff pos-gol | `1` | `1` |

A duplicacao vinha do boot/warmup: `_ready_sync()` e `_ready_web_async()` chamavam `_restart_play(false)` quando `intro_open == false`, e `_restart_play()` iniciava countdown. Depois, ao apertar `Comecar`, `_start_match()` iniciava outro countdown para o mesmo kickoff inicial.

Fix aplicado:

- `_restart_play(after_goal, start_countdown := true)` recebeu flag explicita.
- Boot e warmup usam `_restart_play(false, false)`.
- `_start_match()` continua sendo o disparo unico do countdown inicial.
- Reset pos-gol permanece usando `_restart_play(true)` e dispara exatamente uma vez.

## Evidencia De Gameplay

Script: `tools/capture_track06a_match_start.gd`

- Cena: janela real 1920x1080, `Copa Arena Futebol`, render desktop Forward+.
- Roteiro: menu, start com countdown, kickoff, fim manual do countdown, corrida em 4 frames, chute, gol, HUD limpo.
- Inputs/acoes simuladas: `debug_start_match_with_countdown()`, `debug_finish_kickoff_countdown()`, `debug_release_bot_kickoff_hold()`, deslocamento controlado do player, `_on_player_kick_requested()`, `_process_goal_detection()`.
- Gate noturno: `WorldEnvironment` com ACES/BG_SKY e luminancia de amostra `< 90.0` em escala 0-255.

| Imagem | Checklist | Luma |
| --- | --- | ---: |
| `docs/screenshots/track-06a/menu.png` | PASS, menu capturado antes da partida | n/a |
| `docs/screenshots/track-06a/kickoff-facing-hud-clean.png` | PASS, kickoff com player de costas para camera, bot a frente e HUD sem faixa de hints/crosshair | `46.6` |
| `docs/screenshots/track-06a/hud-no-hints-no-crosshair.png` | PASS, frame especifico comprovando ausencia visual de hints/crosshair | `46.6` |
| `docs/screenshots/track-06a/run-frame-01.png` | PASS, sequencia de corrida/facing | n/a |
| `docs/screenshots/track-06a/run-frame-02.png` | PASS, sequencia de corrida/facing | n/a |
| `docs/screenshots/track-06a/run-frame-03.png` | PASS, sequencia de corrida/facing | n/a |
| `docs/screenshots/track-06a/run-frame-04.png` | PASS, sequencia de corrida/facing | n/a |
| `docs/screenshots/track-06a/kick-moment.png` | PASS, chute preservado visualmente | n/a |
| `docs/screenshots/track-06a/goal.png` | PASS, gol capturado em camera broadcast alta sem quebrar gate noturno | `64.9` |

Observacao: a primeira versao da camera de gol enquadrava vidro/neon perto demais e gerou falsa falha de luma (`218.x`). A captura final usa camera alta de broadcast para medir o ambiente noturno no topo da imagem.

## Web Boot Local

Probe: `tools/track04f_chrome_probe.mjs`

Comando final:

```powershell
node tools\track04f_chrome_probe.mjs --chrome="C:\Program Files\Google\Chrome\Application\chrome.exe" --web-dir=builds/web --out-dir=docs/playtest-reports/track-06a-data --label=06a-web-boot --duration-ms=32000 --screenshot-at-ms=26000 --route="/index.html?jdc_capture=kickoff&jdc_perf=1" --http-port=8091 --cdp-port=9231 --fail-on-runtime-errors=1 --expected-stage=event.visible_match_start
```

Resultado:

- Evidencia: `docs/playtest-reports/track-06a-data/06a-web-boot.json`
- Screenshot: `docs/playtest-reports/track-06a-data/06a-web-boot.png`
- PASS: `expectedStageSeen=true`, `pageErrors=0`, `consoleErrorCount=0`.
- Frame stats do smoke: `frameCount=4109`, `p99=7.1ms`, `max=3055.9ms` durante carregamento.
- Long gates de primeiro minuto/5min nao fazem parte da 06A; ficam para a 06E conforme plano da serie.

## Gates Locais

| Gate | Resultado |
| --- | --- |
| Teste vermelho inicial | FAIL util: kickoff inicial mediu `2` disparos de countdown; pos-gol mediu `1` |
| GUT focado apos fix | PASS, `91` testes / `1298` asserts |
| Validate full final | PASS, `91` testes / `1298` asserts, Web gzip `30.32 MiB / 50.00 MiB`, source integrity `37` arquivos |
| Export Web release final | PASS com `GODOT_THREADS_ENABLED=false` |
| Chrome boot local | PASS, screenshot tardio apos `event.visible_match_start`, page/runtime errors `0` |
| Captura desktop real | PASS, menu/kickoff/corrida/chute/gol/HUD limpo gerados |

Falhas uteis:

| Tentativa | Resultado | Correcao |
| --- | --- | --- |
| Primeiro export Web em worktree novo | FAIL porque `builds/web/` nao existia | Criado diretorio local e export final passou |
| Primeiro `goal.png` | FAIL luma `218.x` | Camera de gol ajustada para enquadramento broadcast alto |
| Primeiro `hud-no-hints-no-crosshair.png` pos-gol | FAIL luma `214.1` por capturar no estado iluminado do gol | Evidencia de HUD limpo movida para kickoff/jogo normal |
| Web smoke com screenshot em `12000ms` | PASS tecnico, mas imagem ainda em aquecimento | Refeito com `26000ms`, `jdc_perf=1` e `event.visible_match_start` |

## Status

Track 06A implementada e validada localmente. Branch deve parar pre-merge para review visual de Claude e aprovacao de Fabio.

Linha de status: `PASS - 91 testes / 1298 asserts - export Web PASS - web boot local PASS - captura desktop PASS`.

