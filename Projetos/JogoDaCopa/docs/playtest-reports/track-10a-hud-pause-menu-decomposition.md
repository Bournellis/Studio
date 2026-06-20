# Track 10A - HUD Pause Menu Decomposition V1

- Date: `2026-06-20`
- Project: `JogoDaCopa`
- Product: `Super Campeao`
- Scope: local HUD decomposition and Web publication candidate.

## Summary

Track 10A extracts the construction and settings synchronization of the football pause menu from `football_hud.gd` into `football_hud_pause_menu_controller.gd`.

The change is intended as a pure refactor. It preserves the existing pause menu node paths, button names, signal behavior, restart confirmation flow, quality/fullscreen/settings callbacks, tab visibility and sensitivity/volume controls.

## Files Touched

- `presentation/hud/football_hud.gd`
- `presentation/hud/football_hud_pause_menu_controller.gd`
- `tools/capture_track10a_hud_pause_menu_decomposition.gd`
- `docs/screenshots/track-10a-hud-pause-menu-decomposition-v1/`
- coordination/status docs for the track.

## Line Count

- `football_hud.gd`: `1512 -> 1148` physical lines.
- New controller: `437` physical lines.
- Net goal: reduce HUD surface area and isolate pause-menu construction without changing public behavior.

## Gameplay Impact

None intended.

Out of scope and untouched: `FootballRoot`, camera, physics, ball contact, kick/SUPER, bot, scoring, field builder, gameplay tuning and match flow.

## UI Evidence

Generated screenshots with `tools/capture_track10a_hud_pause_menu_decomposition.gd`:

- `docs/screenshots/track-10a-hud-pause-menu-decomposition-v1/track10a-pause-controls-1920x1080.png`
- `docs/screenshots/track-10a-hud-pause-menu-decomposition-v1/track10a-pause-audio-1920x1080.png`
- `docs/screenshots/track-10a-hud-pause-menu-decomposition-v1/track10a-pause-video-1920x1080.png`
- `docs/screenshots/track-10a-hud-pause-menu-decomposition-v1/track10a-pause-sensitivity-1920x1080.png`
- Same sections at `1366x768` and `1280x720`.
- Restart confirmation captured at all three resolutions.

Capture luminance gate: PASS. Minimum observed average luma was `0.3108`, above the `0.025` anti-black threshold.

## Validation

- Headless editor import: PASS.
- `tools/validate.gd`: PASS, `107/107` tests, `1835` asserts, `62` source files checked.
- Existing real-click pause menu tests: PASS, including pause tab buttons, restart confirmation, fullscreen toggle, quality option and pause sliders.
- Screenshot capture script: PASS across `1920x1080`, `1366x768` and `1280x720`.
- Web export: PASS.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- Chrome local 90s Web smoke: PASS, `pageErrors=0`, `consoleErrorCount=0`, `stabilityPassed=true`, `firstMinuteHitches=0`, `js_heap_growth -7.45%`, worst 5s FPS window `120.4`.
- `git diff --check`: PASS.
- `D:\Estudio\tools\check_doc_drift.ps1`: PASS.

## Notes

- The capture script printed a Godot `ObjectDB instances leaked at exit` warning after successful screenshot generation. The capture completed with exit code `0`, all PNGs were written, and the validation suite remained green.
- Publication data is recorded in `docs/playtest-reports/track-10a-publication.md` and `docs/playtest-reports/track-10a-data/`.
