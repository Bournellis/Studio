# Track 05 - Validation Matrix

- Status: `T05-B_READY_FOR_INTEGRATION`
- Last Updated: `2026-05-27`
- Owner: `T05-B Validation Matrix`
- Worktree-safe path token: `<WORKTREE>\Projetos\draxos-mobile`

## Goal

Make DraxosMobile validation reproducible for Track 05 without changing gameplay behavior, economy, schema, HTTP contracts, assets or release state.

This matrix defines four lanes:

- `quick`: local Godot/client sanity for frequent iteration.
- `full`: local runtime confidence before handoff or integration.
- `release`: export/manifest/package readiness without publishing.
- `remote`: explicit remote smoke path, guarded by env vars and never using service role in the client.

## Guardrails

- Always run commands against a dedicated worktree, never `D:\Estudio` for implementation.
- Do not run remote publication, Storage upload, Cloudflare deploy or `supabase db push` from T05-B.
- Keep `players.save_type`; do not create `account_profiles` + `game_saves`.
- Do not tune economy, combat, reward, bot, shop or power numbers.
- Client smokes may call existing endpoints through `SupabaseClient`; they must not add endpoints or new payload contracts.
- Remote smokes require explicit env vars and must reject local URLs and service-role keys.

## Smoke Audit

| Surface | Existing Coverage | T05-B Decision |
|---|---|---|
| Session/account shell | `tools/smoke_session_shell.gd` covers anonymous auth, guest account and account/state through `SessionStore`. | Keep as required quick/full runtime smoke. |
| Battle replay | `tools/smoke_battle_replay.gd` covers battle/request, `battle_log_v1`, presenter formatting and battle/latest. | Keep as required full/runtime smoke. |
| Integrated alpha loop | `tools/smoke_alpha_loop.gd` covers battle, Base, Social, Competition, Shop and telemetry in one long client flow. | Keep as end-to-end local runtime smoke; not ideal as the only foundation surface smoke because failures are broad. |
| Base | `smoke_alpha_loop.gd`, `server/tests/base_manager_smoke.ts`, GUT session/presenter tests. | Add focused Godot smoke in `tools/smoke_foundation_surfaces.gd`. |
| Shop | `smoke_alpha_loop.gd`, `server/tests/monetization_rewards_smoke.ts`, GUT session/presenter tests. | Add focused Godot smoke in `tools/smoke_foundation_surfaces.gd`. |
| Social | `smoke_alpha_loop.gd`, `server/tests/social_competition_smoke.ts`, GUT session/presenter tests. | Add focused Godot smoke in `tools/smoke_foundation_surfaces.gd`. |
| Competition | `smoke_alpha_loop.gd`, `server/tests/social_competition_smoke.ts`, GUT session/presenter tests. | Add focused Godot smoke in `tools/smoke_foundation_surfaces.gd`. |
| Dev labs | `tools/smoke_dev_labs.gd`, `tools/smoke_dev_lab_ui.gd`, Deno lab tests. | Keep in full lane or Progression-specific packages. |
| Exports | `tools/smoke_exports.gd`, `tools/export_internal_alpha.ps1`. | Keep `smoke_exports.gd` in release lane; export script only when release ops asks for local artifacts. |
| Remote alpha | `server/tests/internal_alpha_remote_smoke.ts`, `release_manifest_smoke.ts`. | Keep remote lane opt-in only; no publication from T05-B. |

## Lane Matrix

| Lane | Use When | Preconditions | Commands | Pass Criteria |
|---|---|---|---|---|
| `quick` | Any doc/client/test edit before commit. | Godot 4.6.2 local tool exists. No Supabase runtime required. | `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/validate.gd`<br>`D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`<br>`git diff --check` | Content generation, resource checks and GUT pass. Diff has no whitespace errors. |
| `full` | Before handoff for client/runtime work or T05-H integration. | Supabase local is running and migrations are clean. Deno/npm available through `npx`. | `npx -y supabase db reset` from `<WORKTREE>\Projetos\draxos-mobile`<br>`D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/validate.gd`<br>`D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`<br>`D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/smoke_session_shell.gd`<br>`D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/smoke_battle_replay.gd`<br>`D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/smoke_foundation_surfaces.gd`<br>`D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/smoke_alpha_loop.gd`<br>`npx -y deno task check --cwd supabase/functions`<br>`npx -y deno task check --cwd server/functions`<br>`npx -y deno run --allow-net --allow-env server/tests/base_manager_smoke.ts`<br>`npx -y deno run --allow-net --allow-env server/tests/social_competition_smoke.ts`<br>`npx -y deno run --allow-net --allow-env server/tests/monetization_rewards_smoke.ts`<br>`git diff --check` | Local DB resets, Godot validates, focused foundation surfaces pass, integrated alpha loop passes and server smokes protect deeper Base/Social/Competition/Shop behavior. |
| `release` | Before local release artifact prep or release-ops handoff. | Do not publish. Export templates may be absent for smoke-only checks. | `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/smoke_exports.gd`<br>`npx -y deno task check --cwd supabase/functions`<br>`npx -y deno task check --cwd server/functions`<br>`npx -y deno run --allow-net --allow-env server/tests/release_manifest_smoke.ts` against local Supabase when release function is running<br>`git diff --check` | Export presets are structurally valid, release function type-checks and local manifest smoke passes when runtime is available. No remote state changes. |
| `remote` | Only when integration/release ops explicitly asks to verify the published Internal Alpha. | Set `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`. Optional flags must be intentional. Never use service-role key. | `$env:SUPABASE_URL='https://<project-ref>.supabase.co'`<br>`$env:SUPABASE_PUBLISHABLE_KEY='sb_publishable_<public-key>'`<br>`$env:DRAXOS_REMOTE_RELEASE_SMOKE='1'` when manifest is in scope<br>`npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts` | Remote smoke rejects unsafe config, health/manifest/account paths pass according to selected flags, and no publish/upload/deploy command is run. |

## Required T05-B Handoff Set

For this T05-B branch, the required validation set is:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t05-validation-matrix\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t05-validation-matrix\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t05-validation-matrix\Projetos\draxos-mobile -s res://tools/smoke_foundation_surfaces.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t05-validation-matrix\Projetos\draxos-mobile -s res://tools/smoke_session_shell.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t05-validation-matrix\Projetos\draxos-mobile -s res://tools/smoke_battle_replay.gd
git diff --check
```

If Supabase local is unavailable, record the blocker in the Doing note instead of substituting remote state.

## T05-B Validation Result

Validated on `2026-05-27` in `D:\Estudio-worktrees\draxos-mobile--codex--t05-validation-matrix`:

- `tools/validate.gd`: pass.
- GUT client suite: pass.
- `tools/smoke_foundation_surfaces.gd`: pass.
- `tools/smoke_session_shell.gd`: pass.
- `tools/smoke_battle_replay.gd`: pass.
- `git diff --check`: pass.

## Failure Response

- `quick` failure: fix local resource/test issue before any runtime smoke.
- `full` failure: preserve the first failing command output in the handoff and do not keep running mutation smokes blindly.
- `release` failure: do not publish; hand off to T05-G or T05-H with the failing command.
- `remote` failure: do not change remote state from this branch; document env flags, endpoint and failure code.

## Non-Goals

- No new validation lane changes release policy.
- No smoke added here creates gameplay rules.
- No smoke added here replaces Deno server smokes for backend behavior.
- No command here promotes assets, service migrations or production monetization.
