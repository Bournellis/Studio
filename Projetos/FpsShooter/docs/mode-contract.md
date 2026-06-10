# FPS Playground Mode Contract

- Last updated: `2026-06-10`
- Status: `TRACK_05_ACTIVE`

## Purpose

This contract defines how playable modes should be assembled and operated in `FPS Playground`. It applies to `Arena Shooter`, `Futebol` and future local first-person modes.

## Required Responsibilities

Every mode root owns:

- world setup needed by that mode;
- static/runtime layout construction;
- player, bot, HUD and feedback spawning;
- signal wiring;
- pause and restart flow;
- return to main menu;
- authoritative mode state;
- HUD snapshot creation.

Every mode root should delegate:

- primitive mesh/collision creation to shared helpers;
- reusable gameplay math to `gameplay/`;
- visual/audio effects to `presentation/feedback/`;
- HUD rendering to `presentation/hud/`;
- tests to domain-specific test files.

## Standard Runtime Phases

Mode roots should expose this internal sequence where practical:

1. `_configure_world()`
2. `_build_layout()` or mode-specific equivalent
3. `_spawn_runtime()`
4. `_wire_signals()`
5. `_restart_play()` / `restart_round()` / `restart_match()`
6. `_build_hud_snapshot()`

The exact names can vary in older code, but new code should follow this shape.

## Shared Player Contract

The player controller can be reused by modes, but the meaning of fire requests is mode-owned:

- In `Arena Shooter`, `shoot_requested` means rifle shot and `alt_fire_requested` means Plasma Bolt.
- In `Futebol`, `shoot_requested` means kick and `alt_fire_requested` means strong kick.

Modes must not let football kicks apply weapon damage.

## HUD Snapshot Contract

Snapshots should be dictionaries with stable string keys. Missing keys must be treated as optional by HUDs.

Common suggested keys:

- `mode_name`
- `is_paused`
- `message`
- `player_health`
- `bot_health`
- `player_score`
- `bot_score`
- `match_over`
- `round_over`
- `bot_state`
- `bot_route_label`

Mode-specific keys are allowed, but should be documented in the owning HUD script or mode doc.

## Pause/Menu Contract

All modes should support:

- `Esc` toggles pause when gameplay is active.
- `Retomar` returns to gameplay and captures mouse.
- `Menu inicial` returns to `res://modes/menu/main_menu.tscn`.
- Sensitivity changes update the player controller.

`Futebol` additionally starts with an intro/how-to panel. While that panel is open, gameplay should be paused and mouse capture should remain released.

## Restart Contract

`R` should restart the active mode state without returning to the main menu:

- `Arena Shooter`: reset round, health, projectiles, pickups and bot state.
- `Futebol`: reset score, ball, player/bot positions and match state.

Restart should clear transient feedback where practical.

## Future Mode Checklist

Before adding a new mode:

- define the mode name and player input meaning;
- decide what the bot owns and what the mode resolves;
- define HUD snapshot keys;
- add generated scene support;
- add boot test and at least one gameplay contract test;
- add manual smoke section to `docs/validation.md`.
