# First Playable Slice Smoke

- Last Updated: `2026-05-04`
- Active Encounter: `emboscada_na_ponte`
- Active Mode: `limpar_mesa`

## Goal

Confirm the playable slice still works after C1 became the sole runtime combat model.

## Manual Flow

1. Start the project.
2. Choose `Novo jogo`.
3. Move with `WASD`.
4. Talk to the NPC with `E`.
5. Confirm the NPC grants `Golpe Preciso`.
6. Walk to the encounter marker.
7. Press `E` to open deck setup.
8. Confirm the setup shows 20 deck slots.
9. Confirm there is no `Duelo antigo` or variant button.
10. Remove and add cards, then use `Auto preencher`.
11. Confirm `Iniciar encontro` is enabled only with a valid 20-card deck.
12. Start the encounter.
13. Confirm the battle header shows mode `Limpar mesa`.
14. Confirm the enemy hero area says there is no enemy hero.
15. Play a creature into a valid player slot.
16. Confirm the enemy acts automatically when it receives priority.
17. Confirm the game pauses when priority returns to the player.
18. Use `Preparar Defesa` and confirm armor feedback appears.
19. Attack an occupied route and confirm damage/destruction feedback appears.
20. Try an empty player attack route in `limpar_mesa` and confirm no direct enemy hero target exists.
21. Destroy all enemy units and confirm victory returns to result flow.
22. In a separate run, lose the battle and confirm `Tentar novamente` restores the pre-combat setup.
23. Resize near `960x540`, `1100x619`, and `1280x720`; confirm `Preparar Defesa`, `Passar prioridade`, hand cards, slot actions, and feedback stay visible.

## Automated Validation

Run:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd
```

Expected:

- generated catalog succeeds
- generated scenes succeed
- first-slice contract succeeds
- GUT passes
