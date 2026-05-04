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
- Public phases are `manutencao`, `compra`, `fase_principal`, and `descarte`.
- Cleanup is internal.
- Player hero starts at 25 HP.
- Duel enemy hero baseline is 20 HP, used by the next official mode.
- Energy max starts at 3, increases by 1 per turn, capped at 8; refreshes to current max on the controller's upkeep.
- Initial hand is 5 cards.
- Hand limit starts at 5, increases by 1 per turn, capped at 7 (carry-over limit, enforced at end of descarte phase); draw phase fills hand to current limit.
- Temporary hand ceiling is 8; a controller may hold up to 8 cards at any point during their turn.
- Immediate discard trigger: if hand reaches 9 at any point, discard immediately to 8; the descarte phase then handles the reduction to 7.
- Deck is cyclic: played cards and destroyed permanents go to the bottom of the owner's deck. No discard pile.
- Descarte phase (4th public phase): player must discard down to 7; enemy auto-discards lowest-cost card(s) if over 7; voluntary extra discards allowed for the player.
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

### B6. Hand size progression, draw-up rule, and temporary ceiling

Replace the fixed hand limit and fixed draw-1 rule:

- **Initial hand:** 5 cards (dealt at game start from the top of the deck).
- **Hand limit progression:** starts at 5 on turn 1, increases by 1 on each of the controller's own upkeeps, capped at 7. Track as `max_hand_size` per controller. This is the carry-over limit enforced at the end of the descarte phase.
- **Temporary ceiling:** 8 cards. A controller may hold up to 8 cards at any point during their turn.
- **Draw phase (`compra`):** draw cards from the top of the deck until `hand.size() == max_hand_size`. If the hand is already at or above the limit, draw nothing.
- **Immediate discard trigger:** if `hand.size() >= 9` for any reason at any point during play, the controller must immediately send cards from hand to the bottom of the deck until `hand.size() == 8`. This does not wait for the descarte phase. Reaching 8 is normal and allowed; only 9 triggers immediate action.
- The enemy controller uses the same draw-up rule, hand limit progression, and ceiling rules.

### B7. Descarte phase (4th public phase)

Add `descarte` as the fourth and final public phase of the turn, after `fase_principal`:

- The `descarte` phase begins automatically after the `fase_principal` ends (after both consecutive passes).
- **Player controller:** the UI presents the player's current hand; the player must select cards to send to the bottom of the deck until `hand.size() <= 7`; if already at 7 or fewer, no mandatory discard is required, but the player may voluntarily discard additional cards.
- **Enemy controller:** the AI automatically discards the lowest-cost card(s) until `hand.size() <= 7`; if already at 7 or fewer, no action is taken.
- After the descarte phase resolves for both controllers, cleanup runs internally and the turn ends.

### B8. Immediate over-limit enforcement

If any game effect causes a controller's hand to reach 9 or more cards at any point during play (outside of the normal descarte phase):

- For the player: trigger the same discard UI used in B7, restricted to sending cards until `hand.size() == 8`.
- For the enemy AI: automatically discard the lowest-cost card(s) until `hand.size() == 8`.
- Note: holding 8 cards is normal and allowed during the turn. Only reaching 9 triggers this immediate response. The descarte phase then handles the final reduction from 8 to 7 at end of turn.

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

Replace the single encounter marker in `world_root.gd` with a data-driven list of markers. Markers have two categories: **main chain** (linear unlock, each requires the previous) and **optional** (unlock when a specified encounter is completed, no further dependency).

Marker behavior:
- Locked: muted color, no interaction.
- Available: active color; pressing E sets `GameSession.active_encounter_id` and transitions to `deck_setup.tscn`.
- Completed: completed color; re-entry allowed for practice (no second reward).

**Main chain** (linear, each unlocks the next):

| Order | Encounter | Position |
|---|---|---|
| 1 | `emboscada_na_ponte` | `Vector2(400, 330)` |
| 2 | `duelista_bandido` | `Vector2(550, 330)` |
| 3 | `patrulha_avancada` | `Vector2(700, 330)` |
| 4 | `emboscada_no_cruzamento` | `Vector2(850, 330)` |
| 5 | `fortaleza_do_desfiladeiro` | `Vector2(1000, 330)` |
| 6 | `duelista_sombrio` | `Vector2(1000, 220)` |

