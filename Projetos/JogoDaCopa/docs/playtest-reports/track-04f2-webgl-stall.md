# Track 04F.2 - WebGL First-Render Stall V1

Data: 2026-06-12  
Branch: `codex/jogodacopa/track04f2-webgl-first-render-stall-v1`  
Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04f2-webgl-first-render-stall-v1`

## Objetivo

Foco unico: reduzir o stall de primeiro render/upload WebGL ao entrar na partida no Chrome local em primeira visita. A meta operacional do card era `Play -> overlay sai e partida jogavel <= 5s`, sem frame unico `> 1s` durante o loading.

## Baseline

Probe: `docs/playtest-reports/track-04f-data/04f2-a-baseline-web-click-materials.json`

| Medida | Valor |
| --- | ---: |
| p50 / p95 / p99 | 6.9ms / 7.0ms / 13.9ms |
| max frame | 18829.1ms |
| hitches > 50ms | 5 |
| ready depois do Play | 19.52s |
| material refs / unicos | 467 / 467 |
| Standard refs / Shader refs | 331 / 136 |
| variantes de shader estimadas | 24 |

Contagem por categoria na baseline confirmou a suspeita da review: a arena criava centenas de materiais unicos para geometria repetida. As maiores fontes eram estandes, torcida, banners, neon e vidro.

## Otimizacoes Medidas

| Passo | Mudanca | Resultado |
| --- | --- | --- |
| B1 | Cache/compartilhamento de materiais e meshes procedurais. | Retido. Materiais unicos `467 -> 79`; stall max `18.83s -> 8.16s`; ready `19.52s -> 8.81s`. |
| B2 | MultiMesh para torcida. | Revertido. Reduziu mesh refs, mas nao reduziu o stall (`8.17s`). |
| C1 | Warmup incremental completo de toda arena antes do overlay sair. | Revertido. Max caiu para `3.38s`, mas overlay subiu para `14.59s`. |
| C2 | Load threaded da cena. | Revertido. Sem ganho material contra C1. |
| C3 | BoxMesh unitario com scale por instancia. | Revertido. Piorou max/ready. |
| C4 | MultiMesh para estandes/skyline. | Revertido. Menos meshes, mas piorou max (`4.33s`) e ready. |
| C5 | Core warmup + decoracao diferida. | Revertido em favor de C7. Overlay `5.44s`; ainda acima da meta. |
| C6 | Remocao dos awaits finais do overlay. | Parcial. Overlay `3.58s`, mas primeiro vidro decorativo em background ainda fez `1202ms`. |
| C7 | C6 + prewarm dos 2 primeiros vidros antes do overlay. | Retido. Overlay `4.23s`; nenhum frame depois do Play passou de `1s`; maior frame apos Play foi `972ms` no vidro restante. |
| C8 | Cache de recursos VFX. | Revertido. Smoothness longo continuou falhando (`1271ms`). |
| C9 | Warmup visual explicito de VFX antes do overlay. | Revertido. Overlay subiu para `8.11s`. |
| C10 | Pool de GPUParticles3D. | Revertido. Smoothness longo continuou falhando (`1278ms`). |
| C11 | Warmup silencioso de audio recorrente. | Revertido. Warmup de audio levou `6907ms` e quebrou o loading. |

## Resultado Final Retido

Probe principal: `docs/playtest-reports/track-04f-data/04f2-c7-core-glass-prefetch-web-click.json`

| Medida | Baseline A | Final C7 |
| --- | ---: | ---: |
| p50 | 6.9ms | 6.9ms |
| p95 | 7.0ms | 7.0ms |
| p99 | 13.9ms | 7.1ms |
| max bruto do probe | 18829.1ms | 3667.3ms |
| ready depois do Play | 19.52s | 4.23s |
| overlay depois do Play | sem overlay marker | 4.23s |
| frame max entre Play e overlay | 18829.1ms | 972.4ms |
| hitches > 50ms | 5 | 21 |
| material refs / unicos | 467 / 467 | 467 / 79 |
| PCK | ~26.41 MiB pos-04F | 26.43 MiB |

Observacao sobre `max bruto`: o maior frame final do probe C7 (`3667.3ms`) terminou antes do `menu.play_pressed` e nao pertence a janela Play -> overlay. Dentro da janela de loading, o maior frame final ficou abaixo de 1s.

## Smoothness Longo

Probe: `docs/playtest-reports/track-04f-data/04f2-c7-post-warmup-120s-web-play.json`

| Medida | Valor |
| --- | ---: |
| Janela | 125s apos `web_warmup.deferred_render.end` |
| p50 / p95 / p99 | 6.9ms / 7.0ms / 7.1ms |
| max | 1298.8ms |
| hitches > 50ms | 4 |
| page errors | 1 (`WrongDocumentError` de pointer lock no Chrome headless/capture) |

Top hitches residuais:

| dt | Evento correlacionado | Leitura |
| ---: | --- | --- |
| 1298.8ms | `event.confetti_vfx` | Primeiro uso de confetti/VFX/audio pos-goal. |
| 1132.0ms | `event.kick_vfx` | Primeiro kick real no cenario de performance. |
| 187.5ms | `event.kick_vfx` | Kick posterior. |
| 152.9ms | `event.kick_vfx` | Kick posterior. |

Status: o gate de smoothness longo permanece `FAIL` por VFX/audio transiente. As tentativas C8-C11 foram revertidas por nao melhorarem ou por quebrarem o loading. Este residual nao e o stall de primeiro render da arena diagnosticado na 04F; recomendo tratar em track separada focada em VFX/audio first-use.

## Gates

| Gate | Resultado |
| --- | --- |
| Baseline antes de mudanca | PASS |
| Contagem de materiais/shaders | PASS |
| Overlay <= 5s no Chrome local | PASS (`4.23s`) |
| Nenhum frame > 1s durante loading | PASS (`972.4ms` max na janela Play -> overlay) |
| Visual final intencionalmente inalterado | PASS: apenas visibilidade incremental/loading; screenshot de gameplay C7 preservado para review; gate de luminancia `< 90` PASS (`11.78`) |
| PCK <= 27.41 MiB | PASS (`26.43 MiB`) |
| `validate.gd` full / GUT | PASS (`86/86`, `1264` asserts) |
| Web export | PASS |
| Smoothness 120s pos-warmup | FAIL residual VFX/audio |

Gate de luminancia aplicado na captura `04f2-c7-post-warmup-120s-web-play.png`, ROI topo-central da arena (`x=30%-70%`, `y=4%-28%`): `11.78`, limite `< 90`. A captura `04f2-c7-core-glass-prefetch-web-click.png` nao foi usada para o gate porque ainda contem o painel/menu sobre a camera de entrada e a ROI cruza vidro/neon brilhante, nao ceu limpo de gameplay.

## Evidencias

- Baseline: `04f2-a-baseline-web-click-materials.json/png`
- Consolidacao final: `04f2-b1-material-cache-web-click.json/png`
- Tentativas rejeitadas: `04f2-b2-*`, `04f2-c1-*` ate `04f2-c11-*`
- Final de loading: `04f2-c7-core-glass-prefetch-web-click.json/png`
- Smoothness residual: `04f2-c7-post-warmup-120s-web-play.json/png`

`docs/playtest-reports/track-04f-data/.gdignore` foi adicionado para impedir que PNGs/JSONs de evidencia sejam importados pelo Godot e contaminem o PCK.
