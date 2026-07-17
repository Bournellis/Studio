# FpsPlayground Human-Gate Triage

## Metadata

- status: `active`
- authority: `local_state`
- last_verified: `2026-07-16`
- review_when: `a card enters or leaves Kanban/Review`
- supersedes: `none`
- superseded_by: `none`

## Pending Human Decisions

None. `Kanban/Review/` is empty.

The preserved human-authority surfaces for future work are movement feel, weapon feel, bot fairness, map quality and tuning. They are documented as manual capabilities in `../qa/QA_INDEX.md`; they become triage entries only when a concrete card requests a decision.

## Rule

Every entry here must point to exactly one card in `Kanban/Review/` with `human_gate_status: pending`, explicit evidence and an exact `blocking_decision`.
