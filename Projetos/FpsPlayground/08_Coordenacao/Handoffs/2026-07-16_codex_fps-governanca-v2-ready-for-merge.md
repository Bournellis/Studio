# Handoff: FpsPlayground Governance v2 Ready For Merge

## Metadata

- from: `Codex - FPS project agent`
- to: `Codex - Governance v2 lead`
- date: `2026-07-16`
- projeto: `FpsPlayground`
- coordination_scope: `project_local`
- closure_protocol: `agent_local_merge_v3`
- technical_status: `pass`
- human_gate_required: `no`
- human_gate_status: `not_required`
- human_gate_scope: `none`
- human_gate_evidence: `n/a`
- publication_status: `not_authorized`
- blocking_decision: `none`
- execution_mode: `multi_agent`
- delegated_scope: `all writes under Projetos/FpsPlayground`
- branch: `codex/fpsplayground/governanca-v2`
- worktree: `D:\Estudio-worktrees\fpsplayground--codex--governanca-v2`
- base_ref: `main@584733b071dd944876b05b4ebb728e71368a3ee3`
- merge_status: `pending`
- worktree_status: `open`
- branch_cleanup: `pending`
- validation_tier: `Runtime`
- validation_result: `pass`
- global_sync_needed: `yes`
- commits: `af36d382 docs; b5bbf542 docs/history; 641d857c QA; coordination closeout`

## Outcome

The FPS project now has local-first coordination, a 51-line local state, curated history, prospective debt controls and a typed QA contract. No gameplay, tuning, priority, UID, build, publication or human decision changed.

## Changed Surface

- `08_Coordenacao/**`
- `AGENTS.md`, `README.md`, living `docs/**`
- `implementation/current-status.md`, `history.md`, `technical-debt-baseline.md`
- `qa/qa_manifest.json`, `qa/QA_INDEX.md`

## Validation And Evidence

- QA manifest schema and index ID parity: `PASS`.
- Local Markdown links: `PASS`, 14 files and 14 links checked.
- Fast structure/rules/telemetry runners: exit `0`, no tracked side effects; global timing baseline remains intentionally unmeasured.
- Runtime run 1: `PASS`, full validator exit `0`, no tracked side effects.
- Runtime run 2: `PASS`, GUT `67/67`, `599 asserts`, no tracked side effects.
- `git diff --check`: `PASS`.

## Preserved Human Gates

Movement feel, weapon feel, bot fairness, map quality and balance tuning remain Fabio-owned. No decision is currently pending in local `Review`.

## Next Step

Governance lead rebases if `main` advances, performs pre/post-merge validation, merges locally with `ff-only`, consumes `global_sync_needed`, then removes worktree and branch. No push is authorized.
