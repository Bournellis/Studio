# DraxosMobile - Foundation Hardening V2 Readiness Report

- Status: `PUBLISHED_INTERNAL_ALPHA`
- Date: `2026-06-01`
- Integration branch: `codex/draxos-mobile/foundation-hardening-v2`
- Integration worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2`
- Release root: `internal-alpha/v0-foundation-hardening-v2-20260601-aa07388`
- Cloudflare preview: `https://2cba1ff3.draxos-mobile-internal-alpha.pages.dev`
- Current published baseline: `Foundation Hardening V2`

## Summary

Foundation Hardening V2 is implemented, validated and published as the current
Internal Alpha enforcement package for multi-mode expansion. It does not add
gameplay, tuning, economy, new playable content, PVP, social expansion or visual
redesign.

Remote publication was resumed after configuring a local Android release
keystore. Supabase migrations, the `modes` Edge Function, Storage artifacts,
Cloudflare Pages, release manifest promotion and expanded remote read-only
smokes all completed for the V2 release root.

After the first manual Web entry attempt reported `http_error: request failed`,
the same V2 release root was reexported and republished with the registered
Supabase publishable key and the current Cloudflare preview CORS origin. The
manifest now points to `https://2cba1ff3.draxos-mobile-internal-alpha.pages.dev`,
and remote smoke validates release manifest, anonymous auth, `account/guest` and
`account/state`.

## Implemented Enforcement

- Canon/live-doc drift enforcement for Foundation Hardening V2 as the published
  baseline and Hardening Platform V1 as the previous platform baseline.
- Strict mode definition schema and deterministic future-mode scaffold path.
- Decision packs for `openworld`, `towerdefense` and `cardgame`.
- `/modes` backend modularity and mutating endpoint idempotency hardening.
- RPC-backed `/modes/session/abandon` with `request_id` and `request_hash`.
- Session cache ownership slice and save/session boundary tests.
- Validation/security gates for mirrors, budgets, CORS, descriptors, secrets,
  dependency lock sanity and release dry-run.
- Read-only Ops CLI and Backend Proprio boundary inventory.
- Local admin/RLS smoke adjusted to prove revoked admin RPC access through the
  authoritative grant matrix, avoiding a destructive local PG17/PostgREST
  permission-denial crash path.
- Resource reconciliation RPC stability migration, replacing the historical
  dynamic JSON loop with explicit numeric fields.

## Validation Evidence

`tools/validate_foundation.ps1 -ProjectDir . -Profile FullLocal` passed.

Report:

- `build/validation/foundation-validation-latest.json`
- `build/validation/foundation-validation-latest.md`

Summary from the generated report:

- Requested profile: `FullLocal`
- Effective profile: `FullLocal`
- Enabled stages: `DocsOnly, ServerQuick, ClientQuick, ModePlatform, DatabaseLocal, ReleaseDryRun`
- Result: PASS `43`, FAIL `0`, SKIP `3`

Key gates passed:

- `git diff --check`
- PowerShell parse checks
- structural readiness
- V2 descriptor schema strictness hook
- V2 hot file budgets
- V2 dependency lock sanity
- baseline drift guard
- V2 live-doc release root guard
- secrets/client safety scan
- server/supabase mirrors
- V2 mode handler/security strictness
- Deno release and transactional domain typechecks
- Deno foundation, Arena PVE and mode platform contract tests
- `deno task check` in `server/functions`
- `deno task check` in `supabase/functions`
- `tools/check_foundation_expansion_readiness.ps1`
- local transactional RPC live proof
- local Edge transactional RPC adapter smoke
- local mode platform live proof
- local admin RLS live smoke
- Godot `tools/validate.gd`
- full GUT client suite: `161` tests passing
- mode hub, Openworld, responsive layout and export smokes
- release manifest typecheck
- release plan dry-run
- release safety check
- Track 13 readiness
- agent operations foundation

## Publication - 2026-06-01

Remote mutation was executed after `FullLocal`, `ReleaseDryRun` and the Android
release keystore gate passed:

- Android release keystore created locally outside Git under
  `D:\Estudio-secrets\draxos-mobile\android\`.
- `.env.internal-alpha.local` created locally and verified as ignored by Git.
- Strict keystore gate passed:
  `check_android_release_keystore.ps1 -Mode ReleaseCandidate -RequireReleaseKeystore`.
- `FullLocal` passed after keystore configuration.
- `ReleaseDryRun` passed after keystore configuration.
- Android/PC/Web exports passed; Android export mode is `release`, not
  `debug_fallback`.
- Release root:
  `internal-alpha/v0-foundation-hardening-v2-20260601-aa07388`.
- Supabase project linked locally to `armxgipvnbbshzqawklw`.
- Remote migrations applied:
  - `202606010003_foundation_hardening_v2.sql`;
  - `202606010004_resource_reconciliation_stability.sql`.
- Edge Function `modes` deployed to project `armxgipvnbbshzqawklw`.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation` completed.
- Cloudflare Pages package generated and validated against remote Storage asset
  sizes.
- Cloudflare Pages deployed:
  `https://2cba1ff3.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`
  completed and deployed the `release` Edge Function.
- `RemoteReadOnly` passed against the published V2 manifest, Portal/Web shell
  and public artifacts.

Published artifact URLs:

- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-hardening-v2-20260601-aa07388/downloads/draxos-mobile-alpha.apk`
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-hardening-v2-20260601-aa07388/downloads/draxos-mobile-alpha.zip`
- Web asset root:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-hardening-v2-20260601-aa07388/web`
- Portal:
  `https://2cba1ff3.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web:
  `https://2cba1ff3.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Remote manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

Remote HEAD checks passed for:

- Android APK: `30072494` bytes.
- PC ZIP: `40325026` bytes.
- Web `index.pck`: `4577880` bytes.
- Web `index.wasm`: `37695054` bytes.

## Publication Blockers

No publication blockers remain for V2. Resolved blockers:

- Android release keystore is configured locally.
- Supabase URL and project ref are configured locally.
- Android/PC/Web artifacts exist.
- Supabase migrations, `modes` function and Storage upload are published remotely.
- Wrangler authentication/account access was refreshed and Cloudflare Pages
  deployment passed.
- Release manifest promotion passed.
- Expanded remote read-only validation passed.

## Remote Status

Foundation Hardening V2 is the current remote Internal Alpha:

- Release root: `internal-alpha/v0-foundation-hardening-v2-20260601-aa07388`
- Cloudflare preview:
  `https://2cba1ff3.draxos-mobile-internal-alpha.pages.dev`
- Portal:
  `https://2cba1ff3.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web:
  `https://2cba1ff3.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Remote manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

Hardening Platform V1 remains preserved as the previous mode-platform baseline.

## Publication Commands Executed

Key publication commands completed after the partial handoff was resumed:

1. `npx -y wrangler pages deploy .\build\internal-alpha\cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`
2. `tools/publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-foundation-hardening-v2-20260601-aa07388 -StaticSiteBaseUrl https://2cba1ff3.draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation`
3. `tools/validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly`

## Master Baseline Decision

`master` can be promoted to Foundation Hardening V2 after the final integration
branch commit lands and the tree is clean. New DraxosMobile work should branch
from updated `master`, use a dedicated worktree and follow
`docs/multi-agent-workflow.md`.
