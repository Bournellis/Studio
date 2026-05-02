# Estudio Workspace

This workspace is the primary documentation and implementation home for the studio's Godot projects and shared canon.

## Structure

- `canon/`: shared product, design, architecture, roadmap, platform truth, and lore context.
- `Projetos/rpg-isometrico/`: active Godot implementation for the campaign-first isometric action RPG.
- `Projetos/rpg-turnos/`: initial Godot implementation for a provisional turn-based RPG sharing lore but owning separate mechanics.
- `migration/`: historical cutover archive, parity notes, and relocation records.
- `materiais/`: supporting guides and non-canonical studio material.
- `builds/`: generated build outputs and other disposable packages.

## Standard Read Order

For normal work inside `D:\Estudio`, start with:

1. `canon/`
2. the target project `AGENTS.md`
3. the target project `implementation/current-status.md`
4. the active track under the target project `implementation/tracks/`

## Historical Context

- `Projetos/rpg-isometrico/implementation/phase-g1/` through `phase-g4/` preserve the closed Godot validation cycle.
- `migration/` preserves the workspace cutover context and legacy comparison notes.

No standard task in this workspace should require opening the external Unity repository.

## Project Boundary

Projects under `Projetos/` may share lore and studio conventions without sharing mechanics automatically.

`rpg-turnos` should not inherit RPG Isometrico's real-time action combat, loadout contract, or mode roadmap unless a local RPG Turnos document explicitly adopts those decisions.
