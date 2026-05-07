# Production Status

- Last Updated: `2026-05-07`
- Status: `bootstrap scaffold`

## Current Reality

The project is official in the Estudio workspace and has a Godot scaffold, local docs, green local validation, a reduced local catalog, and copied reusable systems.

P01 has locked the first local design contract: the player is a Draxos commander, gameplay identity is class-based, runs have no meta-progression, souls are ship currency, and initial catalog contracts cover encounter tiers, enemy directors, soul bands, and a minimal mainline/sidequest map placeholder.

P02 adds a functional generated ShipHub placeholder. Boot can enter the ship bridge, and the hub exposes clickable placeholder regions for command station, Grande Mestre, subordinados, mission map, deck system, and soul engine.

P03 adds a generated RunMap placeholder. The ShipHub can open the map, the map displays catalog mainline/sidequest nodes, selecting an available node updates `RunSession`, and placeholder completion unlocks dependent nodes.

P04 replaces the inherited RPG Turnos battle fork with a narrow local BattleEngine. The local baseline now uses encounter slot counts, stable 5-card hand, draw-on-play, discard recycle, sacrifice replacement, and automatic front/fallback attacks.

It is not yet a playable roguelike cardgame.

## Present In Code

- Godot project configuration.
- Boot scene script.
- `RunSession` placeholder.
- ShipHub placeholder scene and script.
- RunMap placeholder scene and script.
- Simplified local BattleEngine baseline.
- Local content catalog with placeholder cards, encounter contracts, soul reward bands, and map nodes.
- Local validation script.
- P04 validation green with 15/15 GUT tests on 2026-05-07.
- Copied UI support systems.

## Not Yet Present

- Real roguelike node flow.
- Final class list and class mechanics.
- Final map chain and enemy scripts.
- Final deck size, upgrade, and removal rules.
- First playable encounter.
- Boss summoner behavior.

## Next Production Step

Execute `P05 - First Limpar Mesa`.
