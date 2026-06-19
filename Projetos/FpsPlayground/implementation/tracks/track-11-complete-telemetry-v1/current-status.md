# Track 11 - Complete Telemetry V1

- Status: `HUMAN_SMOKE_APPROVED`
- Started: `2026-06-19`
- Approved: `2026-06-19`
- Owner: Codex
- Branch: `codex/fpsplayground/track11-complete-telemetry-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track11-complete-telemetry-v1`
- Base: Track 10 combat balance merged locally into `main`.

## Goal

Add complete local duel telemetry so future balance, bot, map and combat-feel decisions can be checked against concrete evidence instead of only feel.

## Telemetry Contract

- Local only: no remote analytics, no network, no personal data.
- Gameplay-neutral: no movement, weapon, bot, map, pickup or round-behavior changes.
- Append event stream plus compact summary.
- Deterministic enough for automated tests.
- Human-readable enough for manual playtest analysis.

## Data Categories

- Session and arena setup.
- Round lifecycle and winner.
- Combat shots, hits, misses, damage, knockback and overcharge conversion.
- Plasma projectile lifecycle, direct hits, world impacts and blast falloff.
- Bot state, route label, decision reason, line of sight and combat overlay.
- Pickups, respawns, effective healing, ignored nearby pickups and contest windows.
- Movement samples, airborne/grounded time, jump counts, jump pad triggers and route success.
- Derived summary metrics for quick tuning.

## Guardrails

- Do not alter Track 10 weapon values.
- Do not alter player movement feel.
- Do not alter jump pad force or arena geometry.
- Do not alter bot route-control priorities.
- Do not add external dependencies or remote sinks.

## Delivered

- Added `ArenaTelemetryRecorder` with local JSONL event stream and compact JSON summary.
- Instrumented arena setup, session, rounds, combat, Plasma lifecycle, pickups, bot state, movement samples and jump pad landings.
- Added debug getters for automated tests and manual inspection.
- Added schema/summary/file-output tests plus Track 10 gameplay guardrails.
- Added validation guardrails for the telemetry script and documentation.
- Hotfix V1: `plasma_blast` remains in Plasma/damage contribution metrics, but no longer creates invalid fired-weapon accuracy rows.
- Hotfix V2: `summary.json` is flushed with each recorded event so interrupted or reset sessions remain reviewable.
- Hotfix V3: active manual restarts emit `round_reset reason=manual_restart` before the next `round_start`.

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path "D:\Estudio-worktrees\FpsPlayground--codex--track11-complete-telemetry-v1\Projetos\FpsPlayground" -s res://tools/validate.gd
git diff --check
powershell -ExecutionPolicy Bypass -File D:\Estudio\tools\check_doc_drift.ps1
```

Latest local result:

```text
PASS, GUT 49/49, 464 asserts
```

## Human Smoke

- Approved session: `C:\Users\Fabio\AppData\Roaming\Godot\app_userdata\FpsPlayground\telemetry\arena_20260619_202922_2301377`.
- `events.jsonl` and `summary.json` matched at `1344` events.
- Covered round lifecycle, match reset, manual restart, combat, pickups, bot route events, movement samples and jump pad trigger/landing pairs.
- Confirmed no gameplay feel regression.
