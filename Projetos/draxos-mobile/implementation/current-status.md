# DraxosMobile - Current Status

- Last updated: `2026-06-03`
- Project: `draxos-mobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `Internal Alpha`
- Active stage: `First Access Runtime Publication`
- Active stage status: `PUBLISHED_INTERNAL_ALPHA`
- Hardening baseline: `Track 13 - Foundation Validation And Release Safety`
  (`TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`)
- Agent baseline: `Track 14 - Agent Operations Foundation`
  (`TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`)
- Latest published remote package: `First Access Runtime Fix`, release root
  `internal-alpha/v0-first-access-runtime-20260602-4608977`,
  official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`,
  direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`,
  latest deployment evidence
  `https://36db2742.draxos-mobile-internal-alpha.pages.dev`. This package keeps
  the integrated runtime fix baseline and adds first-access responsiveness:
  surfaces render local shells before network refresh when no cache exists, Arena
  first access shows a server-sync shell without dev fallback actions, and local
  DatabaseLocal/Mode smoke coverage now matches the active Bosque v1 contract.
- Latest implemented local package: `Openworld Sync Stability` on branch
  `codex/draxos-mobile/openworld-sync-stability`; it fixes Bosque event ACK
  rollback by applying authoritative event patches instead of hydrating full
  snapshots during active gameplay. This package is local only and has not been
  published.
- Previous runtime fix package: `Integrated Runtime Fix`, release root
  `internal-alpha/v0-integrated-runtime-fix-20260602-ab5834c`,
  deployment evidence `https://888320f4.draxos-mobile-internal-alpha.pages.dev`.
- Previous integrated App/Arena/Bosque package: release root
  `internal-alpha/v0-integrated-app-arena-bosque-20260602-99304ed`,
  deployment evidence `https://8f2829c0.draxos-mobile-internal-alpha.pages.dev`.
- Previous Web shell package: `Web Launch Resilience`, release root
  `internal-alpha/v0-web-launch-resilience-20260602-49dc5ea`,
  deployment evidence `https://9ba71c4e.draxos-mobile-internal-alpha.pages.dev`.
- Previous visual package: `Refugio Visual Cleanup`, release root
  `internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0`,
  deployment evidence `https://f183cd39.draxos-mobile-internal-alpha.pages.dev`.
- Previous functional package: `Openworld QoL Regression Fix`, release root
  `internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129`,
  deployment evidence `https://95f403c5.draxos-mobile-internal-alpha.pages.dev`.
- Previous hardening baseline: `Foundation Hardening V2`, release root
  `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, Cloudflare
  preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`.
- Validation baseline marker: the latest published remote package is now the
  first access runtime fix package; `Foundation Hardening V2` remains the previous
  hardening/live-doc guard marker.
- Compatibility validation marker: Latest published remote package: `Foundation Hardening V2`
  remains as legacy guard text for Track 13/V2 docs validation; actual latest
  published remote package is the first access runtime fix release above.
- Active follow-up: human review/playtest of the local Openworld Sync Stability
  branch, focused on online Bosque movement, collection, deposit, craft,
  revision conflict/resync and completion behavior. Latest published remote
  package remains the first access runtime fix until a separate publication is
  explicitly approved.
- Latest technical package: `Track 16 - Behavior And Potion Crafting` (technical
  context, not current product focus; current state summarized in
  `docs/behavior-potion-crafting-v1.md`)
- Build channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`

## Openworld Sync Stability - 2026-06-03

This local package addresses the frequent Bosque rollback/desync reported after
the hardening v1 publication. It is implemented in a dedicated worktree and is
not published.

- branch: `codex/draxos-mobile/openworld-sync-stability`;
- commit: `HEAD - Fix openworld event ack sync stability`;
- worktree:
  `D:\Estudio-worktrees\draxos-mobile--codex--openworld-sync-stability`;
- remote publication: not executed;
- remote mutation: not executed;
- latest published remote package remains
  `internal-alpha/v0-first-access-runtime-20260602-4608977`.

Scope delivered:

- `/modes/session/event` returns `mode_event_ack` with `revision_after`,
  `snapshot_patch`, authoritative field metadata and visual authority metadata.
- Generic mode contract now separates full state snapshots, event ACK patches
  and completion results.
- Bosque client no longer hydrates full snapshots from ordinary event ACKs
  during active play, preventing old server position from pulling the player
  backward.
- Player position and active collection remain client-authoritative while the
  session is active; server-authoritative patch fields still update pocket,
  chest, upgrades, collected nodes, score, reward payload and derived weights.
- Collection completion keeps local pending visual state until server ACK
  confirms the collected node.
- Stale revision conflict still triggers explicit resync, now with discreet
  player-facing text.
- Server/supabase function mirrors remain aligned.

Validation:

- `git diff --check`: passed.
- `npx -y deno task --cwd server/functions check`: passed.
- `npx -y deno task --cwd supabase/functions check`: passed.
- `npx -y deno test --allow-read server/tests/modes_domain_test.ts server/tests/modes_platform_schema_test.ts`:
  passed.
- Godot `--headless --import`: passed.
- GUT `test_openworld_mode_dev`: passed (`25/25`, `107` asserts).
- `tools/smoke_openworld_forest.gd`: passed.
- `tools/smoke_modes_visual_layout.gd`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: passed
  on rerun; the first run had an unrelated `tools/validate.gd` navigation flake,
  while its GUT matrix passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ModePlatform`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: passed.

## First Access Runtime Publication - 2026-06-02

This release publishes the first-access responsiveness and local validation
repair follow-up as one Internal Alpha on the official URL.

- branch: `codex/draxos-mobile/first-access-runtime`;
- commit: `4608977`;
- release root:
  `internal-alpha/v0-first-access-runtime-20260602-4608977`;
- Cloudflare production:
  `https://draxos-mobile-internal-alpha.pages.dev`;
- Cloudflare deployment evidence:
  `https://36db2742.draxos-mobile-internal-alpha.pages.dev`;
- Official Portal / manifest `portal_url`:
  `https://draxos-mobile-internal-alpha.pages.dev/`;
- Web:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`;
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-first-access-runtime-20260602-4608977/downloads/draxos-mobile-alpha.apk`;
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-first-access-runtime-20260602-4608977/downloads/draxos-mobile-alpha.zip`;
- remote manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`;
- preview Web launch smoke screenshot:
  `build/diagnostics/web-launch-remote-20260603-000139/web-launch-remote.png`.

Runtime fixes delivered:

- First access without cache renders a local surface shell immediately before
  network refresh while preserving `rendered_from_cache = false`.
- Arena first access without remote state shows a sync shell and suppresses dev
  fallback attempt actions until the server response arrives.
- Local Edge `BOOT_ERROR` was isolated to a stale Supabase container mount from
  an old/deleted worktree; restarting/linking the stack from the current
  worktree restored healthcheck.
- Local Supabase DB validation was reset from migrations after the previous DB
  history proved inconsistent, then `DatabaseLocal` passed.
- Mode platform live smoke now validates the active Bosque v1 contract:
  `openworld` status `active`, `release_channel = internal_alpha` and
  `openworld_forest_ruleset_v1`.

Validation and publication evidence:

- `deno check server/tests/modes_platform_live_test.ts`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile DatabaseLocal`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: passed
  with 181/181 GUT tests and 3249 asserts.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: passed; Android
  export mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan`, `Package`, `Upload` and
  `DeployManifest`: passed with `-ConfirmRemoteMutation` for mutating stages.
- `build_cloudflare_pages_package.ps1`: passed and matched remote Web asset
  sizes for the versioned Storage root.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name
  draxos-mobile-internal-alpha --branch main`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly
  -AllowCloudflareAccess`: passed.
- `tools/smoke_web_launch_remote.ps1` on preview `36db2742`: `game_loaded` in
  4946 ms, release root matched, no runtime errors.

## Integrated Runtime Fix Publication - 2026-06-02

This release corrects and republishes the integrated App/Arena/Bosque package as
one Internal Alpha on the official URL.

- branch: `codex/draxos-mobile/integrated-runtime-fix`;
- release root:
  `internal-alpha/v0-integrated-runtime-fix-20260602-ab5834c`;
- Cloudflare production:
  `https://draxos-mobile-internal-alpha.pages.dev`;
- Cloudflare deployment evidence:
  `https://888320f4.draxos-mobile-internal-alpha.pages.dev`;
- Official Portal / manifest `portal_url`:
  `https://draxos-mobile-internal-alpha.pages.dev/`;
- Web:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`;
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-integrated-runtime-fix-20260602-ab5834c/downloads/draxos-mobile-alpha.apk`;
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-integrated-runtime-fix-20260602-ab5834c/downloads/draxos-mobile-alpha.zip`;
- remote manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`;
- preview Web launch smoke screenshot:
  `build/diagnostics/web-launch-remote-20260602-223337/web-launch-remote.png`.

Runtime fixes delivered:

- Bosque online serializes authoritative session events and waits for each ACK
  before sending the next revision-gated event.
- Bosque collection, deposit and craft no longer mutate reward-bearing local
  state before server confirmation.
- `/modes/session/event` returns the common mode envelope.
- Arena PVE battle logs include `metadata.mode = "PVE_ARENA_V1"`,
  `duel_index` and `duel_count` so the client can activate replay/reward UI.
- Remote `mode_limit_policies` compatibility now supports the live `active`
  policy filter used by Bosque start.
- Web launch smoke treats Cloudflare Access login as an expected protected
  production state instead of failing on login-page console noise.

Publication and validation completed:

- `supabase db push --linked --yes`: passed; applied
  `202606020002_openworld_bosque_policy_active_compat.sql`.
- `supabase functions deploy --project-ref armxgipvnbbshzqawklw`: passed for
  `modes`, `arena` and `release`.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: passed; Android
  mode is `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`: passed.
- `build_cloudflare_pages_package.ps1`: passed.
- `wrangler pages deploy build\internal-alpha\cloudflare-pages --project-name
  draxos-mobile-internal-alpha --branch main`: passed; preview
  `https://888320f4.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`:
  passed; manifest `released_at` is `2026-06-02T22:31:37Z`.
- `release_manifest_smoke.ts`: passed.
- `release_artifacts_remote_smoke.ts`: passed; stable Portal/Web are protected
  by Cloudflare Access as expected.
- `internal_alpha_remote_smoke.ts` with release, anon auth, account, email auth,
  mode and Arena enabled: passed; Bosque and Arena remote sessions were created.
- `smoke_web_launch_remote.ps1` against the stable URL: passed as
  `outcome=cloudflare_access_expected`.
- `smoke_web_launch_remote.ps1` against the preview URL: passed as
  `outcome=game_loaded`, `loaded_after_ms=5838`, with release root and asset
  root matching.

## Integrated App Responsiveness, Arena Loop And Openworld Bosque Publication - 2026-06-02

This release merges and publishes the three completed Codex workstreams:
server/app responsiveness, Autobattler Arena loop flow, and Openworld Bosque
foundation hardening. It updates backend schema, Edge Functions, Android/PC/Web
artifacts, Cloudflare Pages and the remote release manifest.

- merged commits/stages on `master`: app responsiveness (`cfab8f8` via
  `f1caa4b`), Arena loop simplification/feedback (`f8dbdad`, `ab6e1b3` via
  `65c9cef`), Openworld Bosque hardening (`ad5e807` via `b7a314b`),
  integrated validation (`49d380f`) and Bosque migration compatibility
  (`99304ed`);
- release root:
  `internal-alpha/v0-integrated-app-arena-bosque-20260602-99304ed`;
- Cloudflare production:
  `https://draxos-mobile-internal-alpha.pages.dev`;
- Cloudflare deployment evidence:
  `https://8f2829c0.draxos-mobile-internal-alpha.pages.dev`;
- Official Portal / manifest `portal_url`:
  `https://draxos-mobile-internal-alpha.pages.dev/`;
- Compatibility Portal path:
  `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
  redirects to the official root;
- Web:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`;
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-integrated-app-arena-bosque-20260602-99304ed/downloads/draxos-mobile-alpha.apk`;
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-integrated-app-arena-bosque-20260602-99304ed/downloads/draxos-mobile-alpha.zip`;
- remote manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`;
- Web launch smoke screenshot:
  `build/diagnostics/web-launch-remote-20260602-202832/web-launch-remote.png`.

Publication and validation completed:

- `supabase db push`: passed after adding compatibility columns/index for the
  live `mode_limit_policies` schema.
- `supabase functions deploy --project-ref armxgipvnbbshzqawklw`: passed for
  local functions, including updated account/arena/base/battle/build/
  competition/crafting/lab-runner/modes/monetization/progression-lab/social.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: passed; Android
  mode is `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`: passed.
- `build_cloudflare_pages_package.ps1`: passed and verified remote Web asset
  sizes before Pages packaging.
- `wrangler pages deploy ... --branch main`: passed; preview
  `https://8f2829c0.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`:
  passed and redeployed the `release` function.
- Official URL manifest hotfix:
  `publish_internal_alpha.ps1 -ProjectDir D:\Estudio\Projetos\draxos-mobile -ReleaseRoot internal-alpha/v0-integrated-app-arena-bosque-20260602-99304ed -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`
  passed on 2026-06-02; remote manifest `released_at` is
  `2026-06-02T20:53:32Z`, `portal_url` is
  `https://draxos-mobile-internal-alpha.pages.dev/`, and direct Web remains
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`.
- `wrangler pages deployment list`: latest Cloudflare Pages deployment remains
  Production/main/source `99304ed` with evidence
  `https://8f2829c0.draxos-mobile-internal-alpha.pages.dev`.
- `release_manifest_smoke.ts` and `release_artifacts_remote_smoke.ts` passed
  after the manifest hotfix; Portal/Web official URLs return Cloudflare Access
  in anonymous reads, as expected.
- `smoke_web_launch_remote.ps1` against the preview hash: passed,
  `outcome=game_loaded`, `loaded_after_ms=6737`, release root and asset root
  matched.
- `release_artifacts_remote_smoke.ts`: passed; stable Portal/Web are protected
  by Cloudflare Access as expected, downloads/manifest are reachable.
- `internal_alpha_remote_smoke.ts` with release manifest enabled: passed for
  healthcheck, CORS and manifest.
- Remote Web asset size check: `index.pck` local and remote
  `Content-Length` both `4660188`; `index.wasm` local and remote
  `Content-Length` both `37695054`.

Known release notes:

- Android remains `debug_fallback` until release keystore is configured for
  broader Android distribution.
- Stable Cloudflare Pages root is the official Portal and canonical
  `portal_url`; the direct Web URL remains `/web/index.html`. The production
  domain may be Cloudflare Access-protected; use the hash preview as technical
  evidence.
- Next product step is human playtest of the integrated package: login/cache
  refresh, first Arena real loop and next difficulty unlock, plus online Bosque
  start/event/deposit/complete behavior.

## App Responsiveness Architecture Pass - 2026-06-02

This local package improves perceived responsiveness across DraxosMobile
without changing the Supabase/Cloudflare provider stack and without publishing
a new remote Internal Alpha.

Publication note: this workstream was later published as part of
`internal-alpha/v0-integrated-app-arena-bosque-20260602-99304ed`.

- branch: `codex/draxos-mobile/app-responsiveness`;
- worktree:
  `D:\Estudio-worktrees\draxos-mobile--codex--app-responsiveness`;
- remote publication: not executed;
- remote mutation: not executed.

Scope delivered:

- Surface refresh is cache-first, then server-refresh-in-background, with
  lifecycle tokens preventing stale responses from overwriting newer state.
- `SessionStore` persists surface refresh metadata and request latency logs.
- `DraxosOperationState` is the authority for busy state by scope; navigation
  remains usable unless an app-level/replay scope requires blocking.
- Account, Base, Arena, Battle, Preparation/Build, Crafting, Social,
  Competition/Ranking, Shop/Monetization, Mode Hub, Mode Shell, Modes
  Ops/Admin, Battle Lab and Progression Lab now use the surface refresh pattern.
