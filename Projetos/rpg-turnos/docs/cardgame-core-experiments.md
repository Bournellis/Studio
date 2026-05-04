# Cardgame Core Experiments

- Last Updated: `2026-05-04`
- Status: `HISTORICAL_ARCHIVE`

## Current Decision

C1 is the current game, not an experiment branch.

The active implementation uses:

- `manutencao -> compra -> fase_principal`
- shared priority
- attacks as main-phase actions
- no stack
- no response window
- no counterspell/anular
- normal actions pass priority
- instant actions keep priority

Runtime work should focus on battle modes and encounters, not on comparing turn variants.

## Preserved Historical Ideas

The previous A/B matrix and phase-based duel are preserved only as design history:

- `A1_B1`
- `A1_B2`
- `A2_B1`
- `A2_B2`
- phase-based combat with `Main 1 / Combat / Main 2`

These ideas are not active implementation targets and should not appear as runtime buttons.

If a future design review explicitly rejects C1, this document can be used as historical context, but the current project should not maintain playable parity with these alternatives.

## New Experiment Surface

Future experimentation should happen through modes and encounters:

- `limpar_mesa`
- `duelo`
- `ondas`
- `defesa`
- `chefe_multiparte`
- `quebra_cabeca`

The active first mode is `limpar_mesa`, starting with `emboscada_na_ponte`.
