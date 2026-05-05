# RPG Turnos Roadmap

- Last Updated: `2026-05-05`
- Current Direction: `linear implementation after world progression/rewards`

## Done

- Clean Godot project skeleton.
- Menu, placeholder exploration, NPC reward, encounter marker, deck setup, battle, and result flow.
- JSON-driven card catalog and generated Godot resources.
- Generated playable scenes.
- HUD hardening for small debug viewports.
- C1 promoted from variant to sole runtime combat model.
- Old `Duelo antigo` runtime path removed.
- 20-card deck setup with one `Iniciar encontro` entry.
- `limpar_mesa` mode with `Emboscada na Ponte`.
- Automatic enemy priority resolution.
- Simple no-asset visual feedback for battle actions.
- Foundation runtime alignment: public `descarte`, energy/hand ramp, cyclic deck, and `manter_linha` removal.
- Battle rule completion: damage types, coverage, `voadora`, dual burning, `fallback_slots`, and board spells.
- Official `duelo` mode with enemy hero, enemy deck/hand/energy, aggressive AI, and hero fallback.
- Linear world encounter chain with one-time encounter rewards and progressive NPC rewards.

## Completed Coordination Pass

### Documentation And Process Alignment

Goal: align docs, Kanban/Decisions usage, and implementation order before changing runtime rules.

Status: done.

Includes:

- separate implemented runtime from accepted pending design
- record user decisions in `08_Coordenacao_Agentes/Decisoes`
- mark `manter_linha` for deletion
- keep voluntary discard as part of the public `descarte` phase
- correct validation status and stale-test notes
- define the next implementation pass before broad visual work or content expansion

## Completed Runtime Passes

### Battle Modes Pass 01 - `limpar_mesa`

Goal: prove the core battle loop with no enemy hero.

Status: implemented and covered by current validation.

Includes:

- `manutencao -> compra -> fase_principal`
- shared priority
- automatic enemy decisions
- enemy side turns without enemy hero
- victory by clearing relevant enemy units
- no empty-lane hero fallback for player attacks

## Active Passes

These are planned surfaces. Continue linearly; do not expand content broadly before persistence and a small UX hardening pass.

### Foundation Runtime Alignment

Goal: make runtime match the accepted GDD rules before expanding modes.

Status: done.

Implemented:
- remove `size` / `size_limit` logic and stale tests
- delete `manter_linha`
- implement energy ramp 3->8
- implement initial hand 5, max hand 5->7, temporary ceiling 8, immediate discard at 9
- implement cyclic bottom-of-deck behavior with no discard pile
- implement public `descarte` phase with mandatory and voluntary discard
- update validation/GUT coverage for the above

### Battle Rule Completion

Goal: complete the battle rules that official `duelo` depends on.

Status: done.

Implemented:
- damage types: `fisico_melee`, `fisico_alcance`, `magico`
- coverage stack from terrain and keyword against `fisico_alcance`
- `voadora` readiness, `alto` reach, melee transparency, and melee immunity
- `queimando` as slot status and creature status
- `fallback_slots` route continuation
- board spells for `chuva_brasas` and `chamado_hostes`
- GUT coverage for the above

### Official Duel

Goal: implement the first hero-vs-hero encounter mode.

Status: done.

Implemented:
- `duelista_bandido` with 20 HP enemy hero
- enemy deck, hand, draw, and energy
- enemy hero power `Golpe Direto`
- aggressive deterministic AI
- empty-route fallback to enemy hero
- creature movement as a normal action once per turn
- neutral slot engine support
- GUT coverage for the above

### World Progression And Rewards

Goal: turn the prototype into a linear playable slice with persistent-in-session progression.

Status: done.

Implemented:
- encounter chain: `emboscada_na_ponte -> duelista_bandido -> emboscada_no_cruzamento -> fortaleza_do_desfiladeiro`
- locked, available, completed, and re-entry marker states
- encounter completion tracking
- one-time encounter reward claims
- progressive NPC rewards from `first_npc_reward_card` and `npc_reward_choices`
- snapshot/restore support for progression fields
- GUT coverage for the above

### Minimum Save/Load

Goal: persist the playable slice now that progression and rewards exist in memory.

Status: done.

Implemented:
- local JSON save at `user://rpg_turnos_save.json`
- save data for unlocked cards, selected deck, active encounter, completed encounters, claimed rewards, and NPC reward state
- boot `Continuar` flow when a save exists
- runtime save points after new game, rewards, encounter selection, deck confirmation, and victory
- missing/corrupt save fallback to new game
- GUT coverage for save creation, load restore, and fallback behavior

### Phase H — Visual Layer Improvements

Goal: improve battle HUD readability and feedback without importing art assets.

Planned:
- Discrete HUD nodes (energy_label, hp_bar, phase_label, priority_dot)
- HP bar and energy pip row (ProgressBar / PipRowComponent)
- Card type left-stripe color in BattleCardToken
- Route/lane visual markers with named panels
- Slot visual states (empty, occupied, highlighted, attack target)
- Styled damage number labels per event type
- Descarte counter UI panel

### Phase I — Test Coverage

Goal: raise GUT coverage to include all core battle interactions.

Planned:
- keep validation green as rules evolve
- add focused tests only where the next implementation pass changes behavior
- broaden coverage after save/load and UX surfaces exist

### Phase J — Art-Ready Placeholder Structure

Goal: rebuild every screen so named nodes are ready for art import. No image files yet.

Planned:
- `UiTokens` autoload with color tokens and display name maps
- Boot menu: `logo_container`, `bg_visual`, `ambiance_layer`
- World map: named markers, `player_sprite`, `portrait_rect` in dialogue
- CardToken: `art_rect`, `PipRowComponent`, `KeywordChipsComponent`
- BattleCardToken: `type_stripe` color
- Battle board: named lane panels, `player_portrait_rect`, `enemy_portrait_rect`
- HUD: `hp_bar`, `energy_pips`, `priority_dot`, `discard_bar`
- Result screen: victory/defeat color differentiation, `result_icon_rect`
- `AssetIds` constants file mapping all art IDs to `res://` paths

Reference: `../docs/art-direction.md`, `../docs/asset-request.md`

## Next Pass

### Visual/UX Hardening

Goal: improve readability of the playable slice before adding more content.

Planned:
- battle HUD readability
- slot and target state clarity
- world marker readability
- result/reward feedback clarity
- keep changes no-asset and low-risk

## Later Passes

- More board topology tests.
- More terrain and elevation rules.
- `ondas`.
- `defesa`.
- `chefe_multiparte`.
- `quebra_cabeca`.
- Art asset import (follows asset-request.md priority list).
- Broader RPG progression and card acquisition beyond fixed slice rewards.
- Expanded save/load for campaign state beyond the current slice.
- Final 2D/3D/hybrid presentation decisions.

## Historical

The phase-based duel and A/B turn variants are preserved only in `../docs/cardgame-core-experiments.md`.
