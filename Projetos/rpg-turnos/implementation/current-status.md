# Current Status

- Last Updated: `2026-05-06`
- Active Surface: `cardgame-first C1 battle modes`
- Active Project Name: `rpg-turnos`
- Active Track: `Track 01 - Foundation Contracts And First Prototype`
- Active Track Status: `CHEFE_MULTIPARTE_MODE_COMPLETE`
- Current Operational Baseline: `playable Godot 4.6.2 slice with menu, local JSON save/load, 2D exploration placeholder, 20-card deck setup, C1 as the sole runtime combat model, limpar_mesa encounter mode, official duelo mode, official ondas mode, official defesa mode, official chefe_multiparte mode, linear world encounter chain, one-time encounter rewards, NPC progressive rewards, public descarte phase, energy/hand ramp, cyclic bottom-of-deck card flow, damage types, coverage, voadora, dual burning, fallback slots, creature movement, neutral slots in engine, clearer HUD/slots/map/reward feedback, art-ready placeholders with UiTokens and AssetIds, data-driven boards/encounters, automatic enemy priority, simple visual battle feedback, generated scenes, JSON-driven catalog, and green GUT validation`
- Active Goal: `controlled mode/content expansion`
- Active Combat Direction: `C1 - main game, not a variant`
- Preserved Combat Ideas: `A/B priority variants and the phase-based duel are historical only in docs/cardgame-core-experiments.md`
- Active Work Mode: `08_Coordenacao_Agentes Kanban / Decisoes / Handoffs is active for cross-agent coordination`

## Read Next

- `../AGENTS.md`
- `../docs/game-design-document.md`
- `../docs/architecture.md`
- `../docs/cardgame-core-experiments.md`
- `../docs/art-direction.md`
- `../docs/asset-request.md`
- `../docs/open-gaps.md`
- `roadmap.md`
- `tracks/track-01-foundation-first-prototype/cardgame-core-implementation-plan.md`
- `../docs/first-playable-slice-smoke.md`

## Current Runtime

- Deck setup requires exactly 20 unlocked cards.
- Decks may include at most 4 command cards.
- The setup screen has one entry button: `Iniciar encontro`.
- The world map selects the active encounter through the linear marker chain.
- Implemented encounter modes include `limpar_mesa`, `duelo`, `ondas`, `defesa`, and `chefe_multiparte`.
- The old `Duelo antigo` button has been removed.
- The battle engine uses `controladores`, `modo_batalha`, `tabuleiro`, `turno`, public phases, shared priority, and bottom-of-deck cycling.
- Public phases implemented in runtime are `manutencao`, `compra`, `fase_principal`, and `descarte`.
- Cleanup is internal after the public `descarte` phase.
- Player hero starts at 25 HP.
- Duel enemy hero baseline is 20 HP.
- Energy ramps per controller from 3 to 8 on that controller's own upkeep.
- Initial hand is 5 cards.
- Draw phase draws up to the controller's current `max_hand_size`.
- `max_hand_size` ramps from 5 to 7; temporary ceiling is 8; reaching 9 triggers immediate discard to 8.
- There is no active discard pile rule; spells, destroyed permanents, and discarded hand cards go to the bottom of the owner's deck.
- Damage types are implemented: `fisico_melee`, `fisico_alcance`, and `magico`.
- `cobertura` reduces only `fisico_alcance`, stacking terrain and keyword.
- `voadora` enters ready, can reach `alto`, is transparent to non-flying melee routing, and cannot be damaged by non-flying `fisico_melee`.
- `queimando` works as slot status and creature status.
- `fallback_slots` are implemented for melee route continuation.
- `chuva_brasas` and `chamado_hostes` are supported as `magia_de_tabuleiro`.
- `duelo` is implemented with enemy hero, enemy deck/hand/energy, `Golpe Direto`, aggressive AI, and empty-route hero fallback.
- `ondas` is implemented with sequential wave spawning, no enemy hero, persistent player HP/board/hand/deck/energy ramp, and victory only after the final wave is cleared.
- `defesa` is implemented with a survival turn limit, no enemy hero, and no automatic victory from clearing the enemy board.
- `chefe_multiparte` is implemented with `boss_part_slots`, no enemy hero, and victory when all marked parts are destroyed even if support enemies remain.
- Creature movement is implemented as a normal action once per turn.
- Boards may define neutral slots; engine can play/move permanents into them.
- World map has a linear encounter chain: `emboscada_na_ponte -> duelista_bandido -> emboscada_no_cruzamento -> fortaleza_do_desfiladeiro -> invasao_em_ondas -> defesa_do_portao -> colosso_fragmentado`.
- Encounter completion is tracked by `completed_encounter_ids`.
- Encounter rewards are claimed once through `claimed_encounter_reward_ids`.
- NPC rewards use `golpe_preciso` first, then `npc_reward_choices` in order.
- Hero power is `Preparar Defesa`: costs 1 energy and grants 2 persistent armor.
- Enemy decisions resolve automatically until priority returns to the player.
- UI emits simple no-asset feedback for attack, damage, summon, armor, buff, and destruction.
- Save/load uses local JSON at `user://rpg_turnos_save.json`.
- The boot menu exposes `Continuar` when a save exists; `Novo jogo` overwrites the local save.
- Runtime saves after new game, NPC rewards, encounter selection, deck confirmation, and victory rewards.
- Loading falls back to a new game when the save is missing, corrupt, or version-incompatible.
- Battle HUD has HP bars, energy pips, hand/deck count, and discard counter.
- Hand cards show a type stripe.
- Battle slots expose clearer empty/source/target/occupied visual states.
- World markers show connected progress, status labels, and active encounter highlight.
- Result screen shows reward feedback explicitly.
- `UiTokens` and `AssetIds` are registered autoloads.
- Boot, world, battle, card, and result screens expose named art-ready placeholder nodes.
- Card tokens expose `art_rect`, `PipRowComponent`, and `KeywordChipsComponent`.
- Future art files can be added through `core/asset_ids.gd` without changing screen flow.

