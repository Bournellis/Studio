# Track 04B2 - Feel & UI Fixes V1

- Date: `2026-06-11`
- Branch: `codex/jogodacopa/track04b2-feel-ui-fixes-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04b2-feel-ui-fixes-v1`
- Status: `COMPLETE - approved and merged to main`
- Source: Fabio direct task after Track 04B1 debugger/release planning merge to `main`

## Scope

Track 04B2 fixes four feel/UI failures without touching `gameplay/avatar/**` or avatar shaders:

- Dash with body instead of constant velocity snap.
- Pure vertical jump/flip when no directional input exists.
- Clickable result panel with mouse released and Rematch focused.
- Main menu preview no longer silently black, with a stronger hero angle.

## Implementation

- Player and bot dash now share the same calibrated curve:
  - Duration: `0.28s`.
  - Baseline distance: `5.3m`.
  - Peak time: `0.06s`.
  - First-frame speed is lower than peak speed, proving acceleration.
  - Distance is integrated per frame, so final distance is stable within frame remainder.
- Dash presentation keeps trail active and adds a short chase-camera FOV kick separate from sustained boost FOV.
- Player double flip no longer falls back to forward when there is no override/input direction; zero direction means vertical-only.
- Bot flip uses the same vertical-only rule when its target direction is zero.
- Result panel path now:
  - Does not let `FootballRoot._input` consume result-panel mouse clicks.
  - Locks gameplay input when the match ends.
  - Keeps mouse visible.
  - Gives focus to `RematchButton`.
- Pause and intro panels also focus their primary controls and are covered by real click tests.
- Main menu preview has explicit initial camera pose, brighter preview environment, hero/rim lighting and a left-third avatar composition visible behind the menu.

## Tests

Added/updated in `tests/unit/test_bootstrap.gd`:

- `test_main_menu_preview_capture_is_not_black_at_desktop_and_720p`
- `test_football_interactive_panels_accept_real_mouse_clicks`
- `test_football_arcade_dash_curve_accelerates_and_preserves_total_distance`
- `test_football_stationary_jump_and_double_flip_stay_vertical`
- `test_football_jump_with_forward_input_moves_forward`
- `test_football_bot_flip_uses_vertical_only_without_target_direction`

Existing real-click helper from Track 03I now audits main menu, intro, pause and result panels at:

- `1920x1080`
- `1366x768`
- `1280x720`

## Evidence

Playtest report:

- `docs/playtest-reports/track-04b2-feel-ui-fixes-v1.md`

Screenshots:

- `docs/screenshots/track-04b2-feel-ui-fixes-v1/dash_curve_01.png`
- `docs/screenshots/track-04b2-feel-ui-fixes-v1/dash_curve_02.png`
- `docs/screenshots/track-04b2-feel-ui-fixes-v1/dash_curve_03.png`
- `docs/screenshots/track-04b2-feel-ui-fixes-v1/dash_curve_04.png`
- `docs/screenshots/track-04b2-feel-ui-fixes-v1/jump_stationary_vertical.png`
- `docs/screenshots/track-04b2-feel-ui-fixes-v1/jump_forward_input.png`
- `docs/screenshots/track-04b2-feel-ui-fixes-v1/result_panel_cursor_visible.png`
- `docs/screenshots/track-04b2-feel-ui-fixes-v1/menu_preview_1080p.png`
- `docs/screenshots/track-04b2-feel-ui-fixes-v1/menu_preview_720p.png`

## Validation

- One-time headless editor import ran for this new worktree cache.
- Rendered evidence capture ran with Vulkan/Forward+ on NVIDIA GeForce RTX 4070 Ti.
- `tools/validate.gd`: PASS, `70/70` tests, `930` asserts.
- Source integrity: PASS, `28` `.gd/.gdshader` files outside `addons/`.
- Known validation noise: existing GUT UID/text-path warnings.

## Handoff

Claude pre-merge review approved the branch in `docs/code-review-track04b1-04b2-v1.md`, Fabio approved the screenshots, and the track was merged to `main`. The Kanban card is closed in `08_Coordenacao_Agentes/Kanban/Done/2026-06-11_codex_jogodacopa_track04b2-feel-ui-fixes-v1.md`.
