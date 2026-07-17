# AGENTS.md

This file governs agent behavior for the Godot implementation of RPG Isometrico.

## Project Role

This workspace is the active implementation home for RPG Isometrico.

Product canon lives locally under `docs/canon/`. Shared lore lives under `../../canon/shared-lore/`. Neither location carries operational state.

## Read Order

Before substantial work:

1. `docs/canon/product/product-vision.md`
2. `docs/canon/design/game-design-document.md`
3. `docs/canon/design/progression-design.md`
4. `docs/canon/architecture/shared-architecture.md`
5. `docs/canon/architecture/game-mode-standard.md`
6. `docs/canon/roadmap/evolution-roadmap.md`
7. `docs/canon/roadmap/release-horizons.md`
8. `docs/canon/platform/steam-platform.md`
9. `implementation/current-status.md`
10. the active track under `implementation/tracks/`
11. this file

For bounded work:

1. `../../canon/canon-brief.md`
2. `implementation/current-status.md`
3. the active track `current-status.md` when the task belongs to active work
4. touched files

## Current Technical Base

- Engine: Godot `4.6.2-stable`
- Language: GDScript only
- Tests: GUT `9.6.0`
- Content source of truth: JSON definitions that generate Godot resources

## Historical Validation Background

`implementation/phase-g1/` through `phase-g4/` preserve the closed Godot validation cycle that proved this project can carry the core runtime locally.

They are historical context, not the active operational surface.

## Scene Rule

Default rule:

- playable scenes are editor-owned
- generation is allowed for data, catalogs, and repetitive cases

Agents must not hand-edit `.tscn` files as raw text. If a scene must be created or changed without the editor, use a Godot script/tool to generate it.

## Canon Rule

If any historical validation document conflicts with local product canon or shared lore, the applicable current authority wins.

Do not treat old validation behavior as an implicit product decision.

## Validation Rule

Every meaningful active-track change should preserve:

- `tools/validate.gd` headless validation
- GUT test execution
- manual smoke expectations for the current playable loop
