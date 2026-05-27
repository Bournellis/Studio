# Track 07 - Current Status

- Last Updated: `2026-05-27`
- Status: `ACTIVE_PRESENTATION_REWORK`
- Depends On: `T06_INTEGRATED_FEATURE_SLICES_READY`
- Current Stage: `T07_A_COORDINATION`
- Next Action: integrate the App Shell/Foundation branch, then run Refugio, app screens and battle fullscreen work in parallel.

## Estado

Track 07 is active as the mobile-first presentation and layout rework.

The track responds to the first post-Track 06 walkthrough findings: the current Hub still reads like a tab/list app, touch scrolling competes with buttons, the scrollbar affordance is too narrow, Refugio/account/login are cluttered, Progression Lab access became too hidden, and battle should feel like a full-screen landscape game moment instead of a screen inside the Hub chrome.

## Ordem Atual

1. `T07-A` Coordenacao: in progress on `codex/draxos-mobile/t07-coordenacao`.
2. `T07-B` App Shell/Foundation: planned after `T07-A`; creates routes, back stack, orientation helpers and scroll/touch foundation.
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
