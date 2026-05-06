# Track 01 Current Status

- Last Updated: `2026-05-06`
- Status: `QUEBRA_CABECA_MODE_COMPLETE`

## Implemented

- First playable slice flow remains available.
- Deck setup now targets a 20-card deck.
- The battle setup has one official action: `Iniciar encontro`.
- C1 is the only runtime combat model.
- `Duelo antigo` and variant buttons are removed.
- `BattleEngine` now models controllers, battle mode, board, phases, priority, and visual events.
- `limpar_mesa` is implemented through `Emboscada na Ponte`.
- `duelo` is implemented as the official second battle mode.
- `ondas` is implemented as the official sequential wave battle mode.
- `defesa` is implemented as the official survival objective battle mode.
- `chefe_multiparte` is implemented as the official boss-parts objective battle mode.
- `quebra_cabeca` is implemented as the official timed puzzle objective battle mode.
- Enemy priority resolves automatically until the player gets priority.
- Battle feedback uses simple tweens and labels without new assets.
- Battle Rule Completion is implemented: damage types, coverage, `voadora`, dual burning, `fallback_slots`, and board spells for `chuva_brasas` / `chamado_hostes`.
- World progression/rewards are implemented: encounter completion IDs, one-time encounter rewards, NPC progressive rewards, and a linear world marker chain.
- Minimum save/load is implemented with local JSON, boot continuation, runtime save points, and missing/corrupt save fallback.
- Visual/UX hardening is implemented: HUD bars/pips, hand/deck/discard counter, card type stripes, clearer slot states, world marker status, and result reward feedback.
- Art-ready placeholder structure is implemented: `UiTokens`, `AssetIds`, named art placeholders in boot/world/battle/cards/result, pip rows, keyword chips, and automatic asset lookup hooks.
- Latest validation passes cleanly: 77/77 GUT tests pass through `tools/validate.gd`.

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
- `ondas` has no enemy hero, spawns sequential waves, preserves player HP/board/hand/deck/energy ramp, and only wins after the final wave is cleared
- `defesa` has no enemy hero, tracks complete enemy turns survived, and does not win from clearing the enemy board
- `chefe_multiparte` has no enemy hero, tracks marked boss part slots, and can win while non-part support enemies remain alive
- `quebra_cabeca` has no enemy hero, tracks marked puzzle target slots, and loses when the player turn limit expires unsolved
- creature movement works as a normal action once per turn
- neutral slots exist in the engine when a board defines them
- completed encounters are tracked by id
- encounter rewards are claimed once and re-entry is allowed without duplicate rewards
- NPC rewards use `first_npc_reward_card` first, then `npc_reward_choices`
- local save/load persists unlocked cards, selected deck, active encounter, completed encounters, claimed rewards, NPC reward state, and falls back to new game on invalid save
- HUD/slot/map/result feedback is legible enough for the current no-asset playable slice
- art-ready placeholders expose stable node names and asset IDs without requiring imported art
- command card deck limit is 4
- hero power is `Preparar Defesa`

## Accepted GDD Rules Not Yet Implemented

- All currently documented official battle modes are implemented.
- Broader RPG progression remains pending.
- Draxos lore alignment is documented, but runtime content names still need controlled migration from placeholders.

## Next

Choose the first controlled lore/content migration pass after the official battle mode set.
