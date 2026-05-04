# Modes

Composition for playable modes lives here.

Initial lanes:

- `boot/`: startup and first-mode handoff
- `world/`: exploration mode composition
- `battle/`: turn-based card-slot battle mode composition

Do not let mode composition own RPG rules.

Current battle entry starts the active C1 encounter directly; runtime variant selection is not part of the mode flow.
