# DraxosMobile - Current Status

- Last updated: `2026-06-06`
- Project: `draxos-mobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `Internal Alpha`
- Active stage: `Arena PVE Menu Flow Simplification v1`
- Active stage status: `ARENA_PVE_MENU_FLOW_SIMPLIFICATION_V1_PUBLISHED_INTERNAL_ALPHA`
- Build channel: `internal_alpha`
- Version: `0.0.5-alpha.0`
- Version code: `5`

## Current Truth

- Latest published remote package: `Arena PVE Menu Flow Simplification v1`.
- Release root: `internal-alpha/v0-arena-pve-menu-flow-simplification-v1-20260606-5d03a68`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Latest deployment evidence: `https://fdf44707.draxos-mobile-internal-alpha.pages.dev`
- Source state: `main` after merging and publishing Arena PVE Menu Flow Simplification v1, preserving Bosque Offline-First Checkpoint v1, Bosque Sync Responsiveness v1, Arena/Bosque Visible V2, Arena/Bosque Regression Hotfix, Arena PVE Season 1 Loop v1, Arena Duel Flow Hotfix, Track 23 Arena PVE update recovery and later trunk merges.
- Published Arena PVE Menu Flow Simplification v1: bumps APK/manifest to `0.0.5-alpha.0` / version code `5`, reorders the Arena PVE menus around the player's decision flow, keeps a single recommended start CTA, keeps Preparacao visible before start and behavior controls between fights, and preserves all existing Arena functions and server-authoritative rewards.
- Previous Openworld/Bosque policy package: `Bosque Offline-First Checkpoint v1`
- Previous Openworld/Bosque policy release root: `internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22`
- Previous Openworld/Bosque policy preview: `https://fa84e109.draxos-mobile-internal-alpha.pages.dev`
- Previous Openworld/Bosque policy: applies remote migration `202606060001_openworld_bosque_checkpoint_v1.sql`, makes Bosque movement/collection/pocket/chest/craft client-owned during gameplay, persists local visit state, saves compact checkpoints in the background and keeps completion/reward server-authoritative through the last accepted checkpoint.
- Previous Bosque sync package: `Bosque Sync Responsiveness v1`
- Previous Bosque sync release root: `internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95`
- Previous Bosque sync preview: `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`
- Previous visible package: `Arena/Bosque Visible V2`
- Previous visible release root: `internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5`
- Previous visible preview: `https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev`
- Previous visible package: bumps APK/manifest to `0.0.2-alpha.0` / version code `2`, forces old build update, and restores Preparacao even when Arena selection is blocked by an active or stuck attempt.
- Previous visibility hotfix package: `Arena/Bosque Regression Hotfix`
- Previous visibility hotfix release root: `internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f`
- Previous visibility hotfix preview: `https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev`
- Previous visibility hotfix: restored Preparacao before Arena start, during active attempts and on pending buff choice, and restored Bosque deposit/craft visible feedback plus pending-event flush before leaving an integrated session.
- Runtime config hotfix: `release/config` now uses `config_version = track23-online-actions-hotfix` and allows online server-authoritative progression actions (`read_only: false`, `mutable_gameplay_state: true`) while preserving the conservative client fallback when remote config is unavailable.
- Current published implementation: `Arena PVE Menu Flow Simplification v1` is published on `main`. It simplifies menu hierarchy and CTA order without changing Arena content/tuning/backend flow. Bosque Offline-First Checkpoint v1 remains the current Openworld policy package, Bosque Sync Responsiveness v1 remains the previous Bosque sync package and Arena/Bosque Visible V2 remains the previous visible package.
- Human playtest initial result: Bosque Offline-First Checkpoint v1 was reported successful on 2026-06-06; the visible Bosque update appears healthy so far. The Openworld working policy is now documented as client-owned active play with server-owned checkpoints/rewards.
- Previous Arena Season 1 package: `Arena PVE Season 1 Loop v1` groups Season 1 arenas/difficulties, shows S1 progress/reward previews, adds contextual next-step summary, opens pending buff choice without auto-selecting a buff, and preserves `buff_offer` in remote `/arena/pve/state` active attempts after update/reopen.
- Previous Arena Season 1 release root: `internal-alpha/v0-arena-pve-season1-loop-v1-20260605-c8baf32`
- Previous Arena Season 1 preview: `https://d7333659.draxos-mobile-internal-alpha.pages.dev`
- Previous source hotfix: `Arena Duel Flow Hotfix` keeps Preparacao/behavior inside the active-duel menu, removes the detached `Ajustar comportamento` CTA, and treats a server step with `selected_buff` as resolved so the next active menu returns to `Resolver duelo` instead of showing `Escolher buff` again.
- Previous duel-flow hotfix release root: `internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174`
- Previous duel-flow hotfix preview: `https://0536635b.draxos-mobile-internal-alpha.pages.dev`
- Previous Arena package: `Arena PVE First Real Run + Update Recovery`
- Previous Arena release root: `internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a`
- Previous Arena preview: `https://2c020d09.draxos-mobile-internal-alpha.pages.dev`
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

