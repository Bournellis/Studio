# Gameplay Lab V1

## Resultado

Gameplay Lab V1 implementado para o `draxos-roguelike-cardgame` como runner headless explicito de batalhas isoladas reais via `BattleEngine`, com fixtures versionadas, policies deterministicas de acoes legais, avaliador PASS/WARN/FAIL e relatorios comparaveis.

## Branch e worktree

- Branch: `codex/draxos-roguelike-cardgame/gameplay-lab-v1`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--gameplay-lab-v1`

## Entregas

- Contrato inicial `track02_battle_core_v1` em `data/lab/battles/`.
- CLI explicita `tools/run_battle_lab.gd`.
- Modulos `tools/lab/battle_*` para loader, policy, runner, evaluator e reporter.
- Relatorios `battle_results.json`, `battle_results.csv`, `battle_summary.json`, `battle_summary.md` e `battle_gate.md`.
- Testes GUT focados no ferramental.
- Documentacao local e estado operacional atualizados.

## Validacao executada

- `run_battle_lab --mode=gate --pack=track02_battle_core_v1`: PASS, 12 cases, 9 PASS, 3 WARN, 0 FAIL.
- `run_scenarios --mode=gate --pack=track02_core_v1`: PASS, 12 scenarios, 9 PASS, 3 WARN, 0 FAIL.
- `run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1`: PASS.
- `run_lab --mode=gate --preset=quick --baseline=track02_quick_v1`: PASS.
- `tools/validate.gd`: PASS, GUT 131/131, 1382 asserts.

## Observacoes

- Nenhum balanceamento, carta, inimigo, recompensa, loja, rota ou conteudo de gameplay foi alterado.
- Os WARNs do battle pack sao sinais esperados em casos de stress/regressao.
- O proximo uso recomendado e aplicar o Gameplay Lab durante uma mudanca real de gameplay antes de expandir fixtures.
