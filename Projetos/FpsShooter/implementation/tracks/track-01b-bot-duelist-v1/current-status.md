# Track 01B - Bot Duelista V1

- Status: `COMPLETE`
- Last updated: `2026-06-09`

## Goal

Make the bot useful enough to evaluate the local 1x1 FPS duel loop.

## Delivered

- Fair duel bot baseline with explicit states: `idle`, `engage`, `strafe`, `reposition`, `windup`, `cooldown` and `dead`.
- Normal bot shots require target range and line of sight before windup.
- Normal bot shots are resolved by arena raycast, so cover blocks damage and deterministic aim error can produce real misses.
- `force_fire()` remains immediate and direct for tests.
- Bot movement now alternates distance management, strafe and simple reposition points derived from the current flat arena.
- Bot state is readable through lightweight color changes and existing tell feedback.
- Bot miss feedback uses a short amber tracer/audio without damaging the player.

## Validation

- `tools/validate.gd`: PASS.
- GUT: `16/16` tests, `127` asserts.
- Manual smoke target: 3-minute editor duel confirming line of sight, bot strafe/reposition, bot hit/miss, received damage, restart and sensitivity menu.

## Still Deferred

- authored navigation/pathfinding;
- cover/peek intelligence beyond line-of-sight and simple reposition points;
- jump pads, suspended platforms and void/fall rules;
- weapon/projectile variants, ammo, reload, spread or recoil models;
- export, multiplayer, matchmaking, backend or Draxos progression/economy systems.
