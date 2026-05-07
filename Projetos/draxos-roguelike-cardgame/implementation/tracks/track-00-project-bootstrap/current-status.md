# Track 00 Current Status

- Last Updated: `2026-05-07`
- Status: `P06_SUMMONER_BOSS_VALIDATED`
- Scope: `Create official project scaffold, local docs, validation, and first execution plan`

## Completed

- Official project directory created.
- Narrow RPG Turnos technical base copied.
- Local docs created.
- Local RunSession placeholder created.
- Local catalog reduced to placeholder cards and encounters.
- Boot scene script created.
- Validation adapted to bootstrap contract.
- Bootstrap validation green with 5/5 GUT tests.
- P01 local design contract recorded: Draxos commander, class-first gameplay identity, stable 5-card hand, soul reward bands, no meta-progression, and mainline/sidequest map placeholder.
- Catalog contracts now include encounter tier, enemy director, soul reward range, and run-map nodes.
- P01 validation green with 7/7 GUT tests.
- Generated ShipHub placeholder scene created.
- Boot scene can enter the ShipHub.
- ShipHub exposes clickable placeholder regions for command station, Grande Mestre, subordinados, map console, deck system, and soul engine.
- P02 validation green with 9/9 GUT tests.
- Generated RunMap placeholder scene created.
- ShipHub can open the RunMap and RunMap can return to ShipHub.
- RunMap displays catalog mainline/sidequest nodes and can select the first available node.
- RunSession tracks current node and completed node ids for placeholder unlocks.
- P03 validation green with 11/11 GUT tests.
- BattleEngine simplified to local slot-count board construction.
- RPG Turnos route, terrain, elevation, and neutral-slot assumptions removed from BattleEngine.
- Battle baseline supports draw-on-play, discard recycle, sacrifice replacement, and automatic front/fallback attacks.
- P04 validation green with 15/15 GUT tests.
- Generated Battle scene created.
- RunMap can launch the selected encounter into Battle.
- `pouso_elemental` starts with an enemy creature and can be won by clearing the board.
- Victory marks the selected run-map node completed.
- P05 validation green with 17/17 GUT tests.
- `chefe_invocador` now has boss health and scripted summon list.
- BattleEngine supports boss summoning over time and boss defeat through direct damage when the board is open.
- Battle scene can load the summoner boss from the RunMap node.
- P06 validation green with 21/21 GUT tests.

## Current Risk

The forked battle engine still contains RPG Turnos assumptions. It must be simplified before becoming the combat baseline.

## Next

Continue with `P07 - First Playable Checkpoint`.