## Accepted Design, Implemented In Foundation Runtime Alignment

- Public phase flow is `manutencao -> compra -> fase_principal -> descarte`.
- Energy ramps per controller from 3 to 8 and refreshes to current max on that controller's upkeep.
- Initial hand is 5.
- `max_hand_size` starts at 5, ramps to 7, and is enforced as carry-over at the end of `descarte`.
- Temporary hand ceiling is 8; reaching 9 triggers immediate discard to 8.
- The `descarte` phase supports mandatory discard to 7 and voluntary extra discard by the player.
- Decks are cyclic: spells, destroyed permanents, and discarded hand cards go to the bottom of the owner's deck. There is no discard pile in active rules.
- `manter_linha` was removed from the active catalog and generated resource.
- `golpe_preciso` is stored as `first_npc_reward_card`, with `reward_card_id` preserved as a temporary generated compatibility alias.

## Accepted Design, Pending Implementation

- `quebra_cabeca` remains a future battle mode.
- Broader RPG progression, stats, equipment/items, narrative depth, audio, and transition polish remain future layers.

## Implemented Battle Mode Pass 01

- `limpar_mesa` implemented with `Emboscada na Ponte`.
- Enemy side has turns, upkeep, priority, attacks, and starting units, but no enemy hero.
- Player attacks in empty lanes have no hero fallback in `limpar_mesa`.
- Creature-vs-creature damage is simultaneous.
- Creatures use `enjoo`, `pronta`, and `exausta`.
- `rapido`, `defensor`, `atropelar`, and `alcance` are represented in the rules/data.
- `cobertura` reduces ranged damage.
- `queimando` ticks on the occupant controller's upkeep.
- `duelo` exists in the engine/data as the official hero-vs-hero mode.
- `ondas` exists in the engine/data as the official sequential wave mode.
- `defesa` exists in the engine/data as the official survival objective mode.
- `chefe_multiparte` exists in the engine/data as the official boss-parts objective mode.

## Consistency Matrix

| Assunto | Regra ativa | Runtime | Testes | Fonte |
|---|---|---:|---:|---|
| Mao inicial | 5 | sim | sim | GDD |
| Energia | ramp 3->8 | sim | sim | GDD |
| Deck | ciclico, sem pilha de descarte | sim | sim | GDD |
| Descarte | fase publica com voluntario | sim | sim | GDD + decisao 2026-05-05 |
| `size` / `size_limit` | removidos | sim | sim | GDD + dados |
| `manter_linha` | deletada | sim | sim | decisao 2026-05-05 |
| `duelo` | oficial | sim | sim | GDD |
| `ondas` | oficial | sim | sim | GDD |
| `defesa` | oficial | sim | sim | GDD |
| `chefe_multiparte` | oficial | sim | sim | GDD |
| Rewards por encontro | multiplas cartas, claim unico | sim | sim | GDD |
| `voadora` | keyword completa | sim | sim | GDD |
| Visual/UX minimo | HUD, slots, mapa e rewards legiveis | sim | sim | roadmap |
| UI tokens / assets | estrutura placeholder | sim | sim | art-direction |

