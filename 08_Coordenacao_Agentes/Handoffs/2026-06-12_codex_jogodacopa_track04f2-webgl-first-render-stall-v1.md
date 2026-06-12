# Handoff - JogoDaCopa Track 04F.2 WebGL First-Render Stall V1

Data: 2026-06-12  
Autor: Codex  
Branch: `codex/jogodacopa/track04f2-webgl-first-render-stall-v1`  
Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04f2-webgl-first-render-stall-v1`

## Pedido

Review pre-merge da Track 04F.2. Foco unico: stall de primeiro render/upload WebGL ao entrar na partida no Chrome local em primeira visita.

## Commits

- `fb3ba99f` - `perf(jogodacopa): measure track04f2 webgl baseline`
- `d88c60c1` - `perf(jogodacopa): consolidate field materials for web`
- `5e9f3455` - `perf(jogodacopa): warm web first render incrementally`
- Commit D pendente neste handoff: evidencia/docs e card Review.

## Resultado Retido

- Material refs unicos: `467 -> 79`.
- Chrome first-visit ready depois do Play: `19.52s -> 4.23s`.
- Overlay depois do Play: `4.23s`.
- Max frame dentro da janela Play -> overlay: `972.4ms`.
- PCK final: `26.43 MiB` (`<= 27.41 MiB`).
- Validate full: PASS (`86/86`, `1264` asserts).
- Web export: PASS.

## Residual Critico

O gate principal de first-render/loading passou, mas o smoke 120s pos-warmup ainda falha por primeiro uso de VFX/audio:

- `event.confetti_vfx`: `1298.8ms`.
- `event.kick_vfx`: `1132.0ms`.
- Tentativas C8-C11 foram revertidas porque nao melhoraram ou quebraram a meta de loading.

Recomendacao Codex: aprovar 04F.2 se o criterio de merge for especificamente o residual critico de primeiro render da arena; abrir follow-up separado para VFX/audio first-use se o gate de smoothness 120s continuar bloqueante.

## Arquivos Para Revisar

- `Projetos/JogoDaCopa/modes/shared/jdc_perf_probe.gd`
- `Projetos/JogoDaCopa/modes/shared/runtime_primitive_factory.gd`
- `Projetos/JogoDaCopa/modes/football/football_field_builder.gd`
- `Projetos/JogoDaCopa/modes/football/football_root.gd`
- `Projetos/JogoDaCopa/tests/unit/test_bootstrap.gd`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-04f2-webgl-stall.md`
- `Projetos/JogoDaCopa/implementation/tracks/track-04f2-webgl-first-render-stall/current-status.md`

## Evidencias

- Baseline: `Projetos/JogoDaCopa/docs/playtest-reports/track-04f-data/04f2-a-baseline-web-click-materials.json`
- Final loading: `Projetos/JogoDaCopa/docs/playtest-reports/track-04f-data/04f2-c7-core-glass-prefetch-web-click.json`
- Smoothness residual: `Projetos/JogoDaCopa/docs/playtest-reports/track-04f-data/04f2-c7-post-warmup-120s-web-play.json`
- Relatorio: `Projetos/JogoDaCopa/docs/playtest-reports/track-04f2-webgl-stall.md`

## Validacao Executada

- Headless editor import: PASS.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`: PASS.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-release "Web" "builds/web/index.html"`: PASS.
- Chrome probes com `tools/track04f_chrome_probe.mjs`: baseline, B1, C1-C11, final C7.

## Merge

Nao mergeado. Aguardando review Claude.  
Git remoto nao usado. Push/fetch/pull proibidos nesta politica.
