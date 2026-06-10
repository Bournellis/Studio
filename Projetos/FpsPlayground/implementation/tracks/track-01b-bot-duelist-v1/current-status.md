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
- Vertical awareness upgrade: normal line of sight scans player camera/head, upper body, body center and lower body points instead of only the body center.
- Low cover can hide the torso while still letting the bot recognize the exposed camera/head point; tall blockers still cancel windup and force reposition.
- Bot windup and deterministic aim use the current visible target point, keeping height important without making `force_fire()` stricter.

## Validation

- `tools/validate.gd`: PASS.
- GUT: `17/17` tests, `132` asserts.
- Manual smoke target: 3-minute editor duel confirming line of sight, bot vertical awareness over low cover, tall cover blocking, bot strafe/reposition, bot hit/miss, received damage, restart and sensitivity menu.

## Still Deferred

- authored navigation/pathfinding;
- cover/peek intelligence beyond line-of-sight and simple reposition points;
- jump pads, suspended platforms and void/fall rules;
- weapon/projectile variants, ammo, reload, spread or recoil models;
- export, multiplayer, matchmaking, backend or Draxos progression/economy systems.
