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
- Energy max starts at 3, increases by 1 per turn, capped at 8; refreshes to current max on the controller's upkeep.
- Initial hand is 5 cards.
- Hand limit starts at 5, increases by 1 per turn, capped at 7; draw phase fills hand to current limit.
- Deck is cyclic: played cards and destroyed permanents go to the bottom of the owner's deck. No discard pile.
- End-of-turn discard: player may optionally cycle any cards back to the bottom of the deck before ending their turn.
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

## Pending Engine Changes For Codex

All changes below were specified during design sessions on 2026-05-04. Implement phases in order — each phase is a prerequisite for the next. Phases D and E may be worked in parallel since they touch different systems. Phase F does not block any Pass 02 work.

---

## Phase A — Cleanup And Prerequisites

Run once before any other engine work. These are mechanical blockers.

### A1. Delete stale git lock files

The following zero-byte lock files left by a previous process block all git operations on Windows. Delete them manually before running any git command:

- `.git/index.lock`
- `.git/HEAD.lock`
- `.git/objects/maintenance.lock`

### A2. Remove size logic

- `slice_catalog.json`: all `"size"` fields removed from card `effect` objects; `"size_limit"` removed from board slots. Already done in data — remove the engine validation block.
- `battle/battle_engine.gd` lines 869-875: remove the `size_limit` vs `card_size` validation block entirely.

### A3. Elevation rename: `"normal"` → `"chao"`

- All board slots now use `"elevation": "chao"` instead of `"normal"`. Already done in data.
- Update any engine constant or string comparison that checked for `"normal"` elevation to check for `"chao"`.
- Elevation rules: `chao` is ground level. `alto` is elevated. Melee attacks cannot reach `alto` slots. `alcance` and `voadora` creatures can attack `alto` slots. Ranged spells can also target `alto` slots.

---

## Phase B — Engine Core

Foundational rules that all other phases depend on. Must be complete before Phase C, D, or E.

### B1. Damage type system

Every damage source must carry one of three types:

- `fisico_melee`: attacks from creatures/structures without `alcance`; blocked by intermediate occupants; cannot reach `alto` slots; not reduced by `cobertura`
- `fisico_alcance`: attacks from creatures/structures with `alcance`; ignores intermediate occupants; can reach `alto` slots; reduced by `cobertura` (terrain and/or keyword stack, minimum 0)
- `magico`: damage from spells (`magia`, `magia_de_tabuleiro`); ignores `cobertura`; ranged spells (`ranged: true`) target any slot including `alto`, ignoring intermediate occupants; non-ranged spells target slots reachable via the caster's melee routes

### B2. Energy ramp system

Replace the fixed `max_energy = 3` constant with a per-controller ramping value:

- On each controller's own upkeep, increment that controller's `max_energy` by 1 if it is below 8.
- Turn 1: max 3. Turn 2: max 4. Turn 3: max 5. Turn 4: max 6. Turn 5: max 7. Turn 6+: max 8 (capped).
- Energy recharges to current max on upkeep. Unspent energy is lost — it does not carry to the next upkeep.
- Player and enemy controllers ramp independently on their own upkeeps.

### B3. `rapido` enters as `pronta`

- Creatures with the `rapido` keyword enter the board as `pronta`, not `enjoo`.
- They may attack the turn they enter, as soon as priority returns to their controller.
- Update the engine entry path to set state to `pronta` for `rapido` creatures instead of `enjoo`.

### B4. `queimando` dual behavior

`queimando` can exist independently as a slot status or a creature status:

- `queimando` on a slot: on the occupying controller's upkeep, deals 1 damage to whichever creature occupies it; a creature can escape by moving to another slot.
- `queimando` on a creature: on that controller's upkeep, deals 1 damage to the creature; follows the creature when it moves to a new slot.
- Both can coexist simultaneously on the same slot and creature without interaction.

### B5. Cyclic deck — no discard pile

Replace the discard pile concept entirely:

- When a spell (`magia`, `magia_de_tabuleiro`) resolves, it goes to the **bottom** of the owner's deck.
- When a permanent is destroyed, it goes to the **bottom** of its owner's deck.
- When a card is discarded from hand (by choice or over-limit), it goes to the **bottom** of the owner's deck.
- The deck never runs out. There is no deck-out loss condition.
- All code references to a discard pile (`pilha_descarte`, `discard`, etc.) must be replaced with bottom-of-deck insertion.

### B6. Hand size progression and draw-up rule

Replace the fixed hand limit and fixed draw-1 rule:

- **Initial hand:** 5 cards (dealt at game start from the top of the deck).
- **Hand limit progression:** starts at 5 on turn 1, increases by 1 on each of the controller's own upkeeps, capped at 7. Track as `max_hand_size` per controller.
- **Draw phase (`compra`):** draw cards from the top of the deck until `hand.size() == max_hand_size`. If the hand is already at or above the limit, draw nothing.
- **Over-limit rule:** if `hand.size() > 7` for any reason (e.g. a card effect), the controller must immediately send cards from hand to the bottom of the deck until `hand.size() == 7`.
- The enemy controller uses the same draw-up rule and hand limit progression.

