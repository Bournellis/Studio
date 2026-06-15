# DraxosMobile - Current Status

- Last updated: `2026-06-15`
- Project: `draxos-mobile`
- Portfolio status: see `../../08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Active surface: `Internal Alpha`
- Active stage: `Bosque Overlay Layer And Readiness Authority v1`
- Active stage status: `BOSQUE_OVERLAY_LAYER_READINESS_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`
- Build channel: `internal_alpha` | Version: `0.0.23-alpha.0` | Version code: `23` | Minimum supported: `13`
- Package history, stable URLs and download endpoints: `../docs/release-history.md`

## Current Truth

- Latest published remote package: `Bosque Overlay Layer And Readiness Authority v1`.
- Release root: `internal-alpha/v0-bosque-overlay-layer-readiness-authority-v1-20260610-181861c` (from implementation commit `181861c`).
- Deployment evidence: `https://a9e3b2f9.draxos-mobile-internal-alpha.pages.dev`.
- The package keeps the Bosque alive, visible and input-paused behind Arena/Base/Shop/Social/Profile overlays, renders Arena active/replay fullscreen above the menu panel, moves confirmations to a global topmost modal, and exposes route readiness (`opening -> refreshing -> ready -> mutating -> critical`) so server-backed menus show synchronization before accepting dependent commands.
- Remote SQL already applied: `202606080001_openworld_bosque_persistence_rebase_v1.sql` and `202606080002_openworld_bosque_jsonb_object_length_hotfix_v1.sql`.
- Remote functions: `release` redeployed for this package; `arena` remains on Arena PVE Bonus Visual v1; `modes` remains on the operations-v2 backend.
- Initial human playtest of Bosque Bootstrap Authority v1 was reported OK by Fabio on `2026-06-09`. This package answers the two issues he reported afterwards: Arena/new duel appearing under the menu panel, and server-backed menus looking ready before accepting commands.

## Operational Vs Product Direction

- Operational package: Bosque Overlay Layer And Readiness Authority v1 is current.
- Product direction: Arena PVE remains the first approved core, governed by `docs/pve-arena-initial-direction.md` and `docs/pve-arena-v1.md`.
- Arena proof result: Fabio recorded `ARENA_CORE_NEEDS_UX_FIX` + `ARENA_CORE_NOT_PROVEN` on `2026-06-14`; Arena direction remains, but the core is not approved for tuning or expansion yet.
- Bosque/Openworld: approved integrated Internal Alpha slice, not approval for broad continuous-open-world expansion.
- Do not open tuning, PVP, economy, content, weapons, spells, potions, final visuals, remote mutation or a new package without an explicit decision.

## Current Package Evidence

- Local and remote Web/canvas smokes passed for `Fechar`/`Voltar`/Esc, Social `LineEdit` typing, Shop confirm/cancel, Arena retomar/abandonar (`activeAttemptBlocksSelection=false`, `lastArenaOperation.phase=abandon_released`), Arena fullscreen topmost and modal topmost.
- Direct preview Web launch smoke loaded the game, matched release root and reported no runtime errors; remote manifest/deploy validation passed.
- Anonymous canonical Portal/Web returns Cloudflare Access content; the hash preview is the automated Web evidence and the official URL should be tested with an authenticated Access session.
- Android APK uses `debug_fallback`, accepted for closed Internal Alpha only.
- Artifact SHA256 - APK: `986bff2ac180de883f5dfa97078e0a3ff31e2c0d4de139b8863c18e1d37507ab` | PC ZIP: `4659da781b027dcb1c9f1b5d6ec32e56630eac14160413a35cb75a90c2e8c0dc` | Web index: `0f6e3e655367df73f9a6d3ba2ee5a4e205b487bbda03a108ec9fc6db3a7bd73b`

## Preserved Lineage And Guardrails

- Full package lineage (release roots, previews, version codes): `../docs/release-history.md`.
- Track markers active as guardrails: `TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`, `TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`.
- Arena context lineage: Track 18 (PVE Arena Initial), Track 20 (Season 1 Calibration), Track 21 (Arena Loop Unlock/Friction).

## Current Gate

The joint documentation hygiene and client hardening pass 2 was completed
locally on `2026-06-14`, with no remote mutation or publication. It archived
resolved design decisions out of the live pending register, reduced
client-shell test concentration, centralized overlay host call contracts and
split Openworld reward summary formatting out of the integrated bridge.

The next product package, when explicitly opened, must focus Arena
UX/readability/recovery: make the tutorial -> first real arena -> buffs ->
summary -> abandon/resume path understandable without agent explanation.

The documentation round on `2026-06-15` formalized the next package as
`docs/arena-ux-proof-release-discipline-plan.md`: candidate first, automated
validation, human proof, then verdict before any official package promotion.

Open decision focus:

1. Preserve active Bosque runtime as local/offline-first feel plus server-owned checkpoint, completion, reward, caps, ledger and audit authority.
2. Keep Arena regressions in future manual smoke lists: Preparacao visible before start/in active attempts/buff choice, selected victory buff returns to `Resolver duelo`, temporary bonus stats visible in the next fight/replay.
3. Do not open numeric tuning, economy/content expansion, PVP or broad Openworld work until Arena core exits the `NOT_PROVEN` state.
4. Do not use a new official package as the first proof step; run a validated candidate and human proof before promotion.

## Live Boundaries

- DraxosMobile is a PVE Arena-first async autobattler with Refugio/Base, later PVP and social systems.
- Openworld/Bosque is an approved Internal Alpha slice, not a continuous open world approval.
- Remote Lab Runner remains preserved for Battle/Progression Lab in Web export, without service role in client/export and without economy/ranking/save-progress mutation.
- Current names, spells, weapons, economy values, Battle Pass, battle flavor and visual identity are mock/substance unless a live doc promotes them.

## Validation Snapshot

This file is a decision snapshot. Detailed package-by-package validation logs and publication evidence belong in `implementation/tracks/`, `docs/*-report.md`, Kanban Done cards or handoffs.

For docs-only changes: `git diff --check`, targeted `rg` drift checks, `validate_foundation.ps1 -Profile DocsOnly` when docs affect status or agent operation, and `-Profile ReleaseDryRun` after changing PowerShell tooling. Do not run build, deploy, upload, manifest deploy, `supabase db push` or remote mutation for documentation-only follow-ups.

## Read Next

1. `AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `docs/documentation-index.md`
4. `docs/multi-agent-workflow.md`
5. `docs/pve-arena-initial-direction.md`
6. `docs/arena-ux-proof-release-discipline-plan.md`
7. `docs/product-vision.md`
8. `docs/design-pending.md`
