# Systems

Visual-agnostic RPG systems live here.

Initial lanes:

- `character/`: level, stats, profile, progression
- `inventory/`: items, equipment, inventory state
- `dialogue/`: dialogue definitions, dialogue state, narrative flags
- `encounters/`: encounter definitions and launch data
- `save/`: save snapshots and persistence contracts

The active deck rule is implemented under `deck/`: exactly 20 unlocked cards with at most 4 command cards.
