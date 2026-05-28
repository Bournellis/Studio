# Track 09 Current Status

Status: `INTEGRATED_PORTRAIT_LOOP_READY`

Date: 2026-05-28

## Delivered

- Created the Track 09 documentation set and visual direction.
- Changed the app root from `refuge_home` to `entry`.
- Preserved legacy aliases:
  - `hub`, `home`, `refuge_home`, `entrada`, `login` -> `entry`
  - `refugio`, `refuge` -> `refuge`
  - `base` -> `base_management`
- Changed the app contract to portrait-first:
  - no route prefers landscape;
  - battle routes also prefer portrait;
  - Android export uses portrait;
  - PC/Web keep the same vertical frame model.
- Rebuilt the first screen as operational Entry:
  - account/login/create account;
  - normal/lab save controls;
  - reset/sync/update actions;
  - dev labs when enabled;
  - explicit `Entrar no Refugio` CTA.
- Rebuilt Refugio as the playable altar scene:
  - resources/status bar;
  - altar-focused visual scene;
  - hotspots for Battle, Base, Social, Competition, Shop and Profile;
  - internal surfaces open through existing actions/routes with Back support.
- Reworked battle running and summary for portrait fullscreen.
- Updated presentation/foundation tests and smokes for the new loop.

## Guardrails Preserved

- No backend endpoint, schema or migration.
- No tuning of economy, rewards, battle, bots or shop.
- No final asset import.
- No publication or remote manifest mutation.
- `players.save_type` remains the short-term account/save model.
- `boot.gd` remains the orchestrator.

## Validation

Local validation result:

- `tools/validate.gd`: passed with GUT `95/95` tests and `1144` asserts.
- `tools/smoke_mobile_presentation.gd`: passed.
- `tools/smoke_foundation_hardening.gd`: passed.
- `tools/smoke_foundation_surfaces.gd`: passed.
- `tools/smoke_session_shell.gd`: passed.
- `tools/smoke_runtime_config.gd`: passed.
- `tools/smoke_exports.gd`: passed.
- `git diff --check`: passed.
- `tools/smoke_battle_replay.gd`: default local Edge Runtime still returns `NOT_FOUND` for `/battle/history` because `127.0.0.1:54321` serves an older `battle` function. Use `BATTLE_FUNCTION_URL` pointed at the current served function or restart/redeploy local functions before treating this smoke as authoritative.

## Next Step

Manual visual QA in Godot/Android export should focus on the Entry flow, Refugio hotspot readability, Base management in the vertical frame and battle summary ergonomics.
