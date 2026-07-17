# FpsPlayground Local Coordination

## Metadata

- status: `active`
- authority: `operational_contract`
- last_verified: `2026-07-16`
- review_when: `local coordination or gates v3 contract changes`
- supersedes: `global-only project coordination before Governance v2`
- superseded_by: `none`

This directory coordinates project-local work without duplicating portfolio or technical state.

## Authority

1. `../../../08_Coordenacao_Agentes/Prioridades_Estudio.md` controls portfolio priority, status and allowed work.
2. `../implementation/current-status.md` is the sole local technical-state authority.
3. `TRIAGE.md` projects only human gates represented by cards in `Kanban/Review/`.
4. Cards and handoffs record execution history; they do not redefine product contracts.

## Lifecycle

- New local work starts in `Kanban/Backlog/` or `Kanban/Doing/` with gates v3 metadata.
- `Review/` is reserved for an actual pending human decision.
- Technical work may be ready for local merge while a separate human gate remains pending.
- `Done/` rejects `human_gate_status: pending`.
- Local work records `global_sync_needed`; only portfolio-sync work edits global snapshots.

## Boundaries

- No remote mutation, publication, device authority or priority change.
- No football/TPS scope; that belongs to `../JogoDaCopa`.
- Do not create a second state file under this directory.
- Preserve movement, weapon feel, bot fairness, map and tuning decisions for Fabio.

## Entry Points

- Documentation map: `documentation-index.md`
- Human-gate projection: `TRIAGE.md`
- Live work: `Kanban/Doing/`
- Pending decisions: `Kanban/Review/`
- Handoffs: `Handoffs/`