## Validation Command

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd
```

Latest validation run by Codex on `2026-05-06`: `73/73` GUT tests passing. `tools/validate.gd` succeeds.

## Pending Engine Changes For Codex

All changes below were specified during design sessions on 2026-05-04 and user decisions on 2026-05-05. Foundation, battle-rule completion, official duel, world progression/rewards, minimum save/load, visual/UX hardening, art-ready placeholder structure, official ondas mode, official defesa mode, and official chefe_multiparte mode are complete as of `2026-05-06`; continue linearly with controlled mode/content expansion.

---

## Phase A — Cleanup And Prerequisites (complete 2026-05-05)

Completed before the foundation runtime sync. Kept here as implementation record.

### A1. Check stale git lock files

Git operations currently work in this workspace. If any of the following zero-byte lock files reappear and block git on Windows, delete them before continuing:

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

### A4. Delete `manter_linha`

User decision on 2026-05-05: `manter_linha` is not future, reward, enemy-only, or experimental content. Delete it during the next implementation pass:

- remove the card from `slice_catalog.json`
- regenerate `data/generated/slice_catalog.tres`
- remove tests that inject `manter_linha` as an unlocked command-card stress case, or replace them with another active command card if one exists
- remove active asset planning references such as `card_art_manter_linha`
- keep this decision recorded in `08_Coordenacao_Agentes/Decisoes/2026-05-05_rpg-turnos_cardgame_regras_pendentes.md`

---

## Phase B — Engine Core (complete 2026-05-05)

Foundational rules that all other phases depend on. Completed and validated before Phase C, D, or E.

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

Implemented: the discard pile concept was replaced by bottom-of-deck cycling.

- When a spell (`magia`, `magia_de_tabuleiro`) resolves, it goes to the **bottom** of the owner's deck.
- When a permanent is destroyed, it goes to the **bottom** of its owner's deck.
- When a card is discarded from hand (by choice or over-limit), it goes to the **bottom** of the owner's deck.
- The deck never runs out. There is no deck-out loss condition.
- All code references to a discard pile (`pilha_descarte`, `discard`, etc.) must be replaced with bottom-of-deck insertion.

### B6. Hand size progression, draw-up rule, and temporary ceiling

Implemented: the fixed hand limit and fixed draw-1 rule were replaced.

- **Initial hand:** 5 cards (dealt at game start from the top of the deck).
- **Hand limit progression:** starts at 5 on turn 1, increases by 1 on each of the controller's own upkeeps, capped at 7. Track as `max_hand_size` per controller. This is the carry-over limit enforced at the end of the descarte phase.
- **Temporary ceiling:** 8 cards. A controller may hold up to 8 cards at any point during their turn.
- **Draw phase (`compra`):** draw cards from the top of the deck until `hand.size() == max_hand_size`. If the hand is already at or above the limit, draw nothing.
- **Immediate discard trigger:** if `hand.size() >= 9` for any reason at any point during play, the controller must immediately send cards from hand to the bottom of the deck until `hand.size() == 8`. This does not wait for the descarte phase. Reaching 8 is normal and allowed; only 9 triggers immediate action.
- The enemy controller uses the same draw-up rule, hand limit progression, and ceiling rules.

### B7. Descarte phase (4th public phase)

Implemented: `descarte` is the fourth and final public phase of the turn, after `fase_principal`:

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

**NPC progressive rewards** — the catalog root has a `"npc_reward_choices"` array: `["corvo_batedor", "chuva_brasas", "campeao_guilda"]`. On each NPC interaction after the introductory reward, the engine gives the player the next unclaimed card from this list only when progression requirements are met. The global `"reward_card"` field is legacy and must be renamed to `"first_npc_reward_card"` for `golpe_preciso`, keeping compatibility temporarily only if needed.

This ensures all 11 unlockable player reward cards are accessible across the full progression:
- NPC first visit / intro reward: `golpe_preciso`
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
- Add `claim_first_npc_reward() -> String` for `golpe_preciso`; this replaces the current `claim_npc_reward()` behavior after compatibility migration
- `active_encounter_id` must be settable dynamically by the world when the player interacts with a specific marker (remove the hardcoded constant)
- Update `complete_encounter()` to append to `completed_encounter_ids` instead of setting a bool
- Add `has_completed_encounter(id: String) -> bool` helper
- Add `claim_encounter_reward(encounter_id: String) -> Array[String]` that looks up the `reward_cards` array from `ContentLibrary`, adds each newly unlocked card to `unlocked_card_ids`, skips already unlocked duplicate sources, and records the encounter in `claimed_encounter_reward_ids`
- Update `capture_pre_combat_snapshot()` and `restore_pre_combat_snapshot()` to include the new fields

### E3. World map encounter chain

Replace the single encounter marker in `world_root.gd` with a data-driven list of markers. Markers have two categories: **main chain** (linear unlock, each requires the previous) and **optional** (unlock when a specified encounter is completed, no further dependency).

Marker behavior:
- Locked: muted color, no interaction.
- Available: active color; pressing E sets `GameSession.active_encounter_id` and transitions to `deck_setup.tscn`.
- Completed: completed color; re-entry allowed for practice (no second reward).
- Specified but unsupported: visible only if useful for planning/debug, not playable; do not expose markers for encounters whose mode or board dependencies are not implemented unless explicitly marked as practice/dev.

**Main chain** (linear, each unlocks the next):

| Order | Encounter | Position |
|---|---|---|
| 1 | `emboscada_na_ponte` | `Vector2(400, 330)` |
| 2 | `duelista_bandido` | `Vector2(550, 330)` |
| 3 | `patrulha_avancada` | `Vector2(700, 330)` |
| 4 | `emboscada_no_cruzamento` | `Vector2(850, 330)` |
| 5 | `fortaleza_do_desfiladeiro` | `Vector2(1000, 330)` |
| 6 | `duelista_sombrio` | `Vector2(1000, 220)` |

**Future optional encounters** (appear when unlock condition met, not required for main chain):

| Encounter | Unlocks after | Position |
|---|---|---|
| `emboscada_reforcos` | `emboscada_na_ponte` | `Vector2(400, 220)` |

Current linear implementation adds `invasao_em_ondas` after `fortaleza_do_desfiladeiro`, `defesa_do_portao` after `invasao_em_ondas`, and `colosso_fragmentado` after `defesa_do_portao` to keep Codex execution sequential.

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

Save/load is not required in this documentation-alignment pass, but it must be implemented before progression is treated as durable campaign state.

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

Implemented. Requires Phase D (duelo) to be complete as it shares hero, deck, and energy state management.

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

### G3. Encounter unlock

`invasao_em_ondas` is currently part of the linear implementation chain and unlocks after `fortaleza_do_desfiladeiro`. This keeps the Codex implementation path sequential while optional branch support remains a later map feature.

---

## Phase G2 — Pass 04: `defesa` Mode

Implemented the survival objective mode.

### G2.1. `defesa` mode rules

- The enemy side has no hero.
- Victory is achieved by surviving the number of complete enemy turns defined by `defense_turn_limit`.
- Clearing the enemy board does not immediately win the encounter.
- Defeat occurs when the player hero reaches 0 HP at any point.
- The normal hand, deck, board, discard, and energy rules remain active during the defense window.

### G2.2. First `defesa` encounter

`defesa_do_portao` uses `muralha_desfiladeiro`, starts with pressure on the front and tower lane, and unlocks after `invasao_em_ondas` in the current linear implementation chain.

---

## Phase G3 — Pass 05: `chefe_multiparte` Mode

Implemented the boss-parts objective mode.

### G3.1. `chefe_multiparte` mode rules

- The enemy side has no hero.
- `boss_part_slots` defines which enemy slots are vital boss parts.
- Victory is achieved when all listed boss part slots are empty.
- Enemy support slots may remain alive; the mode does not require clearing the whole enemy board.
- Defeat occurs when the player hero reaches 0 HP at any point.

### G3.2. First `chefe_multiparte` encounter

`colosso_fragmentado` uses `muralha_desfiladeiro`, marks E1, E3, and ET as boss parts, includes a non-part support in E2, and unlocks after `defesa_do_portao` in the current linear implementation chain.

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
- Color encodes damage type through the `UiTokens` feedback table in Phase J10; do not hardcode separate H-phase colors
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

Implement new GUT tests and fix stale tests. Phase I is partially complete for Phase A/B foundation rules; remaining Phase C+ mechanics still need tests when implemented. All tests go in `tests/unit/`.

Phase I does not add new test files; it adds test functions to the existing files or creates `test_mechanics.gd` for the new keyword and mechanic suites.

### I1. Fix stale tests (complete for Phase A/B)

The stale Phase A/B tests were replaced on 2026-05-05:

- `test_hand_limit_discards_extra_draws` was replaced by cyclic deck / immediate discard coverage.
- `test_slot_restriction_rejects_large_card_on_bridge_slot` was replaced by `test_size_no_longer_restricts_slot_placement`.
- `manter_linha` stress fixtures were removed; content/session coverage now asserts the card is absent from the catalog.

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
- After player upkeep on turn 10 (or any turn ≥ 7): assert `max_hand_size == 7` (capped)

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

---

## Phase J — Art-Ready Placeholder Structure

Goal: rebuild every screen so placeholders carry the exact node structure that future art imports will slot into. No textures yet. Every `TextureRect`, `AnimatedSprite2D`, and `GPUParticles2D` that art will eventually populate is named, sized, and present — but invisible or filled with a typed color block. The Codex task is pure GDScript; no image files are imported in this phase.

Reference for asset IDs: `docs/asset-request.md`.

### J1. Design system foundation

**Files to create:**
- `core/ui_tokens.gd` — autoload singleton

**`UiTokens` autoload:**

```gdscript
# core/ui_tokens.gd
extends Node

