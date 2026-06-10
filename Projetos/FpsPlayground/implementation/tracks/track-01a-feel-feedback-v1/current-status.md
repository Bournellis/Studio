# Track 01A - Feel/Feedback V1

- Status: `COMPLETE`
- Last updated: `2026-06-09`

## Goal

Make the first 1x1 FPS duel readable and satisfying enough for editor feel testing.

## Delivered

- Agile arena feel baseline with direct movement, FOV `86`, move speed `7.8`, jump `5.6` and simple air control.
- Simple rifle hitscan preserved: no ammo, reload, spread, projectile variants or weapon roster.
- Player shot feedback: muzzle flash, tracer, hit/miss distinction, impact flash and synthetic shot/hit/miss audio.
- HUD feedback: control-based crosshair, health bars, hit/kill states, damage overlay, short combat messages and round-end feedback.
- Bot readability: normal shots use a short `0.18s` tell before damage; `force_fire()` remains immediate for tests.
- Combatant feedback: reusable body center and short material flash on damage.
- Runtime-generated primitives only; no authored final assets.

## Validation

- `tools/validate.gd`: PASS.
- GUT: `10/10` tests, `94` asserts.
- Manual smoke target: 3-minute editor duel confirming shot, hit, miss, bot tell, received damage, round end, restart and sensitivity menu.

## Still Deferred

- reload, ammo, spread, recoil model and additional weapons;
- special projectiles and stronger knockback variants;
- advanced duel bot behavior;
- jump pads, suspended platforms and void/fall rules;
- export, multiplayer, matchmaking, backend or Draxos progression/economy systems.