**Optional encounters** (appear when unlock condition met, not required for main chain):

| Encounter | Unlocks after | Position |
|---|---|---|
| `emboscada_reforcos` | `emboscada_na_ponte` | `Vector2(400, 220)` |
| `invasao_em_ondas` | `patrulha_avancada` | `Vector2(700, 220)` |

NPC progressive rewards trigger: give the next card from `npc_reward_choices` when the player has completed N main-chain encounters, where N equals the current `npc_reward_index` + 1. (Complete 1 main encounter → get choice 0; complete 2 → get choice 1; complete 3 → get choice 2.)

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

---

## Phase G — Pass 03: `ondas` Mode

Implement the wave encounter mode. Requires Phase D (duelo) to be complete as it shares hero, deck, and energy state management.

### G1. `ondas` mode rules

- The enemy side has no hero. Victory is achieved when all waves have been cleared.
- Defeat occurs when the player hero reaches 0 HP at any point during any wave.
- Between waves, nothing resets: hero HP, deck state, hand, and energy ramp all persist exactly as they were when the last enemy permanent was removed.
- Player permanents remain on the board between waves; only enemy permanents are removed.
- The next wave spawns at the start of the enemy's upkeep after the previous wave is fully cleared.

### G2. `ondas` encounter JSON structure

Encounters using `"mode": "ondas"` use a `"waves"` array instead of `"starting_enemy_slots"`:

```json
{
  "mode": "ondas",
  "waves": [
    {"wave_number": 1, "starting_enemy_slots": [{"slot": 0, "card_id": "..."}]},
    {"wave_number": 2, "starting_enemy_slots": [{"slot": 0, "card_id": "..."}, ...]}
  ]
}
```

The engine reads the current wave index from the encounter state. When all enemy permanents are destroyed and `wave_index < waves.length - 1`, increment `wave_index` and spawn the next wave on the enemy's next upkeep. When the last wave is cleared, trigger victory.

### G3. Optional encounter unlock

`invasao_em_ondas` is an optional encounter that unlocks after `patrulha_avancada` is completed. It is not part of the main encounter chain. The world map marker system (Phase E) must support optional unlock conditions in addition to the linear chain.

---

## Phase H — Visual Layer

Implement the full battle HUD and board feedback layer. Phase H does not depend on Phases B–G and may be developed in parallel. All visual elements read engine state; they do not own rules.

### HUD Target Layout

This is the reference wireframe for the enriched battle screen. All named nodes must exist and be reachable via their script properties (for test assertions).

```
┌──────────────────────────────────────────────────────────────────────┐
│  LIMPAR MESA   Turno 3   Fase: Fase principal   Prioridade: VOCÊ      │
│  [Inimigo] sem herói                                                  │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  [E1 chão  Goblin 2/1  PRONTA]  [E2 chão  —]  [E3 ▲ALTO  Arq 1/3]   │
│                                                                       │
│  [P1 chão  Escu 2/2  ●PRONTA]   [P2 chão  —]  [P3 ●COB  Lobo 3/1 ✗] │
│                                                                       │
├──────────────────────────────────────────────────────────────────────┤
│  ♥ HP 25   ■■□□ 2 arm    Energia: ■■■■□□□□ 4/8    Mão: 4  Baralho: 16│
│  [Preparar Defesa — 1 energia]          [Passar prioridade]           │
├──────────────────────────────────────────────────────────────────────┤
│  [Escu 1  2/2]  [Lobo 1  3/1 rapido]  [Barricada 1  0/5]  [Raio 1]  │
└──────────────────────────────────────────────────────────────────────┘
```

Legend: `●PRONTA` = green border, `✗EXAUSTA` = gray border, `~ENJOO` = amber border. `▲ALTO` = elevated slot badge. `●COB` = cobertura terrain badge. `QUEIM` = queimando terrain badge (also shown on slot when burning, even if empty).

### H1. HUD enrichment

Expand the existing battle header/footer to expose the following as discrete labeled UI nodes (each must be a named node the root script can reference):

