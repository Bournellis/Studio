# Scenario Fixtures V1 - Codex

- Data: `2026-06-05`
- Agente: `Codex`
- Projeto: `Projetos/draxos-roguelike-cardgame/`
- Branch: `codex/draxos-roguelike-cardgame/scenario-fixtures-v1`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--scenario-fixtures-v1`
- Status: `DONE`

## Objetivo

Implementar Scenario Fixtures V1 como segunda camada do AutoRun Lab, com fixtures deterministicas para regressao/tuning de rota, economia, deck, boss, classes e keywords usando `macro_route_v1`.

## Entrega

- Criado o pack versionado `data/lab/scenarios/track02_core_v1.json` com 12 cenarios iniciais.
- Criado `tools/run_scenarios.gd` com filtros por pack, scenario, tags, out, mode e stop-on-failure.
- Criados modulos `tools/lab/scenario_fixture_loader.gd`, `scenario_evaluator.gd`, `scenario_runner.gd` e `scenario_reporter.gd`.
- Implementado envelope de resultado com `schema_version`, `tool`, `scenario`, `result`, `timeline`, `expectations`, `warnings` e `tags`.
- Implementados relatorios `scenario_results.json`, `scenario_results.csv`, `scenario_summary.json`, `scenario_summary.md` e `scenario_gate.md`.
- Adicionados testes GUT focados no loader, runner, evaluator, filtros e Markdown.
- Atualizados `docs/autorun-lab.md`, snapshots locais, Track 02 handoff e portfolio.

## Validacao Executada

- `run_scenarios --mode=gate --pack=track02_core_v1`: 12 cenarios, 9 PASS, 3 WARN, 0 FAIL.
- `run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1`: passou.
- `run_lab --mode=gate --preset=quick --baseline=track02_quick_v1`: passou 30 casos.
- `tools/validate.gd`: passou com 120/120 GUT tests e 1343 asserts.

## Observacoes

- Nenhuma carta, inimigo, recompensa, custo, economia ou balanceamento foi alterado.
- `tools/run_scenarios.gd` permanece gate explicito e nao foi integrado ao `tools/validate.gd`.
- WARN nao falha gate; os WARN atuais representam sinais esperados de stress em `no_shop`, `big_deck` e `thin_deck`.
- Debitos visuais opcionais ja conhecidos permanecem inalterados.

## Proximo Passo

Usar AutoRun Gate Pack V1 e Scenario Fixtures V1 antes/depois da primeira mudanca real de gameplay; expandir fixtures somente apos avaliar a qualidade do sinal em uma mudanca concreta.
