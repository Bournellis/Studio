# DraxosMobile - Current Status

- Last updated: `2026-06-16`
- Project: `draxos-mobile`
- Portfolio status: see `../../08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Active surface: `Internal Alpha`
- Active stage: `Arena Runtime Config Sync Ready v3`
- Active stage status: `ARENA_RUNTIME_CONFIG_SYNC_READY_V3_PUBLISHED_INTERNAL_ALPHA`
- Build channel: `internal_alpha` | Version: `0.0.27-alpha.0` | Version code: `27` | Minimum supported: `13`
- Package history, stable URLs and download endpoints: `../docs/release-history.md`

## Current Truth

- Latest published remote package: `Arena Runtime Config Sync Ready v3`.
- Release root: `internal-alpha/v0-arena-runtime-config-sync-ready-v3-20260616-bc04e88a` (from implementation commit `bc04e88a`).
- Deployment evidence: `https://a50d282b.draxos-mobile-internal-alpha.pages.dev`.
- The package preserves the Arena UX/readability route and fixes the Web runtime_config recovery path: embedded internal_alpha config is used in Web, automatic runtime_config sync repaints the current route when it exits fallback, and required remote runtime_config overlay actions pass before retest.
- Remote SQL already applied: `202606080001_openworld_bosque_persistence_rebase_v1.sql` and `202606080002_openworld_bosque_jsonb_object_length_hotfix_v1.sql`.
- Remote functions: `release` redeployed for this package; `arena` remains on Arena PVE Bonus Visual v1; `modes` remains on the operations-v2 backend.
- Initial human playtest of Bosque Bootstrap Authority v1 was reported OK by Fabio on `2026-06-09`. Bosque overlay/readiness remains preserved under this newer Arena UX package.

## Operational Vs Product Direction

- Operational package: Arena Runtime Config Sync Ready v3 is current.
- Product direction: Arena PVE remains the first approved core, governed by `docs/pve-arena-initial-direction.md` and `docs/pve-arena-v1.md`.
- Arena proof result: Fabio recorded `ARENA_CORE_NEEDS_UX_FIX` + `ARENA_CORE_NOT_PROVEN` on `2026-06-14`; this package was published by explicit user approval to support the proof, but the core is still not approved for tuning or expansion yet.
- Bosque/Openworld: approved integrated Internal Alpha slice, not approval for broad continuous-open-world expansion.
- Do not open tuning, PVP, economy, content, weapons, spells, potions, final visuals, remote mutation or a new package without an explicit decision.

## Current Package Evidence

- ClientQuick, ReleaseDryRun, RemoteReadOnly, Deno release checks and required remote runtime_config overlay actions passed for this package.
- Remote preview Web launch smoke loaded the game, matched release root and reported no runtime errors; manifest/deploy validation passed.
- `smoke_web_overlay_menu_actions.ps1 -RequireRemoteRuntimeConfig` passed against the preview and reported `fallback=false`, `allowsGameplayMutation=true`.
- Anonymous canonical Portal/Web returns Cloudflare Access content; the hash preview is the automated Web evidence and the official URL should be tested with an authenticated Access session.
- Android APK uses `debug_fallback`, accepted for closed Internal Alpha only.
- Artifact SHA256 - APK: `f759d99f113e004c4ba5e2f15d3597904cfd97c6a3277514b3c0ab1035cf3b04` | PC ZIP: `b37677c972c0c23302dab4658a2a5369f0d182f9abff064191058541f889705a` | Web index: `14197329480a197e21673ecce96e512ffff22faa6a79720c7c19c92f6ce11428`

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

The Arena runtime_config recovery package was republished on `2026-06-16` by
explicit user approval after v1/v2 were superseded by required remote smoke
failures.
The next step is human proof using `docs/arena-pve-product-proof.md`; do not
open tuning, economy, PVP, content expansion or broad Openworld work until
Fabio records the verdict.

Open decision focus:

1. Preserve active Bosque runtime as local/offline-first feel plus server-owned checkpoint, completion, reward, caps, ledger and audit authority.
2. Keep Arena regressions in future manual smoke lists: Preparacao visible before start/in active attempts/buff choice, selected victory buff returns to `Resolver duelo`, temporary bonus stats visible in the next fight/replay.
3. Do not open numeric tuning, economy/content expansion, PVP or broad Openworld work until Arena core exits the `NOT_PROVEN` state.
4. Treat the current package as a technical publication for proof, not as product approval of the Arena core.

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
