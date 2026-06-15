# Track 02 - Bot Tactical Movement V1

- Created: `2026-06-15`
- Status: `READY_FOR_HUMAN_SMOKE`
- Status marker: `FPS_PLAYGROUND_TRACK02_BOT_TACTICAL_MOVEMENT_READY_FOR_HUMAN_SMOKE`
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
- [x] Documentation baseline committed.
- [x] Tactical context implementation.
- [x] Movement/scoring implementation.
- [x] Focused tests updated.
- [x] Final automated validation.
- [x] Handoff for human bot movement smoke.

## Delivered

- Added `gameplay/bot/bot_tactical_context.gd`.
- `Duel Pit V2` now publishes bot tactical roles and jump pad routes from the arena layer.
- `BasicDuelBot` consumes tactical context, scores roles and remembers recent routes.
- Bot now has stronger movement intent around pressure, flanks, cover, retreat, health, overcharge and high ground.
- Conservative pressure tuning: lower reaction/cooldown and smaller deterministic aim error while preserving shot tell.
- Tests cover Duel Pit roles, critical health route priority and an alternate context with no Duel Pit points.

## Validation

Run before handoff:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
git diff --check
git status --short
```

Final automated result:

- `tools/validate.gd`: PASS, GUT `18/18`, `135` asserts.
- `git diff --check`: PASS.
- `tools/check_doc_drift.ps1`: PASS.
- Known warning class remains limited to GUT UID/text-path fallback warnings.

## Human Smoke Pending

Fabio should run the Track 02 smoke in `docs/validation.md` and judge whether the bot movement is harder, fair and less tied to the current arena model.
