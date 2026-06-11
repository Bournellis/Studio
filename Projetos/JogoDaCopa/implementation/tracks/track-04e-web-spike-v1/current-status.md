# Track 04E - Web Export Spike & Render Profile V1

- Status marker: `JOGO_DA_COPA_TRACK_04E_WEB_SPIKE_V1_BRANCH_REVIEW`
- Branch: `codex/jogodacopa/track04e-web-spike-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track04e`
- Status: `BRANCH_REVIEW`
- Date: `2026-06-11`

## Objective

Export the complete current game to Web using the approved single-threaded contract, create a central render profile for desktop/Web parity fallbacks, and document Compatibility renderer divergences with desktop vs Chrome screenshots.

## Implemented

- Added Web export preset to `export_presets.cfg`, outputting to `builds/web/index.html`.
- Kept Web single-threaded: thread support OFF, extensions OFF, no SharedArrayBuffer requirement and no COOP/COEP header dependency.
- Added `RenderProfile` autoload with desktop Forward+ values preserved and Web Compatibility fallbacks for environment, emissive strengths, fake AO intent, SubViewport sizes, particles, audio/user-save contract and shader scale values.
- Applied profile values through stadium materials, pitch/nets/crowd/scoreboards, ball shader/particles, uniforms and transient feedback without forking gameplay logic.
- Added runtime fallback reporting: known Web visual differences warn once; invalid Web contract emits `push_error`.
- Added capture query support for Web evidence scenes: menu, kickoff, goal, result and live play/performance.
- Added RenderProfile unit tests and validation checks for the Web export contract.
- Promoted the permanent Web closure gate in project `AGENTS.md` and `docs/validation.md`.

## Evidence

- Report: `docs/playtest-reports/track-04e-web-spike.md`
- Screenshots: `docs/screenshots/track-04e-web-spike/`
- Desktop scenes: menu hero, kickoff, goal, result.
- Web scenes: menu hero, kickoff, goal, result, play/performance.

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Result: PASS, 85 tests, 1250 asserts, source integrity checked 33 `.gd/.gdshader` files.

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-release "Web" "builds/web/index.html"
```

Result: PASS, single-threaded Web build with `GODOT_THREADS_ENABLED=false`.

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --path . -s res://tools/performance_sample.gd --label=track04e-web-spike-v1
```

Result: PASS, desktop Forward+ windowed 1920x1080, vsync off, average `738.1fps`, min warmed instant `451.3fps`, `0/360` frames below 60.

Chrome Web smoke: PASS, canvas 1920x1080, no page errors, no unexpected console errors, `crossOriginIsolated=false`, `SharedArrayBuffer=false`, rAF sample average `102.0fps`, p95 `8.1ms`.

## Handoff

Stop on branch for mandatory Claude pre-merge review. Fabio should decide visual parity from the desktop vs Web evidence before merge. No push/fetch/pull was performed by Codex.
