# Track 09 Current Status

Status: `INTEGRATED_PORTRAIT_SLIM_LOOP_READY`

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
  - slim account/login first;
  - create account via popup with email, password and username;
  - normal/lab save controls;
  - reset/sync/update actions;
  - dev labs when enabled;
  - login, signup and guest dev navigate to Refugio after save recovery without a second CTA.
- Rebuilt Refugio as the playable altar scene:
  - `Caminhos do Refugio` as the top/main interaction block;
  - hotspots for Battle, Base, Social, Competition, Shop and Profile;
  - resources/status in a compact footer;
  - internal surfaces open through existing actions/routes with Back support.
- Reworked battle running and summary for portrait fullscreen.
- Updated presentation/foundation tests and smokes for the new loop.
- Applied Track 09B slim UX correction:
  - removed username/invite from inline Entry login;
  - moved create account to runtime `ConfirmationDialog`;
  - removed the mandatory `Entrar no Refugio` step;
  - kept saves and Labs Dev as secondary Entry blocks;
  - changed Refugio composition so the altar is background and Caminhos is the foreground.
- Applied Track 09B Refugio follow-up:
  - removed the runtime altar background and empty top spacer;
  - moved `Caminhos do Refugio` to the top of the Refugio screen.
- Applied Track 09B Refugio-as-Base follow-up:
  - removed the separate `Base` hotspot from Refugio;
  - embedded Refugio management actions and structure panels directly inside `Caminhos do Refugio`;
  - kept the legacy `base`/`base_management` route only as compatibility, with user-facing labels shifted to Refugio.
- Applied Track 09B Refugio core-flow follow-up:
  - removed the `Atualizar Refugio` requirement from the main Refugio screen;
  - moved Refugio routine/structure content above the secondary path buttons;
  - added automatic Refugio state sync when the screen opens with a valid session and no local snapshot.

## Guardrails Preserved

- No backend endpoint, schema or migration.
- No tuning of economy, rewards, battle, bots or shop.
- No final asset import.
- No publication or remote manifest mutation.
- `players.save_type` remains the short-term account/save model.
- `boot.gd` remains the orchestrator.

## Validation

Local validation result:

- Track 09B core-flow patch: `tools/validate.gd` passed with GUT `96/96` tests and `1170` asserts; `tools/smoke_mobile_presentation.gd`, `tools/smoke_foundation_hardening.gd` and `git diff --check` passed.
- Track 09B patch: `tools/validate.gd` passed with GUT `96/96` tests and `1163` asserts; `tools/smoke_mobile_presentation.gd`, `tools/smoke_foundation_hardening.gd` and `git diff --check` passed.
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

Manual visual QA in Godot/Android export should focus on the slim Entry auth flow, create-account popup, Refugio Caminhos with routine/structures immediately visible, and battle summary ergonomics.
