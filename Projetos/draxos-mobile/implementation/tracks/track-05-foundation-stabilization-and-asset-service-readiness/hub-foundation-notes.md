# T05-C - Hub Foundation Notes

- Date: `2026-05-27`
- Branch: `codex/draxos-mobile/t05-hub-foundation`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t05-hub-foundation`
- Status: `READY_FOR_INTEGRATION`

## Scope

Reduce structural risk in the Boot Hub after Track 04 without changing behavior.

Ownership remains:

| Area | Owner |
|---|---|
| screen routing/history, actions, confirmations and busy states | `modes/boot/boot.gd` |
| Supabase calls, manifest fetches and save type configuration | `modes/boot/boot.gd` + `online/supabase_client.gd` |
| `SessionStore` mutations/cache/recovery | `modes/boot/boot.gd` + `online/session_store.gd` |
| telemetry emission | `modes/boot/boot.gd` |
| render-only Hub/Battle/Base/Social/Competition/Shop surfaces | `modes/boot/surfaces/` |

## Audit Result

- `boot.gd` still owns online actions, replay execution, session recovery, Supabase calls, busy state, confirmation flow and telemetry.
- Surface presenters build controls and render already-loaded snapshots; they do not await, fetch, mutate session state, emit telemetry or configure backend state.
- `battle_surface_presenter.gd` was obsolete: `boot.gd` no longer preloaded it, and the active Battle tab uses `battle_replay_presenter.gd`.
- The update gate presenter had one direct `SupabaseClient.manifest_url()` fallback. That fallback moved behind `boot.gd` so Supabase ownership stays host-side.

## Changes

- Retired obsolete `modes/boot/surfaces/battle_surface_presenter.gd`.
- Updated `modes/boot/surfaces/README.md` to describe the retired Battle scaffold and the render-only contract.
- Added `boot.gd::_manifest_url()` as the host-owned manifest URL fallback used by the update presenter.
- Added focused GUT coverage that scans surface presenter scripts for forbidden host-owned concerns and asserts the retired Battle scaffold is absent.
- Made Boot surface tests clear cached `SessionStore` state before each test so external `user://session_cache.json` data cannot switch the suite into local-only Progression Lab mode.

## Explicit Non-Changes

- No `SupabaseClient`, `SessionStore`, `BackendConfig`, HTTP contract, economy, battle simulator, schema or Edge Function changes.
- No player-visible text, button IDs, endpoint payloads, rewards, power, bot, shop or combat number changes.

## Validation

- Pass: `tools/validate.gd`.
- Pass: GUT client.
- Pass: `tools/smoke_session_shell.gd`.
- Pass: `tools/smoke_battle_replay.gd`.
- Pass: `git diff --check`.
