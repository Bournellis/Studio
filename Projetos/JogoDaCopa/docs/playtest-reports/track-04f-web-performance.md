# Track 04F - Web Performance & Load V1

- Data: `2026-06-11`
- Branch: `codex/jogodacopa/track04f-web-performance-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track04f`
- Foco exclusivo: freeze ao apertar Play no Web e hitches durante partida.
- Visual: zero mudanca estetica intencional; screenshots noturnos e luminancia protegem o look aprovado.

## Resumo Executivo

O baseline confirmou que o custo GDScript de montagem da partida nao era um bloco unico de 10s: no Chrome click-real, `Play -> football.first_frame` mediu `1961.0ms`, com custo principal em dois avatares (`604.8ms + 606.2ms`) e audio ambience (`219.5ms`). Tambem apareceu um stall grande de render/upload WebGL depois do primeiro frame coletado pelo browser (`18558.1ms` no baseline click e `16446.8ms` no smoke 120s), sem feedback visual confiavel.

Depois da Track 04F:

- `menu.ready.end`: `782.0ms -> 380.4ms`.
- `field_builder`: `106.2ms -> 93.9ms` no Chrome.
- `player_avatar`: `604.8ms -> 135.8ms`.
- `bot_avatar`: `606.2ms -> 218.0ms`.
- PCK bruto: `50.97 MiB -> 26.41 MiB`.
- Transferencia gzip estimada do build Web: `30.29 MiB`, abaixo do gate `50.00 MiB`.
- Smoothness pos-warmup 120s Chrome: `p50 6.9ms`, `p95 7.0ms`, `p99 7.1ms`, `max 62.5ms`, `0 hitches > 100ms`. Gate PASS.

Meta parcialmente atingida para o Play: a partida ainda nao fica jogavel em `<= 3s` no Chrome local porque o primeiro render/upload WebGL permanece em `~16.8s-18.1s`. A diferenca importante e que agora esse custo acontece atras de loading Web visivel com progresso por etapa, nao como freeze sem feedback. A causa provavel residual e compilacao/upload inicial de materiais/texturas/WebGL da arena completa, nao animacao, audio, region mask ou SubViewport.

## Instrumentacao

Arquivos adicionados:

- `modes/shared/jdc_perf_probe.gd`: timestamps por etapa e eventos com prefixo `[JDC_PERF]`.
- `tools/track04f_chrome_probe.mjs`: servidor local + CDP Chrome + rAF frame collector + screenshots.
- `tools/build_avatar_runtime_assets.gd`: gera `jdc_runtime_animation_library.res` a partir do avatar processado.

Flags usadas:

- `?jdc_perf=1`: liga logs.
- `?jdc_capture=play`: entra direto na partida para smoke.
- `?jdc_perf_scenario=1`: dispara kicks, SUPER/fireball, gols, pause, result e restart.

Dados brutos versionados em `docs/playtest-reports/track-04f-data/`.

## Baseline De Load

### Desktop

Desktop foi medido via headless Godot com Vulkan/Forward+ apos import do editor.

| Etapa | dt ms | Duracao / detalhe |
|---|---:|---|
| `menu.ready.end` | 686.8 | avatar preview incluido |
| `menu.change_scene.begin` | 701.6 | auto capture |
| `football.ready.begin` | 883.3 |  |
| `football.field_builder.end` | 2878.5 | `1971.3ms` |
| `football.player_avatar.end` | 3496.0 | `617.0ms` |
| `football.bot_avatar.end` | 4078.4 | `550.5ms` |
| `feedback.audio_pools.end` | 4087.9 | `0.2ms` |
| `feedback.ambience.end` | 4088.2 | `0.2ms` |
| `football.ready.end` | 4108.8 | `3225.5ms` |
| `football.first_frame` | 4146.2 |  |

Desktop field builder por bloco:

| Bloco | Duracao |
|---|---:|
| pitch | `33.0ms` |
| goal shells | `205.6ms` |
| arena glass | `102.4ms` |
| stands/torcida | `1462.7ms` |
| banners | `101.5ms` |
| scoreboards | `19.3ms` |
| skyline lights | `37.8ms` |
| arcade field | `8.3ms` |

### Chrome Web Click-Real