### B7. End-of-turn discard step (player only)

Add an optional discard step at the end of the **player controller's** main phase:

- Triggered just before the second consecutive pass that closes the main phase.
- The UI presents the player's current hand and allows selecting zero or more cards to cycle back to the bottom of the deck.
- After the player confirms, the selected cards move to the bottom of the deck and the phase ends.
- The **enemy controller skips this step** entirely; the AI always retains its full hand.

### B8. Over-limit discard enforcement

If any game effect causes a controller's hand to exceed 7 cards at any point:

- For the player: trigger the same discard UI used in B7, restricted to sending cards until `hand.size() == 7`.
- For the enemy AI: automatically discard the lowest-cost card(s) until `hand.size() == 7`.

---

## Phase C — `voadora` Keyword (complete implementation)

Implement as a single coherent unit. All three sub-items are interdependent.

### C1. `voadora` definition and damage type ruling

Core behavior:

- Enters as `pronta` (same as `rapido`). May attack the turn it enters after priority returns.
- Can attack `alto` slots and any slot in its defined routes.
- Cannot be targeted by `fisico_melee` damage from any source.

Damage type ruling:

- A `voadora` creature **without** `alcance` deals `fisico_melee` damage. The normal restriction that `fisico_melee` cannot reach `alto` slots does **not** apply to `voadora` creatures — they are airborne. `cobertura` does not reduce their attacks.
- A `voadora` creature **with** `alcance` deals `fisico_alcance` damage normally. `cobertura` (terrain and/or keyword, stacking, minimum 0) reduces their attacks.

### C2. `voadora` is transparent to melee routing

When resolving a melee attack route:

- Skip any `voadora` occupants in the route — they are not valid melee targets.
- The first non-`voadora` occupied slot is the legal melee target.
- If the entire route contains only `voadora` occupants or is empty, apply the mode fallback (`hero` or `none`).

### C3. `atropelar` interaction with `voadora`

- Excess damage from `atropelar` carries to the next occupied non-`voadora` slot in the route.
- If no such slot exists, the excess hits the enemy hero (if the mode allows it).
- If no hero or valid fallback, the excess is lost.
- Excess damage inherits the original damage type: `fisico_melee` excess cannot hit `voadora` creatures.

---

## Phase D — Pass 02: `duelo` Mode

Implement the official duel mode. Requires Phase A, B, and C to be complete.

### D1. Enemy hero power

`Golpe Direto`:

- Cost: 0 energy
- Speed: normal
- Usage: once per own turn
- Effect: deals 1 `magico` damage to the player hero
- AI uses it at the start of its own turn if the power has not been used this turn.

### D2. Enemy AI (deterministic, aggressive)

AI decision sequence each time the enemy has priority:

1. Use hero power if available, targeting the player hero.
2. Play the highest-cost card the AI can afford, prioritizing `criatura` and `estrutura` types over spells.
3. Attack with each ready permanent in descending ATK order; if the route is empty in `duelo` mode, fall back to the player hero.
4. Pass priority when no legal actions remain.

### D3. Enemy deck

- Use the custom deck defined in `slice_catalog.json` under the `duelista_bandido` encounter.
- Do not use the player starter deck for the enemy side.

### D4. Creature movement

- A `criatura` (not `estrutura`) may spend priority once per turn as a normal action to move to any empty slot in its own controller's area or in a neutral area.
- Movement does not exhaust the creature; it may still attack on the same turn after receiving priority back.

### D5. Neutral area slots

- Boards may define slots with `"owner": "neutral"` in JSON.
- Either controller may play or move a permanent into a neutral slot if it is empty.
- A neutral slot occupied by one controller cannot be entered by the other.

---

## Phase E — Pass 02: World Progression

Implement the encounter chain and card reward system. Touches different systems from Phase D and may be developed in parallel.

### E1. Reward cards in `slice_catalog.json`

**Per-encounter rewards** — each encounter uses a `"reward_cards"` array (one or two card IDs). All cards in the array are added to `unlocked_card_ids` on the first victory for that encounter. Current assignments:

- `emboscada_na_ponte` → `["lobo_alfa"]`
- `duelista_bandido` → `["relampago", "flagelo"]`
- `emboscada_no_cruzamento` → `["arqueira_voante", "torre_blindada"]`
- `fortaleza_do_desfiladeiro` → `["dragao_jovem", "chamado_hostes"]`

**NPC progressive rewards** — the catalog root has a `"npc_reward_choices"` array: `["corvo_batedor", "chuva_brasas", "campeao_guilda"]`. On each NPC interaction after the first, the engine gives the player the next unclaimed card from this list (one per visit). The global `"reward_card"` field (currently `"golpe_preciso"`) is still given on the very first NPC visit and is not part of this list.

