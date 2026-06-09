# DraxosMobile - Current Status

- Last updated: `2026-06-09`
- Project: `draxos-mobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `Internal Alpha`
- Active stage: `Bosque Bootstrap Authority v1`
- Active stage status: `BOSQUE_BOOTSTRAP_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`
- Build channel: `internal_alpha`
- Version: `0.0.15-alpha.0`
- Version code: `15`
- Minimum supported version code: `13`

## Current Truth

- Latest published remote package: `Bosque Bootstrap Authority v1`.

- Release root: `internal-alpha/v0-bosque-bootstrap-authority-v1-20260609-ba99e70`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Deployment evidence: `https://0123894f.draxos-mobile-internal-alpha.pages.dev`
- Source state: implementation branch merged into `main`; release commit is `ba99e70`.
- Published package: bumps APK/manifest to `0.0.15-alpha.0` / version code `15`, keeps `minimum_supported_version_code` at `13`, redeploys `release`, and fixes Bosque reentry bootstrap by hiding the playable integrated viewport until canonical remote/cache state arrives.
- Remote SQL already applied: `202606080001_openworld_bosque_persistence_rebase_v1.sql` and `202606080002_openworld_bosque_jsonb_object_length_hotfix_v1.sql`.
- Remote functions: `release` redeployed for Bosque Bootstrap Authority v1; `arena` remains on Arena PVE Bonus Visual v1; `modes` remains on the operations-v2 backend from the previous Bosque packages.

Initial human playtest of Bosque Bootstrap Authority v1 was reported OK by Fabio on `2026-06-09`: everything tested so far appeared to work. Documentation drift cleanup is complete. The current open decision is `DMOB-D076`, choosing the next post-Bootstrap product package. If future errors appear, they return to the normal bugfix flow.

## Operational Vs Product Direction

- Operational package: Bosque Bootstrap Authority v1 is current.
- Product direction: Arena PVE remains the first approved core, governed by `docs/pve-arena-initial-direction.md` and `docs/pve-arena-v1.md`.
- Bosque/Openworld status: approved integrated Internal Alpha slice, not approval for broad continuous-open-world expansion.
- Do not open tuning, PVP, economy, content, weapons, spells, potions, final visuals, remote mutation or a new package without an explicit decision.

## Current Package Evidence

Delivered:

- hides the integrated Bosque playable viewport until canonical remote/cache bootstrap completes;
- prevents the `Voltar -> entrar` transient full-spawn world flash before authority sync;
- adds regression coverage for delayed `/modes/state` not exposing a full-spawn frame before sync;
- aligns release/export scripts and remote smokes with version code `15`;
- preserves Arena PVE Bonus Visual v1, Bosque Node Cooldown ACK v1, resume/exit lifecycle, feel/spawn authority, persistence rebase and station-craft behavior.

Publication evidence:

- Cloudflare Pages preview evidence: `https://0123894f.draxos-mobile-internal-alpha.pages.dev`.
- Direct preview Web launch smoke loaded the game in `6890 ms`, matched release root and reported no runtime errors.
- Remote manifest smoke, internal alpha release smoke and remote artifact smoke passed.
- Canonical Portal/Web are Cloudflare Access protected; preview Web launch validated the public Pages deployment.
- Android APK uses `debug_fallback`, accepted for closed Internal Alpha only.

Artifact hashes:

- Android APK SHA256: `f7406c57b1a8ef6af6496395eba25c7cde0358781c5c47e845daa457405b84f4`
- PC Windows ZIP SHA256: `b45826aaa8fbd70959795f3758c43d1b7e6f4590378d63f47a071958ed5d588b`
- Web Index SHA256: `9f410baff95d901a65f46d05eae316f7bdc203b0fcc200e8bacdf750e42dde56`

## Preserved Lineage

These packages are preserved history/context, not the current publication:

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

The next operational step is the explicit `DMOB-D076` decision for the next post-Bootstrap product package. Do not repeat the Bosque Bootstrap Authority v1 playtest as the required next step unless a new bug report or explicit validation request appears.

Open decision focus:

1. Choose the next product package explicitly: Arena PVE follow-up, focused Openworld/Bosque tuning or another scoped polish pass.
2. Preserve active Bosque runtime as local/offline-first feel plus server-owned checkpoint, completion, reward, caps, ledger and audit authority.
3. Keep Arena regressions in future manual smoke lists: Preparacao visible before start/in active attempts/buff choice, selected victory buff returns to `Resolver duelo`, and temporary bonus stats are visible in the next fight/replay.

## Live Boundaries

- DraxosMobile is a PVE Arena-first async autobattler with Refugio/Base, later PVP and social systems.
- Openworld/Bosque is an approved Internal Alpha slice, not approval for a continuous open world expansion.
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
- Run `validate_foundation.ps1 -Profile DocsOnly` from `Projetos/draxos-mobile` when docs affect status or agent operation.

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
