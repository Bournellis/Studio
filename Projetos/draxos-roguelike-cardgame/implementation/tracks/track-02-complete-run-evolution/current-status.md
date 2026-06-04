# Track 02 Current Status

- Last Updated: `2026-06-03`
- Status: `T02-P09_COMPLETE`
- Scope: `First complete 29-map version of the Draxos roguelike cardgame`
- Baseline Dependency: `Track 01 - Playable Run Loop`
- Validation Baseline: `Foundation hardening 7 validation green: 103/103 GUT tests, 1271 asserts, shared full-route pacing smoke green, Run Lab golden comparison green`

## Purpose

Track 02 turned the historical validated 13-map playable slice into the first complete version of the game.

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
- `validation-and-tuning-notes.md`

## Current Execution Cursor

Completed prompt: `T02-P09 - UI Polish, Telemetry, Full-Route Validation, And Tuning`.

Next implementation prompt: none. Track 02 is ready for user playtest.

## Implemented Baseline

- SaveManager save version and RunSession snapshot version are now `5`; v4 and older files follow the existing stale-save pattern.
- Runtime state now persists Track 02 contract fields for stat caps, relic ids, expanded shop state, reward category state, reroll count, and route metadata.
- Track 02 data metadata exposes the 29-map reward schedule and the active route now uses the fixed 29-map sequence.
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
- The active run route now contains the complete fixed 29-map linear sequence with exact unlock chaining and compact visual node positions.
- Track 02 encounter coverage now includes Tutorial, Ondas, Duelo, Chefe Invocador, Sobreviver Turnos, Emboscada, Escolta, and Invasao.
- BattleEngine now supports the planned board formats: Padrao, Assimetrico, Nucleo Central, Flanco, Frente e Retaguarda, and Abismo.
- Elemental field effects are implemented for Terra, Gelo, Ar, Fogo, and final-chaos encounters, including effects that influence movement, summons, attack lanes, damage, poison, freeze, and death hooks.
- Boss maps 8, 15, 22, and 29 now have representative scripted phase hooks and intent data.
- Production reward overrides are active: map 14 grants a Gelo remaining card, map 15 grants HP plus boss relic, map 23 raises max mana to 6, and map 28 grants rare/ultra relic choice.
- Validation now checks the 29-map route, linear unlock chain, reward schedule, mode/format/effect coverage, and boss hook coverage; representative tests exercise new modes, board formats, and field effects.
- Screenshot workflow captures RunMap and representative Battle surfaces for the complete-route state.
- T02-P09 added full-route pacing telemetry to validation, with map count, estimated turns, HP loss, Souls, deck size, relic count, shop usage, and deaths.
- Foundation hardening 2 extracted that route pacing telemetry into `tools/route_pacing_simulator.gd`, now shared by `tools/validate.gd`, `tools/run_lab.gd`, and GUT coverage.
- Foundation hardening 2 added `docs/playtest-track-02.md` as the human playtest checklist for the complete route.
- Foundation hardening 3 extracted enemy turn and intent directors, `core/run_reward_service.gd`, and the pure battle preview presenter while preserving public APIs, route behavior, reward/shop payloads, UI layout, and pacing metrics.
- Foundation hardening 4 added `tools/run_lab_golden_metrics.gd` and optional Run Lab golden comparison, with Arcano seed `20260518` exact metrics protected and Invocador/Necromante completion/no-death contracts checked.
- Foundation hardening 5 extracted Souls shop offer generation, purchases, rerolls, max-HP buys, cost helpers, and `shop_state` sync into `core/run_shop_service.gd` while preserving `RunSession` wrappers, snapshot v5 payloads, and golden pacing metrics.
- Foundation hardening 6 extracted BattleRoot HUD/objective readouts and combat FX filtering/text/state projection into pure presenters while preserving scene composition, layout, drag/drop, UI node names, route behavior, and golden pacing metrics.
- Foundation hardening 7 added `tools/catalog_source_loader.gd` as a composition seam for future catalog domain splits while preserving the current single `slice_catalog.json` source, generated `.tres` semantics, route behavior, and golden pacing metrics.
- Reward screen, RunMap, Souls shop/relic state, keyword preview, enemy intent, and dense Battle layouts received readability polish.
- Discard marking now happens in the main creature-play phase with right-click card selection, a visible hand hint, and marked-card discard/redraw on combat resolution instead of a separate pre-combat phase.
- 5/5, 6/6, and 7/7 battle layouts now have regression coverage.
- First tuning pass keeps the approved reward schedule and shop costs unchanged, but makes Track 02 upgrade rewards level-only instead of adding extra rarity copies; the full-route smoke now ends at `38` cards.
- Screenshot workflow now captures RunMap, reward screen, shop/relic, keyword tooltip, enemy intent, and late-board Battle surfaces at `1280x720` and `960x540`.

## Handoff Rule

Every future Track 02 implementation thread must:

- read this file and `implementation-prompts.md`;
- execute exactly one prompt unless the user explicitly expands scope;
- run the required validation;
- update this file with status and next prompt;
- append `handoff-log.md`;
- leave a clear final summary with changed files, validation result, blockers, and next prompt id.

## Current Risk

Track 02 is ready for user playtest. Remaining risk is human balance feedback: the deterministic full-route smoke validates structure and pacing telemetry, but it is not a substitute for a manual run.