# Color palette tokens
const BG_DEEP       := Color(0.043, 0.051, 0.059)
const BG_PANEL      := Color(0.094, 0.110, 0.122)
const BG_PANEL_ALT  := Color(0.078, 0.086, 0.094)
const BORDER_DEFAULT:= Color(0.239, 0.282, 0.310)
const BORDER_ACTIVE := Color(0.353, 0.439, 0.502)
const TEXT_PRIMARY  := Color(0.878, 0.878, 0.847)
const TEXT_SECONDARY:= Color(0.541, 0.573, 0.596)
const TEXT_PHASE    := Color(0.690, 0.753, 0.784)

# Card type accent colors
const TYPE_CRIATURA  := Color(0.290, 0.478, 0.353)
const TYPE_ESTRUTURA := Color(0.353, 0.416, 0.478)
const TYPE_PERMANENTE:= Color(0.478, 0.416, 0.227)
const TYPE_MAGIA     := Color(0.416, 0.290, 0.478)
const TYPE_COMANDO   := Color(0.478, 0.290, 0.290)
const TYPE_DEFAULT   := Color(0.310, 0.349, 0.376)

# Phase display names
const PHASE_NAMES := {
    "manutencao":   "Manutenção",
    "compra":       "Compra",
    "fase_principal":"Principal",
    "descarte":     "Descarte",
    "encerrada":    "—",
}