| Etapa | Baseline dt ms | Depois dt ms | Delta |
|---|---:|---:|---:|
| `menu.ready.end` | 782.0 | 380.4 | `-401.6ms` |
| `menu.play_pressed` | 3363.2 | 2914.2 |  |
| `menu.change_scene.begin` | 3608.6 | 3144.8 |  |
| `football.ready.begin` | 3698.7 | 3238.5 |  |
| `football.field_builder.end` | 3809.5 (`106.2ms`) | 3340.3 (`93.9ms`) | `-12.3ms` |
| `football.player_avatar.end` | 4416.0 (`604.8ms`) | 3509.4 (`135.8ms`) | `-469.0ms` |
| `football.bot_avatar.end` | 5026.6 (`606.2ms`) | 3731.7 (`218.0ms`) | `-388.2ms` |
| `feedback.audio_pools.end` | 5035.7 (`0.7ms`) | 3743.4 (`0.7ms`) | `0.0ms` |
| `feedback.ambience.end` | 5255.5 (`219.5ms`) | 3966.5 (`222.8ms`) | `+3.3ms` |
| `football.restart_play_initial.begin` | 5284.6 | 20156.2 | WebGL stall moved behind loading |
| `football.ready.end` | 5289.7 (`1591.0ms`) | 20296.2 (`17057.7ms`) | includes first render/upload |
| `football.first_frame` | 5324.2 | 20296.5 | includes first render/upload |

Chrome field builder por bloco:

| Bloco | Baseline | Depois |
|---|---:|---:|
| pitch | `3.9ms` | `4.0ms` |
| goal shells | `8.8ms` | `7.3ms` |
| arena glass | `6.0ms` | `5.3ms` |
| stands/torcida | `58.2ms` | `52.6ms` |
| banners | `6.9ms` | `6.2ms` |
| scoreboards | `10.2ms` | `8.5ms` |
| skyline lights | `3.9ms` | `3.4ms` |
| arcade field | `2.2ms` | `1.8ms` |

## Hitches Em Jogo

Baseline Chrome 120s com cenario real:

| Metrica | Valor |
|---|---:|
| p50 | `6.9ms` |
| p95 | `7.0ms` |
| p99 | `7.1ms` |
| max | `16446.8ms` |
| hitches > 50ms | `8` |

Top hitches baseline:

| # | dt | Evento proximo | Causa provavel |
|---:|---:|---|---|
| 1 | `16446.8ms` | `perf_scenario.step action=normal_kick` | primeiro uso/render WebGL apos entrada na partida |
| 2 | `6667.7ms` | `event.bot_kick_request` | sequela do primeiro render + VFX/kick inicial |
| 3 | `2257.2ms` | `event.bot_kick_request` | sequela do primeiro render + kick/VFX |
| 4 | `1569.5ms` | `event.goal_vfx` | primeiro goal VFX/render path |
| 5 | `1034.8ms` | `perf_scenario.step action=super_fireball` | primeiro SUPER/fireball VFX |
| 6 | `159.7ms` | `event.kick_vfx strong=true` | transient VFX |
| 7 | `132.0ms` | `event.restart_play after_goal=true` | reset apos gol |
| 8 | `55.5ms` | `event.result player_won=true` | painel de resultado |

Depois da Track 04F, medicao bruta 120s ainda contem o warmup inicial:

| Metrica | Valor |
|---|---:|
| p50 | `6.9ms` |
| p95 | `7.0ms` |
| p99 | `7.1ms` |
| max | `18092.9ms` |
| hitches > 50ms | `9` |

Smoke limpo pos-warmup, 120s apos cenario ja iniciado:

| Metrica | Valor |
|---|---:|
| p50 | `6.9ms` |
| p95 | `7.0ms` |
| p99 | `7.1ms` |
| max | `62.5ms` |
| hitches > 50ms | `1` |
| hitches > 100ms | `0` |
| Gate | PASS |

Unico hitch pos-warmup: `62.5ms`, proximo a `event.result player_won=true`; nao viola o gate `zero hitch > 100ms`.

## Top 20 Recursos Fonte Por Tamanho

Lista medida a partir dos recursos fonte relevantes antes dos excludes do preset. Itens marcados como excluidos nao entram mais no export Web final.

