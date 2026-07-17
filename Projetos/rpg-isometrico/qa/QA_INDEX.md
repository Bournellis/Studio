# QA Index — RPG Isométrico

## Metadata

- status: living
- authority: technical_contract
- last_verified: 2026-07-16
- review_when: runner, jornada, gate ou estado de pausa mudar
- supersedes: none
- superseded_by: none

O manifesto JSON governa comandos. Este índice governa jornadas, leitura humana e limites da pausa. IDs correspondem exatamente.

## Runners

- runner_id: `contracts_fast`
- runner_id: `runtime_full`

## Jornadas

- capability_id: `campaign`
- capability_id: `profile`
- capability_id: `save`
- capability_id: `modes`
- capability_id: `human_playability`

FastSuite executa a regressão GUT local, pequena o bastante para o budget. Runtime acrescenta geração oficial, contrato de loadout, carga de cenas e a mesma regressão integral.

Runtime e FastSuite só rodam com seleção explícita deste projeto. Não há Build configurado, remoto, publicação ou gate humano durante a pausa. Retomar playability review exige decisão de portfólio anterior à execução de produto.
