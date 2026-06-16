# Track 06 - Arena Variety And Bot Generalization V1

- Status: `READY_FOR_HUMAN_SMOKE`
- Planned: `2026-06-16`
- Implemented: `2026-06-16`
- Owner: Codex
- Execution branch: `codex/fpsplayground/track06-arena-variety-bot-generalization-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track06-arena-variety-bot-generalization-v1`
- Base: Track 05B approved by Fabio.

## Why This Track Comes Next

Track 05B proved the current bot can feel good in the accepted arenas after route-control and long jump pad fixes. The next risk is generalization: the bot may still be too dependent on the current two arena shapes.

Track 06 should create a third arena with a different rhythm and use it to prove the map contracts, route labels, jump pad physics and bot objective logic are reusable.

## Delivered

- Added `Crossfire Crucible V1` as the third selectable Arena Shooter layout.
- Built a compact crossfire arena with a low-ground loop, diagonal high route, core sightline break, separated item routes and two distinct jump pad route lengths.
- Published layout catalog, jump pad routes and tactical points for pressure, cover, flank, retreat, health, overcharge, jump pad entry, jump pad landing and high ground.
- Reused the existing route-first bot movement and combat overlay behavior without adding map-specific bot conditionals.
- Added menu, runtime and helper tests for three-arena selection, required tactical roles, context label delivery and jump pad route contracts.

## Validation Result

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
# PASS, GUT 32/32, 289 asserts
```

Known accepted noise: GUT UID/text-path warnings after fresh worktree import.

## Human Smoke Handoff

Track 06 is ready for Fabio/tester smoke. Focus the playtest on:

- launching all three arenas from the menu;
- running a full low-ground loop in `Crossfire Crucible V1`;
- using both `Crossfire Crucible V1` jump pads from natural movement speed;
- confirming health and overcharge pull different routes;
- watching the bot rotate through the new arena without freezing, wall-rubbing or repeating one route forever;
- confirming the bot keeps shooting as combat overlay without canceling movement objectives.

## Product Goal

Add one new 1x1 arena that feels meaningfully different from `Duel Pit V2` and `Relay Foundry V1`, while preserving the approved bot behavior:

- player movement remains readable and continuous;
- bot movement is driven by arena contracts, not map-specific code;
- items create routing decisions instead of awkward detours;
- jump pads and vertical connectors are reliable on first use;
- shooting remains an overlay during movement, not a route canceller.

## Arena Direction

Recommended arena concept: `Crossfire Crucible V1`.

Design intent:

- a compact cross-shaped central fight space;
- one fast low-ground loop around the center;
- one diagonal high route that changes sightlines instead of mirroring the existing foundry route;
- one short vertical connector and one longer route connector, but not two identical long pads;
- health and overcharge separated so stack decisions force different routes;
- cover used to break sightlines without creating dead ends or ceiling traps.

This arena should be less wide than `Relay Foundry V1`, less symmetric than `Duel Pit V2`, and more focused on route timing through the center.

## Required Pre-Step Documentation

Before implementation, read and keep open:

1. `Projetos/FpsPlayground/AGENTS.md`
2. `Projetos/FpsPlayground/implementation/current-status.md`
3. `Projetos/FpsPlayground/docs/work-plan.md`
4. `Projetos/FpsPlayground/docs/arena-tactical-layouts.md`
5. `Projetos/FpsPlayground/docs/bot-tactical-context.md`
6. `Projetos/FpsPlayground/docs/bot-route-control.md`
7. `Projetos/FpsPlayground/docs/validation.md`

## Implementation Plan

### Step 1 - Layout Contract First

- Define the new arena id, display name and route labels in `ArenaLayoutCatalog`.
- Sketch the intended ground loop, vertical connector and item routes in code comments or compact local doc notes.
- Choose route names that describe function, not coordinates.
- Keep roles sparse enough that bot debug reasoning remains readable.

Acceptance:

- the catalog exposes three distinct layouts;
- the new layout has stable id/display/map names;
- route names are reused consistently across jump pad entry, landing, high ground and item points.

### Step 2 - Build The Arena Geometry

- Add runtime geometry for the new arena without hand-editing generated `.tscn` files.
- Preserve generous collision margins around spawn points, pickup pockets, jump pad approaches and landings.
- Ensure the player can run a complete low-ground loop without sharp catches.
- Ensure the high route has a clear entry, a readable landing and a useful drop/re-entry to the ground loop.

Acceptance:

- player and bot spawns are clear;
- health and overcharge are reachable without clipping or edge catches;
- jump pad approach lanes are not blocked by cover or platforms;
- high route landing is not glued to a ceiling/wall/platform edge.

### Step 3 - Publish Tactical Context

- Add tactical points for pressure, flank, cover, retreat, health, overcharge, jump pad entry, jump pad landing and high ground.
- Weight points to express the arena's intended rhythm, not to force one scripted route.
- Avoid adding bot conditionals that mention the new arena id.

Acceptance:

- the bot receives the active arena context after spawn/restart;
- the bot can choose new arena points using the existing scoring model;
- no new map-specific bot code is required.

### Step 4 - Prove Bot Generalization

- Add focused tests that build the new layout and inspect its contracts.
- Add tests proving the bot can score/use the new context without `Duel Pit V2` or `Relay Foundry V1` assumptions.
- Add first-use reliability tests for any jump pad route whose geometry differs meaningfully from the previous maps.

Acceptance:

- full validation passes;
- tests fail if the new arena omits required tactical roles;
- tests fail if route labels break staged vertical navigation.

### Step 5 - Menu, Smoke And Documentation

- Add the new arena to the Arena Shooter menu selection.
- Update validation smoke with Track 06 checks.
- Update documentation index and current status.
- Keep Track 06 focused on arena variety and bot generalization only.

Acceptance:

- all three arenas are selectable from the menu;
- manual smoke can compare movement in `Duel Pit V2`, `Relay Foundry V1` and `Crossfire Crucible V1`;
- Track 06 closes only when the new arena feels playable and the bot remains competent without special-case behavior.

## Automated Validation Targets

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
git diff --check
powershell -ExecutionPolicy Bypass -File D:\Estudio\tools\check_doc_drift.ps1
git status --short
```

