# Track 01D - Knockback Movement Combat V1

- Status: `COMPLETE`
- Last updated: `2026-06-09`

## Goal

Turn knockback from a basic proof into a readable movement-combat baseline for the `Duel Pit V1` duel loop.

## Delivered

- `FpsCombatant3D` now has an explicit knockback impulse contract:
  - horizontal force is preserved from the shot direction;
  - lift is controlled separately;
  - stacked horizontal and vertical impulse are clamped;
  - impulse decays faster on ground and slower while airborne;
  - debug helpers expose last impulse, event count and horizontal speed.
- Player hits apply stronger readable push and lift without changing the rifle into a new weapon type.
- Bot hits apply a smaller controlled lift through the same combatant contract.
- Arena hit resolution now triggers a short knockback feedback pulse on real hits only.
- The feedback controller adds a primitive beam/sphere/light plus short low tone for knockback without replacing the existing hit, miss or damage state.
- Misses still show tracer/miss feedback but do not apply damage, knockback or false hit confirmation.
- Existing bot `force_fire()` remains immediate for tests.

## Validation

- One-time headless editor import was required in the fresh worktree for GUT global classes.
- `tools/validate.gd`: PASS.
- GUT: `20/20` tests, `203` asserts.
- Added automated coverage for:
  - impulse horizontal force and lift;
  - clamp against excessive stacked force;
  - slower airborne decay than grounded decay;
  - player shot knockback and visual feedback;
  - bot shot knockback;
  - bot miss without knockback;
  - synthetic feedback controller knockback pulse.

## Manual Smoke Target

Open `Projetos/FpsShooter/project.godot` in Godot 4.6.2 and press Play.

Expected:

- player shots push the bot in the shot direction with a small readable lift;
- bot shots push the player with a lighter impulse and red damage feedback;
- misses never move the target;
- knockback remains readable around ramps/platforms without becoming uncontrollable;
- `R` restart clears round state, bot state and transient feedback;
- `Esc` sensitivity menu remains functional.

## Still Deferred

- recoil/spread;
- ammo/reload;
- weapon or projectile variants;
- jump pads;
- suspended platforms without ramp access;
- void/fall/respawn rules;
- pickups;
- advanced air movement tech;
- multiplayer, export, backend or Draxos progression/economy systems.
