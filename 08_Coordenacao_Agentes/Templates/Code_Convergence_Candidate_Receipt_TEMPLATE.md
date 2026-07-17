# Recibo de candidato de convergencia: <candidate_id>

## Metadata

- status: template
- authority: operational_contract
- last_verified: 2026-07-17
- review_when: o candidato, seus commits ou contratos locais mudar
- supersedes: none
- superseded_by: none

## State

- candidate_id: `<stable_id>`
- status: `observation`
- registry_mode: `read_only`
- shared_core_created: `no`
- owner: `<owner>`
- recorded_at: `YYYY-MM-DD`

## Observed implementations

| project | commit | literal_path | sha256 | responsibility |
|---|---|---|---|---|
| `<project_a>` | `<sha>` | `<path>` | `<hash>` | `<behavior>` |
| `<project_b>` | `<sha>` | `<path>` | `<hash>` | `<behavior>` |

## Compatibility

- common_behavior: `<verified overlap>`
- required_differences: `<product, platform, persistence or API differences>`
- local_contracts: `<paths>`
- regression_tests: `<paths and commands>`
- ownership_and_versioning: `<proposal or unresolved>`
- dependency_cost: `<assessment>`
- rollback: `<local restoration plan>`

## Decision boundary

- proposed_next_state: `<keep_local|local_adoption_proposed|extraction_proposed|reject>`
- required_authority: `<cross_project|global_governance|Fabio decision>`
- blocking_decision: `<exact decision or none>`
- evidence: `<read-only reports and diffs>`

Este recibo nao altera os projetos observados. Qualquer adocao ou extracao exige tarefa propria, autores identificados e validacao local de cada projeto.
