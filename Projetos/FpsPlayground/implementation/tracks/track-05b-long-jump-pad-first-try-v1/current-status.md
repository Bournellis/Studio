# Track 05B - Long Jump Pad First Try V1

- Status: `APPROVED`
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

## Delivered

- Jump pad launch now uses actor trigger position and route-distance speed calculation instead of one fixed horizontal speed.
- Long routes are clamped to a controlled maximum so regular pads stay readable while `Relay Foundry V1` can clear its longer gap.
- The bot locks its pad approach near the trigger and skips local projectile dodge while entering or flying committed jump pad routes.
- Bot air steering is reduced during committed jump pad flight so the first launch is not invalidated by full-speed strafe.
- Automated coverage now checks route-distance launch and first-attempt long jump pad completion in `Relay Foundry V1`.
- Smoke documentation now includes first-trigger long pad checks for bot and player feel.

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
# PASS, GUT 30/30, 238 asserts
```

Known GUT UID/text-path warnings can appear on fresh imports and are accepted when the suite passes.

## Handoff

- Fabio approved the bot after smoke on 2026-06-15.
- The first long jump pad issue in `Relay Foundry V1` is considered resolved.
- Next step is choosing Track 06 from the approved bot, map and movement baseline.
- PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
