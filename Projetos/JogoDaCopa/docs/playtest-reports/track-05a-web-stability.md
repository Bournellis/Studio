# Track 05A - Web Stability Hotfix V1

Data: 2026-06-12

Branch: `codex/jogodacopa/track05a-web-stability-v1`

Objetivo: investigar a oscilacao ciclica de producao relatada por Fabio e tester externo em `https://copa-arena-futebol.pages.dev/`, separar vazamento retido de churn por frame e publicar hotfix Web V1 com gate permanente de estabilidade.

## Instrumentacao

- `tools/track04f_chrome_probe.mjs` passou a coletar amostras a cada 1s por partidas longas, incluindo `performance.memory`, heap WASM quando exposto por `WebAssembly.Memory`, hitches e janelas de FPS.
- `modes/shared/jdc_perf_probe.gd` passou a emitir `stability.sample` com `OBJECT_COUNT`, `OBJECT_RESOURCE_COUNT`, `OBJECT_NODE_COUNT`, `OBJECT_ORPHAN_NODE_COUNT`, `RENDER_TOTAL_OBJECTS_IN_FRAME`, `RENDER_VIDEO_MEM_USED`, `RENDER_TEXTURE_MEM_USED`, particulas/transients vivos e contadores extras de caches.
- `football_field_builder.gd` e `runtime_primitive_factory.gd` passaram a expor contadores dos caches estaticos criados na Track 04F.2.
- O cenario `jdc_perf_scenario=1` roda partida continua variada: jogo real, chute, gol, pause, confetti, resultado e rematch.

## Baseline antes do fix

Artefatos brutos: `docs/playtest-reports/track-05a-data/`.

| Probe | Duracao | p95 / p99 | Hitches apos 60s | JS heap apos 60s | Godot stability samples | Observacao |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `05a-remote-prod-baseline-5min.json` | 310s | 7.0 / 7.1 ms | 0 | 116.7 MB -> max 172.8 MB -> 120.0 MB | 0 | Producao sem instrumentacao Godot nova; pageErrors eram pointer-lock do modo de captura. |
| `05a-local-instrumented-baseline-5min.json` | 310s | 7.0 / 7.1 ms | 0 | 117.8 MB -> max 168.7 MB -> 123.6 MB | 282 | Com `jdc_perf=1`; material/node/particle counters estaveis. |
| `05a-local-no-jdc-perf-control-120s.json` | 130s | 7.0 / 7.1 ms | 0 | 115.6 MB -> max 116.0 MB -> 105.5 MB | 0 | Controle sem `jdc_perf`; heap JS estavel. |

Nota: `05a-local-no-jdc-perf-control-5min.png` foi gerado, mas a execucao de 5 min sem `jdc_perf` nao retornou JSON antes do timeout do comando. O controle de 120s foi mantido como amostra sem instrumentacao para isolar o proprio probe.

## Contadores Godot apos warmup

Amostra: `05a-local-instrumented-baseline-5min.json`, janela apos 60s.

| Contador | Primeiro | Max | Ultimo | Delta |
| --- | ---: | ---: | ---: | ---: |
| `object_count` | 3222 | 3277 | 3222 | 0 |
| `object_resource_count` | 74 | 74 | 74 | 0 |
| `object_node_count` | 766 | 771 | 766 | 0 |
| `object_orphan_node_count` | 0 | 0 | 0 | 0 |
| `static_cache_total_entries` | 144 | 144 | 144 | 0 |
| `runtime_standard_material_cache` | 68 | 68 | 68 | 0 |
| `runtime_glass_material_cache` | 4 | 4 | 4 | 0 |
| `runtime_box_mesh_cache` | 68 | 68 | 68 | 0 |
| `field_net_material_cache` | 1 | 1 | 1 | 0 |
| `field_crowd_material_cache` | 1 | 1 | 1 | 0 |
| `field_flag_material_cache` | 1 | 1 | 1 | 0 |
| `field_halo_material_cache` | 1 | 1 | 1 | 0 |
| `feedback_active_effects` | 0 | 5 | 0 | 0 |
| `live_particle_nodes` | 6 | 8 | 6 | 0 |
| `live_emitting_particles` | 0 | 2 | 0 | 0 |
| `live_transient_nodes` | 9 | 13 | 9 | 0 |
| `live_feedback_nodes` | 1 | 4 | 1 | 0 |
| `render_video_mem_used` | 242603518 | 242665798 | 242603518 | 0 |
| `render_texture_mem_used` | 227116112 | 227116112 | 227116112 | 0 |

## Root cause antes do fix

Suspeitos verificados:

