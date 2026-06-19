# Track 09L - Web Heap Instrumentation V1

- Date: `2026-06-19`
- Product: `Super Campeao`
- Public baseline during the track: `v1.2.1+7995b06c`
- Public release root during the track: `web/v1-copa-arena-futebol-20260616-7995b06c`
- Status: `INSTRUMENTATION_READY_NO_PUBLICATION`

## Scope

Track 09L added diagnostic visibility to the Chrome Web heap probe after Tracks 09J and 09K failed the remote 5-minute heap gate while production stayed restored to the approved 09I baseline.

This track did not change gameplay, input, bot behavior, physics, scoring, HUD, assets, publication scripts or public Cloudflare Pages routing. It did not publish a new build.

## Implementation

- Added optional `--heap-debug-summary=1` support to `tools/track04f_chrome_probe.mjs`.
- Added `probeConfig` to probe JSON output so evidence files carry the active sample interval, warmup, stability gate, heap threshold and diagnostic flags.
- Added `stability.heapDiagnostics.components` for:
  - `js_wasm_heap_bytes`
  - `usedJSHeapSize`
  - `totalJSHeapSize`
  - `wasmHeapBytes`
- Added `stability.heapDiagnostics.windows` for:
  - `boot_0_60s`
  - `mid_60_180s`
  - `late_180_300s`
  - `gate_warmup_to_final`
- Added `stability.heapDiagnostics.finalGc` to compare the last interval sample against the explicit final-GC sample.
- Added per-sample `reason`, `sampleIndex` and `jsWasmHeapBytes` fields in `stability.browserSamples`.

## Evidence

| Evidence | Result | Notes |
|---|---:|---|
| `track-09l-data/09l-local-heap-diagnostics-smoke.json` | FAIL | Diagnostic-only first local run; warmup at `10000ms` included loading/startup stalls and failed FPS, while runtime errors were `0` and heap diagnostics were generated. |
| `track-09l-data/09l-local-heap-diagnostics-smoke-pass.json` | PASS | Local instrumented Web run with `30000ms` warmup; stability PASS. |
| `track-09l-data/09l-remote-09i-heap-diagnostics-5min.json` | PASS | Remote non-mutating diagnostic against approved production 09I; stability PASS and release root matched `web/v1-copa-arena-futebol-20260616-7995b06c`. |

Screenshots:

- `track-09l-data/09l-local-heap-diagnostics-smoke.png`
- `track-09l-data/09l-local-heap-diagnostics-smoke-pass.png`
- `track-09l-data/09l-remote-09i-heap-diagnostics-5min.png`

## Heap Findings

The important 09L finding is that `wasmHeapBytes` had no samples in the Chrome runs available for 09I, 09J, 09K and 09L. In practice, the old `js_wasm_heap_growth` gate was measuring `performance.memory.usedJSHeapSize` only for these runs.

| Run | Baseline | Final | Max | Growth | Peak | WASM samples | Result |
|---|---:|---:|---:|---:|---:|---:|---|
| 09I remote original | `43,925,492` | `48,010,927` | `50,244,475` | `+9.30%` | `+14.39%` | `0` | PASS |
| 09J remote attempt | `43,740,045` | `50,719,101` | `64,046,786` | `+15.96%` | `+46.43%` | `0` | FAIL |
| 09J remote rerun | `44,045,553` | `50,751,097` | `64,104,862` | `+15.22%` | `+45.54%` | `0` | FAIL |
| 09K remote attempt | `43,753,441` | `50,033,782` | `51,905,100` | `+14.35%` | `+18.63%` | `0` | FAIL |
| 09L remote 09I diagnostic | `44,175,847` | `48,028,601` | `50,140,150` | `+8.72%` | `+13.50%` | `0` | PASS |

The 09L remote 09I final-GC diagnostic did not show meaningful cleanup of the exposed JS heap: `usedJSHeapSize` moved by only `+62,672` bytes (`+0.13%`) between the last interval sample and the explicit final-GC sample.

## Interpretation

09L does not prove a Godot gameplay leak. It proves the current remote heap gate is not observing a real JS+WASM aggregate in these Chrome runs; it is observing JS heap exposed by Chrome. The 09J/09K failures remain real gate failures, but the signal should be treated as browser-exposed JS heap growth unless a future probe can collect real WASM memory.

Godot-side counters and FPS remained stable in the failed 09J/09K publication attempts, and approved 09I remains green when re-measured with the 09L diagnostic probe.

## Validation

- `node --check tools\track04f_chrome_probe.mjs` - PASS
- Godot headless import - PASS
- `tools/validate.gd` - PASS, `104` tests, `1826` asserts, `57` source files checked
- Web export release - PASS
- Local instrumented Chrome smoke - PASS after correct post-load warmup
- Remote instrumented Chrome diagnostic against production 09I - PASS

## Recommendation

Do not resume `FootballRoot` reduction or republish 09J/09K yet. Open a short Track 09M to either:

- rename/refine the exposed metric from `js_wasm_heap_growth` to `js_heap_growth` while preserving historical comparability, or
- run an A/B candidate probe with the 09L diagnostics before any remote mutation.

The next technical step should be measurement refinement, not another gameplay/controller extraction.
