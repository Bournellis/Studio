# Track 05B - Long Jump Pad First Try V1

- Status: `IN_PROGRESS`
- Started: `2026-06-15`
- Owner: Codex
- Branch: `codex/fpsplayground/track05b-long-jump-pad-first-try-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track05b-long-jump-pad-first-try-v1`
- Base: Track 05 route-control bot merged to `main`.

## Human Smoke Input

Fabio approved the Track 05 bot overall, but observed one specific failure:

- in the second map (`Relay Foundry V1`), the bot fails the long jump pad on the first try and succeeds on the second try.

## Diagnosis

- `Relay Foundry V1` long pads have much longer flat travel than `Duel Pit V2`.
- Jump pad launch uses a fixed horizontal speed for all routes.
- The trigger can fire while the bot enters at the edge of the pad, but launch direction is calculated from the pad center.
- Existing tests cover commitment after launch, not the full first-attempt path through approach, trigger, flight and landing.

## Goal

Make the long jump pad reliable on the first attempt while preserving the Track 05 route-control behavior:

- movement objective remains primary;
- combat overlay can still shoot during routes;
- no generic air strafe during committed jump-pad flight;
- long route physics are derived from route geometry instead of fixed old-map speed.

## Scope

- Calculate launch velocity from actor position and route distance.
- Keep launch speeds clamped so regular pads still feel controlled.
- Tighten bot jump pad approach/flight commitment.
- Add first-attempt automated coverage for `Relay Foundry V1`.
- Update smoke documentation.

## Non-Goals

- No new maps.
- No new weapons.
- No aim/damage tuning.
- No export/Web/mobile/multiplayer/backend.

## Validation Plan

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
git diff --check
powershell -ExecutionPolicy Bypass -File D:\Estudio\tools\check_doc_drift.ps1
git status --short
```
