# Track 01 Linear Execution Plan

- Last Updated: `2026-05-07`
- Status: `NEXT`
- Execution Owner: `Codex`
- Scope: `First coherent playable run loop after Track 00 checkpoint`
- Validation Command: `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/validate.gd`

## Purpose

Turn the Track 00 placeholder checkpoint into a playable loop that starts a run, chooses a class placeholder, travels through map nodes, resolves battles, and returns to the ship with visible run state.

## Execution Rules

- Keep classes as placeholders until the dedicated class design session defines final mechanics.
- Do not implement final reward formulas, final map chain, or final enemy scripts before their design sessions.
- Prefer small visible loop improvements backed by GUT tests.
- Run validation after code, scene, data, generated resource, or test changes.
- Update `../../current-status.md`, this track, and the studio snapshot when observable status changes.

## Current Execution Cursor

Next prompt: `P01 - Run Start And Class Placeholder`.

## Linear Prompt Sequence

| Prompt | Status | Goal | Validation |
|---|---|---|---|
| P01 | pending | Add a class placeholder selection and explicit run start state before entering the map. | Run validation |
| P02 | pending | Return from battle to ShipHub/RunMap with visible completed-node and commander health state. | Run validation |
| P03 | pending | Add placeholder post-combat reward choice that changes the current run immediately. | Run validation |
| P04 | pending | Add soul currency visibility and paid healing placeholder in ShipHub. | Run validation |
| P05 | pending | Harden full-loop checkpoint documentation and status. | Run validation |

## P01 - Run Start And Class Placeholder

Goal: make the pre-run identity explicit without designing final classes yet.

Expected work:

- Add 3 placeholder class options.
- Store selected class id in `RunSession`.
- Start a run from ShipHub before entering RunMap.
- Keep class mechanics as TODO placeholders, not final gameplay.

Exit criteria:

- Player can choose a placeholder class before the run.
- RunSession records selected class and active run state.
- ShipHub can enter RunMap only through the explicit placeholder run flow.
