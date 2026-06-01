# DraxosMobile - Foundation Hardening V2 Readiness Report

- Status: `LOCAL_READY_REMOTE_BLOCKED`
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

Remote publication was intentionally stopped before FullPublish because the V2
plan requires a configured Android release keystore. The available environment
does not provide the release keystore tuple, and the release dry-run also reports
missing publish artifacts and remote Supabase URL configuration.

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

## Publication Blockers

FullPublish was not run and no remote mutation was executed.

Blocking items:

- Android release keystore is not configured.
- Strict keystore gate fails as expected with:
  `check_android_release_keystore.ps1 -Mode ReleaseCandidate -RequireReleaseKeystore`.
- `SUPABASE_URL` or `DRAXOS_MOBILE_SUPABASE_URL` is not configured for packaging/publish.
- Local publish artifacts are absent:
  - `build/android/draxos-mobile-alpha.apk`
  - `build/pc/draxos-mobile-alpha.zip`
  - `build/web/index.html`

The safe plan gate still passes in `Plan` mode and reports these as blockers for
Package/remote modes.

## Remote Status

No new Internal Alpha was published for V2.

Current remote alpha remains Hardening Platform V1:

- Release root: `internal-alpha/v0-hardening-platform-v1-20260601-19eb80d`
- Cloudflare preview: `https://68452eed.draxos-mobile-internal-alpha.pages.dev`
- Stable Portal: `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Stable Web: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Remote manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

## Ready To Resume FullPublish

Before resuming publication:

1. Configure Android release keystore values locally:
   - `DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PATH`
   - `DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_USER`
   - `DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PASSWORD`
2. Provide publish environment:
   - Supabase/Cloudflare CLI authenticated.
   - `SUPABASE_URL` or `DRAXOS_MOBILE_SUPABASE_URL`.
   - Required publish tokens in the local shell only.
3. Re-run:
   - `tools/check_android_release_keystore.ps1 -Mode ReleaseCandidate -RequireReleaseKeystore`
   - `tools/validate_foundation.ps1 -Profile FullLocal`
   - `tools/validate_foundation.ps1 -Profile ReleaseDryRun`
4. Export signed Android, PC and Web artifacts.
5. Run FullPublish with explicit `-ConfirmRemoteMutation`.
6. Run expanded `RemoteReadOnly` and record the new release URLs/hashes.

## Master Baseline Decision

`master` should not be updated to claim V2 as the official published baseline
until the Android release keystore gate, artifacts, remote publish and remote
read-only smokes complete. Until then, Hardening Platform V1 remains the
published baseline and V2 remains an integration branch ready for publication
handoff.
