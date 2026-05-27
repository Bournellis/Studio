# Draxos Roguelike Cardgame - Foundation Hardening 4

- Data: `2026-05-27`
- Agente: `Codex`
- Branch: `codex/draxos-roguelike-cardgame/foundation-hardening-4`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--foundation-hardening-4`
- Base: `b6a0fcc` (`codex/draxos-roguelike-cardgame/foundation-hardening-3`)

## Objetivo

Executar a primeira etapa da revisao completa da fundacao: criar regression harness e golden metrics comparaveis para proteger as passadas futuras de loja, UI, catalogo e BattleEngine, sem alterar gameplay, conteudo, balanceamento, IA, UI ou catalogo.

## Arquivos Pretendidos

- `Projetos/draxos-roguelike-cardgame/tools/run_lab.gd`
- `Projetos/draxos-roguelike-cardgame/tools/route_pacing_simulator.gd`
- `Projetos/draxos-roguelike-cardgame/tools/validate.gd`
- `Projetos/draxos-roguelike-cardgame/tests/unit/`
- `Projetos/draxos-roguelike-cardgame/docs/`
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
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/validation-and-tuning-notes.md`

## Validacao Planejada

- Rodar baseline headless antes de editar.
- Rodar Run Lab inicial para Arcano, Invocador e Necromante com seed `20260518`.
- Adicionar golden metrics e comparacao automatica ao Run Lab/validacao sem mudar o simulador de gameplay.
- Cobrir golden metrics em GUT.
- Rodar `validate.gd` duas vezes no final e confirmar ausencia de churn gerado.
- Rodar Run Lab final em modo de comparacao.

## Handoff

Status final: Foundation Pass 4 implementada.

- Baseline inicial confirmado em worktree dedicada: validacao headless verde com `97/97`, `1218` asserts e smoke `29/29`; Run Lab inicial verde para Arcano/Invocador/Necromante seed `20260518`.
- Adicionado `tools/run_lab_golden_metrics.gd` com goldens Track 02.
- `validate.gd` agora compara o smoke Arcano seed `20260518` contra o golden exato.
- `run_lab.gd` preserva CLI/CSV/JSON padrao e adiciona `--compare-golden`, `--require-golden` e `--strict-golden`.
- GUT cobre baseline golden e deteccao de regressao Arcano.
- Validacao final verde: `99/99` GUT, `1228` asserts, smoke `29/29`.
- Run Lab final com `--compare-golden --require-golden`: Arcano, Invocador e Necromante seed `20260518` verdes; Arcano exato e todas as classes `29/29` sem morte.

Proximo checkpoint recomendado: Foundation Pass 5 - Run Economy Services.
