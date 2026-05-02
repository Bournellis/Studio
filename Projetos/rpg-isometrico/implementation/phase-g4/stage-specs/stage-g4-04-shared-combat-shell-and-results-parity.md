# Stage G4-04 - Shared Combat Shell And Results Parity

## Goal

Unify the player-facing runtime shell across Arena, Survival, and Boss so the local multi-mode base does not drift into three separate HUD and result families.

## Required Outcome

- Arena, Survival, and Boss share one combat-shell family instead of drifting HUDs
- mode-specific additions remain modular and bounded
- result overlays and return actions feel structurally consistent across solo modes
- world-space combat feedback stays adjacent presentation, not folded into HUD ownership
- the shared shell is readable on desktop at the current baseline quality bar

## Scope

- HUD composition and module boundaries
- mode-specific info panels inside the shared shell
- result-summary parity and shared return actions
- readability cleanup across the three local modes
- regression coverage for shared presentation seams

## Non-Goals

- final art polish
- mobile HUD layout
- new skills or weapons
- Steam leaderboard UI
