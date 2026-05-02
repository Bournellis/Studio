# Stage G4-02 - Survival Playable Baseline

## Goal

Bring `Onda de Trolls` into Godot as the first local PvE mode built on top of the shared solo-mode foundation.

## Required Outcome

- the player can enter Survival cleanly from the frontend
- a local wave loop runs to death or defined session end without relying on online seams
- troll enemy and spawn control baseline create real wave pressure
- Survival results surface at least survival time and wave count
- the shared combat shell stays aligned with Arena instead of forking into a separate HUD family

## Scope

- Survival scene, bootstrap, session manager, and game loop
- wave manager and spawn controller baseline
- local enemy runtime needed for the troll baseline
- Survival HUD modules and result summary
- automated validation for the Survival loop

## Non-Goals

- co-op parity pass
- Steam leaderboard submission
- multiple enemy families or Survival variants
- campaign progression gating
