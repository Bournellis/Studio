# Card Flow Expectations V4.2

- Data: `2026-06-06`
- Agente: `Codex`
- Projeto: `draxos-roguelike-cardgame`
- Branch: `codex/draxos-roguelike-cardgame/card-flow-expectations-v4-2`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--card-flow-expectations-v4-2`
- Base: `dda67ba` / `codex/draxos-roguelike-cardgame/card-flow-redesign-batch-01-v4-1`

## Objetivo

Implementar `Card Impact V4.2 - Card Flow Expectations` como etapa tooling-only para promover os deltas de card-flow observados em V4.1 para expectations explicitas de regressao, sem alterar gameplay, cartas, inimigos, rota, rewards, loja, relics ou balanceamento.

## Arquivos Pretendidos

- `Projetos/draxos-roguelike-cardgame/data/lab/card_impact/track02_card_impact_v4_2.json`
- `Projetos/draxos-roguelike-cardgame/tools/lab/card_impact_pack_loader.gd`
- `Projetos/draxos-roguelike-cardgame/tools/lab/card_impact_runner.gd`
- `Projetos/draxos-roguelike-cardgame/tools/lab/card_impact_reporter.gd`
- `Projetos/draxos-roguelike-cardgame/tests/unit/test_card_impact_tooling.gd`
- status/docs locais e coordenacao conforme necessario

## Docs Lidos

- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
- `Projetos/draxos-roguelike-cardgame/AGENTS.md`

## Validacao Planejada

- `run_card_impact --phase=before --mode=gate --pack=track02_card_impact_v4_2 --out=user://card_impact/track02_card_impact_v4_2_card_flow_expectations`
- `run_card_impact --phase=after --mode=gate --pack=track02_card_impact_v4_2 --out=user://card_impact/track02_card_impact_v4_2_card_flow_expectations`
- `run_card_impact --phase=compare --mode=gate --pack=track02_card_impact_v4_2 --out=user://card_impact/track02_card_impact_v4_2_card_flow_expectations`
- `run_card_impact --phase=compare --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/card_flow_redesign_batch_01_v4_1`
- `run_battle_lab --mode=gate --pack=track02_battle_core_v1`
- `run_scenarios --mode=gate --pack=track02_core_v1`
- `run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1`
- `run_lab --mode=gate --preset=quick --baseline=track02_quick_v1`
- `tools/validate.gd`

## Handoff

Entregar branch commitada com V4.2, reports atualizados, testes e validacao final registrada. Ponto de handoff seguinte: usar V4.2 como default recomendado antes de novos redesigns de card-flow/reward cards.

## Resultado

- `track02_card_impact_v4_2` implementado com 108 player cards, 30 enemy report-only cards, 15 legacy inactive cards e 3 card-flow player cards esperadas.
- `card_flow_expectations` implementado com 21 checks para Colheita base/Lvl 2/Lvl 3: 12 required e 9 watch.
- Gate V4.2 bloqueia required failures e mantem deltas numericos intencionais como review/WARN quando ainda cumprem required.
- Relatorios Card Impact agora incluem secao `Card Flow Expectations` em Markdown, gate e CSV.

## Validacao Executada

- `run_card_impact --phase=before --mode=gate --pack=track02_card_impact_v4_2 --out=user://card_impact/track02_card_impact_v4_2_card_flow_expectations`: PASS.
- `run_card_impact --phase=after --mode=gate --pack=track02_card_impact_v4_2 --out=user://card_impact/track02_card_impact_v4_2_card_flow_expectations`: PASS.
- `run_card_impact --phase=compare --mode=gate --pack=track02_card_impact_v4_2 --out=user://card_impact/track02_card_impact_v4_2_card_flow_expectations`: PASS, 21/21 expectations.
- `run_card_impact --phase=compare --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/card_flow_redesign_batch_01_v4_1`: PASS.
- `run_battle_lab --mode=gate --pack=track02_battle_core_v1`: PASS, 9 PASS / 3 WARN / 0 FAIL.
- `run_scenarios --mode=gate --pack=track02_core_v1`: PASS, 9 PASS / 3 WARN / 0 FAIL.
- `run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1`: PASS.
- `run_lab --mode=gate --preset=quick --baseline=track02_quick_v1`: PASS.
- `tools/validate.gd`: PASS depois do import padrao da worktree, 199/199 GUT tests e 1827 asserts.

## Proximo Handoff

Usar `REWARD-CARD-REDESIGN-BATCH-03-USING-V4-2`: executar o proximo batch maior de reward cards com `before -> change -> after -> compare` no V4.2; se uma reducao intencional de card-flow for aceita, atualizar a expectation V4.2 no mesmo trabalho.
