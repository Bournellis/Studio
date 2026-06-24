# DraxosMobile - Current Status

- Last updated: `2026-06-24`
- Project: `draxos-mobile`
- Portfolio status: see `../../08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Active surface: `Internal Alpha`
- Active stage: `Arena Web Static Assets Hotfix v1`
- Active stage status: `ARENA_WEB_STATIC_ASSETS_HOTFIX_V1_HUMAN_APPROVED`
- Build channel: `internal_alpha` | Version: `0.0.27-alpha.0` | Version code: `27` | Minimum supported: `13`
- Package history, stable URLs and download endpoints: `../docs/release-history.md`

## Current Truth

- Latest published remote package: `Arena Runtime Config Sync Ready v3` with the `Arena Web Static Assets Hotfix v1` hosting layer.
- Latest Web publication hotfix: `Arena Web Static Assets Hotfix v1` - approved by Fabio on `2026-06-24`.
- Underlying app/runtime package remains `Arena Runtime Config Sync Ready v3`; Android APK, PC ZIP, app version and version code are unchanged.
- Release root: `internal-alpha/v0-arena-runtime-config-sync-ready-v3-20260616-bc04e88a` (from implementation commit `bc04e88a`).
- Deployment evidence: `https://10efff9c.draxos-mobile-internal-alpha.pages.dev`.
- Previous v3 package evidence preserved for release-root lineage: `https://a50d282b.draxos-mobile-internal-alpha.pages.dev`.
- Web runtime assets now load from Cloudflare Pages: `index.pck` is served directly by Pages and `index.wasm` is reconstructed in-browser from `index.wasm.part0` + `index.wasm.part1`. This removes the failing Supabase Storage public asset dependency that returned `544 DatabaseTimeout` for the Web runtime files.
- The package preserves the Arena UX/readability route and fixes the Web runtime_config recovery path: embedded internal_alpha config is used in Web, automatic runtime_config sync repaints the current route when it exits fallback, and required remote runtime_config overlay actions pass before retest.
- Remote SQL already applied: `202606080001_openworld_bosque_persistence_rebase_v1.sql` and `202606080002_openworld_bosque_jsonb_object_length_hotfix_v1.sql`.
- Remote functions: `release` redeployed for this package; `arena` remains on Arena PVE Bonus Visual v1; `modes` remains on the operations-v2 backend.
- Initial human playtest of Bosque Bootstrap Authority v1 was reported OK by Fabio on `2026-06-09`. Bosque overlay/readiness remains preserved under this newer Arena UX package.

## Operational Vs Product Direction

- Operational package: Arena Runtime Config Sync Ready v3 remains current; Web Static Assets Hotfix v1 is the current hosting layer for that package.
- Product direction: Arena PVE remains the first approved core, governed by `docs/pve-arena-initial-direction.md` and `docs/pve-arena-v1.md`.
- Arena proof result: Fabio recorded `ARENA_CORE_NEEDS_UX_FIX` + `ARENA_CORE_NOT_PROVEN` on `2026-06-14`; this package was published by explicit user approval to support the proof, but the core is still not approved for tuning or expansion yet.
- Bosque/Openworld: approved integrated Internal Alpha slice, not approval for broad continuous-open-world expansion.
- Do not open tuning, PVP, economy, content, weapons, spells, potions, final visuals, remote mutation or a new package without an explicit decision.

## Current Package Evidence

- ClientQuick, ReleaseDryRun, RemoteReadOnly, Deno release checks and required remote runtime_config overlay actions passed for the underlying v3 package.
- Web Static Assets Hotfix v1 direct asset checks passed on the hash preview: Web shell has no `storage/v1` reference, `index.pck` and both `index.wasm.part*` chunks are served by Cloudflare Pages, and no file in the Pages package is `>= 25 MiB`.
- Remote preview Web launch smoke loaded the game from `https://10efff9c.draxos-mobile-internal-alpha.pages.dev/web/index.html`, matched release root, reported `assetRoot=/web` and had no runtime errors.
- `smoke_web_overlay_menu_actions.ps1 -RequireRemoteRuntimeConfig` passed against the hotfix preview and reported `fallback=false`, `allowsGameplayMutation=true`.
- Human Web hotfix validation: Fabio reported `Funcionou, aprovado!` on `2026-06-24`; this approves the Web loading/hosting fix only, not the Arena PVE core loop.
- Anonymous canonical Portal/Web returns Cloudflare Access content; the hash preview is the automated Web evidence and the official URL should be tested with an authenticated Access session.
- Android APK uses `debug_fallback`, accepted for closed Internal Alpha only.
- Artifact SHA256 - APK: `f759d99f113e004c4ba5e2f15d3597904cfd97c6a3277514b3c0ab1035cf3b04` | PC ZIP: `b37677c972c0c23302dab4658a2a5369f0d182f9abff064191058541f889705a` | Cloudflare Web index: `d9465f5bbae71190d861705a95e23bedfcf5c1a0ba6b0238f15ba1db17eb9dc2`

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
failures. On `2026-06-24`, Web Static Assets Hotfix v1 republished only the
Cloudflare Pages hosting layer after Supabase Storage public runtime assets
returned `544 DatabaseTimeout`; app/runtime package, release root, APK and PC
ZIP remain unchanged. Fabio approved this Web loading hotfix on `2026-06-24`.
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
