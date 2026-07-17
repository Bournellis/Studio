# QA Index - Draxos Roguelike Cardgame

## Metadata

- status: living
- authority: technical_contract
- last_verified: 2026-07-16
- review_when: runner, jornada, gate, ambiente ou baseline mudar
- supersedes: roteamento implicito por tools/validate.gd e docs de labs
- superseded_by: none

`qa_manifest.json` governa comandos, argumentos, timeouts e ambientes. Este indice governa leitura humana, jornadas, gates e evidencias; os IDs correspondem exatamente.

## Runners

- runner_id: `roguelike_fast_contracts`
- runner_id: `roguelike_runtime_full`
- runner_id: `run_lab_smoke_gate`
- runner_id: `scenario_fixture_gate`
- runner_id: `battle_lab_gate`
- runner_id: `card_impact_v5_gate`
- runner_id: `design_lab_sample_gate`

Fast executa o GUT completo e cobre dados, keywords, AI/intent, batalha por lanes e save/recompensas. Runtime executa `tools/validate.gd` integralmente.

Labs existem somente na lane `lab` de `FullLocal`, escrevem em `user://` e nao aprovam produto.

## Jornadas criticas

- capability_id: `data_catalog`
- capability_id: `keyword_engine`
- capability_id: `enemy_ai_intent`
- capability_id: `lane_battle`
- capability_id: `save_snapshot_v5`
- capability_id: `route_29_maps`
- capability_id: `three_classes`
- capability_id: `rewards_relics_souls`
- capability_id: `scenario_and_card_labs`
- capability_id: `design_lab_promotion`
- capability_id: `balance_and_pacing`
- capability_id: `complete_run_feel`
- capability_id: `publication`

## Gates e evidencias

- Runtime deve preservar `226/226` testes e `1.975` asserts e rodar duas vezes sem alterar arquivos rastreados.
- A rota automatizada deve permanecer `29/29`; Arcano, Invocador e Necromante continuam cobertos.
- Promocao do Design Lab, balanceamento/pacing e sensacao da run sao gates humanos em `../08_Coordenacao/Kanban/Review/`.
- Warnings opcionais de arte, recursos GUT e alpha da nave sao conhecidos e nao fatais; novos warnings exigem triagem.
- Evidencia historica permanece nos registros da Track 02 e em `user://`; novos bundles rastreados seguem `estudio_evidence_v1`.
- Nenhum runner autoriza remoto, publicacao, retomada de produto ou mudanca de prioridade.
