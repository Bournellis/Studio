# Draxos Roguelike Cardgame - Foundation Hardening 5

- Data: `2026-05-27`
- Agente: `Codex`
- Branch: `codex/draxos-roguelike-cardgame/foundation-hardening-5`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--foundation-hardening-5`
- Base: `43fde93` (`codex/draxos-roguelike-cardgame/foundation-hardening-4`)

## Objetivo

Executar a Foundation Pass 5 - Run Economy Services: extrair mutacoes da Souls shop de `RunSession` para `core/run_shop_service.gd`, mantendo `RunSession` como dono do estado e preservando API publica, snapshot v5, `shop_state`, `reward_category_state`, Souls e metricas do Run Lab.

## Arquivos Pretendidos

- `Projetos/draxos-roguelike-cardgame/core/run_session.gd`
- `Projetos/draxos-roguelike-cardgame/core/run_shop_service.gd`
- `Projetos/draxos-roguelike-cardgame/tests/unit/test_run_rewards_shop_save.gd`
- `Projetos/draxos-roguelike-cardgame/tools/run_lab_golden_metrics.gd` somente se o schema de comparacao exigir ajuste
- `Projetos/draxos-roguelike-cardgame/docs/architecture.md`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-roguelike-cardgame/AGENTS.md`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`

## Validacao Planejada

- Rodar baseline `validate.gd` antes de editar.
- Rodar Run Lab com `--compare-golden --require-golden` antes de editar.
- Extrair shop em passos pequenos mantendo wrappers publicos em `RunSession`.
- Adicionar/ajustar GUT para confirmar delegacao do shop service e preservacao de payloads.
- Rodar `validate.gd` duas vezes no final e confirmar ausencia de churn gerado.
- Rodar Run Lab final com `--compare-golden --require-golden`.

## Handoff

Status final: Foundation Pass 5 implementado. `RunSession` permanece dono do estado e API publica; `core/run_shop_service.gd` agora concentra ofertas, compras, rerolls, remove/duplicate/card/relic/max HP, helpers de custo e sync de `shop_state`.

Validacao final:

- `validate.gd` headless passou duas vezes seguidas com GUT `100/100`, `1238` asserts e smoke Track 02 `29/29` sem alterar metricas aprovadas.
- Run Lab `--compare-golden --require-golden` passou para Arcano, Invocador e Necromante seed `20260518`; Arcano preservou 217 turnos, 116 HP loss, 0 mortes, 38 cartas, 6 reliquias e 21 acoes de loja.
- `git diff --check` limpo.

Proximo checkpoint recomendado: Foundation Pass 6 - BattleRoot Composition.
