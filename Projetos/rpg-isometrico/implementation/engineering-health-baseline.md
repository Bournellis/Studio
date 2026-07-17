# Baseline de saúde de engenharia — RPG Isométrico

## Metadata

- status: living
- authority: technical_contract
- last_verified: 2026-07-16
- review_when: arquivo listado for tocado, extraído ou mudar de contagem
- supersedes: none
- superseded_by: none

Contagem no commit-base `584733b0`; `addons/` excluído do limite. A allowlist não autoriza crescimento ou nova responsabilidade.

## Acima de 1.000 linhas

| Arquivo | Linhas | Razão preservada | Regra ao tocar |
|---|---:|---|---|
| `modes/frontend/frontend_root.gd` | 1920 | composição histórica de frontend, rotas e builders | responsabilidade nova exige extração |

## Warning de 701 a 1.000 linhas

- `modes/campaign/campaign_root.gd`: 947.
- `tests/unit/test_frontend_flow.gd`: 716.

Correção cirúrgica de até 20 linhas exige regressão, não pode adicionar responsabilidade nem ultrapassar a baseline. Fora disso, decomponha primeiro. A pausa não autoriza refatoração em massa.
