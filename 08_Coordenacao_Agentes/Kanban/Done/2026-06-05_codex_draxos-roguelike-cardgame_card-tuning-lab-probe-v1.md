# Card Tuning Lab Probe V1

## Resultado

Executado tuning leve e intencional em carta para testar o ferramental de labs com uma mudanca real de gameplay.

## Branch e worktree

- Branch: `codex/draxos-roguelike-cardgame/card-tuning-lab-probe-v1`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--card-tuning-lab-probe-v1`

## Mudanca aplicada

- `arcano_choque`: dano base `2` -> `3`.
- `data/generated/slice_catalog.tres` regenerado por `tools/validate.gd`.

## Resultado dos labs

- Before:
  - Battle Lab: 9 PASS, 3 WARN, 0 FAIL.
  - Scenario Fixtures: 9 PASS, 3 WARN, 0 FAIL.
  - AutoRun smoke: PASS.
  - AutoRun quick: PASS.
- After:
  - Battle Lab: 8 PASS, 3 WARN, 1 FAIL.
  - Scenario Fixtures: 9 PASS, 3 WARN, 0 FAIL.
  - AutoRun smoke: PASS.
  - AutoRun quick: PASS.
  - `tools/validate.gd`: FAIL esperado para a prova, GUT 128/131.

## Leitura

O ferramental respondeu corretamente: a camada Battle Lab e os testes unitarios detectaram alteracao de carta/combate, enquanto as camadas macro de rota permaneceram estaveis.

## Handoff

Branch mantida como prova experimental. Nao deve ser mergeada como balanceamento final sem decisao explicita de aceitar `Choque` com 3 de dano e recalibrar os contratos afetados.
