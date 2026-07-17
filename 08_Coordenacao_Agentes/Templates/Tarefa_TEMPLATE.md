# Tarefa: <titulo>

## Metadata

- id: `<YYYY-MM-DD_slug>`
- owner: `Fabio | Hermes | Codex | Shared`
- status: `Backlog | Doing | Review | Done`
- projeto: `<project>`
- prioridade_portfolio: `<value from Prioridades_Estudio.md>`
- coordination_scope: `project_local | operations_local | cross_project | portfolio_sync | global_governance | documentation_alignment | implementation | review`
- closure_protocol: `agent_local_merge_v3`
- closure_contract: `estudio_lifecycle_v1`
- closure_mode: `in_progress | merged_pending_human_review | merged_not_required_done | merged_approved_done | merged_rejected_done | merged_superseded_done | n/a`
- technical_status: `pending | pass | fail | superseded`
- human_gate_required: `yes | no`
- human_gate_status: `pending | approved | rejected | not_required | superseded`
- human_gate_scope: `<decision surface | none>`
- human_gate_evidence: `<paths/receipt | n/a>`
- publication_status: `not_requested | not_authorized | dry_run | published_by_fabio`
- blocking_decision: `<exact decision | none>`
- execution_mode: `single_agent | multi_agent`
- delegated_scope: `<bounded scope | none>`
- branch: `<branch>`
- worktree: `<absolute path>`
- base_ref: `main@<sha>`
- commit: `<sha | n/a before first commit>`
- merged_to: `main@<sha> | n/a before merge`
- merge_strategy: `ff-only | n/a before merge`
- merge_status: `pending | merged | abandoned | n/a`
- worktree_status: `open | removed | kept - <reason> | n/a`
- branch_cleanup: `pending | deleted | kept - <reason> | n/a`
- validation_tier: `Docs | QA | Runtime | Build | FullLocal | n/a`
- validation_result: `<commands/results | pending>`
- post_merge_validation: `<command/result | pending | n/a>`
- closure_summary: `<technical result and remaining human/external state | pending>`
- global_sync_needed: `yes | no`

## Goal

Describe the concrete outcome in one sentence.

## Scope

- Include: `<systems/files>`
- Exclude: `<product, remote and project boundaries>`

## Acceptance Criteria

- [ ] Technical result is validated.
- [ ] Human/publication gates are recorded independently.
- [ ] No secret or unauthorized remote mutation occurred.
- [ ] Coordination and portfolio sync state are accurate.
- [ ] Commit reachability, merge target and cleanup receipt are recorded at closure.

## Closeout

- Commits: `<sha subjects>`
- Lifecycle receipt: `<output from close_worktree_powershell.ps1 | pending>`
- Handoff: `none | path`
- Push: `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`