- `energy_label`: shows `"Energia: X / Y"` where X is current energy and Y is current max; updates after every action
- `energy_bar`: a progress bar (or sequence of filled/empty pip icons) showing X out of Y; max visually reflects the ramp (not a fixed 8 pips until turn 6+)
- `player_hp_label`: shows `"HP: X / 25"`
- `player_armor_label`: shows `"Arm: X"` (hidden or shows 0 when armor is 0)
- `hand_count_label`: shows `"Mão: X"`
- `deck_count_label`: shows `"Baralho: X"`
- `turn_label`: shows `"Turno X"`
- `phase_label`: already exists — update to include `descarte` as a valid phase string (`"Fase: Descarte"`)
- `priority_label`: already exists — keep behaviour

All labels update immediately when the engine state changes (after each action, at phase transitions, and at start of turn).

### H2. Slot state markers

Each slot container (player and enemy) must display a visible state badge reflecting the current combat state of its occupant:

- `pronta`: green-tinted border or badge reading `"PRONTA"` — shown when the occupant can legally attack this turn
- `exausta`: gray-tinted border or badge reading `"EXAUSTA"` — shown after the occupant has attacked or used an exhausting action
- `enjoo`: amber-tinted border or badge reading `"ENJOO"` — shown when the occupant entered this turn and cannot act yet
- Empty slot: no state badge; show only terrain/elevation labels (H4)

State must update immediately after each engine action without requiring a full re-render of the slot container.

### H3. Attack route highlights

When the player selects (clicks/focuses) a creature slot that is `pronta`:

- Highlight each valid attack target slot with a colored overlay border (distinct from the selection color)
- Use one color for melee targets and a second color for ranged targets (`ranged_targets` from the board JSON); if a slot appears in both lists, use the ranged color
- Highlight the enemy hero target area (if the mode allows it) with the same melee color
- Deselect and clear highlights when: the player clicks elsewhere, an action resolves, or priority changes

If a `pronta` slot has zero valid targets (all routes blocked, mode prevents fallback), show the slot normally without highlighting anything — this is feedback that the creature is stuck.

### H4. Slot terrain and elevation labels

Each slot (player, enemy, and neutral) must display persistent small badges showing its terrain and elevation, even when empty:

- `elevation: "alto"`: badge `"▲ ALTO"` (visible at all times)
- `terrain: "cobertura"`: badge `"◆ COB"` (visible at all times)
- `terrain: "queimando"`: badge `"● QUEIM"` with amber tint (visible at all times; badge animates or pulses when a creature is actively burning — i.e., when a creature occupies the slot and will take damage next upkeep)
- `terrain: "normal"` and `elevation: "chao"`: no badges (default, uncluttered)
- Badges must not obscure the creature name/stats when the slot is occupied; position at the top corner of the slot container

### H5. Floating damage numbers

When a slot occupant or hero takes damage, display a short-lived floating number over the target:

- The number appears at the target's position, moves upward, and fades out over ~0.6 seconds (use a `Tween` or `AnimationPlayer`)
- Color encodes damage type: `fisico_melee` = white/light gray, `fisico_alcance` = light blue, `magico` = light purple
- Armor absorption: show damage absorbed by armor as a separate number in yellow with an `"ARM"` suffix (e.g., `"2 ARM"`) that appears alongside the HP damage number
- If a creature is destroyed, add a brief `"X"` or destruction marker before the slot clears
- Source: read from `eventos_visuais` emitted by the engine after each action

### H6. Slot occupant card info

When a slot is occupied, display the following inside the slot container (in addition to the creature name):

- Current ATK and HP in `"ATK/HP"` format (e.g., `"2/1"` after taking 1 damage from a 2/2)
- HP should reflect current health, not base health; color the HP number red if below 50% of base
- Keyword badges as small pills, one per keyword: `rapido`, `voadora`, `alcance`, `atropelar`, `defensor`, `cobertura`
- `voadora` creatures should be visually offset upward within their slot container (e.g., translated up by ~8px) to suggest elevation; their slot border may use a subtle blue tint
- Structures (`estrutura`) should use a distinct container style from creatures (e.g., square corners vs rounded, or a small `"EST"` label)

### H7. Descarte phase UI

When the engine transitions to the `descarte` phase:

