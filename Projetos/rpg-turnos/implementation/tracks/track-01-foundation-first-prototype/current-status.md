# Track 01 Current Status

- Last Updated: `2026-05-05`
- Status: `WORLD_PROGRESSION_REWARDS_COMPLETE`

## Implemented

- First playable slice flow remains available.
- Deck setup now targets a 20-card deck.
- The battle setup has one official action: `Iniciar encontro`.
- C1 is the only runtime combat model.
- `Duelo antigo` and variant buttons are removed.
- `BattleEngine` now models controllers, battle mode, board, phases, priority, and visual events.
- `limpar_mesa` is implemented through `Emboscada na Ponte`.
- `duelo` is implemented as the official second battle mode.
- Enemy priority resolves automatically until the player gets priority.
- Battle feedback uses simple tweens and labels without new assets.
- Battle Rule Completion is implemented: damage types, coverage, `voadora`, dual burning, `fallback_slots`, and board spells for `chuva_brasas` / `chamado_hostes`.
- World progression/rewards are implemented: encounter completion IDs, one-time encounter rewards, NPC progressive rewards, and a linear world marker chain.
- Latest validation passes cleanly: 51/51 GUT tests pass through `tools/validate.gd`.

## Implemented Runtime Rules

- `manutencao -> compra -> fase_principal -> descarte`
- no stack
- no response window
- normal action passes priority
- instant action keeps priority
- two passes end the main phase
- cleanup is internal after `descarte`
- energy max ramps 3->8 per controller
- initial hand is 5
- deck size is 20
- max hand size ramps 5->7; temporary ceiling is 8; reaching 9 triggers immediate discard to 8
- spells, destroyed permanents, and discarded hand cards go to the bottom of the owner's deck
- damage types are `fisico_melee`, `fisico_alcance`, and `magico`
- `cobertura` reduces only `fisico_alcance`, stacking terrain and keyword
- `voadora` enters ready, can reach `alto`, and is not targetable by non-flying `fisico_melee`
- `queimando` works as slot status and creature status
- `duelo` has enemy hero at 20 HP, enemy deck/hand/energy, `Golpe Direto`, aggressive AI, and empty-lane hero fallback
- creature movement works as a normal action once per turn
- neutral slots exist in the engine when a board defines them
- completed encounters are tracked by id
- encounter rewards are claimed once and re-entry is allowed without duplicate rewards
- NPC rewards use `first_npc_reward_card` first, then `npc_reward_choices`
- command card deck limit is 4
- hero power is `Preparar Defesa`

## Accepted GDD Rules Not Yet Implemented

- Save/load remains pending before progress should persist between application runs.
- Full visual hardening / art-ready placeholder structure remains pending.

## Next

Implement save/load minimum or visual/UX hardening as the next linear pass.
