# Tarefa: FpsPlayground Governance v2 Migration

## Metadata

- id: `2026-07-16_codex_fps-governanca-v2`
- owner: `Codex`
- status: `Doing`
- projeto: `FpsPlayground`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- coordination_scope: `project_local`
- closure_protocol: `agent_local_merge_v3`
- technical_status: `pending`
- human_gate_required: `no`
- human_gate_status: `not_required`
- human_gate_scope: `none`
- human_gate_evidence: `n/a`
- publication_status: `not_authorized`
- blocking_decision: `none`
- execution_mode: `multi_agent`
- delegated_scope: `local coordination, documentation, QA contract and debt baseline under Projetos/FpsPlayground`
- branch: `codex/fpsplayground/governanca-v2`
- worktree: `D:\Estudio-worktrees\fpsplayground--codex--governanca-v2`
- base_ref: `main@756e82ebedc6fbdde7186faa15c1bd2e7683da2c`
- merge_status: `pending`
- worktree_status: `open`
- branch_cleanup: `pending`
- validation_tier: `Runtime`
- validation_result: `pending`
- global_sync_needed: `yes`
- handoff_status: `in_progress`

## Goal

Adopt local-first coordination, compact state, typed QA and prospective debt controls without changing the approved FPS product baseline.

## Scope

- Include: `08_Coordenacao/`, living documentation, `qa/` and documentation-only integrity work.
- Exclude: gameplay, tuning, product priority, UIDs, global/canon files, build/export, remote actions and human approvals.

## Intended Files

- `08_Coordenacao/**`
- `AGENTS.md`, `README.md`, `docs/**`
- `implementation/current-status.md`, `implementation/history.md`, `implementation/technical-debt-baseline.md`
- `qa/qa_manifest.json`, `qa/QA_INDEX.md`

## Validation Plan

- Governance/QA schema and Markdown ID parity.
- Document metadata, budgets, UTF-8, links and `git diff --check`.
- Runtime `tools/validate.gd --profile=full` twice with exactly `67/67`, `599 asserts` and no tracked side effects.

## Acceptance Criteria

- [ ] Local coordination structure and v3 card are present.
- [ ] Current status is at most 60 lines and history is preserved outside it.
- [ ] QA covers arenas, weapons, bot, pickups, pause and telemetry.
- [ ] Human authority over movement, weapons, bot fairness, maps and tuning remains explicit.
- [ ] Technical debt cannot grow when touched without extraction or exception.
- [ ] Runtime passes twice without tracked changes.

## Closeout

- Commits: `pending`
- Handoff: `pending`
- Push: `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`
