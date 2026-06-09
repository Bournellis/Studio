# FpsShooter Work Plan

- Last updated: `2026-06-09`
- Status: `BOOTSTRAP_ACTIVE`

## North Star

Create a small first-person shooter tech probe that proves Godot 4.6.2 can support a satisfying PC editor-first 3D combat loop for the studio.

The project starts as a traditional FPS. Special projectile types, jump pads, suspended platforms, void/fall rules and richer knockback play come later.

## Track 00 - Project Bootstrap

Goal: make `Projetos/FpsShooter` an official implementable Godot project.

Acceptance:

- local `AGENTS.md`;
- `implementation/current-status.md`;
- `project.godot`;
- generated main arena scene;
- input bootstrap;
- validation entrypoint;
- initial GUT tests;
- portfolio docs updated.

## Track 01 - Arena 1x1 V1

Goal: editor-playable local 1x1 arena shooter.

Acceptance:

- player can move, look and shoot in first person;
- bot walks and shoots;
- hitscan damage and visible health;
- basic knockback;
- round end state;
- simple arena with walls and obstacles;
- no export requirement.

## Track 02 - Shooter Feel

Goal: make the first-person feel readable and worth iterating.

Candidate scope:

- tune FOV, speed, acceleration and jump;
- improve hit feedback, damage feedback and crosshair;
- add basic recoil/spread decision if useful;
- improve bot readability;
- add a manual smoke checklist.

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
