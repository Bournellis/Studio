# Track 01 - Combat Readability Polish V1

- Created: `2026-06-15`
- Status: `DOING`
- Status marker: `FPS_PLAYGROUND_TRACK01_COMBAT_READABILITY_POLISH_DOING`
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
- [ ] Feedback/HUD implementation.
- [ ] Focused test coverage updated.
- [ ] Final automated validation.
- [ ] Handoff for human combat readability smoke.

## Validation

Run before handoff:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
git diff --check
git status --short
```

Manual smoke lives in `docs/validation.md`.
