# FpsPlayground Work Plan

- Status: `FPS_PLAYGROUND_TRACK04_ARENA_MOVEMENT_FLOW_BOT_NAVIGATION_DOING`
- Current surface: FPS arena lab.

## North Star

Keep `FpsPlayground` as a clean first-person gameplay laboratory for arena movement, shooting, projectiles, bots, maps and combat feel.

## Complete Baseline

- Project split from `FpsShooter` into `FpsPlayground`.
- Menu launches only `Arena Shooter`.
- Arena Shooter preserves the accepted `Duel Pit V2` baseline.
- Validation now targets FPS resources and arena tests only.
- Football/TPS scope moved to `../JogoDaCopa`.

## Previous Track

`Track 02 - Bot Tactical Movement V1` is approved after automated validation and Fabio smoke.

Goals:

- Make the bot harder primarily through better movement and route decisions, not raw aimbot tuning.
- Replace one-arena reposition assumptions with an arena-provided tactical context.
- Let arenas declare tactical affordances: pressure, flank, cover, retreat, health, overcharge, high ground and jump pad routes.
- Improve bot route scoring, anti-repeat behavior, stuck recovery and objective pressure.
- Preserve readable shot windup and fair reaction windows.

Delivered:

- Bot tactical context helper and Duel Pit V2 tactical provider.
- Tactical route scoring for pressure, flank, cover, retreat, health, overcharge, high ground and jump pad routes.
- Anti-repeat route memory and objective route holding for critical health/vertical pressure.
- Conservative bot pressure tuning through cooldown/reaction/aim values.
- Focused automated tests for alternate arena context and critical health route priority.

Delivered before this track:

- Track 01 approved combat readability: bot tell, damage intake, Plasma hit/overcharge, pickups and jump pad cues.

Non-goals:

- No new weapon.
- No new map/layout.
- No export, Web/mobile, multiplayer or backend.
- No football/TPS scope.
- No impossible instant-shot bot behavior.

## Previous Track

`Track 03 - Arena Tactical Context Proof V1` is locally validated and ready for human smoke.

Goals:

- Prove that bot tactical movement is arena-agnostic in playable content, not only in unit tests.
- Move layout-specific data into a catalog/provider that can describe multiple arenas.
- Keep `Duel Pit V2` as the default known-good baseline.
- Add `Relay Foundry V1`, a second arena with different footprint, route graph, high ground, pickups and jump pad flow.
- Let the main menu launch either arena.
- Add automated coverage that checks both arenas publish tactical points, roles and route labels to the bot.

Delivered:

- `ArenaLayoutCatalog` moved layout data out of `arena_root.gd`.
- `Duel Pit V2` remains the default baseline.
- `Relay Foundry V1` adds a second arena with distinct geometry, high routes, pickups, jump pads and tactical points.
- Main menu can launch either arena.
- GUT covers menu selection, layout catalog distinction and runtime multi-arena bot context.
- `tools/validate.gd` PASS `20/20`, `175 asserts`.

Delivered before this track:

- Track 01 approved combat readability: bot tell, damage intake, Plasma hit/overcharge, pickups and jump pad cues.
- Track 02 approved bot tactical movement: arena tactical context, route scoring, anti-repeat, objective routing and conservative pressure tuning.

Non-goals:

- No new weapon.
- No raw aimbot difficulty spike.
- No export, Web/mobile, multiplayer or backend.
- No final art pass.
- No broad refactor outside arena layout/context boundaries.

## Active Track

`Track 04 - Arena Movement Flow And Bot Navigation V1` is active.

Human smoke from Track 03 accepted the improved bot aim direction, but rejected the movement feel:

- the bot appears to treat map geometry like jump pad routes;
- the bot can get stuck against ceilings and walls;
- `Relay Foundry V1` jump pads are too close to high platforms;
- platform placement does not support a good movement rhythm.

Goals:

- Rebuild arena layouts around continuous player movement.
- Make jump pads readable connectors with clear approach and landing space.
- Keep high platforms useful without making them collision traps.
- Make bot movement route-based instead of destination-only.
- Add validation for movement clearance and staged vertical routing.

Delivered before this track:

- Track 01 approved combat readability.
- Track 02 approved bot tactical movement in the accepted baseline.
- Track 03 delivered multi-arena catalog and selection, but exposed movement-flow failures in smoke.

Non-goals:

- No new weapon.
- No raw aim/damage tuning spike.
- No export, Web/mobile, multiplayer or backend.
- No final art pass.

## Recommended Next Track After Track 04 Smoke

Choose between:

- human playtest-driven combat number tuning after movement is accepted;
- projectile/weapon experiment;
- export-readiness pass for the FPS lab.

## Out Of Scope

- Football minigames.
- TPS camera/avatar football work.
- Multiplayer/backend/export unless explicitly planned.
