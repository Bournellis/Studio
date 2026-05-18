# Track 02 Linear Execution Plan

- Last Updated: `2026-05-18`
- Status: `READY_FOR_IMPLEMENTATION`
- Execution Owner: `Codex`
- Scope: `Complete 29-map run evolution`
- Validation Command: `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/validate.gd`

## Execution Rules

- Execute prompts from `implementation-prompts.md` in order.
- Each new thread should execute one prompt unless the user explicitly expands scope.
- Do not skip validation after code, scene, data, generated resource, or test changes.
- UI/map/battle visual changes require screenshots using the existing project screenshot workflow.
- Each thread must update `current-status.md` and append `handoff-log.md`.
- Each thread final answer must include changed files, validation result, blockers, and next prompt id.
- Prefer small internal checkpoints, but do not split the 9 production prompts unless blocked.

## Prompt Sequence

| Prompt | Status | Goal | Validation |
|---|---|---|---|
| T02-P01 | pending | Add Track 02 data contract, save version, and validation scaffolding. | Godot validate |
| T02-P02 | pending | Implement reward categories, map reward schedule, max mana/hand/HP progression. | Godot validate |
| T02-P03 | pending | Implement relic system and expanded Souls shop. | Godot validate |
| T02-P04 | pending | Implement keyword vocabulary, tooltip system, and status presentation. | Godot validate + screenshots if UI changed |
| T02-P05 | pending | Implement full keyword engine behavior. | Godot validate |
| T02-P06 | pending | Promote placeholder cards into real class cards and add enemy card content. | Godot validate |
| T02-P07 | pending | Implement enemy AI profiles and enemy intent panel. | Godot validate + screenshots |
| T02-P08 | pending | Implement 29-map route, new encounter modes, board formats, field effects, boss phases. | Godot validate + screenshots |
| T02-P09 | pending | Polish UI/visuals, add telemetry, run full-route validation, and tune. | Godot validate + screenshots/playtest notes |

## Current Execution Cursor

Next prompt: `T02-P01 - Track 02 Data Contract, Save Version, And Validation Scaffolding`.

## Acceptance For Track 02

- A new save version cleanly starts a Track 02 run.
- The 29-map route is playable from start to victory.
- Max mana first-test cap is 6.
- Max hand size first-test cap is 5.
- HP starts at 20 and can reach at least 30 through fixed rewards.
- All reward categories work.
- Relics are visible, stored, and mechanically active.
- The expanded shop supports heal, remove, duplicate, buy card, upgrade card, buy relic, reroll, and max HP purchase.
- All planned keywords have tooltip text and implemented behavior or explicit enemy-only/boss-only behavior.
- Enemy AI has element profiles and readable intent.
- All current and new encounter types are represented.
- Bosses have scripted phases and intent display.
- Reward, map, battle, keyword, relic, and enemy intent UI remain readable.
- Validation is green at the end of each prompt.
