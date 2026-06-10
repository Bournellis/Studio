# Track 01C - Arena Layout V1

- Status: `COMPLETE`
- Last updated: `2026-06-09`

## Goal

Replace the bootstrap rectangle with the first real 1x1 duel map for editor playtesting.

## Delivered

- New runtime map shape named `Duel Pit V1`.
- Arena expanded to `30x30`.
- Protected diagonal spawns: first direct player shot from spawn is blocked by map geometry.
- Central high blocker cuts the long sightline and gives the duel a mid-map anchor.
- Low covers preserve the Track 01B vertical-awareness contract: torso can be hidden while camera/head remains visible.
- High covers and spawn covers fully block visible target points.
- Two low side platforms and two ramp primitives create the first non-flat sightline experiment without jump pads, suspended platforms or void rules.
- Route markings use non-colliding primitive meshes for early readability.
- Bot reposition points were rebuilt around the new layout and exposed through debug helpers for tests.

## Validation

- `tools/validate.gd`: PASS.
- GUT: `19/19` tests, `186` asserts.
- Manual smoke target: 3-5 minute editor duel confirming spawns, mid blocker, low/high cover, ramps/platforms, bot repositioning, hit/miss feedback, restart and sensitivity menu.

## Still Deferred

- jump pads;
- suspended platforms without ramp access;
- void/fall/respawn rules;
- pickups;
- authored navigation/pathfinding;
- advanced cover peeking;
- final art/assets;
- export, multiplayer, matchmaking, backend or Draxos progression/economy systems.
