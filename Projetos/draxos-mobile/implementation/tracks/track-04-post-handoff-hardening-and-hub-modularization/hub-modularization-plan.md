# Track 04 - Hub Modularization Plan

- Status: `T04-B_COMPLETE`
- Last Updated: `2026-05-27`
- Branch: `codex/draxos-mobile/t04-hub-scaffold`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t04-hub-scaffold`
- Dependency: `T04-A` coordination update.

## Objective

Reduce `modes/boot/boot.gd` incrementally without changing player-visible behavior.

The first scaffold creates render-only presenters under `modes/boot/surfaces/`. Each presenter receives `host: Node`, builds only UI controls, and calls existing host helpers such as `_add_body_text`, `_add_action_button`, `_add_social_input`, `_add_output_label` and the existing state render helpers.

## Current Boot Map

| Area | Current Owner | Notes |
|---|---|---|
| Shell, header, nav, scroll root and confirmation dialog | `boot.gd` | Keep in host until T04-C defines shell ownership. |
| Screen routing/history | `boot.gd` | `_show_screen`, `_go_back`, nav sync and telemetry remain host-owned. |
| Hub/account/save/update render shell | `surfaces/hub_surface_presenter.gd` | Render-only; auth/session actions still execute in `boot.gd`. |
| Battle tab render shell | `surfaces/battle_surface_presenter.gd` | Creates `BattleVisualMockup`; replay execution remains in `boot.gd`. |
| Base tab render shell | `surfaces/base_surface_presenter.gd` | Creates action shell and state container; Base state panels/helpers stay in host for now. |
| Social tab render shell | `surfaces/social_surface_presenter.gd` | Creates inputs/actions/state container; social actions/network stay in host. |
| Competition tab render shell | `surfaces/competition_surface_presenter.gd` | Creates matchmaking/ranking shell; endpoint calls stay in host. |
| Shop tab render shell | `surfaces/shop_surface_presenter.gd` | Owns shop button specs as UI metadata only; purchases/rewards stay in host. |
| Actions, confirmations and busy states | `boot.gd` | `_execute_action`, `_set_busy`, `_sync_buttons` remain host-owned. |
| Supabase/network calls | `boot.gd` + `SupabaseClient` | Do not move during T04-B. |
| SessionStore mutations/cache | `boot.gd` + `SessionStore` | Do not move during T04-B. |
| State panel rendering helpers | `boot.gd` | Base/Social/Competition/Shop detail panels stay in host until their dedicated extraction. |
| Telemetry | `boot.gd` | `screen_opened`, action and network events remain host-owned. |

## Scaffold Contract

- Presenters must be deterministic and render-only.
- Presenters may assign host UI references such as `_timeline_label`, `_battle_visual` and surface state containers.
- Presenters must not call `SupabaseClient`, mutate `SessionStore`, emit telemetry, run async actions, or change navigation state.
- Action IDs remain stable because the host still owns `_execute_action`.
- No backend, schema, economy, ranking, battle simulator or HTTP contract changes are allowed in this package.

## Extraction Order

1. `T04-B` scaffold: presenter files, Boot delegation, GUT smoke for shell rendering.
2. `T04-C` shell/login/update: move login/update render details and related shell helpers behind a dedicated shell presenter/controller, still without backend changes.
3. `T04-F` battle/replay: move battle visual composition and replay control rendering; keep `BattleLogPresenter`, `BattleVisualMockup` and replay timing behavior stable.
4. `T04-D` Base/Loja: move Base state panels first, then Shop panels; keep endpoints and product/reward IDs unchanged.
5. `T04-E` Social/Competicao: move social and ranking panel rendering; keep polling, chat, leaderboard and ranking calls unchanged.
6. Labs dev-only only after the main surfaces are stable.

## Validation Matrix

| Package | Required Validation |
|---|---|
| T04-B scaffold | Godot `tools/validate.gd`, GUT client, `git diff --check` |
| T04-C shell/login/update | `tools/smoke_session_shell.gd`, GUT shell/update coverage, `git diff --check` |
| T04-D Base/Loja | smoke alpha loop or focused Base/Shop smoke, GUT surface coverage, `git diff --check` |
| T04-E Social/Competicao | social/competition smoke coverage, GUT surface coverage, `git diff --check` |
| T04-F Batalha/Replay | `tools/smoke_battle_replay.gd`, GUT battle presenter/mockup/stage coverage, `git diff --check` |

## Handoff Point

T04-B hands off when:

- `boot.gd` delegates top-level surface rendering to `modes/boot/surfaces/`;
- actions/network remain in `boot.gd`;
- the Track 04 plan names the next extraction order;
- Godot validate, GUT and `git diff --check` are green.

Current handoff result:

- `modes/boot/boot.gd` delegates top-level Hub/Battle/Base/Social/Competition/Shop render shells to presenters.
- `modes/boot/surfaces/README.md` records presenter ownership.
- `tests/client/test_boot_mobile_ui.gd` covers presenter shell rendering without network actions.
- Validation passed: Godot validate, GUT client and `git diff --check`.
