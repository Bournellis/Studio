# Production Status

- Last Updated: `2026-05-15`
- Status: `Track 01 real upgrades and reward cards validation green`

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
- maps 3, 4, 9, and 12 grant upgrade choices;
- maps 7 and 11 grant new-card choices, adding 3 copies; map 7 offers the 2 class cards, map 11 offers the remaining card;
- map 8 unlocks the fixed class passive, and for Necromante also unlocks active level 1;
- map 10 unlocks the fixed class active, and for Necromante upgrades the active to level 2;
- card upgrades now produce real Lvl 2/Lvl 3 variants through `card_upgrade_counts`;
- new cards are active: Arcano `Bola de Fogo`/`Acelerar`, Invocador `Atacar`/`Golem`, Necromante `Carniceiro`/`Punir`;
- `iniciativa`, `defensor`, `reviver`, `regeneracao`, `carnica`, `enfraquecer`, `prender`, `remover keywords`, `promover`, and dynamic `poder de habilidade` are active;
- adjacent damage, temporary mana, temporary spell power, temporary all-ally buffs, Punir on snared targets, and delayed automatic target choices are active;
- `Resolver Combate` runs combat before maintenance/script, with no separate enemy combat turn and no summoning sickness;
- front attacks remain simultaneous, while overflow attacks resolve sequentially by lane and skip dead attackers/defenders;
- duel enemy AI plays new cards after combat/maintenance for the next player turn;
- summoning over allied creatures requires sacrifice confirmation, and adjacent occupied allied slots can swap if both creatures have movement;
- defense map 7 is a real hold objective with heavier wave pressure, and maps 7-13 have stronger late-run pressure;
- validation is green with 65/65 GUT tests and 511 asserts.

## Present In Code

- Boot, ShipHub, RunMap, Deck, Almas, and Battle scenes.
- Boot as main menu and ShipHub visual navigation.
- `SaveManager` with save version 3; v2 save files are intentionally invalidated, still shown as old/invalid, deletable, and overwritable.
- `RunSession` with class, deck, health, max mana, max hand size, souls, completed nodes, fixed rewards, pending reward choices, card upgrade counts, passive unlock, active unlock state, and Necromante active level.
- Front-lane BattleEngine with simultaneous front damage, sequential overflow, direct lane damage, initiative, defender redirect, revive, regeneration, carrion, weaken, snare, keyword removal, punish-snared, promote choices, ability power, waves, duel, defense position, survive turns, and summoner boss.
- Arcano, Invocador, and Necromante class mechanics gated by map unlocks.
- Real 2-card reward pools for each class.
- Real upgrade variants for current starter, map-2, and new reward cards.
- VisualAssets manifest and fallback reporting for missing optional PNGs.
- Contract validation and GUT tests for the current slice.

## Not Yet Final

- Balance of upgrades/new cards is provisional until full-route playtest.
- Future expansion from 2 reward cards per class toward 6-8 cards remains a design decision.
- Enemy names/scripts are functional placeholders, though late-map pressure was increased.
- Card art is still provisional or missing for many cards.

## Next Production Step

Playtest the full 13-map route with save v3, real upgrades, new cards, and stronger maps 7-13; then tune difficulty/reward cadence.
