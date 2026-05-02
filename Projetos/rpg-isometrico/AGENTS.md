# AGENTS.md

This file governs agent behavior for the Godot implementation of RPG Isometrico.

## Project Role

This workspace is the active implementation home for RPG Isometrico.

Shared canon lives outside this project under:

- `../../canon/product/product-vision.md`
- `../../canon/design/game-design-document.md`
- `../../canon/design/progression-design.md`
- `../../canon/architecture/shared-architecture.md`
- `../../canon/architecture/game-mode-standard.md`
- `../../canon/roadmap/evolution-roadmap.md`
- `../../canon/roadmap/release-horizons.md`
- `../../canon/platform/steam-platform.md`

## Read Order

Before substantial work:

1. `../../canon/product/product-vision.md`
2. `../../canon/design/game-design-document.md`
3. `../../canon/design/progression-design.md`
4. `../../canon/architecture/shared-architecture.md`
5. `../../canon/architecture/game-mode-standard.md`
6. `../../canon/roadmap/evolution-roadmap.md`
7. `../../canon/roadmap/release-horizons.md`
8. `../../canon/platform/steam-platform.md`
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

If any historical validation document conflicts with shared canon, shared canon wins.

Do not treat old validation behavior as an implicit product decision.

## Validation Rule

Every meaningful active-track change should preserve:

- `tools/validate.gd` headless validation
- GUT test execution
- manual smoke expectations for the current playable loop
