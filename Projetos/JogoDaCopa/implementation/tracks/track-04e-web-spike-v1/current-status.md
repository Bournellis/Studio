# Track 04E - Web Export Spike & Render Profile V1

- Status marker: `JOGO_DA_COPA_TRACK_04E1_NIGHT_CAPTURE_HOTFIX_BRANCH_REVIEW`
- Branch: `codex/jogodacopa/track04e-web-spike-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track04e`
- Status: `BRANCH_REVIEW_AFTER_HOTFIX_04E1`
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
- Hotfix 04E.1 restored night evidence captures by replacing the gameplay chase camera in capture mode with a named evidence camera, adding rendered sky luma checks, and documenting the root cause found by the red-first test.
- Hotfix 04E.1 removed UTF-8 BOM from affected `.gd` files and promoted BOM rejection into source integrity.
- Added RenderProfile unit tests and validation checks for the Web export contract.
- Promoted the permanent Web closure gate in project `AGENTS.md` and `docs/validation.md`.

## Evidence

- Report: `docs/playtest-reports/track-04e-web-spike.md`
- Screenshots: `docs/screenshots/track-04e-web-spike/`
- Desktop scenes: menu hero, kickoff, goal, result, play.
- Web scenes: menu hero, kickoff, goal, result, play and play/performance.
- Night luma gate: desktop `60.2`, `64.0`, `75.8`, `60.2`; Web `10.9`, `29.5`, `6.4`, `10.9`; all game scenes pass `< 90`.

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Result: PASS, 86 tests, 1264 asserts, source integrity checked 33 `.gd/.gdshader` files with UTF-8 BOM rejection.

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-release "Web" "builds/web/index.html"
```

Result: PASS, single-threaded Web build with `GODOT_THREADS_ENABLED=false`.

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --path . -s res://tools/performance_sample.gd --label=track04e-web-spike-v1
```

Result: PASS, desktop Forward+ windowed 1920x1080, vsync off, average `600.2fps`, min warmed instant `374.1fps`, `0/360` frames below 60.

Chrome Web smoke: PASS, canvas 1920x1080, final CDP screenshot `1345589` bytes, rAF sample average `142.3fps`, p95 `7.0ms`.

## Handoff

Stop on branch for mandatory Claude pre-merge review after Hotfix 04E.1. Fabio should decide visual parity from the recaptured desktop vs Web evidence before merge. No push/fetch/pull was performed by Codex.