# Mode display names
const MODE_NAMES := {
    "limpar_mesa": "Limpar Mesa",
    "duelo":       "Duelo",
    "ondas":       "Ondas",
}

static func type_color(card_type: String) -> Color:
    match card_type:
        "criatura":   return TYPE_CRIATURA
        "estrutura":  return TYPE_ESTRUTURA
        "permanente": return TYPE_PERMANENTE
        "magia":      return TYPE_MAGIA
        "comando":    return TYPE_COMANDO
    return TYPE_DEFAULT

static func phase_name(phase_id: String) -> String:
    return PHASE_NAMES.get(phase_id, phase_id)

static func mode_name(mode_id: String) -> String:
    return MODE_NAMES.get(mode_id, mode_id)
```

Register `UiTokens` in `project.godot` autoloads. Replace all hardcoded `Color(...)` calls in screen files with `UiTokens.*` references.

### J2. Boot menu — art-ready structure

**File:** `modes/boot/boot_root.gd`

Replace the current single panel with layered structure. Each named node is a future art slot.

```
CanvasLayer
  bg_visual       — ColorRect(BG_DEEP) → future: TextureRect(asset: menu_background)
  ambiance_layer  — Node2D, empty       → future: GPUParticles2D atmospheric effect
  CenterContainer
    panel         — PanelContainer
      VBoxContainer
        logo_container   — CenterContainer, min_size=(360,90)
          logo_rect      — ColorRect(BG_PANEL, border BORDER_ACTIVE) → future: TextureRect(asset: ui_logo)
          logo_label     — Label("RPG Turnos", 38px, centered) — hidden when logo_rect has texture
        subtitle_label   — Label("", TEXT_SECONDARY) — empty until title is set
        [spacer 18px]
        novo_jogo_button — Button
        sair_button      — Button
```

`logo_rect` minimum size: 360×90. When `ui_logo.png` is imported, set it as `logo_rect.texture` and hide `logo_label`.

### J3. World map — art-ready structure

**File:** `modes/world/world_root.gd`

Split `_draw()` into named child nodes. Keep `_draw()` only for the player movement dot (until `player_sprite` receives a texture).

```
Node2D (world_root)
  map_bg          — ColorRect(rect=MAP_RECT, color=Color(0.12,0.16,0.14)) → future: TextureRect(asset: map_environment)
  env_overlay     — Node2D, empty → future: decoration sprites layer
  path_draw       — Node2D, draws line NPC→ENCOUNTER in BORDER_DEFAULT (2px) → future: sprite path
  npc_marker      — Control, position=NPC_POSITION
    npc_icon      — ColorRect(28×28, TYPE_ESTRUTURA) → future: TextureRect(asset: marker_npc)
    npc_name      — Label("NPC", TEXT_SECONDARY, 14px, below icon)
  encounter_marker — Control, position=ENCOUNTER_POSITION
    enc_icon      — ColorRect(34×34, orange/green per state) → future: TextureRect(asset: marker_encounter)
    enc_name      — Label("Encontro", TEXT_SECONDARY, 14px, below icon)
  player_node     — Node2D, position=player_position (updated in _process)
    player_sprite — ColorRect(22×22, TEXT_PRIMARY) → future: AnimatedSprite2D(asset: player_token)
  CanvasLayer
    top_bar       — PanelContainer (existing prompt_label)
    dialogue_panel — PanelContainer (bottom)
      HBoxContainer
        portrait_rect  — ColorRect(72×72, BG_PANEL_ALT, border BORDER_DEFAULT) → future: TextureRect(asset: portrait_npc_viajante)
        VBoxContainer
          speaker_label  — Label("", TEXT_SECONDARY, 12px) — set to NPC name when dialogue opens
          dialogue_text  — Label(autowrap)
          close_button   — Button("Fechar")
