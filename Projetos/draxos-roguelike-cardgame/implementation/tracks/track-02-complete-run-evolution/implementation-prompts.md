# Track 02 Implementation Prompts

- Last Updated: `2026-05-18`
- Status: `READY_FOR_COPY_PASTE`

Use one prompt per new Codex thread. Each thread should execute only the requested prompt, validate, update status, append `handoff-log.md`, and report the next prompt id.

## Shared Read Order For Every Prompt

1. `D:\Estudio\08_Coordenacao_Agentes\Prioridades_Estudio.md`
2. `D:\Estudio\Projetos\README.md`
3. `D:\Estudio\08_Coordenacao_Agentes\Estado_Atual.md`
4. `D:\Estudio\Projetos\draxos-roguelike-cardgame\AGENTS.md`
5. `D:\Estudio\Projetos\draxos-roguelike-cardgame\implementation\current-status.md`
6. `D:\Estudio\Projetos\draxos-roguelike-cardgame\implementation\tracks\track-02-complete-run-evolution\current-status.md`
7. `D:\Estudio\Projetos\draxos-roguelike-cardgame\implementation\tracks\track-02-complete-run-evolution\design-brief.md`
8. The Track 02 support docs relevant to the prompt.

## T02-P01 - Data Contract, Save Version, And Validation Scaffolding

```text
Implement Track 02 prompt T02-P01 for D:\Estudio\Projetos\draxos-roguelike-cardgame.

Goal:
Add the data/runtime contract needed for Track 02 without implementing the full reward, relic, keyword, AI, or 29-map content yet.

Read first:
- Follow the shared read order in implementation-prompts.md.
- Then read reward-system.md, relics.md, enemy-ai-and-difficulty.md, and existing Track 01 save/run/session code.

Owned scope:
- Add a new save version for Track 02.
- Extend run state/data contracts so future prompts can store max HP, max mana cap 6, max hand size cap 5, relic ids, shop state, reward category state, reroll count, and Track 02 route metadata.
- Add validation/test scaffolding for Track 02 data assumptions.
- Preserve Track 01 behavior where practical, but stale older saves may be marked invalid using the existing stale-save pattern.

Out of scope:
- Do not implement relic effects.
- Do not implement the expanded shop.
- Do not implement the 29-map route.
- Do not add all new keywords.
- Do not promote placeholder cards.
- Do not build enemy intent UI.

Required validation:
- Run D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/validate.gd

Handoff:
- Update track-02-complete-run-evolution/current-status.md.
- Append handoff-log.md with prompt id T02-P01.
- Final response must include changed files, validation result, blockers, and next prompt id T02-P02.
```

## T02-P02 - Reward System And Progression

```text
Implement Track 02 prompt T02-P02 for D:\Estudio\Projetos\draxos-roguelike-cardgame.

Goal:
Implement the Track 02 reward categories and progression schedule from reward-system.md.

Read first:
- Follow the shared read order in implementation-prompts.md.
- Read reward-system.md and the reward code/data from Track 01.

Owned scope:
- Implement reward categories for max mana, max hand size, max HP, new-card choice, remaining-card grant, card upgrade, relic placeholder reward, utility choice, and victory.
- Implement the 29-map reward schedule in data/contracts, even if later prompts fill route encounters.
- Set first-test caps: max mana 6, max hand size 5.
- Implement fixed HP progression: start 20, +5 at map 10, +5 at map 15.
- Implement map 27 utility choice: remove card, duplicate card, or upgrade card.
- Preserve rarity rule 70/25/5 and current new-card copy rules.
- Add tests for reward schedule, caps, and reward application.

Out of scope:
- Do not implement real relic effects beyond reward placeholders if needed.
- Do not expand the shop beyond what is required for reward application.
- Do not implement new cards or keywords.
- Do not implement 29-map battles.

Required validation:
- Run the Track 02 validation command.

Handoff:
- Update current-status.md.
- Append handoff-log.md with prompt id T02-P02.
- Final response must include changed files, validation result, blockers, and next prompt id T02-P03.
```

## T02-P03 - Relic System And Expanded Souls Shop

