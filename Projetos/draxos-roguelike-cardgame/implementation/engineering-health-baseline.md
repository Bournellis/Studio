# Baseline de saude de engenharia - Draxos Roguelike Cardgame

## Metadata

- status: living
- authority: technical_contract
- last_verified: 2026-07-17
- review_when: arquivo listado mudar de tamanho, responsabilidade ou cobertura
- supersedes: `52f52f7cd33d1711579f9cccbe4c848ab45a02e4:Projetos/draxos-roguelike-cardgame/docs/foundation-closeout.md`
- superseded_by: none

Contagens excluem `addons/` e foram medidas no cutover da Governanca v2.

## Allowlist acima de 1.000 linhas

| Arquivo | Linhas | Razao preservada | Review when |
|---|---:|---|---|
| `battle/battle_engine.gd` | 2965 | facade de compatibilidade com regras Track 02 e diretores ja extraidos | nova responsabilidade, mudanca de contrato ou crescimento |
| `modes/battle/battle_root.gd` | 1742 | raiz de composicao da cena coberta por presenters e regressao | nova responsabilidade, mudanca visual estrutural ou crescimento |
| `tests/unit/test_card_impact_tooling.gd` | 1299 | regressao historica integrada do Card Impact V1-V5 | novo dominio de teste ou crescimento |

## Avisos entre 700 e 1.000 linhas

| Arquivo | Linhas | Razao preservada | Review when |
|---|---:|---|---|
| `core/run_session.gd` | 912 | estado de run e wrappers compativeis com servicos extraidos | nova responsabilidade ou crescimento |
| `tools/lab/battle_runner.gd` | 818 | executor deterministico compartilhado pelos labs | novo tipo de execucao ou crescimento |
| `tools/lab/card_impact_runner.gd` | 790 | orquestracao das assinaturas V1-V5 | nova familia de impacto ou crescimento |
| `tools/validate.gd` | 729 | orquestrador integral de contratos oficiais | novo subsistema de validacao ou crescimento |

## Regra de toque

- arquivo acima de 1.000 linhas nao pode crescer sem extracao ou excecao registrada;
- nova responsabilidade exige extracao;
- correcao cirurgica de ate 20 linhas e aceita somente sem nova responsabilidade e com regressao proporcional;
- esta migracao registra divida e bloqueia crescimento; nao autoriza refatoracao em massa.
