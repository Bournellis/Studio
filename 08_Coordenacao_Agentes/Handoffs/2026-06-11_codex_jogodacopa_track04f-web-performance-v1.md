# Handoff - JogoDaCopa Track 04F Web Performance & Load V1

- Data: `2026-06-11`
- Agente: `Codex`
- Branch: `codex/jogodacopa/track04f-web-performance-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track04f`
- Status: `READY_FOR_CLAUDE_REVIEW_PRE_MERGE`

## Escopo

Foco exclusivo em:

- Freeze/trava longa ao apertar Play no Web.
- Quedas drasticas de FPS/hitches durante a partida.
- Zero mudanca estetica intencional.

## Principais Entregas

- Instrumentacao de etapas e eventos em `modes/shared/jdc_perf_probe.gd`.
- Probe Chrome/CDP em `tools/track04f_chrome_probe.mjs`.
- Relatorio completo em `Projetos/JogoDaCopa/docs/playtest-reports/track-04f-web-performance.md`.
- Dados brutos em `Projetos/JogoDaCopa/docs/playtest-reports/track-04f-data/`.
- Loading Web com progresso real por etapa durante a entrada na partida.
- `jdc_runtime_animation_library.res` gerado offline para evitar processamento UAL a cada Play.
- Cache estatico de animation library e region mask por variante.
- Menu preview e stadium scoreboards em Web com SubViewport `UPDATE_ONCE`.
- Imports Web de normal/roughness 4K limitados/com VRAM compression.
- Duplicatas orfas removidas do `base/`.
- Preset Web exclui UAL GLB bruto e audios alternativos sem referencia runtime.
- Gate de build Web gzip estimado no `validate.gd`.

## Resultado Medido

- `menu.ready.end`: `782.0ms -> 380.4ms`.
- `field_builder`: `106.2ms -> 93.9ms` no Chrome.
- `player_avatar`: `604.8ms -> 135.8ms`.
- `bot_avatar`: `606.2ms -> 218.0ms`.
- PCK bruto: `50.97 MiB -> 26.41 MiB`.
- Build gzip estimado: `30.29 MiB / 50.00 MiB`.
- Smoothness Chrome pos-warmup 120s: `p99 7.1ms`, `max 62.5ms`, `0 hitches > 100ms`: PASS.
- F1 chase camera gameplay Web capturada: `post-web-chase-camera-gameplay.png`.
- Luminancia Web gameplay: `13.02`, gate `<90`: PASS.

## Risco Residual

- A meta `Play -> partida jogavel <= 3s` ainda nao foi atingida no Chrome local quando medida ate o overlay sair.
- Residual medido: primeiro render/upload WebGL da arena completa em `~16.8s-18.1s`.
- Esse custo agora ocorre com loading visivel e progresso, nao como freeze silencioso.
- Glow Web OFF foi medido e rejeitado: piorou `Play -> first_frame` (`17382.3ms -> 18703.8ms`).
- Audio e region mask nao foram causas principais nos dados finais; OGG mono do stadium loop e mesh offline de vertex colors ficam como follow-up apenas se Claude/Fabio quiserem atacar o residual restante.

## Validacao

- Import headless do editor antes de runtime: PASS.
- `validate.gd --profile=structure`: PASS.
- `final-web-export.log`: PASS, exit code `0`.
- `final-validate.log`: PASS, `86` tests, `1264` asserts, `31.377s`.
- `git diff --check`: pendente no momento deste arquivo; rodar no fechamento.
- `git status --short`: deve ficar limpo apos commits.

## Review Pedido Para Claude

1. Confirmar se o residual WebGL com loading visivel e aceitavel para merge ou se exige Track 04F.1.
2. Revisar se o gate gzip de build Web em `validate.gd` e a interpretacao correta para o limite de 50 MiB, dado o WASM bruto do Godot.
3. Confirmar que os excludes Web nao removem recurso runtime necessario.
4. Conferir screenshots noturnos e F1 chase camera gameplay.

## Push

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