```text
Implement Track 02 prompt T02-P03 for D:\Estudio\Projetos\draxos-roguelike-cardgame.

Goal:
Implement universal run relics and expand the Souls shop according to relics.md and reward-system.md.

Read first:
- Follow the shared read order in implementation-prompts.md.
- Read relics.md, reward-system.md, existing Souls/Almas scene/code, and current reward code.

Owned scope:
- Add data definitions for the initial 18 relics.
- Store owned relic ids in run state.
- Implement relic reward choice and relic shop purchase.
- Implement expanded shop categories: heal, remove card, duplicate card, buy card, upgrade card, buy relic, reroll shop/reward, increase max HP.
- Implement initial shop prices exactly as documented.
- Implement max HP shop purchase limit: two purchases, 18 then 28 Souls.
- Implement mechanical effects for relics whose hooks already exist safely; if a hook requires later prompt work, store the relic and mark effect pending in tests/status.
- Add tests for relic ownership, shop inventory, prices, purchases, reroll cost scaling, and max HP purchase limits.

Out of scope:
- Do not implement new keywords just to support a relic.
- Do not implement enemy intent.
- Do not redesign visuals beyond necessary shop/relic display.

Required validation:
- Run the Track 02 validation command.
- If shop UI changes are visible, capture screenshots using the existing screenshot workflow.

Handoff:
- Update current-status.md.
- Append handoff-log.md with prompt id T02-P03.
- Final response must include changed files, validation result, screenshots if captured, blockers, and next prompt id T02-P04.
```

## T02-P04 - Keyword Vocabulary, Tooltips, And Status Presentation

```text
Implement Track 02 prompt T02-P04 for D:\Estudio\Projetos\draxos-roguelike-cardgame.

Goal:
Create the keyword/status vocabulary and tooltip presentation layer before implementing all keyword mechanics.

Read first:
- Follow the shared read order in implementation-prompts.md.
- Read docs/design-proposals/sessao-a-keywords.md and existing card/field preview code.

Owned scope:
- Add canonical keyword definitions for all Track 02 keywords and existing active keywords.
- Add tooltip text for cards, occupants, rewards, shop items, relics, enemy intent, and board effects.
- Ensure every keyword badge can show a floating explanation.
- Add status presentation for stack/count/timing when data exists.
- Add tests or UI-safe assertions for keyword definition lookup and missing tooltip detection.

Out of scope:
- Do not implement full keyword mechanics in BattleEngine yet.
- Do not add new card content beyond keyword references needed for tests.
- Do not implement enemy AI.

Required validation:
- Run the Track 02 validation command.
- Capture screenshots for card/reward/shop tooltip surfaces if available.

Handoff:
- Update current-status.md.
- Append handoff-log.md with prompt id T02-P04.
- Final response must include changed files, validation result, screenshots if captured, blockers, and next prompt id T02-P05.
```

## T02-P05 - Full Keyword Engine Implementation

```text
Implement Track 02 prompt T02-P05 for D:\Estudio\Projetos\draxos-roguelike-cardgame.

Goal:
Implement all Track 02 keyword mechanics in the combat engine.

Read first:
- Follow the shared read order in implementation-prompts.md.
- Read docs/design-proposals/sessao-a-keywords.md, enemy-ai-and-difficulty.md, and current BattleEngine tests.

Owned scope:
- Implement Atropelar, Brutal, Drenar, Espinhos, Escudo, Resistencia, Imune, Crescer, Furia, Ecoar, Veneno, Congelar, Profanar, Entrar, Proliferar, Sacrificio, Inspirar, Pacto, Drenar Almas, and Ressurgir.
- Preserve existing behavior for Iniciativa, Defensor, Reviver, Regeneracao, Carnica, Suicida, Enfraquecer, Prender, Remover Keywords, and Poder de Habilidade.
- Define exact timing through tests: start turn, summon, combat stage, damage received, death, end combat, maintenance.
- Mark enemy-only or boss-only behavior in data when needed.
- Add broad BattleEngine tests for each keyword and key interactions.

Out of scope:
- Do not create final 29-map route.
- Do not promote all placeholder cards unless required for focused keyword tests.
- Do not implement enemy AI scoring beyond keyword behavior.

Required validation:
- Run the Track 02 validation command.

Handoff:
- Update current-status.md.
- Append handoff-log.md with prompt id T02-P05.
- Final response must include changed files, validation result, blockers, and next prompt id T02-P06.
```

## T02-P06 - Cards And Enemy Content

```text
Implement Track 02 prompt T02-P06 for D:\Estudio\Projetos\draxos-roguelike-cardgame.

Goal:
Promote placeholder reward cards into real class cards and add the Track 02 enemy card gallery.

Read first:
- Follow the shared read order in implementation-prompts.md.
- Read docs/design-proposals/sessao-b-cartas-novas.md and docs/design-proposals/rota-29-mapas.md.

Owned scope:
- Replace the 6 placeholder reward cards per class with the approved Gelo/Ar/Fogo cards.
- Add Lvl 2 and Lvl 3 variants for every new class card.
- Preserve the 6 current real cards per class.
- Add enemy cards for Terra, Gelo, Ar, and Fogo galleries needed by the 29-map route.
- Add visual asset manifest placeholders for new cards/enemies.
- Add data validation for card ids, upgrade ids, reward pools, keyword references, and placeholder removal.

Out of scope:
- Do not implement the 29-map route encounters yet.
- Do not implement AI profiles.
- Do not make final art assets.

Required validation:
- Run the Track 02 validation command.

Handoff:
- Update current-status.md.
- Append handoff-log.md with prompt id T02-P06.
- Final response must include changed files, validation result, blockers, and next prompt id T02-P07.
```