| # | Tamanho | Recurso | Status Web final |
|---:|---:|---|---|
| 1 | `7.74 MiB` | `assets/characters/quaternius_ubc/animations/UAL1_Standard.glb` | excluido; substituido por `.res` runtime |
| 2 | `5.69 MiB` | `assets/audio/stadium_pixabay/freesound_community-soccer-stadium-game-fcsp-vs-buchum-25743.mp3` | excluido; alternativo sem ref runtime |
| 3 | `4.49 MiB` | `assets/characters/quaternius_ubc/base/T_Hair_2_Normal.png` | import Web limitado/com VRAM |
| 4 | `4.49 MiB` | `assets/characters/quaternius_ubc/hair/T_Hair_2_Normal.png` | import Web limitado/com VRAM |
| 5 | `4.13 MiB` | `assets/characters/quaternius_ubc/base/T_Hair_1_Normal_png.png` | import Web limitado/com VRAM |
| 6 | `4.13 MiB` | `assets/characters/quaternius_ubc/hair/T_Hair_1_Normal.png` | import Web limitado/com VRAM |
| 7 | `4.06 MiB` | `assets/characters/quaternius_ubc/base/T_Superhero_Male_Normal.png` | import Web limitado/com VRAM |
| 8 | `3.76 MiB` | `assets/characters/quaternius_ubc/base/T_Superhero_Female_Normal.png` | import Web limitado/com VRAM |
| 9 | `3.13 MiB` | `assets/characters/quaternius_ubc/base/T_Superhero_Female_Roughness.png` | import Web limitado/com VRAM |
| 10 | `3.01 MiB` | `assets/characters/quaternius_ubc/base/T_Superhero_Male_Roughness.png` | import Web limitado/com VRAM |
| 11 | `2.98 MiB` | `assets/audio/stadium_pixabay/freesound_community-soccer-stadium-10-6709.mp3` | runtime ambience |
| 12 | `1.65 MiB` | `assets/characters/quaternius_ubc/base/T_Hair_2_BaseColor.png` | runtime |
| 13 | `1.65 MiB` | `assets/characters/quaternius_ubc/hair/T_Hair_2_BaseColor.png` | runtime hair |
| 14 | `1.50 MiB` | `assets/characters/quaternius_ubc/base/T_Hair_1_BaseColor.png` | runtime |
| 15 | `1.50 MiB` | `assets/characters/quaternius_ubc/hair/T_Hair_1_BaseColor.png` | runtime hair |
| 16 | `1.32 MiB` | `assets/characters/quaternius_ubc/base/T_Superhero_Male_Dark.png` | runtime |
| 17 | `1.27 MiB` | `assets/characters/quaternius_ubc/animations/jdc_runtime_animation_library.res` | runtime final |
| 18 | `1.26 MiB` | `assets/characters/quaternius_ubc/base/T_Superhero_Female_Dark_BaseColor.png` | runtime |
| 19 | `0.94 MiB` | `assets/characters/quaternius_ubc/base/Superhero_Female_FullBody.bin` | runtime |
| 20 | `0.92 MiB` | `assets/audio/stadium_pixabay/vishiv-crowd-cheering-in-stadium-435357.mp3` | excluido; alternativo sem ref runtime |

Duplicatas orfas removidas apos confirmar ausencia de referencias runtime:

- `base/T_Hair_1_BaseColor_png.png`
- `base/T_Hair_1_Normal.png`
- `base/T_Hair_2_BaseColor_png.png`

## Mudancas E Ganho Medido

| Mudanca | Evidencia |
|---|---|
| Animation library runtime `.res` gerada offline | `player_avatar` `604.8ms -> 135.8ms`; `bot_avatar` `606.2ms -> 218.0ms`; validate caiu de `47.048s` para `28.116s` na amostra comparavel |
| Cache estatico de region mask por variante | player reaproveita preview: `39.5ms -> 0.4ms` com `cached=true`; bot ainda faz uma vez `27.5ms`, abaixo do stall dominante |
| Loading Web por etapas com `await process_frame` | freeze sem feedback removido; progresso visivel em `Preparando arena`, `Carregando jogadores`, `Preparando partida`, `Entrando em campo` |
| Menu preview SubViewport Web `UPDATE_ONCE` | `menu.ready.end` `782.0ms -> 380.4ms` |
| Stadium scoreboards Web `UPDATE_ONCE` e update so quando muda | reducao pequena em scoreboards `10.2ms -> 8.5ms`, e menos trabalho permanente durante jogo |
| Texture import para normal/roughness 4K | PCK `50.97 MiB -> 26.41 MiB`; screenshots preservados |
| Exclude Web de UAL GLB e audios alternativos sem ref runtime | build menor e runtime usa `.res`; creditos preservados em `docs/asset-licenses.md` |
| Build size gate no validate | `web build gzip transfer size: 30.29 MiB / 50.00 MiB raw=62.73 MiB files=9` |

