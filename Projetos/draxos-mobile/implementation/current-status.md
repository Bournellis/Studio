# DraxosMobile - Current Status

- Last updated: `2026-06-05`
- Project: `draxos-mobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `Internal Alpha`
- Active stage: `Openworld Main Menu Sync Publication`
- Active stage status: `OPENWORLD_MAIN_MENU_SYNC_PUBLISHED_INTERNAL_ALPHA`
- Build channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`

## Current Truth

- Latest published remote package: `Openworld Main Menu Sync`
- Release root: `internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Latest deployment evidence: `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`
- Source state: already-merged `master` state from Openworld collection sync backend fix plus main menu simplification.
- Previous hardening baseline: `Foundation Hardening V2`
- Previous hardening release root: `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`
- Previous hardening preview: `https://ca946749.draxos-mobile-internal-alpha.pages.dev`
- Hardening baseline marker: `Track 13 - Foundation Validation And Release Safety` (`TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`)
- Agent baseline marker: `Track 14 - Agent Operations Foundation` (`TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`)
- Arena contract context: `Track 18 - PVE Arena Initial`, Track 20 Season 1 Arena Calibration and Track 21 Arena Loop Unlock/Friction are preserved Arena/Autobattler context, not the current platform baseline.
- Technical context: Track 16 Behavior And Potion Crafting is existing alpha substance summarized in `docs/behavior-potion-crafting-v1.md`, not the current product focus.

## Published Package

Openworld Main Menu Sync published the current player-facing Internal Alpha package:

- applies remote migration `202606040002_openworld_bosque_collection_sync_v1.sql`;
- redeploys Supabase Edge Function `modes`;
- accepts all 26 active Bosque ruleset resource nodes in the backend;
- persists `player_position` only through `move_heartbeat`;
- sanitizes event ACK patches so ordinary event responses do not roll back active local position;
- preserves local player position during active resync of the same session;
- removes player-facing Mode Hub, collect-all, direct Energia and dev Openworld shortcuts;
- keeps `Bosque` as the direct Openworld entry;
- moves Preparacao into Arena PVE and keeps Energia purchase inside Loja;
- keeps the production Pages domain as the official URL and the hash deployment only as evidence.

Publication evidence preserved for this package:

- `supabase db push`, `supabase functions deploy modes`, export, Storage upload, Cloudflare Pages production branch `main`, remote manifest, RemoteReadOnly and remote Web launch smoke all passed during publication.
- Remote Web smoke loaded the game in `4639 ms`, matched release root and reported no runtime errors.
- Android APK uses `debug_fallback`, accepted for closed Internal Alpha only.

## Current Gate

The next product step remains human review/playtest of the published Openworld Main Menu Sync package before any new expansion package.

Playtest focus:

1. Confirm Bosque collect/deposit/resync after collecting v2 nodes.
2. Confirm simplified main menu path into Bosque, Arena PVE and Loja.
3. Confirm tutorial Arena and first real Arena loop still read correctly.
4. Record whether the next package should be a Bosque/menu hotfix or an Arena PVE/tuning package. This decision is not fixed yet.

## Current Technical Hardening Work

Active local work on branch `codex/draxos-mobile/technical-hardening` is allowed to address the approved hardening package:

- compact live docs and remove stale blockers from the decision snapshot;
- move `Modes Ops` out of the client while preserving Battle Lab and Progression Lab;
- make release publication happen only through `publish_internal_alpha.ps1` with explicit `-ReleaseRoot` and `-ConfirmRemoteMutation`;
- refactor large hotspots to make upcoming implementation safer;
- harden mutable backend auth broadly in two phases;
- add transactional account reset v1 with `request_hash`;
- move Arena reward authority DB-side through explicit reward profiles.

No remote publication, Supabase remote mutation, Cloudflare deploy, keystore work, tuning expansion, PVP, new content, new weapons, new spells, new potions or economy pass is included in this local hardening package.

## Live Boundaries

- DraxosMobile is a PVE Arena-first async autobattler with Refugio/Base, later PVP and social systems.
- Openworld/Bosque is an approved Internal Alpha slice, not approval for a continuous open world expansion.
- Arena PVE remains the living product direction for early game, governed by `docs/pve-arena-initial-direction.md` and `docs/pve-arena-v1.md`.
- Foundation Hardening V2 remains the previous hardening/live-doc enforcement baseline.
- Hardening Platform V1 remains the previous mode-platform baseline.
- Remote Lab Runner remains preserved for Battle Lab and Progression Lab in Web export, without service role in client/export and without economy/ranking/save-progress mutation.
- Current names, spells, weapons, economy values, Battle Pass, battle flavor and visual identity are mock/substance unless a live doc promotes them.

## Validation Snapshot

Latest local audit before this hardening branch:

- `validate_foundation.ps1 -Profile DocsOnly -NoProjectWrites`: PASS
- `validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`: PASS
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS (`222/222` GUT tests)
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: PASS
- `validate_foundation.ps1 -Profile ModePlatform -NoProjectWrites`: PASS (`38/38` mode contract tests plus Godot smokes)
- `git status --short`: clean

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
