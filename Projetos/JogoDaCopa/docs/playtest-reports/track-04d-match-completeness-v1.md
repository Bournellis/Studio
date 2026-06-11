# Playtest Report - Track 04D Match Completeness V1

- Date: `2026-06-11`
- Agent: `Codex`
- Scope: pause/result/fade/menu completeness before web publish.
- Scene: `res://modes/football/football.tscn` and `res://modes/menu/main_menu.tscn`
- Capture tool: `res://tools/capture_track04d_match_completeness.gd`
- Constraint: no gameplay rule changes; tap/RMB/regras stayed untouched.

## What Ran

- Generated current menu and football scenes through `BootstrapSceneGenerator`.
- Started rendered Godot captures in a real Vulkan window, not headless.
- Used debug hooks only to create deterministic pause, result and fade evidence.
- Ran full validation after captures: `79/79` tests, `1186` asserts.
- Ran studio doc drift check and git whitespace check: both PASS.

## Inputs And Simulation

- Pause evidence starts a real match, opens pause through the production pause path and captures the panel with mouse-visible UI.
- Result evidence simulates a `3-1` goal-mode match through the same stat-collection helpers used by the match root.
- Hero evidence captures the menu at `1920x1080` and `1280x720` with the uniformed player preview visible beside the menu panel.
- Fade evidence captures three frames of the short black transition: start, full black and clear.

## Captures

- `docs/screenshots/track-04d-match-completeness-v1/hero-menu-1920x1080.png`
- `docs/screenshots/track-04d-match-completeness-v1/hero-menu-1280x720.png`
- `docs/screenshots/track-04d-match-completeness-v1/pause-menu-1920x1080.png`
- `docs/screenshots/track-04d-match-completeness-v1/result-stats-simulated-match-1920x1080.png`
- `docs/screenshots/track-04d-match-completeness-v1/fade-frame-01-start.png`
- `docs/screenshots/track-04d-match-completeness-v1/fade-frame-02-black.png`
- `docs/screenshots/track-04d-match-completeness-v1/fade-frame-03-clear.png`

## Checklist

| Item | Result | Evidence |
|---|---|---|
| Pause menu real with `Continuar`, `Reiniciar partida`, four volume sliders and `Sair ao menu` | PASS | `test_football_interactive_panels_accept_real_mouse_clicks`, `pause-menu-1920x1080.png` |
| Game pauses for pause menu and focuses `Continuar` first | PASS | `test_football_interactive_panels_accept_real_mouse_clicks` |
| Result screen has final score, kits/codes, stats and buttons | PASS | `test_football_root_collects_match_stats_for_result_screen`, `result-stats-simulated-match-1920x1080.png` |
| Result buttons accept real mouse click | PASS | `test_football_interactive_panels_accept_real_mouse_clicks` |
| Match stats are pure rule data | PASS | `test_football_match_rules_collects_match_stats_as_pure_data` |
| Fades exist without blocking headless input tests | PASS | `fade-frame-01-start.png`, `fade-frame-02-black.png`, `fade-frame-03-clear.png` |
| Menu hero preview is visible and anti-black checks remain | PASS | `test_main_menu_preview_capture_is_not_black_at_desktop_and_720p`, `hero-menu-1920x1080.png`, `hero-menu-1280x720.png` |
| ESC maps intro/match/result consistently | PASS | `test_football_escape_targets_intro_pause_and_result_menu` |
| Restart cleans countdown, golden goal and slow-mo | PASS | `test_football_restart_cleans_countdown_golden_goal_and_slowmo` |
| 04C reserved files untouched | PASS | Git diff excludes `field_builder/**`, shaders and `gameplay/avatar/**` |

## Observations

- Pause screenshot intentionally keeps a darkened game backdrop; the black fade overlay is cleared before capture.
- Result stats are deterministic capture data: goals by period, total shots, possession by touch counts, supers used and longest touch streak.
- Fade screenshots are evidence of transition presence and timing, not a subjective visual approval gate.
- Final visual approval remains Fabio's gate before merge.