- Cache de materiais da 04F.2 com chave instavel: descartado. Todos os caches ficaram constantes apos warmup (`static_cache_total_entries=144`, runtime material/mesh caches constantes).
- Transients de VFX/audio sem `queue_free`: descartado como vazamento retido. `OBJECT_NODE_COUNT`, `live_transient_nodes` e `live_feedback_nodes` voltaram ao baseline apos picos esperados de evento.
- Particulas/trails acumulando emissores: descartado como vazamento retido. `live_particle_nodes` voltou a 6 e `live_emitting_particles` voltou a 0.
- Probe acumulando dados: confirmado apenas no harness. Com `jdc_perf=1`, o browser heap cresce por logs/amostras do probe; com `jdc_perf` desligado, o controle de 120s fica estavel. Esse crescimento nao existe no jogo publicado normal.

Causa raiz de producao tratada no hotfix: churn continuo no loop quente de `FootballRoot._process`.

Antes do fix, cada frame de partida executava:

- `hud.update_snapshot(_build_hud_snapshot())`, criando um `Dictionary` novo e varias strings formatadas por frame.
- `_update_stadium_scoreboards()`, formatando textos de placar/fase por frame para dois SubViewports.
- `FootballHud.update_snapshot()`, reatribuindo textos e valores mesmo quando o conteudo nao mudava.

Esse padrao nao aparece como crescimento monotonicamente retido em nodes/materiais porque o lixo e coletavel. Em Web single-threaded, especialmente em maquinas mais fracas, ele cria pressao de GC suficiente para explicar o ciclo relatado de alguns segundos lisos seguidos por alguns segundos quase frame a frame.

## Fix aplicado

- HUD snapshot e placares de estadio passaram para cadencia de 0.1s, mantendo fisica, input, timers e VFX por frame.
- O HUD passou a evitar reatribuicao de texto/ProgressBar quando o valor novo e identico ao valor atual.
- O modo de captura/probe deixou de tentar pointer lock, removendo `WrongDocumentError` do smoke automatizado.
- O menu principal passou a exibir `Copa Arena Futebol v1.0.1+<hash curto>` no rodape e removeu `PC Windows editor-first`.
- `publish_web.ps1` passa a gerar `build/release_info.json` durante o export para embutir versao/hash no pacote Web.

## Gate permanente

O smoke Chrome aceita `--stability-gate=1` e falha quando, apos 60s de warmup:

- crescimento retido final de JS+WASM heap excede 10% (pico de heap continua registrado como diagnostico de GC);
- contadores de nodes/objetos/caches/memoria de video deixam de ficar estaveis;
- qualquer janela de 5s tem FPS medio abaixo de 30.

## Validacao local pos-fix

Artefato: `docs/playtest-reports/track-05a-data/05a-local-stability-gate-5min-pass.json`.

| Gate | Resultado |
| --- | --- |
| Smoke Chrome 5 min | PASS |
| Runtime errors | `pageErrors=0`, `consoleErrorCount=0` |
| Frames | `frameCount=42643`, `p95=7.0ms`, `p99=7.1ms` |
| Heap JS+WASM retido | `124976879 -> 127790476 bytes`, crescimento `2.25%` |
| Heap peak diagnostico | `182502827 bytes`, pico `46.03%` antes de GC |
| Contadores Godot | PASS, `object_node_count 766 -> 766`, `static_cache_total_entries 144 -> 144` |
| FPS 5s | PASS, pior janela `139.6 FPS` |

Comando local esperado:

```powershell
node tools/track04f_chrome_probe.mjs --chrome="C:\Program Files\Google\Chrome\Application\chrome.exe" --web-dir="builds/web" --route="/index.html?jdc_capture=play&jdc_perf=1&jdc_perf_scenario=1" --out-dir="docs/playtest-reports/track-05a-data" --label=05a-local-stability-gate-5min --duration-ms=310000 --sample-interval-ms=1000 --stability-gate=1 --headless=0 --http-port=8068 --cdp-port=9235 --screenshot-at-ms=60000 --fail-on-runtime-errors=1
```

Comando remoto esperado apos publicacao:

```powershell
node tools/track04f_chrome_probe.mjs --chrome="C:\Program Files\Google\Chrome\Application\chrome.exe" --url="https://copa-arena-futebol.pages.dev/index.html?jdc_capture=play&jdc_perf=1&jdc_perf_scenario=1" --out-dir="docs/playtest-reports/track-05a-data" --label=05a-remote-stability-gate-5min --duration-ms=310000 --sample-interval-ms=1000 --stability-gate=1 --headless=0 --cdp-port=9236 --screenshot-at-ms=60000 --fail-on-runtime-errors=1
```
