# Shared Canon

This directory is the shared engine-neutral source of truth for established studio canon.

Most current product, gameplay, progression, roadmap, and platform documents describe RPG Isometrico. New projects may reuse shared lore context, but they must not treat RPG Isometrico mechanics as automatic canon.

## Authority

For RPG Isometrico, this canon governs:

- product identity
- gameplay and loadout contracts
- progression model
- shared architecture boundaries
- mandatory game-mode structure
- roadmap direction
- platform strategy

## Read Order

1. `product/product-vision.md`
2. `design/game-design-document.md`
3. `design/progression-design.md`
4. `architecture/shared-architecture.md`
5. `architecture/game-mode-standard.md`
6. `roadmap/evolution-roadmap.md`
7. `roadmap/release-horizons.md`
8. `platform/steam-platform.md`

## Boundary

This canon does not carry:

- active implementation status
- engine-local execution logs
- track or phase ownership
- legacy runtime snapshots

New project-specific mechanics belong in the local project docs until they are promoted into shared canon.

## Operational Docs

Engine-local operational documentation belongs in the Godot workspace:

- `D:\Estudio\Projetos\rpg-isometrico\implementation\current-status.md`
- `D:\Estudio\Projetos\rpg-turnos\implementation\current-status.md`
- the active track under `D:\Estudio\Projetos\rpg-isometrico\implementation\tracks\`
- future active tracks under `D:\Estudio\Projetos\rpg-turnos\implementation\tracks\`

Historical validation and cutover context live outside canon and must not be mistaken for product truth.
