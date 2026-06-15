# Track 04 - Arena Movement Flow And Bot Navigation V1

- Status: `READY_FOR_HUMAN_SMOKE`
- Started: `2026-06-15`
- Owner: Codex
- Branch: `codex/fpsplayground/track04-arena-movement-flow-bot-navigation-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track04-arena-movement-flow-bot-navigation-v1`
- Base: Track 03 locally validated; human smoke found movement/map flow issues.

## Human Smoke Input

Fabio reported:

- bot aim is better;
- bot movement is not good enough;
- bot appears to use map geometry as if it were a jump pad;
- bot gets stuck hitting ceilings and walls;
- `Relay Foundry V1` jump pad near the high platform is hard to reach and too close to the high platform;
- platform positioning does not have a good movement feel.

## Goal

Rebuild arena movement flow and bot navigation around arena-shooter principles:

- continuous duel loops;
- readable vertical routes;
- jump pads with clear approach and landing space;
- high platforms connected by real movement affordances;
- bot route selection based on movement chains, not raw high-position destinations.

## Scope

1. Document movement flow rules for FpsPlayground arena layouts.
2. Add validation coverage for layout clearance and vertical route contracts.
3. Rebuild `Relay Foundry` geometry and jump pad placement around player movement.
4. Normalize `Duel Pit` tactical route data to the same contract without discarding its accepted baseline.
5. Update bot movement so high-ground goals are reached through staged routes.
6. Add tests for bot route resolution and jump pad navigation safety.
7. Update manual smoke instructions and coordination state.

## Non-Goals

- No new weapon.
- No raw aim/damage difficulty spike.
- No multiplayer/backend/export/Web/mobile.
- No final art pass.
- No broad non-arena refactor.

## Movement Contract

- Jump pads must have readable floor approach space before the trigger.
- Jump pad targets must land on a clear zone, not on an edge or under cover.
- Tactical high-ground points must publish a route label shared with their entry/landing affordances.
- Bot navigation may use high-ground destinations only through valid route stages.
- Arenas should support at least one continuous ground loop and one vertical loop.
- Cover should support combat readability without creating snag corridors.

## Acceptance Criteria

- `Relay Foundry` no longer places jump pads directly against high platforms.
- Player can run a continuous loop through each arena without obvious dead ends.
- Bot does not repeatedly jump into walls, ceilings or platform edges during passive-player smoke.
- Bot reaches vertical goals through staged jump pad/ramp routes.
- Automated validation passes and includes movement-flow coverage.
- Manual smoke checklist explicitly covers player movement feel and bot movement quality.

## Delivered

- Added movement-flow route contract coverage for all active layouts.
- Rebuilt `Relay Foundry V1` with a larger footprint, longer jump pad arcs, clearer approaches and less cramped high-platform geometry.
- Kept `Duel Pit V2` inside the new vertical route label contract.
- Updated bot vertical navigation to route through jump pad entries/targets before high-ground destinations.
- Added overhead clearance checks for bot jumps and temporary blocked-route penalties after stuck recovery.
- Added focused tests for Relay spacing and bot staged jump pad target selection.

## Validation Plan

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
git diff --check
git status --short
```

Final automated result:

- `tools/validate.gd`: PASS, GUT `23/23`, `201` asserts.
- Known warning class remains limited to GUT UID/text-path fallback warnings.

## Handoff

- Human smoke pending.
- Focus: player flow, jump pad approach/landing readability and bot wall/ceiling stuck behavior.
- Push pending: Fabio via GitHub Desktop (`origin` remote is Fabio-only).
