# FpsPlayground Work Plan

- Status: `FPS_PLAYGROUND_TRACK02_BOT_TACTICAL_MOVEMENT_IN_PROGRESS`
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

`Track 02 - Bot Tactical Movement V1` is active.

Goals:

- Make the bot harder primarily through better movement and route decisions, not raw aimbot tuning.
- Replace one-arena reposition assumptions with an arena-provided tactical context.
- Let arenas declare tactical affordances: pressure, flank, cover, retreat, health, overcharge, high ground and jump pad routes.
- Improve bot route scoring, anti-repeat behavior, stuck recovery and objective pressure.
- Preserve readable shot windup and fair reaction windows.

Delivered before this track:

- Track 01 approved combat readability: bot tell, damage intake, Plasma hit/overcharge, pickups and jump pad cues.

Non-goals:

- No new weapon.
- No new map/layout.
- No export, Web/mobile, multiplayer or backend.
- No football/TPS scope.
- No impossible instant-shot bot behavior.

## Recommended Next Track After Track 02

Choose between:

- human playtest-driven combat number tuning;
- new arena map/layout using the tactical context;
- projectile/weapon experiment;
- export-readiness pass for the FPS lab.

## Out Of Scope

- Football minigames.
- TPS camera/avatar football work.
- Multiplayer/backend/export unless explicitly planned.