- Battle and Arena Duel keep server-authoritative result semantics; the client
  shows real waiting/status and does not start replay/summary before the server
  payload arrives.
- State endpoints now use a shared response envelope with `api_version`,
  `account`, `save`, `cache.generated_at` and `server_timing`.
- `/arena/pve/state` now returns a lightweight projection of list/unlocks/
  records/active attempt, leaving full loadout data to start/duel/buff flows.
- Mutations return affected surface deltas where useful, reducing immediate
  follow-up fetches after actions such as alpha purchases.
- Local and remote telemetry payloads now cover `request_latency`,
  `surface_refresh`, `surface_cache_rendered` and `action_latency`.

Validation:

- `git diff --check`: passed.
- `deno task check` in `server/functions`: passed.
- `deno task check` in `supabase/functions`: passed.
- `deno test --allow-read server/tests/api_version_contract_test.ts server/tests/arena_loop_unlock_friction_test.ts server/tests/lab_runner_contract_test.ts`:
  passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile FullLocal`: partial;
  all DocsOnly, ServerQuick, ModePlatform, ClientQuick and ReleaseDryRun stages
  passed, and local Supabase transactional RPC live proof passed. The three
  local Edge Runtime live smokes failed because the local Edge worker returned
  `BOOT_ERROR` at `http://127.0.0.1:54321`; no remote mutation was attempted.

## Openworld Bosque Hardening V1 - 2026-06-02

Status: implemented first in a dedicated worktree and later published as part
of `internal-alpha/v0-integrated-app-arena-bosque-20260602-99304ed`.

- branch: `codex/draxos-mobile/bosque-hardening`;
- worktree:
  `D:\Estudio-worktrees\draxos-mobile--codex--bosque-hardening`;
- release channel remains `internal_alpha`;
- no upload, Cloudflare deploy, manifest update, remote migration or
  `-ConfirmRemoteMutation` command was executed in the original worktree
  delivery; those publication steps were completed during the integrated
  release above.

Scope delivered:

- `openworld/forest` is prepared as an `active` Internal Alpha mode using
  `openworld_forest_ruleset_v1`.
- The Bosque ruleset moved to the shared versioned definition
  `data/definitions/openworld/forest_ruleset_v1.json`; v0 remains historical.
- Local client and Edge Functions now share ruleset identity, session limits,
  item, recipe and node definitions.
- `mode_sessions` gains remote snapshot/revision fields and
  `mode_session_events` records revision-gated session events.
- `POST /modes/session/event` accepts `move_heartbeat`, `collect_start`,
  `collect_cancel`, `collect_complete`, `deposit_all`, `craft`,
  `complete_requested` and `abandon_requested`.
- `GET /modes/state?mode_id=openworld` can return an active resumable Bosque
  session with snapshot, revision, expiry and status.
- `mode_session_complete_v1` calculates rewards from the server snapshot only;
  client-sent reward/deposit payloads are not authoritative.
- Offline/no-auth/network-failed Bosque remains playable only as preview and
  cannot complete for reward until resynced.
- Player-facing UI removes technical labels such as `integrated_alpha`,
  `online` and `dev_local`, keeping technical state inside operation details.
- The client mode registry now reports `openworld` as `active`, matching the
  descriptor while preserving the `internal_alpha` release channel.

Dependency gate:

- Merge/publication must wait for `codex/draxos-mobile/app-responsiveness` to
  become the baseline or be explicitly superseded, then this branch must be
  rebased and conflict-reviewed around `SessionStore`, `SupabaseClient`,
  response envelopes, cache and latency handling.
- The dirty/unmerged `arena-backend` work remains informative only; it does not
  block this Bosque hardening branch.

Validation completed locally:

- `git diff --check`: passed.
- Deno check for `server/functions/modes/index.ts` and
  `supabase/functions/modes/index.ts`: passed.
- Deno checks for local/remote mode live smoke scripts: passed.
- Deno tests for mode domain, reward bridge, ruleset definition, descriptor
  schema, registry, rate limit and mode platform schema: passed.
- Godot headless import: passed with known GUT import warnings.
- `tools/smoke_openworld_forest.gd`: passed.
- GUT client: passed, `174/174`, `3182` asserts.
- `tools/smoke_modes_visual_layout.gd`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ModePlatform`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: passed.
  The plan dry-run reported expected Package blockers because Supabase URL and
  local APK/ZIP/Web artifacts were intentionally absent in this non-publication
  delivery.

Remaining gates before publication:

- Re-run `ServerQuick`, `ModePlatform`, `ClientQuick` and `ReleaseDryRun` after
  the integration merge.
- Apply the migration only in an explicitly approved remote mutation window.
- Package/upload/deploy/manifest only after explicit publication approval.

## Web Launch Resilience - 2026-06-02

This release supersedes Refugio Visual Cleanup as the latest published Internal
Alpha without changing gameplay, backend, schema, migrations, endpoints,
economy, tuning, content or Reward Bridge behavior. It keeps the fixed
Cloudflare Access-protected production domain as the official manifest URL and
uses the preview hash only as technical launch evidence.

- branch: `codex/draxos-mobile/web-launch-resilience`;
- worktree:
  `D:\Estudio-worktrees\draxos-mobile--codex--web-launch-resilience`;
- implementation commit: `49dc5ea`;
- release root:
  `internal-alpha/v0-web-launch-resilience-20260602-49dc5ea`;
- Cloudflare production:
  `https://draxos-mobile-internal-alpha.pages.dev`;
- Cloudflare deployment evidence:
  `https://9ba71c4e.draxos-mobile-internal-alpha.pages.dev`;
- Portal:
  `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`;
- Web:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`;
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-web-launch-resilience-20260602-49dc5ea/downloads/draxos-mobile-alpha.apk`;
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-web-launch-resilience-20260602-49dc5ea/downloads/draxos-mobile-alpha.zip`;
- remote manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`;
- Web launch smoke screenshot:
  `D:\Estudio-worktrees\draxos-mobile--codex--web-launch-resilience\Projetos\draxos-mobile\build\diagnostics\web-launch-remote-20260602-042353\web-launch-remote.png`.

Scope delivered:

- `tools/build_cloudflare_pages_package.ps1` now emits a Web shell with
  `DRAXOS_RELEASE_ROOT`, `DRAXOS_WEB_ASSET_ROOT` and
  `window.DRAXOS_WEB_RELEASE`.
- Local Web assets use release-root cache-bust query strings:
  `/web/index.js`, splash and icons.
- A non-invasive 20s watchdog shows a readable troubleshooting message when
  the Godot splash remains visible, without interrupting `engine.startGame`.
- `engine.startGame` rejection now shows a readable on-page error while keeping
  the detailed failure in the console.
- Release-root changes trigger selective cache/service-worker cleanup for old
  Draxos/Godot/Internal Alpha caches without clearing Supabase sessions or game
  localStorage data.
- `tools/smoke_web_launch_remote.ps1` adds a Chrome/Edge CDP smoke that waits
  for `#status` to disappear, captures screenshot/logs under
  `build/diagnostics/`, checks the expected release root and fails on stuck
  splash, critical Web asset failures or relevant runtime/network errors.

Validation and publication:

- `git diff --check`: passed.
- First responsive smoke in the fresh worktree found missing Godot global-class
  cache; `Godot --headless --editor --quit --path .` rebuilt `.godot` with known
  GUT import warnings, then the smoke passed.
- `tools/smoke_responsive_layout.gd`: passed.
- GUT client: passed, `174/174`, `3182` asserts.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: passed.
- Android/PC/Web export passed; Android uses `debug_fallback` because release
  keystore was unavailable in this worktree.
- `publish_internal_alpha.ps1 -Mode Plan -ReleaseRoot internal-alpha/v0-web-launch-resilience-20260602-49dc5ea -PublicDownloads`: passed.
- `publish_internal_alpha.ps1 -Mode Package -ReleaseRoot internal-alpha/v0-web-launch-resilience-20260602-49dc5ea -PublicDownloads`: passed.
- `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-web-launch-resilience-20260602-49dc5ea -PublicDownloads -ConfirmRemoteMutation`: passed after linking the new worktree to Supabase project `armxgipvnbbshzqawklw`.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl <versioned-web-root>`:
  passed.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`:
  passed, deployment evidence
  `https://9ba71c4e.draxos-mobile-internal-alpha.pages.dev`, production URL
  `https://draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-web-launch-resilience-20260602-49dc5ea -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation`:
  passed, preserving the official stable Web URL in the manifest.
- `tools/smoke_web_launch_remote.ps1 -WebUrl https://9ba71c4e.draxos-mobile-internal-alpha.pages.dev/web/index.html -ExpectedReleaseRoot internal-alpha/v0-web-launch-resilience-20260602-49dc5ea`:
  passed; outcome `game_loaded`, splash cleared in `6715` ms.
- Preview Web HTML contains the expected release root and cache-busted
  `/web/index.js?v=internal-alpha%2Fv0-web-launch-resilience-20260602-49dc5ea`.
- Anonymous GET to the production fixed URL returns Cloudflare Access, expected
  for the protected domain.
- Remote `Content-Length` matched local bytes for `index.pck` (`4611048`) and
  `index.wasm` (`37695054`).
- `tools/validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly -AllowCloudflareAccess`:
  passed.

Next human check:

- Completed on `2026-06-02`: the user confirmed the Web build is functioning.
  This package can be merged to `master` and closed. Future validation can use
  the preview hash only as technical deployment evidence while the fixed
  production URL remains the official Access-protected Web URL.

## Refugio Visual Cleanup - 2026-06-02

This client-only visual package supersedes the Openworld QoL regression fix as
the latest published Internal Alpha without changing gameplay, backend,
schema, migrations, endpoints, economy, tuning, content or Reward Bridge
behavior.

- branch: `codex/draxos-mobile/refugio-visual-cleanup`;
- worktree:
  `D:\Estudio-worktrees\draxos-mobile--codex--refugio-visual-cleanup`;
- release root:
  `internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0`;
- Cloudflare production:
  `https://draxos-mobile-internal-alpha.pages.dev`;
- Cloudflare deployment evidence:
  `https://f183cd39.draxos-mobile-internal-alpha.pages.dev`;
- Portal:
  `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`;
- Web:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`;
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0/downloads/draxos-mobile-alpha.apk`;
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0/downloads/draxos-mobile-alpha.zip`;
- remote manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`.

Scope delivered:

- Refugio menu icon visible labels no longer show the sigla prefixes `AR`,
  `PP`, `RF`, `SO`, `MD`, `LJ`, `CL`, `EN`; button/node identities and actions
  remain intact.
- Top HUD removes the visible `Refugio` title, uses a shorter bar and starts the
  compact resource line with `Level <n>`.
- Center `ALTAR` / `Refugio do Mago` presentation and surrounding glow/panel
  boxes are no longer rendered.
- Persistent `RefugeLoopPanel` and `RefugeProgressionPanel` are no longer
  rendered; only the main CTA remains visible in the bottom area.
- Hidden feedback/status panel remains available for action results and errors.

Validation and publication:

- `git diff --check`: passed.
- Godot `--headless --import`: passed, with known GUT asset warnings.
- `tools/smoke_responsive_layout.gd`: passed.
- GUT client: passed, `174/174`, `3182` asserts.
- `tools/smoke_mobile_presentation.gd`: passed.
- `tools/smoke_foundation_loop.gd`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: passed.
- Android/PC/Web export passed; Android uses `debug_fallback` because release
  keystore was unavailable in this worktree.
- `publish_internal_alpha.ps1 -Mode Plan -ReleaseRoot internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0 -PublicDownloads`: passed.
- `publish_internal_alpha.ps1 -Mode Package -ReleaseRoot internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0 -PublicDownloads`: passed.
- `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0 -PublicDownloads -ConfirmRemoteMutation`: passed after linking the new worktree to Supabase project `armxgipvnbbshzqawklw`.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl <versioned-web-root>`:
  passed.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`:
  passed, deployment evidence
  `https://f183cd39.draxos-mobile-internal-alpha.pages.dev`, production URL
  `https://draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0 -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation`:
  passed.
- Preview Web HTML at
  `https://f183cd39.draxos-mobile-internal-alpha.pages.dev/web/index.html`
  returned `200` and points to the new versioned Web root; unauthenticated GET
  to the production domain returns Cloudflare Access, as expected for the stable
  gate.
- Remote `Content-Length` matched local bytes for `index.pck` (`4611176`) and
  `index.wasm` (`37695054`).
- `tools/validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly -AllowCloudflareAccess`: passed.

Visual evidence:

- Before screenshot:
  `D:\Estudio\Projetos\draxos-mobile\build\track15_mobile_ux_checkpoint\02_refugio.png`.
- After screenshot:
  `D:\Estudio-worktrees\draxos-mobile--codex--refugio-visual-cleanup\Projetos\draxos-mobile\build\track15_mobile_ux_checkpoint\02_refugio.png`.

Additional cleanup suggestions captured for a later package:

- `Modos`: translate or soften `Modes`, `Active`, `Staged`,
  `Internal Alpha`, `Power` and `Lv`.
- Base cards: replace bracket codes like `[ALM]`, `[ENE]`, `[SAN]` with cleaner
  labels or icons.
- Arena selection: hide technical difficulty IDs such as `s1_d...` behind
  friendlier labels.
- Account/update: move build/channel/manifest details into an advanced/debug
  section.
- Social: reduce visible `username`, `badge` and `Save Lab` technical language
  in the normal player flow.
- Shop: soften `Battle Pass`, `Premium` and test/alpha wording.
- Battle summary: consider merging reward/resources/progress cards on mobile if
  the screen feels too stacked.

Next human check:

- Review the published Refugio screen on Web/PC and Android package, confirm the
  CTA-only bottom area still supports the expected action feedback, then decide
  the next visual cleanup package or resume Openworld functional playtest.

## Openworld QoL Regression Fix - 2026-06-01

This hotfix supersedes the first Openworld Node2D QoL publication after human
Web feedback confirmed that border walls worked, but WASD, free joystick and
large-object collision were not good enough in the published experience.

- branch: `codex/draxos-mobile/openworld-node2d-qol`;
- worktree:
  `D:\Estudio-worktrees\draxos-mobile--codex--openworld-node2d-qol`;
- release root:
  `internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129`;
- Cloudflare production:
  `https://draxos-mobile-internal-alpha.pages.dev`;
- Cloudflare deployment evidence:
  `https://95f403c5.draxos-mobile-internal-alpha.pages.dev`;
- Portal:
  `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`;
- Web:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`;
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129/downloads/draxos-mobile-alpha.apk`;
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129/downloads/draxos-mobile-alpha.zip`;
- remote manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`.

## Internal Alpha Production Domain Pin - 2026-06-02

The Internal Alpha playtest URL is now the fixed Cloudflare Pages production
domain, not the per-deployment hash URL.

- official Portal:
  `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`;
- official Web:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`;
- latest deployment evidence:
  `https://95f403c5.draxos-mobile-internal-alpha.pages.dev`;
- Cloudflare Pages deployment list reports deployment
  `95f403c5-fde4-4522-b366-783e361dd2bb` as `Production`, branch `main`,
  source `ba6f129`;
- remote manifest was redeployed with
  `StaticSiteBaseUrl=https://draxos-mobile-internal-alpha.pages.dev`, keeping
  the Openworld QoL hotfix APK/ZIP hashes and release root unchanged;
- production CORS origin GET/OPTIONS checks pass for
  `https://draxos-mobile-internal-alpha.pages.dev`;
- unauthenticated GET to production can return Cloudflare Access instead of the
  Godot shell. That is an access gate, not a release URL rotation; validate
  content through an authenticated Access session or use the hash URL only as
  technical deployment evidence.

Fixes delivered:

- Web/PC keyboard input now uses a focusable Openworld shell, global `_input`
  routing and manual `keycode`/`physical_keycode` fallback for WASD/setas.
