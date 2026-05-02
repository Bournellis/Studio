# Stage G4-01 - Shared Mode Foundation And Frontend Routing

## Goal

Open the next Godot phase by turning the single-slice entry flow into a reusable local mode foundation.

## Required Outcome

- the frontend exposes explicit local entry paths for Arena, Survival, and Boss
- launch context carries mode identity and mode-specific parameters without becoming a generic state bag
- each playable mode has a clear bootstrap, session-manager, and game-loop ownership seam
- return flow from each mode resolves cleanly back to the frontend
- the accepted Arena baseline keeps working while the new mode seams open

## Scope

- frontend routing and local mode selection
- launch-context expansion
- composition and bootstrap contracts
- initial scaffolds for `modes/survival/` and `modes/boss/`
- shared return-to-frontend contract

## Non-Goals

- final enemy AI or wave behavior
- boss tuning or boss-script polish
- Steam or co-op seams
- broad HUD polish
