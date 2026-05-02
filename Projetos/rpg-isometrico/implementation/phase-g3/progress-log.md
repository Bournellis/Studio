# Phase G3 Progress Log

## 2026-04-19 - Stage G3-01 Executed

- Added combat telemetry to `GameContext` so round stats and recent event feed are available during and after the fight.
- Added action pulses for player and bot actions, plus a visible melee telegraph window for the bot.
- Expanded the HUD with player status, bot intent, and recent event feed.
- Expanded the result overlay with round summary stats for both combatants.
- Added automated tests for the new combat telemetry surface and kept validation green.

## 2026-04-19 - Stage G3-02 Executed

- Replaced the instant round start with an explicit pre-match countdown in `ArenaSessionManager`.
- Added a short post-match linger so the final hit can breathe before the result overlay appears.
- Added floating combat feedback for damage, heal, barrier, block, and death moments.
- Expanded automated coverage for the new session flow and kept validation green.

## 2026-04-19 - Stage G3-03 Executed

- Added camera impact feedback so damage exchanges land with more presence in the arena.
- Expanded the HUD to surface basic attack and dash readiness, not only skill and potion cooldowns.
- Reworked the bot into a clearer pressure -> windup -> reposition rhythm.
- Added automated coverage for the new bot pacing and arena impact hooks and kept validation green.

## 2026-04-19 - Stage G3-04 Executed

- Added a 3D combat clarity layer with player basic-attack reach, dash distance, bot threat ring, and ground aim marker.
- Exposed the minimum controller state needed to drive those spatial clarity surfaces cleanly.
- Expanded automated coverage for the new clarity layer and kept validation green.

## 2026-04-19 - Stage G3-05 Executed

- Added a dedicated `SkillFeedback3D` layer so projectile, buff, burst, and leap skills read differently on the arena floor.
- Extended the player skill execution payload so the readability layer can stage origin, impact, duration, and hit-confirmed moments cleanly.
- Wired the new layer into the authored arena baseline and expanded automated coverage for the new runtime surface.
- Replaced the old target-biased skill resolution for projectile and leap with desktop manual aim authority, while keeping the future mobile plan as lock-on plus tap-release or drag aim.

## 2026-04-19 - Stage G3-06 Executed

- Added stronger target-side hit feedback, including impact halo pulses and a heavier flash on damage and blocks.
- Added short shared motion pauses on impact moments so hits land with more weight without changing the whole engine timescale.
- Extended the final-blow beat with a slightly longer post-match linger and expanded automated coverage for the new combat feel hooks.

## 2026-04-19 - Stage G3-07 Executed

- Reduced floor clutter by making baseline rings and threat surfaces more contextual instead of equally loud all the time.
- Changed the manual skill preview logic to show only the most relevant preview at a time instead of stacking both projectile and leap guides together.
- Lightened buff and burst staging so arena readability stays stronger during real exchanges.

## 2026-04-19 - Stage G3-08 Executed

- Expanded the arena footprint and moved the camera to a more zoomed-out orthographic framing while keeping the player locked at center.
- Added closed perimeter walls so the fight space reads as an enclosed arena instead of an open platform.
- Added a small set of interior wall blocks to give the floor more shape without choking the simple bot loop.
- Expanded automated coverage so the larger arena, wall enclosure, and obstacle layout stay protected.

## 2026-04-19 - Phase G3 Accepted

- The first Godot slice was judged as proven after repeated playtesting and iterative polish.
- The project now treats Godot viability as accepted rather than still under proof.
- The next conversation should plan deliberate expansion from this baseline instead of continuing open-ended slice validation.
