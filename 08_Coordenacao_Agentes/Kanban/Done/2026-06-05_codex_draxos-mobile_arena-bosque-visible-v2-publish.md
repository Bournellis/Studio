# DraxosMobile - Arena/Bosque Visible V2 Publish

- date: `2026-06-05`
- agent: `codex`
- branch: `codex/draxos-mobile/cache-apk-v2`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--cache-apk-v2`
- source commit: `01d80d5`
- release root: `internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5`
- official portal: `https://draxos-mobile-internal-alpha.pages.dev/`
- official web: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- deployment evidence: `https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev`
- Android APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5/downloads/draxos-mobile-alpha.apk`
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5/downloads/draxos-mobile-alpha.zip`

## Root Cause

The user reported that the published test still looked unchanged for both Arena preparation and Bosque.

Two causes were found and fixed:

- Android/export visibility: the previous APK and manifest still used app version code `1`, so an installed old alpha could continue behaving like the current build. Arena/Bosque Visible V2 bumps app/export/manifest metadata to `0.0.2-alpha.0` and version code `2`, and the remote manifest now uses minimum supported version code `2`.
- Arena blocked selection: `arena_surface_presenter.gd` returned early when an active/stuck attempt blocked new starts, before adding the preparation panel. The active/stuck selection path now renders behavior preparation before the recovery panel.

Bosque runtime fixes from Arena/Bosque Regression Hotfix remain preserved: local deposit/craft feedback while the server event is pending, duplicate-action blocking during save, and pending-event flush before leaving the integrated session.

## Artifacts

- Android APK SHA256: `aef590a4d5a072153e6c1fb21ed9722e890654a2b2acaa575780758ec18d4282`
- PC Windows ZIP SHA256: `f5fde2d9a3274683fa941145718626e929732d76e85acc6babe7d69d6b0c7572`
- Web Index SHA256: `bf3d428d2dd7990ca90d245784ce1b98b43a71e638e4ffcbf84a43d605c769d4`
- Android export mode: `debug_fallback`

## Validation

- `tools/validate.gd`: PASS, 236 tests / 3716 asserts.
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: PASS.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -ReleaseRoot internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5 -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5 -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: PASS, preview `https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5 -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5 -RemoteWebUrl https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS. Manifest version `0.0.2-alpha.0`, version code `2`, artifact URLs matched the release root, and Web launch loaded in `3542 ms`.

## Handoff

Ask the tester to install the new APK URL above. If Android keeps the old app or refuses the update, uninstall the previous DraxosMobile alpha once and install the new APK with version code `2`.