## Current Published Package

Arena PVE Menu Flow Simplification v1 is published as the current Internal Alpha package. It preserves Bosque Offline-First Checkpoint v1 as the Openworld policy baseline and focuses only on Arena PVE menu clarity: fewer redundant steps, clearer decision order and better placement of Preparacao/behavior controls.

Delivered:

- bumps in-app, export and manifest versioning to `0.0.5-alpha.0` / version code `5`;
- forces clients on version code `4` or older to update through the remote manifest instead of silently continuing the old APK;
- reorders Arena selection to context -> Season 1 progress -> recommended challenge -> Preparacao -> other arenas -> back;
- replaces duplicate start actions with one CTA, `Iniciar desafio recomendado`;
- shows active attempt recovery before secondary behavior controls when an attempt exists;
- shows `Resolver duelo` or `Escolher buff` before Preparacao/behavior inside active Arena flow;
- shows buff cards before behavior controls during buff choice;
- preserves all Season 1 arena/difficulty data, active-attempt recovery, locked loadout, buff flow and server-authoritative rewards;
- preserves Arena Preparacao before start, in active/stuck attempts, in the duel menu and in buff choice;
- preserves Arena PVE Season 1 Loop v1, Arena Duel Flow Hotfix, Arena PVE First Real Run + Update Recovery, Bosque v3 UX/Feel, Technical Hardening, Openworld Main Menu Sync, Foundation Hardening V2, Hardening Platform V1 and Remote Lab Runner.

Publication evidence:

- Export regenerated APK, PC ZIP and Web artifacts from current `main`.
- Public Storage upload, Cloudflare Pages production branch `main`, release manifest deploy and Edge Function `release` deploy passed.
- Cloudflare Pages preview evidence: `https://fdf44707.draxos-mobile-internal-alpha.pages.dev`.
- Remote Web launch smoke on preview loaded the game, matched release root and asset root, and reported no runtime errors.
- Remote artifact smoke passed for manifest, APK, ZIP, Portal and Web after local manifest expectations were updated to version code `5`; stable Portal/Web remain protected by Cloudflare Access.
- Remote read-only release/CORS smoke passed.
- Android APK uses `debug_fallback`, accepted for closed Internal Alpha only.
- `release/config` remains on `track23-online-actions-hotfix`, so online progression actions are not paused by remote config.

Artifact hashes:

- Android APK SHA256: `960c1ca2193a5d5f013437058f7119ac1a31bcc0f34b52a287b6435b0d794d7a`
- PC Windows ZIP SHA256: `bacd5d421206299a806c629a15a938402f7330c936a72ceefcf410cc75d08fd6`
- Web Index SHA256: `b39c432610b029560e6fd6672d1ca964f811f46c1dff2e5bd92e9865f35d5300`

## Bosque Offline-First Checkpoint v1 Details

Bosque Offline-First Checkpoint v1 is published remotely and should be the active Bosque playtest baseline.

Delivered:

- adds `/modes/session/checkpoint`, `checkpoint` audit event compatibility and mirrored checkpoint migrations in `server/schema` and `supabase/migrations`;
- adds SQL validation for idempotent checkpoint writes, ruleset match, active session, unique/valid nodes, pocket/chest capacity, craft derivability and atomic snapshot revision update;
- wraps Bosque completion so reward requires an accepted checkpoint;
- preserves legacy `collect_batch`, `collect_complete`, `deposit_all` and `craft` for older builds but stops using microevents as the new Bosque client path;
- persists Bosque local state in `SessionStore.openworld_local_state` and boots the world from compatible local cache/session before the first playable frame;
- stops sending `move_heartbeat` as revisioned mutation and prevents late ACK/resync from resetting player position, active collection, pocket, chest, upgrades, crafted structures or pending nodes during active gameplay;
- keeps collection, deposit and craft immediate locally while checkpoint save runs in the background;
- keeps `Voltar` as a preserve-and-background-save action instead of a sync blocker;
- keeps `Encerrar visita` blocked until final checkpoint is accepted, preserving server-authoritative reward and ledger;
- preserves Arena Preparacao before start, in active/stuck attempts, in the duel menu and in buff choice.

