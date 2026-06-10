# Track 06B - Third-Person Football Camera V1

- Last updated: `2026-06-10`
- Status: `COMPLETE`
- Target status marker: `FPS_PLAYGROUND_TRACK_06B_THIRD_PERSON_FOOTBALL_CAMERA_COMPLETE`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--track06b-third-person-football-camera-v1`
- Branch: `codex/fpsshooter/track06b-third-person-football-camera-v1`

## Goal

Convert the `Futebol` mode from first-person football into a third-person chase-camera mode inspired by Rocket League, while preserving the accepted first-person `Arena Shooter` baseline and the existing football score, bot, ball, avatar and menu contracts.

## Confirmed Direction

- `Futebol` uses a third-person camera.
- `Arena Shooter` remains first-person.
- The local player avatar is visible in `Futebol`.
- Movement, scoring, ball physics, bot behavior and intro/pause menus stay inside the accepted Track 06A scope.
- No boost, dash, slide tackle, asset import, persistence, export, multiplayer or backend in this track.

## Delivered

- Added `presentation/camera/football_chase_camera.gd`.
- `FootballRoot` now spawns `RuntimeRoot/FootballChaseCamera` and makes it current in `Futebol`.
- The reused first-person player camera remains available for the controller but is not current in `Futebol`.
- The local player avatar is no longer configured as first-person-hidden in `Futebol`.
- Player LMB/RMB kick direction now comes from the player's body-forward vector instead of the hidden first-person camera pitch.
- Futebol intro and HUD hints now describe third-person camera control.
- Automated coverage verifies the chase camera exists, is current, follows behind the player, keeps the FPS camera inactive in `Futebol`, keeps the avatar visible and preserves kick/strong-kick behavior.

## Validation Plan

- `tools/validate.gd -- --profile=quick` after implementation.
- final `tools/validate.gd -- --profile=full`.
- `git diff --check`.
- Manual editor smoke in `docs/validation.md`.

## Acceptance

- `Futebol` boots with a current third-person chase camera: done.
- `Arena Shooter` still boots with the current first-person camera: done by regression.
- Local football player avatar is visible in third person: done.
- Mouse still rotates the player/camera relationship through the reused controller: done.
- Kicks are body-forward and do not depend on an invisible FPS pitch: done.
- Existing football scoring, bot kick handoff, avatar selection and feedback are preserved: done by regression.

## Validation Snapshot

- `tools/validate.gd -- --profile=quick`: passed with `58/58` tests and `455` asserts during implementation.
- `tools/validate.gd -- --profile=full`: passed with `58/58` tests and `455` asserts before closeout.
