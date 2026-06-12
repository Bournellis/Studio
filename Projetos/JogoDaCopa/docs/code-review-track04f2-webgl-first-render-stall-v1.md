# Code Review - Track 04F.2 WebGL First-Render Stall V1

- Data: `2026-06-12`
- Reviewer: `Claude`
- Branch: `codex/JogoDaCopa/track04f2-webgl-first-render-stall-v1` (4 commits: baseline -> consolidacao -> warmup -> evidencia)
- Veredito: **APROVADA PARA MERGE**. Residual de smoothness longo (primeiro uso de VFX/audio) promovido a `Track 04F.3 - VFX/Audio First-Use Warmup`.

## Gates Do Card

| Gate | Resultado |
| --- | --- |
| Baseline antes de mudanca (contagem materiais/shaders + timeline) | PASS (467 materiais unicos; stall 18.83s; ready 19.52s) |
| Overlay <= 5s primeira visita Chrome local | PASS (`4.23s`) |
| Nenhum frame > 1s na janela Play -> overlay | PASS (`972.4ms` max) |
| Visual final inalterado | PASS (cache keyed por todos os parametros + gate de luminancia `11.78 < 90` + screenshots) |
| PCK <= 27.41 MiB | PASS (`26.43 MiB`; `.gdignore` impede evidencias no PCK) |
| `validate.gd` full / GUT | PASS (`86/86`, `1264` asserts) |
| Otimizacoes sem ganho revertidas e documentadas | PASS (10 de 13 passos revertidos com medicao) |
| Smoothness 120s pos-warmup | FAIL residual - primeiro uso de VFX/audio (confetti `1299ms`, kick `1132ms`); C8-C11 tentados e revertidos |

Resultado central: `Play -> partida jogavel` caiu de `19.52s` para `4.23s` (materiais unicos `467 -> 79`). O bloqueio de publicacao diagnosticado na 04F esta resolvido.

## Achados De Codigo

- `runtime_primitive_factory.gd`: caches estaticos de `StandardMaterial3D`/vidro/`BoxMesh` com chave composta por TODOS os parametros do material - compartilhamento so quando identico, visual preservado por construcao. Correto.
- Varredura de mutacao: todos os pontos que mutam `albedo_color`/`emission` no runtime (`football_root`, `main_menu_root`, `football_ball`, `combatant_3d`, `player_avatar_3d`) operam sobre materiais criados localmente com `StandardMaterial3D.new()` - nenhum muta material vindo do cache. Sem risco de sangramento visual entre instancias.
- Warmup incremental (`football_root.gd`): gated por `RenderProfileScript.is_web_platform()`, ondas por categoria (campo/bola -> avatares -> 2 vidros core -> decorativo diferido via `call_deferred`), instrumentado pelo `jdc_perf_probe` em cada fase, constantes nomeadas para tuning. Desktop/editor intocados.
- Metodologia exemplar mantida: B2/C1-C5/C8-C11 revertidos por medicao; somente B1+C6+C7 retidos.

## Observacoes Menores (nao bloqueiam)

- N1: o frame maximo da janela de loading (`972ms`) passa o gate de 1s por margem de 28ms. Em maquinas mais lentas pode estourar; re-medir este gate na 04F.3.
- N2: a branch orfa `codex/JogoDaCopa/track04f2-webgl-stall-v1` (primeira tentativa, superada) pode ser apagada localmente apos o merge.
- N3: ~20 MiB de PNGs de evidencia por track acumulam no repo. Sugestao para proximas tracks: manter JSONs completos e somente PNGs de baseline + final.

## Residual Promovido

`Track 04F.3 - VFX/Audio First-Use Warmup`: hitches de primeiro uso de confetti/kick VFX/audio pos-warmup (ate `1.3s`). Nao e o stall de arena da 04F.2; exige abordagem propria (pre-bake de particulas/decode de audio durante o loading, ou aceitacao documentada de hitch unico por sessao). Hipoteses ja descartadas por medicao: cache de recursos VFX (C8), warmup visual de VFX no loading (C9, +4s de overlay), pool de GPUParticles3D (C10), warmup silencioso de audio (C11, quebrou o loading).
