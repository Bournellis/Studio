# Phase G4 Progress Log

## 2026-04-20 - Phase G4 Opened

- Opened `Phase G4 - Shared Solo Base Expansion` as the next bounded Godot phase after Checkpoint G3.
- Chose deliberate expansion over renewed engine-viability proof.
- Set the phase target around shared solo mode foundation, Survival baseline, Boss baseline, and combat-shell parity.
- Kept Steam, campaign, co-op productionization, and broad content reformulation out of scope for this phase.

## 2026-04-20 - Stage G4-01 Executed

- Expanded the frontend from a single Arena launch into explicit local routing for `Arena`, `Survival`, and `Boss`.
- Replaced the old loadout-only launch handoff with a typed shared launch request carrying mode id, scene path, loadout, and sanitized mode parameters.
- Kept Arena on the accepted G3 runtime baseline while moving it onto the shared launch/session foundation.
- Added initial Survival and Boss scaffolds with their own root/bootstrap, session manager, game loop, scaffold overlay, and shared result-return flow.
- Expanded automated coverage with launch-context tests, frontend routing tests, scaffold boot tests, and generated-scene validation.
- Validation for this execution passed through `tools/validate.gd` and a standalone GUT run.

## 2026-04-20 - Stage G4-02 Executed

- Replaced the Survival scaffold with a playable local `Onda de Trolls` baseline built on the G4 shared launch/session foundation.
- Added a bounded troll enemy runtime, local spawn controller, and wave manager with quick-session completion at Wave 7 plus rest windows between cleared waves.
- Reused the shared combat shell through `CombatHud` instead of creating a parallel Survival HUD family, while exposing tempo, onda, and active-enemy module data inside the same shell.
- Extended shared combat feedback and round-summary plumbing so Survival can surface per-run troll pressure and Survival-specific result details without breaking Arena.
- Expanded automated coverage with Survival boot/runtime checks, spawn pressure verification, and wave-to-rest transition validation.
- Validation for this execution passed through `tools/validate.gd` and a standalone GUT run.

## 2026-04-20 - Stage G4-03 Executed

- Replaced the Boss scaffold with a playable local Boss Troll encounter built on the same shared launch/session foundation already consumed by Arena and Survival.
- Added a bounded authored boss runtime with wake-up, three phases, phase-transition invulnerability, regeneration pressure, and the three canonical attacks: `Grande Martelada`, `Tremor Rastejante`, and `Rugido Atordoante`.
- Reused the shared combat shell through `CombatHud` instead of creating a separate Boss HUD family, while exposing Boss phase, boss HP, readable intent, and tempo inside the same shell contract.
- Extended shared result plumbing and combat-summary aggregation so Boss can surface clear-time context, player damage taken, boss phase reached, and Boss-specific combatant summaries without breaking Arena or Survival.
- Expanded automated coverage with Boss boot/runtime checks, phase-threshold validation, and shared result-return validation.
- Validation for this execution passed through `tools/validate.gd` and a standalone GUT run.

## 2026-04-20 - Stage G4-04 Executed

- Reframed `CombatHud` around one shared shell-snapshot contract produced by the active mode runtime instead of branching into separate Arena, Survival, and Boss HUD behaviors.
- Added explicit shell snapshots for `Arena`, `Survival`, and `Boss`, keeping one combat-shell family while preserving bounded mode-specific modules such as duel distance, wave tempo, and boss phase/intent.
- Brought Arena onto the same result-summary contract already used by Survival and Boss so the three solo modes now feed one structured `ResultOverlay` family with aligned summary sections and shared return action.
- Added dedicated regression coverage for shared presentation parity, including shell snapshot structure across all three modes and Arena result-summary parity inside the shared overlay.
- Validation for this execution passed through `tools/validate.gd` and a standalone GUT run with `23` tests and `280` asserts green.

## 2026-04-20 - Stage G4-05 Executed

- Closed the phase around validation and handoff instead of opening new runtime scope.
- Expanded automated regression coverage so the shared frontend now proves mode-specific copy plus launch defaults across `Arena`, `Survival`, and `Boss`, and the launch context now proves sequential consumption without stale parameter leakage during re-entry.
- Rewrote the G4 smoke guide into an explicit local playtest gate with preconditions, pass order, return-contract checks, and exit judgment language for the checkpoint review.
- Opened `Checkpoint G4 - Local Multi-Mode Base Acceptance` so the next planning pass can choose between content reformulation, Steam prep, or campaign prep without reopening shared mode-foundation questions.
- Validation for this execution passed through `tools/validate.gd` and a standalone GUT run with `25` tests and `352` asserts green.

## 2026-04-20 - Checkpoint G4 Accepted

- The implemented G4 packages were accepted as complete after the initially found errors were corrected.
- The local Arena / Survival / Boss base is now treated as a credible shared multi-mode foundation rather than an open checkpoint handoff.
- Remaining improvement ideas are intentionally deferred as later quality work rather than blockers for next-phase planning.
