# Track 12 - Telemetry Readout And Balance Baseline V1

- Status: `READY_FOR_HUMAN_SMOKE`
- Started: `2026-06-19`
- Owner: Codex
- Branch: `codex/fpsplayground/track12-telemetry-readout-balance-baseline-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track12-telemetry-readout-balance-baseline-v1`
- Base: Track 11 complete telemetry approved in human smoke.

## Goal

Turn Track 11 telemetry into a local readout and first balance baseline so future tuning decisions can start from evidence instead of raw JSON.

## Guardrails

- No gameplay changes.
- No movement, jump pad, map, weapon, pickup or bot tuning.
- No remote analytics.
- No generated user telemetry files committed.

## Delivered

- Added `TelemetryReadoutAnalyzer` for local session parsing, integrity checks, lifecycle summaries, combat, pickups, bot, movement and alerts.
- Added `tools/telemetry_readout.gd` headless runner with `--latest`, `--session`, `--root` and `--json`.
- Added GUT coverage for healthy sessions, mismatched summaries, jump pad alerting and latest-session lookup.
- Added `docs/telemetry-readout.md` and `docs/balance-baseline.md`.
- Updated validation contract for the new readout resources and docs.

## First Readout

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\FpsPlayground--codex--track12-telemetry-readout-balance-baseline-v1\Projetos\FpsPlayground -s res://tools/telemetry_readout.gd -- --session="C:\Users\Fabio\AppData\Roaming\Godot\app_userdata\FpsPlayground\telemetry\arena_20260619_202922_2301377"
```

Result:

- Integrity OK, `1344` events matched.
- Lifecycle OK, including match resets and manual restarts.
- Jump pad trigger/landing parity OK.
- Watch item: `player_rifle` dealt `88.7%` of total damage in that session.

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\FpsPlayground--codex--track12-telemetry-readout-balance-baseline-v1\Projetos\FpsPlayground -s res://tools/validate.gd
git diff --check
powershell -ExecutionPolicy Bypass -File D:\Estudio\tools\check_doc_drift.ps1
```

Latest local result:

```text
PASS, GUT 53/53, 496 asserts
```

## Human Smoke

- Run the readout against the latest `user://telemetry` session.
- Run the readout against the approved Track 11 session.
- Confirm the report is readable enough to choose a next balance/map/bot track.
- Confirm no gameplay feel changed.
