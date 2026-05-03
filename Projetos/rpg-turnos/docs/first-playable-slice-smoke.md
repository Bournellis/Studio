# First Playable Slice Smoke

## Purpose

This smoke document verifies the first playable slice for `rpg-turnos`.

The slice covers:

- menu
- 2D top-down exploration map
- NPC interaction and one-time card reward
- full 10-card deck setup
- turn-based card-slot duel against an enemy hero
- victory/defeat result flow
- return to map or retry from the pre-combat snapshot

## Setup

After a fresh checkout or after adding/updating GUT, run the one-time headless editor import so Godot registers global classes:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos --editor --quit
```

Then run the project validation:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd
```

## Manual Smoke

1. Launch the Godot project.
2. Confirm the first screen is the menu.
3. Press `Novo jogo`.
4. Confirm the 2D map opens.
5. Move with `WASD`.
6. Approach the NPC and press `E`.
7. Confirm the NPC grants `Balista Improvisada` once.
8. Approach the encounter marker and press `E`.
9. Confirm the deck setup opens.
10. Remove one deck card and drag `Balista Improvisada` into a deck slot.
11. Confirm `Iniciar batalha` is enabled only with exactly 10 selected cards.
12. Start the battle.
13. Drag unit or structure cards to player slots.
14. Drag `Centelha Curta` to an enemy slot or enemy hero target.
15. Press `Encerrar turno` to resolve the enemy phase and confrontation.
16. Confirm victory shows a result screen and returns to the map.
17. In a separate run, lose the duel and confirm `Tentar novamente` restores the pre-combat deck/setup state without penalty.

## Expected Automated Coverage

`tools/validate.gd` must:

- generate the JSON-driven slice catalog
- generate scenes without raw `.tscn` hand edits
- validate the first-slice contract
- run GUT tests for session, deck, reward, energy, timing, victory, and defeat

Current expected result:

- `10` GUT tests passing
