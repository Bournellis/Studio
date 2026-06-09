# DraxosMobile - Current Status

- Last updated: `2026-06-09`
- Project: `draxos-mobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `Internal Alpha`
- Active stage: `Bosque Overlay Navigation Hotfix v1`
- Active stage status: `BOSQUE_OVERLAY_NAVIGATION_HOTFIX_V1_PUBLISHED_INTERNAL_ALPHA`
- Local follow-up stage: `Bosque Overlay Navigation Hotfix v1`
- Local follow-up status: none; the navigation hotfix is already published.
- Build channel: `internal_alpha`
- Version: `0.0.18-alpha.0`
- Version code: `18`
- Minimum supported version code: `13`

## Current Truth

- Latest published remote package: `Bosque Overlay Navigation Hotfix v1`.

- Release root: `internal-alpha/v0-bosque-overlay-navigation-hotfix-v1-20260609-9b93e5d`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Deployment evidence: `https://92cc0579.draxos-mobile-internal-alpha.pages.dev`
- Source state: release root was generated from implementation commit `9b93e5d`; publication/status closure is recorded in the Kanban Done handoff.
- Published package: bumps APK/manifest to `0.0.18-alpha.0` / version code `18`, keeps `minimum_supported_version_code` at `13`, redeploys `release`, publishes the overlay navigation hotfix over the live Bosque, and keeps the Bosque visible but input-paused while menus/Arena are open.
- Remote SQL already applied: `202606080001_openworld_bosque_persistence_rebase_v1.sql` and `202606080002_openworld_bosque_jsonb_object_length_hotfix_v1.sql`.
- Remote functions: `release` redeployed for Bosque Overlay Navigation Hotfix v1; `arena` remains on Arena PVE Bonus Visual v1; `modes` remains on the operations-v2 backend from the previous Bosque packages.

Initial human playtest of Bosque Bootstrap Authority v1 was reported OK by Fabio on `2026-06-09`: everything tested at that point appeared to work. `DMOB-D076` was resolved by choosing the diegetic launcher foundation, `DMOB-D077` published it, `DMOB-D078` published the persistent overlay shell, and `Bosque Overlay Navigation Hotfix v1` now publishes the follow-up navigation fix for `Fechar`, `Voltar` and Esc over that overlay model. The next operational step is focused human playtest of this newly published overlay package. If future errors appear, they return to the normal bugfix flow.

## Operational Vs Product Direction

- Operational package: Bosque Overlay Navigation Hotfix v1 is current.
- Implementation stage: Bosque Overlay Navigation Hotfix v1 is now published as the current Internal Alpha package.
- Product direction: Arena PVE remains the first approved core, governed by `docs/pve-arena-initial-direction.md` and `docs/pve-arena-v1.md`.
- Bosque/Openworld status: approved integrated Internal Alpha slice with diegetic launcher and persistent overlay shell, not approval for broad continuous-open-world expansion.
- Do not open tuning, PVP, economy, content, weapons, spells, potions, final visuals, remote mutation or a new package without an explicit decision.

## Published Overlay Scope

`Bosque Overlay Navigation Hotfix v1` keeps the Bosque instantiated, visible and input-paused while launcher targets render as a responsive overlay, and is now published as the current Internal Alpha Web/APK package:

- preserves the `mode_shell` and active `openworld_forest_screen.gd` node while Shop/Base/Social/Profile and the Arena flow open above it;
- renders a shared overlay sheet over the Bosque, with a near-full-height mobile panel, desktop side panel, backdrop dimming and a separate overlay route stack;
- pauses Bosque input, movement, collection, launcher taps and joystick while the overlay is open, then restores focus without rebootstrap;
- keeps Arena Selection -> Active -> Replay -> Buff/Summary inside the overlay and blocks close/back during replay or critical mutation;
- routes `Voltar`, `ACTION_RETURN_REFUGE` and `open_mode_shell:openworld` back to the existing Bosque node instead of recreating the shell;
- preserves pending checkpoint behavior before opening overlay targets: flush when possible, keep pending ops and show an honest message when not.

This publication updates release metadata, manifest defaults, APK/Web artifacts, Cloudflare Pages and the `release` function only. It does not change Supabase schema, economy, rewards, tuning, content, broad Openworld scope or the Arena PVE product direction.

## Current Package Evidence

Delivered:

