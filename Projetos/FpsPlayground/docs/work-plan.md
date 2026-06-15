# FpsPlayground Work Plan

- Status: `FPS_PLAYGROUND_TRACK02_BOT_TACTICAL_MOVEMENT_APPROVED`
- Current surface: FPS arena lab.

## North Star

Keep `FpsPlayground` as a clean first-person gameplay laboratory for arena movement, shooting, projectiles, bots, maps and combat feel.

## Complete Baseline

- Project split from `FpsShooter` into `FpsPlayground`.
- Menu launches only `Arena Shooter`.
- Arena Shooter preserves the accepted `Duel Pit V2` baseline.
- Validation now targets FPS resources and arena tests only.
- Football/TPS scope moved to `../JogoDaCopa`.

## Active Track

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

## Recommended Next Track After Track 02 Smoke

Choose between:

- new arena map/layout using the tactical context contract;
- human playtest-driven combat number tuning;
- projectile/weapon experiment;
- export-readiness pass for the FPS lab.

## Out Of Scope

- Football minigames.
- TPS camera/avatar football work.
- Multiplayer/backend/export unless explicitly planned.