```

`portrait_rect` must always be present and sized 72×72. When `portrait_npc_viajante.png` is imported, assign it as `portrait_rect.texture`.

### J4. CardToken redesign (deck setup)

**File:** `ui/controls/card_token.gd`

Target size: 148×180px (full). 132×90px (compact).

```
PanelContainer (bg: BG_PANEL, border: type_color 2px)
  VBoxContainer
    top_bar                — HBoxContainer, 24px tall
      type_badge           — Label(type display name, 10px, type_color bg, TEXT_PRIMARY)
      [spacer]
      cost_pips            — HBoxContainer (PipRowComponent — see below)
    art_rect               — ColorRect(148×80, color=type_color*0.4) → future: TextureRect(asset: card_art_{card_id})
    info_bar               — HBoxContainer, 22px
      name_label           — Label(card name, 13px bold, TEXT_PRIMARY, expand)
      stat_label           — Label("ATK/HP" or "—", 12px, TEXT_SECONDARY)
    text_label             — Label(card.text, 10px, TEXT_SECONDARY, 2 lines, autowrap)
    keyword_row            — HBoxContainer (KeywordChipsComponent — see below)
```

**PipRowComponent** (`ui/controls/pip_row.gd`):
- Receives `cost: int`
- Renders up to 5 filled circles (BORDER_ACTIVE color, 8px diameter) + empty circles (BORDER_DEFAULT)
- If cost > 5: renders "X●" label instead

**KeywordChipsComponent** (`ui/controls/keyword_chips.gd`):
- Receives `keywords: Array[String]`
- For each keyword: small PanelContainer (BG_PANEL_ALT bg, BORDER_DEFAULT border, 4px corner radius) with Label (keyword display name, 9px, TEXT_SECONDARY)
- Display names: `{"rapido":"Rápido","voadora":"Voadora","defensor":"Defensor","alcance":"Alcance","atropelar":"Atropelar","cobertura":"Cobertura"}`
- Hidden when keywords array is empty

**Type badge background**: use `type_color(card.type)` at 60% opacity for the badge.

### J5. BattleCardToken redesign

**File:** `ui/controls/battle_card_token.gd`

Target size: 160×88px.

```
PanelContainer (bg: BG_PANEL, border: BORDER_DEFAULT 1px)
  HBoxContainer
    type_stripe    — ColorRect(4×full_height, type_color) → visual type indicator
    VBoxContainer (expand)
      name_label   — Label(card name, 13px, TEXT_PRIMARY)
      HBoxContainer
        cost_pips  — PipRowComponent (compact: 3 pips max, then "X+")
        [spacer]
        stat_label — Label("ATK / HP", 12px, TEXT_SECONDARY)
      keyword_row  — KeywordChipsComponent
      art_hint     — Label(type_display_name, 9px, type_color, align right) → removed when card has art
```

`type_stripe` uses `UiTokens.type_color(card.type)`.

### J6. Battle board — lane visual structure

**File:** `modes/battle/battle_root.gd`

The board area (between enemy slots header and hand panel) needs explicit lane structure. Currently slots are laid out in generic rows.

Replace the current slot row approach with named lane panels:

```
board_container — VBoxContainer
  enemy_area    — VBoxContainer
    enemy_hero_bar  — HBoxContainer (portrait_rect 48×48, hero name/hp label)
      enemy_portrait_rect — ColorRect(48×48, BG_PANEL_ALT) → future: TextureRect(asset: portrait_hero_{hero_id})
    lane_grid_enemy — GridContainer (columns = route count)
      lane_A_enemy_panel — VBoxContainer, label "Rota A", slots...
      lane_B_enemy_panel — VBoxContainer, label "Rota B", slots...
  divider       — HSeparator (COLOR: BORDER_DEFAULT)
  lane_grid_player — GridContainer (columns = route count)
      lane_A_player_panel — VBoxContainer, label "Rota A", slots...
      lane_B_player_panel — VBoxContainer, label "Rota B", slots...
  player_area   — HBoxContainer
    player_portrait_rect — ColorRect(48×48, BG_PANEL_ALT) → future: TextureRect(asset: portrait_hero_{hero_id})
    player_stats_panel  — VBoxContainer (hp_bar, energy_pips, armor_label, deck_label)