- Free joystick is hidden at rest, starts at arbitrary pointer/touch location
  in empty world space and resets on release.
- HUD, buttons and inventory sheet are excluded from free joystick activation.
- Chest, trees and rocks use dedicated physical blockers under
  `OpenworldObjectBlockers`, separate from visual y-sorted nodes.
- CORS now echoes the allowed request origin through `withCorsResponse` and
  accepts current/future hash previews only for the
  `draxos-mobile-internal-alpha.pages.dev` project, not a wildcard origin.
- `modes` entrypoint again delegates directly to `mode_handler.ts`; CORS
  wrapping moved inside the exported handler to satisfy strictness checks.

Publication and validation:

- Android/PC/Web export passed; Android uses `debug_fallback` because release
  keystore was unavailable in this worktree.
- `publish_internal_alpha.ps1 -Mode Plan -ReleaseRoot internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129 -PublicDownloads`: passed.
- `publish_internal_alpha.ps1 -Mode Package -ReleaseRoot internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129 -PublicDownloads`: passed.
- `publish_internal_alpha.ps1 -Mode Upload` initially stalled on the optional
  storage cleanup command after uploading most files; missing Web objects were
  uploaded with direct `supabase storage cp` to the new release root, and all
  25 package files passed public `HEAD` byte-size validation.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl <versioned-web-root>`:
  passed.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`:
  passed, deployment evidence
  `https://95f403c5.draxos-mobile-internal-alpha.pages.dev`, production URL
  `https://draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129 -StaticSiteBaseUrl https://95f403c5.draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation`:
  initially passed with hash URLs.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129 -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation`:
  passed on `2026-06-02`, repointing the remote manifest to production fixed
  Portal/Web URLs without changing APK/ZIP/Web assets.
- Supabase Edge Functions were redeployed after the CORS helper update; `modes`
  was redeployed again after the entrypoint strictness alignment.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: passed;
  Openworld GUT remains `22/22` with real key/mouse event coverage.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ModePlatform`: passed;
  includes `smoke_openworld_forest.gd` and `smoke_modes_visual_layout.gd`.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly` with
  `DRAXOS_REMOTE_CORS_ORIGIN=https://95f403c5.draxos-mobile-internal-alpha.pages.dev`:
  passed.
- Headless Chrome opened
  `https://95f403c5.draxos-mobile-internal-alpha.pages.dev/web/index.html`,
  found a `1280x720` canvas with `GODOT_CONFIG`, no page errors and no
  suspicious CORS/Supabase console logs.

Remaining human check:

- Browser automation reached the published app shell but did not complete a
  human login/guest route into Openworld. The next check is hands-on Web/PC
  playtest of WASD, mouse drag joystick, chest/tree/rock collision, borders,
  collection and deposit flow.

## Openworld Node2D QoL Foundation - 2026-06-01

This initial publication is superseded by the Openworld QoL Regression Fix
above. It prepared the existing Openworld Bosque slice for better playtest feel
without expanding gameplay, but human Web feedback found regressions in WASD,
free joystick and obstacle collision.

- branch: `codex/draxos-mobile/openworld-node2d-qol`;
- worktree:
  `D:\Estudio-worktrees\draxos-mobile--codex--openworld-node2d-qol`;
- release root:
  `internal-alpha/v0-openworld-node2d-qol-20260601-5707167`;
- Cloudflare preview:
  `https://2cca25db.draxos-mobile-internal-alpha.pages.dev`;
- Portal:
  `https://2cca25db.draxos-mobile-internal-alpha.pages.dev/portal/index.html`;
- Web:
  `https://2cca25db.draxos-mobile-internal-alpha.pages.dev/web/index.html`;
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-openworld-node2d-qol-20260601-5707167/downloads/draxos-mobile-alpha.apk`;
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-openworld-node2d-qol-20260601-5707167/downloads/draxos-mobile-alpha.zip`;
- remote manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`;
- scope: `OpenworldForestScreen` remains the `Control` shell screen, while the
  Bosque runtime now uses an internal `SubViewport`/`Node2D` world;
- controls: WASD/setas on PC/Web, free mouse/touch joystick in empty viewport
  area, and preserved debug vector for smokes;
- collision: `CharacterBody2D` player, border walls, blocking chest/tree/rock
  objects, pass-through resource areas and larger chest deposit interaction;
- visuals: procedural world preserved, with object/player depth ordering and HUD
  overlay above the world.

Boundaries preserved:

- no new enemies, combat, map, rewards, economy, backend, migration, endpoint
  or Reward Bridge change;
- publication only repoints the standard Internal Alpha release manifest to this
  package and its versioned artifacts;
- `OpenworldForestModel` remains the authority for collection, pocket, chest,
  craft and result payload.

Validation completed:

- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: passed;
- `tools/smoke_openworld_forest.gd`: passed;
- `tools/smoke_modes_visual_layout.gd`: passed.
- Android/PC/Web export passed; Android uses `debug_fallback` because release
  keystore was unavailable in this worktree.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: passed.
- `publish_internal_alpha.ps1 -Mode Plan -ReleaseRoot internal-alpha/v0-openworld-node2d-qol-20260601-5707167 -PublicDownloads`: passed.
- `publish_internal_alpha.ps1 -Mode Package -ReleaseRoot internal-alpha/v0-openworld-node2d-qol-20260601-5707167 -PublicDownloads`: passed.
- `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-openworld-node2d-qol-20260601-5707167 -PublicDownloads -ConfirmRemoteMutation`: passed.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl <versioned-web-root>`:
  passed.
- Cloudflare Pages deploy passed, preview
  `https://2cca25db.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-openworld-node2d-qol-20260601-5707167 -StaticSiteBaseUrl https://2cca25db.draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation`: passed.
- Supabase Edge Functions were redeployed after adding
  `https://2cca25db.draxos-mobile-internal-alpha.pages.dev` to the CORS
  allowlist.
- Supabase Edge Functions CORS hotfix redeployed after browser feedback:
  functions now echo the allowed request origin dynamically instead of always
  returning the first allowlisted preview origin.
- CORS GET checks passed against `healthcheck` for the current preview
  `https://2cca25db.draxos-mobile-internal-alpha.pages.dev`, the stable Pages
  origin `https://draxos-mobile-internal-alpha.pages.dev`, and the previous V2
  preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`.
- CORS preflight check passed for the stable Pages origin against
  `/functions/v1/modes/state`.
- `DRAXOS_REMOTE_CORS_ORIGIN=https://2cca25db.draxos-mobile-internal-alpha.pages.dev`
  `tools/validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly`:
  passed.
- `DRAXOS_REMOTE_CORS_ORIGIN=https://draxos-mobile-internal-alpha.pages.dev`
  `tools/validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly`:
  passed after the CORS hotfix.
- `SUPABASE_URL=https://armxgipvnbbshzqawklw.supabase.co`
  `SUPABASE_PUBLISHABLE_KEY=<project publishable key>`
  `DRAXOS_REMOTE_CORS_ORIGIN=https://draxos-mobile-internal-alpha.pages.dev`
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`
  `deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts`:
  passed read-only; auth/account/mode mutation flags were skipped.

Publication status: superseded by
`internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129`.

Next human check: playtest the published Openworld package for movement feel,
collision fairness, y-depth readability, HUD/input interference and
collection/deposit friction.

## Foundation Hardening V2 - 2026-06-01

This package is preserved as the previous remotely published Internal Alpha
multi-mode expansion enforcement baseline.

- release root:
  `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`;
- branch: `codex/draxos-mobile/foundation-hardening-v2`;
- Cloudflare preview:
  `https://ca946749.draxos-mobile-internal-alpha.pages.dev`;
- Portal:
  `https://ca946749.draxos-mobile-internal-alpha.pages.dev/portal/index.html`;
- Web:
  `https://ca946749.draxos-mobile-internal-alpha.pages.dev/web/index.html`;
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4/downloads/draxos-mobile-alpha.apk`;
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4/downloads/draxos-mobile-alpha.zip`;
- remote manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`.

Scope:

- No gameplay, content, tuning, economy, PVP, social expansion or visual
  redesign was added.
- V2 enforces strict expansion gates for future multi-mode work.
- Mode decision packs now exist for Openworld, Towerdefense and Cardgame.
- Backend Proprio boundary inventory and read-only Ops CLI are documented.
- Data/schema enforcement rejects invalid future mode definition drift.
- Android release signing remains required for broader Android distribution; the
  hotfix2 correction APK uses `debug_fallback` because the release keystore was
  unavailable in this worktree. This is accepted for the current functional
  playtest scope.
- Supabase migrations `202606010003_foundation_hardening_v2.sql` and
  `202606010004_resource_reconciliation_stability.sql` were applied remotely.
- Edge Function `modes`, Storage artifacts, Cloudflare Pages and the release
  manifest were published for the V2 release root.

Validation and publication completed:

- `tools/validate_foundation.ps1 -ProjectDir . -Profile FullLocal`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: passed.
- Android release keystore gate passed during the original V2 publish path. The
  later hotfix2 correction was exported with Android `debug_fallback` because
  the release keystore was unavailable in this worktree.
- Android/PC/Web exports passed.
- Remote migrations were applied and Edge Function `modes` was deployed.
- Storage upload passed for APK, PC ZIP and Web assets.
- Post-publication login hotfix: after manual Web entry reported
  `http_error: request failed` / Supabase unavailable, the V2 package was
  reexported with the registered Supabase publishable key, Portal/Web links were
  hardened against stale placeholders, Supabase Auth error normalization was
  corrected, and the package was republished under cache-bust release root
  `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`; CORS was
  updated for the current Cloudflare preview and the remote manifest now points
  to `https://ca946749.draxos-mobile-internal-alpha.pages.dev`.
- Hotfix validation passed: `server/functions` Deno check, `supabase/functions`
  Deno check, `DocsOnly`, `RemoteReadOnly`, and remote smoke with anonymous auth
  plus `account/guest`/`account/state`.
- Cloudflare Pages deploy passed.
- `DeployManifest` passed and deployed the `release` Edge Function.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly`: passed.

Publication status: published as the current Internal Alpha expansion
enforcement baseline; hardening complete for functional playtest.

Next human check: playtest the published V2 build. After that, mode-specific
work can run in dedicated worktrees from updated `master`.

## Hardening Platform V1 - 2026-06-01

This package is preserved as the previous published Internal Alpha multi-mode
platform baseline.

- release root:
  `internal-alpha/v0-hardening-platform-v1-20260601-19eb80d`;
- branch: `codex/draxos-mobile/hardening-platform-v1`;
- baseline merge: `scroll-drag-release-fix` integrated into `master` before
  hardening work;
- Cloudflare preview:
  `https://68452eed.draxos-mobile-internal-alpha.pages.dev`;
- stable Portal:
  `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`;
- stable Web:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`;
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-hardening-platform-v1-20260601-19eb80d/downloads/draxos-mobile-alpha.apk`;
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-hardening-platform-v1-20260601-19eb80d/downloads/draxos-mobile-alpha.zip`;
- remote manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`.

Scope:

- Multi-agent workflow and hardening templates are documented.
- Five official modes are descriptor-driven:
  `basebuilder`, `autobattler`, `openworld`, `towerdefense`, `cardgame`.
- Boot runtime and Hub presenters are split into bounded modules with validation
  budgets.
- Session store state is split into account/save, arena, modes, telemetry and
  pending mutation slices.
- `/modes` backend is modularized and mirrored between `server/functions` and
  `supabase/functions`.
- Mode admin mutations use audited RPCs and `admin_audit_log`.
- Reward Bridge V1 is documented and protected by default-deny policies.
- Validation profiles now cover docs, client, server, mode platform, local
  database, release dry-run, remote read-only and full local gates.

Validation and publication completed:

- `tools/validate_foundation.ps1 -ProjectDir . -Profile FullLocal`: passed.
- Remote migration applied:
  `202606010002_modes_admin_audit_hardening.sql`.
- Edge Function `modes` deployed to project `armxgipvnbbshzqawklw`.
- Export Android/PC/Web passed; Android uses `debug_fallback` because release
  keystore was not configured.
- Storage upload, Cloudflare Pages deploy and manifest deploy passed.
- `release_manifest_smoke.ts`, `release_artifacts_remote_smoke.ts` via
  `RemoteReadOnly`, and `internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1` passed.
- Cloudflare preview Portal/Web returned `200`.

Publication status: published as the current Internal Alpha platform baseline.

Next human check: review/playtest the published hardening build and then run
mode-specific work in dedicated worktrees from updated `master`.

## Scroll Drag Release Fix - 2026-06-01

This hotfix remains preserved as the previous client package over Minigame
Platform V1 and was integrated into `master` before Hardening Platform V1.

- release root:
  `internal-alpha/v0-scroll-drag-release-fix-20260601-c7735c5`;
- branch: `codex/draxos-mobile/scroll-drag-release-fix`;
- fix commit: `c7735c5`;
- Portal:
  `https://c4394be5.draxos-mobile-internal-alpha.pages.dev/portal/index.html`;
- Web:
  `https://c4394be5.draxos-mobile-internal-alpha.pages.dev/web/index.html`;
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-scroll-drag-release-fix-20260601-c7735c5/downloads/draxos-mobile-alpha.apk`;
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-scroll-drag-release-fix-20260601-c7735c5/downloads/draxos-mobile-alpha.zip`;
- remote manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`.

Scope:

- `DraxosTouchScrollContainer` now clears drag state on global mouse/touch
  release, including release outside the scroll container.
- Mouse motion without the left button pressed clears stale drag state, fixing
  the case where scroll could feel stuck to the cursor.
- Touch drag now tracks the active touch index, preventing unrelated touches
  from keeping a stale scroll interaction alive.
- No backend, schema, economy, mode registry or reward contract changed.

Validation and publication completed:

- `git diff --check`: passed.
- Godot headless import: passed in the fresh hotfix worktree.
- GUT client: passed (`153/153`, `2428` asserts).
- `tools/smoke_responsive_layout.gd`: passed.
- `tools/validate.gd`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile Client`: passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile Release -RequireClean`:
  passed before export/upload.
- Export/package/upload/deploy manifest completed for release root
  `internal-alpha/v0-scroll-drag-release-fix-20260601-c7735c5`.
- Cloudflare Pages deployed preview
  `https://c4394be5.draxos-mobile-internal-alpha.pages.dev`.
- Remote `release_manifest_smoke.ts`, `release_artifacts_remote_smoke.ts` and
  `internal_alpha_remote_smoke.ts` passed.

Next human check: open scroll-heavy panels in Web/PC, drag with the mouse,
release outside the panel, move the mouse without holding the button and confirm
the screen no longer keeps scrolling as if grabbed.

## Arena PVE Sequence Fix - 2026-06-01

This backend hotfix is deployed remotely to Edge Function `arena`. It addresses
a real remote reproduction where a fresh player could clear the tutorial, open
`Arena Curta Das Cinzas - Intro`, win duel 1, then lose duel 2 and remain
blocked from further Arena progression.

- branch: `codex/draxos-mobile/scroll-drag-release-fix`;
- fix commit: `f69d56c`;
- remote target: Supabase project `armxgipvnbbshzqawklw`, Edge Function
  `arena`;
- client artifact package remains
  `internal-alpha/v0-scroll-drag-release-fix-20260601-c7735c5` because no
  client/export artifact changed.

Scope:

- Added shared PVE Arena combatant tuning for server and Supabase functions.
- The first real Arena runway now uses readable pre-familiar opponents derived
  from enemy legal unlocks and the Arena target sequence.
- Enemy display names still come from the PVE enemy catalog, while source bot
  builds provide the archetype.
- First real rank-zero Arena clears are no longer reduced as tutorial repeats;
  tutorial repeats remain protected by the tutorial completion marker.
- Added regression coverage for the real sequence: post-tutorial player clears
  the first real three-duel Arena and its first-clear XP reaches the next
  difficulty unlock.

