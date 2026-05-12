# Production Status

- Last Updated: `2026-05-12`
- Status: `Track 01 linear 10-encounter slice validated`

## Current Reality

The project is official in the Estudio workspace and has a Godot 4.6.2 playable slice with generated catalog, generated scenes, green validation, 3 classes, 10 linear encounters, automatic run rewards, and a local BattleEngine using front-lane combat.

Track 01 now validates the current roguelike cardgame direction:

- class choice before run;
- mana initial 2 for all classes;
- starter decks without cost 3 cards;
- 10 mainline map nodes and all 6 encounter modes;
- automatic souls on every node;
- map 2 grants +1 max mana;
- map 3 adds current playable cost 3 cards;
- map 5 unlocks the fixed class passive;
- map 7 unlocks the fixed class active;
- `iniciativa` replaces `protecao` and `voadora`;
- validation green with 41/41 GUT tests and 351 asserts.

## Present In Code

- Boot, ShipHub, RunMap, and Battle scenes.
- `RunSession` with class, deck, health, max mana, souls, completed nodes, automatic rewards, passive unlock, and active unlock state.
- Front-lane BattleEngine with simultaneous lane damage, direct lane damage, initiative, waves, duel, defense position, survive turns, and summoner boss.
- Arcano, Invocador, and Necromante first-pass class mechanics gated by map unlocks.
- VisualAssets manifest and fallback reporting for missing optional PNGs.
- Contract validation and GUT tests for the current slice.

## Not Yet Final

- Cards are still mockups and will be redesigned.
- Enemy names/stats/scripts are functional placeholders.
- Recompensas for maps 1, 4, 6, 8, 9, and 10 beyond souls are not yet defined.
- Card upgrades, removals, shops, and final reward UI are pending.

## Next Production Step

Playtest the full 10-map route, then redesign the card catalog and distribute the remaining rewards.
