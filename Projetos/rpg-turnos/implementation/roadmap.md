# RPG Turnos Roadmap

- Last Updated: `2026-05-04`
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

## Current Pass

### Battle Modes Pass 01 - `limpar_mesa`

Goal: prove the core battle loop with no enemy hero.

Status: implemented and validated.

Includes:

- `manutencao -> compra -> fase_principal`
- shared priority
- automatic enemy decisions
- enemy side turns without enemy hero
- victory by clearing relevant enemy units
- no empty-lane hero fallback for player attacks

## Active Passes (parallel to Battle Modes)

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

Goal: expose the official duel mode after `limpar_mesa` is stable and H/I/J are done.

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
