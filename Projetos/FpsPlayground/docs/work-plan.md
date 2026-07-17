# FpsPlayground Work Plan

## Metadata

- status: `active`
- authority: `product_contract`
- last_verified: `2026-07-17`
- review_when: `a planned gameplay sequence is opened, completed or superseded`
- supersedes: `track-by-track work-plan narrative before Governance v2`
- superseded_by: `none`

This document defines safe expansion order. The active baseline and next technical step live only in `../implementation/current-status.md`; completed tracks live in `../implementation/history.md`.

## North Star

Keep `FpsPlayground` a focused first-person arena laboratory for movement, shooting, projectiles, bots, maps and combat feel. Expand through small evidence-backed tracks with explicit rollback points.

## Planned Sequence

### Multi-Arena Balance Baseline

- Compare sessions from all three arenas before tuning.
- Review rifle dominance, Plasma contribution, overcharge/pickup route value, bot route diversity and jump-pad reliability.
- Produce `no change`, `observe` or `candidate tuning` decisions; do not change gameplay in the evidence track.

### Arsenal And Buff Contracts

- Define weapon roles, pickup/buff taxonomy, telemetry requirements and input/UI limits.
- Do not add a weapon before its role, counterplay and evidence fields exist.

### Smallest Evidence-Backed Tuning

- Change only values justified by the multi-arena baseline and a local contract.
- Preserve movement, jump-pad force, map geometry and bot route-control unless the track explicitly targets one of them.

### Arena Production Rules

- Turn the existing layout contract into a checklist for any future arena.
- Require movement routes, tactical context, telemetry targets and a manual smoke script.

### Bot Duel Intelligence

- Improve item, weapon and pressure-route choices without hidden aim, reaction or information advantages.
- Keep route-first movement and readable shot windup.

## Retained Planning Inputs

These are inputs preserved from the Track 13 roadmap, not approved features or tuning decisions.

- New arenas must introduce a distinct duel rhythm and satisfy the authoring contract in `arena-tactical-layouts.md` before implementation.
- Candidate arsenal roles may include close pressure, delayed area denial, positioning utility or high-risk burst, but each needs explicit role, counterplay, input/UI and telemetry contracts first.
- Candidate buffs may affect damage, defense, route access, visibility or cooldowns, but they must create movement decisions, preserve health routing and avoid opaque stacking.
- Future bot work may consider range-aware weapon pressure, item timing and opponent item control, but must stay arena-context driven and expose readable decision reasons.
- Telemetry must answer map, weapon contribution, pickup route value, bot route diversity and jump-pad reliability across repeated sessions; one session is an observation, never balance truth.

## Guardrails

- Human approval is required for movement feel, weapon feel, bot fairness, map quality and tuning.
- Do not tune every arena from one arena's data.
- Do not add buffs that bypass route decisions or aim difficulty that cheats readability.
- Do not add football/TPS, export, multiplayer/backend, Web/mobile, progression or final art without a separately authorized track.
- Follow `../implementation/technical-debt-baseline.md` whenever planned work touches a hotspot.

## Evidence And Validation

- Automated coverage and typed runners: `../qa/QA_INDEX.md`.
- Human journeys: `validation.md`.
- Telemetry interpretation: `telemetry-readout.md` and `balance-baseline.md`.