- keeps the Bosque scene alive behind Shop/Base/Social/Profile and Arena overlays;
- pauses Bosque input/collection/launcher interactions while overlays are open;
- routes overlay back/close through a dedicated stack before returning focus to the same `mode_shell`;
- runs Arena selection, active attempt, replay, buff choice and summary inside the overlay;
- blocks overlay close/back during replay or critical server mutation;
- aligns release/export scripts and remote smokes with version code `18`;
- preserves Arena PVE Bonus Visual v1, Bosque Node Cooldown ACK v1, resume/exit lifecycle, feel/spawn authority, persistence rebase and station-craft behavior.

Publication evidence:

- Cloudflare Pages preview evidence: `https://92cc0579.draxos-mobile-internal-alpha.pages.dev`.
- Direct preview Web launch smoke loaded the game in `3711 ms` during consolidated `RemoteReadOnly` validation, matched release root and reported no runtime errors.
- Remote manifest smoke, internal alpha release smoke and remote artifact smoke passed.
- Canonical Portal/Web are Cloudflare Access protected; preview Web launch validated the public Pages deployment.
- Android APK uses `debug_fallback`, accepted for closed Internal Alpha only.

Artifact hashes:

- Android APK SHA256: `80d30c54f315d2a0681374ae603a33d8c4cb19759b3bb3262752ccc7f06624d8`
- PC Windows ZIP SHA256: `4fa2fba1505d4dfe97e365923209b3ea76c7601a8e9f03da6bf2da8828357de0`
- Web Index SHA256: `33244df3094513af49d57b3b6f9bc32e755b66671926c92db9baaffc3905db55`

## Preserved Lineage

These packages are preserved history/context, not the current publication:

- Previous launcher package: `Bosque Diegetic Launcher Foundation v1`, release root `internal-alpha/v0-bosque-diegetic-launcher-foundation-v1-20260609-e55ed0c`, preview `https://56b58162.draxos-mobile-internal-alpha.pages.dev`, APK/manifest `0.0.16-alpha.0` / version code `16`.
- Previous overlay package: `Bosque Persistent Overlay Shell v1`, release root `internal-alpha/v0-bosque-persistent-overlay-shell-v1-20260609-d05081c`, preview `https://a53c1d27.draxos-mobile-internal-alpha.pages.dev`, APK/manifest `0.0.17-alpha.0` / version code `17`.
- Previous bootstrap package: `Bosque Bootstrap Authority v1`, release root `internal-alpha/v0-bosque-bootstrap-authority-v1-20260609-ba99e70`, preview `https://0123894f.draxos-mobile-internal-alpha.pages.dev`, APK/manifest `0.0.15-alpha.0` / version code `15`.
- Previous Arena package: `Arena PVE Bonus Visual v1`, release root `internal-alpha/v0-arena-pve-bonus-visual-v1-20260608-e281d63`, preview `https://6c8bf8e1.draxos-mobile-internal-alpha.pages.dev`, APK/manifest `0.0.14-alpha.0` / version code `14`.
- Previous Bosque package: `Bosque Node Cooldown ACK v1`, release root `internal-alpha/v0-bosque-node-cooldown-ack-v1-20260608-626b4ad`, preview `https://5cce952e.draxos-mobile-internal-alpha.pages.dev`, APK/manifest `0.0.13-alpha.0` / version code `13`.
- Previous resume/exit package: `Bosque Resume Exit Lifecycle v1`, release root `internal-alpha/v0-bosque-resume-exit-lifecycle-v1-20260608-9a0f7c0`, preview `https://39128c59.draxos-mobile-internal-alpha.pages.dev`, APK/manifest `0.0.12-alpha.0` / version code `12`.
- Previous feel/spawn package: `Bosque Feel & Spawn Authority v1`, release root `internal-alpha/v0-bosque-feel-spawn-authority-v1-20260608-70b79c3`, preview `https://16ac3cb7.draxos-mobile-internal-alpha.pages.dev`, APK/manifest `0.0.11-alpha.0` / version code `11`.
- Previous persistence/operations package: `Bosque Persistence Rebase v1`, release root `internal-alpha/v0-bosque-persistence-rebase-v1-20260608-bc23f74`, preview `https://0c0a8dcf.draxos-mobile-internal-alpha.pages.dev`, APK/manifest `0.0.10-alpha.0` / version code `10`.
- Previous session-lifecycle package: `Bosque Session Lifecycle & Durable Structures Hotfix v1`, release root `internal-alpha/v0-bosque-session-lifecycle-structures-hotfix-v1-20260607-c953b51`, preview `https://8ecac093.draxos-mobile-internal-alpha.pages.dev`, APK/manifest `0.0.9-alpha.0` / version code `9`.
- Previous local/account domain package: `Bosque World Hub Domain Separation v1`, release root `internal-alpha/v0-bosque-world-hub-domain-separation-v1-20260606-81ecf05`, preview `https://d1872010.draxos-mobile-internal-alpha.pages.dev`.
- Previous station-craft package: `Bosque Fogueira Potion Crafting v1`, release root `internal-alpha/v0-bosque-fogueira-potion-crafting-v1-20260606-cad6d2c`, preview `https://08d00f24.draxos-mobile-internal-alpha.pages.dev`.
- Previous durable Openworld package: `Bosque Durable Bau Mochila v1`, release root `internal-alpha/v0-bosque-durable-bau-mochila-v1-20260606-6e7ca6b`, preview `https://39198a35.draxos-mobile-internal-alpha.pages.dev`.
- Previous Arena menu package: `Arena PVE Menu Flow Simplification v1`, release root `internal-alpha/v0-arena-pve-menu-flow-simplification-v1-20260606-5d03a68`, preview `https://fdf44707.draxos-mobile-internal-alpha.pages.dev`.
- Previous Openworld/Bosque policy package: `Bosque Offline-First Checkpoint v1`, release root `internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22`, preview `https://fa84e109.draxos-mobile-internal-alpha.pages.dev`.
- Previous Bosque sync package: `Bosque Sync Responsiveness v1`, release root `internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95`, preview `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`.
- Previous visible package: `Arena/Bosque Visible V2`, release root `internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5`, preview `https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev`.
- Previous hardening baseline: `Foundation Hardening V2`, release root `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`.
- Earlier preserved packages: `Arena/Bosque Regression Hotfix`, `Arena PVE Season 1 Loop v1`, `Arena Duel Flow Hotfix`, `Arena PVE First Real Run + Update Recovery`, `Bosque v3 UX/Feel`, `Technical Hardening`, `Openworld Main Menu Sync`, `Hardening Platform V1` and `Remote Lab Runner`.

