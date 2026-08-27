# Documentation Index - Estudio

## Metadata

- status: `active`
- authority: `router`
- last_verified: `2026-08-27`
- review_when: `authority map or official project registry changes`
- supersedes: `documentation-index.md before Governance v2`
- superseded_by: `none`

Global documentation router. It carries no package, marker, release URL or next step.

## Authority

- `Prioridades_Estudio.md` - focus, portfolio status and allowed work.
- Project `implementation/current-status.md` - local baseline, gate, risk and validation.
- `Estado_Atual.md` - short portfolio projection.
- `PortfolioSync_QUEUE.md` - pending/reflected synchronization acts, never state authority.
- `../AGENTS.md` - workspace operational contract.

## Coordination

- `Decisoes/` - active and historical product/process decisions.
- `Templates/` - gates v3 and lifecycle templates.
- `Registers/` - machine-readable governance and approved cleanup manifests; classification alone never authorizes deletion.
- `History/` - compact monthly history absorbed from redundant global records.
- `Receipts/DocumentationLite/` - exact cutover receipts and recovery provenance.
- `Runbooks/DOCUMENTATION_LITE_LIFECYCLE.md` - active lifecycle for compact history and recoverable cleanup.
- `Runbooks/GIT_SAFE_PUSH.md` - exact delegated synchronization of `main` to `origin/main`.
- `Runbooks/VISUAL_PRODUCTION_PIPELINE.md` - prospective visual production and independent gates.
- `Kanban/` and `Handoffs/` - current global/cross-project work; closed narratives are absorbed into compact history.
- Project `08_Coordenacao/` - new project-local cards, triage and handoffs.
- `FABIO_DASHBOARD.md` / `.html` - human projection, never technical authority.

## Canon

- `../STUDIO_CORE.md` - bridge to thematic shared canon revision `lore.v2`, exact source snapshots and the binding registry in `D:\Studio Core`.
- Project `STUDIO_CORE.md` - explicit `shared` or `none` binding, adopted domains and local lore authority.
- `../canon/canon-brief.md` and `../canon/README.md` - transitional local routers to the Core.
- `../canon/shared-lore/` - superseded provenance bridges; not living canon.
- `../canon/studio-conventions/project-boundaries.md` - adoption rules.
- `../canon/studio-conventions/prospective-asset-provenance.md` - provenance required for new runtime assets.
- `../canon/studio-conventions/code-convergence-registry.md` - read-only convergence policy; no shared core.
- `../canon/studio-conventions/final-focus-readiness.md` - inactive checklist, activated only by Fabio.
- `../Projetos/rpg-isometrico/docs/canon/` - RPG Isometrico product canon.
- Other projects - local product/technical contracts under their own docs.

## Projects

Use `../Projetos/README.md`, then the target `AGENTS.md`, `implementation/current-status.md`, `08_Coordenacao/documentation-index.md` and `qa/QA_INDEX.md`.

## Tooling

- `../tools/studio_doctor.ps1` - environment and integrity checks.
- `../tools/validate_estudio.ps1` - DocsOnly, FastSuite, Runtime, Build and FullLocal orchestration.
- `../tools/estudio_governance.json` - machine-readable project/tooling configuration, without portfolio status duplication.
- `../tools/check_doc_drift.ps1` - compatibility entrypoint for DocsOnly.
- `../tools/git_commit_powershell.ps1` / `close_worktree_powershell.ps1` - local commit and closure helpers.
- `../tools/create_evidence_manifest.py` / `register_new_lfs_path.ps1` - dry-run-first evidence and literal LFS helpers.
- `../tools/check_secret_scan.ps1` - read-only tracked-file secret scan.

Removed pre-cutover sources are not recreated as stubs. Inspect compact history first, then the approved receipt/manifest, and use the recorded baseline commit or blob only for an explicit historical recovery task.
