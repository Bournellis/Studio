# Track 01 Current Status

- Last Updated: `2026-05-04`
- Status: `C1_BATTLE_MODES_PASS_01_CLEAR_BOARD_IMPLEMENTED`

## Implemented

- First playable slice flow remains available.
- Deck setup now targets a 20-card deck.
- The battle setup has one official action: `Iniciar encontro`.
- C1 is the only runtime combat model.
- `Duelo antigo` and variant buttons are removed.
- `BattleEngine` now models controllers, battle mode, board, phases, priority, and visual events.
- `limpar_mesa` is implemented through `Emboscada na Ponte`.
- `duelo` is represented in data/engine for the next official pass.
- Enemy priority resolves automatically until the player gets priority.
- Battle feedback uses simple tweens and labels without new assets.
- Validation passes with 34 GUT tests.

## Active Rules

- `manutencao -> compra -> fase_principal`
- no stack
- no response window
- normal action passes priority
- instant action keeps priority
- two passes end the main phase
- cleanup is internal
- energy max starts at 3
- initial hand is 4
- deck size is 20
- hand limit is 8
- command card deck limit is 4
- hero power is `Preparar Defesa`

## Next

Promote `duelo` into a selectable or progression-driven official encounter once `limpar_mesa` playtesting is stable.
