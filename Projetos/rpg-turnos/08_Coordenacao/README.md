# RPG Turnos Local Coordination

## Metadata

- status: `active`
- authority: `operational_contract`
- last_verified: `2026-07-16`
- review_when: `the Studio coordination or closure protocol changes`
- supersedes: `global-only coordination for new RPG Turnos work`
- superseded_by: `none`

New RPG Turnos cards and handoffs live here. Pre-cutover records remain historical in the Studio-level coordination hub and are not copied.

## Authority Boundaries

- Portfolio focus, status and allowed work: `../../../08_Coordenacao_Agentes/Prioridades_Estudio.md`.
- Local technical baseline: `../implementation/current-status.md`.
- Product and gameplay contracts: `../docs/`.
- This directory routes work; it cannot resume the project, change priority or approve a human gate.

## Local-First Rules

- Project-local implementation, documentation, validation and review use this coordination root.
- Cross-project, canon, portfolio and global-governance changes use the Studio coordination root through a dedicated writer.
- Local work records `global_sync_needed`; it never edits global hot files incidentally.
- `Review` is reserved for a real pending human decision. A branch waiting for merge is not a human gate.
- Rejected or superseded work closes in `Done` with the outcome recorded.

## Card Metadata V3

Every task card records:

- Closure: `closure_protocol` and `technical_status`.
- Human gate: `human_gate_required`, `human_gate_status`, `human_gate_scope` and `human_gate_evidence`.
- External state: `publication_status` and `blocking_decision`.
- Execution: `execution_mode`, `delegated_scope`, `branch`, `worktree` and `base_ref`.
- Cleanup: `merge_status`, `worktree_status` and `branch_cleanup`.
- Verification: `validation_tier`, `validation_result` and `global_sync_needed`.

Allowed closure protocol: `agent_local_merge_v3`. Human and publication gates stay independent from technical integration.

## Naming

- Cards and handoffs: `YYYY-MM-DD_agente_slug.md`.
- One active worktree and branch per implementation card.
- Queue and handoff placeholders are the tracked `README.md` files in their directories.
