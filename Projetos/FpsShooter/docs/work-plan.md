# FpsShooter Work Plan

- Last updated: `2026-06-10`
- Status: `FPS_PLAYGROUND_TRACK_05_FOUNDATION_HARDENING_REFACTOR_COMPLETE`

## North Star

Create a small first-person playground tech probe that proves Godot 4.6.2 can support satisfying PC editor-first first-person 3D game modes for the studio.

The project started as a traditional FPS. Track 02A adds the first special projectile and micro-objectives. Track 03A turns that accepted duel loop into the first no-void vertical arena with jump pads and elevated objectives. Track 03B tunes that arena flow so high routes, pickups and bot intent are easier to read. Track 04A turns the project into `FPS Playground` by adding a container-centered main menu and the first alternate first-person mode: `Futebol` 1x1 against a bot, now with a paused how-to intro and fully closed goal interiors. Track 05 hardens the project so both accepted modes can grow from a cleaner professional foundation. Void/fall pressure is reserved for future dedicated maps.

## Track 00 - Project Bootstrap

Goal: make `Projetos/FpsShooter` an official implementable Godot project.

Status: complete with first fixes.

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

Status: complete; Track 02A is complete.

## Track 02A - Combat Loop Expansion V1

Goal: add a robust first gameplay layer after feel/bot/map/knockback are accepted.

Status: complete.

Delivered:

- RMB `Plasma Bolt`: visible slow projectile, cooldown, primitive glow, crosshair-aligned damage from the offset muzzle, hit/miss feedback and stronger controlled knockback;
- overcharge pickup that empowers the next rifle or plasma shot;
- health pickup that creates a recovery objective;
- pickup respawn timers and simple HUD readability;
- bot awareness for health seeking, overcharge contest and nearby plasma dodge;
- bot pressure hotfix: ready shots now beat pickup routes, health routes can be interrupted by a ready shot and the bot can make simple jumps toward raised reposition goals/low blockers;
- plasma damage hotfix: the projectile now converges toward the camera/crosshair aim point and uses radius-aware collision fallback so visible hits reliably damage the bot;
- arena-side authority for projectile collision, pickup consumption, damage, knockback and feedback;
- automated coverage for input, projectile spawn/hit, pickup effects, bot pickup priority, ready-shot-over-health pressure, pickup-route interruption, simple bot jump and bot dodge awareness.

Future candidate scope:

- recoil/spread or ammo/reload only if explicitly selected;
- additional projectile variants only after Plasma Bolt is accepted in editor smoke.

## Track 03 - Verticality And Hazards

Goal: add the first gameplay shape beyond a flat arena.

Status: complete; Track 03A no-void baseline and Track 03B route tuning are complete.

## Track 03A - Vertical Arena No Void V1

Goal: make vertical positioning part of the playable 1x1 duel loop without using void/fall pressure in the current map.

Status: complete.

Delivered:

- `Duel Pit V2` active map name and runtime layout;
- two high platforms above the existing side routes;
- Health Shard and Overcharge moved onto elevated objectives;
- two jump pads that launch player and bot toward high platforms;
- jump-pad visual/audio/HUD feedback using runtime primitives only;
- bot jump-pad route awareness for high reposition goals;
- `Duel Pit V2` has no active north/south void wells and no fall penalty processing;
- automated coverage for map structure, jump pads, absent void wells and bot vertical routing.

Future candidate scope:

- refine platform geometry after editor smoke;
- add one more vertical route only if Duel Pit V2 feels too binary;
- improve bot route choice if it overuses or underuses jump pads;
- add a dedicated void/fall map variant later, after the no-void vertical duel baseline is accepted.

## Track 03B - Arena Flow & Route Tuning V1

Goal: consolidate `Duel Pit V2` as the first readable no-void vertical duel arena.

Status: complete.

Delivered:

- Health Shard moved to `Vector3(-7.6, 3.55, -8.6)` and Overcharge moved to `Vector3(7.6, 3.55, 8.6)`;
- pickup respawns tuned to Health `10s` and Overcharge `14s`;
- jump pad targets remain near the elevated objectives, but pickups require a small micro-commit after landing;
- cyan route/landing markers, green health objective marker and purple overcharge objective marker added with runtime primitives;
- high platforms gained light cover pieces that support short duels without fully closing shooting lanes;
- bot route selection now exposes route labels/debug score data and uses vertical-route cooldown/objective intervals to reduce immediate high-route loops;
- ready shot pressure still beats pickup routing, while health and overcharge routes remain available when the bot is hurt or lacks a clear shot window;
- HUD now shows a compact bot flow line with state, route, LOS and last jump pad cue for editor playtest.

Future candidate scope:

- compare editor smoke notes against bot route labels to tune route weights;
- add one more ground/high connection only if the arena still feels binary;
- keep void/fall pressure for a dedicated future map, not this `Duel Pit V2` baseline.

## Track 04 - FPS Playground Modes

Goal: preserve the accepted FPS arena loop while opening the project to alternate first-person prototypes.

Status: active; Track 04A is complete.

## Track 04A - Menu & Futebol V1

Goal: create the `FPS Playground` shell and first alternate mode.

Status: complete.

Delivered:

- project display name changed to `FPS Playground`, with folder name `FpsShooter` preserved;
- generated container-centered main menu scene with `Arena Shooter`, `Futebol` and `Sair`;
- `Arena Shooter` remains intact and can return to the main menu from pause;
- `Futebol` mode in first person, 1x1 against a bot, no weapons, score to 3 goals;
- paused `Como Jogar` / `Comecar` intro before football gameplay and mouse capture;
- LMB kick and RMB strong kick reuse the existing FPS input/camera flow without applying damage;
- arcade loose `RigidBody3D` football with velocity clamps and reset safeguards;
- primitive festive stadium with field, safe goal floors and side walls, goal frames, crowd bands and score/flow HUD;
- simple football bot that chases, attacks, defends, jumps toward high ball positions and emits kick requests;
- shared feedback controller extended with football kick/goal primitives and synthetic audio;
- bootstrap generation and validation now cover menu, arena and football scenes.

Future candidate scope:

- tune ball friction/bounce and kick reach after human smoke;
- add goalkeeper-style positioning only if 1x1 defense feels unreadable;
- add boost/dash or slide tackle only after the base kick loop is accepted;
- add multiple football maps only after this first field is fun enough to iterate.

## Track 05 - Foundation Hardening & Refactor V1

Goal: turn the accepted two-mode prototype into a cleaner professional foundation without changing gameplay.

Status: complete.

Delivered:

- documentation index, architecture overview, codebase audit and mode/bot/tuning/validation/publication contracts;
- validation profile hardening and clearer known-warning policy;
- shared runtime primitive helpers so mode roots stop owning every mesh/collision detail;
- safe Arena/Futebol layout builders and rule extraction;
- bot aim/visibility helper extraction while preserving state-machine behavior;
- test suite split into broad integration regression plus focused pure-helper coverage;
- closeout docs and portfolio update.

Acceptance:

- `Arena Shooter` behavior preserved;
- `Futebol` behavior preserved;
- automated validation green after every phase;
- docs explain where new work belongs;
- mode roots are easier to extend for the next mode/map;
- test failures become easier to locate.

Future candidate scope:

- choose a gameplay growth track now that the foundation is clean;
- recommended candidates are football feel/possession tuning, arena content/map expansion, or another small FPS Playground mode;
- keep export/publication as a separate readiness track.

## Deferred

- multiplayer;
- matchmaking;
- online state;
- Web/mobile export;
- Draxos economy/progression/lore systems;
- broad weapon roster;
- Ricochet-like projectile contract.