- Display a dedicated panel or overlay section (non-blocking — it replaces the action area, not a full-screen modal)
- Header reads `"Fase: Descarte — escolha cartas para devolver ao baralho"`
- Each card in hand is shown with a toggle/checkbox; selected cards are marked for discard
- A counter shows `"Mão: X → 7"` updating live as the player selects cards; if already at 7 or fewer, counter shows `"Mão: X (ok)"` and no selection is required
- A `"Confirmar descarte"` button sends selected cards to the bottom of the deck and transitions to cleanup
- If hand is already ≤ 7, an optional `"Descartar mesmo assim"` toggle lets the player discard voluntarily before confirming with no selection
- The enemy descarte resolves automatically (no UI); a brief feedback line `"Inimigo descartou X carta(s)."` appears in `feedback_label`

---

## Phase I — Test Coverage

Implement new GUT tests and fix stale tests. Phase I should be developed in parallel with Phases B and C — each new mechanic in B/C gets its test in I immediately, before moving to the next mechanic. All tests go in `tests/unit/`.

Phase I does not add new test files; it adds test functions to the existing files or creates `test_mechanics.gd` for the new keyword and mechanic suites.

### I1. Fix stale tests (do this first, before any other Phase I work)

Two existing tests in `test_battle_engine.gd` will break when Phases A and B5 are implemented. Fix them before running the full suite:

**`test_hand_limit_discards_extra_draws`** — currently tests that drawing beyond the hand limit sends cards to a `discard` array. Phase B5 removes the discard pile; cards go to the bottom of the deck instead. Rewrite this test to:
- Set up a controller with a full hand (at current limit) and a small deck
- Call the draw phase
- Assert that `hand.size()` did not increase
- Assert that the deck bottom now contains the would-be-drawn cards (i.e., deck length is unchanged because cards were attempted from a full hand — or adjust to test that draw-up stops at the limit)

**`test_slot_restriction_rejects_large_card_on_bridge_slot`** — tests size limit logic removed in Phase A2. Delete this test entirely. Replace it with a neutral assertion confirming that any `criatura` can be played into any slot regardless of `size` (i.e., size is no longer a placement constraint).

### I2. Voadora suite — add to `test_battle_engine.gd` or new `test_mechanics.gd`

**`test_voadora_is_immune_to_fisico_melee`**
- Place a `voadora` creature in a player slot
- Have an enemy melee attacker target that slot
- Assert the attack is rejected (`ok == false` or no damage applied)
- Assert the voadora creature's health is unchanged

**`test_voadora_is_transparent_to_melee_routing`**
- Place a `voadora` creature in a front slot and a normal creature behind it (use `fallback_slots` or a multi-occupant route)
- Have an enemy melee attacker target the front slot
- Assert the attack resolves against the non-voadora creature, not the voadora
- Assert the voadora is untouched

**`test_voadora_without_alcance_can_attack_alto_slot`**
- Place a voadora creature (without `alcance`) in a player slot
- Place an enemy creature in an `alto` slot
- Assert the voadora has the `alto` slot as a legal attack target
- Execute the attack and assert damage is dealt (`fisico_melee` type)

**`test_voadora_with_alcance_damage_reduced_by_cobertura`**
- Place a `voadora+alcance` creature in a player slot with `ranged_targets` covering a `cobertura` slot
- Place an enemy creature with some HP in that cobertura slot
- Execute the attack and assert the damage dealt equals `ATK - 1` (cobertura reduction applied to `fisico_alcance`)

### I3. Energy ramp — add to `test_battle_engine.gd`

