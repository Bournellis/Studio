# Track 01 Current Status

- Last Updated: `2026-05-07`
- Status: `P04_MECHANICAL_CLASS_SLICE_VALIDATED`
- Scope: `First playable class and encounter slice after Track 00 checkpoint`

## Completed

- Track 00 checkpoint committed and closed.
- P01-P03 placeholder loop validated previously: class selection, explicit run start, map selection, battle return, visible state, and immediate reward mutation.
- Catalog now exposes the three real slice classes: `arcano`, `invocador`, and `necromante`.
- Each class has a 15-card mockup starter deck, starting health 20, and starting mana 3.
- RunSession records class, deck, health, mana, souls, pending rewards, applied rewards, completed nodes, and last battle state.
- ShipHub exposes the real class choices and paid healing with souls.
- RunMap exposes the clear-board first encounter, the waves second encounter, and an optional elite side node.
- Battle receives current run class, deck, health, and mana.
- Battle exposes a class active button.
- BattleEngine implements first-pass Arcano `Fluxo Continuo`, Invocador permanent buffs and keywords, Necromante `Cinzas`, death hooks, debuffs, and reanimation.
- BattleEngine implements sequential waves and keeps scripted boss summons.
- BattleEngine shuffles the run deck deterministically on battle start and when discard recycles into the deck.
- Validation green with 22/22 GUT tests and 165 asserts.

## Current Risk

The slice is mechanically playable but not balanced. Targeting is still automated for speed of testing, class active names are still provisional, and class/debuff keyword vocabulary needs a dedicated schema pass before content grows.

## Next

Playtest the three classes against `pouso_elemental` and `ondas_iniciais`, then tune card numbers, encounter pressure, target selection UX, and reward options.
