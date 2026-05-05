# Track 01 Current Status

- Last Updated: `2026-05-05`
- Status: `PASS_01_RUNTIME_IMPLEMENTED__DOC_ALIGNMENT_ACTIVE`

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
- Latest validation does not pass cleanly: 33/34 GUT tests pass, with one stale `size_limit` test failing after data removed size constraints.

## Implemented Runtime Rules

- `manutencao -> compra -> fase_principal`
- no stack
- no response window
- normal action passes priority
- instant action keeps priority
- two passes end the main phase
- cleanup is internal
- energy max is fixed at 3
- initial hand is 4
- deck size is 20
- hand limit is 8
- played cards currently go to a `discard` array
- command card deck limit is 4
- hero power is `Preparar Defesa`

## Accepted GDD Rules Not Yet Implemented

- public flow becomes `manutencao -> compra -> fase_principal -> descarte`
- energy ramps 3->8 per controller
- initial hand becomes 5
- carry-over hand limit ramps 5->7
- temporary ceiling is 8 and immediate discard triggers at 9
- `descarte` phase supports mandatory discard to 7 and voluntary extra discard
- deck is cyclic with no discard pile
- `manter_linha` must be deleted
- rewards use `first_npc_reward_card`, `npc_reward_choices`, and per-encounter `reward_cards`

## Next

Implement Foundation Runtime Alignment before promoting `duelo`, visual Phase H/J, or progression content expansion.
