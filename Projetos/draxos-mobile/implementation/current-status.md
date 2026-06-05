# DraxosMobile - Current Status

- Last updated: `2026-06-05`
- Project: `draxos-mobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `Internal Alpha`
- Active stage: `Arena PVE First Real Run + Update Recovery`
- Active stage status: `ARENA_PVE_FIRST_REAL_RUN_PUBLISHED_INTERNAL_ALPHA`
- Build channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`

## Current Truth

- Latest published remote package: `Arena PVE First Real Run + Update Recovery`
- Release root: `internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Latest deployment evidence: `https://2c020d09.draxos-mobile-internal-alpha.pages.dev`
- Source state: `master` after merging Track 23 Arena PVE update recovery and preserving the later Scenario Fixtures V1 merge on the same trunk.
- Runtime config hotfix: `release/config` now uses `config_version = track23-online-actions-hotfix` and allows online server-authoritative progression actions (`read_only: false`, `mutable_gameplay_state: true`) while preserving the conservative client fallback when remote config is unavailable.
- Previous content/polish package: `Bosque v3 UX/Feel`
- Previous content/polish release root: `internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45`
- Previous content/polish preview: `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`
- Previous technical package: `Technical Hardening`
- Previous technical release root: `internal-alpha/v0-technical-hardening-20260605-8e54a1f`
- Previous technical preview: `https://2fe9393e.draxos-mobile-internal-alpha.pages.dev`
- Previous Openworld content package: `Openworld Main Menu Sync`
- Previous Openworld release root: `internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`
- Previous Openworld preview: `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`
- Previous hardening baseline: `Foundation Hardening V2`
- Previous hardening release root: `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`
- Previous hardening preview: `https://ca946749.draxos-mobile-internal-alpha.pages.dev`
- Hardening baseline marker: `Track 13 - Foundation Validation And Release Safety` (`TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`)
- Agent baseline marker: `Track 14 - Agent Operations Foundation` (`TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`)
- Arena context: Track 18 - PVE Arena Initial, Track 20 Season 1 Arena Calibration and Track 21 Arena Loop Unlock/Friction are preserved Arena/Autobattler context and are now extended by Track 23 update recovery.
- Technical context: Track 16 Behavior And Potion Crafting remains existing alpha substance summarized in `docs/behavior-potion-crafting-v1.md`, not the current product focus.

## Published Package

Arena PVE First Real Run + Update Recovery is the current Internal Alpha package. It closes the critical update-friction case where a player had an active Arena attempt after a package update, was told to finish the run, but no longer had a useful route to access or end it.

Delivered in this package:

- keeps tutorial Arena as 1 duel and the first real Arena as 3 duels with buff choices between wins;
- adds `Retomar tentativa`, `Abandonar tentativa` and `Encerrar tentativa antiga` actions in the Arena shell;
- blocks new Arena starts locally while an active attempt exists, pushing the player to resume or abandon first;
- routes abandon through `/arena/pve/abandon` with `request_id/request_hash`;
- treats incompatible or malformed active attempts as recovery state instead of trapping the player;
- preserves server-authoritative rewards: abandon grants no completion reward;
- keeps Bosque v3 UX/Feel, Technical Hardening, Openworld Main Menu Sync, Foundation Hardening V2, Hardening Platform V1, Remote Lab Runner and the Arena/Lab baselines intact.

Publication evidence:

- Export regenerated APK, PC ZIP and Web artifacts from current `master`.
- Public Storage upload, Cloudflare Pages production branch `main`, release manifest deploy and RemoteReadOnly passed.
- Cloudflare Pages preview evidence: `https://2c020d09.draxos-mobile-internal-alpha.pages.dev`.
- Remote Web launch smoke on preview loaded the game in `3463 ms`, matched release root and asset root, and reported no runtime errors.
- Stable Portal/Web remain protected by Cloudflare Access and passed RemoteReadOnly with Access marked expected.
- Android APK uses `debug_fallback`, accepted for closed Internal Alpha only.
- `release/config` hotfix applied after publication so the same package no longer pauses online progression actions by remote config.

