# FpsPlayground QA Index

## Metadata

- status: `active`
- authority: `technical_contract`
- last_verified: `2026-07-16`
- review_when: `runner, capability, timeout, gate or validation baseline changes`
- supersedes: `validation command routing spread across live docs before Governance v2`
- superseded_by: `none`

`qa_manifest.json` is the machine-readable authority for commands, timeouts and environments. This index explains intent, journeys, human gates and evidence. IDs must match exactly.

## Runners

- runner_id: `fps_fast_structure`
  - Fast Godot structure profile: deterministic scene generation, project resources and generated-scene loading.
- runner_id: `fps_fast_rules`
  - Selected GUT rule suite for combat, layouts, pickups, jump pads and bot decisions.
- runner_id: `fps_fast_telemetry`
  - Selected GUT telemetry and readout suites.
- runner_id: `fps_runtime_full`
  - Full local validator and complete GUT baseline; used by Runtime and FullLocal.

Fresh worktrees may need a one-time headless editor import before the GUT global-class cache exists. That warm-up may write only ignored `.godot/` cache. Every declared runner must leave tracked state unchanged.

## Automated And Manual Capabilities

- capability_id: `arena_selection_and_duel_flow`
  - Automated menu, three-arena boot, round, score and reset coverage.
- capability_id: `weapon_contracts`
  - Automated rifle, Plasma, blast, overcharge, damage and knockback contracts.
- capability_id: `bot_route_control`
  - Automated tactical context, route scoring, item priority, shooting overlay and jump-pad commitment.
- capability_id: `pickup_and_jump_pad_contracts`
  - Automated pickup collection/respawn and approved launch-force coverage.
- capability_id: `pause_resume_and_return`
  - Manual pause, resume, restart and return-to-menu journey from `../docs/validation.md`.
- capability_id: `telemetry_lifecycle_and_readout`
  - Automated local schema, files, lifecycle, reset ordering, summaries and readout alerts.
- capability_id: `movement_feel_gate`
  - Fabio decides responsiveness and whether approved movement feel remains intact.
- capability_id: `weapon_feel_gate`
  - Fabio decides readability, commitment and role balance.
- capability_id: `bot_fairness_gate`
  - Fabio decides reaction, aim readability and pressure fairness.
- capability_id: `map_quality_gate`
  - Fabio decides flow, route value, arena readability and jump-pad feel.
- capability_id: `balance_tuning_gate`
  - Fabio decides any tuning after reviewing evidence from all arenas.
- capability_id: `desktop_build_export`
  - Explicit active-project gap: no Build configuration; see `../docs/publication-readiness.md`.
- capability_id: `network_backend_and_device`
  - Not applicable to this local desktop gameplay laboratory.

## Profiles

- `FastSuite`: structure, selected rules and telemetry suites.
- `Runtime`: complete `tools/validate.gd --profile=full` baseline.
- `FullLocal`: Runtime only; there is no additional platform lane.
- `Build`: not configured and excluded from supported project profiles.

## Acceptance Baseline

- Full Runtime: GUT `67/67`, `599 asserts`.
- Runtime is executed twice for migration acceptance; both runs must produce the same clean tracked Git state.
- Build/export, remote services and physical-device validation remain outside automation and are not approved by a green Runtime.

## Human Evidence

Human evidence follows `../docs/validation.md` and is attached to a concrete `../08_Coordenacao/Kanban/Review/` card only when a decision is actually requested.

A general gameplay approval cannot approve export, publication, priority or unrelated tuning.
