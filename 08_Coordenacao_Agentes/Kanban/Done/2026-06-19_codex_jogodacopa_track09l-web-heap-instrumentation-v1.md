# Track 09L - Web Heap Instrumentation V1

- Data: `2026-06-19`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa/`
- Branch: `codex/jogodacopa/track09l-web-heap-instrumentation-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09l-web-heap-instrumentation-v1`
- Status: `DONE_LOCAL_COMMIT_PENDING_PUSH`

## Objetivo

Instrumentar o gate Web de heap para separar crescimento real do jogo de crescimento causado por probe/browser/runtime, antes de qualquer nova reducao do `FootballRoot` ou nova publicacao.

## Escopo Executado

- Atualizado `Projetos/JogoDaCopa/tools/track04f_chrome_probe.mjs` com diagnostico opcional `--heap-debug-summary=1`.
- Adicionado `probeConfig` aos JSONs do probe.
- Adicionadas series de diagnostico para `usedJSHeapSize`, `totalJSHeapSize`, `wasmHeapBytes` e agregado `js_wasm_heap_bytes`.
- Adicionados resumos por janelas de tempo e comparacao do ultimo sample contra sample pos-GC final.
- Consolidado relatorio `Projetos/JogoDaCopa/docs/playtest-reports/track-09l-web-heap-instrumentation.md`.
- Registradas evidencias em `Projetos/JogoDaCopa/docs/playtest-reports/track-09l-data/`.

## Resultado Tecnico

- Em todas as evidencias remotas analisadas de 09I/09J/09K/09L, `wasmHeapBytes` ficou sem amostras.
- O gate historico `js_wasm_heap_growth` estava medindo `performance.memory.usedJSHeapSize` nestas runs de Chrome.
- A 09L nao prova vazamento de gameplay/Godot; ela prova que o sinal atual e heap JS exposto pelo browser, nao JS+WASM real.
- A producao aprovada 09I segue verde: run remota 09L contra `web/v1-copa-arena-futebol-20260616-7995b06c` PASS com crescimento `+8.72%`.
- As falhas 09J/09K continuam bloqueantes, mas devem ser tratadas como falha de `js_heap_growth` ate haver medicao real de WASM.

## Validacao

- `node --check tools\track04f_chrome_probe.mjs` - PASS
- Import headless Godot - PASS
- `tools/validate.gd` - PASS, `104` tests, `1826` asserts, `57` source files checked
- Web export release - PASS
- Chrome local instrumentado - PASS em `09l-local-heap-diagnostics-smoke-pass.json`
- Chrome remoto instrumentado contra 09I - PASS em `09l-remote-09i-heap-diagnostics-5min.json`
- `tools/check_doc_drift.ps1` - PASS
- `git diff --check` - PASS

## Evidencias

- `Projetos/JogoDaCopa/docs/playtest-reports/track-09l-data/09l-local-heap-diagnostics-smoke.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09l-data/09l-local-heap-diagnostics-smoke.png`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09l-data/09l-local-heap-diagnostics-smoke-pass.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09l-data/09l-local-heap-diagnostics-smoke-pass.png`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09l-data/09l-remote-09i-heap-diagnostics-5min.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09l-data/09l-remote-09i-heap-diagnostics-5min.png`

## Proximo Passo Recomendado

Abrir Track 09M curta para refinar/renomear o gate como `js_heap_growth` ou rodar um A/B remoto com diagnosticos 09L antes de qualquer nova publicacao ou reducao do `FootballRoot`.

## Publicacao

Nao houve publicacao nesta track.

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
