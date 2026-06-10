# FPS Playground Validation Profiles

- Last updated: `2026-06-10`
- Status: `TRACK_05_ACTIVE`

## Purpose

`tools/validate.gd` is the main automated gate. Track 05 adds profile thinking so future validation can scale without becoming one opaque command.

## Profiles

### `quick`

Intended for frequent refactor checks.

Should cover:

- scene regeneration;
- project setting/resource checks;
- full GUT unit suite.

Command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\FpsShooter -s res://tools/validate.gd -- --profile=quick
```

### `full`

Intended before commits, merges and handoffs.

Should cover:

- everything in `quick`;
- generated scene load checks;
- documentation contract checks;
- warning summary;
- manual smoke pointer.

Default command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\FpsShooter -s res://tools/validate.gd
```

Explicit command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\FpsShooter -s res://tools/validate.gd -- --profile=full
```

### `structure`

Intended for very fast checks while moving docs/resources/scene generation contracts.

Should cover:

- scene regeneration;
- project setting/resource checks;
- generated scene load checks;
- no GUT execution.

Command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\FpsShooter -s res://tools/validate.gd -- --profile=structure
```

### `editor-smoke`

Intended after structural changes that may affect Godot import/class registration.

Should cover:

- one headless editor import/reload;
- no new project script warnings;
- known GUT UID/text-path warnings allowed.

## Current Command

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\FpsShooter -s res://tools/validate.gd
```

From a worktree, replace the path with the worktree project path.

List profiles:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\FpsShooter -s res://tools/validate.gd -- --list-profiles
```

## Known Warnings

Allowed known warning class:

- GUT scenes/resources may report invalid UID and fallback to text paths.

Fresh worktree note:

- If validation reports `GutUtils` missing, run a one-time headless editor import:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path Projetos\FpsShooter --editor --quit
```

Then rerun validation.

## Current Automated Suite

- `tests/unit/test_bootstrap.gd` remains the broad integration regression for menu, arena, football, bot, combat, HUD and feedback behavior.
- `tests/unit/test_rule_helpers.gd` covers pure helper contracts for extracted arena combat math, football match rules and bot helper calculations.

Future tracks should keep moving pure helper coverage into focused files while preserving integrated scene tests for accepted player-facing behavior.

## Failure Policy

- Do not continue to the next refactor phase with failing automated validation.
- If a failure is expected during a narrow intermediate edit, finish that edit immediately and validate before committing.
- If a new Godot script warning appears in project code, treat it as a blocker unless explicitly accepted.
- Warnings from GUT resources should be documented, not hidden.
