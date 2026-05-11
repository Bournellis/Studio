# Track 01 Current Status

- Last Updated: `2026-05-11`
- Status: `P05_VISUAL_SUPPORT_V1_VALIDATED`
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
- Battle exposes drag-and-drop targeting for hand cards and class spells.
- Battle exposes a hover preview for hand cards, field occupants, class spells, slots, and hero targets when present.
- Necromante's class spell exposes a choice modal for Lentidao, Podridao, Confusao, and reanimation choices.
- BattleEngine implements first-pass Arcano `Fluxo Continuo`, Invocador permanent buffs and keywords, Necromante `Cinzas`, death hooks, debuffs, and reanimation.
- BattleEngine implements sequential waves and keeps scripted boss summons.
- BattleEngine shuffles the run deck deterministically on battle start and when discard recycles into the deck.
- Visual support V1 adds `VisualAssets`, `data/definitions/visual_assets.json`, optional PNG fallback reporting, asset READMEs, and an AI art guide.
- ShipHub, RunMap, and Battle now have visual background slots with themed fallbacks.
- RunMap now presents the route as visual markers positioned by the visual manifest.
- Battle cards now use a portrait visual contract with image area, frame slot, text area, cost, ATK, and HP rendered by UI.
- Card text supports simple visual templates backed by mechanical values for obvious current cards.
- Validation green with 32/32 GUT tests and 230 asserts; 37 PNGs are reported missing by design.

## Current Risk

The slice is mechanically playable but not balanced. Targeting UX and visual support V1 are implemented, but PNGs are still absent/provisional, class active names are still provisional, and class/debuff keyword vocabulary needs a dedicated schema pass before content grows.

## Next

Add provisional AI PNGs to the manifest paths, then playtest the three classes against `pouso_elemental` and `ondas_iniciais`; tune card numbers, encounter pressure, readability details, and reward options.
