# JogoDaCopa Publication Readiness

Current state: first Windows debug export smoke generated for `Copa Arena Futebol`.

## Product Identity

- Product/module name: `Copa Arena Futebol`.
- Main scene: `res://modes/menu/main_menu.tscn`.
- Icon: `res://assets/branding/copa_arena_icon.svg`.
- Boot splash: `res://assets/branding/copa_arena_splash.png`.
- Windows preset: `Windows Desktop` in `export_presets.cfg`.
- Export target path: `builds/windows/CopaArenaFutebol.exe` (generated artifact, ignored by git).

## 2026-06-10 Smoke

- `tools/validate.gd`: PASS, 28 tests, 279 asserts.
- Command: `Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-debug "Windows Desktop" "builds/windows/CopaArenaFutebol.exe"`.
- Result: PASS, exit code `0`.
- Generated files: `CopaArenaFutebol.exe` (~100.9 MB) and `CopaArenaFutebol.console.exe` (~85 KB).
- Log tail ended with `[ DONE ] savepack`; only known Godot/GUT UID warnings and one ObjectDB leak warning at editor shutdown were observed.

## Known Limitations

- Debug export smoke only; no signed/release candidate yet.
- Human editor playtest remains required for camera feel, goal readability and menu-to-match presentation.
- PC Windows only; no Web, mobile, multiplayer or backend.
- Country kits and branding are generic/inspired; no official FIFA, World Cup, federation or club logos are included.
