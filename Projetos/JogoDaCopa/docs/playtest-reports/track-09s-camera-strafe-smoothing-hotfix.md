# Track 09S - Camera Strafe Smoothing Hotfix V1

- Date: 2026-06-20
- Branch: `codex/jogodacopa/track09s-camera-strafe-smoothing-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09s-camera-strafe-smoothing-hotfix-v1`
- Status: local validated, pending merge/publication

## Scope

Track 09S pauses further `FootballRoot` reductions to fix the residual chase-camera discomfort reported after Track 09R. The issue was most visible when tapping `A` or `D`: the player movement itself stayed stable, but the camera focus snapped as lateral velocity changed, creating a perceived tremor/pull.

The fix is presentation-only:

- Smooths the chase-camera ball-focus weight when lateral strafe velocity changes.
- Smooths the final focus point used by the camera look-at step.
- Preserves `snap_to_target()` for immediate setup/reset behavior.
- Preserves goal-focus punch by bypassing the new easing while goal focus is active.
- Does not change player movement, physics, collision, bot, ball, scoring, SUPER, HUD, assets or match tuning.

## Files Touched

- `presentation/camera/football_chase_camera.gd`
- `tests/unit/test_bootstrap.gd`
- `docs/playtest-reports/track-09s-camera-strafe-smoothing-hotfix.md`
- `docs/playtest-reports/track-09s-data/09s-local-web-camera-strafe.json`
- `docs/playtest-reports/track-09s-data/09s-local-web-camera-strafe.png`

## Red/Green Test

Added `test_football_chase_camera_smooths_quick_lateral_tap_focus_shift`.

Initial red result before the fix:

- Actual first-frame focus jump: `0.73289066553116`.
- Allowed threshold: `< 0.36644533276558`.
- Ball focus weight snapped to `0.02333333333333`, below the required eased value `> 0.04`.

Green result after the fix:

- `tools/validate.gd` PASS.
- Full GUT suite PASS: `107/107` tests, `1835` asserts.

## Local Validation

Commands run:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --editor --quit --path .
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-release "Web" "builds/web/index.html"
node --check tools/track04f_chrome_probe.mjs
git diff --check
D:\Estudio\tools\check_doc_drift.ps1
node tools/track04f_chrome_probe.mjs --chrome="C:\Program Files\Google\Chrome\Application\chrome.exe" --web-dir=builds/web --duration-ms=90000 --stability-gate=1 --stability-warmup-ms=30000 --label=09s-local-web-camera-strafe --out-dir=docs/playtest-reports/track-09s-data --fail-on-runtime-errors=1 --cdp-port=9254
```

Results:

- Headless editor import: PASS, with existing GUT UID/text-path warnings.
- `tools/validate.gd`: PASS, `107/107` tests, `1835` asserts, `60` source files checked.
- Web export: PASS. First attempt failed because `builds/web` did not exist in the fresh worktree; after creating the directory, the same export command passed.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- `git diff --check`: PASS.
- `D:\Estudio\tools\check_doc_drift.ps1`: PASS.
- Local Chrome Web smoke: PASS, `pageErrors=0`, `consoleErrorCount=0`, `stabilityPassed=true`, `firstMinuteHitches=0`.

Local smoke evidence:

- `docs/playtest-reports/track-09s-data/09s-local-web-camera-strafe.json`
- `docs/playtest-reports/track-09s-data/09s-local-web-camera-strafe.png`

## Publication Plan

After merge to `main`, publish 09S to Cloudflare Pages and run:

- Remote menu gate.
- Remote first-minute gate.
- Remote 5-minute stability gate.
- Remote night luma gate.
- Fabio/tester human retest focused on quick `A/D` taps and normal `W/S` movement.
