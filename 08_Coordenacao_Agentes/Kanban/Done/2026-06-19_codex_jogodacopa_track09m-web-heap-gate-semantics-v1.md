# Track 09M - Web Heap Gate Semantics V1

- Data: `2026-06-19`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa/`
- Branch: `codex/jogodacopa/track09m-web-heap-gate-semantics-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09m-web-heap-gate-semantics-v1`
- Base: `codex/jogodacopa/track09l-web-heap-instrumentation-v1` (`c2cce0b1`)
- Status: `DONE_LOCAL_COMMIT_PENDING_PUSH`

## Objetivo

Refinar a semantica do gate Web de heap depois da Track 09L: expor claramente `js_heap_growth` quando o Chrome nao fornece `wasmHeapBytes`, preservar compatibilidade com o campo legado `js_wasm_heap_growth` e produzir uma run remota nao mutante contra a producao 09I.

## Escopo Executado

- Atualizado `Projetos/JogoDaCopa/tools/track04f_chrome_probe.mjs`.
- Gate primario renomeado para `js_heap_growth`.
- Alias legado `js_wasm_heap_growth` preservado dentro do check como `legacyAlias`.
- `probeConfig` agora registra `heapGateMetric` e `legacyHeapGateMetric`.
- Diagnosticos agora usam `js_heap_bytes`, `total_js_heap_bytes`, `wasm_heap_bytes` e `js_wasm_heap_bytes`.
- Evidencias criadas em `Projetos/JogoDaCopa/docs/playtest-reports/track-09m-data/`.
- Relatorio criado em `Projetos/JogoDaCopa/docs/playtest-reports/track-09m-web-heap-gate-semantics.md`.

## Resultado Tecnico

- Run local PASS confirmou `stability.gate.checks[0].name = "js_heap_growth"`.
- Run remota nao mutante contra 09I PASS confirmou release root `web/v1-copa-arena-futebol-20260616-7995b06c`.
- 09M remoto 09I: `js_heap_growth +9.38%`, limite `10%`, `wasmSampleCount=0`.
- Nenhuma publicacao, nenhuma reducao de `FootballRoot`, nenhuma mudanca de gameplay/input/bot/fisica/scoring/HUD/assets.

## Validacao

- `node --check Projetos\JogoDaCopa\tools\track04f_chrome_probe.mjs` - PASS
- Import headless Godot - PASS
- `tools/validate.gd` - PASS, `104` tests, `1826` asserts, `57` source files checked
- Web export release - PASS
- Chrome local instrumentado - PASS em `09m-local-js-heap-gate-smoke.json`
- Chrome remoto 5min contra 09I - PASS em `09m-remote-09i-js-heap-gate-5min.json`
- `tools/check_doc_drift.ps1` - PASS
- `git diff --check` - PASS

## Evidencias

- `Projetos/JogoDaCopa/docs/playtest-reports/track-09m-data/09m-local-js-heap-gate-smoke.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09m-data/09m-local-js-heap-gate-smoke.png`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09m-data/09m-remote-09i-js-heap-gate-5min.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09m-data/09m-remote-09i-js-heap-gate-5min.png`

## Proximo Passo Recomendado

Retomar reducao local apenas com gate nomeado como `js_heap_growth` e com comparacao A/B contra 09I usando o probe 09M antes de qualquer publicacao.

## Publicacao

Nao houve publicacao nesta track.

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