Validation completed locally:

- Real remote reproduction before patch confirmed the blocker:
  `arena_cinzas_curta:s1_d00_intro` reached duel 2, lost to the opponent, and
  `arena_veu_curta:s1_d02_iniciado` stayed locked with
  `Conclua Arena Curta Das Cinzas`.
- `npx -y deno fmt` on changed server/supabase Arena files and tests: passed.
- `npx -y deno lint` on new/changed Arena tuning tests/modules: passed.
- `npx -y deno test --allow-read server/tests/arena_pve_sequence_tuning_test.ts server/tests/arena_loop_unlock_friction_test.ts server/tests/arena_consistency_pass_schema_test.ts server/tests/battle_combatants_test.ts`:
  passed (`20` tests).
- `npx -y deno task --cwd server/functions check`: passed.
- `npx -y deno task --cwd supabase/functions check`: passed.
- `git diff --check`: passed.
- `npx -y supabase functions deploy arena --project-ref armxgipvnbbshzqawklw`:
  passed.
- Remote real-player smoke after deployment passed:
  tutorial winner `player`; `arena_cinzas_curta:s1_d00_intro` duels 1-3 winners
  `player`; `arena_cinzas_curta:s1_d01_aprendiz` unlocked.

Publication status: published as Internal Alpha backend hotfix.

## Minigame Platform V1 - Official Modes

V1 promotes the previous single-prototype minigame layer into a mode platform:

- official modes: `basebuilder`, `autobattler`, `towerdefense`, `cardgame`, `openworld`;
- player-facing names: `Basebuilder`, `Autobattler`, `Towerdefense`, `Cardgame`, `Openworld`;
- Openworld Bosque replaces the old Rpgsuave identity in client code, docs,
  tests, ruleset payloads and `/modes` contracts;
- Mode Hub is visible from the Refugio Internal Alpha surface;
- Basebuilder opens current Refugio/Base, Autobattler opens current Arena PVE,
  Openworld opens fullscreen Bosque, Towerdefense/Cardgame stay staged/disabled;
- backend V1 adds registry rows, `/modes`, `mode_limit_policies`,
  `admin_roles`, session abandon, admin/ops routes and analytics summary;
- published release root:
  `internal-alpha/v0-minigame-platform-v1-modes-20260601-c0c1e9c`;
- Portal:
  `https://d3a140a5.draxos-mobile-internal-alpha.pages.dev/portal/index.html`;
- Web:
  `https://d3a140a5.draxos-mobile-internal-alpha.pages.dev/web/index.html`;
- remote manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`.

Validation and publication completed for Minigame Platform V1:

- `tools/validate_foundation.ps1 -ProjectDir . -Profile Full -RequireClean`
  passed with Godot validation, GUT client, responsive/mobile smokes, local
  Supabase schema checks, local `/modes` live proof and Deno server tests.
- Remote migration applied `202606010000_minigame_platform_v0.sql` and
  `202606010001_modes_platform_v1.sql`.
- Edge Function `modes` deployed; legacy `minigames` function removed from the
  active remote contract.
- `release_manifest_smoke.ts`, `release_artifacts_remote_smoke.ts` and
  `internal_alpha_remote_smoke.ts` passed remotely with `/modes` enabled.
- Manual remote check confirmed `/functions/v1/minigames/registry` returns
  `404`.

## Baseline

Track 00-15 are integrated on Godot 4.6.2 + Supabase. Track 16 is the latest
technical package and has not been promoted as the current product focus. Its
live bridge document is `docs/behavior-potion-crafting-v1.md`.

The implemented base includes Android/PC/Web alpha surfaces, email/password
account flow, `normal` and `progression_lab` saves, server-authoritative battle,
Base/Social/Competition/Shop loops, Progression Lab/Battle Lab, portrait
Refugio, fullscreen portrait battle, skip, summary and current-battle logs.
Track 18 now adds the published Arena PVE-first implementation branch with
server-authoritative attempts, steps, temporary buffs, completion rewards,
client shell routes and arena-specific lab outputs.
Track 19 now aligns the same package for consistency before tuning: potions are
consumed from live stock per Arena duel, claim is read as summary/ack only, the
public buff endpoint is `/arena/pve/buff/select`, the client lists remote Arena
data, and the labs report Arena PVE sequence sanity targets.
Lab Web Export Guard is preserved as the browser safety baseline over Track 19:
Battle Lab Dev and Progression Lab Dev detect Web export before calling
`OS.execute`, disable local-process actions in the browser and keep PC/editor
Lab generation available.
Remote Lab Runner is preserved in the current alpha lineage: Web Battle Lab and
Progression Lab call Supabase Edge
`lab-runner` with the same email/password Internal Alpha account gate used by
the game, without exposing service role to the client or mutating
economy/ranking/progress.

Track 20 - Season 1 Arena Calibration is the preserved Arena calibration
package.
It promotes `pve_arena_difficulties` from data contract to operational source
for labs, generated Edge catalog, backend runtime and client difficulty
selection. The package keeps global combat, XP formula, `players.power`,
weapons, spells, passives, familiars, potions and assets untouched; Arena tuning
power remains lab/runtime metadata for PVE enemy scaling only.

Track 21 - Arena Loop Unlock And Friction Pass is the preserved Arena loop
package. It fixes the tutorial unlock blocker by updating `players.level` with
Arena completion XP in `arena_record_duel_v1`, keeps the idempotent reward path
single-apply, routes Arena start directly into the active duel screen, and keeps
post-summary continuation inside Arena selection after a read-only claim ack.
Track 21 was also published remotely before Hardening Platform V1: migration
`202605310004_arena_loop_unlock_friction.sql` was applied to Supabase, release
manifest was redeployed and Cloudflare Pages preview is
`https://2adcfa6b.draxos-mobile-internal-alpha.pages.dev`.

Current product reading: this is a strong prototype base for refinement. The
current product direction is Arena PVE initial, documented in
`docs/pve-arena-initial-direction.md`. Names, spells, weapons, economy values,
Battle Pass, battle flavor, visual identity and premium content are
mock/substance used to keep the app from feeling empty, not final design
direction unless the Arena PVE package explicitly promotes them.

Historical foundation shell loop from Foundation Loop UX Pass 01
(app-shell baseline, not the current product loop):

`Base -> collect resources -> evolve base -> battle -> receive rewards -> check base again`

Product loop now selected for the current package:

`Refugio -> Arena PVE selection -> start attempt (loadout locks) -> duel list -> temporary stat buffs and behavior prep between duels -> rewards -> continue in Arena -> upgrades`

The major foundation baseline is:

- Track 11: live docs, release state, Kanban cleanup, manual walkthrough and
  first safe `boot.gd` cut.
- Track 12 + Foundation Final Polish: `boot.gd` stays as a thin scene-facing
  shell, action/runtime flow lives behind dedicated scripts, and
  `hub_surface_presenter.gd` stays a facade under the final shell budget.
- Track 13: `tools/validate_foundation.ps1`, safe `publish_internal_alpha.ps1`
  modes, release safety checks, readiness checks and Android/Windows/Web manual
  gate.
- Track 14: agent operating manual, documentation index, status sync, safe
  commands and drift guards.
- Track 15: premium internal Android portrait UX for Entry, Refugio,
  Battle/Summary, Base and Shop without gameplay/backend/economy changes.
- Track 16: behavior, Po de Osso and potion crafting package; technical context
  and not current product focus.
- Lab Track 16 Alignment: Battle Lab and Progression Lab now model Track 16
  potion slots, potion crafting stock, `po_osso`, default potion behavior and
  spell behavior toggles as lab-only evidence before tuning.

## Track 18 - PVE Arena Initial

On `2026-05-31`, the product direction changed from PVP-first to Arena
PVE-first. Track 18 is implemented and published from
`codex/draxos-mobile/pve-arena-integration` to Internal Alpha.

- tutorial starts with 1 guided duel;
- first real arenas start with 3 duels;
- v1 data includes 3, 4, 5 and 6-duel arenas;
- longer arenas unlock later and keep scaling difficulty;
- loadout is locked before the arena;
- HP resets to 100% before every duel;
- between duels, the player chooses 1 of 3 temporary stat buffs;
- behavior can be adjusted before the next enemy;
- combat has no cooldown;
- rewards are controlled by first clears, completion, difficulty, records,
  repeat reduction, daily/weekly limits and season caps;
- PVP moves to a later competitive package, with bots only as fallback or
  simulation while playerbase grows.

Implemented and published in Track 18:

- `docs/pve-arena-v1.md` and contract docs define Arena PVE as a domain
  separate from PVP/ranking.
- `pve_arenas`, `pve_enemies`, `arena_buffs` and `arena_rewards` are registered
  in `foundation_ruleset_v0`.
- `arena_attempts`, `arena_attempt_steps` and `arena_progress` are
  server-authoritative via transactional RPCs.
- Edge Functions expose `arena/pve/state`, `arena/pve/start`,
  `arena/pve/duel/request`, `arena/pve/buff/select`, `arena/pve/claim` and
  `arena/pve/abandon`, mirrored in `server/` and `supabase/`.
- Arena PVE reward/progress mutation happens on the final
  `arena/pve/duel/request`; `arena/pve/claim` is a summary/ack endpoint and
  returns `mutates_economy: false`.
- Refugio now points the main CTA to Arena PVE, with selection, locked-loadout,
  active attempt, replay, buff choice and summary surfaces.
- Battle Lab now emits `battle_lab_arena_sequences.csv`; Progression Lab now
  emits `arena_progression_checks.csv` and models attempts/duels/clear rate
  instead of treating PVP battles as the early loop.

Validation and publication completed for Track 18:

- `git diff --check`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `npx -y deno test --allow-read --allow-write tools/battle_lab/battle_lab_test.ts`
- `npx -y deno test --allow-read --allow-write tools/progression_lab/progression_lab_test.ts`
- `npx -y deno test --allow-read server/tests/foundation_ruleset_test.ts`
- Godot `tools/validate.gd` after a one-time headless editor import: 134/134
  tests, 2310 assertions.
- `tools/validate_foundation.ps1 -Profile Full -RequireClean`: passed after
  Track 18 integration.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: passed using
  the ignored local Internal Alpha env file; Android export mode:
  `debug_fallback`.
- `tools/publish_internal_alpha.ps1 -Mode Plan`: passed.
- `tools/publish_internal_alpha.ps1 -Mode Package`: passed and produced the
  local package at `build/internal-alpha/publish`.
- `tools/publish_internal_alpha.ps1 -Mode Upload -PublicDownloads
  -ConfirmRemoteMutation`: passed for release root
  `internal-alpha/v0-pve-arena-entry-20260531-6cbc853`.
- `tools/build_cloudflare_pages_package.ps1`: passed with Web assets rooted at
  the versioned Supabase Storage path.
- `npx -y wrangler pages deploy`: passed, preview
  `https://c185369d.draxos-mobile-internal-alpha.pages.dev`.
- `tools/publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads
  -ConfirmRemoteMutation`: passed, manifest now points to the Track 18 preview.
- `server/tests/release_manifest_smoke.ts`: passed remotely.
- `server/tests/release_artifacts_remote_smoke.ts`: passed remotely for
  manifest, Portal, Web, APK and PC ZIP.
- `server/tests/internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`: passed remotely.

Published Internal Alpha artifacts:

- Portal:
  `https://c185369d.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web:
  `https://c185369d.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-pve-arena-entry-20260531-6cbc853/downloads/draxos-mobile-alpha.apk`
  (`31737628` bytes).
- PC Windows ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-pve-arena-entry-20260531-6cbc853/downloads/draxos-mobile-alpha.zip`
  (`40196236` bytes).
- Manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

Remaining after publication: run human playtest of the Arena PVE tutorial,
3-duel arena, preparation/loadout lock, buff choice, defeat/conclusion summary
and return-to-Refugio loop in Web/APK/PC.

## Track 19 - Arena Consistency Pass

Track 19 is implemented and published remotely on
`codex/draxos-mobile/arena-consistency-pass` as a consistency package over the
published Track 18 Arena PVE baseline.

Implemented in Track 19:

- Arena PVE potion use now treats the equipped potion as locked loadout intent,
  but consumes live `player_consumables` stock per duel through
  `arena_record_duel_v1` and `item_transactions` source `arena_pve_v1`.
- `arena/pve/duel/request` passes simulator consumable usage to the RPC; retry
  with the same idempotency key does not duplicate potion consumption, reward,
  step progression or ledger effects.
- `/arena/pve/claim` remains a compatibility endpoint for summary/ack and
  returns `reward_already_applied` plus `mutates_economy: false`.
- `/arena/pve/buff/select` is the public buff endpoint; `/arena/buff/choose`
  remains compatibility alias only.
- The Refugio Arena surface renders all arenas from `arena_state.arenas` with
  `arena_start:<arena_id>` actions, disabled locked entries and fixture buttons
  only as dev fallback.
- Attempt summary, preparation and active-attempt copy now distinguish locked
  loadout, editable behavior and already-applied rewards.
- `foundation_ruleset_v0` now declares
  `primary_product_mode: PVE_ARENA_INITIAL`; `FIRST_SLICE_SIM` remains a
  technical simulator/replay mode.
- Battle Lab and Progression Lab now report Arena PVE attempt/sequence language,
  potion pressure and sanity clear-rate targets for 1/3/4/5/6 duel arenas.

Validation and publication completed for Track 19:

- `tools/validate_foundation.ps1 -Profile Full -RequireClean`: passed.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: passed using
  the ignored local Internal Alpha env file; Android export mode:
  `debug_fallback`.
- `tools/publish_internal_alpha.ps1 -Mode Plan`: passed.
- `tools/publish_internal_alpha.ps1 -Mode Package`: passed and produced
  `build/internal-alpha/publish`.
- `tools/publish_internal_alpha.ps1 -Mode Upload -PublicDownloads
  -ConfirmRemoteMutation`: passed for release root
  `internal-alpha/v0-arena-consistency-pass-20260531-0865e43`.
- `tools/build_cloudflare_pages_package.ps1`: passed with Web assets rooted at
  the versioned Supabase Storage path.
- `npx -y wrangler pages deploy`: passed, preview
  `https://168dc669.draxos-mobile-internal-alpha.pages.dev`.
- `tools/publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads
  -ConfirmRemoteMutation`: passed, manifest now points to the Track 19 preview.
- `server/tests/release_manifest_smoke.ts`: passed remotely.
- `server/tests/release_artifacts_remote_smoke.ts`: passed remotely for
  manifest, Portal, Web, APK and PC ZIP.
- `server/tests/internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`: passed remotely.

Published Track 19 Internal Alpha artifacts:

- Portal:
  `https://168dc669.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web:
  `https://168dc669.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-arena-consistency-pass-20260531-0865e43/downloads/draxos-mobile-alpha.apk`
  (`31741724` bytes).
