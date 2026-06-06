# Card Impact V4.1 Card-Flow Harness Pass

- Data: `2026-06-06`
- Agente: `Codex`
- Projeto: `draxos-roguelike-cardgame`
- Branch: `codex/draxos-roguelike-cardgame/card-impact-v4-1-card-flow-harness`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--card-impact-v4-1-card-flow-harness`
- Base: `337d017` / `codex/draxos-roguelike-cardgame/reward-card-redesign-batch-02-utility-v4`

## Objetivo

Implementar `CARD-IMPACT-V4-1-CARD-FLOW-HARNESS-PASS` como etapa tooling-only para tornar deltas de compra, descarte, mao e deck observaveis no Card Impact antes de redesigns maiores de card-flow.

## Arquivos Pretendidos

- `Projetos/draxos-roguelike-cardgame/data/lab/card_impact/track02_card_impact_v4_1.json`
- `Projetos/draxos-roguelike-cardgame/tools/lab/card_impact_pack_loader.gd`
- `Projetos/draxos-roguelike-cardgame/tools/lab/card_impact_matrix.gd`
- `Projetos/draxos-roguelike-cardgame/tools/lab/battle_runner.gd`
- `Projetos/draxos-roguelike-cardgame/tools/lab/battle_effect_signature.gd`
- `Projetos/draxos-roguelike-cardgame/tools/lab/lab_diff_reporter.gd`
- `Projetos/draxos-roguelike-cardgame/tools/lab/card_impact_reporter.gd`
- `Projetos/draxos-roguelike-cardgame/tests/unit/test_card_impact_tooling.gd`
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
- `Projetos/draxos-roguelike-cardgame/AGENTS.md`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/validation-and-tuning-notes.md`
- `Projetos/draxos-roguelike-cardgame/docs/autorun-lab.md`

## Validacao Planejada

1. `run_card_impact --phase=before --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/track02_card_impact_v4_1_card_flow_harness`
2. `run_card_impact --phase=after --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/track02_card_impact_v4_1_card_flow_harness`
3. `run_card_impact --phase=compare --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/track02_card_impact_v4_1_card_flow_harness`
4. `run_card_impact --phase=compare --mode=gate --pack=track02_card_impact_v4 --out=user://card_impact/reward_card_redesign_batch_02_utility_v4`
5. `run_battle_lab --mode=gate --pack=track02_battle_core_v1`
6. `run_scenarios --mode=gate --pack=track02_core_v1`
7. `run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1`
8. `run_lab --mode=gate --preset=quick --baseline=track02_quick_v1`
9. `tools/validate.gd`

## Handoff

V4.1 entregue e validado. O pacote `track02_card_impact_v4_1` preserva cobertura V4, adiciona 2 casos card-flow esperados (`necro_colheita_das_almas`, `necro_colheita_das_almas_lvl3`), registra `card_flow_expected/observed/missing_reason`, mostra `Card Flow Coverage` no Markdown e usa `initial_dead_unit_count=2` como prestate de lab apenas no caso lvl3.

## Resultado

- `run_card_impact --phase=before --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/track02_card_impact_v4_1_card_flow_harness`: PASS.
- `run_card_impact --phase=after --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/track02_card_impact_v4_1_card_flow_harness`: PASS.
- `run_card_impact --phase=compare --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/track02_card_impact_v4_1_card_flow_harness`: PASS.
- `run_card_impact --phase=compare --mode=gate --pack=track02_card_impact_v4 --out=user://card_impact/reward_card_redesign_batch_02_utility_v4`: PASS.
- `run_battle_lab --mode=gate --pack=track02_battle_core_v1`: 9 PASS / 3 WARN / 0 FAIL.
- `run_scenarios --mode=gate --pack=track02_core_v1`: 9 PASS / 3 WARN / 0 FAIL.
- `run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1`: PASS.
- `run_lab --mode=gate --preset=quick --baseline=track02_quick_v1`: PASS.
- `tools/validate.gd`: PASS, 185/185 GUT tests, 1766 asserts.

## Proximo Ponto

Usar V4.1 em um pequeno redesign real de card-flow com fluxo `before -> change -> after -> compare`; depois decidir se algum threshold ou secao de relatorio deve virar expectativa promovida. Assinaturas causais de cartas inimigas continuam como follow-up tecnico.
