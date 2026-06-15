# Track 01 - Combat Readability Polish V1

- Created: `2026-06-15`
- Status: `READY_FOR_HUMAN_SMOKE`
- Status marker: `FPS_PLAYGROUND_TRACK01_COMBAT_READABILITY_POLISH_READY_FOR_HUMAN_SMOKE`
- Branch: `codex/fpsplayground/track01-combat-readability-polish-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track01-combat-readability-polish-v1`

## Goal

Polish `Arena Shooter` combat readability after accepted human regression of the preserved `Duel Pit V2` baseline.

The track should help the player understand:

- when rifle shots hit or miss;
- when the player takes damage;
- when the bot is about to fire;
- where Plasma Bolt is travelling and impacting;
- when overcharge is active;
- where pickups and jump pad routes matter during the duel.

## Baseline

- Human Arena Shooter regression: OK, reported by Fabio on 2026-06-15.
- Baseline validation after one-time fresh worktree import: `tools/validate.gd` PASS, GUT `14/14`, `95` asserts.
- Known validation noise: GUT UID/text-path fallback warnings.

## Scope

- Rifle tracer and impact readability.
- Bot hit and kill confirmation readability.
- Player damage intake readability.
- Bot shot tell readability.
- Plasma Bolt normal/overcharged trajectory and impact readability.
- Pickup and jump pad combat readability.
- Focused tests for feedback contracts.
- Manual smoke checklist update.

## Non-Goals

- No new weapon.
- No new arena map or layout.
- No broad damage, health, movement or bot difficulty retuning.
- No export/publication.
- No Web/mobile.
- No multiplayer/backend.
- No football/TPS scope.

## Phase Checklist

- [x] Worktree and Kanban registered.
- [x] Baseline validation run.
- [x] Retomada/status documentation updated.
- [x] Feedback/HUD implementation.
- [x] Focused test coverage updated.
- [x] Final automated validation.
- [ ] Handoff for human combat readability smoke.

## Delivered

- Added HUD event coloring and explicit `BOT FIRING`, `UNDER FIRE`, `PLASMA HIT` and `OVERCHARGE HIT` readability messages.
- Added dedicated HUD tracking for Plasma hits and bot shot tells.
- Routed bot windup into HUD feedback.
- Added health/overcharge pickup readability halos and beacons.
- Added launch direction cues to jump pads.
- Added tests for readability nodes and HUD/feedback event contracts.

## Validation

Run before handoff:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
git diff --check
git status --short
```

Manual smoke lives in `docs/validation.md`.

Final automated result:

- `tools/validate.gd`: PASS, GUT `15/15`, `118` asserts.
- Known warning class remains limited to GUT UID/text-path fallback warnings.
