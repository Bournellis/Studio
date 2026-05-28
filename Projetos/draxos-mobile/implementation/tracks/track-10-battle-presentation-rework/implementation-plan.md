# Track 10 Implementation Plan

## Work Items

1. Register Track 10 and update coordination status.
2. Add battle logs route/action to the app shell contract.
3. Convert battle running to stage-only fullscreen portrait.
4. Simplify battle summary to result + `Ver logs` + `Voltar ao Refugio`.
5. Add current-battle log screen with formatted textual events.
6. Update GUT and smokes for the new battle loop.
7. Validate and update project/portfolio status.

## Acceptance

- `battle_running` has no app chrome, no external header and no external timeline.
- `BattleStage2D` remains visible and receives replay events.
- `Pular batalha` is a large fixed button in the lower-right corner.
- `battle_summary` is minimal and has no reward/resource/stat cards.
- `battle_logs` shows the current battle events and can return to summary or Refugio.