This ensures all 10 new cards are accessible across the full progression:
- NPC visit 1: `golpe_preciso`
- NPC visit 2 (post encounter 1): `corvo_batedor`
- NPC visit 3 (post encounter 2): `chuva_brasas`
- NPC visit 4 (post encounter 3): `campeao_guilda`
- `emboscada_na_ponte` clear: `lobo_alfa`
- `duelista_bandido` clear: `relampago` + `flagelo`
- `emboscada_no_cruzamento` clear: `arqueira_voante` + `torre_blindada`
- `fortaleza_do_desfiladeiro` clear: `dragao_jovem` + `chamado_hostes`

### E2. `GameSession` multi-encounter tracking

Replace the single `is_encounter_completed: bool` with a set-based structure:

- Add `completed_encounter_ids: Array[String]` (replaces `is_encounter_completed`)
- Add `claimed_encounter_reward_ids: Array[String]` to track which encounter rewards have already been added to `unlocked_card_ids`
- Add `npc_reward_index: int` (default 0) to track how many NPC progressive rewards have been given; incremented each time a card from `npc_reward_choices` is claimed
- Add `claim_npc_progressive_reward() -> String` that returns the next unclaimed card from `npc_reward_choices` (by `npc_reward_index`), adds it to `unlocked_card_ids`, increments the index, and returns the card ID (or `""` if all have been claimed)
- `active_encounter_id` must be settable dynamically by the world when the player interacts with a specific marker (remove the hardcoded constant)
- Update `complete_encounter()` to append to `completed_encounter_ids` instead of setting a bool
- Add `has_completed_encounter(id: String) -> bool` helper
- Add `claim_encounter_reward(encounter_id: String) -> String` that looks up the `reward_card_id` from `ContentLibrary`, adds it to `unlocked_card_ids` if not already present, and records it in `claimed_encounter_reward_ids`
- Update `capture_pre_combat_snapshot()` and `restore_pre_combat_snapshot()` to include the new fields

### E3. World map encounter chain

Replace the single encounter marker in `world_root.gd` with a data-driven list of markers:

- Markers are defined in order; the first is always available after the NPC reward card is claimed.
- Each subsequent marker is locked until the previous encounter appears in `completed_encounter_ids`.
- Each marker stores its `encounter_id` and a world position.
- Locked markers: rendered in a muted color with no interaction prompt.
- Available markers: rendered in the active color; pressing E sets `GameSession.active_encounter_id` to this marker's encounter ID and transitions to `deck_setup.tscn`.
- Completed markers: rendered in the completed color; pressing E shows a dialogue ("Encontro concluído.") but allows re-entry for practice (no second reward).

Starting marker positions (placeholder, adjust in editor):

| Encounter | Position |
|---|---|
| `emboscada_na_ponte` | `Vector2(600, 330)` |
| `duelista_bandido` | `Vector2(750, 330)` |
| `emboscada_no_cruzamento` | `Vector2(900, 330)` |
| `fortaleza_do_desfiladeiro` | `Vector2(900, 250)` |

### E4. Result screen reward display

In `result_root.gd`, on victory:

1. Call `GameSession.claim_encounter_reward(active_encounter_id)` — this returns an `Array[String]` of newly unlocked card IDs (empty if already claimed or no rewards).
2. If the array is non-empty, display one "Carta desbloqueada: [display_name]" line per card before the "Voltar ao mapa" button.
3. If empty (already claimed), show no unlock label.
4. The "Voltar ao mapa" button remains.

In `world_root.gd`, on NPC interaction after the first reward:

1. Call `GameSession.claim_npc_progressive_reward()`.
2. If a card ID is returned, show it in the dialogue: "A viajante entrega mais uma carta: [display_name]."
3. If `""` is returned (all progressive rewards claimed), show the existing idle dialogue.

---

## Phase F — Pass 03+: Advanced Board Topology

These features support the complex boards (`muralha_desfiladeiro`, `cruzamento_neutro`). They do not block Pass 02. Implement after `duelo` is stable.

### F1. `fallback_slots` engine support

Route definitions in JSON may include a `fallback_slots` array (ordered list of slot refs) positioned between `targets` and the mode's final `fallback` string:

- After exhausting `targets` with no non-`voadora` occupant found, iterate `fallback_slots` in order with the same search logic.
- Only after all `fallback_slots` are also empty does the mode `fallback` (`hero` or `none`) apply.
- `muralha_desfiladeiro` uses this for a double defensive line: front slots E1–E3 backed by rear slots EB1–EB2.

### F2. `neutral_routes` engine support

Boards may define a `neutral_routes` object keyed by neutral slot index (as a string):

- Each entry has `player_targets`, `enemy_targets`, and `fallback`.
- When resolving attacks from a permanent in a neutral slot, use `player_targets` if the permanent belongs to the player controller, or `enemy_targets` if it belongs to the enemy controller.
- All standard route blocking rules apply (non-`voadora` first occupant for melee, `alcance` ignores intermediates, etc.).
- `cruzamento_neutro` uses this: a permanent in N1 attacks the opposite front row depending on which controller owns it.
