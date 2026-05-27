# Track 07 - Current Status

- Last Updated: `2026-05-27`
- Status: `ACTIVE_PRESENTATION_REWORK`
- Depends On: `T06_INTEGRATED_FEATURE_SLICES_READY`
- Current Stage: `T07_B_APP_SHELL_FOUNDATION`
- Next Action: run Refugio/Home, App Screens and Battle Fullscreen work in parallel on top of the T07-B foundation.

## Estado

Track 07 is active as the mobile-first presentation and layout rework.

The track responds to the first post-Track 06 walkthrough findings: the current Hub still reads like a tab/list app, touch scrolling competes with buttons, the scrollbar affordance is too narrow, Refugio/account/login are cluttered, Progression Lab access became too hidden, and battle should feel like a full-screen landscape game moment instead of a screen inside the Hub chrome.

## Ordem Atual

1. `T07-A` Coordenacao: complete and on master.
2. `T07-B` App Shell/Foundation: in progress on `codex/draxos-mobile/t07-app-shell-foundation`; creates routes, back stack, orientation helpers and scroll/touch foundation.
3. `T07-C` Refugio/Home: planned after `T07-B`; turns Refugio into full-screen home with altar/hotspots and cleaner account panel.
4. `T07-D` App Screens: planned after `T07-B`; adapts Base, Social, Competition and Shop into internal app screens.
5. `T07-E` Battle Fullscreen: planned after `T07-B`; makes battle/replay full-screen landscape with skip and summary.
6. `T07-F` PC/Web + Validation: planned after `T07-C` to `T07-E`; adds presentation smoke and compatibility coverage.
7. `T07-G` Integracao: planned final integration and status update.

## Guardrails

- Do not edit directly in `D:\Estudio` for implementation.
- Do not change backend, Supabase schema, HTTP contracts, ranking, economy, rewards, bots, shop numbers or battle simulator.
- Do not create `account_profiles` + `game_saves`.
- Do not publish builds or mutate remote release state.
- Keep Progression Lab dev/internal.
- Keep PC executable and PC browser usable for handoff and testing.

## T07-B Handoff

Status: `COMPLETE_VALIDATED`.

Delivered:

- Route constants and normalization for `refuge_home`, `account`, `base`, `social`, `competition`, `shop`, `battle_entry`, `battle_running`, `battle_summary`, `battle_lab` and `progression_lab`.
- Legacy route compatibility for older calls such as `hub`, `battle` and `monetization`.
- Route stack/back helpers with Refugio as root.
- Android-only orientation helper that locks `battle_running` to landscape and restores sensor orientation after leaving gameplay.
- Shell presenter without the old global tab navigation row.
- `DraxosTouchScrollContainer` with wider scrollbar affordance and drag threshold for touch/mouse scrolling.
- Touch-friendly button helper using larger targets and pass-through mouse filtering for scroll gestures.
- Focused GUT coverage for route normalization, absent global nav, orientation route declaration and touch-scroll threshold.

Validation:

- `tools/validate.gd`: passed with `77/77` tests and `865` asserts.
- GUT client completo: passed with `77/77` tests and `865` asserts.
- `git diff --check`: passed.

## Validation Baseline

Client packages:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
git diff --check
```

Expected integration smokes:

- `tools/smoke_session_shell.gd`
- `tools/smoke_battle_replay.gd`
- `tools/smoke_foundation_surfaces.gd`
- `tools/smoke_exports.gd`
- `tools/smoke_mobile_presentation.gd`

## Fontes

- Escopo: `scope.md`
- Plano: `implementation-plan.md`
- Agent registry: `agent-registry.md`
- Prompts: `agent-prompts.md`
- Track 06 status: `../track-06-feature-installation-rails-and-first-slices/current-status.md`
- Product vision: `../../../docs/product-vision.md`
- Architecture: `../../../docs/architecture.md`
