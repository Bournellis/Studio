# Phase G2 Progress Log

## 2026-04-19 - Phase G2 Prepared

- Opened the documentation shell for the stabilization phase.
- Kept scope intentionally narrow so the team can harden the first slice before adding breadth.

## 2026-04-19 - Stage G2-01 Executed

- Hardened the frontend layout so the action row remains visible at common desktop sizes.
- Preserved manual loadout assembly while adding an explicit `Usar salvo` path for persisted choices.
- Added selection limits and clearer loadout section counts to reduce accidental invalid states.
- Improved arena readability with smoother camera tracking, named runtime nodes, richer HUD information, and clearer combat body feedback.
- Expanded automated coverage to protect frontend boot, scene generation, and arena runtime expectations.
- Removed orphan and timer leak warnings from the GUT pass and kept `tools/validate.gd` green after the stabilization changes.

## 2026-04-19 - Stage G2-02 Executed

- Replaced root-only bootstrap scenes with authored `frontend.tscn` and `arena.tscn` scene structures.
- Moved the main UI and world shells into stable named scene anchors so the runtime scripts no longer create the whole shell from scratch.
- Added explicit `RuntimeRoot`, `PresentationRoot`, `PlayerSpawn`, and `BotSpawn` anchors to the arena scene.
- Updated the scene bootstrap helper so validation no longer overwrites authored scenes.
- Expanded automated checks to assert the new scene ownership baseline and kept validation fully green.
