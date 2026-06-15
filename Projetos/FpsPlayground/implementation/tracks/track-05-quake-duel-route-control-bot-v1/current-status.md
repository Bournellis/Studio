# Track 05 - Quake Duel Route Control Bot V1

- Status: `READY_FOR_HUMAN_SMOKE`
- Started: `2026-06-15`
- Owner: Codex
- Branch: `codex/fpsplayground/track05-quake-duel-route-control-bot-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track05-quake-duel-route-control-bot-v1`
- Base: Track 04B pickup commitment ready for smoke.

## Human Smoke Input

Fabio reported:

- bot prioritizes fighting too much over movement;
- bot fails the long jump pad by strafing in the air and not completing the route;
- bot should shoot visible targets, but map movement, damage boost and health should guide general movement;
- high health should bias toward damage boost;
- low health should bias toward health;
- bot is overusing strafe/cover instead of moving correctly through the map.

## Goal

Move the bot from combat-first state behavior toward route-control behavior inspired by arena duel principles:

- movement objective is the primary layer;
- aim/fire is a combat overlay;
- item control and stack state guide route choice;
- jump pad routes receive commitment through approach, flight and landing.

## Scope

- Document the route-control contract.
- Keep visible-target shooting active without canceling movement routes.
- Add health/overcharge item bias by stack state.
- Add jump pad flight/landing commitment so the bot completes long routes.
- Reduce default strafe/cover dominance.
- Add focused tests for combat overlay, item priority and jump pad route commitment.

## Non-Goals

- No new weapons.
- No aim/damage spike.
- No map geometry rebuild.
- No multiplayer/backend/export/Web/mobile.

## Validation Plan

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
git diff --check
.\tools\check_doc_drift.ps1
git status --short
```

## Delivered

- Added `docs/bot-route-control.md` with the movement-objective/combat-overlay contract.
- Converted visible-target shooting into an overlay so route movement can continue while firing.
- Preserved item routes when a shot is fired instead of switching to cooldown/strafe.
- Added healthy overcharge priority and stronger low-health health route bias.
- Reduced cover/strafe dominance in the default engage/cooldown flow.
- Added jump pad flight/landing commitment so long jump pad routes complete before generic strafe resumes.
- Added debug hooks and focused tests for route-control behavior.

## Validation

- `tools/validate.gd`: PASS, GUT `28/28`, `229` asserts.
- Added tests:
  - `test_bot_prioritizes_overcharge_route_when_healthy_even_with_line_of_sight`
  - `test_bot_combat_overlay_shoots_without_canceling_item_route`
  - `test_bot_commits_to_jump_pad_landing_after_launch`

## Handoff

- Ready for Fabio smoke focused on Quake-style route control.
- Smoke priorities: long jump pad completion, high-health overcharge priority, low-health health/reset priority and shooting during routes.
- Push pending: Fabio via GitHub Desktop (`origin` remote is Fabio-only).
