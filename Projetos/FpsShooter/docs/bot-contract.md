# FPS Playground Bot Contract

- Last updated: `2026-06-10`
- Status: `TRACK_05_ACTIVE`

## Purpose

This document defines what the arena duel bot owns, what the arena owns and what tests must preserve during hardening.

## Bot Role

`BasicDuelBot` is a local editor-first opponent for evaluating first-person duel feel. It is intentionally not a perfect competitive bot.

The bot owns:

- high-level state machine;
- movement intent;
- strafe/reposition selection;
- line-of-sight and target exposure checks;
- deterministic aim offset selection;
- windup/tell timing;
- pickup/overcharge interest;
- projectile dodge intent;
- simple jump and jump-pad route awareness;
- debug state for tests and HUD readability.

The arena owns:

- final shot raycast resolution;
- applying damage;
- applying knockback;
- hit/miss feedback;
- pickup consumption;
- projectile simulation;
- round end.

## Required States

Current states are stable API for tests and HUD:

- `idle`
- `engage`
- `strafe`
- `reposition`
- `windup`
- `cooldown`
- `dead`

Do not rename states without a migration and test update.

## Required Signals

The bot may emit:

- `shot_fired`
- `shot_windup_started(origin, target_position, duration)`
- `shot_feedback_requested(origin, target_position)`
- `shot_resolution_requested(origin, direction, damage, knockback)`

`shot_resolution_requested` is the authoritative normal-shot handoff. The arena must decide hit or miss.

## Debug Contract

Tests and HUD may use:

- `debug_get_state()`
- `debug_get_target()`
- `debug_has_line_of_sight()`
- `debug_get_reposition_destination()`
- `debug_get_last_aim_position()`
- `debug_get_visible_target_position()`
- `debug_is_projectile_dodging()`
- `debug_get_jump_count()`
- `debug_get_jump_pad_launch_count()`
- `debug_get_route_label()`
- `debug_get_last_reposition_score()`
- `debug_is_high_route_active()`
- `debug_get_last_navigation_target()`

When refactoring internals, keep these methods stable unless a test migration is part of the same commit.

## Fairness Rules

- Normal shots require living target, range and line of sight.
- Normal shots use tell/windup before damage.
- Deterministic aim error can create real misses.
- `force_fire()` remains immediate for tests.
- Ready shot pressure beats health pickup routing unless the bot is in critical survival state.
- Health routing should not dominate pressure.
- Overcharge routing should happen only when pressure is not clearly available.
- Jump-pad routes should be useful but not loop endlessly.

## Refactor Guidelines

Safe extractions:

- visibility point calculation;
- raycast visibility checks;
- aim error math;
- route scoring/classification;
- debug data structs or helper methods.

Track 05 implemented the first two low-risk helper seams:

- `gameplay/bot/bot_visibility_points.gd` builds the target exposure points used by the existing raycast flow.
- `gameplay/bot/bot_aim_model.gd` owns deterministic aim offset patterns and distance-scaled aim error.

Risky extractions:

- splitting state transitions before tests are split;
- changing movement velocity composition;
- changing cooldown/windup timing;
- changing pickup priority weights without a gameplay tuning track.

Track 05 should preserve feel. Bot difficulty changes belong in a later gameplay track.
