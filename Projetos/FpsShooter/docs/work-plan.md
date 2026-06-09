# FpsShooter Work Plan

- Last updated: `2026-06-09`
- Status: `FPS_SHOOTER_TRACK_02A_COMBAT_LOOP_EXPANSION_COMPLETE`

## North Star

Create a small first-person shooter tech probe that proves Godot 4.6.2 can support a satisfying PC editor-first 3D combat loop for the studio.

The project starts as a traditional FPS. Track 02A adds the first special projectile and micro-objectives; jump pads, suspended platforms, void/fall rules and deeper movement-combat play still come later.

## Track 00 - Project Bootstrap

Goal: make `Projetos/FpsShooter` an official implementable Godot project.

Status: complete.

Acceptance:

- local `AGENTS.md`;
- `implementation/current-status.md`;
- `project.godot`;
- generated main arena scene;
- input bootstrap;
- validation entrypoint;
- initial GUT tests;
- portfolio docs updated.
- editor-playable FPS baseline with movement, mouse look, hitscan damage, bot V1, HUD, knockback, restart and pause sensitivity menu.

## Track 01 - Arena 1x1 V1

Goal: editor-playable local 1x1 arena shooter.

Status: active; Track 01A, Track 01B, Track 01C and Track 01D are complete.

Acceptance:

- player can move, look and shoot in first person;
- bot walks and shoots;
- hitscan damage and visible health;
- basic knockback;
- round end state;
- simple arena with walls and obstacles;
- no export requirement.

## Track 01A - Feel/Feedback V1

Goal: make the first-person feel readable and worth iterating.

Status: complete.

Delivered:

- agile movement baseline: FOV `86`, move speed `7.8`, jump `5.6` and simple air control;
- rifle hitscan feedback with muzzle flash, tracer, hit/miss distinction, impact flash and synthetic audio;
- HUD crosshair, health bars, damage overlay, short combat messages and round-end feedback;
- bot `0.18s` shot tell before normal damage, while `force_fire()` stays immediate for tests;
- 3-minute manual smoke checklist for editor feel validation.

## Track 01B - Bot Duelista V1

Goal: make the bot useful enough to evaluate the FPS duel loop.

Status: complete.

Delivered:

- fair duel bot states for engage, strafe, reposition, windup, cooldown and dead;
- line-of-sight gate before normal bot shots;
- arena-side raycast resolution for bot hit/miss, damage and knockback;
- deterministic aim error so the bot can miss without relying on loose randomness;
- simple reposition points derived from the current flat map;
- readable bot state colors and bot miss tracer/audio feedback;
- bot line-of-sight and windup aim use visible target points, so camera/head exposure over low cover is recognized while tall blockers still deny shots;
- automated coverage for line of sight, vertical exposure over low cover, windup, hit, miss, strafe/reposition, cancel and restart.

## Track 01C - Arena Layout V1

Goal: replace the bootstrap rectangle with the first real duel map.

Status: complete.

Delivered:

- `Duel Pit V1` runtime layout expanded to `30x30`;
- protected diagonal spawns that block first direct shots;
- central high blocker, spawn covers and high covers for clear line-of-sight breaks;
- low covers that continue testing head/camera exposure over cover;
- two side platforms and two ramp primitives for controlled early height testing;
- visual route markings without gameplay collision;
- bot reposition points rebuilt around the new map;
- automated coverage for map structure, spawn sightline blocking, route markers and bot reposition points.

## Track 01D - Knockback Movement Combat V1

Goal: make knockback useful and readable on the first real duel map.

Status: complete.

Delivered:

- explicit combatant impulse contract with last impulse/event debug data;
- horizontal force, controlled lift and stacked impulse clamps;
- slower airborne decay and faster grounded decay;
- player hit knockback tuned for readable displacement without changing weapon scope;
- bot hit knockback tuned as a lighter received-damage impulse;
- primitive knockback pulse/thump feedback on real hits only;
- automated coverage for impulse, clamp, decay, player hit, bot hit and bot miss.

## Track 02 - Combat Shape Expansion

Goal: expand the duel from pure rifle pressure into a first tactical combat loop.

Status: active; Track 02A is complete.

## Track 02A - Combat Loop Expansion V1

Goal: add a robust first gameplay layer after feel/bot/map/knockback are accepted.

Status: complete.

Delivered:

- RMB `Plasma Bolt`: visible slow projectile, cooldown, primitive glow, hit/miss feedback and stronger controlled knockback;
- overcharge pickup that empowers the next rifle or plasma shot;
- health pickup that creates a recovery objective;
- pickup respawn timers and simple HUD readability;
- bot awareness for health seeking, overcharge contest and nearby plasma dodge;
- arena-side authority for projectile collision, pickup consumption, damage, knockback and feedback;
- automated coverage for input, projectile spawn/hit, pickup effects, bot pickup priority and bot dodge awareness.

Future candidate scope:

- recoil/spread or ammo/reload only if explicitly selected;
- additional projectile variants only after Plasma Bolt is accepted in editor smoke.

## Track 03 - Verticality And Hazards

Goal: add the first gameplay shape beyond a flat arena.

Candidate scope:

- jump pads;
- suspended platforms;
- fall/void respawn;
- knockback as real positional pressure;
- bot awareness for vertical arena rules.

## Deferred

- multiplayer;
- matchmaking;
- online state;
- Web/mobile export;
- Draxos economy/progression/lore systems;
- broad weapon roster;
- Ricochet-like projectile contract.
