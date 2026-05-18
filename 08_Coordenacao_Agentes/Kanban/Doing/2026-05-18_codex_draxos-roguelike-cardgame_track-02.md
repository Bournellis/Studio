# Tarefa: Draxos Roguelike Cardgame Track 02

## Metadata

- id: `2026-05-18_codex_draxos-roguelike-cardgame_track-02`
- owner: `Codex`
- status: `Doing`
- projeto: `draxos-roguelike-cardgame`
- prioridade_portfolio: `P0_IMPLEMENTACAO`

## Goal

Evoluir o slice validado de 13 mapas para a primeira versao completa do jogo: run linear fixa de 29 mapas, recompensas revisadas, reliquias universais, loja expandida, todas as keywords, AI inimiga melhorada, painel de intencao, novos modos/formatos de encontro e melhoria visual de mapa/batalha/recompensas.

## Technical Scope

- `track-02-complete-run-evolution`
- `RunSession`
- `RewardSystem`
- `RelicSystem`
- `SoulsShop`
- `KeywordTooltips`
- `BattleEngine`
- `EnemyAI`
- `RunMap`
- `Battle`
- `slice_catalog.json`

## Out of Scope

- Conta/meta progressao permanente.
- Track 03.
- Retomar projetos pausados.
- Mudar passivas/ativas fixas de classe fora do plano aprovado.

## Expected Files

- `implementation/tracks/track-02-complete-run-evolution/`
- `implementation/current-status.md`
- `data/definitions/slice_catalog.json`
- `tools/validate.gd`

## Acceptance Criteria

- [ ] `T02-P01` conclui contrato de dados/save/validacao.
- [ ] `T02-P02` conclui recompensas e progressao de mana/mao/HP.
- [ ] `T02-P03` conclui reliquias e loja expandida.
- [ ] `T02-P04` conclui vocabulario de keywords e tooltips.
- [ ] `T02-P05` conclui engine completo de keywords.
- [ ] `T02-P06` conclui cartas novas e inimigos.
- [ ] `T02-P07` conclui AI inimiga e painel de intencao.
- [ ] `T02-P08` conclui rota 29 mapas, novos encontros, formatos, field effects e bosses.
- [ ] `T02-P09` conclui polish, telemetria, validacao de rota e tuning inicial.
- [ ] Cada thread atualiza `handoff-log.md`.
- [ ] Validacao Godot fica verde apos cada prompt de implementacao.

## Handoff Needed

`Yes - to Codex`

## Notes

Prompts copia-e-cola vivem em `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/implementation-prompts.md`.