Track markers that remain active as guardrails:

- Hardening baseline marker: `Track 13 - Foundation Validation And Release Safety` (`TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`)
- Agent baseline marker: `Track 14 - Agent Operations Foundation` (`TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`)
- Arena context: Track 18 - PVE Arena Initial, Track 20 Season 1 Arena Calibration and Track 21 Arena Loop Unlock/Friction.

## Current Gate

The next operational step is focused human playtest of the published `Bosque Overlay Navigation Hotfix v1` Web/APK package. Validate that Bosque landmarks open Arena/Base/Shop/Social/Profile through shell actions, that `Fechar`, `Voltar` and Esc return to the Bosque when possible, that pending Bosque state remains honest on menu exit, and that no Tower/Card/dev-tool launcher entries appear.

Open decision focus:

1. After the focused launcher playtest, choose any next package explicitly: bugfix, launcher polish, Arena PVE follow-up, focused Openworld/Bosque tuning, or another scoped hardening/product step.
2. Preserve active Bosque runtime as local/offline-first feel plus server-owned checkpoint, completion, reward, caps, ledger and audit authority.
3. Keep Arena regressions in future manual smoke lists: Preparacao visible before start/in active attempts/buff choice, selected victory buff returns to `Resolver duelo`, and temporary bonus stats are visible in the next fight/replay.

## Live Boundaries

- DraxosMobile is a PVE Arena-first async autobattler with Refugio/Base, later PVP and social systems.
- Openworld/Bosque is an approved Internal Alpha slice with local diegetic launcher and persistent overlay shell, not approval for a continuous open world expansion.
- Arena PVE remains the living product direction for early game.
- Foundation Hardening V2 remains the previous hardening/live-doc enforcement baseline.
- Hardening Platform V1 remains the previous mode-platform baseline.
- Remote Lab Runner remains preserved for Battle Lab and Progression Lab in Web export, without service role in client/export and without economy/ranking/save-progress mutation.
- Current names, spells, weapons, economy values, Battle Pass, battle flavor and visual identity are mock/substance unless a live doc promotes them.

## Validation Snapshot

This file is a decision snapshot. Detailed package-by-package validation logs and publication evidence belong in `implementation/tracks/`, `docs/*-report.md`, Kanban Done cards or handoffs.

For docs-only changes:

- Run `git diff --check`.
- Run targeted `rg` drift checks against live docs.
- Run `validate_foundation.ps1 -Profile DocsOnly` from `Projetos/draxos-mobile` when docs affect status or agent operation; this now includes `tools/check_hardening_contracts.ps1` for validation-profile, account/save, lab-authority, release-safety and mirror-drift boundaries.
- Run `validate_foundation.ps1 -Profile ReleaseDryRun` after changing PowerShell validation/release tooling.

Do not run build, deploy, upload, manifest deploy, `supabase db push` or remote mutation for documentation-only follow-ups.

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
