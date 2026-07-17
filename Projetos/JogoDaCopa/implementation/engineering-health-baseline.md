# Baseline de saúde de engenharia — JogoDaCopa

## Metadata

- status: living
- authority: technical_contract
- last_verified: 2026-07-16
- review_when: arquivo listado for tocado, extraído ou mudar de contagem
- supersedes: none
- superseded_by: none

Contagem no commit-base `d69456d8`; `addons/` excluído do limite de linhas. Esta allowlist não autoriza crescimento nem nova responsabilidade.

## Acima de 1.000 linhas

| Arquivo | Linhas | Razão preservada | Regra ao tocar |
|---|---:|---|---|
| `tests/unit/test_bootstrap.gd` | 2000 | suíte histórica integrada de contratos de bootstrap | extrair por domínio antes de ampliar cobertura |
| `modes/menu/main_menu_root.gd` | 1209 | composição histórica do menu e seleção | responsabilidade nova exige extração |
| `presentation/hud/football_hud.gd` | 1148 | fachada histórica de HUD e compatibilidade | responsabilidade nova exige extração |
| `gameplay/avatar/player_avatar_3d.gd` | 1100 | apresentação e adaptação histórica do avatar | responsabilidade nova exige extração |

## Warning de 701 a 1.000 linhas

- `presentation/feedback/fps_feedback_controller.gd`: 937.
- `modes/football/football_root.gd`: 919.
- `modes/football/football_field_builder.gd`: 899.

Correção cirúrgica de até 20 linhas só é aceitável sem nova responsabilidade, sem ultrapassar a baseline e com regressão. Fora disso, decomponha primeiro.
