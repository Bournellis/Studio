# DraxosMobile - Foundation Hardening V2 Readiness Report

- Status: `PARTIAL_REMOTE_STORAGE_BACKEND_READY_CLOUDFLARE_BLOCKED`
- Date: `2026-06-01`
- Integration branch: `codex/draxos-mobile/foundation-hardening-v2`
- Integration worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2`
- Planned release root: `internal-alpha/v0-foundation-hardening-v2-20260601-<sha>`
- Latest published baseline remains: `Hardening Platform V1`
- Latest published release root remains: `internal-alpha/v0-hardening-platform-v1-20260601-19eb80d`

## Summary

Foundation Hardening V2 is implemented and locally validated as an enforcement
package for multi-mode expansion. It does not add gameplay, tuning, economy,
new playable content, PVP, social expansion or visual redesign.

Remote publication was resumed after configuring a local Android release
keystore. The V2 backend/schema and Storage artifacts are now staged remotely,
but the final Internal Alpha was intentionally stopped before manifest promotion
because Cloudflare Pages deployment is blocked by the local Wrangler
authentication/account configuration.

The current remote alpha remains Hardening Platform V1 until Cloudflare Pages is
deployed and the release manifest is promoted to the V2 release root.

## Implemented Enforcement

- Canon/live-doc drift enforcement for Hardening Platform V1 as the published
  baseline and V2 as an unpublished local-ready branch.
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

## Partial Remote Publication - 2026-06-01

Remote mutation was executed only for the safe staged pieces needed before
Cloudflare/manifest promotion:

- Android release keystore created locally outside Git under
  `D:\Estudio-secrets\draxos-mobile\android\`.
- `.env.internal-alpha.local` created locally and verified as ignored by Git.
- Strict keystore gate passed:
  `check_android_release_keystore.ps1 -Mode ReleaseCandidate -RequireReleaseKeystore`.
- `FullLocal` passed after keystore configuration.
- `ReleaseDryRun` passed after keystore configuration.
- Android/PC/Web exports passed; Android export mode is `release`, not
  `debug_fallback`.
- Release root staged:
  `internal-alpha/v0-foundation-hardening-v2-20260601-aa07388`.
- Supabase project linked locally to `armxgipvnbbshzqawklw`.
- Remote migrations applied:
  - `202606010003_foundation_hardening_v2.sql`;
  - `202606010004_resource_reconciliation_stability.sql`.
- Edge Function `modes` deployed to project `armxgipvnbbshzqawklw`.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation` completed.
- Cloudflare Pages package generated and validated against remote Storage asset
  sizes.

Staged artifact URLs:

- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-hardening-v2-20260601-aa07388/downloads/draxos-mobile-alpha.apk`
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-hardening-v2-20260601-aa07388/downloads/draxos-mobile-alpha.zip`
- Web asset root:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-hardening-v2-20260601-aa07388/web`

Remote HEAD checks passed for:

- Android APK: `30072494` bytes.
- PC ZIP: `40325026` bytes.
- Web `index.pck`: `4577880` bytes.
- Web `index.wasm`: `37695054` bytes.

## Publication Blockers

FullPublish was not completed and the release manifest was not promoted.

Resolved blockers:

- Android release keystore is configured locally.
- Supabase URL and project ref are configured locally.
- Android/PC/Web artifacts exist.
- Supabase migrations, `modes` function and Storage upload are staged remotely.

Remaining blocker:

- Wrangler cannot deploy Cloudflare Pages with the current local authentication.
  `wrangler pages deploy` fails with Cloudflare API authentication error
  `10000` even when `CLOUDFLARE_ACCOUNT_ID` is supplied.

Until Cloudflare Pages deployment succeeds, do not run `DeployManifest` or
`FullPublish`, because the stable Web shell would still point at the previous
published package.

## Remote Status

No new complete Internal Alpha was published for V2.

Current remote alpha remains Hardening Platform V1:

- Release root: `internal-alpha/v0-hardening-platform-v1-20260601-19eb80d`
- Cloudflare preview: `https://68452eed.draxos-mobile-internal-alpha.pages.dev`
- Stable Portal: `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Stable Web: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Remote manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

## Ready To Resume FullPublish

Before resuming publication:

1. Fix local Cloudflare Wrangler authentication/account access.
2. Deploy:
   `npx -y wrangler pages deploy .\build\internal-alpha\cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`.
3. Promote the manifest:
   `tools/publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-foundation-hardening-v2-20260601-aa07388 -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation`.
4. Run expanded `RemoteReadOnly` and remote release smokes.
5. Record the Cloudflare preview URL and final hashes.

## Master Baseline Decision

`master` should not be updated to claim V2 as the official published baseline
until the Android release keystore gate, artifacts, remote publish and remote
read-only smokes complete. Until then, Hardening Platform V1 remains the
published baseline and V2 remains an integration branch ready for publication
handoff.