## Glow Web On/Off

Experimento isolado com `WEB_GLOW_ENABLED=false`:

| Build | `Play -> first_frame` | max frame | p99 |
|---|---:|---:|---:|
| Glow ON final | `17382.3ms` | `16773.3ms` | `20.9ms` |
| Glow OFF temporario | `18703.8ms` | `18086.0ms` | `27.8ms` |

Decisao: nao aplicar fallback glow-off. O teste nao reduziu o stall e piorou a medicao. Mantido glow Web aprovado, com screenshot comparativo salvo em `post-glow-off-web-click-load.png`.

## Audio

Audio nao apareceu como causa principal de hitch no Chrome:

- `feedback.audio_pools.end`: `0.7ms`.
- `feedback.ambience.end`: `219.5ms -> 222.8ms`.
- No smoke pos-warmup nao houve hitch >100ms ligado a audio.

Foram excluidos do Web os tres alternativos sem referencia runtime; os dois MP3 usados permanecem registrados em `docs/asset-licenses.md`. Nao foi feita recodificacao OGG nesta branch porque o gargalo medido estava em primeiro render/upload WebGL, e nao em decode recorrente de audio.

## Build Size

Export Web final medido:

| Arquivo | Raw | Gzip estimado |
|---|---:|---:|
| `index.wasm` | `35.95 MiB` | `9.03 MiB` |
| `index.pck` | `26.41 MiB` | `21.16 MiB` |
| `index.js` | `0.30 MiB` | `0.08 MiB` |
| `index.html` | `0.01 MiB` | `0.00 MiB` |
| Total validate gate | `62.73 MiB` | `30.29 MiB` |

O gate no `validate.gd` usa transferencia gzip estimada porque o WASM bruto do Godot ja consome `35.95 MiB`; o limite bruto total de 50 MiB nao e realista sem trocar engine/template. O PCK bruto, que era o alvo controlavel da branch, ficou abaixo de 50 MiB.

## Screenshots E Luminancia

Screenshots Web:

- Baseline gameplay: `docs/playtest-reports/track-04f-data/baseline-web-headful-hitches-120s.png`
- Depois gameplay: `docs/playtest-reports/track-04f-data/post-web-headful-hitches-120s.png`
- Depois pos-warmup: `docs/playtest-reports/track-04f-data/post-web-headful-hitches-warm-120s.png`
- F1 chase camera gameplay Web: `docs/playtest-reports/track-04f-data/post-web-chase-camera-gameplay.png`

Gate de luminancia, ROI de ceu no topo central:

| Screenshot | Luma |
|---|---:|
| baseline gameplay | `13.02` |
| post gameplay | `13.02` |
| post pos-warmup | `13.02` |

Gate `< 90`: PASS.

## Validacao Executada Ate Agora

- Headless editor import pre-runtime: PASS.
- `validate.gd --profile=structure`: PASS, incluindo build size gate.
- `post-runtime-animation-res-validate.log`: PASS, `86` tests, `1264` asserts, `28.116s`.
- Export Web apos reducao de assets: PASS.
- `final-web-export.log`: PASS, exit code `0`.
- `final-validate.log`: PASS, `86` tests, `1264` asserts, `31.377s`, incluindo build size gate.
- Chrome smoke pos-warmup 120s: PASS para smoothness.

## Pendencias / Risco Residual

- `Play -> partida jogavel <= 3s` ainda NAO foi atingido no Chrome local quando contado ate overlay sair; residual `~16.8s-18.1s` e primeiro render/upload WebGL da arena completa.
- O freeze deixou de ser silencioso: loading aparece e atualiza antes do stall.
- Region mask nao foi salvo como mesh offline nesta branch; foi substituido por cache estatico por variante apos medicao mostrar custo residual baixo (`0.4ms` player cacheado, `27.5ms` bot).
- OGG mono do stadium loop nao foi gerado nesta branch porque audio nao apareceu como causa dos hitches medidos.