Validation:

- `deno test --allow-read server/tests/modes_platform_schema_test.ts server/tests/modes_domain_test.ts server/tests/openworld_ruleset_definition_test.ts`: PASS, 34 tests.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/client/test_openworld_integrated_session_bridge.gd,res://tests/client/test_openworld_mode_dev.gd,res://tests/client/test_openworld_screen_foundation.gd -gexit`: PASS, 236 tests. GUT still reports known teardown orphan/ObjectDB warnings.
- `git diff --check`: PASS.
- `supabase db push --linked --yes`: PASS after migration rename fix.
- `supabase functions deploy modes`: PASS.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -ReleaseRoot internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22 -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22 -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: PASS, preview `https://fa84e109.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22 -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22 -RemoteWebUrl https://fa84e109.draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS after docs/test guard refresh.

## Previous Bosque Sync Responsiveness v1 Details

Bosque Sync Responsiveness v1 is preserved as the previous Bosque sync baseline.

Delivered:

- adds `collect_batch` to `/modes/session/event` and mirrored migrations in `server/schema` and `supabase/migrations`;
- keeps legacy `collect_complete` compatible for older packages;
- coalesces multiple `collect_complete` client actions into one `collect_batch` request before `deposit_all`, `craft`, `complete` or exit flush;
- applies resource collection to the local pocket immediately and marks the node pending until server ACK/resync;
- allows `Depositar` while collection sync is pending when the local pocket has items and the player is near the chest;
- applies deposit/craft locally and queues them after pending collection batch without requiring an empty queue;
- prevents intermediate collection/deposit ACK patches from rolling back later local optimistic deposit/craft state;
- keeps `Encerrar visita` blocked until the server-authoritative snapshot is fully synced;
- changes `Voltar` to preserve the session and trigger a short background flush instead of trapping the player behind pending sync;
- updates Bosque HUD/tooltips/status so pending sync is shown as saving state, not as a normal deposit blocker;
- keeps Arena regression coverage for Preparacao and selected buff returning to `Resolver duelo`.

Validation:

- `deno test --allow-read server/tests/openworld_ruleset_definition_test.ts server/tests/modes_domain_test.ts`: PASS, 14 tests.
- `deno check server/functions/_shared/mode_domain.ts supabase/functions/_shared/mode_domain.ts server/functions/modes/mode_handler.ts supabase/functions/modes/mode_handler.ts`: PASS.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --import`: PASS for fresh worktree import.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/client/test_openworld_integrated_session_bridge.gd -gtest=res://tests/client/test_openworld_mode_dev.gd -gtest=res://tests/client/test_boot_mobile_ui.gd -gexit`: PASS, 238 tests / 3739 asserts. GUT still reports known teardown orphan/ObjectDB warnings.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`: PASS, 238 tests / 3739 asserts and content/catalog validation. GUT still reports known teardown orphan/ObjectDB warnings.
- `git diff --check`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun -RequireClean -NoProjectWrites`: PASS.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -ReleaseRoot internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95 -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95 -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: PASS, preview `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95 -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95 -RemoteWebUrl https://60e2d4be.draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS.

## Previous Visibility Hotfix Package

Arena/Bosque Regression Hotfix is the previous visibility hotfix package. It preserves Arena PVE Season 1 Loop v1 and fixes the two regressions found in playtest: Preparacao disappearing from Arena PVE surfaces and Bosque integrated actions not giving/saving expected session feedback.

Delivered:

- restores `Preparacao` before Arena start, inside active attempts and on pending buff choice between fights;
- keeps behavior-only preparation available after an Arena attempt starts, without unlocking the locked loadout;
- applies Bosque deposit/craft locally while the server-authoritative event is pending;
- blocks duplicate deposit/craft events while the Bosque is still saving;
- waits for pending Bosque event flush before closing the integrated session;
- preserves Arena PVE Season 1 Loop v1, Arena Duel Flow Hotfix, Arena PVE First Real Run + Update Recovery, Bosque v3 UX/Feel, Technical Hardening, Openworld Main Menu Sync, Foundation Hardening V2, Hardening Platform V1 and Remote Lab Runner.

