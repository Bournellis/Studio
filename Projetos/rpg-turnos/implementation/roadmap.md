# RPG Turnos Roadmap

- Last Updated: `2026-05-05`
- Current Direction: `C1 battle modes`

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

## Current Coordination Pass

### Documentation And Process Alignment

Goal: align docs, Kanban/Decisions usage, and implementation order before changing runtime rules.

Status: active.

Includes:

- separate implemented runtime from accepted pending design
- record user decisions in `08_Coordenacao_Agentes/Decisoes`
- mark `manter_linha` for deletion
- keep voluntary discard as part of the public `descarte` phase
- correct validation status and stale-test notes
- define the next implementation pass before `duelo`, H/J, or content expansion

## Current Runtime Pass

### Battle Modes Pass 01 - `limpar_mesa`

Goal: prove the core battle loop with no enemy hero.

Status: implemented, but latest validation is not green because one stale `size_limit` test remains.

Includes:

- `manutencao -> compra -> fase_principal`
- shared priority
- automatic enemy decisions
- enemy side turns without enemy hero
- victory by clearing relevant enemy units
- no empty-lane hero fallback for player attacks

## Active Passes (parallel to Battle Modes)

These are planned surfaces. Do not start broad visual or content expansion before the foundation rule sync below is complete, unless the work is strictly documentation-only.

### Foundation Runtime Alignment — next implementation priority

Goal: make runtime match the accepted GDD rules before expanding modes.

Planned:
- remove `size` / `size_limit` logic and stale tests
- delete `manter_linha`
- implement energy ramp 3->8
- implement initial hand 5, max hand 5->7, temporary ceiling 8, immediate discard at 9
- implement cyclic bottom-of-deck behavior with no discard pile
- implement public `descarte` phase with mandatory and voluntary discard
- update validation/GUT coverage for the above

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
- Fix 2 stale tests
- 20 new tests: voadora, energy ramp, cyclic deck, hand progression, atropelar, defensor, magia_de_tabuleiro, descarte phase, immediate discard trigger

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

### Battle Modes Pass 02 - `duelo`

Goal: expose the official duel mode after Foundation Runtime Alignment is implemented and `limpar_mesa` is stable.

Planned:
- encounter selection or progression-controlled entry
- enemy hero at 20 HP
- enemy deck, hand, energy, and draw
- simple duel AI using cards and attacks
- empty-lane fallback to enemy hero
- victory by enemy hero HP reaching 0

## Later Passes

- More board topology tests.
- More terrain and elevation rules.
- `ondas`.
- `defesa`.
- `chefe_multiparte`.
- `quebra_cabeca`.
- Art asset import (follows asset-request.md priority list).
- RPG progression and card acquisition.
- Save/load.
- Final 2D/3D/hybrid presentation decisions.

## Historical

The phase-based duel and A/B turn variants are preserved only in `../docs/cardgame-core-experiments.md`.