```

Lane panels must show route label ("Rota A", "Rota B") as a small TEXT_SECONDARY label above the slot row. Route label disappears when replaced by actual board art.

Slot visual states (apply via `StyleBoxFlat` swap):
- Empty: BORDER_DEFAULT, BG_PANEL_ALT, dashed appearance (corner_radius=4, thin border)
- Occupied: BORDER_ACTIVE, BG_PANEL, solid border
- Highlighted (valid drop target): `BORDER_ACTIVE` at full brightness + slight bg tint
- Attack target: `TYPE_COMANDO` border pulse (Tween alpha 0.4→1.0→0.4, 0.6s loop)

### J7. HUD stats bar redesign

**File:** `modes/battle/battle_root.gd`

Replace `status_label` string with discrete named nodes. (Expands Phase H1.)

**Player stats layout inside `player_area`:**

```
player_portrait_rect  — ColorRect 48×48 (J6 above)
VBoxContainer
  HBoxContainer
    player_hp_label   — Label("HP", 11px, TEXT_SECONDARY)
    hp_bar            — ProgressBar (custom StyleBox: fill=TYPE_CRIATURA, bg=BG_PANEL_ALT, h=8px, no percentage text)
    hp_value_label    — Label("20/20", 11px, TEXT_PRIMARY)
  HBoxContainer
    energy_label      — Label("Energia", 11px, TEXT_SECONDARY)
    energy_pips       — PipRowComponent (max=5)
    energy_value      — Label("3/5", 11px, TEXT_PRIMARY)
  HBoxContainer
    armor_label       — Label("Armadura  0", 11px, TEXT_SECONDARY)
    deck_label        — Label("Deck  14", 11px, TEXT_SECONDARY)
    hand_label        — Label("Mão  5", 11px, TEXT_SECONDARY)
```

**Header bar (top of battle screen):**

```
HBoxContainer
  turno_label        — Label("Turno 1", TEXT_PRIMARY, 13px)
  mode_label         — Label("Limpar Mesa", TYPE_PERMANENTE, 13px)  ← UiTokens.mode_name()
  phase_label        — Label("Principal", TEXT_PHASE, 13px)         ← UiTokens.phase_name()
  priority_dot       — ColorRect(12×12, corner=6) → green=player, red=enemy, animated alpha
```

Priority dot: Tween `modulate.a` 0.5→1.0→0.5, 1.2s loop when it's the active controller's turn.

**Descarte counter (Phase H7, now named):**

```
discard_bar         — HBoxContainer, visible only during descarte phase
  discard_label     — Label("Descartar: X carta(s)", TYPE_COMANDO, 13px)
  discard_count     — Label("0/X", TEXT_PRIMARY, 13px)
```

### J8. Result screen — victory/defeat differentiation

**File:** `modes/battle/result_root.gd`

```
bg_visual    — ColorRect(BG_DEEP) → future: TextureRect(asset: result_bg_victory or result_bg_defeat)
glow_layer   — Node2D → future: GPUParticles2D celebration/darkness effect
CenterContainer
  panel — PanelContainer
    VBoxContainer
      result_icon_rect  — ColorRect(64×64, centered) → future: TextureRect(asset: icon_victory or icon_defeat)
                          placeholder fill: TYPE_CRIATURA (victory) or TYPE_COMANDO (defeat)
      title_label       — Label, font_size=32
                          victory: TEXT_PRIMARY color, text "Vitória"
                          defeat:  TYPE_COMANDO color, text "Derrota"
      summary_label     — Label (existing)
      reward_panel      — VBoxContainer, visible only on victory when a reward card exists
        reward_title    — Label("Carta obtida:", TEXT_SECONDARY, 12px)
        reward_token    — CardToken (shows the reward card)
      action_button     — Button (existing logic)
```

Panel border color: `BORDER_ACTIVE` on victory, `TYPE_COMANDO` on defeat.

### J9. Asset constants

**File:** `core/asset_ids.gd` — autoload or plain const file (not autoloaded, just a reference)

```gdscript
# core/asset_ids.gd
# Maps logical asset IDs to res:// paths.
# Add entries here as art is imported. Placeholder = empty string.
# Card IDs match slice_catalog.json exactly. See docs/asset-request.md for full spec.

