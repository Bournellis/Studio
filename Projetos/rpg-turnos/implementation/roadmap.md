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

## Next Pass

### Battle Modes Pass 02 - `duelo`

Goal: expose the official duel mode after `limpar_mesa` is stable.

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
- RPG progression and card acquisition.
- Save/load.
- Final 2D/3D/hybrid presentation decisions.

## Historical

The phase-based duel and A/B turn variants are preserved only in `../docs/cardgame-core-experiments.md`.
