# DraxosMobile - Current Status

- Last updated: `2026-06-05`
- Project: `draxos-mobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `Internal Alpha`
- Active stage: `Bosque v3 UX/Feel Publication`
- Active stage status: `BOSQUE_V3_UX_FEEL_PUBLISHED_INTERNAL_ALPHA`
- Build channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`

## Current Truth

- Latest published remote package: `Bosque v3 UX/Feel`
- Release root: `internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Latest deployment evidence: `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`
- Source state: `master` after merging Bosque v3 UX/Feel and AutoRun Lab V1 updates.
- Previous content package: `Openworld Main Menu Sync`
- Previous content release root: `internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`
- Previous content verified preview: `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`
- Previous technical package: `Technical Hardening`
- Previous technical release root: `internal-alpha/v0-technical-hardening-20260605-8e54a1f`
- Previous technical preview: `https://2fe9393e.draxos-mobile-internal-alpha.pages.dev`
- Previous hardening baseline: `Foundation Hardening V2`
- Previous hardening release root: `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`
- Previous hardening preview: `https://ca946749.draxos-mobile-internal-alpha.pages.dev`
- Hardening baseline marker: `Track 13 - Foundation Validation And Release Safety` (`TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`)
- Agent baseline marker: `Track 14 - Agent Operations Foundation` (`TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`)
- Arena contract context: `Track 18 - PVE Arena Initial`, Track 20 Season 1 Arena Calibration and Track 21 Arena Loop Unlock/Friction are preserved Arena/Autobattler context, not the current platform baseline.
- Technical context: Track 16 Behavior And Potion Crafting is existing alpha substance summarized in `docs/behavior-potion-crafting-v1.md`, not the current product focus.

## Published Package

Bosque v3 UX/Feel is the current Internal Alpha package. It preserves Technical Hardening, Openworld Main Menu Sync and the Arena/Lab baselines while improving the active Bosque slice without opening continuous Openworld scope.

Delivered in this package:

- accepts the Technical Hardening playtest result as OK and resolves `DMOB-D074` toward a narrow Bosque/menu polish package;
- moves one resource node out of collision risk and slightly reduces blocker collision areas for large trees/rocks;
- adds a ruleset test that keeps resource nodes clear of blockers and unsafe borders;
- adds nearby/active resource visual states, pickup markers, blocking-vs-decor visual distinction, campfire glow and nonblocking landmarks;
- improves HUD, inventory sheet, deposit/craft availability, pocket-full feedback, session/resync copy and visit summaries with player-facing names;
- keeps `Bosque` as the direct Openworld entry and keeps Openworld as a contained Internal Alpha slice, not approval for enemies, NPCs, quests, city or a continuous world.

Publication evidence for this package:

- Export regenerated APK, PC ZIP and Web artifacts from the merged Bosque code.
- Public Storage upload, Cloudflare Pages production branch `main`, release manifest deploy and RemoteReadOnly passed.
- Cloudflare Pages preview evidence: `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`.
- Remote Web launch smoke on preview loaded the game in `3533 ms`, matched release root and asset root, and reported no runtime errors.
- Stable Portal/Web remain protected by Cloudflare Access and passed RemoteReadOnly with Access marked expected.
- Android APK uses `debug_fallback`, accepted for closed Internal Alpha only.

Artifact hashes:

- Android APK SHA256: `4455af96d285a2ac3f5d8268d5d044ff4933eb10303dfbe113d3aba0811efaa5`
- PC Windows ZIP SHA256: `bd2ce982a4bba80eedbd8ff165537dbe4bdc49183139d6e5b8e7e598cff85f93`
- Web Index SHA256: `75b9d6e532b78dbe9a6cdb8caee3a6794ab2ae0c4e2aaf8e7ac619022a20d11f`

## Current Gate

The next product step is human playtest of the published Bosque v3 UX/Feel package before opening Arena tuning or broader Openworld expansion.

Playtest focus:

1. Confirm resource node readability and collision comfort in Bosque.
2. Confirm collect, pocket-full, deposit, craft, fogueira and visit summary feedback.
3. Confirm session/resync messages are readable and do not look technical.
4. Confirm main menu, Bosque entry and Arena tutorial still read correctly after the package.
5. Decide whether the next package is an Arena PVE/tuning pass or another narrow Bosque/menu polish pass.

## Live Boundaries

- DraxosMobile is a PVE Arena-first async autobattler with Refugio/Base, later PVP and social systems.
- Openworld/Bosque is an approved Internal Alpha slice, not approval for a continuous open world expansion.
- Arena PVE remains the living product direction for early game, governed by `docs/pve-arena-initial-direction.md` and `docs/pve-arena-v1.md`.
- Foundation Hardening V2 remains the previous hardening/live-doc enforcement baseline.
- Hardening Platform V1 remains the previous mode-platform baseline.
- Remote Lab Runner remains preserved for Battle Lab and Progression Lab in Web export, without service role in client/export and without economy/ranking/save-progress mutation.
- Current names, spells, weapons, economy values, Battle Pass, battle flavor and visual identity are mock/substance unless a live doc promotes them.

## Validation Snapshot

Bosque v3 local validation before publication:

- `git diff --check`: PASS.
- `npx -y deno test --allow-read server/tests/openworld_ruleset_definition_test.ts`: PASS, 5 tests.
- `smoke_openworld_forest.gd`: PASS.
- `smoke_modes_visual_layout.gd`: PASS.
- GUT client suite: PASS, 226 tests.
- `validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ModePlatform -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile FullLocal -NoProjectWrites`: BLOCKED only in `DatabaseLocal` because Docker Desktop/Supabase local was unavailable; DocsOnly, ServerQuick, ClientQuick, ModePlatform and ReleaseDryRun stages passed before that blocker.

Bosque v3 publication validation:

- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -PublicDownloads -ConfirmRemoteMutation`: PASS after one retry of a transient Supabase CLI 502.
- `build_cloudflare_pages_package.ps1`: PASS.
- `wrangler pages deploy ... --branch main`: PASS, preview `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45 -RemoteWebUrl https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS.

Historical validation logs and package-by-package publication evidence belong in `implementation/tracks/`, `docs/*-report.md`, Kanban Done cards or handoffs, not in this decision snapshot.

## Read Next

1. `AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `docs/documentation-index.md`
4. `docs/multi-agent-workflow.md`
5. `docs/pve-arena-initial-direction.md`
6. `docs/product-vision.md`
7. `docs/product-brief.md`
8. `docs/design-pending.md`
