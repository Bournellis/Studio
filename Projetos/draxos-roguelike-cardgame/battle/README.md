# Battle

Local roguelike card battle logic lives here.

Current runtime is intentionally narrow:

- per-encounter `player_slots_count`
- per-encounter `enemy_slots_count`
- dynamic hand limit with base 3-card hand and draw-on-play
- discard shuffles back into the deck when the deck is empty
- creature replacement sacrifices the previous occupant
- automatic attacks resolve on `Resolver Combate`, then maintenance/scripts advance without a separate enemy combat turn
- front attacks are simultaneous inside their stage; overflow attacks resolve sequentially by lane, player then enemy, left to right
- automatic attacks choose the opposing front slot, then the nearest live enemy `defensor` when the lane is empty, then direct hero damage when the mode allows it
- duel enemy hand/deck AI plays new cards after combat and maintenance, preparing the next player turn
- no summoning sickness; creatures can attack in the next available combat after entering play
- pending choices cover floating-card target/options for effects such as `enfraquecer` and `promover`

The battle baseline must not depend on RPG Turnos movement lanes, terrain, elevation, neutral slots, or route tables.
