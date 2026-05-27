# Shared Canon

This directory is the shared engine-neutral source of truth for established studio canon.

Most current product, gameplay, progression, roadmap, and platform documents still describe RPG Isometrico. Shared lore lives under `lore/`. New projects may reuse shared lore context, but they must not treat RPG Isometrico mechanics as automatic canon.

DraxosMobile has local product canon in `D:\Estudio\Projetos\draxos-mobile\docs\product-vision.md` until specific parts are promoted into this shared canon. Draxos Roguelike Cardgame also owns its local product/gameplay contracts. Do not copy RPG Isometrico product rules into these projects by default.

## Authority

For RPG Isometrico, this canon governs:

- shared lore context
- product identity
- gameplay and loadout contracts
- progression model
- shared architecture boundaries
- mandatory game-mode structure
- roadmap direction
- platform strategy

## Read Order

1. `lore/shared-lore.md`
2. `lore/draxos-invasion.md` when working on RPG Turnos lore/content
3. `lore/immortals.md` when working on RPG Isometrico Imortais lore/content
4. `product/product-vision.md`
5. `design/game-design-document.md`
6. `design/progression-design.md`
7. `architecture/shared-architecture.md`
8. `architecture/game-mode-standard.md`
9. `roadmap/evolution-roadmap.md`
10. `roadmap/release-horizons.md`
11. `platform/steam-platform.md`

## Boundary

This canon does not carry:

- active implementation status
- engine-local execution logs
- track or phase ownership
- legacy runtime snapshots

New project-specific mechanics belong in the local project docs until they are promoted into shared canon.

## Operational Docs

Engine-local operational documentation belongs in the Godot workspace:

- `D:\Estudio\Projetos\draxos-roguelike-cardgame\implementation\current-status.md`
- `D:\Estudio\Projetos\draxos-mobile\docs\product-vision.md`
- `D:\Estudio\Projetos\draxos-mobile\implementation\current-status.md`
- `D:\Estudio\Projetos\rpg-isometrico\implementation\current-status.md`
- `D:\Estudio\Projetos\rpg-turnos\implementation\current-status.md`
- active tracks under `D:\Estudio\Projetos\draxos-roguelike-cardgame\implementation\tracks\`
- active tracks under `D:\Estudio\Projetos\draxos-mobile\implementation\tracks\`
- the active track under `D:\Estudio\Projetos\rpg-isometrico\implementation\tracks\`
- future active tracks under `D:\Estudio\Projetos\rpg-turnos\implementation\tracks\`

Historical validation and cutover context live outside canon and must not be mistaken for product truth.
