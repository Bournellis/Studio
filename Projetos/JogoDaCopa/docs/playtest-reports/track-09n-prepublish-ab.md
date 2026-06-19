# Track 09N - Prepublish A/B Against 09I

- Data: 2026-06-19
- Branch: `codex/jogodacopa/track09n-render-settings-controller-v1`
- Publicacao: nao realizada nesta track.
- Baseline publico aprovado: Track 09I, `Super Campeao v1.2.1+7995b06c`, `web/v1-copa-arena-futebol-20260616-7995b06c`.
- Candidata: Track 09N local, `football_render_settings_controller.gd`.

## Objetivo

Executar a comparacao pre-publicacao recomendada apos a Track 09M: validar o baseline remoto aprovado 09I e a candidata local 09N usando o probe Chrome com gate primario `js_heap_growth`.

## Matriz

| Run | Alvo | Gate | Release root | Resultado |
|---|---|---:|---|---|
| `09n-ab-09i-remote-5min` | Producao 09I remota | PASS | `web/v1-copa-arena-futebol-20260616-7995b06c` | Baseline aprovado continua saudavel |
| `09n-ab-09n-local-5min` | Build local 09N | PASS | n/a local | Candidata liberada para publicacao tentativa |

## Evidencias

| Metrica | 09I remoto aprovado | 09N local candidata |
|---|---:|---:|
| `event.visible_match_start` | true | true |
| Page errors | `0` | `0` |
| Console errors | `0` | `0` |
| Console warnings | `56` | `56` |
| First-minute hitches | `0` | `0` |
| Stability samples browser/Godot | `319 / 305` | `317 / 305` |
| `js_heap_growth` final | `-5.32%` | `+9.25%` |
| Pico de `js_heap_growth` | `+1.79%` | `+16.17%` |
| `total_js_heap_growth` final | `-16.29%` | `-3.48%` |
| Alias legado `js_wasm_heap_growth` | `-5.32%` | `+9.25%` |
| `wasmSampleCount` | `0` | `0` |
| p50 / p95 / p99 frame | `6.90 / 7.00 / 7.10 ms` | `6.90 / 7.10 / 7.10 ms` |

Arquivos:

- Baseline remoto JSON: `track-09n-ab-data/09n-ab-09i-remote-5min.json`
- Baseline remoto screenshot: `track-09n-ab-data/09n-ab-09i-remote-5min.png`
- Candidata local JSON: `track-09n-ab-data/09n-ab-09n-local-5min.json`
- Candidata local screenshot: `track-09n-ab-data/09n-ab-09n-local-5min.png`

## Decisao

Pre-publicacao aprovada para a Track 09N.

A 09I remota confirmou o baseline publico aprovado e a 09N local passou no mesmo gate primario de estabilidade. A candidata ficou perto do teto final de `js_heap_growth` (`+9.25%` contra limite de `+10%`) e teve pico temporario acima do limite final (`+16.17%`), mas o gate configurado e final-pos-warmup/final-GC e passou.

## Recomendacao

- Prosseguir para merge/publicacao tentativa da 09N.
- Apos publicar, repetir os gates remotos completos: menu, primeiro minuto, estabilidade 5min e luma.
- Se a estabilidade remota pos-deploy falhar ou ficar sem margem, restaurar producao para 09I e abrir hotfix/investigacao antes de qualquer nova reducao.
