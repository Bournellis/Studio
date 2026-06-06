# Card Flow Redesign Batch 01 Using V4.1

- Data: `2026-06-06`
- Agente: `Codex`
- Projeto: `draxos-roguelike-cardgame`
- Branch: `codex/draxos-roguelike-cardgame/card-flow-redesign-batch-01-v4-1`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--card-flow-redesign-batch-01-v4-1`
- Base: `29a8d41` / `codex/draxos-roguelike-cardgame/card-impact-v4-1-card-flow-harness`

## Objetivo

Executar um redesign pequeno e real de card-flow usando Card Impact V4.1 no fluxo `before -> change -> after -> compare`, com foco em validar que deltas de compra/deck/mao aparecem como sinal de impacto sem promover tuning amplo.

## Escopo

- Ajustar somente cartas de jogador ja cobertas pelo card-flow V4.1.
- Nao alterar inimigos, rota, loja, rewards, relics, encounters, UI ou ferramentas de gameplay fora do necessario para docs/status/testes.
- Preservar V4.1 como harness/gate explicito.

## Arquivos Pretendidos

- `Projetos/draxos-roguelike-cardgame/data/definitions/slice_catalog.json`
- `Projetos/draxos-roguelike-cardgame/data/generated/slice_catalog.tres`
- `Projetos/draxos-roguelike-cardgame/tests/unit/test_keywords.gd`
- `Projetos/draxos-roguelike-cardgame/docs/autorun-lab.md`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/validation-and-tuning-notes.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/handoff-log.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-roguelike-cardgame/AGENTS.md`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/validation-and-tuning-notes.md`

## Validacao Planejada

1. `run_card_impact --phase=before --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/card_flow_redesign_batch_01_v4_1`
2. aplicar batch pequeno de card-flow;
3. `run_card_impact --phase=after --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/card_flow_redesign_batch_01_v4_1`
4. `run_card_impact --phase=compare --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/card_flow_redesign_batch_01_v4_1`
5. `run_battle_lab --mode=gate --pack=track02_battle_core_v1`
6. `run_scenarios --mode=gate --pack=track02_core_v1`
7. `run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1`
8. `run_lab --mode=gate --preset=quick --baseline=track02_quick_v1`
9. `tools/validate.gd`

## Handoff

Entregar batch commitado, com impacto card-flow documentado, gates verdes e proxima etapa recomendada.

## Resultado

- `draw_if_at_least` agora resolve como compra bonus apos refill normal de mao.
- `necro_colheita_das_almas_lvl2` mudou Ashes `2 -> 3`, ganhou `draw_if_at_least=3` e entrou no card-flow esperado.
- `track02_card_impact_v4_1` agora exige 3 cartas card-flow esperadas.
- Compare V4.1 em `user://card_impact/card_flow_redesign_batch_01_v4_1`: PASS, 0 structural errors, 0 new failures, 0 removed records, 3 changed battle records, 11 effect deltas.
- Deltas principais: `cards_drawn 1 -> 2`, `deck_delta -1 -> -2`, `hand_delta 0 -> 1` em Colheita base/Lvl 2/Lvl 3; Lvl 2 tambem `ashes_gained 2 -> 3`.

## Validacao Executada

- `run_card_impact --phase=before --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/card_flow_redesign_batch_01_v4_1`: PASS.
- `run_card_impact --phase=after --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/card_flow_redesign_batch_01_v4_1`: PASS.
- `run_card_impact --phase=compare --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/card_flow_redesign_batch_01_v4_1`: PASS.
- `run_battle_lab --mode=gate --pack=track02_battle_core_v1`: 9 PASS / 3 WARN / 0 FAIL.
- `run_scenarios --mode=gate --pack=track02_core_v1`: 9 PASS / 3 WARN / 0 FAIL.
- `run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1`: PASS.
- `run_lab --mode=gate --preset=quick --baseline=track02_quick_v1`: PASS.
- `tools/validate.gd`: PASS, 187/187 GUT tests, 1785 asserts.

## Proximo Handoff

Recomendo `CARD-FLOW-EXPECTATION-PROMOTION-REVIEW`: revisar se campos V4.1 de card-flow devem virar expectations explicitas antes do proximo batch maior de reward cards.
