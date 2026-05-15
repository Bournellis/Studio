# Production Status

- Last Updated: `2026-05-15`
- Status: `Track 01 13-map early-game reward update validation green`

## Current Reality

The project is official in the Estudio workspace and has a Godot 4.6.2 playable slice with generated catalog, generated scenes, green validation, 3 save slots, 3 classes, 13 linear encounters, fixed and choice-based run rewards, and a local BattleEngine using front-lane combat.

Track 01 now validates the current roguelike cardgame direction:

- class choice before run;
- mana inicial 1 for all classes;
- starter decks with 9 cost-1 cards, 3 types x 3 copies, and base hand limit 3;
- map 1 grants +1 max mana;
- map 2 grants 3 copies of the class cost-2 core card;
- map 5 grants +1 max mana;
- map 6 grants +1 max hand size;
- maps 3, 4, 6, 9, and 12 grant upgrade choices, 1 in 3;
- maps 7 and 11 grant new-card choices, 1 in 3, adding 3 copies;
- map 8 unlocks the fixed class passive, and for Necromante also unlocks active level 1;
- map 10 unlocks the fixed class active, and for Necromante upgrades the active to level 2;
- `iniciativa`, `defensor`, `reviver`, `enfraquecer`, `prender`, `promover`, and dynamic `poder de habilidade` are active;
- `Resolver Combate` runs combat before maintenance/script, with no separate enemy combat turn and no summoning sickness;
- front attacks remain simultaneous, while overflow attacks resolve sequentially by lane and skip dead attackers/defenders;
- duel enemy AI plays new cards after combat/maintenance for the next player turn;
- summoning over allied creatures requires sacrifice confirmation, and adjacent occupied allied slots can swap if both creatures have movement;
- defense map 7 is a real hold objective with wave pressure, while survive map 9 has a light enemy buff;
- validation is green with 59/59 GUT tests and 442 asserts.

## Present In Code

- Boot, ShipHub, RunMap, Deck, Almas, and Battle scenes.
- Boot as main menu and ShipHub visual navigation.
- `SaveManager` with save version 2; old save files are intentionally invalidated by the 13-map route update.
- `RunSession` with class, deck, health, max mana, max hand size, souls, completed nodes, fixed rewards, pending reward choices, card upgrade counts, passive unlock, active unlock state, and Necromante active level.
- Front-lane BattleEngine with simultaneous front damage, sequential overflow, direct lane damage, initiative, defender redirect, revive, weaken, snare, promote choices, ability power, waves, duel, defense position, survive turns, and summoner boss.
- Arcano, Invocador, and Necromante class mechanics gated by map unlocks.
- Placeholder reward pools for future class cards.
- Placeholder upgrade tracking without final upgrade mechanics.
- VisualAssets manifest and fallback reporting for missing optional PNGs.
- Contract validation and GUT tests for the current slice.

## Not Yet Final

- Exact upgrade branches are A definir in a design session.
- Exact new reward cards are A definir in a design session.
- Placeholder reward cards are mechanically minimal and should not be treated as final class kits.
- Enemy names/stats/scripts are functional placeholders.
- Card art is still provisional or missing for many cards.

## Next Production Step

Run a design session for upgrade branches and class reward cards, then playtest the full 13-map route.
