# Track 11 - Complete Telemetry V1

- Status: `IN_PROGRESS`
- Started: `2026-06-19`
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

## Validation Plan

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path "D:\Estudio-worktrees\FpsPlayground--codex--track11-complete-telemetry-v1\Projetos\FpsPlayground" -s res://tools/validate.gd
git diff --check
powershell -ExecutionPolicy Bypass -File D:\Estudio\tools\check_doc_drift.ps1
```

## Human Smoke

- Launch `Arena Shooter` and play at least one full round.
- Confirm telemetry files are created under Godot `user://telemetry/`.
- Confirm files answer: what won the round, what dealt damage, which pickups were used, whether bot routes/jump pads worked and whether overcharge mattered.
- Confirm no gameplay feel regression.
