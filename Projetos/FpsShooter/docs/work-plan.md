# FpsShooter Work Plan

- Last updated: `2026-06-09`
- Status: `TRACK_01B_BOT_DUELIST_COMPLETE`

## North Star

Create a small first-person shooter tech probe that proves Godot 4.6.2 can support a satisfying PC editor-first 3D combat loop for the studio.

The project starts as a traditional FPS. Special projectile types, jump pads, suspended platforms, void/fall rules and richer knockback play come later.

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

Status: active; Track 01A and Track 01B are complete.

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
- automated coverage for line of sight, windup, hit, miss, strafe/reposition, cancel and restart.

## Track 02 - Next Combat Shape

Goal: choose the next gameplay shape after the first readable duel baseline.

Candidate scope:

- arena layout pass with clearer cover, sightlines and spawns;
- knockback and movement-combat pass;
- recoil/spread or ammo/reload only if explicitly selected;
- future projectile variants after hitscan feel remains stable.

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
