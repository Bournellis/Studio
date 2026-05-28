# Track 07 - Current Status

- Last Updated: `2026-05-28`
- Status: `INTEGRATED_PRESENTATION_READY`
- Depends On: `T06_INTEGRATED_FEATURE_SLICES_READY`
- Current Stage: `T07_G_COMPLETE_VALIDATED`
- Next Action: run a manual mobile/PC/Web walkthrough of the new presentation loop and decide the next asset/service feature track.

## Estado

Track 07 is integrated as the mobile-first presentation and layout rework.

Corrective follow-up `T07R` is active on branch `codex/draxos-mobile/t07r-refugio-first-screen` because the original integration treated "first screen" as the root route inside the app shell. The correction makes `refuge_home` a true first-screen layer in `RefugeFirstScreenRoot`, hides `AppShellChromeRoot` on the Refugio, and reserves the app shell for internal screens opened from the Refugio.

The track responds to the first post-Track 06 walkthrough findings: the current Hub still reads like a tab/list app, touch scrolling competes with buttons, the scrollbar affordance is too narrow, Refugio/account/login are cluttered, Progression Lab access became too hidden, and battle should feel like a full-screen landscape game moment instead of a screen inside the Hub chrome.

## Ordem Atual

1. `T07-A` Coordenacao: complete and on master.
2. `T07-B` App Shell/Foundation: complete and on master; created routes, back stack, orientation helpers and scroll/touch foundation.
3. `T07-C` Refugio/Home: complete and integrated into `T07-G`; turns Refugio into full-screen home with altar/hotspots and cleaner account panel.
4. `T07-D` App Screens: complete and integrated into `T07-G`; adapts Base, Social, Competition and Shop into internal app screens.
5. `T07-E` Battle Fullscreen: complete and integrated into `T07-G`; makes battle/replay full-screen landscape with skip and summary.
6. `T07-F` PC/Web + Validation: complete and validated in `T07-G`; added presentation smoke and compatibility coverage.
7. `T07-G` Integracao: complete and validated; final status and portfolio snapshots updated.

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

## T07-C Handoff

Status: `COMPLETE_VALIDATED`.

Delivered:

- Refugio now renders as a full-screen home surface with a central altar/ambient panel instead of the previous login/status/tabs list.
- Home hotspots open Battle, Base, Social, Competition, Shop and Profile/Account through the T07-B route shell.
- Dev Lab hotspots remain internal/editor-gated; Progression Lab appears on the Refugio only when the editor/dev setting is enabled.
- Account/login/register/guest/save/update controls moved into the focused `account` route/panel, preserving existing `boot.gd` actions.
- Focused GUT coverage validates Refugio hotspots, account route, dev Progression Lab visibility and the moved account controls.

Validation:

- `tools/validate.gd`: passed with `79/79` tests and `894` asserts.
- GUT client completo: passed with `79/79` tests and `894` asserts.
- `tools/smoke_session_shell.gd`: passed with anonymous auth, guest account and `account/state`.
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

## T07-E Handoff

Status: `COMPLETE_VALIDATED`.

Delivered:

- `battle_running` renders a full-screen overlay using the existing `BattleReplayPresenter`, `BattleVisualMockup` and `BattleStage2D` replay path.
- The battle overlay uses a 16:9 landscape frame for Android, PC and Web windows, while Android orientation lock/restoration remains owned by the T07-B route helper.
- A large fixed `Pular` button sits in the lower-right corner and remains enabled while replay is running.
- Replay completion or skip transitions to `battle_summary`, restoring app orientation and rendering a full-screen summary.
- Summary shows winner, duration, event count, mode, reward/resources, and actions: `Voltar ao Refugio`, `Rever replay`, `Historico`.
- Existing battle request/latest/history/replay endpoints, `battle_log_v1`, simulator and reward flow were not changed.

Validation:

- GUT client complete: passed with `81/81` tests and `907` asserts.
- `tools/validate.gd`: passed with `81/81` tests and `907` asserts.
- `tools/smoke_battle_replay.gd`: passed when `BATTLE_FUNCTION_URL` pointed to the current `battle` function served from this worktree. The default local Supabase Edge Runtime was still mounted to another worktree and returned `NOT_FOUND` for `/battle/history`.
- `git diff --check`: passed.

## T07-F Handoff

Status: `COMPLETE_VALIDATED`.

Delivered:

- Added `tools/smoke_mobile_presentation.gd` to exercise the presentation loop without network.
- Smoke covers portrait Refugio/home, account route, Back behavior, landscape internal app route, scroll reset, battle fullscreen route, landscape declaration and battle summary actions.
- `tools/validate.gd` now checks that the presentation smoke exists.

Validation:

- `tools/smoke_mobile_presentation.gd`: passed.
- `tools/smoke_exports.gd`: passed.
- `tools/validate.gd`: passed with `85/85` tests and `968` asserts.
- GUT client complete: passed with `85/85` tests and `968` asserts.

## T07-G Integration

Status: `COMPLETE_VALIDATED`.

Delivered:

- Integrated T07-D and T07-E into `codex/draxos-mobile/t07-integration` after T07-C and resolved documentation conflicts without changing backend/schema/economy/rewards/ranking/simulator contracts.
- Added the T07-F mobile presentation smoke directly in the integration worktree because C/D/E were already available there.
- Updated `implementation/current-status.md`, Track 07 status, agent registry, implementation plan and portfolio snapshots.

Final validation:

- `tools/validate.gd`: passed with `85/85` tests and `968` asserts.
- GUT client complete: passed with `85/85` tests and `968` asserts.
- `tools/smoke_session_shell.gd`: passed.
- `tools/smoke_foundation_surfaces.gd`: passed.
- `tools/smoke_mobile_presentation.gd`: passed.
- `tools/smoke_exports.gd`: passed.
- `tools/smoke_battle_replay.gd`: passed with `BATTLE_FUNCTION_URL` pointing to the current `battle` function served from the integration worktree.
- `git diff --check`: passed after final status updates.

Known operational note:

- The already-running local Supabase Edge Runtime on `127.0.0.1:54321` was still serving an older `battle` function and returned `NOT_FOUND` for `/battle/history`. Restart/redeploy local functions before using the default local endpoint for battle history/replay validation.

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
