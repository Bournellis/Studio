# Track 02 Current Status

- Last Updated: `2026-05-18`
- Status: `T02-P07_COMPLETE`
- Scope: `First complete 29-map version of the Draxos roguelike cardgame`
- Baseline Dependency: `Track 01 - Playable Run Loop`
- Validation Baseline: `T02-P07 validation green: 89/89 GUT tests, 928 asserts`

## Purpose

Track 02 turns the validated 13-map playable slice into the first complete version of the game.

The target is a fixed, linear 29-map run with all planned encounter types, all planned keywords, improved enemy AI, a redesigned reward economy, universal run relics, a complete Souls shop, and stronger battle/map/reward UI.

## Approved Direction

- First complete version: fixed 29-map linear run.
- Target full-run duration: around 90 minutes.
- Player can lose before map 29.
- First balance target: max mana `6`, max hand size `5`.
- HP starts at `20`; fixed rewards raise it to `30`; shop/relics can raise it further.
- Every map grants Souls plus one main reward category.
- Reward rarity remains `70% common`, `25% rare`, `5% ultra rare`.
- Shop is available between maps and refreshes after victories.
- Existing class passives and actives remain intact.
- Universal relics are added as a separate run-passive system.
- All proposed keywords and encounter types are in scope.
- Enemy difficulty should not receive another global `+20%` stat pass; tune by element identity, AI behavior, and encounter role.

## Production Documents

- `design-brief.md`
- `reward-system.md`
- `relics.md`
- `enemy-ai-and-difficulty.md`
- `linear-execution-plan.md`
- `implementation-prompts.md`
- `handoff-log.md`

## Current Execution Cursor

Completed prompt: `T02-P07 - Enemy AI Profiles And Intent Panel`.

Next implementation prompt: `T02-P08 - Route, Encounter Modes, Board Formats, Field Effects, Boss Phases`.

## Implemented Baseline

- SaveManager save version and RunSession snapshot version are now `5`; v4 and older files follow the existing stale-save pattern.
- Runtime state now persists Track 02 contract fields for stat caps, relic ids, expanded shop state, reward category state, reroll count, and route metadata.
- Track 02 data metadata exposes the 29-map reward schedule while the active route remains the Track 01 13-map baseline.
- Reward application now supports max mana, max hand size, max HP, new-card choice, remaining-card grant, card upgrade, real relic rewards, utility choice, and victory metadata.
- Fixed HP progression starts at `20` and applies `+5` at map 10 and map 15; first-test caps remain max mana `6` and max hand size `5`.
- Map 27 utility choice supports remove card, duplicate card, or upgrade card.
- Reward rarity remains `70/25/5`, and new-card copy rules remain `3/4/5`.
- Track 02 now defines the initial 18 universal relics in data and stores owned relic ids in run state.
- Souls shop now exposes heal, remove card, duplicate card, buy card, upgrade card, buy relic, reroll shop/reward, and +3 max HP purchases with documented prices.
- Max HP shop purchases are limited to 2 per run with costs `18` then `28` Souls.
- Safe relic effects are implemented for Bolsa de Cinzas, Lamina de Reserva, Couro Astral, Marca de Guerra, Eco Menor, Catalisador Arcano, Ferramentas de Cirurgia, Estandarte Vivo, Nucleo Instavel, Coracao de Eter, Biblioteca Proibida, Forja Negra, and Pacto das Ruinas.
- Relics pending later hooks remain data-owned but effect-pending: Mao Preparada, Contrato de Sangue, Escudo de Marcha, Olho do Grande Mestre, and Selo de Dominacao.
- Track 02 now has canonical tooltip definitions for existing active keywords and all proposed keywords: Atropelar, Brutal, Drenar, Espinhos, Escudo, Resistencia, Imune, Crescer, Furia, Ecoar, Veneno, Congelar, Profanar, Entrar, Proliferar, Sacrificio, Inspirar, Pacto, Drenar Almas, and Ressurgir.
- Card, occupant, reward, shop item, relic, enemy intent, and board effect tooltip surfaces now route through shared lookup helpers; card/field keyword badges expose tooltip text and Souls shop/reward choices show floating previews.
- Status presentation now summarizes stack/count/timing data when fields exist, including current markers such as Lentidao, Confusao, Regeneracao, Carnica, revive use, and future markers for Escudo, Resistencia, Veneno, and Congelado.
- BattleEngine now implements all Track 02 keyword mechanics with timing coverage for summon, start of player turn, combat damage, damage received, death, end of combat, maintenance, sacrifice-cost confirmation, and run-economy bonus hooks.
- Implemented keyword scope includes Atropelar, Brutal, Drenar, Espinhos, Escudo, Resistencia, Imune, Crescer, Furia, Ecoar, Veneno, Congelar, Profanar, Entrar, Proliferar, Sacrificio, Inspirar, Pacto, Drenar Almas, and Ressurgir while preserving Iniciativa, Defensor, Reviver, Regeneracao, Carnica, Suicida, Enfraquecer, Prender, Remover Keywords, and Poder de Habilidade tests.
- T02-P06 promoted the 6 placeholder reward cards per class into real Gelo/Ar/Fogo class cards while preserving the 6 existing real cards per class.
- Every new class reward card now has Lvl 2 and Lvl 3 variants, and each class reward pool now contains the intended 8-card Terra/Gelo/Ar/Fogo sequence.
- Track 02 enemy card galleries now exist for Terra, Gelo, Ar, and Fogo, with 30 enemy cards total for later route/AI prompts.
- BattleEngine now has deterministic hybrid enemy AI foundations with archetype-driven scoring for Terra, Gelo, Ar, and Fogo profiles, including objective pressure, lane pressure, empty lanes, Defensor coverage, high-value threats, Espinhos risk, control priorities, and boss-phase protection scoring.
- Summoner-boss encounters now expose phase-hook intent data for current phase, next scripted trigger, and next major special action without implementing the final boss phase set.
- Battle state now exposes an enemy intent model for common encounters and bosses, including likely priorities, incoming lane/hero pressure, target priority, field-effect hints, next likely play, boss phase, next trigger, and next special action.
- Battle UI now shows a visible `BattleEnemyIntentPanel` with tooltip-backed intent categories, and the screenshot workflow captures duel battle screenshots with the panel visible.
- Visual asset manifest placeholders now cover all new class reward cards and enemy gallery cards.
- Validation now checks reward card ids, upgrade ids, reward pool order, enemy gallery card ids, keyword references, placeholder removal, deterministic enemy AI decisions, intent output, and intent panel presence.
- Playable 29-map encounters are still pending.

## Handoff Rule

Every future Track 02 implementation thread must:

- read this file and `implementation-prompts.md`;
- execute exactly one prompt unless the user explicitly expands scope;
- run the required validation;
- update this file with status and next prompt;
- append `handoff-log.md`;
- leave a clear final summary with changed files, validation result, blockers, and next prompt id.

## Current Risk

Relics, expanded shop, keyword/status presentation, full keyword mechanics, promoted class cards, enemy card galleries, enemy AI profiles, and battle intent panel are implemented on the active 13-map baseline. The next risk is `T02-P08`: implement the 29-map route, encounter modes, board formats, field effects, and representative boss phase behavior without retuning the whole game globally.
