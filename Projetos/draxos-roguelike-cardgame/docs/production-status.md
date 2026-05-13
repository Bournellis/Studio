# Production Status

- Last Updated: `2026-05-13`
- Status: `Track 01 sacrifice, movement, Cinzas and tuning validation green`

## Current Reality

The project is official in the Estudio workspace and has a Godot 4.6.2 playable slice with generated catalog, generated scenes, green validation, 3 save slots, 3 classes, 10 linear encounters, automatic run rewards, and a local BattleEngine using front-lane combat with the redesigned card baseline.

Track 01 now validates the current roguelike cardgame direction:

- class choice before run;
- mana initial 2 for all classes;
- redesigned starter decks with 12 cards, 4 types x 3 copies, and base hand limit 3;
- 10 mainline map nodes and all 6 encounter modes;
- automatic souls on every node;
- map 2 grants +1 max mana;
- map 3 grants +1 max hand size;
- map 5 unlocks the fixed class passive, and for Necromante also unlocks active level 1;
- map 7 unlocks the fixed class active, and for Necromante upgrades the active to level 2;
- `iniciativa`, `defensor`, `reviver`, `enfraquecer`, `prender`, `promover`, and dynamic `poder de habilidade` are active;
- `Resolver Combate` runs combat before maintenance/script, with no separate enemy combat turn and no summoning sickness;
- front attacks remain simultaneous, while overflow attacks resolve sequentially by lane and skip dead attackers/defenders;
- duel enemy AI plays new cards after combat/maintenance for the next player turn;
- summoning over allied creatures requires sacrifice confirmation, and adjacent occupied allied slots can swap if both creatures have movement;
- defense map 4 is a real hold objective with wave pressure, while survive map 6 has a light enemy buff;
- sacrifice/movement/Cinzas/tuning validation is green with 58/58 GUT tests and 409 asserts.

## Present In Code

- Boot, ShipHub, RunMap, and Battle scenes.
- Boot as main menu, dedicated Deck and Almas scenes, and ShipHub visual navigation.
- `SaveManager` with 3 local JSON save slots under `user://`.
- `RunSession` with class, deck, health, max mana, max hand size, souls, completed nodes, automatic rewards, passive unlock, active unlock state, and Necromante active level.
- Front-lane BattleEngine with simultaneous front damage, sequential overflow, direct lane damage, initiative, defender redirect, revive, weaken, snare, promote choices, ability power, waves, duel, defense position, survive turns, and summoner boss.
- Arcano, Invocador, and Necromante first-pass class mechanics gated by map unlocks.
- VisualAssets manifest and fallback reporting for missing optional PNGs.
- Contract validation and GUT tests for the current slice.

## Not Yet Final

- Player cards have a first redesigned catalog pass, but still need playtest tuning and final art/naming.
- Enemy names/stats/scripts are functional placeholders.
- Recompensas for maps 1, 4, 6, 8, 9, and 10 beyond souls are not yet defined.
- Card upgrades, removals, shops, and final reward UI are pending.

## Next Production Step

Playtest the sacrifice/movement/Cinzas tuning pass across the redesigned 10-map route, then replace alpha-debt ship overlays and distribute the remaining rewards.
