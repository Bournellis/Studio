# Track 02 Current Status

- Last Updated: `2026-05-18`
- Status: `READY_FOR_IMPLEMENTATION_PLANNING`
- Scope: `First complete 29-map version of the Draxos roguelike cardgame`
- Baseline Dependency: `Track 01 - Playable Run Loop`
- Validation Baseline: `Track 01 validation green: 67/67 GUT tests, 536 asserts`

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

Next implementation prompt: `T02-P01 - Track 02 Data Contract, Save Version, And Validation Scaffolding`.

## Handoff Rule

Every future Track 02 implementation thread must:

- read this file and `implementation-prompts.md`;
- execute exactly one prompt unless the user explicitly expands scope;
- run the required validation;
- update this file with status and next prompt;
- append `handoff-log.md`;
- leave a clear final summary with changed files, validation result, blockers, and next prompt id.

## Current Risk

Track 02 is documentation-ready but not implemented. The next risk is integration scope: reward, relic, keyword, AI, route, and UI changes touch shared runtime state. Future prompts must preserve small validation gates and avoid mixing prompt boundaries.
