# Track 01 - Foundation Contracts And First Prototype

- Status: `SLICE_01_PLAYABLE`
- Last Updated: `2026-05-03`
- Goal: `prove the first complete playable RPG-cardgame loop without committing final visual direction`

## Implemented Slice

- Menu with `Novo jogo` and `Sair`.
- Session-only game state.
- Small 2D top-down map with player movement, NPC, and encounter marker.
- NPC one-time card reward.
- Encounter gate that requires NPC reward first.
- Full 10-card deck setup with drag-and-drop.
- Turn-based 3-lane enemy-hero duel.
- Scripted enemy behavior.
- Victory result returning to map.
- Defeat result restoring the pre-combat snapshot with no penalty.
- JSON-driven content catalog and generated Godot resource.
- Generated playable scenes.
- GUT validation coverage.

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd
```

Current expected result:

- `10` GUT tests passing.

## Next Decision Sessions

Open a design session before implementing any of these:

- final 2D versus 3D/isometric presentation
- real save/load
- Command/Presence resource
- first real narrative content pass
- RPG progression beyond card unlocks
- expanded enemy AI beyond deterministic scripts
