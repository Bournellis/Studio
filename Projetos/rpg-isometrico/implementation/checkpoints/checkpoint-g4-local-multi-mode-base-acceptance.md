# Checkpoint G4 - Local Multi-Mode Base Acceptance

## Purpose

Checkpoint G4 exists to decide whether the current Godot implementation has moved beyond
one proven combat slice and become a credible **local multi-mode base**.

## Current Snapshot

- Status: `CLOSED - ACCEPTED AS CREDIBLE LOCAL MULTI-MODE BASE`
- Covered Work:
  - `Phase G4 - Shared Solo Base Expansion`
  - `Stage G4-01` through `Stage G4-05`
- Slice: `frontend -> Arena / Survival / Boss -> shared result/return`
- Runtime Scope: `solo local only`
- Shared Surfaces: `frontend routing, typed launch context, shared combat shell, shared result overlay, shared return contract`
- Validation:
  - `tools/validate.gd` passes
  - GUT passes with `25/25` tests and `352` asserts
  - `docs/g4-shared-mode-foundation-smoke.md` now defines the local playtest gate
  - the implemented packages were accepted as complete after the initially found errors were corrected, with remaining issues treated as later quality follow-up rather than blockers

## What Is Now Proven

- one frontend can route into `Arena`, `Survival`, and `Boss` without mode-specific bootstraps drifting apart
- Arena still preserves the accepted G3 combat-validation baseline while living on the shared G4 launch/session foundation
- Survival and Boss now run as real local playable surfaces, not scaffolds
- one `CombatHud` shell contract and one `ResultOverlay` family now cover the three solo modes
- automated regression now covers routing copy/defaults, launch-context sanitization plus re-entry consumption, Arena regression/result, Survival wave flow, Boss phase/result flow, and shared presentation parity

## What Is Not Yet Proven

- human local feel or readability judgment from a fresh interactive play pass on this exact handoff
- release-build behavior
- Steam, online, or campaign scope
- public playtest operations

## Acceptance Questions

- Does the Godot project now feel like a believable local multi-mode base rather than one accepted Arena slice with side experiments?
- Can the next planning pass choose between content reformulation, Steam prep, or campaign prep without reopening shared routing, HUD, and result-return questions?
- Are the remaining unknowns now mostly about next-phase direction and quality tuning instead of mode-foundation risk?

## Acceptance Criteria

- `tools/validate.gd` stays green
- GUT stays green
- the multi-mode smoke guide is explicit enough to run without scene or parameter guesswork
- frontend routing, mode entry, in-match flow, shared result overlay, and return-to-frontend behavior remain coherent across `Arena`, `Survival`, and `Boss`
- the current base is judged credible enough to plan the next bounded phase on top of it

## Current Decision

- Decision: `ACCEPTED AS CREDIBLE LOCAL MULTI-MODE BASE`
- Reason: the Godot implementation now supports a believable shared local base across `Arena`, `Survival`, and `Boss`; automated validation is green; the stage package was implemented and corrected to a level considered complete for next-phase planning.

## Planning Handoff

The next planning conversation should assume:

- Checkpoint G4 is accepted and closed
- the shared local mode foundation is delivered
- Arena remains the combat-validation surface inside the multi-mode base
- Survival and Boss remain the bounded local PvE baselines
- the next bounded phase should explicitly choose between content reformulation, Steam preparation, or campaign preparation
- shared mode-foundation work should reopen only if the local playtest gate exposes a concrete blocker