- PC Windows ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-arena-consistency-pass-20260531-0865e43/downloads/draxos-mobile-alpha.zip`
  (`40201184` bytes).
- Manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

Next after Track 19: playtest the Arena PVE tutorial and 3-duel arena, confirm
the potion and summary behavior manually, then choose the focused tuning pass.

## Track 20 - Season 1 Arena Calibration

Track 20 is implemented and published remotely on
`codex/draxos-mobile/s1-arena-calibration-integration` as the first playable
Season 1 Arena calibration package.

Implemented in Track 20:

- `pve_arena_difficulties.json` is now the source of truth for 27 Season 1
  tiers across 1/3/4/5/6 duel arenas, with `arena_id`, `difficulty_id`,
  recommended level/power, enemy sequence, final enemy power, reward profile
  and clear-rate target.
- `season_1_progression_targets.json` records the 40-level Season 1 XP curve,
  milestone windows and the rule that `arena_tuning_power_v1` does not change
  `players.power` or global `calculatePower`.
- `tools/generate_pve_arena_catalog.ts` generates mirrored runtime catalog
  helpers for `server/functions` and `supabase/functions`.
- Battle Lab now simulates full Arena PVE tier sequences from data, with HP
  reset per duel, accumulated temporary buffs and PASS/REVIEW/CRITICAL clear
  rate status by tier.
- Progression Lab now models Season 1 milestones, arena attempts, repeat
  factors, base-building pressure and potion pressure.
- Backend `arena/pve/state` and `arena/pve/start` are data-driven by
  `arena_id + difficulty_id`; completion rewards and repeat detection use
  `arena_id:difficulty_id` first-clear metadata.
- Client Arena selection renders server-provided difficulties as
  `arena_start:<arena_id>:<difficulty_id>` actions while preserving the dev
  fallback when remote Arena state is missing.

Calibration evidence:

- Battle Lab archived baseline:
  `docs/battle-lab/runs/2026-05-31_s1_arena_baseline_v01`.
- Progression Lab archived baseline:
  `docs/progression-lab/runs/2026-05-31_s1_arena_baseline_v01`.
- Tier summary: all 27 Arena S1 tiers are `PASS`; no `CRITICAL` tiers remain in
  `battle_lab_arena_tier_summary.json`.
- Progression milestones at 2h, 5h, 10h and 20h are inside target bands in
  `season_1_level_curve.csv`; remaining Progression Lab `REVIEW` items are
  non-blocking resource/model pressure notes for fine tuning.

Validation and publication completed:

- `git diff --check`: passed.
- Deno function check passed for `server/functions` and `supabase/functions`.
- Deno data/schema tests passed for Arena difficulties, generated catalog,
  foundation ruleset and Arena consistency.
- Deploy fix: the initial Arena migration now keeps `ruleset_id` as a textual
  snapshot and references immutable ruleset context through
  `ruleset_publication_id`; the remote database was repaired and then migrated
  through `202605310002` and `202605310003`.
- Deno Battle Lab and Progression Lab tests passed.
- Deno `server/tests/lab_runner_contract_test.ts`: passed after remote function
  publication.
- Godot `tools/validate.gd`: passed (`138/138`, `2368` asserts).
- GUT client: passed (`138/138`, `2368` asserts).
- `tools/smoke_responsive_layout.gd`: passed.
- `tools/validate_foundation.ps1 -Profile Quick`: passed.
- `tools/validate_foundation.ps1 -Profile Full -RequireClean`: passed before
  publication.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: passed using
  the ignored local Internal Alpha env file; Android export mode:
  `debug_fallback`.
- `tools/publish_internal_alpha.ps1 -Mode Plan`: passed.
- `tools/publish_internal_alpha.ps1 -Mode Package`: passed and produced the
  local package at `build/internal-alpha/publish`.
- `supabase db push --linked --yes`: passed after remote Arena table repair.
- `supabase functions deploy arena`: passed.
- `supabase functions deploy lab-runner`: passed.
- `tools/publish_internal_alpha.ps1 -Mode Upload -PublicDownloads
  -ConfirmRemoteMutation`: passed for release root
  `internal-alpha/v0-s1-arena-calibration-20260531-c40c2a6`.
- `tools/build_cloudflare_pages_package.ps1`: passed with Web assets rooted at
  the versioned Supabase Storage path.
- `npx -y wrangler pages deploy`: passed, preview
  `https://c20c0ff3.draxos-mobile-internal-alpha.pages.dev`.
- `tools/publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads
  -ConfirmRemoteMutation`: passed; the manifest points at the stable protected
  Cloudflare Pages domain.
- `server/tests/release_manifest_smoke.ts`: passed remotely.
- `server/tests/release_artifacts_remote_smoke.ts`: passed remotely; Portal and
  Web are correctly protected by Cloudflare Access.
- `server/tests/internal_alpha_remote_smoke.ts`: passed remotely.

Published Track 20 Internal Alpha artifacts:

- Portal:
  `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Preview:
  `https://c20c0ff3.draxos-mobile-internal-alpha.pages.dev`
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-s1-arena-calibration-20260531-c40c2a6/downloads/draxos-mobile-alpha.apk`
  (`31762404` bytes),
  SHA256 `6c84aea08f9731d6449c9aca8186695020161a4fd688f0f0a59c24a952b1286d`.
- PC Windows ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-s1-arena-calibration-20260531-c40c2a6/downloads/draxos-mobile-alpha.zip`
  (`40221978` bytes),
  SHA256 `aab5adad9064f869b01ffe92c8d7244a0ec36be7253839d09ef1765364050992`.
- Web Index: `5442` bytes,
  SHA256 `63bfb9aa4f79882413ff0b462f6420630cfedcdca825ba41b44ff51d65f6caff`.
- Manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

Next after Track 20: run a human playtest focused on tutorial, multiple
difficulties of the 3-duel arena, locked loadout, buff choice, potion
consumption, summary ack, repeat rewards and Web Battle/Progression Labs before
tuning numbers finer.

## Track 21 - Arena Loop Unlock And Friction Pass

Track 21 is implemented and published remotely on `2026-05-31` as a hotfix over
Track 20 after the first playtest found that tutorial completion did not unlock
the next Arena tier.

Implemented in Track 21:

- Added mirrored migration `202605310004_arena_loop_unlock_friction.sql` with
  `foundation_level_for_xp_v1` and an updated `arena_record_duel_v1`.
- Arena completion rewards now update `players.xp` and `players.level` in the
  same transaction, preserving idempotency for repeated
  `request_id/request_hash`.
- The tutorial first-clear XP now reaches level 3 and
  `arena_cinzas_curta:s1_d00_intro` unlocks in the next `arena/pve/state`.
- Arena start now routes directly to `ROUTE_ARENA_ACTIVE`; the loadout lock is
  informational instead of a required confirmation step.
- Completed-attempt summary now says `Continuar na Arena`, calls claim only as
  a compatibility ack/read-only summary, refreshes remote Arena state and
  returns to Arena selection.
- Arena selection highlights the next recommended unlocked tier before the full
  server-driven list.

Validation and publication completed:

- `git diff --check`: passed.
- Focused Deno tests for Arena loop unlock, catalog, difficulties and schema:
  passed.
- `npx -y deno task --cwd server/functions check`: passed.
- `npx -y deno task --cwd supabase/functions check`: passed.
- Godot `validate.gd`: passed, 140 tests / 2376 asserts.
- `smoke_responsive_layout.gd`: passed.
- `smoke_exports.gd`: passed.
- `validate_foundation.ps1 -Profile Quick`: passed.
- `export_internal_alpha.ps1`: passed with Android `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan`: passed.
- `publish_internal_alpha.ps1 -Mode Package`: passed.
- `supabase db push --linked --yes`: passed, applying
  `202605310004_arena_loop_unlock_friction.sql`.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`: passed.
- `build_cloudflare_pages_package.ps1`: passed with Web assets rooted at the
  versioned Supabase Storage path.
- `npx -y wrangler pages deploy`: passed, preview
  `https://2adcfa6b.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`:
  passed; the manifest points at the stable protected Cloudflare Pages domain.
- `server/tests/release_manifest_smoke.ts`: passed remotely.
- `server/tests/release_artifacts_remote_smoke.ts`: passed remotely; Portal and
  Web are correctly protected by Cloudflare Access.
- `server/tests/internal_alpha_remote_smoke.ts`: passed remotely.

Published Track 21 Internal Alpha artifacts:

- Portal:
  `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Preview:
  `https://2adcfa6b.draxos-mobile-internal-alpha.pages.dev`
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-track21-arena-loop-20260531-df9f12d/downloads/draxos-mobile-alpha.apk`
  (`31762404` bytes),
  SHA256 `515bb254c3b2e3825f6951a828e424c361fadb7ef696688bbff16b0c63044a05`.
- PC Windows ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-track21-arena-loop-20260531-df9f12d/downloads/draxos-mobile-alpha.zip`
  (`40223926` bytes),
  SHA256 `4c78b6e51b18183d5e3bfcea938663715876043e711790a982e160aa0c321f86`.
- Web Index: `5442` bytes,
  SHA256 `9ac3699ee5514844b7886a7f2cad9f3307335f82fb82409bc5469c8420aa27f2`.
- Manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

Next after Track 21: test a new save through tutorial clear, Arena return,
first 3-duel unlock and starting the next Arena without the redundant loadout
confirmation.

## Lab Web Export Guard Hotfix

Lab Web Export Guard is implemented and published remotely on
`codex/draxos-mobile/lab-web-export-guard` as a client hotfix over Track 19.

Implemented in the hotfix:

- Battle Lab Dev and Progression Lab Dev detect Web export before calling
  `OS.execute`.
- Buttons that require local `npx/deno` are disabled in the browser and expose
  a clear message to use PC/editor for local generation.
- PC/editor Lab generation remains unchanged.
- Tests simulate process-unavailable mode so the Web guard stays protected.

Validation and publication completed:

- `git diff --check`
- GUT client: `138/138`, `2364` asserts.
- `tools/smoke_dev_lab_ui.gd`: passed.
- `tools/validate.gd`: passed.
- `tools/smoke_responsive_layout.gd`: passed.
- `tools/smoke_exports.gd`: passed.
- `tools/validate_foundation.ps1 -Profile Client`: passed.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: passed using
  the ignored local Internal Alpha env file; Android export mode:
  `debug_fallback`.
- `tools/publish_internal_alpha.ps1 -Mode Plan`: passed.
- `tools/publish_internal_alpha.ps1 -Mode Package`: passed.
- `tools/publish_internal_alpha.ps1 -Mode Upload -PublicDownloads
  -ConfirmRemoteMutation`: passed for release root
  `internal-alpha/v0-lab-web-export-guard-20260531-9a415c3`.
- `tools/build_cloudflare_pages_package.ps1`: passed with Web assets rooted at
  the versioned Supabase Storage path.
- `npx -y wrangler pages deploy`: passed, preview
  `https://fc60138d.draxos-mobile-internal-alpha.pages.dev`.
- `tools/publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads
  -ConfirmRemoteMutation`: passed, manifest now points to the hotfix preview.
- `server/tests/release_manifest_smoke.ts`: passed remotely.
- `server/tests/release_artifacts_remote_smoke.ts`: passed remotely for
  manifest, Portal, Web, APK and PC ZIP.
- `server/tests/internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`: passed remotely.

Published hotfix Internal Alpha artifacts:

- Portal:
  `https://fc60138d.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web:
  `https://fc60138d.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-lab-web-export-guard-20260531-9a415c3/downloads/draxos-mobile-alpha.apk`
  (`31741724` bytes,
  `b23b88839f57fee70fd161d412ef78d6ea2a23300e01f0a731f36db6ab0749de`).
