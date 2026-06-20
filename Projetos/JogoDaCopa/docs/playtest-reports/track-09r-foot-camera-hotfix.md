# Track 09R - Foot And Camera Hotfix V1

- Date: 2026-06-19
- Branch: `codex/jogodacopa/track09r-foot-camera-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09r-foot-camera-hotfix-v1`
- Status: local hotfix validated; not published.

## Scope

Track 09R pauses further `FootballRoot` reduction to fix two playtest findings reported after the 09Q public approval:

- visible avatar feet/boots were slightly inside the field plane;
- the chase camera could pull/tilt oddly during lateral A/D movement.

No gameplay collision, movement physics, bot, ball, kick/SUPER, scoring, HUD, assets or match tuning changes were intended.

## Root Cause

- Foot clearance: the real Quaternius model's visible mesh bottom sat slightly below the avatar local field plane. The focused red test measured `min_y=-0.009`, below the required `0.025` clearance.
- Lateral camera feel: the chase camera kept the same subtle ball focus during lateral-dominant strafe. In a forced A/D scenario, `debug_get_ball_focus_weight()` stayed at `0.08`, enough to pull the focus sideways. The camera also relied on the generic `look_at` basis instead of explicitly rebuilding a level horizon.

## Implementation

- `gameplay/avatar/player_avatar_3d.gd`
  - Added `REAL_MODEL_FIELD_CLEARANCE_OFFSET = 0.05`.
  - Applies the offset only to `AvatarParts`, so the visible model clears the field while the gameplay body/collision remains unchanged.
- `presentation/camera/football_chase_camera.gd`
  - Added a velocity-aware strafe multiplier for ball focus.
  - When lateral velocity dominates, ball focus is dampened toward `25%` of the normal value.
  - Replaced generic `look_at` use with a level-horizon basis builder.
- `tests/unit/test_avatar_system.gd`
  - Added visible mesh min-Y field clearance coverage.
- `tests/unit/test_bootstrap.gd`
  - Added lateral strafe camera coverage for reduced ball focus and level horizon.

## Red Green Evidence

Before the fix, the focused tests failed:

- `test_real_avatar_visible_feet_clear_field_plane`: measured `min_y=-0.00874889642`, expected `>= 0.025`.
- `test_football_chase_camera_reduces_ball_pull_during_lateral_strafe`: measured ball focus weight `0.08`, expected `<= 0.025`.

After the fix:

- `tools/validate.gd`: PASS, `106/106` tests, `1831` asserts.
- Source integrity: `60` `.gd/.gdshader` files checked.
- Web gzip gate: `30.61 MiB / 50.00 MiB`.

## Validation

- Import headless: PASS.
- `tools/validate.gd`: PASS, `106/106`, `1831` asserts.
- Web export: PASS.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- Chrome local Web smoke:
  - command label: `09r-local-web-foot-camera`
  - duration: `90000ms`
  - `pageErrors=0`
  - `consoleErrorCount=0`
  - `stabilityPassed=true`
  - `firstMinutePassed=true`
  - JSON: `docs/playtest-reports/track-09r-data/09r-local-web-foot-camera.json`
  - PNG: `docs/playtest-reports/track-09r-data/09r-local-web-foot-camera.png`

## Coordination

- 09Q public retest was approved by Fabio/tester before this hotfix.
- 09R remains local until Fabio/tester approves the hotfix candidate for publication.
- Reductions should remain paused until the foot/camera hotfix is accepted or rejected.

## Next Step

Merge locally after green checks, then Fabio tests the 09R candidate. If approved, publish 09R before resuming `FootballRoot` reductions.