const ASSETS := {
    # UI / menus
    "ui_logo":                      "",  # res://assets/ui/ui_logo.png
    "menu_background":              "",  # res://assets/ui/menu_background.png
    "result_bg_victory":            "",  # res://assets/ui/result_bg_victory.png
    "result_bg_defeat":             "",  # res://assets/ui/result_bg_defeat.png
    "icon_victory":                 "",  # res://assets/ui/icon_victory.png
    "icon_defeat":                  "",  # res://assets/ui/icon_defeat.png
    # World map
    "map_environment":              "",  # res://assets/world/map_environment.png
    "marker_npc":                   "",  # res://assets/world/marker_npc.png
    "marker_encounter_active":      "",  # res://assets/world/marker_encounter_active.png
    "marker_encounter_done":        "",  # res://assets/world/marker_encounter_done.png
    "player_token":                 "",  # res://assets/world/player_token.png
    # Portraits
    "portrait_npc_viajante":        "",  # res://assets/portraits/portrait_npc_viajante.png
    "portrait_hero_aprendiz":       "",  # res://assets/portraits/portrait_hero_aprendiz.png
    "portrait_hero_duelista_bandido":"", # res://assets/portraits/portrait_hero_duelista_bandido.png
    # Card frames (one per type)
    "card_frame_criatura":          "",  # res://assets/cards/frames/card_frame_criatura.png
    "card_frame_estrutura":         "",
    "card_frame_permanente":        "",
    "card_frame_magia":             "",
    "card_frame_magia_de_tabuleiro":"",
    "card_frame_comando":           "",
    "card_back":                    "",  # res://assets/cards/card_back.png
    # Card art — starter deck (IDs match slice_catalog.json)
    "card_art_escudeiro":           "",  # res://assets/cards/art/card_art_escudeiro.png
    "card_art_guarda_vila":         "",
    "card_art_lobo_faminto":        "",
    "card_art_soldado_linha":       "",
    "card_art_arqueira_penhasco":   "",
    "card_art_bruto_mercenario":    "",
    "card_art_javali_guerra":       "",
    "card_art_barricada":           "",
    "card_art_balista":             "",
    "card_art_raio_curto":          "",
    # Card art — reward cards
    "card_art_golpe_preciso":       "",
    "card_art_corvo_batedor":       "",
    "card_art_chuva_brasas":        "",
    "card_art_campeao_guilda":      "",
    "card_art_lobo_alfa":           "",
    "card_art_relampago":           "",
    "card_art_flagelo":             "",
    "card_art_arqueira_voante":     "",
    "card_art_torre_blindada":      "",
    "card_art_dragao_jovem":        "",
    "card_art_chamado_hostes":      "",
}

static func path(asset_id: String) -> String:
    return ASSETS.get(asset_id, "")

static func has_art(asset_id: String) -> bool:
    var p: String = ASSETS.get(asset_id, "")
    return p != "" and ResourceLoader.exists(p)
```

Usage pattern in any screen node: `if AssetIds.has_art("ui_logo"): logo_rect.texture = load(AssetIds.path("ui_logo"))`. This pattern means art slots activate automatically once the path is filled in `asset_ids.gd` and the file is imported — no other code changes needed.

### J10. Visual feedback polish

**File:** `modes/battle/battle_root.gd` — `_spawn_feedback_label()` and `visual_layer`

Upgrade floating feedback labels:

| Event type | Color | Font size | Duration |
|---|---|---|---|
| Damage (fisico_melee) | `TYPE_COMANDO` | 18px | 0.9s |
| Damage (fisico_alcance) | `TYPE_PERMANENTE` | 16px | 0.9s |
| Damage (magico) | `TYPE_MAGIA` | 18px | 1.0s |
| Heal / armor | `TYPE_CRIATURA` | 16px | 0.8s |
| Destroy | `TEXT_PRIMARY` | 22px bold | 1.1s |
| Blocked | `TYPE_ESTRUTURA` | 14px | 0.7s |
| Phase change | `TEXT_PHASE` | 14px italic | 0.6s |

All labels: Tween `position.y -= 48`, `modulate.a` 1.0→0.0. Destroy on tween finish.

`visual_layer` node must be a dedicated `CanvasLayer` (z_index above all board nodes) so feedback floats over cards and slots.

---

### Phase J acceptance criteria

- `UiTokens` autoload resolves in any GDScript file with no null refs
- No hardcoded `Color(...)` in any screen file (all replaced with `UiTokens.*`)
- `AssetIds.has_art(id)` returns false for all entries (no art imported yet)
- `logo_container` present in boot scene; `logo_label` visible when `has_art("ui_logo")` is false
- `portrait_rect` present in world dialogue; sized 72×72; shows typed color block
- `art_rect` present in every `CardToken`; fills 60% of card height with `type_color * 0.4`
- `type_stripe` present in every `BattleCardToken`; 4px wide; correct type color
- `PipRowComponent` renders correctly for costs 0–7
- `KeywordChipsComponent` renders chips for each keyword; hidden when empty
- `player_portrait_rect` and `enemy_portrait_rect` present in battle board; 48×48
- `hp_bar` renders as a filled bar (ProgressBar), not a text label
- `energy_pips` renders as a PipRowComponent row
- `priority_dot` animates when priority owner is active
- `discard_bar` visible only during `descarte` phase
- Result screen: victory uses `TYPE_CRIATURA` icon tint; defeat uses `TYPE_COMANDO`
- Feedback labels use event-type color table (J10)
- Smoke test passes after J is complete
