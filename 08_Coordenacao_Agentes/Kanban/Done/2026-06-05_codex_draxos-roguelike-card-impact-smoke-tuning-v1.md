# Card Impact Smoke Tuning V1

- Data: `2026-06-05`
- Agente: `Codex`
- Projeto: `Projetos/draxos-roguelike-cardgame/`
- Branch: `codex/draxos-roguelike-cardgame/card-impact-smoke-tuning-v1`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--card-impact-smoke-tuning-v1`
- Base: `codex/draxos-roguelike-cardgame/card-impact-pack-v1`
- Status: `DONE`

## Entrega

Executado o primeiro ciclo real do Card Impact Pack V1 com fluxo `before -> change -> after -> compare`.

Mudancas de cartas aplicadas:

- `arcano_choque_lvl2`: dano `3 -> 4`, texto atualizado.
- `arcano_choque_lvl3`: dano `3 -> 4`, texto atualizado.
- `invocador_batedor_lvl3`: ataque `6 -> 5`.
- `necro_esqueleto_lvl2`: vida `2 -> 3`.
- `enemy_ar_rajada`: ataque `4 -> 5`.

## Resultado Do Card Impact

- Output: `user://card_impact/smoke_tuning_v1`
- Cobertura: `84/84` cartas ativas, `54` variantes de jogador, `30` cartas inimigas, `15` `elemental_*` legado auditadas.
- Gate compare: PASS.
- Estrutural: `0` erros, `0` novas falhas, `0` registros removidos, `0` mudancas de status.
- Impacto detectado: `enemy_ar_rajada` gerou `damage_to_player_hero` `4 -> 5` e `player_hp` `56 -> 55` no harness isolado.

## Aprendizado

- Um probe temporario em `enemy_terra_guerreiro_terra` causou falhas no Battle Lab do boss map 8 e foi revertido. Isso confirmou que o stack completo pega mudancas inseguras fora do gate estrutural do Card Impact.
- As mudancas em cartas de jogador foram exercitadas, mas nao moveram metricas finais do compare. Proximo refinamento recomendado: Card Impact V2 com deltas derivados de log/efeito para casos de cartas de jogador ou harnesses que exponham melhor variacoes numericas de cartas jogadas.

## Validacao

- `run_card_impact --phase=before --mode=gate --pack=track02_card_impact_v1 --out=user://card_impact/smoke_tuning_v1`: PASS.
- `run_card_impact --phase=after --mode=gate --pack=track02_card_impact_v1 --out=user://card_impact/smoke_tuning_v1`: PASS.
- `run_card_impact --phase=compare --mode=gate --pack=track02_card_impact_v1 --out=user://card_impact/smoke_tuning_v1`: PASS.
- `run_battle_lab --mode=gate --pack=track02_battle_core_v1`: PASS, `9 PASS / 3 WARN / 0 FAIL`.
- `run_scenarios --mode=gate --pack=track02_core_v1`: PASS, `9 PASS / 3 WARN / 0 FAIL`.
- `run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1`: PASS.
- `run_lab --mode=gate --preset=quick --baseline=track02_quick_v1`: PASS.
- `tools/validate.gd`: PASS, `148/148` testes, `1544` asserts, full-route smoke `29/29`.

## Handoff

Worktree deve ficar limpa apos commit. Proximo passo recomendado: escolher entre Card Impact V2 para deltas de efeito/log em cartas de jogador ou um lote maior controlado de cartas usando o mesmo fluxo before/change/after/compare.