Publication evidence:

- Export regenerated APK, PC ZIP and Web artifacts from current `main`.
- Public Storage upload, Cloudflare Pages production branch `main`, release manifest deploy and Edge Function `release` deploy passed.
- Cloudflare Pages preview evidence: `https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev`.
- Remote Web launch smoke on preview loaded the game in `3770 ms`, matched release root and asset root, and reported no runtime errors.
- Remote artifact smoke passed for manifest, APK, ZIP, Portal and Web; stable Portal/Web remain protected by Cloudflare Access.
- Remote read-only release/CORS smoke passed.
- Android APK uses `debug_fallback`, accepted for closed Internal Alpha only.
- `release/config` remains on `track23-online-actions-hotfix`, so online progression actions are not paused by remote config.

Artifact hashes:

- Android APK SHA256: `82b5476504e559ec72b83caac1c6fd82beea7cf35562e4bb0ab49bf81bc89138`
- PC Windows ZIP SHA256: `54263a71119e3d121ce668f343792da069e73ffc43aac24facfeb8e1da6f9417`
- Web Index SHA256: `6a1525cd66f95d1ab8f20a781c0c5039813af1ce8cb75a1081ff8f0c6b7dce8a`

## Previous Published Package

Arena PVE Season 1 Loop v1 is the previous Internal Alpha package. It builds on the accepted Arena Duel Flow Hotfix playtest and moves the next Arena expansion from "functional flow" to "readable Season 1 loop".

Delivered:

- groups Arena selection by arena and difficulty with `ArenaSeason1ProgressPanel`, `ArenaSeason1Group_*` and `ArenaSeason1NextStepPanel`;
- shows Season 1 progress, next recommended challenge, locked reasons and reward preview per tier;
- keeps reward preview as informational only; final reward remains server-authoritative on the last `/arena/pve/duel/request`;
- changes active pending-buff CTA to navigate to buff choice through resume instead of auto-selecting the first buff;
- aligns legacy first-real fallback to `s1_d00_intro` + tier `0`;
- enriches `/arena/pve/state` and claim deltas with active attempt `latest_step`, `last_step`, `state = "awaiting_buff"` and `buff_offer` when a pending buff exists;
- extends remote Arena smoke to tutorial, claim, unlock of first real 3-duel run, active-start blocker, buff selection between duels and final claim;
- preserves Bosque v3 UX/Feel, Technical Hardening, Openworld Main Menu Sync, Foundation Hardening V2, Hardening Platform V1, Remote Lab Runner and previous Arena packages.

Publication evidence:

- Export regenerated APK, PC ZIP and Web artifacts from current `main`.
- Public Storage upload, Cloudflare Pages production branch `main`, release manifest deploy and RemoteReadOnly passed.
- Supabase Edge Function `arena` was deployed before remote Arena smoke.
- Cloudflare Pages preview evidence: `https://d7333659.draxos-mobile-internal-alpha.pages.dev`.
- Remote Web launch smoke on preview loaded the game in `6361 ms`, matched release root and asset root, and reported no runtime errors.
- Remote Arena smoke with email auth and `DRAXOS_REMOTE_ARENA_SMOKE=1` passed tutorial, first real 3-duel run, active-start blocker, buff selection and final claim.
- Stable Portal/Web remain protected by Cloudflare Access and passed RemoteReadOnly with Access marked expected.
- Android APK uses `debug_fallback`, accepted for closed Internal Alpha only.
- `release/config` remains on `track23-online-actions-hotfix`, so online progression actions are not paused by remote config.

Artifact hashes:

- Android APK SHA256: `401834de0f7872233f46bbbf52aae5d7fc4bc560e527d32aaa52c3a0b74fb27b`
- PC Windows ZIP SHA256: `9597c82368d233263075fb87688a1ed4325e4dc6566dc8eebf11bcc836cf4a4a`
- Web Index SHA256: `09aa3cbdac38dddadfa177f09759dd0cd5ce00ee84b0260d59459138690bff98`

## Earlier Published Package

