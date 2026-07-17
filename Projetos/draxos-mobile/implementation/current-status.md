# DraxosMobile — Current Status

## Metadata

- status: `living`
- authority: `local_state`
- last_verified: `2026-07-16`
- review_when: `the observable technical baseline or next technical step changes`
- supersedes: `implementation/tracks/governance-v2-pre-cutover-status-2026-07-16.md`
- superseded_by: `none`

## Authority boundary

- Portfolio status and allowed work come only from `../../../08_Coordenacao_Agentes/Prioridades_Estudio.md`.
- Package lineage, stable endpoints and older evidence live only in `../docs/release-history.md`.
- This file is the only short local technical snapshot; it does not approve priority, product or release.

## Technical baseline

- Latest published remote package: `Arena Runtime Config Sync Ready v3`.
- Release root: `internal-alpha/v0-arena-runtime-config-sync-ready-v3-20260616-bc04e88a`.
- Deployment evidence: `https://a50d282b.draxos-mobile-internal-alpha.pages.dev`.
- Build channel: `internal_alpha`; version `0.0.27-alpha.0`; Version code: `27`; Minimum supported: `13`.
- The approved Web hosting hotfix and its newer preview evidence are recorded in `../docs/release-history.md`.
- Arena PVE direction and implementation contracts: `../docs/pve-arena-initial-direction.md` and `../docs/pve-arena-v1.md`.
- Server-authoritative account/save, battle, reward and mode boundaries remain preserved.
- Release safety baseline: `TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`.
- Agent operations baseline: `TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`.

## Gate and next technical step

- Arena result remains `ARENA_CORE_NEEDS_UX_FIX` plus `ARENA_CORE_NOT_PROVEN`.
- Human proof in `../docs/arena-pve-product-proof.md` remains pending before tuning, economy, PVP, content or final visual work.
- Next technical step: preserve the current package and prepare only evidence/support needed for that human proof when explicitly requested.
- Remote mutation, publication, device validation and human product decisions are outside local automation.

## Validation contract

- Fast: local `DocsOnly`, `ServerQuick` and selected GUT tests.
- Runtime: local `ClientQuick`, `ServerQuick` and `ModePlatform`.
- Build: local `ReleaseDryRun`; it never publishes.
- Each runtime/build runner must execute twice with an unchanged tracked Git snapshot.
