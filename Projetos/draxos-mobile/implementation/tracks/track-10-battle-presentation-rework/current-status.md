# Track 10 Current Status

Status: `INTEGRATED_BATTLE_PRESENTATION_READY`

Date: 2026-05-28

## Delivered

- Created the Track 10 documentation set and coordination registry.
- Added `battle_logs` to the app route contract as fullscreen portrait gameplay.
- Reworked `battle_running`:
  - no app chrome;
  - no external header, timeline or side cards outside the stage;
  - `BattleVisualMockup` now supports `stage_only` mode;
  - `BattleStage2D` remains the main duel stage with HP, mana, spells, status, effects and summons;
  - `Pular batalha` is a large lower-right action in the battle layout.
- Reworked `battle_summary`:
  - minimal result screen;
  - primary actions are `Ver logs` and `Voltar ao Refugio`;
  - reward/resource/stat cards are intentionally not shown there.
- Added fullscreen `battle_logs`:
  - shows formatted text events for the current battle;
  - supports `Voltar ao Resultado` and `Voltar ao Refugio`;
  - does not fetch global history by default.
- Tightened `BattleStage2D` label/status positioning so narrow portrait stages do not leak horizontally.
- Updated GUT and smokes for the new battle loop.

## Validation

- `tools/validate.gd`: passed with GUT `98/98` tests and `1208` asserts.
- GUT client complete: passed with `98/98` tests and `1208` asserts.
- `tools/smoke_mobile_presentation.gd`: passed.
- `tools/smoke_foundation_hardening.gd`: passed.
- `git diff --check`: passed before final status update; rerun at handoff.
- `tools/smoke_battle_replay.gd`: battle request/replay formatting reached history fetch, then failed with existing local Edge Runtime issue `NOT_FOUND: Unknown battle endpoint` for `/battle/history`; this matches the prior Track 09 caveat that the default `127.0.0.1:54321` function can be stale until the local `battle` function is restarted/redeployed or `BATTLE_FUNCTION_URL` points to the current function.

## Guardrails

- No backend, schema, migration, simulator, reward, ranking, economy or `battle_log_v1` changes.
- No final asset import.
- `boot.gd` remains the orchestrator.
- Presenters remain render-only.
