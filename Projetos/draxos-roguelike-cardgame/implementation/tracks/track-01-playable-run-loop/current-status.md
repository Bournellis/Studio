# Track 01 Current Status

- Last Updated: `2026-05-13`
- Status: `P11_SACRIFICE_MOVEMENT_NECRO_TUNING_VALIDATED`
- Scope: `First playable class and encounter slice after Track 00 checkpoint`

## Completed

- Track 00 checkpoint committed and closed.
- P01-P03 placeholder loop validated previously: class selection, explicit run start, map selection, battle return, visible state, and immediate reward mutation.
- Catalog now exposes the three real slice classes: `arcano`, `invocador`, and `necromante`.
- Each class has a redesigned 12-card starter deck, starting health 20, starting mana 2, and base hand limit 3.
- RunSession records class, deck, health, max mana, max hand size, souls, completed nodes, automatic rewards, passive unlock, active unlock, and last battle state.
- ShipHub exposes the real class choices and paid healing with souls.
- RunMap exposes 10 linear mainline nodes with no sidequests for this slice.
- Automatic rewards are active: map 2 grants +1 max mana, map 3 grants +1 max hand size, map 5 unlocks the class passive, and map 7 unlocks the class active.
- Battle receives current run class, deck, health, and mana.
- Battle exposes drag-and-drop targeting for hand cards and unlocked class spells.
- Battle exposes a hover preview for hand cards, field occupants, class spells, slots, and hero targets when present.
- Necromante's class spell exposes a choice modal for Podridao, temporary attack buffs, and level 2 reanimation choices.
- BattleEngine implements four-stage combat (`Iniciativa - Frente`, `Iniciativa - Sobra`, `Combate - Frente`, `Combate - Sobra`), simultaneous front damage, sequential overflow targeting, direct lane damage, `iniciativa`, `defensor`, `reviver`, `enfraquecer`, `prender`, `promover`, dynamic `poder de habilidade`, and `regeneracao`.
- Battle now uses `Resolver Combate`: player actions, combat, pending choices, maintenance/script, pending choices, duel enemy preparation for the next turn, automatic return to the player. There is no separate enemy combat turn and no summoning sickness.
- BattleEngine implements first-pass Arcano `Fluxo Continuo`, Invocador permanent buffs, Necromante `Cinzas`, death hooks, debuffs, and reanimation with passives locked until map 5 and actives hidden/locked until map 7.
- BattleEngine implements sequential waves, duel hero kill, defense position, survive turns, and scripted summoner bosses.
- BattleEngine shuffles the run deck deterministically on battle start and when discard recycles into the deck.
- Visual support V1 adds `VisualAssets`, `data/definitions/visual_assets.json`, optional PNG fallback reporting, asset READMEs, and an AI art guide.
- ShipHub, RunMap, and Battle now have visual background slots with themed fallbacks.
- RunMap now presents the route as visual markers positioned by the visual manifest.
- Battle cards now use a portrait visual contract with image area, frame slot, text area, and floating base mana/ATK/HP badges; spells show only the floating mana badge.
- Battle field slots now render compact card-shaped sockets; occupied slots show card art/fallbacks with floating base mana cost, current ATK, and current HP from `BattleEngine`.
- Battle field previews now call out current stats against base card stats when buffs, damage, debuffs, regeneration, or reanimation alter the occupant.
- Card text supports state-aware visual templates backed by mechanical values, including power/Fluxo-adjusted spell and ability text.
- ShipHub now uses 4 primary scene hotspots for Comando, Mapa, Deck, and Almas instead of the previous large grid.
- RunMap now draws route connections directly over the planet background with compact node labels.
- Battle now uses an objective-focused HUD: player HP/mana/resource dock, class-resource visibility by selected class, right-side end-turn button, ESC menu for map/menu/quit, compact log button, and no constant encounter text.
- Duel encounters now opt into `enemy_commander_enabled`, exposing enemy HP/mana HUD and partial mockup cardbacks while leaving enemy card AI out of scope.
- VisualAssets now records provisional background/frame debt and only uses frame overlays when `overlay_safe` is true.
- Screenshot capture tool generates ShipHub/RunMap/Battle screenshots at 1280x720 and 960x540 under `builds/`.
- Main menu is now the player entry surface with 3 `Save` slots, Novo Jogo/Continuar/Deletar gating, delete confirmation, and `Draxos: Invasão Elemental` title.
- `SaveManager` persists 3 local JSON slots under `user://`, with autosave outside battle and slot summaries showing class plus next map.
- ShipHub now uses visual Deck/Mapa/Almas buttons, forced class-pick modal for new games, no run-state panel on the nave, and ESC menu for main menu/quit/cancel.
- Deck and Almas are dedicated scenes; Deck shows grouped run cards plus upgrades, Almas offers paid healing at +5 HP for 10 souls, and both return to ShipHub on ESC.
- RunMap keeps the current/next encounter selected, and Battle victory now shows a floating reward modal before returning to the map.
- ESC handling in RunMap, Deck, Almas, ShipHub, and Battle now guards the viewport before marking input handled, preventing the null viewport crash seen in the map/deck/souls flows.
- Deck now falls back to the selected class starter deck when the run snapshot has no `current_deck_ids`, and tests assert real `DeckCard_*` rows.
- ShipHub now builds Deck/Mapa/Almas as transparent scene overlays positioned by `ship_overlays` in the visual manifest instead of framed UI buttons.
- VisualAssets now reports non-fatal alpha debts for ship overlays that require real transparency.
- ShipHub map and souls overlays have been repositioned toward the nave scene hotspots while deck remains class-driven on the right.
- Battle choice modals for `Promover`, `Enfraquecer`, and Necromante choices are centered and scrollable for long option lists.
- `Tempestade Arcana` now targets the enemy board as an area spell through the `BattleEnemyBoardAreaTarget` drop zone.
- Allied creatures can move by drag to an adjacent empty allied slot once per turn, excluding defense objectives.
- Allied creatures can swap by drag with an adjacent occupied allied slot; both creatures spend movement and the swap fails if either already moved.
- Duel enemies now use real enemy deck/hand/discard/mana state and play new cards after combat/maintenance so they are visible for the next player turn.
- Survive objectives can end early when the enemy board is cleared; defense objectives now require holding the objective through the configured turns.
- `sobreviver_turnos_inicial`, `chefe_invocador`, and `chefe_summoner_final` start with stronger enemy boards; initial and elite duels have enemy decks.
- Battle HUD now uses a compact dense-encounter composition: enemy commander info floats at the top, player HUD lives inside the hand band, cards shrink for duel/boss/4+ lane layouts, and enemy-board area targeting no longer consumes its own vertical row.
- Enemy-board area targeting now renders as a large table under the enemy cards/slots, so area spells can target the table without blocking individual card/slot interaction.
- Battle HUD keeps compact player/enemy target icons with name/HP only, keeps enemy targets visible in duel/summoner boss fights, and exposes unlocked passive/active class abilities as constant hoverable tokens.
- New runs require a 2-18 character player name after class choice; local save slots show player name, class, and map, with old saves falling back to `Comandante Draxos`.
- Arcano balance pass applied: Barreira Arcana 1/5, Fagulha Arcana 1/2, Choque 2 damage, Tempestade Arcana 4 damage, and Prender cost 1.
- Sacrifice/tuning pass applied: summoning over an allied creature now requires a Sacrificar/Cancelar modal before mana/card spend, Barreira Arcana has Defensor, defense map is a real hold objective with waves and no early clear-board victory, survive map has a light enemy buff, and Necromante unlocks active level 1 with the passive reward before upgrading to level 2 on the active reward.
- Validation green with 58/58 GUT tests and 409 asserts; 33 optional PNGs and 4 non-fatal ship overlay alpha debts are reported by design.

## Current Risk

The slice is mechanically playable but not fully balanced. The 10-map route now has staged combat and stronger duel/survive/boss pressure, but encounter numbers still need playtest, several maps only grant souls, most card art is still absent, enemy cardback art is still pending, `Mapa.png` still has fake checkerboard/no alpha, class ship overlays and `NpcAlmas.png` are pending, Invocador/Necromante frames are not alpha-safe overlays, backgrounds are accepted as provisional 16:9 `1456x816`, and final card/class naming still needs a dedicated content pass.

## Next

Playtest the sacrifice/movement/Cinzas tuning pass across the full route, replace transparent ship overlay art for Mapa/Deck/Almas, then distribute the remaining non-soul rewards.