Arena Duel Flow Hotfix is the previous Internal Alpha package. It preserves Arena PVE First Real Run + Update Recovery, then fixes the active-duel menu so Preparacao/behavior is available inside the duel flow and a victory buff already selected does not loop the player back into `Escolher buff`.

Delivered in this package:

- keeps tutorial Arena as 1 duel and the first real Arena as 3 duels with buff choices between wins;
- adds `Retomar tentativa`, `Abandonar tentativa` and `Encerrar tentativa antiga` actions in the Arena shell;
- blocks new Arena starts locally while an active attempt exists, pushing the player to resume or abandon first;
- routes abandon through `/arena/pve/abandon` with `request_id/request_hash`;
- treats incompatible or malformed active attempts as recovery state instead of trapping the player;
- embeds Preparacao/behavior controls in the active-duel menu instead of a detached `Ajustar comportamento` action;
- treats server steps with `selected_buff` as resolved so the next active menu returns to `Resolver duelo`;
- preserves server-authoritative rewards: abandon grants no completion reward;
- keeps Bosque v3 UX/Feel, Technical Hardening, Openworld Main Menu Sync, Foundation Hardening V2, Hardening Platform V1, Remote Lab Runner and the Arena/Lab baselines intact.

Publication evidence:

- Export regenerated APK, PC ZIP and Web artifacts from current `main`.
- Public Storage upload, Cloudflare Pages production branch `main`, release manifest deploy and RemoteReadOnly passed.
- Cloudflare Pages preview evidence: `https://0536635b.draxos-mobile-internal-alpha.pages.dev`.
- Remote Web launch smoke on preview loaded the game in `3479 ms`, matched release root and asset root, and reported no runtime errors.
- Stable Portal/Web remain protected by Cloudflare Access and passed RemoteReadOnly with Access marked expected.
- Android APK uses `debug_fallback`, accepted for closed Internal Alpha only.
- `release/config` remains on `track23-online-actions-hotfix`, so online progression actions are not paused by remote config.

Artifact hashes:

- Android APK SHA256: `8565862ba070af58e14d7135077f59c31ca4927c4a23d1b1f79ae968a4dca814`
- PC Windows ZIP SHA256: `d3d01f17950c2e2cb8cbd34875b86f4ae767864e366114264a5516d9644d127d`
- Web Index SHA256: `e9023d89326b54ae55fd2a55b4a85424124bd25b99d1679f7096f98252bd1dfa`

## Current Gate

The next operational step is human playtest of Arena PVE Menu Flow Simplification v1, especially the Arena selection order, active attempt recovery, between-duel behavior controls and buff-choice menu. Do not reopen server-driven microaction sync for Openworld unless a new decision pack explicitly overrides the current client-owned play/server-owned rewards policy.

Decision focus:

1. Choose whether the next DraxosMobile package is focused Openworld/Bosque tuning, Arena PVE follow-up or another explicitly scoped polish pass.
2. If Openworld is selected, start from `docs/minigames/openworld.md` and `docs/minigames/openworld-decision-pack.md`.
3. Preserve active Bosque runtime as local/offline-first; server authority remains checkpoint, completion, reward, caps, ledger and audit.
4. Keep Arena regressions in the manual smoke list: Preparacao visible before start/in active attempts/buff choice, and selected victory buff returns to `Resolver duelo`.

## Live Boundaries

- DraxosMobile is a PVE Arena-first async autobattler with Refugio/Base, later PVP and social systems.
- Openworld/Bosque is an approved Internal Alpha slice, not approval for a continuous open world expansion.
- Arena PVE remains the living product direction for early game, governed by `docs/pve-arena-initial-direction.md` and `docs/pve-arena-v1.md`.
- Foundation Hardening V2 remains the previous hardening/live-doc enforcement baseline.
- Hardening Platform V1 remains the previous mode-platform baseline.
- Remote Lab Runner remains preserved for Battle Lab and Progression Lab in Web export, without service role in client/export and without economy/ranking/save-progress mutation.
- Current names, spells, weapons, economy values, Battle Pass, battle flavor and visual identity are mock/substance unless a live doc promotes them.

## Validation Snapshot

Bosque Sync Responsiveness v1 publication validation:

