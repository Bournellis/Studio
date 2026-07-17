# Coordenação local — DraxosMobile

## Metadata

- status: `living`
- authority: `operational_contract`
- last_verified: `2026-07-16`
- review_when: `the local lifecycle or closure protocol changes`
- supersedes: `global-only coordination for new DraxosMobile work`
- superseded_by: `none`

New project-only cards and handoffs live here. Global records before the 2026-07-16 cutover remain historical and are not copied.

## Authorities

- Portfolio: `../../../08_Coordenacao_Agentes/Prioridades_Estudio.md`.
- Local technical state: `../implementation/current-status.md`.
- QA commands: `../qa/qa_manifest.json`.
- Journeys and human gates: `../qa/QA_INDEX.md`.
- Documentation routes: `documentation-index.md`.
- Triage and debt: `TRIAGE.md`, `technical-debt-baseline.md`.

## Lifecycle

`Backlog -> Doing -> Done` is the technical flow. `Review` is reserved for a real human decision. Green technical work may be merged and cleaned while Arena proof or another independent human gate remains pending.

Every card uses metadata v3 and records validation, merge/worktree/branch cleanup, publication status and `global_sync_needed`. Local work never updates global portfolio hot files directly; a later `portfolio_sync` consumes the queue.

No local card can approve Arena proof, tuning, economy, PVP, visual direction, remote mutation, device QA or release.

