# Current Status

- Last Updated: `2026-05-04`
- Active Surface: `cardgame-first C1 battle modes`
- Active Project Name: `rpg-turnos`
- Active Track: `Track 01 - Foundation Contracts And First Prototype`
- Active Track Status: `C1_BATTLE_MODES_PASS_01_CLEAR_BOARD_IMPLEMENTED`
- Current Operational Baseline: `playable Godot 4.6.2 slice with menu, 2D exploration placeholder, 20-card deck setup, C1 as the sole runtime combat model, limpar_mesa encounter mode, data-driven boards/encounters, automatic enemy priority, simple visual battle feedback, generated scenes, JSON-driven catalog, and GUT validation`
- Active Goal: `prove the cardgame battle modes before returning to RPG progression, lore, stats, persistence, or final visual direction`
- Active Combat Direction: `C1 - main game, not a variant`
- Preserved Combat Ideas: `A/B priority variants and the phase-based duel are historical only in docs/cardgame-core-experiments.md`

## Read Next

- `../AGENTS.md`
- `../docs/game-design-document.md`
- `../docs/architecture.md`
- `../docs/cardgame-core-experiments.md`
- `roadmap.md`
- `tracks/track-01-foundation-first-prototype/cardgame-core-implementation-plan.md`
- `../docs/first-playable-slice-smoke.md`

## Current Runtime

- Deck setup requires exactly 20 unlocked cards.
- Decks may include at most 4 command cards.
- The setup screen has one entry button: `Iniciar encontro`.
- The active encounter is `emboscada_na_ponte`.
- The active mode is `limpar_mesa`.
- The old `Duelo antigo` button has been removed.
- The battle engine uses `controladores`, `modo_batalha`, `tabuleiro`, `turno`, `fase_principal`, and shared priority.
- Public phases are `manutencao`, `compra`, and `fase_principal`.
- Cleanup is internal.
- Player hero starts at 25 HP.
- Duel enemy hero baseline is 20 HP, used by the next official mode.
- Energy max starts at 3 and refreshes on the controller's upkeep.
- Initial hand is 4 cards; later own draws are 1 card.
- Hand limit is 8.
- Hero power is `Preparar Defesa`: costs 1 energy and grants 2 persistent armor.
- Enemy decisions resolve automatically until priority returns to the player.
- UI emits simple no-asset feedback for attack, damage, summon, armor, buff, and destruction.

## Implemented Battle Mode Pass 01

- `limpar_mesa` implemented with `Emboscada na Ponte`.
- Enemy side has turns, upkeep, priority, attacks, and starting units, but no enemy hero.
- Player attacks in empty lanes have no hero fallback in `limpar_mesa`.
- Creature-vs-creature damage is simultaneous.
- Creatures use `enjoo`, `pronta`, and `exausta`.
- `rapido`, `defensor`, `atropelar`, and `alcance` are represented in the rules/data.
- `cobertura` reduces ranged damage.
- `queimando` ticks on the occupant controller's upkeep.
- `duelo` exists in the engine/data as the next official mode but is not the current entry flow.