- `deno test --allow-read server/tests/openworld_ruleset_definition_test.ts server/tests/modes_domain_test.ts`: PASS, 14 tests.
- `deno check server/functions/_shared/mode_domain.ts supabase/functions/_shared/mode_domain.ts server/functions/modes/mode_handler.ts supabase/functions/modes/mode_handler.ts`: PASS.
- GUT client suite: PASS, 238 tests and 3739 asserts.
- `validate.gd`: PASS, 238 tests and 3739 asserts.
- `validate_foundation.ps1 -Profile ReleaseDryRun -RequireClean -NoProjectWrites`: PASS.
- `supabase db push --linked --dry-run`: PASS, pending only `202606050003_openworld_bosque_collect_batch_v1.sql`.
- `supabase db push --linked --yes`: PASS, remote migration applied.
- `supabase migration list --linked`: PASS, local/remote aligned through `202606050003`.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -ReleaseRoot internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95 -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95 -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl <versioned-web-asset-root>`: PASS.
- `wrangler pages deploy ... --branch main`: PASS, preview `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95 -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95 -RemoteWebUrl https://60e2d4be.draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS, Web loaded in `4246 ms`.

Arena/Bosque Visible V2 publication validation:

- `validate.gd`: PASS, 236 tests and 3716 asserts.
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: PASS.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -ReleaseRoot internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5 -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5 -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl <versioned-web-asset-root>`: PASS.
- `wrangler pages deploy ... --branch main`: PASS, preview `https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5 -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `release_artifacts_remote_smoke.ts` with env loaded from `.env.internal-alpha.local`: PASS.
- `smoke_web_launch_remote.ps1 -WebUrl https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev/web/index.html -ExpectedReleaseRoot internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5 -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS, loaded in `12442 ms`.
- `internal_alpha_remote_smoke.ts` read-only release/CORS smoke with env loaded from `.env.internal-alpha.local`: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5 -RemoteWebUrl https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS with env loaded from `.env.internal-alpha.local`; docs/release guards, remote artifacts smoke, read-only release/CORS smoke and Web launch smoke passed, with Web loaded in `3542 ms`.

Arena/Bosque Regression Hotfix local validation:

- `git diff --check`: PASS.
- `tools/validate.gd`: PASS, 236 tests and 3710 asserts.
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS, including GUT client, runtime config smoke, foundation hardening smoke, responsive layout smoke, modes visual layout smoke and export preset smoke.

Arena PVE Season 1 Loop v1 publication validation:

- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -ReleaseRoot internal-alpha/v0-arena-pve-season1-loop-v1-20260605-c8baf32`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-arena-pve-season1-loop-v1-20260605-c8baf32 -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl <versioned-web-asset-root>`: PASS.
- `wrangler pages deploy ... --branch main`: PASS, preview `https://d7333659.draxos-mobile-internal-alpha.pages.dev`.
- `supabase functions deploy arena --project-ref armxgipvnbbshzqawklw`: PASS.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-arena-pve-season1-loop-v1-20260605-c8baf32 -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-arena-pve-season1-loop-v1-20260605-c8baf32 -RemoteWebUrl https://d7333659.draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS.
- `DRAXOS_REMOTE_EMAIL_AUTH_SMOKE=1 DRAXOS_REMOTE_ARENA_SMOKE=1 DRAXOS_REMOTE_RELEASE_SMOKE=1 deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts`: PASS.

Arena PVE Season 1 Loop v1 local validation:

- `deno test --allow-read server/tests/arena_loop_unlock_friction_test.ts server/tests/pve_arena_catalog_test.ts`: PASS, 9 tests.
- `deno check server/tests/internal_alpha_remote_smoke.ts`: PASS.
- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- GUT client suite: PASS, 234 tests and 3690 asserts.
- `tools/validate.gd`: PASS, 234 tests and 3690 asserts.

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

Arena Duel Flow local hotfix validation:

- `git diff --check`: PASS.
- GUT client suite: PASS, 232 tests and 3666 asserts.
- `tools/validate.gd`: PASS, 232 tests and 3666 asserts.
- `tools/smoke_responsive_layout.gd`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick -RequireClean:$false`: PASS.
- `deno run --allow-net --allow-env server/tests/runtime_config_smoke.ts` against remote Supabase: PASS.

Arena Duel Flow publication validation:

- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: PASS.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174 -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl <versioned-web-asset-root>`: PASS.
- `wrangler pages deploy ... --branch main`: PASS, preview `https://0536635b.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174 -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174 -RemoteWebUrl https://0536635b.draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS after loading local read-only Supabase URL and publishable key from `.env.internal-alpha.local`.

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
