# Track 01 Current Status

- Last Updated: `2026-05-12`
- Status: `P05_LINEAR_10_MAP_SLICE_VALIDATED`
- Scope: `First playable class and encounter slice after Track 00 checkpoint`

## Completed

- Track 00 checkpoint committed and closed.
- P01-P03 placeholder loop validated previously: class selection, explicit run start, map selection, battle return, visible state, and immediate reward mutation.
- Catalog now exposes the three real slice classes: `arcano`, `invocador`, and `necromante`.
- Each class has a mockup starter deck, starting health 20, starting mana 2, and no cost 3 cards in the starter list.
- RunSession records class, deck, health, max mana, souls, completed nodes, automatic rewards, passive unlock, active unlock, and last battle state.
- ShipHub exposes the real class choices and paid healing with souls.
- RunMap exposes 10 linear mainline nodes with no sidequests for this slice.
- Automatic rewards are active: map 2 grants +1 max mana, map 3 adds current cost 3 cards, map 5 unlocks the class passive, and map 7 unlocks the class active.
- Battle receives current run class, deck, health, and mana.
- Battle exposes drag-and-drop targeting for hand cards and unlocked class spells.
- Battle exposes a hover preview for hand cards, field occupants, class spells, slots, and hero targets when present.
- Necromante's class spell exposes a choice modal for Lentidao, Podridao, Confusao, and reanimation choices.
- BattleEngine implements front-lane combat, simultaneous opposed-lane damage, direct lane damage, `iniciativa`, and `regeneracao`.
- BattleEngine implements first-pass Arcano `Fluxo Continuo`, Invocador permanent buffs, Necromante `Cinzas`, death hooks, debuffs, and reanimation with passives locked until map 5 and actives hidden/locked until map 7.
- BattleEngine implements sequential waves, duel hero kill, defense position, survive turns, and scripted summoner bosses.
- BattleEngine shuffles the run deck deterministically on battle start and when discard recycles into the deck.
- Visual support V1 adds `VisualAssets`, `data/definitions/visual_assets.json`, optional PNG fallback reporting, asset READMEs, and an AI art guide.
- ShipHub, RunMap, and Battle now have visual background slots with themed fallbacks.
- RunMap now presents the route as visual markers positioned by the visual manifest.
- Battle cards now use a portrait visual contract with image area, frame slot, text area, and floating base mana/ATK/HP badges; spells show only the floating mana badge.
- Battle field slots now render compact card-shaped sockets; occupied slots show card art/fallbacks with floating base mana cost, current ATK, and current HP from `BattleEngine`.
- Battle field previews now call out current stats against base card stats when buffs, damage, debuffs, regeneration, or reanimation alter the occupant.
- Card text supports simple visual templates backed by mechanical values for obvious current cards.
- ShipHub now uses 4 primary scene hotspots for Comando, Mapa, Deck, and Almas instead of the previous large grid.
- RunMap now draws route connections directly over the planet background with compact node labels.
- Battle now uses an objective-focused HUD: player HP/mana/resource dock, class-resource visibility by selected class, right-side end-turn button, ESC menu for map/menu/quit, compact log button, and no constant encounter text.
- Duel encounters now opt into `enemy_commander_enabled`, exposing enemy HP/mana HUD and partial mockup cardbacks while leaving enemy card AI out of scope.
- VisualAssets now records provisional background/frame debt and only uses frame overlays when `overlay_safe` is true.
- Screenshot capture tool generates ShipHub/RunMap/Battle screenshots at 1280x720 and 960x540 under `builds/`.
- Validation green with 48/48 GUT tests and 434 asserts; 37 PNGs are reported missing by design.

## Current Risk

The slice is mechanically playable but not balanced. The 10-map route uses functional enemy mockups, cost 3 cards are temporarily released all at once on map 3, several maps only grant souls, most card art is still absent, enemy cardback art is still pending, Invocador/Necromante frames are not alpha-safe overlays, backgrounds are accepted as provisional 16:9 `1456x816`, and final card/class naming still needs a dedicated content pass.

## Next

Playtest the full 10-map route, then redesign cards/enemies and distribute the remaining non-soul rewards.
