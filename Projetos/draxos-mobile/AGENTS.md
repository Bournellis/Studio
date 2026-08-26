# AGENTS.md — DraxosMobile

## Metadata

- status: `living`
- authority: `operational_contract`
- last_verified: `2026-08-26`
- review_when: `authority, validation or release safety changes`
- supersedes: `global-first DraxosMobile coordination`
- superseded_by: `none`

This is the fast operational entrypoint for `Projetos/draxos-mobile`. Do not confuse this project with the separate Steam roguelike cardgame. This file carries no package names, URLs or version codes.

## Authority

1. Portfolio focus and allowed work: `../../08_Coordenacao_Agentes/Prioridades_Estudio.md`.
2. Shared-universe binding and adopted domains: `STUDIO_CORE.md`.
3. Local technical baseline and next technical step: `implementation/current-status.md`.
4. Product contracts: `docs/product-vision.md`, `docs/pve-arena-initial-direction.md` and `docs/game-design-document.md`.
5. QA commands: `qa/qa_manifest.json`; journeys and human gates: `qa/QA_INDEX.md`.
6. Package lineage and endpoints: `docs/release-history.md`.

No local file may redefine portfolio priority. DraxosMobile adopts only the Core domains declared in its binding and owns all local lore, product and mechanics; another project's campaign or implementation is never an implicit contract.

## Local-first cycle

- New project-only cards and handoffs live in `08_Coordenacao/`.
- Read `08_Coordenacao/TRIAGE.md`, open a v3 card, and use a dedicated worktree before editing.
- `Review` is only for an actual pending human decision. Technical work may be integrated while its independent human gate remains pending.
- Local work records `global_sync_needed`; only a later `portfolio_sync` writer updates global hot files.
- Keep history in `implementation/history.md`, `implementation/history-ledger/` or `docs/release-history.md`, never in the live status. Closed cards and handoffs are transient.

## Read by task

- Runtime/client: `docs/agent-operating-manual.md`, then the affected contract.
- Account/save/server authority: `docs/contracts/account-save.md`, `docs/contracts/database-schema.md`, `docs/contracts/api-endpoints.md`.
- Feature installation: `docs/contracts/feature-registry.md`.
- Arena: `docs/pve-arena-initial-direction.md`, the Arena section of `docs/game-design-document.md`, executable contracts under `docs/contracts/`, and `docs/arena-pve-product-proof.md`.
- Release/build: `docs/contracts/release-safety.md`, `docs/release-ops-checklist.md`; stay local unless Fabio explicitly authorizes external mutation.
- QA profile detail: `qa/validation-matrix.md`.
- Parallel lanes: `docs/multi-agent-workflow.md`.

## Safe local validation

Run from this project root:

```powershell
.\tools\validate_foundation.ps1 -ProjectDir . -Profile DocsOnly
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ServerQuick
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ModePlatform
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun
git diff --check
git status --short
```

The studio orchestrator snapshots Git around every declared runner. A validator-caused tracked change is `VALIDATOR_SIDE_EFFECT` and must be investigated, never restored automatically.

## Hard stops

- No secret, service role, database/keystore password or private token in code, exports, portal, manifests or docs.
- No remote database, device, upload, deploy, publication or external mutation without explicit authorization.
- No new product feature, tuning, economy, PVP, content expansion or final visual pass while Arena proof remains pending.
- No bypass of `account_profiles/game_saves`, ruleset registry, idempotency or server-authoritative battle/reward boundaries.
- No raw `.tscn` edit unless explicitly requested and safer than the editor/tool path.
- No growth of allowlisted debt without extraction or a recorded exception plus regression.