Artifact hashes:

- Android APK SHA256: `ae886a7790c19213c44a728e56481126e20f47b4ddb588e2ffdfc99fd99fd7ce`
- PC Windows ZIP SHA256: `09f3be25a8a5520876796fbe3ec7ab60281b773f4807e96c7b83422437e706ff`
- Web Index SHA256: `fb549621d02bafc85cf1eece7ff69bd90c2daa445aa3f83de44e9bc8e8e31a2d`

## Current Gate

The next product step is human playtest of the published Arena PVE First Real Run + Update Recovery package before opening Arena tuning, broader Openworld expansion or new mode work.

Playtest focus:

1. Start from tutorial, then confirm the first real Arena is a 3-duel run with buff choices between victories.
2. Confirm an active run can be resumed from Arena selection after leaving/reopening.
3. Confirm `Abandonar tentativa` and `Encerrar tentativa antiga` clear the blocker without granting completion reward.
4. Confirm the player is no longer trapped by an inaccessible post-update Arena attempt.
5. Confirm Bosque entry, collect/deposit/craft feedback and main menu still regress cleanly after the Arena package.

## Live Boundaries

- DraxosMobile is a PVE Arena-first async autobattler with Refugio/Base, later PVP and social systems.
- Openworld/Bosque is an approved Internal Alpha slice, not approval for a continuous open world expansion.
- Arena PVE remains the living product direction for early game, governed by `docs/pve-arena-initial-direction.md` and `docs/pve-arena-v1.md`.
- Foundation Hardening V2 remains the previous hardening/live-doc enforcement baseline.
- Hardening Platform V1 remains the previous mode-platform baseline.
- Remote Lab Runner remains preserved for Battle Lab and Progression Lab in Web export, without service role in client/export and without economy/ranking/save-progress mutation.
- Current names, spells, weapons, economy values, Battle Pass, battle flavor and visual identity are mock/substance unless a live doc promotes them.

## Validation Snapshot

Track 23 local validation before publication:

- `git diff --check`: PASS.
- `deno test --allow-read server/tests/arena_loop_unlock_friction_test.ts`: PASS, 6 tests.
- GUT client suite: PASS, 229 tests.
- `validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ModePlatform -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: PASS after moving the active Doing card to Done, as required by release safety.

Track 23 publication validation:

- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- `wrangler pages deploy ... --branch main`: PASS, preview `https://2c020d09.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a -RemoteWebUrl https://2c020d09.draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS after loading local read-only Supabase URL and publishable key from `.env.internal-alpha.local`.

Runtime config online actions hotfix validation:

- `deno test --allow-read server/tests/release_auth_contract_test.ts`: PASS, 4 tests.
- `deno check server/functions/release/index.ts supabase/functions/release/index.ts server/tests/runtime_config_smoke.ts server/tests/release_auth_contract_test.ts`: PASS.
- `tools/smoke_runtime_config.gd`: PASS.
- `validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS after one-time `Godot --headless --import` for the fresh worktree cache.
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: PASS after moving the hotfix card from Doing to Done, as required by release safety.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a -PublicDownloads -ConfirmRemoteMutation`: PASS, redeploying the `release` Edge Function.
- Remote `GET /release/config`: PASS with `config_version = track23-online-actions-hotfix`, `read_only = false`, `mutable_gameplay_state = true`, `no_service_role = true`, and `no_secrets = true`.
- `deno run --allow-net --allow-env server/tests/runtime_config_smoke.ts` against remote Supabase: PASS.

Historical validation logs and package-by-package publication evidence belong in `implementation/tracks/`, `docs/*-report.md`, Kanban Done cards or handoffs, not in this decision snapshot.

## Read Next

1. `AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `docs/documentation-index.md`
4. `docs/multi-agent-workflow.md`
5. `docs/pve-arena-initial-direction.md`
6. `docs/pve-arena-v1.md`
7. `docs/product-vision.md`
8. `docs/product-brief.md`
9. `docs/design-pending.md`
