# AGENTS.md

This file governs agent behavior for the `D:\Estudio` workspace.

## Workspace Roles

- `canon/` is the shared source of truth for established product identity, lore context, gameplay contracts, progression, shared architecture, mode standard, and platform strategy.
- `Projetos/rpg-isometrico/` is the active Godot implementation workspace for the campaign-first isometric action RPG.
- `Projetos/rpg-turnos/` is the initial Godot implementation workspace for a provisional turn-based RPG-cardgame that may share studio lore but owns separate mechanics.
- `migration/` is a historical archive for cutover, relocation, and legacy comparison context.

## Read Order

Before substantial work in this workspace, read:

1. `canon/product/product-vision.md`
2. `canon/design/game-design-document.md`
3. `canon/design/progression-design.md`
4. `canon/architecture/shared-architecture.md`
5. `canon/architecture/game-mode-standard.md`
6. `canon/roadmap/evolution-roadmap.md`
7. `canon/roadmap/release-horizons.md`
8. `canon/platform/steam-platform.md`
9. the local project `AGENTS.md`
10. the local project `implementation/current-status.md`
11. this file

For bounded work, start with:

1. `canon/canon-brief.md`
2. the local project `AGENTS.md`
3. the local project `implementation/current-status.md`
4. the touched files

## Canon Rule

If shared canon conflicts with any historical implementation note, shared canon wins.

Do not silently treat historical runtime behavior as canon.

Do not silently apply one project's mechanics to another project. `rpg-turnos` may share lore with `rpg-isometrico`, but RPG Isometrico's real-time action loadout and mode contracts are not RPG Turnos canon unless a local RPG Turnos document explicitly adopts them.

## Historical Context Rule

The default flow for this workspace lives entirely inside `D:\Estudio`.

If historical context is needed, consult in this order:

1. `migration/`
2. `Projetos/rpg-isometrico/implementation/phase-g1/` through `phase-g4/`
3. only then any external legacy repository if the task is explicitly historical

## Godot Rule

Godot implementation surfaces live under `Projetos/`.

Current Godot projects:

- `Projetos/rpg-isometrico/`
- `Projetos/rpg-turnos/`

When working in Godot:

1. consult shared canon first
2. consult `implementation/current-status.md` second
3. consult the local project `AGENTS.md` and active track under `implementation/tracks/` third
4. consult historical validation docs only when they answer a specific question

Use relative paths when referencing shared canon from a Godot project.