## Validation Command

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd
```

Latest validation: `34/34` GUT tests passing.

## Pending Engine Changes For Codex (design session 2026-05-04)

The following changes were made to `data/definitions/slice_catalog.json` and `docs/game-design-document.md` during a design session. The engine must be updated to match before continuing Pass 02 implementation.

### 0. Before anything else: delete git lock files

The following stale lock files are blocking normal git operations on Windows. Delete them manually before running any git command:

- `.git/index.lock`
- `.git/HEAD.lock`
- `.git/objects/maintenance.lock`

These are zero-byte stale files left by a previous process. Safe to delete.

### 1. Remove size logic

- `slice_catalog.json`: all `"size"` fields removed from card `effect` objects; `"size_limit"` removed from board slots. Size is no longer a game concept.
- `battle/battle_engine.gd` lines 869-875: remove the `size_limit` vs `card_size` validation block entirely.

### 2. Elevation rename: "normal" -> "chao"

- All board slots that previously used `"elevation": "normal"` now use `"elevation": "chao"`.
- Update any engine constant or string comparison that checked for `"normal"` elevation to check for `"chao"`.
- Elevation rules: `chao` is ground level. `alto` is elevated. Melee attacks cannot reach `alto` slots. `alcance` and `voadora` creatures can attack `alto` slots. Ranged spells can also target `alto` slots.

### 3. Damage type system (new, required for all Pass 02 mechanics)

Implement three damage types. Every damage source must carry one:

- `fisico_melee`: creature attacks without `alcance`; blocked by intermediate occupants; cannot reach `alto`; not reduced by `cobertura`
- `fisico_alcance`: attacks from creatures/structures with `alcance` keyword; ignores intermediate occupants; can reach `alto`; reduced by `cobertura` (terrain and/or keyword, stacking, minimum 0)
- `magico`: spells (`magia`, `magia_de_tabuleiro`); ignores `cobertura`; ranged spells (`ranged: true`) target any slot including `alto`, ignoring intermediate occupants; non-ranged spells target slots reachable via the caster's melee routes

### 4. `voadora` keyword (new)

- Enters as `pronta` (same as `rapido`).
- Can attack `alto` slots and any slot reachable via its defined routes.
- Cannot be targeted by `fisico_melee` damage.
- Does NOT count as a blocking occupant for melee routing: melee passes through it to the next occupied non-`voadora` slot or fallback.
- Can be targeted by `fisico_alcance`, other `voadora`, and `magico` damage normally.

### 5. `rapido` clarification

- Enters as `pronta` (not `enjoo`). May attack the turn it enters after priority returns.
- Update engine to set state to `pronta` on entry instead of `enjoo` for `rapido` creatures.

### 6. Route blocking with `voadora` (engine audit)

- When resolving a melee attack route, skip any `voadora` occupants.
- The first non-`voadora` occupant is the legal target.
- If the entire route has only `voadora` occupants or is empty, use the mode fallback.

### 7. `atropelar` clarification

- Excess damage carries to the next occupied non-`voadora` slot in the route.
- If no such slot, hits the enemy hero.
- If no hero or fallback, excess is lost.
- Excess inherits the original damage type: `fisico_melee` excess cannot hit `voadora`.

### 8. `queimando` as slot status vs creature status

- `queimando` on a slot: deals 1 damage to any creature occupying it on that controller's upkeep; creature can escape by moving to another slot.
- `queimando` on a creature: deals 1 damage on that controller's upkeep; follows the creature when it moves to a new slot.
- Both can coexist independently on the same slot+creature combination.

### 9. Movement (Pass 02)

- A `criatura` (not `estrutura`) may spend priority once per turn as a normal action to move to an empty slot in its own controller's area or a neutral area.
- Movement does not exhaust the creature; it may still attack after receiving priority back in the same turn.

### 10. Neutral area slots (Pass 02)

- Boards may define slots with `"owner": "neutral"` in JSON.
- Either controller may play or move permanents into neutral slots if empty.

### 11. Enemy hero power for `duelo` (Pass 02)

- `Golpe Direto`: cost 0, normal speed, usable once per own turn, deals 1 `magico` damage to the player hero.
- AI uses it at the start of its turn if available.

### 12. Enemy AI for `duelo` (Pass 02, deterministic aggressive)

1. Use hero power if available, targeting the player hero.
2. Play the highest-cost card the AI can afford, prioritizing criaturas and estruturas.
3. Attack with each ready permanent: prioritize the enemy slot with the highest ATK; if the route is empty in `duelo` mode, fall back to the player hero.
4. Pass priority when no legal actions remain.

### 13. Enemy deck for `duelo`

- Use the custom deck defined in `slice_catalog.json` under the `duelista_bandido` encounter.
- Do not use the player starter deck.

### 14. `fallback_slots` engine support (Pass 02)

- Route definitions in JSON may include a `fallback_slots` array (ordered list of slot refs) between `targets` and the mode `fallback`.
- When all `targets` slots are empty (no non-`voadora` occupant found), the engine iterates `fallback_slots` in order, applying the same occupant-search logic.
- Only after all `fallback_slots` are also exhausted does the mode `fallback` (`hero` or `none`) apply.
- `muralha_desfiladeiro` board uses this to create a double defensive line: front slots (E1–E3) backed by rear slots (EB1–EB2).

### 15. `neutral_routes` engine support (Pass 02)

- Boards may define a `neutral_routes` object keyed by neutral slot index (string).
- Each entry has `player_targets`, `enemy_targets`, and `fallback`.
- When a permanent is in a neutral slot, the engine resolves its attack routes using `player_targets` if the permanent belongs to the player, or `enemy_targets` if it belongs to the enemy.
- Route blocking rules (non-`voadora` first occupant, `alcance` ignores, etc.) apply identically to neutral routes.
- `cruzamento_neutro` board uses this: N1 is a contested central zone where the occupying controller can attack the opposite front row.

### 16. Energy ramp system (Pass 02)

- Replace fixed `max_energy = 3` with a ramping system.
- On each controller's upkeep, increment that controller's `max_energy` by 1 if below 8.
- Turn 1: max 3. Turn 2: max 4. ... Turn 6+: max 8 (capped).
- Energy recharges to current max on upkeep. Unspent energy is lost (not carried over).
- Both player and enemy controllers ramp independently on their own upkeeps.

### 17. `voadora` damage type ruling

- A `voadora` creature **without** `alcance` deals `fisico_melee` damage. The normal restriction that `fisico_melee` cannot reach `alto` slots does NOT apply to `voadora` creatures (they are airborne). `cobertura` does not reduce their attacks.
- A `voadora` creature **with** `alcance` deals `fisico_alcance` damage normally. `cobertura` (terrain and keyword, stacking) reduces their attacks.
- This distinction matters for `cobertura` interaction and for `atropelar` excess damage type inheritance.
