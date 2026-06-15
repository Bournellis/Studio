# Track 02 - Bot Tactical Movement V1

- Created: `2026-06-15`
- Status: `IN_PROGRESS`
- Status marker: `FPS_PLAYGROUND_TRACK02_BOT_TACTICAL_MOVEMENT_IN_PROGRESS`
- Branch: `codex/fpsplayground/track02-bot-tactical-movement-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track02-bot-tactical-movement-v1`

## Goal

Make the `Arena Shooter` bot harder and more reusable through arena-agnostic tactical movement.

The bot should not be trapped in a single `Duel Pit V2` point model. Arenas should publish tactical affordances, and the bot should score them according to the duel state.

## Scope

- Bot tactical context contract.
- Duel Pit V2 tactical point provider.
- Route scoring for pressure, flank, cover, retreat, health, overcharge, high ground and jump pad routes.
- Anti-repeat route memory and stuck recovery improvements.
- Conservative fairness tuning around reaction/cooldown/aim.
- Focused automated tests and manual smoke checklist.

## Non-Goals

- No new arena map.
- No new weapon.
- No export/publication.
- No Web/mobile.
- No multiplayer/backend.
- No football/TPS scope.

## Phase Checklist

- [x] Worktree and Kanban registered.
- [ ] Documentation baseline committed.
- [ ] Tactical context implementation.
- [ ] Movement/scoring implementation.
- [ ] Focused tests updated.
- [ ] Final automated validation.
- [ ] Handoff for human bot movement smoke.

## Validation

Run before handoff:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
git diff --check
git status --short
```
