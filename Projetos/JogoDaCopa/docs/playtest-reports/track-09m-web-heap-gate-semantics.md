# Track 09M - Web Heap Gate Semantics V1

- Date: `2026-06-19`
- Product: `Super Campeao`
- Public baseline during the track: `v1.2.1+7995b06c`
- Public release root during the track: `web/v1-copa-arena-futebol-20260616-7995b06c`
- Status: `GATE_SEMANTICS_READY_NO_PUBLICATION`

## Scope

Track 09M refined the Web heap gate semantics after Track 09L showed that the Chrome runs available for 09I, 09J, 09K and 09L had no `wasmHeapBytes` samples. The gate is now named for what it actually blocks in these runs: `js_heap_growth`.

This track did not change gameplay, input, bot behavior, physics, scoring, HUD, assets, publication scripts or public Cloudflare Pages routing. It did not publish a new build.

## Implementation

- Renamed the primary stability check from `js_wasm_heap_growth` to `js_heap_growth`.
- Kept `js_wasm_heap_growth` as `legacyAlias` inside the heap check for historical comparability.
- Added `heapGateMetric: "js_heap_growth"` and `legacyHeapGateMetric: "js_wasm_heap_growth"` to `probeConfig`.
- Renamed diagnostic components to stable metric names:
  - `js_heap_bytes`
  - `total_js_heap_bytes`
  - `wasm_heap_bytes`
  - `js_wasm_heap_bytes` as legacy aggregate/alias
- Kept the PASS/FAIL decision equivalent for current Chrome runs because `wasmSampleCount` remains `0`.

## Evidence

| Evidence | Result | Notes |
|---|---:|---|
| `track-09m-data/09m-local-js-heap-gate-smoke.json` | PASS | Local Web probe confirmed `stability.gate.checks[0].name = "js_heap_growth"` with legacy alias present. |
| `track-09m-data/09m-remote-09i-js-heap-gate-5min.json` | PASS | Remote non-mutating diagnostic against approved production 09I; release root matched `web/v1-copa-arena-futebol-20260616-7995b06c`. |

Screenshots:

- `track-09m-data/09m-local-js-heap-gate-smoke.png`
- `track-09m-data/09m-remote-09i-js-heap-gate-5min.png`

## Heap Findings

| Run | Gate name | Baseline | Final | Max | Growth | Peak | WASM samples | Result |
|---|---|---:|---:|---:|---:|---:|---:|---|
| 09M local smoke | `js_heap_growth` | `56,408,389` | `43,538,486` | `56,408,389` | `-22.82%` | `0.00%` | `0` | PASS |
| 09M remote 09I 5min | `js_heap_growth` | `43,870,097` | `47,985,379` | `50,585,776` | `+9.38%` | `+15.31%` | `0` | PASS |

The remote 09I final-GC diagnostic still did not show a meaningful cleanup effect. `js_heap_bytes` moved by only `+77,148` bytes (`+0.16%`) between the last interval sample and the final-GC sample.

## Compatibility

Historical reports and JSON evidence before Track 09M use `js_wasm_heap_growth`. New probe runs use:

- `stability.gate.checks[0].name = "js_heap_growth"`
- `stability.gate.checks[0].legacyAlias.name = "js_wasm_heap_growth"`
- `stability.gate.checks[0].legacyAlias.measurement = "usedJSHeapSize_only_no_wasm_samples"` when `wasmSampleCount` is `0`

This keeps old reports comparable while preventing new evidence from implying that real WASM memory was sampled.

## Validation

- `node --check Projetos\JogoDaCopa\tools\track04f_chrome_probe.mjs` - PASS
- Godot headless import - PASS
- `tools/validate.gd` - PASS, `104` tests, `1826` asserts, `57` source files checked
- Web export release - PASS
- Local Chrome smoke with `--heap-debug-summary=1` - PASS
- Remote Chrome 5-minute diagnostic against production 09I - PASS

## Recommendation

Keep production on approved 09I. The next reduction track can resume only after treating the Web stability threshold as `js_heap_growth` and comparing any candidate against the approved 09I baseline with the 09M probe before publication.