Expected test additions:

- layout catalog exposes the new arena with distinct id and tactical context;
- new arena publishes required roles;
- new arena publishes route-consistent jump pad entry/landing/high-ground contracts;
- bot can score movement in the new arena without hardcoded points from older arenas;
- menu exposes the third arena.

## Manual Smoke Targets

- Launch each arena from the menu and confirm the accepted baseline still works.
- In the new arena, run one full low-ground loop without catching on geometry.
- In the new arena, use every jump pad/vertical connector from natural movement speed.
- Confirm health and overcharge create different route decisions.
- Stand passive and watch the bot rotate through routes instead of freezing, wall-rubbing or repeating one route forever.
- Confirm the bot still shoots while moving without canceling its route.
- Confirm restart with `R`, pause and return to menu still work.

## Non-Goals

- No new weapon.
- No new bot aim/damage tuning spike.
- No final art pass.
- No export, Web/mobile, multiplayer or backend.
- No broad combat redesign.
- No rewrite of the bot state machine unless required by a failing generalization contract.

## Risks And Guardrails

- Risk: a new arena can look valid in tests but feel bad in hand movement. Guardrail: manual smoke must prioritize player route feel before tactical density.
- Risk: adding many tactical points can make bot behavior noisy. Guardrail: start sparse, then add only points that serve an observed route.
- Risk: jump pads can reintroduce first-use failures. Guardrail: any long or unusual connector needs first-attempt coverage.
- Risk: the new arena becomes another version of `Relay Foundry V1`. Guardrail: choose a distinct route rhythm: compact crossfire, diagonal high pressure and separated item routes.

## Review Status

Track 06 is in Review because:

- the third arena is playable from the menu;
- full validation passes;
- docs and smoke checklist are updated;
- no map-specific bot code was added;
- the bot uses the new arena's context with route-first movement;
- the player can move through the arena without obvious geometry catches.
