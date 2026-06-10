# Codex - FpsShooter Track 04A Football First Fixes

- Date: `2026-06-10`
- Agent: `codex`
- Project: `Projetos/FpsShooter`
- Branch: `codex/fpsshooter/track04a-football-first-fixes`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--track04a-football-first-fixes`
- Status: `COMPLETE`
- Portfolio marker: `FPS_PLAYGROUND_TRACK_04A_FOOTBALL_FIRST_FIXES_COMPLETE`

## Objective

Fix first Futebol playtest issues after Track 04A: main menu layout, goal floor hole and paused pre-match `Como Jogar` / `Começar` flow.

## Delivered

- Main menu `MenuBox` now uses explicit centered anchors and offsets to avoid first-viewport drift.
- `Futebol` now starts paused with a `Como Jogar` panel, hotkeys/basic explanation and `Começar` button before gameplay/mouse capture.
- North and south goal mouths now include collision floor extensions so the goal area does not drop the player/ball out of the map.
- Tests now cover menu centering offsets, football intro panel visibility/start contract and goal safety floors.
- Local/project/portfolio docs updated to `FPS_PLAYGROUND_TRACK_04A_FOOTBALL_FIRST_FIXES_COMPLETE`.

## Validation

PASS:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path Projetos\FpsShooter -s res://tools/validate.gd
```

Result:

- GUT `42/42`.
- `351` asserts.

PASS:

```powershell
git diff --check
```

PASS:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --editor --quit --path Projetos\FpsShooter
```

Notes:

- Godot editor headless still reports known GUT plugin UID/text-path warnings and ObjectDB warning.
- No new blocking warnings from touched FpsShooter scripts.

## Handoff

Merged back to `main` after commit. Next step is a short editor smoke of the centered menu and Futebol intro/goal safety.
