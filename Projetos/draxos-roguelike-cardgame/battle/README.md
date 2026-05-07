# Battle

Local roguelike card battle logic lives here.

Current runtime is intentionally narrow:

- per-encounter `player_slots_count`
- per-encounter `enemy_slots_count`
- stable 5-card hand with draw-on-play
- discard shuffles back into the deck when the deck is empty
- creature replacement sacrifices the previous occupant
- automatic attacks choose the opposing front slot, then the first occupied opposing slot from left to right

The battle baseline must not depend on RPG Turnos movement lanes, terrain, elevation, neutral slots, or route tables.
