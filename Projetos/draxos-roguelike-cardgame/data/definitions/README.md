# Definitions

Source definitions for authored Draxos roguelike cardgame content live here.

Current active sources:

- `slice_catalog.json`: Track 02 complete-run source of truth with Arcano, Invocador, Necromante, fixed 29-map route, save/snapshot v5 contract metadata, reward schedule, relics, expanded shop, keyword/status vocabulary, class reward pools, enemy galleries, encounter modes, board formats, field effects, boss hooks, and validation contracts.
- `visual_assets.json`: Visual support manifest with surface backgrounds, card art paths, card frame paths, ship overlays, and run-map marker positions. PNGs remain optional for the current foundation pass and use runtime fallbacks when missing.

Foundation hardening 7 added `tools/catalog_source_loader.gd` as the composition seam. It still loads the current single JSON source, but exposes domain slices for cards, enemies, classes, rewards, relics, encounters, run map, keywords and visuals so a future split can preserve semantic equivalence.

Generated outputs under `data/generated/` must be produced by tools and stay idempotent when authored JSON is semantically unchanged.