- PC Windows ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-lab-web-export-guard-20260531-9a415c3/downloads/draxos-mobile-alpha.zip`
  (`40202687` bytes,
  `1c937191561f0f1a39df0c4234eb183faf4be553afa057f9a6fd8613fbaf2e23`).
- Manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

Next after hotfix: playtest the Arena PVE tutorial and 3-duel arena, confirm
that Battle Lab Dev no longer tries to start `npx/deno` in Web export, then
choose the focused tuning pass.

## Remote Lab Runner

Remote Lab Runner is implemented and published remotely on
`codex/draxos-mobile/remote-lab-runner` as the current Internal Alpha package
over Lab Web Export Guard.

Implemented in this package:

- New mirrored Edge Function `lab-runner` exposes `POST /lab-runner/battle` and
  `POST /lab-runner/progression`.
- Access uses the same Internal Alpha Supabase account gate as the game: JWT
  from a non-anonymous email/password account with a registered `normal` save. No
  separate Lab allowlist exists.
- Service role is used only inside the Edge Function to verify alpha access.
  The client/export never receives service role or secrets.
- Battle Lab Web can generate remote scratch runs and custom replay samples in
  memory when local `npx/deno` is unavailable.
- Progression Lab Web can generate the report data in memory when local
  `npx/deno` is unavailable.
- Remote runner does not write `docs/**`, `.battle_lab_scratch/**` or
  `.progression_lab_scratch/**`, does not archive official runs and does not
  mutate reward, XP, resources, ranking, potion stock, saves or ledger.

Validation and publication completed:

- `npx -y deno check server/functions/lab-runner/index.ts`
- `npx -y deno check supabase/functions/lab-runner/index.ts`
- `npx -y deno check server/functions/lab-runner/index.ts server/tests/lab_runner_contract_test.ts`
- `npx -y deno check supabase/functions/lab-runner/index.ts`
- `npx -y deno test --allow-read server/tests/lab_runner_contract_test.ts`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `npx -y deno test --allow-read server/tests/lab_heuristics_contract_test.ts server/tests/lab_runner_contract_test.ts`
- `tools/check_agent_ops_foundation.ps1`: PASS.
- `tools/validate_foundation.ps1 -Profile Quick`: PASS.
- Godot `tools/validate.gd`: PASS (`138/138`, `2364` asserts).
- `supabase functions deploy lab-runner`: PASS.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS using the
  ignored local Internal Alpha env file; Android export mode: `debug_fallback`.
- `tools/publish_internal_alpha.ps1 -Mode Plan`: PASS.
- `tools/publish_internal_alpha.ps1 -Mode Package`: PASS.
- Supabase Storage upload: PASS for release root
  `internal-alpha/v0-remote-lab-runner-20260531-e659d7e5`.
- `tools/build_cloudflare_pages_package.ps1`: PASS with Web assets rooted at
  the versioned Supabase Storage path.
- `npx -y wrangler pages deploy`: PASS, preview
  `https://9ae1e953.draxos-mobile-internal-alpha.pages.dev`.
- `tools/publish_internal_alpha.ps1 -Mode DeployManifest`: BLOCKED because
  `SUPABASE_ACCESS_TOKEN` is not available in the local release environment.
  The release manifest was updated instead by deploying the `release` Edge
  Function with a newer code default manifest; remote manifest smokes passed.
- `server/tests/release_manifest_smoke.ts`: PASS remotely.
- `server/tests/release_artifacts_remote_smoke.ts`: PASS remotely for manifest,
  Portal, Web, APK and PC ZIP.
- `server/tests/internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS remotely.

Published Remote Lab Runner Internal Alpha artifacts:

- Portal:
  `https://9ae1e953.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web:
  `https://9ae1e953.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-remote-lab-runner-20260531-e659d7e5/downloads/draxos-mobile-alpha.apk`
  (`31745820` bytes,
  `b013182633fbd5ef568344d3f551490d993dc9eb0edb77a89e46d0e4f028faf4`).
- PC Windows ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-remote-lab-runner-20260531-e659d7e5/downloads/draxos-mobile-alpha.zip`
  (`40206417` bytes,
  `292f92916d30420dc8bb1cf49ac2e5d3375bd43548fb25ad8cb7e47b676c1495`).
- Manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

## Foundation Audit

Foundation Expansion Readiness/Foundation Closeout is the delivered foundation
gate. Foundation Audit aligned
documents, audited the internal post-login loop and produced the current
published baseline before implementation expands.

Documentation alignment is complete, and the first loop audit is recorded in
`docs/foundation-loop-audit.md`. The audit conclusion was: the foundation exists
technically, but the V0 UX needed a focused pass so the player always
understands the next post-login action.

Foundation Loop UX Pass 01 is implemented and published to the Internal Alpha
artifact/site channel from branch `codex/draxos-mobile/foundation-loop-ux-pass`.
It makes Refugio the operational loop home, adds a visible loop panel, separates
unseen battle rewards from old battle history, removes confirmation from routine
collection, changes the battle summary return to `Voltar e verificar base`,
marks battle results as seen on return, and adds the no-network smoke
`tools/smoke_foundation_loop.gd`.

Foundation Responsive Guardrails were applied and published on `2026-05-28`
after manual review found the published Web/APK layout clipping Entry tools,
Refugio and Battle. The hotfix restores Entry Labs in Internal Alpha, moves
Refugio/Battle immersive UI into safe frames, and adds
`docs/foundation-responsive-layout-contract.md` plus
`tools/smoke_responsive_layout.gd`. The publication used public unlisted APK/PC
Storage URLs so mobile downloads do not hit the protected Bearer-token endpoint.

Follow-up refuge/battle hotfixes were published on `2026-05-28` from branch
`codex/draxos-mobile/foundation-responsive-guardrails`. They keep Refugio as the
post-login session root, keep Labs Dev visible from Refugio, redirect accidental
login returns back to Refugio during an active session, and replace the
battle-request replay preview with a static battle splash while the real battle
opens.

Entry Dev Labs export hotfix was published on `2026-05-28` after manual review
showed the published menu still hid Battle Lab and Progression Lab. The root
cause was `export_presets.cfg` excluding `dev/**`, so exported builds could not
satisfy `ResourceLoader.exists()` for the lab overlays. Internal Alpha exports
now package `res://dev/battle_lab/battle_lab_screen.gd` and
`res://dev/progression_lab/progression_lab_screen.gd`, and
`tools/smoke_exports.gd` prevents this regression.

Manual Android/Windows/Web review passed on `2026-05-29`. The review confirmed
Battle Lab and Progression Lab in the initial menu, Refugio/Battle contained in
screen bounds, APK download without Bearer-token error, static splash while
requesting battle and a clear post-login loop. Foundation Loop UX Pass 01 is
therefore the accepted historical app-shell baseline; the current product loop
is Arena PVE.

Priority order after baseline confirmation:

1. Arena PVE initial product/tuning package.
2. Integrated leveling/upgrades/rewards/power calibration.
3. Base/preparation support for Arena PVE.
4. PVP posterior, with controlled bot fallback.
5. Social/competition after the PVE/PVP routine is clear.

Internal loop ergonomics, Social Basico Guilda v1, Visual Direction v1, Ossos
Inteiros v1, Battle Presentation v1, Battle Drama v1.1, Battle Preparation v1,
Battle Preparation Complete v1, Progression Clarity v1 and First Session Clarity
v1 have received explicit packages and are published to Internal Alpha. No new
code, schema, backend, asset, gameplay or balance work belongs outside an
explicit next package decision.

## First Session Clarity v1

First Session Clarity v1 is implemented, published and manually approved as the
current client-only first-session guidance package. It does not change backend,
schema, migrations, simulator, rewards, economy, tuning, weapons, spells,
potions, behavior or catalog content.

- Refugio now shows a persistent first-session hint inside the `Progresso`
  panel.
- The contextual Refugio CTA now explains reward, collection, base evolution and
  battle as one cycle.
- Preparation now gives a short first-session reading cue before loadout
  details.
- Battle summary now includes `Proximo passo`, connecting rewards back to
  collection, base evolution and the next battle.
- `tools/smoke_foundation_loop.gd` protects reward, collection, upgrade and
  summary guidance.
- `portal/internal-alpha/index.html` now uses `DraxosMobile Alpha`, matching the
  remote release smoke contract.
- Validation completed on `2026-05-30`: one-time Godot import in the fresh
  worktree, `git diff --check`, `tools/smoke_foundation_loop.gd`, GUT client
  (`123/123`, `1990` asserts), `tools/smoke_responsive_layout.gd`,
  `validate_foundation.ps1 -Profile Client`, publication checks and
  `server/tests/release_artifacts_remote_smoke.ts` passed.
- First Session Clarity v1 was published to Internal Alpha on `2026-05-30` with
  release root `internal-alpha/v0-first-session-clarity-v1-20260530`, public Web
  preview
  `https://f2ead4bd.draxos-mobile-internal-alpha.pages.dev/web/index.html`,
  public APK
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-first-session-clarity-v1-20260530/downloads/draxos-mobile-alpha.apk`
  and public PC ZIP
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-first-session-clarity-v1-20260530/downloads/draxos-mobile-alpha.zip`.
- Manual review on `2026-05-30` approved the package as clearer. The project
  remains active in P2; do not open an initial-loop motivation package by
  default.

Recommended next package: Arena PVE initial. Lab evidence is now aligned with
Track 16, but it still must be extended to arena sequences before promoting
numeric tuning.

## Foundation Expansion Readiness

Foundation Expansion Readiness is the delivered pre-expansion package. It
prepares DraxosMobile for production future, parallel agent work and larger
feature lanes without changing the published player-facing UX.

Delivered in the current branch:

- `docs/foundation-expansion-readiness.md` defines the multiagent lane matrix
  and contract-first gate.
- `docs/contracts/account-save.md` makes `account_profiles` + `game_saves` the
  account/save authority, with `players.save_type` as compatibility only.
- `docs/contracts/ruleset-registry.md` records the approved third path:
  repo-generated ruleset as authorship source and database registry as
  publication record.
- `docs/contracts/minigame-integration.md` blocks real minigames until entry,
  data, cost, reward, telemetry, admin and rollback are explicit.
- `docs/contracts/admin-ops.md` defines minimum auditable admin/support
  operations.
- `docs/contracts/lab-heuristics.md` fences Progression Lab and Battle Lab as
  lab-only diagnostic/authoring tools, records current model IDs and blocks
  tuning promotion without explicit package/ruleset validation.
- Migration `202605300001_foundation_expansion_readiness.sql` adds
  `account_profiles`, `game_saves`, `ruleset_registry`, `admin_audit_log`,
  idempotency v1 fields and ruleset metadata columns.
- Migration `202605300002_transactional_domain_enforcement.sql` promotes Base
  collect/upgrade to real v1 transactional RPCs with `game_saves`,
  `request_hash`, ruleset metadata, resource ledger and service-role-only
  grants.
- Migration `202605300003_remaining_transactional_domain_enforcement.sql`
  promotes `battle/request` (`FIRST_SLICE_SIM`, technical simulator/replay mode
  rather than current product mode), rewards claim, alpha purchase, build equip,
  crafting craft/crush-bones and guild create/join to v1 transactional RPCs
  with `game_saves`, `request_hash`, ruleset metadata, ledger/idempotency and
  service-role-only grants.
- Migration `202605300004_foundation_closeout.sql` corrects
  `ruleset_registry` to immutable `publication_id`, updates the active
  `foundation_ruleset_v0` simulator hash, persists ruleset hashes in
  `game_saves` and history rows, adds `state_version`/`season_context`, creates
  internal admin RPCs and promotes build spell behavior, potion equip/behavior,
  friend add and chat send to v1 transactional/idempotent RPCs.
- Edge Functions now enforce `x-draxos-api-version: 1` when the header is
  present, still tolerate absence during alpha, and reject other explicit
  values with `UNSUPPORTED_API_VERSION`.
- `foundation_ruleset_v0` is generated with content/simulator hashes and
  mirrored into server/supabase shared modules.
- `battle/request`, `battle/latest`, `battle/history` and `battle/replay` expose
  ruleset metadata for new battles/log reads, using row-persisted hashes for
  new rows and `FOUNDATION_RULESET` fallback only for old rows.
- `base/state`, `base/collect` and `base/upgrade` now use the Base transactional
  RPC path while preserving the current UI payload contract.
- `battle`, `build`, `crafting`, `monetization` and `social` adapters now
  compute canonical `request_hash`, resolve `game_saves` and call domain RPCs
  while preserving the current client payload shape where the UI depends on it.
- `server/tests/transactional_rpc_live_test.ts` now proves
  rollback/retry/idempotency against a reset local Supabase Postgres stack for
  battle rewards, build equip, crafting, reward claim, alpha purchase and guild
  create/join.
- `server/tests/transactional_edge_rpc_smoke.ts` now proves the local Edge
  Function HTTP path over the v1 RPC adapters for base, battle, build, crafting,
  monetization and social, including the Closeout endpoints
  `build/spell-behavior`, `build/potion/equip`, `build/potion-behavior`,
  `social/friends/add`, `social/chat/send` and API version failure.
- `server/functions/_shared/base_domain.ts`,
  `server/functions/_shared/battle_log_projection.ts`,
  `server/functions/_shared/battle_combatants.ts`,
  `server/functions/_shared/progression_domain.ts` and
  `server/functions/_shared/economy_domain.ts` continue the portable
  domain-service split with mirrored Supabase modules and Deno contract tests
  for Base rules/projection, saved battle log projection, battle player/bot
  combatant mapping, build payload/unlocks/equip validation, runtime power,
  battle helper projection, rewards/products and crafting/monetization
  source-sink payloads.
- Battle Lab Godot power display now matches the Battle Lab TypeScript runner
  weights, and `server/tests/lab_heuristics_contract_test.ts` guards Lab model
  IDs, Battle Lab power weights, Progression Lab profile/milestone selectors and
  ruleset model hashing. The same test now also keeps Lab generators
  offline/adapter-free, keeps the Progression Lab seeder local-only and blocks
  server runtime imports from dev Lab generators/screens.
- `DraxosOperationState` and `DraxosAppShellActionRouter` create client shell
  contracts without adding feature rules to `boot.gd`; the real action path now
  routes through the action router and busy/error state is scoped by operation.
- `SupabaseClient` sends API version and `request_hash`, while `SessionStore`
  persists pending idempotent mutations so retries reuse the same
  `request_id/request_hash`.
- V1 replaces the previous minigame placeholder with active mode contracts:
  `ROUTE_MODE_HUB`, `ROUTE_MODE_SHELL` and `open_mode_shell:<mode_id>`.
  `/modes` is the active API surface; `/minigames` is historical only.
- `tools/check_foundation_expansion_readiness.ps1` is the read-only structural
  gate and is called from `validate_foundation.ps1`. Full profile now requires
  local Supabase RPC, Edge RPC and admin/RLS smokes instead of silently skipping
  them.

This package does not implement a new gameplay feature, new social loop or new
minigame. Remaining balance/content expansion should now start only after an
explicit package choice, with Lab heuristics treated as evidence instead of
runtime authority.

## Foundation Final Polish

Foundation Final Polish is the last hardening pass before tuning. It does not
add gameplay, economy, social expansion or minigame rewards. It was published
to Internal Alpha after explicit release approval on `2026-05-30`.

- Live docs now identify Foundation Closeout and Lab Track 16 Alignment as
  delivered; the final Full validation passed on the canonical local branch.
- New agents should branch locally from `codex/draxos-mobile/foundation-final-polish`
  at the final validated HEAD until a merge/push decision exists.
- `modes/boot/boot.gd` is a thin shell facade and
  `modes/boot/surfaces/hub_surface_presenter.gd` is a facade under automated
  line budgets in `validate_foundation.ps1`.
- `SessionStore` exposes read-only domain slices/snapshots, and touched
  presenters read those snapshots instead of public mutable dictionaries.
- Client source guards now block presenter calls to Supabase, direct telemetry,
  direct `SessionStore` mutations and direct `create_request_id()` outside the
  approved shell paths.
- `server/tests/foundation_admin_rls_live_smoke.ts` proves local RLS/admin:
  `anon/authenticated` cannot execute admin RPCs, `service_role` can lookup,
  reconcile, diagnose, adjust resources with ledger/audit/idempotency and flag
  accounts, and `admin_audit_log` is not client-readable.
- `validate_foundation.ps1 -Profile Full` includes local Supabase RPC, local
  Edge RPC and local admin/RLS smokes; if the local stack is not active, Full
  fails instead of skipping silently.
- Internal Alpha publication used release root
  `internal-alpha/v0-foundation-final-polish-20260530-8c658f6`, public
  Cloudflare preview
  `https://721dc985.draxos-mobile-internal-alpha.pages.dev/web/index.html`,
  public APK
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-final-polish-20260530-8c658f6/downloads/draxos-mobile-alpha.apk`
  and public PC ZIP
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-final-polish-20260530-8c658f6/downloads/draxos-mobile-alpha.zip`.
- Publication validation passed: `validate_foundation.ps1 -Profile Release`,
  export Android/PC/Web, `publish_internal_alpha.ps1 -Mode Plan`, `Package`,
  `Upload -ConfirmRemoteMutation`, Cloudflare Pages deploy, `DeployManifest
  -ConfirmRemoteMutation`, `release_manifest_smoke.ts`,
  `release_artifacts_remote_smoke.ts`, `internal_alpha_remote_smoke.ts` with
  release manifest check, and a direct preview shell check confirming
  `GODOT_CONFIG`, versioned Web asset root and `index.pck` size match.
- Known release risk: Android was exported with `debug_fallback` because no
  release keystore was configured in the local env used for publication.

## Debug Clean Web Config

Debug Clean Web Config is a post-publication hardening pass over Foundation
Final Polish. It does not add gameplay, tuning, schema changes, economy changes
or new UX. It addresses debug-console noise and the manual Web login failure
reported after publication.

- Root cause for the Web login failure: the published Edge Functions still
  answered browser CORS preflight without `x-draxos-api-version`, while the
  Foundation Final Polish Web client correctly sent that API v1 header. The
  browser blocked the request before it reached `account/guest`, and the client
  surfaced the older generic "Supabase local unavailable" message.
- Remote Edge Functions were redeployed for the Internal Alpha Supabase project
  so the current published Web app can pass preflight with
  `x-draxos-api-version: 1`.
- `server/tests/internal_alpha_remote_smoke.ts` now performs non-mutating
  browser preflight checks against auth and the major Edge Function adapters,
  preventing a stale remote CORS deploy from looking like a local Supabase
  outage again.
- Client network error copy now distinguishes local Supabase outages from
  remote/browser-blocked connection failures.
- Debug cleanup removed invalid GUT font UID warnings, JSON parse noise from
  corrupt session cache reads, unused-variable/parameter warnings, test
  telemetry HTTP noise and detailed GUT orphan spam.
- Main app debug pass is clean: no `WARNING`, `ERROR`, `SCRIPT ERROR`,
  `ObjectDB`, leaked instance or HTTP noise in
  `build/debug/godot_main_debug_clean_latest.log`.
- Godot validation/GUT still reports a final engine-level
  `GDScriptFunctionState` leak warning under `--debug` at process shutdown;
  verbose output shows coroutine states from the async GUT runner, not live UI
  nodes. Tests pass and the main app debug run is clean.

Closeout validation on this branch:

- Deno check: `server/functions` PASS and `supabase/functions` PASS.
- Static foundation contract tests: PASS (`57` tests through
  `validate_foundation.ps1 -Profile Quick` before local Supabase/Edge gated
  steps).
- Godot validate: PASS (`132/132`, `2052` asserts) after the client shell retry
  changes.
- `supabase migration up --local`: PASS for
  `202605300004_foundation_closeout.sql`.
- `validate_foundation.ps1 -Profile Full`: PASS with local Supabase RPC and
  local Edge RPC smokes included.

Lab Track 16 Alignment validation on this branch:

- Battle Lab model/generator now emits Track 16 potion-enabled,
  potion-disabled and spell-behavior-disabled scenarios. The generated report is
  `REVIEW` because anti-stall rate is `6.4%` against the current lab threshold
  of `<=5%`; this is tuning evidence, not an automatic balance change.
- Progression Lab model/generator now emits healthy saves with `po_osso`,
  `craft_pocao_vida`, `pocao_vida`, potion slot state, inventory and spell
  behaviors, plus potion affordability, crafting pressure and preparation
  readiness artifacts.
- Progression Lab apply/seeding now preserves generated consumable, potion slot
  and spell behavior state for lab snapshots instead of wiping Track 16 state.
- Validation: `npx -y deno test tools/battle_lab tools/progression_lab` PASS,
  `npx -y deno test --allow-read server/tests/lab_heuristics_contract_test.ts`
  PASS, Deno check for `server/functions` and `supabase/functions` PASS, GUT
  client PASS (`132/132`, `2057` asserts), `tools/smoke_dev_labs.gd` PASS and
  `validate_foundation.ps1 -Profile Quick` PASS. The Quick gate caught and then
  confirmed the corrected `foundation_ruleset_v0` content hash mirrored in the
  Closeout migration seed.

Historical handoff: Foundation Final Polish unlocked the Arena PVE initial
package. That recommendation is now superseded by Track 18 being published;
use the Track 18 section and Next Step above for current work. Do not start
unrelated base builder, PVP, social or minigame work implicitly from the
Foundation Final Polish branch.

## Web Auth Foundation Context Hotfix

Web Auth Foundation Context Hotfix is a post-publication auth/foundation repair
over Debug Clean Web Config. It does not add gameplay, tuning, schema design,
economy changes or new UX.

- Reported failures on the published Web app: guest entry could return
  `Essa rota e apenas para guest dev`, and email/password entry could return
  `FOUNDATION_CONTEXT_NOT_FOUND: Account/save foundation context was not created
  yet`.
- Root cause for `FOUNDATION_CONTEXT_NOT_FOUND`: the Internal Alpha remote
  database was still missing the Foundation Expansion/Closeout migrations
  `202605300001` through `202605300004`. `supabase db push --linked` applied the
  missing migrations, and `supabase migration list --linked` confirmed local and
  remote are aligned through `202605300004_foundation_closeout.sql`.
- Root cause for the guest error: the client guest path reused a cached
  registered email session token in Web storage, so the backend correctly
  rejected the request because `account/guest` is anonymous-only. The client
  now clears registered-session state and signs in anonymously before calling
  the guest bootstrap.
- Remote account smoke after the migration repair passed for anonymous auth,
  account state, email auth, release manifest, progression lab bootstrap and a
  battle request against `https://armxgipvnbbshzqawklw.supabase.co`.
- Client validation passed with `validate_foundation.ps1 -Profile Client`,
  including GUT `tests/client` (`134/134`, `2274` asserts),
  `tools/validate.gd`, runtime config, foundation hardening, responsive layout,
  export smoke and `git diff --check`.
- The hotfix was exported and uploaded to Supabase Storage at release root
  `internal-alpha/v0-web-auth-foundation-context-20260530`; remote HEAD checks
  passed for Web `index.html`, `index.pck` (`4293280` bytes), `index.wasm`,
  APK and PC ZIP.
- Cloudflare Pages deploy for the new Web shell is blocked in the current local
  environment by Wrangler authentication error `10000`. Until Wrangler is
  reauthenticated and the Pages package is deployed, the live Cloudflare Web
  shell still serves the previous client; email/password is repaired by the
  remote migration fix, while the cached-email-to-guest client fix requires the
  new Web shell or a cleared browser site session.

## Progression Clarity v1

Progression Clarity v1 is implemented and published as a client-only readability
layer over the existing account/build/battle snapshots. It does not change
backend, schema, migrations, simulator, rewards, economy, tuning, weapons,
spells or catalog content.

- Refugio now has a compact `Progresso` panel in the immersive home layout with
  level, power and the next visible milestone.
- Preparation now shows `Proximos marcos`, derived from current build state,
  lock reasons and known unlock levels.
- Battle summary now includes `Progresso`, showing current level/power, battle
  XP when present and the next milestone without claiming resource balances were
  refreshed.
- `modes/boot/surfaces/progression_clarity_presenter.gd` centralizes
  player-facing progression copy.
- `docs/progression-clarity-v1.md` is the live package note.
- Validation completed on `2026-05-29`: GUT client passed with `123/123` tests
  and `1984` asserts; `tools/smoke_foundation_loop.gd`,
  `tools/smoke_responsive_layout.gd`, `validate_foundation.ps1 -Profile Client`
  and `git diff --check` passed. `tools/smoke_foundation_surfaces.gd` remained
  blocked locally because Supabase local was unavailable.
- Progression Clarity v1 was published to Internal Alpha on `2026-05-29` with
  release root `internal-alpha/v0-progression-clarity-v1-20260529`, public
  Cloudflare Pages preview
  `https://3cf22c65.draxos-mobile-internal-alpha.pages.dev/web`, public APK
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-progression-clarity-v1-20260529/downloads/draxos-mobile-alpha.apk`
  and public PC ZIP
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-progression-clarity-v1-20260529/downloads/draxos-mobile-alpha.zip`.

## Battle Preparation Complete v1

Battle Preparation Complete v1 is implemented and published as the current
loadout package for the Refugio preparation hotspot. It promotes the previous
explanatory panel into a real pre-battle editor while keeping simulator, tuning,
economy, new content, migrations and advanced tactics out of scope.

- Refugio keeps the existing `Preparacao` hotspot and no new route was added.
- The Preparation panel now opens with `Pronto para batalha` and summarizes
  power, ritual instrument, equipped skills, doctrine, familiar, potion and
  simple behavior presets.
- The player can equip an instrument, equip/remove skills in positions 1/2/3,
  equip/remove doctrine, equip/remove familiar and keep potion/behavior controls
  from Track 16.
- The server implements `POST /build/equip`, validates catalog ids, unlock
  levels and duplicate skills, updates `builds` and recalculates
  `players.power`; the client never sends final power.
- `GET /build/state` returns enriched humanized equipment options and lock
  reasons so the UI does not need to show raw ids.
- Export presets now exclude `assets/referenciaimagens/**`, which is
  moodboard/reference only, reducing published APK/ZIP/PCK sizes enough for the
  current Storage/Pages flow.
- `docs/battle-preparation-complete-v1.md` is the live package note;
  `docs/battle-preparation-v1.md` is historical context.
- Battle Preparation Complete v1 was published to Internal Alpha on `2026-05-29`
  with public unlisted APK/PC downloads, a cache-busted Web asset root and
  verified public Cloudflare Pages preview
  `https://0fee1018.draxos-mobile-internal-alpha.pages.dev/web`.
- The Web package points to
  `internal-alpha/v0-battle-preparation-complete-v1-20260529/web`, with
  equip-feedback hotfix PCK
  `internal-alpha/v0-battle-preparation-complete-v1-20260529-hotfix4/web/index.pck`.

## Battle Presentation v1

Battle Presentation v1 is implemented as a client-only readability pass for the
real battle loop. It keeps the existing backend/API/schema, simulator, rewards,
ranking, economy, weapons, spells and `battle_log_v1` contract.

- `battle_running` stays fullscreen, without app chrome, inside
  `BattleSafeFrame`.
- Running battle now has a compact confrontation strip with player vs opponent,
  lance progress, current state and a touch-safe `Pular batalha` action.
- `BattleVisualMockup`, `BattleStage2D` and `BattleLogPresenter` now present
  damage, healing, consumable use, status, familiars, summons and battle result
  with player-facing language.
- `battle_summary` prioritizes the result, opponent, short outcome phrase,
  reward/resources/ranking when present and the primary CTA
  `Voltar e verificar base`.
- `battle_logs` remains read-only and scoped to the current battle, with logs
  formatted for players instead of technical inspection.
- `docs/battle-presentation-v1.md` is the live package note.
- Battle Presentation v1 was published to Internal Alpha on `2026-05-29` after
  explicit release approval. The publication updated Android APK, PC Windows
  ZIP, Web assets, the Cloudflare Pages package and portal copy without
  backend/schema/API changes.
- The public Web package now points to the cache-busted asset root
  `internal-alpha/v0-battle-presentation-20260529/web`.

## Battle Drama v1.1

Battle Drama v1.1 is implemented and published as the client-only follow-up
after Web review showed Battle Presentation v1 was technically updated but still
looked too much like a mock/debug arena.

- `BattleStage2D` now has stronger side lighting, clash focus, softer floor
  guides and less empty marker noise.
- `BattleActorMarker` now draws a larger robed combatant silhouette with staff,
  aura, barrier read and stronger pulse feedback.
- The current-lance callout is wider and more legible, with the event name and
  player-facing effect on the first line.
- Empty status/cooldown rows no longer render dash icons that read like debug
  placeholders.
- Familiar and summon markers are slightly larger while preserving tooltips and
  replay state.
- The compact battle readout now uses player-facing pressure language for life,
  effects, waits and allies.
- `docs/battle-drama-v1-1.md` is the live package note.
- Battle Drama v1.1 was published to Internal Alpha on `2026-05-29` from branch
  `codex/draxos-mobile/battle-drama-v1-1`.
- The verified public preview is
  `https://7261c476.draxos-mobile-internal-alpha.pages.dev/web/index.html`, and
  its Web shell points to `internal-alpha/v0-battle-drama-v1-1-20260529/web`.
- The stable Cloudflare Pages domain was redeployed, but public unauthenticated
  GET still returns the Cloudflare Access page; use the verified preview URL or
  an authenticated Access session for human Web review.

## Social Basico Guilda v1

Social Basico Guilda v1 is implemented as the next product package after the
confirmed Foundation baseline. It keeps the existing backend/API/schema and
focuses on making the current social loop usable by real testers:

- Social screen now highlights account identity, own username, social save badge
  and clear Friends/Guild/Chat sections.
- Copy/show own username is a local shell action; it does not touch the server.
- Friends by username, guild create/join, member list, read-only guild
  structures and guild chat keep the existing endpoints.
- Guild chat now has light auto-sync every 8s only while the Social screen is
  open, pausing outside Social, offline, without account/session, during another
  action or in local-only Progression Lab.
- Published Internal Alpha builds now include Social Basico Guilda v1. Realtime,
  direct chat, helps, guild contributions, chat global, moderation/report/block,
  invites, guild wars and backend/schema changes remain out of scope.

## Latest Technical Package

Track 16 added the first behavior/crafting/consumable package requested by the
user. It remains technical context and not the current product focus;
`docs/behavior-potion-crafting-v1.md` is the current live summary. Ossos
Inteiros v1 only promotes the subset needed to make the published alpha coherent
around whole-number Ossos.

- Ossos are represented as whole numbers in the new scale
  (`1 Osso atual = 0.01 Osso antigo`) and current economy/content/Progression
  Lab values were rescaled by `100`.
- `po_osso` was added as a whole-number resource, created by crushing Ossos.
- `pocao_vida` and `craft_pocao_vida` were added to content, crafting state and
  server-authoritative Edge Functions.
- Save-scoped `crafting/*` and `build/*` endpoints manage crafting, consumable
  inventory, potion slot and spell/potion behavior.
- Battle simulator supports spell behavior, `consumable_use`, one potion use per
  slot per battle and five `heal` ticks of `4%` max HP.
- Godot Base/Ossario and Refugio preparation panels expose crafting, potion
  equip/remove and simple behavior toggles.
- Battle Preparation Complete v1 is the published product surface for potion
  equip/remove and simple behavior controls; further potion, behavior, crafting,
  tuning or economy expansion still needs a new explicit package.

Ossos Inteiros v1 is now published on top of the Visual Direction v1 build. The
remote migration `202605280001_behavior_crafting.sql` is applied, Edge Functions
were redeployed, generated Grimoire catalogs now expose whole-number Ossos
values, and Base collection preserves sub-one Ossos accrual until at least `1`
whole Osso is collectable. This fixes the visible `0.1 osso` class of issue
without adding a new schema/API package beyond Track 16.

## Release Snapshot

| Artifact       |      Bytes | SHA256                                                             |
| -------------- | ---------: | ------------------------------------------------------------------ |
| Android APK    | `31820934` | `ac154edf699afa74f3c82f44e3fd57969b3943420f4bb3fb94fb142620fdda60` |
| PC Windows ZIP | `40277711` | `14aa516367d4cfded3c1cad574f0cbdcb1d722cc7ee83b054f79e8736ae2f3b5` |
| Web index      |     `5442` | `dc79081a3d2cb360b6ad0a1b5ca7b1fa9efb58a78777b972bfdd89aa43271c90` |

Links:

- Supabase remote: `https://armxgipvnbbshzqawklw.supabase.co`
- Manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Stable portal:
  `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Stable Web: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Latest verified preview:
  `https://d3a140a5.draxos-mobile-internal-alpha.pages.dev`
- Web asset root:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-minigame-platform-v1-modes-20260601-c0c1e9c/web`
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-minigame-platform-v1-modes-20260601-c0c1e9c/downloads/draxos-mobile-alpha.apk`
- PC Windows ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-minigame-platform-v1-modes-20260601-c0c1e9c/downloads/draxos-mobile-alpha.zip`

Minigame Platform V1 was published to the Internal Alpha artifact/site channel
on `2026-06-01`. The remote manifest points to the Cloudflare Pages preview
above, APK/PC downloads are public unlisted Storage URLs, and the active API
contract is now `/modes`. Historical publication notes below are retained for
traceability.

Battle Preparation Complete v1 was published to the Internal Alpha artifact/site
channel on `2026-05-29`. Android APK, PC ZIP and Web assets were uploaded to
`internal-alpha/v0-battle-preparation-complete-v1-20260529`; Web assets use the
versioned root so browser caches cannot reuse older `index.js`, `index.pck` or
`index.wasm` paths. Web hotfixes later republished the Cloudflare Pages shell at
`https://d8f2e0a7.draxos-mobile-internal-alpha.pages.dev/web`, using local
loader assets in Pages and hotfix PCK `4247612` bytes to avoid the exported
`content_generator.gd` preload parse error and to fix the Preparation popup
visual regression where Refugio/Batalhar showed through the panel. APK/PC
downloads are public unlisted Storage URLs. The stable Cloudflare Pages domain
remains behind Access for public unauthenticated checks. The Edge manifest
endpoint remains healthy, but the release override was not updated during this
publication because the local environment did not include
`SUPABASE_ACCESS_TOKEN`; the portal package reads its bundled
`manifest.example.json` for published links/hashes.

Preparation equip-feedback hotfix was published on `2026-05-29` after Web review
showed `Equipar` looked silent in the Preparation popup. The client now
keeps/reopens the Preparation panel after equip and behavior actions, shows
`Ultima escolha: ...`, refreshes the equipped item state, prunes stale popup
action buttons during refresh, and keeps `boot.gd` under the Track 12 shell
budget. Validation passed with GUT client (`122/122`),
`validate_foundation.ps1 -Profile Client`, `smoke_responsive_layout.gd`,
`smoke_foundation_loop.gd` and `git diff --check`.
`smoke_foundation_surfaces.gd` was blocked by `NETWORK_UNAVAILABLE` against
local Supabase, not by this change. Export/upload/deploy passed with hotfix PCK
`4242428` bytes, public APK/ZIP HEAD checks and Browser visual review confirming
a real `Equipar` click changes `Athame Hematico` to `Em uso` in the published
Web preview
`https://0fee1018.draxos-mobile-internal-alpha.pages.dev/web?cachebust=hotfix4`.

## Visual Direction v1

Visual Direction v1 is implemented and published as the next refinement package
after Social Basico Guilda v1. It did not change backend, schema, API, gameplay,
economy, content tuning or final art.

- `docs/visual-direction-v1.md` is the live direction document for this package.
- `core/ui_tokens.gd` now owns surface accents, action accents, CTA selection
  and shared panel/button style helpers.
- Entry, Refugio drawer actions, shell action buttons, output panels and
  Base/Social/Competition/Shop panels now use the same restrained surface accent
  contract.
- Touch targets, responsive frames, first-screen Refugio anchors and battle safe
  frames remain in the existing Foundation Responsive contract.

## Risks And Blocks

- Track 16 migration/functions/catalog changes needed for Ossos Inteiros v1 are
  deployed. Further crafting, behavior, tuning, economy or content expansion
  still needs its own explicit package decision.
- Foundation Loop UX Pass 01 is the accepted historical V0 app-shell UX
  baseline after manual Android/Windows/Web review on `2026-05-29`; Social
  Basico Guilda v1, Battle Presentation v1, Battle Drama v1.1 and Battle
  Preparation Complete v1 are now available in the published Internal Alpha
  build for human validation.
- Battle Preparation Complete v1 is published to Internal Alpha with public
  APK/PC downloads, a cache-busted Web asset root and no-store Cloudflare Pages
  headers; Web/mobile visual confirmation passed on the latest preview, while
  Android/Windows still need manual confirmation.
- Edge release manifest override needs `SUPABASE_ACCESS_TOKEN` available in the
  release environment for future
  `publish_internal_alpha.ps1 -Mode DeployManifest` runs. This publication kept
  the endpoint healthy and used the packaged portal manifest as the
  published-link source.
- Track 13 release safety remains the baseline for any future publication or
  wider-access gate.
- `players.save_type` remains as alpha compatibility only. `account_profiles` +
  `game_saves` now exists as the foundation model; future account/save features
  should not use `players.save_type` as primary authority.
- Progression/economy remains mock/substance and not the current tuning focus.
- Release scripts are safe by default; remote mutation remains opt-in with
  `-ConfirmRemoteMutation`.

## Next Step

Openworld Node2D QoL Foundation is now the latest Internal Alpha publication:
release root `internal-alpha/v0-openworld-node2d-qol-20260601-5707167`, preview
`https://2cca25db.draxos-mobile-internal-alpha.pages.dev`. The next product
step is human review/playtest of the published Openworld Bosque feel: WASD,
free mouse/touch joystick, obstacle collision, border walls, y-depth/layers,
HUD/input interference, collection and chest deposit. Foundation Hardening V2
remains the previous hardening/multi-mode gate baseline. Arena tuning notes can
follow only after manual confirmation of the tutorial -> first real Arena ->
next difficulty loop, including potion consumption, remote arena selection,
buff selection, summary/claim behavior and Web Battle Lab/Progression Lab
remote generation through the same Supabase email/password Internal Alpha gate.
Do not open PVP, victory prediction, opponent counter-picks, custom thresholds,
enemy-specific behavior, spell priorities, direct chat, helps, contributions,
moderation, tuning numbers, new weapons, new spells, economy, new potions,
crafting expansion or broader replay controls beyond the Arena PVE package
without its own package decision.

## Validation

Latest validation for Battle Preparation Complete v1 publication on
`2026-05-29`:

- `npx -y deno check server/functions/build/index.ts supabase/functions/build/index.ts server/tests/build_equip_smoke.ts`:
  PASS.
- `npx -y deno test --allow-read server/tests/foundation_contracts_test.ts`:
  PASS.
- Remote `server/tests/build_equip_smoke.ts`: PASS against Supabase Internal
  Alpha after `build` function deploy.
- GUT `tests/client`: PASS through `tools/validate.gd` (`121/121`).
- `tools/smoke_foundation_loop.gd`: PASS.
- `tools/smoke_responsive_layout.gd`: PASS.
- `tools/validate.gd`: PASS.
- `validate_foundation.ps1 -Profile Client`: PASS, including
  `tools/validate.gd`, GUT `tests/client`, runtime/hardening/responsive/export
  smokes and `git diff --check`.
- `tools/smoke_foundation_surfaces.gd`: BLOCKED at anonymous auth with
  `NETWORK_UNAVAILABLE`; local/remote backend availability is outside the
  client-only package.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export
  mode `debug_fallback`.
- `export_presets.cfg` now excludes `assets/referenciaimagens/**`, keeping
  moodboard assets out of runtime exports and reducing APK/ZIP/PCK below current
  upload limits.
- Supabase Storage bucket file limit was raised to `209715200` bytes for
  Internal Alpha release buckets.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: PASS for
  `internal-alpha/v0-battle-preparation-complete-v1-20260529`.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: PASS.
- Supabase Storage upload: PASS for versioned APK/ZIP/Web.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-preparation-complete-v1-20260529/web`:
  PASS.
- Cloudflare Pages deploy: PASS, verified preview
  `https://17ea0fa1.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`:
  BLOCKED before remote secret mutation because `SUPABASE_ACCESS_TOKEN` was not
  available.
- Preview GET checks: PASS for
  `https://17ea0fa1.draxos-mobile-internal-alpha.pages.dev/web` with versioned
  Web asset root and `GODOT_CONFIG.fileSizes.index.pck = 4247020`.
- Remote HEAD checks: PASS for versioned `index.pck` (`4247020` bytes),
  `index.wasm` (`37695054` bytes), Android APK (`31649813` bytes) and PC ZIP
  (`40118021` bytes), all without Bearer token.
- Web hotfix after visual review: PASS. `tools/validate.gd` passed (`121/121`),
  `tools/smoke_exports.gd` passed, `tools/check_release_safety.ps1` passed,
  `git diff --check` passed,
  `export_internal_alpha.ps1 -AllowAndroidDebugFallback` passed, hotfix
  `index.pck` uploaded to
  `internal-alpha/v0-battle-preparation-complete-v1-20260529-hotfix1/web/index.pck`
  (`4247356` bytes),
  `build_cloudflare_pages_package.ps1 -MainPackUrl <hotfix-pck>` passed,
  Cloudflare Pages deploy passed with preview
  `https://dc29916b.draxos-mobile-internal-alpha.pages.dev/web`, and Browser
  visual review confirmed the Preparation panel opens in Web/mobile with
  readable Instrumento, Habilidades, Doutrina, Familiar and Pocao sections.
- Preparation popup visual hotfix: PASS. GUT `tests/client` passed (`121/121`,
  `1941` asserts), `tools/smoke_responsive_layout.gd` passed, `git diff --check`
  passed, `export_internal_alpha.ps1 -AllowAndroidDebugFallback` passed, hotfix
  `index.pck` uploaded to
  `internal-alpha/v0-battle-preparation-complete-v1-20260529-hotfix3/web/index.pck`
  (`4247612` bytes), Cloudflare Pages deploy passed with preview
  `https://d8f2e0a7.draxos-mobile-internal-alpha.pages.dev/web`, public HEAD
  check confirmed the hotfix PCK, and Browser visual review confirmed the mobile
  Preparation popup is opaque/full-height and no longer exposes the Refugio
  `Batalhar` CTA behind it.

Latest validation for Battle Drama v1.1 publication on `2026-05-29`:

- One-time Godot `--headless --import`: PASS in fresh worktree.
- GUT `tests/client`: PASS (`119/119`, `1896` asserts).
- `tools/smoke_responsive_layout.gd`: PASS.
- `validate_foundation.ps1 -Profile Client`: PASS, including
  `tools/validate.gd`, GUT `tests/client`, runtime/hardening/responsive/export
  smokes and `git diff --check`.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export
  mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: PASS for
  `internal-alpha/v0-battle-drama-v1-1-20260529`.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -PublicDownloads -ConfirmRemoteMutation`:
  PASS for versioned Storage APK/ZIP/Web and portal manifest package.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-drama-v1-1-20260529/web`:
  PASS.
- Cloudflare Pages deploy: PASS, verified preview
  `https://7261c476.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`:
  BLOCKED before remote secret mutation because `SUPABASE_ACCESS_TOKEN` was not
  available.
- Preview GET checks: PASS for `/web/index.html` with versioned Web asset root
  and `GODOT_CONFIG.fileSizes.index.pck = 4230188`.
- Remote HEAD checks: PASS for versioned `index.js` (`315759` bytes),
  `index.pck` (`4230188` bytes), `index.wasm` (`37695054` bytes), Android APK
  (`31637525` bytes) and PC ZIP (`40103282` bytes), all without Bearer token.

Latest validation for Battle Presentation v1 publication on `2026-05-29`:

- One-time Godot `--headless --import`: PASS in fresh publication worktree.
- `validate_foundation.ps1 -Profile Client`: PASS, including
  `tools/validate.gd`, GUT `tests/client` (`119/119`, `1895` asserts),
  runtime/hardening/responsive/export smokes.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export
  mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: PASS for
  `internal-alpha/v0-battle-presentation-20260529`.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: PASS.
- Supabase Storage upload: PASS for
  `internal-alpha/v0-battle-presentation-20260529` and stable
  `internal-alpha/v0`.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-presentation-20260529/web`:
  PASS.
- Cloudflare Pages deploy: PASS, verified preview
  `https://2a470539.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`:
  BLOCKED before remote secret mutation because `SUPABASE_ACCESS_TOKEN` was not
  available; Edge manifest endpoint remained healthy and portal was adjusted to
  read bundled `manifest.example.json`.
- `server/tests/release_manifest_smoke.ts`: PASS against remote Supabase.
- `server/tests/internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS.
- Preview GET checks: PASS for `/portal/index.html`,
  `/portal/manifest.example.json` and `/web/index.html` with versioned Web asset
  root.
- Remote HEAD checks: PASS for versioned `index.js` (`315759` bytes),
  `index.pck` (`4227948` bytes), `index.wasm` (`37695054` bytes), versioned APK
  (`31633429` bytes) and stable APK (`31633429` bytes), all without Bearer
  token.

Latest validation for Ossos Inteiros v1 publication on `2026-05-29`:

- `npx -y deno test --allow-read server/tests/integer_bones_contract_test.ts`:
  PASS.
- `npx -y deno check server/functions/base/index.ts supabase/functions/base/index.ts server/functions/content/index.ts supabase/functions/content/index.ts server/tests/integer_bones_contract_test.ts`:
  PASS.
- `npx -y deno test --allow-read server/tests/foundation_contracts_test.ts server/tests/integer_bones_contract_test.ts`:
  PASS.
- `validate_foundation.ps1 -Profile Client`: PASS after one-time Godot import in
  the fresh worktree.
- `validate_foundation.ps1 -Profile Quick`: PASS after server config and smoke
  updates.
- Supabase remote migration push: PASS; local/remote migrations aligned through
  `202605280001_behavior_crafting.sql`.
- Supabase Edge Function deploy: PASS for gameplay/release functions touched by
  the package.
- Remote smokes: PASS for `base_manager_smoke.ts`,
  `monetization_rewards_smoke.ts`, `grimoire_catalog_smoke.ts` and
  `first_slice_battle_smoke.ts`.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export
  mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: PASS.
- Supabase Storage upload with CLI `2.98.0`: PASS for `internal-alpha/v0` and
  `internal-alpha/v0-integer-bones-20260529`.
- Cloudflare Pages deploy: PASS, preview
  `https://d7a31bf6.draxos-mobile-internal-alpha.pages.dev`.
- Supabase release manifest override + `release` function deploy: PASS.
- Remote release smokes: PASS for `release_manifest_smoke.ts`,
  `release_artifacts_remote_smoke.ts`, `internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`, and `grimoire_catalog_smoke.ts`.
- Direct APK HEAD without Bearer token: PASS, `200`, `31629333` bytes,
  `application/vnd.android.package-archive`.
- Cache-bust preview checks: PASS for `/portal/index.html` with public APK link,
  `/web/index.html` with `GODOT_CONFIG` and the versioned asset root, plus
  remote HEAD `200` for versioned `index.js`, `index.pck` and `index.wasm`.

Latest validation for Visual Direction v1 publication on `2026-05-29`:

- One-time Godot `--headless --import`: PASS in fresh publication worktree.
- `validate_foundation.ps1 -Profile Client`: PASS, including `git diff --check`,
  PowerShell parse, server/supabase mirrors, Deno release typecheck light,
  structural readiness, `tools/validate.gd`, GUT `tests/client` (`119/119`,
  `1880` asserts), `tools/smoke_runtime_config.gd`,
  `tools/smoke_foundation_hardening.gd`, `tools/smoke_responsive_layout.gd` and
  `tools/smoke_exports.gd`.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export
  mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan`: PASS.
- `publish_internal_alpha.ps1 -Mode Package`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- Cloudflare Pages deploy: PASS, preview
  `https://6a6ae522.draxos-mobile-internal-alpha.pages.dev`.
- Supabase Storage upload: PASS with Supabase CLI `2.98.0`, protected downloads
  enabled.
- Supabase release manifest override + `release` function deploy: PASS.
- `server/tests/release_manifest_smoke.ts`: PASS against remote Supabase.
- `server/tests/release_download_smoke.ts`: PASS with signed HEAD checks for
  Android and PC downloads.
- `server/tests/internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS.
- Preview GET checks: PASS for `/portal/index.html` (`Draxos Alpha`) and
  `/web/index.html` (`GODOT_CONFIG`).
- Web cache-bust hotfix after browser check: PASS.
  `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-web-20260529-visual-direction-v1 -ConfirmRemoteMutation`
  uploaded versioned Web assets,
  `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-web-20260529-visual-direction-v1/web`
  rewrote the loader URLs, and Cloudflare Pages deploy produced preview
  `https://5477aaf9.draxos-mobile-internal-alpha.pages.dev`.
- Cache-bust preview checks: PASS for `/portal/index.html` (`Draxos Alpha`),
  `/web/index.html` (`GODOT_CONFIG` and versioned asset root), and remote HEAD
  `200` for versioned `index.js`, `index.pck` and `index.wasm`.
- `tools/check_agent_ops_foundation.ps1`: PASS after status updates.
- `validate_foundation.ps1 -Profile Quick`: PASS after status updates.
- `git diff --check`: PASS.

Latest validation for Social Basico Guilda v1 publication on `2026-05-29`:

- `validate_foundation.ps1 -Profile Full`: PASS, including `tools/validate.gd`,
  GUT `tests/client` (`117/117`, `1857` asserts),
  runtime/hardening/responsive/export smokes, release typecheck, Track 13
  readiness and Track 14 agent ops checks.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export
  mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan`: PASS.
- `publish_internal_alpha.ps1 -Mode Package`: PASS.
- Cloudflare Pages deploy: PASS, preview
  `https://483a73f3.draxos-mobile-internal-alpha.pages.dev`.
- Supabase Storage upload: PASS, `25` files uploaded across public site assets
  and protected downloads.
- Supabase release manifest override + `release` function deploy: PASS.
- `server/tests/release_manifest_smoke.ts`: PASS against remote Supabase.
- `server/tests/release_download_smoke.ts`: PASS with signed HEAD checks for
  Android and PC downloads.
- `server/tests/internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS.
- Preview GET checks: PASS for `/portal/index.html` (`Draxos Alpha`) and
  `/web/index.html` (`GODOT_CONFIG`).
- `git diff --check`: PASS.
- `server/tests/release_artifacts_remote_smoke.ts`: unauthenticated artifact
  probe returns `401` for protected downloads by design; use
  `release_download_smoke.ts` for the signed download contract.

Latest validation for Battle Presentation v1 local merge on `2026-05-29`:

- GUT `tests/client`: PASS (`119/119`, `1895` asserts).
- `tools/smoke_mobile_presentation.gd`: PASS.
- `tools/smoke_responsive_layout.gd`: PASS, including `battle_running`,
  `battle_summary` and `battle_logs` at `360x800`, `390x844`, `1280x720` and
  `1920x1080`.
- `tools/smoke_foundation_loop.gd`: PASS.
- `tools/validate.gd`: PASS (`119/119`, `1895` asserts).
- `validate_foundation.ps1 -Profile Client`: PASS, including `git diff --check`,
  PowerShell parse, server/supabase mirrors, Deno release typecheck light,
  structural readiness, `tools/validate.gd`, GUT `tests/client`,
  `tools/smoke_runtime_config.gd`, `tools/smoke_foundation_hardening.gd`,
  `tools/smoke_responsive_layout.gd` and `tools/smoke_exports.gd`.
- `validate_foundation.ps1 -Profile Quick`: PASS after documentation/status
  updates.
- `tools/check_agent_ops_foundation.ps1`: PASS after Kanban/status updates.
- `git diff --check`: PASS.

Documentation/foundation validation for this stage:

```powershell
git diff --check
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_agent_ops_foundation.ps1 -ProjectDir .
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_loop.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_hardening.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
```

Full release/backend validation remains available through
`validate_foundation.ps1 -Profile Full` when a gate needs it.

Note: on a fresh worktree, run the Godot `--import` step once before headless
smokes if global class names are not yet registered.

## Read Next

1. `../AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `docs/documentation-index.md`
4. `docs/foundation-app-v0-audit.md`
5. `docs/foundation-loop-audit.md`
6. `docs/pve-arena-initial-direction.md`
7. `docs/product-vision.md`
8. `docs/product-brief.md`
9. `docs/design-pending.md`
