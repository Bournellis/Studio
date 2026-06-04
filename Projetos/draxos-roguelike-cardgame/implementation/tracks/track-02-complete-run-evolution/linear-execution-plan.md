# Track 02 Linear Execution Plan

- Last Updated: `2026-06-03`
- Status: `TRACK_02_COMPLETE_READY_FOR_USER_PLAYTEST`
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
| T02-P01 | complete | Add Track 02 data contract, save version, and validation scaffolding. | Green 70/70 |
| T02-P02 | complete | Implement reward categories, map reward schedule, max mana/hand/HP progression. | Green 73/73 |
| T02-P03 | complete | Implement relic system and expanded Souls shop. | Green 79/79 + screenshots |
| T02-P04 | complete | Implement keyword vocabulary, tooltip system, and status presentation. | Green 81/81 + screenshots |
| T02-P05 | complete | Implement full keyword engine behavior. | Green 87/87 |
| T02-P06 | complete | Promote placeholder cards into real class cards and add enemy card content. | Green 87/87 |
| T02-P07 | complete | Implement enemy AI profiles and enemy intent panel. | Green 89/89 + screenshots |
| T02-P08 | complete | Implement 29-map route, new encounter modes, board formats, field effects, boss phases. | Green 92/92 + screenshots |
| T02-P09 | complete | Polish UI/visuals, add telemetry, run full-route validation, and tune. | Green; post-hardening baseline 103/103 + smoke/golden/catalog notes |

## Current Execution Cursor

Next prompt: none. Track 02 is ready for user playtest.

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
