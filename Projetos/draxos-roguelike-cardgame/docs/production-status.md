# Production Status

- Last Updated: `2026-05-07`
- Status: `first playable checkpoint`

## Current Reality

The project is official in the Estudio workspace and has a Godot scaffold, local docs, green local validation, a reduced local catalog, copied reusable systems, and a first placeholder playable flow.

P01 has locked the first local design contract: the player is a Draxos commander, gameplay identity is class-based, runs have no meta-progression, souls are ship currency, and initial catalog contracts cover encounter tiers, enemy directors, soul bands, and a minimal mainline/sidequest map placeholder.

P02 adds a functional generated ShipHub placeholder. Boot can enter the ship bridge, and the hub exposes clickable placeholder regions for command station, Grande Mestre, subordinados, mission map, deck system, and soul engine.

P03 adds a generated RunMap placeholder. The ShipHub can open the map, the map displays catalog mainline/sidequest nodes, selecting an available node updates `RunSession`, and placeholder completion unlocks dependent nodes.

P04 replaces the inherited RPG Turnos battle fork with a narrow local BattleEngine. The local baseline now uses encounter slot counts, stable 5-card hand, draw-on-play, discard recycle, sacrifice replacement, and automatic front/fallback attacks.

P05 adds the first playable placeholder encounter. The RunMap can launch `pouso_elemental`, the Battle scene can play cards and end turns, clearing the enemy board wins the encounter, and victory marks the selected node completed.

P06 adds the first boss-summoner placeholder. `chefe_invocador` has boss health and scripted summons; the BattleEngine summons creatures over time and supports defeating the boss when the board is open.

P07 closes Track 00 as the first playable checkpoint. Track 01 P01 adds explicit class-placeholder run start from ShipHub. Track 01 P02 makes battle victory visible outside combat through RunSession, RunMap, and ShipHub state. Track 01 P03 adds a placeholder post-combat reward choice that mutates the current run immediately. It is not yet a full playable roguelike cardgame.

## Present In Code

- Godot project configuration.
- Boot scene script.
- `RunSession` placeholder.
- ShipHub placeholder scene and script.
- RunMap placeholder scene and script.
- Battle placeholder scene and script.
- Simplified local BattleEngine baseline.
- 3 placeholder class options.
- Explicit ShipHub run start that records selected class, deck, and health in `RunSession`.
- Visible post-battle placeholder state: completed node, last battle result, current health, and newly available map nodes.
- Pending placeholder reward after battle victory.
- RunMap reward choices that can add `Pulso Astral` to the run deck or reinforce health by +2.
- Local content catalog with placeholder cards, encounter contracts, soul reward bands, and map nodes.
- Local validation script.
- Track 00 validation record.
- Track 01 P03 validation green with 29/29 GUT tests and 238 asserts on 2026-05-07.
- Copied UI support systems.

## Not Yet Present

- Real roguelike node flow.
- Final class list and class mechanics.
- Final map chain and enemy scripts.
- Final deck size, upgrade, and removal rules.

## Next Production Step

Execute `P04 - Soul Currency And Paid Healing Placeholder`.
