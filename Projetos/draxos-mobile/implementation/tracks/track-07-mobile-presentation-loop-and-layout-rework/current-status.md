# Track 07 - Current Status

- Last Updated: `2026-05-27`
- Status: `ACTIVE_PRESENTATION_REWORK`
- Depends On: `T06_INTEGRATED_FEATURE_SLICES_READY`
- Current Stage: `T07_D_APP_SCREENS`
- Next Action: integrate Refugio/Home, App Screens and Battle Fullscreen branches, then run PC/Web presentation validation.

## Estado

Track 07 is active as the mobile-first presentation and layout rework.

The track responds to the first post-Track 06 walkthrough findings: the current Hub still reads like a tab/list app, touch scrolling competes with buttons, the scrollbar affordance is too narrow, Refugio/account/login are cluttered, Progression Lab access became too hidden, and battle should feel like a full-screen landscape game moment instead of a screen inside the Hub chrome.

## Ordem Atual

1. `T07-A` Coordenacao: complete and on master.
2. `T07-B` App Shell/Foundation: complete and on master; created routes, back stack, orientation helpers and scroll/touch foundation.
3. `T07-C` Refugio/Home: planned after `T07-B`; turns Refugio into full-screen home with altar/hotspots and cleaner account panel.
4. `T07-D` App Screens: complete on `codex/draxos-mobile/t07-app-screens`; adapts Base, Social, Competition and Shop into internal app screens.
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

## T07-D Handoff

Status: `COMPLETE_VALIDATED`.

Delivered:

- Base, Social, Competition and Shop remain render-only presenters, now organized as internal route screens opened through the T07-B route shell.
- Added a shared responsive panel helper in `boot.gd`: portrait/narrow layouts stay single-column; landscape/wide layouts use two panel columns while keeping the global `TouchScrollContainer`.
- Base routine, map and selected-structure detail now sit in responsive panels without changing Base endpoints, payloads or upgrade/collect actions.
- Social, Competition and Shop state panels use the same responsive internal-screen layout while preserving polling, ranking, product, reward and contract text.
- Route/back behavior remains host-owned: Base, Social, Competition and Shop show `Voltar`, clear scroll position on route change and keep the old tab list absent.
- Focused GUT coverage added for portrait/landscape layout decisions and internal route/back/scroll behavior.

Validation:

- `tools/smoke_foundation_surfaces.gd`: passed against local Supabase runtime.
- `tools/validate.gd`: passed with `79/79` tests and `897` asserts.
- GUT client complete: passed with `79/79` tests and `897` asserts.
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
