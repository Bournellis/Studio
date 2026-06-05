# Estudio Workspace

This workspace is the primary documentation and implementation home for the studio's Godot projects, coordination state and shared canon.

## Structure

- `canon/`: shared product, design, architecture, roadmap, platform truth, and lore context.
- `Projetos/draxos-roguelike-cardgame/`: active P0 implementation for the menu-first Draxos roguelike cardgame.
- `Projetos/draxos-mobile/`: active P2 implementation for DraxosMobile, currently at `OPENWORLD_MAIN_MENU_SYNC_PUBLISHED_INTERNAL_ALPHA`.
- `Projetos/_conceitos/mobile-universe/`: read-only DraxosMobile design archive.
- `Projetos/rpg-isometrico/`: paused historical Godot implementation for the campaign-first isometric action RPG.
- `Projetos/rpg-turnos/`: paused historical Godot implementation for a provisional turn-based RPG-cardgame sharing lore but owning separate mechanics.
- `migration/`: historical cutover archive, parity notes, and relocation records.
- `materiais/`: supporting guides and non-canonical studio material.
- `builds/`: generated build outputs and other disposable packages.

## Standard Read Order

For normal work inside `D:\Estudio`, start with:

1. `08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `AGENTS.md`
3. `Projetos/README.md`
4. `08_Coordenacao_Agentes/Estado_Atual.md`
5. `canon/canon-brief.md`
6. the target project `AGENTS.md`
7. the target project `implementation/current-status.md`

## Historical Context

- `Projetos/rpg-isometrico/implementation/phase-g1/` through `phase-g4/` preserve the closed Godot validation cycle.
- `migration/` preserves the workspace cutover context and legacy comparison notes.

No standard task in this workspace should require opening the external Unity repository.

## Project Boundary

Projects under `Projetos/` may share lore and studio conventions without sharing mechanics automatically.

`rpg-turnos` should not inherit RPG Isometrico's real-time action combat, loadout contract, or mode roadmap unless a local RPG Turnos document explicitly adopts those decisions.
