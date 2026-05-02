# Stage G4-03 - Boss Playable Baseline

## Goal

Bring Boss Mode into Godot as a local authored encounter that shares the same mode-standard structure as the other solo surfaces.

## Required Outcome

- the player can enter Boss Mode cleanly from the frontend
- the boss encounter bootstraps with its own session flow and result path
- the Boss Troll baseline supports readable phases, attacks, and transition beats
- defeat and victory both return cleanly through the shared result flow
- the shared combat-shell contract remains intact

## Scope

- Boss scene, bootstrap, session manager, and game loop
- boss controller and runtime hooks
- Boss HUD modules and result summary
- automated validation for boss flow and return behavior

## Non-Goals

- Steam leaderboard submission
- final numeric tuning pass
- co-op parity
- additional bosses
