# FpsPlayground Work Plan

- Status: `FPS_PLAYGROUND_TRACK03_ARENA_TACTICAL_CONTEXT_PROOF_IN_PROGRESS`
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

## Active Track

`Track 03 - Arena Tactical Context Proof V1` is in execution.

Goals:

- Prove that bot tactical movement is arena-agnostic in playable content, not only in unit tests.
- Move layout-specific data into a catalog/provider that can describe multiple arenas.
- Keep `Duel Pit V2` as the default known-good baseline.
- Add `Relay Foundry V1`, a second arena with different footprint, route graph, high ground, pickups and jump pad flow.
- Let the main menu launch either arena.
- Add automated coverage that checks both arenas publish tactical points, roles and route labels to the bot.

Delivered before this track:

- Track 01 approved combat readability: bot tell, damage intake, Plasma hit/overcharge, pickups and jump pad cues.
- Track 02 approved bot tactical movement: arena tactical context, route scoring, anti-repeat, objective routing and conservative pressure tuning.

Non-goals:

- No new weapon.
- No raw aimbot difficulty spike.
- No export, Web/mobile, multiplayer or backend.
- No final art pass.
- No broad refactor outside arena layout/context boundaries.

## Recommended Next Track After Track 03 Smoke

Choose between:

- human playtest-driven combat number tuning;
- projectile/weapon experiment;
- export-readiness pass for the FPS lab.

## Out Of Scope

- Football minigames.
- TPS camera/avatar football work.
- Multiplayer/backend/export unless explicitly planned.
