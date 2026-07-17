# Engineering Health Baseline

## Metadata

- status: `active`
- authority: `technical_contract`
- last_verified: `2026-07-16`
- review_when: `either allowlisted file changes or the project resumes`
- supersedes: `none`
- superseded_by: `none`

This baseline records existing debt; it does not authorize new product work or a broad refactor while the project is paused.

## Allowlisted Files

| File | Baseline | Classification | Existing responsibility |
|---|---:|---|---|
| `battle/battle_engine.gd` | 2081 lines | failure threshold exception | C1 rules, six encounter modes, class mechanics and resolution pipeline |
| `modes/battle/battle_root.gd` | 891 lines | warning threshold | battle assembly, targeting and presentation adapter |

## Prospective Guardrail

- Existing files above 1000 lines must not grow beyond the recorded baseline without an extraction and focused regression coverage.
- A surgical correction of at most 20 lines is allowed only when it adds no responsibility and includes a regression test.
- New behavior belongs in a narrower rules, mode or presentation component instead of either allowlisted file.
- Addons and generated resources are outside the source-line threshold; generated files must remain deterministic.
- A future decomposition is triggered when the affected file is touched for a new responsibility or when the portfolio explicitly resumes the project.

## Validation Reference

- Runtime contract: `../tools/validate.gd`.
- QA routing: `../qa/QA_INDEX.md`.
- Latest validated totals remain in `current-status.md`.