## T02-P07 - Enemy AI Profiles And Intent Panel

```text
Implement Track 02 prompt T02-P07 for D:\Estudio\Projetos\draxos-roguelike-cardgame.

Goal:
Improve enemy AI and add readable enemy intent.

Read first:
- Follow the shared read order in implementation-prompts.md.
- Read enemy-ai-and-difficulty.md and current duel enemy AI code.

Owned scope:
- Implement hybrid AI foundations: archetype-driven scoring for common encounters and scripted phase hooks for bosses.
- Add element AI profiles for Terra, Gelo, Ar, and Fogo.
- AI should consider objective, lane pressure, empty lanes, Defensor coverage, high-value threats, Espinhos risk, control targets, and boss-phase pieces.
- Add an enemy intent model and visible panel.
- Common intent should show likely priorities and incoming pressure.
- Boss intent should show current phase, next scripted trigger, and next major special action.
- Add tests for deterministic AI decisions and intent output.

Out of scope:
- Do not implement all final boss phases or the 29-map route.
- Do not retune all enemy stats globally.
- Do not change reward systems.

Required validation:
- Run the Track 02 validation command.
- Capture battle screenshots showing the intent panel.

Handoff:
- Update current-status.md.
- Append handoff-log.md with prompt id T02-P07.
- Final response must include changed files, validation result, screenshots, blockers, and next prompt id T02-P08.
```

## T02-P08 - Route, Encounter Modes, Board Formats, Field Effects, Boss Phases

```text
Implement Track 02 prompt T02-P08 for D:\Estudio\Projetos\draxos-roguelike-cardgame.

Goal:
Implement the complete 29-map route and all Track 02 encounter structure.

Read first:
- Follow the shared read order in implementation-prompts.md.
- Read reward-system.md, enemy-ai-and-difficulty.md, and docs/design-proposals/rota-29-mapas.md.

Owned scope:
- Implement the 29 fixed linear maps.
- Implement new encounter modes: Emboscada, Escolta, Invasao.
- Implement board formats: Assimetrico, Nucleo Central, Flanco, Frente e Retaguarda, Abismo.
- Implement field effects by element.
- Implement boss phases and scripted behaviors for maps 8, 15, 22, and 29.
- Apply the production reward changes: map 14 Gelo remaining card, map 15 HP + boss relic, map 23 max mana 6, map 28 rare/ultra relic.
- Add route/encounter validation and representative tests for each mode/format/effect.

Out of scope:
- Do not add final art.
- Do not do final tuning pass beyond making encounters playable and valid.
- Do not redesign reward/shop/relic systems.

Required validation:
- Run the Track 02 validation command.
- Capture RunMap and representative Battle screenshots.

Handoff:
- Update current-status.md.
- Append handoff-log.md with prompt id T02-P08.
- Final response must include changed files, validation result, screenshots, blockers, and next prompt id T02-P09.
```

## T02-P09 - UI Polish, Telemetry, Full-Route Validation, And Tuning

```text
Implement Track 02 prompt T02-P09 for D:\Estudio\Projetos\draxos-roguelike-cardgame.

Goal:
Finish Track 02 readability, telemetry, validation, and first tuning pass.

Read first:
- Follow the shared read order in implementation-prompts.md.
- Read all Track 02 docs and the latest handoff-log.md.

Owned scope:
- Polish reward screen, relic display, keyword previews, enemy intent panel, RunMap visuals, and Battle visuals.
- Ensure 5/5, 6/6, and 7/7 layouts remain readable.
- Add telemetry or validation output for full-run pacing: map count, turns, HP loss, Souls, deck size, relic count, shop usage, and deaths if available.
- Run a first tuning pass for enemy stats, rewards, shop costs, and pacing without changing the approved reward schedule unless a blocker appears.
- Update documentation with final Track 02 validation/tuning notes.

Out of scope:
- Do not add new systems beyond Track 02 scope.
- Do not start a Track 03.
- Do not add permanent account progression.

Required validation:
- Run the Track 02 validation command.
- Capture RunMap, reward screen, shop/relic, keyword tooltip, enemy intent, and late-board Battle screenshots.
- If practical, perform or document a full-route smoke/playtest path.

Handoff:
- Update current-status.md.
- Append handoff-log.md with prompt id T02-P09.
- Final response must include changed files, validation result, screenshots/playtest notes, blockers, and whether Track 02 is ready for user playtest.
```
