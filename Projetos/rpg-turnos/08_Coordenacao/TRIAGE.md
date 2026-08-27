# RPG Turnos Triage

## Metadata

- status: `active`
- authority: `runbook`
- last_verified: `2026-08-27`
- review_when: `portfolio permissions or the closure protocol changes`
- supersedes: `none`
- superseded_by: `none`

## Route The Request

1. Read the Studio portfolio authority and the local technical state.
2. Classify scope as `project_local`, `operations_local`, `review`, `portfolio_sync`, `cross_project` or `global_governance`.
3. Keep local scopes in this directory; route the other three to the Studio coordination writer.
4. A paused project accepts only the explicitly requested integrity, documentation or historical scope. A local card never resumes product work.

## Queue Rules

- `Backlog`: bounded proposal with no implied authorization.
- `Doing`: an authorized task with named branch, worktree, base ref, files and validation.
- `Review`: technical work is integrated or ready, and a concrete human decision remains pending.
- `Done`: technical outcome and every required gate are final, including rejected or superseded work.

## Gate Rules

- Product direction, playability, visual quality, balance, release and publication are human gates.
- `human_gate_required: no` requires `human_gate_status: not_required`.
- `Done` rejects `human_gate_status: pending`.
- Product/backend remote mutation, publication, device testing and portfolio priority changes remain hard stops; routine Git synchronization follows the global contract.
