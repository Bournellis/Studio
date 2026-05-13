# Production Status

- Last Updated: `2026-05-13`
- Status: `Track 01 menu/save reform validated`

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
- map 5 unlocks the fixed class passive;
- map 7 unlocks the fixed class active;
- `iniciativa`, `defensor`, `reviver`, `enfraquecer`, `prender`, `promover`, and dynamic `poder de habilidade` are active;
- `Resolver Combate` runs combat before maintenance/script, with no separate enemy combat turn and no summoning sickness;
- menu/save reform validation is green with 18/18 GUT tests and 159 asserts.

## Present In Code

- Boot, ShipHub, RunMap, and Battle scenes.
- Boot as main menu, dedicated Deck and Almas scenes, and ShipHub visual navigation.
- `SaveManager` with 3 local JSON save slots under `user://`.
- `RunSession` with class, deck, health, max mana, max hand size, souls, completed nodes, automatic rewards, passive unlock, and active unlock state.
- Front-lane BattleEngine with simultaneous lane damage, direct lane damage, initiative, defender redirect, revive, weaken, snare, promote choices, ability power, waves, duel, defense position, survive turns, and summoner boss.
- Arcano, Invocador, and Necromante first-pass class mechanics gated by map unlocks.
- VisualAssets manifest and fallback reporting for missing optional PNGs.
- Contract validation and GUT tests for the current slice.

## Not Yet Final

- Player cards have a first redesigned catalog pass, but still need playtest tuning and final art/naming.
- Enemy names/stats/scripts are functional placeholders.
- Recompensas for maps 1, 4, 6, 8, 9, and 10 beyond souls are not yet defined.
- Card upgrades, removals, shops, and final reward UI are pending.

## Next Production Step

Playtest the reformed menu/save/hub flow with the redesigned 10-map route, then tune enemy pressure and distribute the remaining rewards.