**`test_energy_ramp_increases_max_each_turn`**
- Start engine at turn 1, assert `max_energy == 3` and `energy == 3`
- Advance to turn 2 (pass both controllers' turns); assert `max_energy == 4` and `energy == 4` at start of player upkeep
- Advance to turn 3; assert `max_energy == 5`

**`test_energy_ramp_caps_at_8`**
- Fast-forward through 8+ turns (or directly set `turno` and call `_resolve_upkeep`)
- Assert `max_energy` never exceeds 8
- Assert `energy` never exceeds 8 after recharge

**`test_unspent_energy_is_lost_not_carried`**
- Start turn 1 with energy 3; spend 0 energy
- End the player's turn (pass twice to advance to turn 2)
- At the start of the player's turn 2 upkeep, assert `energy == 4` (new max), not `energy == 3 + 4`

### I4. Cyclic deck — add to `test_battle_engine.gd`

**`test_spell_goes_to_bottom_of_deck_not_discard`**
- Play a `magia` card from hand (e.g., `raio_curto`) targeting a valid slot
- Assert the card is not in `hand`
- Assert there is no `discard` pile (or it is empty / does not exist)
- Assert the card ID appears at the bottom of the controller's `deck` array

**`test_destroyed_permanent_goes_to_bottom_of_owner_deck`**
- Place a creature in a player slot with 1 HP remaining
- Deal 1 damage to destroy it
- Assert the slot is now empty
- Assert the creature's card ID appears at the bottom of the player's `deck`

### I5. Hand progression and descarte phase — add to `test_battle_engine.gd`

**`test_hand_max_size_increases_by_one_per_turn_capped_at_7`**
- At turn 1: assert `max_hand_size == 5`
- After player upkeep on turn 2: assert `max_hand_size == 6`
- After player upkeep on turn 3: assert `max_hand_size == 7`
- After player upkeep on turn 10 (or any turn >= 7): assert `max_hand_size == 7` (capped)

**`test_compra_fills_hand_to_current_max_not_plus_one`**
- Set hand to 2 cards and `max_hand_size` to 5
- Run the `compra` phase
- Assert `hand.size() == 5` (drew 3, not 1)

**`test_descarte_phase_reduces_hand_to_7`**
- Set hand to 8 cards
- Trigger the descarte phase (engine side: call the discard resolution with a selection of 1 card)
- Assert `hand.size() == 7`
- Assert the discarded card is at the bottom of the deck

**`test_immediate_discard_trigger_at_9_cards`**
- Set hand to 8 cards and deck to have cards available
- Trigger any effect that would add a 9th card to hand (or directly call the over-limit check with `hand.size() == 9`)
- Assert the engine immediately requests a discard without waiting for the descarte phase
- After discard resolves, assert `hand.size() == 8`

### I6. Atropelar chaining — add to `test_battle_engine.gd`

**`test_atropelar_overflow_hits_second_occupant_in_route`**
- Use a board with `fallback_slots` (e.g., `muralha_desfiladeiro`): place a weak creature in E1 (front) and another creature in EB1 (back)
- Play an `atropelar` attacker with ATK high enough to destroy E1 and still have excess
- Execute the attack
- Assert E1 is destroyed
- Assert EB1 received the excess damage (and was not bypassed)

**`test_atropelar_fisico_melee_excess_does_not_hit_voadora`**
- Place a `voadora` creature in the second slot of an `atropelar` attacker's route, and a normal creature behind it (or hero fallback)
- Use an `atropelar` attacker with enough ATK to destroy the first occupant and produce excess
- Execute the attack
- Assert the `voadora` is untouched
- Assert the excess hits the next non-voadora occupant (or hero, if mode allows)

### I7. Defensor routing — add to `test_battle_engine.gd`

**`test_defensor_skipped_when_alternative_target_exists`**
- Set up a board where a `defensor` creature occupies one of two valid targets in the attacker's route
- Assert that `get_attack_options` returns both slots
- Assert the player can choose to attack the non-defensor slot without restriction

**`test_defensor_is_forced_when_it_is_the_only_target`**
- Set up a board where only a `defensor` creature is in the attacker's route (no other valid targets)
- Assert that `get_attack_options` returns only the defensor slot
- Execute the attack against the defensor and assert it resolves normally

### I8. Magia de tabuleiro — add to `test_battle_engine.gd`

**`test_chuva_brasas_applies_queimando_to_all_enemy_slots`**
- Play `chuva_brasas` from hand
- Assert every enemy slot definition has `terrain == "queimando"` (or equivalent slot status flag)
- Advance to enemy upkeep; assert an enemy creature currently occupying any slot takes 1 damage

**`test_chamado_hostes_removes_enjoo_from_all_friendly_creatures`**
- Place two friendly creatures in slots while they are in the `enjoo` state (just played, not rapido)
- Play `chamado_hostes` from hand
- Assert both creatures now have `state == "pronta"` (not `enjoo`)
- Assert `get_attack_options` returns valid targets for both creatures
