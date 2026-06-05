# DraxosMobile - Current Status

- Last updated: `2026-06-05`
- Project: `draxos-mobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `Internal Alpha`
- Active stage: `Technical Hardening Publication`
- Active stage status: `TECHNICAL_HARDENING_PUBLISHED_INTERNAL_ALPHA`
- Build channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`

## Current Truth

- Latest published remote package: `Technical Hardening`
- Release root: `internal-alpha/v0-technical-hardening-20260605-8e54a1f`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Latest deployment evidence: `https://2fe9393e.draxos-mobile-internal-alpha.pages.dev`
- Source state: `master` after merging Track 22 Technical Hardening.
- Previous content package: `Openworld Main Menu Sync`
- Previous content release root: `internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`
- Previous content verified preview: `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`
- Previous hardening baseline: `Foundation Hardening V2`
- Previous hardening release root: `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`
- Previous hardening preview: `https://ca946749.draxos-mobile-internal-alpha.pages.dev`
- Hardening baseline marker: `Track 13 - Foundation Validation And Release Safety` (`TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`)
- Agent baseline marker: `Track 14 - Agent Operations Foundation` (`TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`)
- Arena contract context: `Track 18 - PVE Arena Initial`, Track 20 Season 1 Arena Calibration and Track 21 Arena Loop Unlock/Friction are preserved Arena/Autobattler context, not the current platform baseline.
- Technical context: Track 16 Behavior And Potion Crafting is existing alpha substance summarized in `docs/behavior-potion-crafting-v1.md`, not the current product focus.
- Latest hardening package: `Track 22 - Technical Hardening`, merged to `master` and published to Internal Alpha.

## Published Package

Technical Hardening published the current Internal Alpha package. It preserves the Openworld Main Menu Sync player-facing content and adds the hardening package:

- applies remote migrations `202606050001_arena_reward_profiles_v1.sql` and `202606050002_account_reset_request_hash_v1.sql`;
- redeploys Supabase Edge Functions after the shared-auth, idempotency and release fallback updates;
- keeps the Openworld migration `202606040002_openworld_bosque_collection_sync_v1.sql` from the previous content package;
- accepts all 26 active Bosque ruleset resource nodes in the backend;
- persists `player_position` only through `move_heartbeat`;
- sanitizes event ACK patches so ordinary event responses do not roll back active local position;
- preserves local player position during active resync of the same session;
- removes player-facing Mode Hub, collect-all, direct Energia and dev Openworld shortcuts;
- keeps `Bosque` as the direct Openworld entry;
- moves Preparacao into Arena PVE and keeps Energia purchase inside Loja;
- keeps the production Pages domain as the official URL and the hash deployment only as evidence;
- keeps `Modes Ops` out of the Godot client while Battle Lab and Progression Lab remain available;
- migrates mutable/lab/release endpoints broadly to shared `verifiedAuthContext`;
- promotes account reset to request-hash idempotency and Arena rewards to DB-side reward profiles;
- reduces large client hotspots with extract-only helper modules.

Publication evidence preserved for this package:

- `supabase db push`, `supabase functions deploy`, export, Storage upload, Cloudflare Pages production branch `main`, remote manifest, RemoteReadOnly and remote Web launch smoke all passed during publication.
- Remote Web smoke on preview evidence loaded the game in `6042 ms`, matched release root and reported no runtime errors; the validation rerun loaded it in `3302 ms`.
- Stable Portal/Web remain protected by Cloudflare Access and pass RemoteReadOnly with Access marked expected.
- Android APK uses `debug_fallback`, accepted for closed Internal Alpha only.

## Current Gate

The next product step remains human review/playtest of the published Technical Hardening package before any new expansion package.

Playtest focus:

1. Confirm Bosque collect/deposit/resync after collecting v2 nodes.
2. Confirm simplified main menu path into Bosque, Arena PVE and Loja.
3. Confirm tutorial Arena and first real Arena loop still read correctly.
4. Record whether the next package should be a hotfix or an Arena PVE/tuning package. This decision is not fixed yet.

## Latest Local Technical Hardening Work

Track 22 Technical Hardening is merged to `master` and published as Internal Alpha.

Delivered locally:

- live docs compacted and the decision snapshot kept short;
- `Modes Ops` removed from the Godot client while Battle Lab and Progression Lab remain available;
- `validate_foundation.ps1` kept non-publishing; remote mutation remains explicit through `publish_internal_alpha.ps1 -ReleaseRoot ... -ConfirmRemoteMutation`;
- mutable Edge endpoints migrated broadly to shared `verifiedAuthContext`, including `content`, `lab-runner`, gameplay domains, `modes` and `release`;
- account save reset promoted to request-hash idempotent reset v1;
- Arena reward authority moved DB-side through explicit reward profiles;
- large client hotspots reduced with extract-only helpers for battle replay, account forms, preparation actions, Base and Arena surfaces.

No keystore work, tuning expansion, PVP, new content, new weapons, new spells, new potions or economy pass is included in this hardening package.

## Live Boundaries

- DraxosMobile is a PVE Arena-first async autobattler with Refugio/Base, later PVP and social systems.
- Openworld/Bosque is an approved Internal Alpha slice, not approval for a continuous open world expansion.
- Arena PVE remains the living product direction for early game, governed by `docs/pve-arena-initial-direction.md` and `docs/pve-arena-v1.md`.
- Foundation Hardening V2 remains the previous hardening/live-doc enforcement baseline.
- Hardening Platform V1 remains the previous mode-platform baseline.
- Remote Lab Runner remains preserved for Battle Lab and Progression Lab in Web export, without service role in client/export and without economy/ranking/save-progress mutation.
- Current names, spells, weapons, economy values, Battle Pass, battle flavor and visual identity are mock/substance unless a live doc promotes them.

## Validation Snapshot

Latest Track 22 validation before publication:

- `validate_foundation.ps1 -Profile FullLocal -NoProjectWrites`: PASS on merged `master`.
- `validate_foundation.ps1 -Profile DatabaseLocal -NoProjectWrites`: PASS after starting Docker Desktop, local Supabase and local Edge Functions.
- `smoke_web_launch_remote.ps1 -WebUrl https://2fe9393e.draxos-mobile-internal-alpha.pages.dev/web/index.html -ExpectedReleaseRoot internal-alpha/v0-technical-hardening-20260605-8e54a1f`: PASS.

Latest validation after release fallback/docs update and Edge redeploy:

- `git diff --check`: PASS.
- `npx -y deno check server/functions/release/index.ts supabase/functions/release/index.ts server/tests/release_manifest_smoke.ts server/tests/release_artifacts_remote_smoke.ts server/tests/release_auth_contract_test.ts`: PASS.
- `validate_foundation.ps1 -Profile DocsOnly -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-technical-hardening-20260605-8e54a1f -RemoteWebUrl https://draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS.
- `validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`: PASS (`112` foundation tests and `19` PVE Arena tests).

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
