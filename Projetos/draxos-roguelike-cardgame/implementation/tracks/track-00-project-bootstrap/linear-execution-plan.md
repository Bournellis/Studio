# Track 00 Linear Execution Plan

- Last Updated: `2026-05-07`
- Status: `COMPLETE`
- Execution Owner: `Codex`
- Scope: `Draxos Roguelike Cardgame project bootstrap`
- Validation Command: `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/validate.gd`

## Purpose

Turn the official scaffold into the first local roguelike cardgame slice without silently inheriting RPG Turnos mechanics.

## Execution Rules

- Work linearly.
- Keep copied RPG Turnos systems marked as scaffolding until simplified.
- Do not add final deck, mana, draw, discard, or reward rules without a local design decision.
- Run validation after code, scene, data, generated resource, or test changes.
- Update this file, `../../current-status.md`, this track status, and the studio snapshot when observable status changes.

## Current Execution Cursor

Next track: `Track 01 - Playable Run Loop`.

Next prompt: `Track 01 / P01 - Run Start And Class Placeholder`.

## Linear Prompt Sequence

| Prompt | Status | Goal | Validation |
|---|---|---|---|
| P00 | complete | Create official project scaffold, docs, local catalog, validation, and records. | Green 5/5 |
| P01 | complete | Clean catalog schema around local card, encounter, run map, and slot-count contracts. | Green 7/7 |
| P02 | complete | Create ShipHub placeholder screen with clickable captain/member/system regions. | Green 9/9 |
| P03 | complete | Create RunMap placeholder with linear route and optional nodes. | Green 11/11 |
| P04 | complete | Simplify BattleEngine to local slot-count board assumptions. | Green 15/15 |
| P05 | complete | Implement first `limpar_mesa` encounter using local battle rules. | Green 17/17 |
| P06 | complete | Implement first `chefe_summoner` encounter. | Green 21/21 |
| P07 | complete | First playable checkpoint docs, status, and validation record. | Green 21/21 |

## Prompt Details

### P01 - Catalog Cleanup For Local Roguelike Contracts

Goal: make the authored JSON clearly represent this project, not RPG Turnos.

Expected work:

- Keep placeholder cards minimal.
- Keep encounter fields centered on `mode`, `player_slots_count`, `enemy_slots_count`, and pacing label.
- Add first local run-map node definitions if needed by P03.
- Add tests for schema expectations.

Exit criteria:

- Catalog is local, small, and validates.
- No RPG Turnos encounter IDs are required by validation.
- Player-facing catalog uses `Comandante Draxos`, not the RPG Turnos protagonist premise.
- Encounter contracts include tier, enemy director, soul reward band, and slot counts.
- Run-map placeholder includes mainline and optional sidequest nodes.

### P02 - ShipHub Placeholder

Goal: replace abstract boot-only flow with the first hub screen.

Expected work:

- Create a ship/base screen script through generation/tooling.
- Add clickable placeholder regions for captain, expedition member, map console, and deck system.
- Keep visuals no-final-art but full-screen and diegetic.

Exit criteria:

- Boot can enter ShipHub.
- Hub communicates the ship/base premise.
- ShipHub exposes clickable placeholder regions for command station, Grande Mestre, subordinados, map console, deck system, and soul engine.

### P03 - RunMap Placeholder

Goal: create the first map flow.

Expected work:

- Add a simple linear route with optional nodes.
- Track selected/current node in `RunSession`.
- Provide entry points back to hub and forward to future battle.

Exit criteria:

- Player can inspect a placeholder route and choose an available node.
- RunSession tracks current node selection and completed node ids for placeholder unlocks.
- ShipHub can open the RunMap and RunMap can return to ShipHub.

### P04 - Simplify BattleEngine

Goal: remove inherited board complexity from the local combat baseline.

Expected work:

- Replace route/terrain/elevation assumptions with slot-count board construction.
- Preserve encounter objective vocabulary.
- Keep presentation events simple.

Exit criteria:

- Combat engine no longer depends on RPG Turnos board routes for basic play.
- BattleEngine uses only `player_slots_count` and `enemy_slots_count` for board construction.
- BattleEngine supports stable 5-card hand, draw-on-play, discard recycle, slot replacement sacrifice, and automatic front/fallback attacks.

### P05 - First Limpar Mesa

Goal: implement the first small encounter.

Expected work:

- Use local starter deck placeholders.
- Win by clearing enemy board presence.
- Target about 1 minute of play once tuned.

Exit criteria:

- First encounter is playable through local flow.
- `pouso_elemental` starts with an enemy on the board.
- RunMap can launch Battle and Battle can complete `limpar_mesa`, marking the node completed.

### P06 - First Chefe Summoner

Goal: prove the boss direction.

Expected work:

- Boss occupies enemy identity.
- Boss summons multiple creatures over time.
- Encounter target is longer than a small encounter.

Exit criteria:

- Boss summoner behavior is testable and documented.
- `chefe_invocador` has boss health and scripted summon list.
- BattleEngine summons boss creatures over time and supports boss defeat through direct hero damage when the board is open.
- Battle scene can load the boss encounter from the RunMap node.

### P07 - First Playable Checkpoint

Goal: close Track 00 cleanly.

Expected work:

- Update docs, status, Kanban, and validation record.
- Mark next track or next prompt explicitly.

Exit criteria:

- Agents can continue without reading RPG Turnos history.
- Track 00 status records point to the local Draxos Roguelike checkpoint instead of RPG Turnos history.
- Validation record captures the P07 green run.
- Next operational track is explicit.
