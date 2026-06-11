# Playtest Report - Track 04B2 Feel & UI Fixes V1

- Date: `2026-06-11`
- Agent: `Codex`
- Scene: `res://modes/football/football.tscn` and `res://modes/menu/main_menu.tscn`
- Branch: `codex/jogodacopa/track04b2-feel-ui-fixes-v1`
- Status: `WORKTREE_VERIFIED`

## What Ran

- Generated current scenes with `BootstrapSceneGenerator`.
- Ran deterministic rendered captures in Godot Vulkan/Forward+.
- Ran full headless validation after implementation and evidence capture.
- Verified no files under `gameplay/avatar/**` or avatar shaders were touched.

## Evidence Captures

Dash with acceleration curve:

- `docs/screenshots/track-04b2-feel-ui-fixes-v1/dash_curve_01.png`
- `docs/screenshots/track-04b2-feel-ui-fixes-v1/dash_curve_02.png`
- `docs/screenshots/track-04b2-feel-ui-fixes-v1/dash_curve_03.png`
- `docs/screenshots/track-04b2-feel-ui-fixes-v1/dash_curve_04.png`

Jump comparison:

- `docs/screenshots/track-04b2-feel-ui-fixes-v1/jump_stationary_vertical.png`
- `docs/screenshots/track-04b2-feel-ui-fixes-v1/jump_forward_input.png`

Result panel:

- `docs/screenshots/track-04b2-feel-ui-fixes-v1/result_panel_cursor_visible.png`
- Automated proof: `Input.MOUSE_MODE_VISIBLE`, player input locked and `RematchButton` focused when match ends.

Menu preview:

- `docs/screenshots/track-04b2-feel-ui-fixes-v1/menu_preview_1080p.png`
- `docs/screenshots/track-04b2-feel-ui-fixes-v1/menu_preview_720p.png`

## Checklist

| Item | Result | Evidence |
|---|---|---|
| Dash no longer starts as constant velocity snap | PASS | `test_football_arcade_dash_curve_accelerates_and_preserves_total_distance` |
| Dash first-frame speed is lower than peak speed | PASS | Same test |
| Dash total distance remains `5.3m` within 5% | PASS | Same test |
| Bot uses same dash curve/distance/peak | PASS | Same test and parity asserts |
| Dash has trail and short FOV kick | PASS | `FootballRoot` dash signal and `FootballChaseCamera.play_dash_fov_kick` |
| Stationary initial jump does not drift in X/Z | PASS | `test_football_stationary_jump_and_double_flip_stay_vertical` |
| Stationary double flip does not drift in X/Z | PASS | Same test |
| Forward input jump moves toward forward | PASS | `test_football_jump_with_forward_input_moves_forward` |
| Bot flip is vertical-only with zero direction | PASS | `test_football_bot_flip_uses_vertical_only_without_target_direction` |
| Result panel releases mouse and focuses Rematch | PASS | `test_football_interactive_panels_accept_real_mouse_clicks` |
| Result Rematch/Menu buttons accept real injected clicks | PASS | Same test, 3 resolutions |
| Pause and intro panels accept real injected clicks | PASS | Same test, 3 resolutions |
| Menu preview is not black in 1080p and 720p | PASS | `test_main_menu_preview_capture_is_not_black_at_desktop_and_720p` and screenshots |

## Validation

Command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Result:

- PASS
- `70/70` tests
- `930` asserts
- Source integrity checked: `28` `.gd/.gdshader` files outside `addons/`

## Notes For Review

- The result-panel screenshot cannot embed the OS cursor in the viewport texture, but the automated test verifies `Input.MOUSE_MODE_VISIBLE` and click delivery with real `InputEventMouseButton` injection.
- Headless validation uses Godot's dummy renderer; the menu luminance probe reads real pixels in rendered mode and falls back to configured preview luminance only when no headless pixels are available.
- Final branch is intended for Claude review, not merge.
