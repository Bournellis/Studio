# FpsPlayground Work Plan

- Status: `FPS_PLAYGROUND_TRACK01_COMBAT_READABILITY_POLISH_READY_FOR_HUMAN_SMOKE`
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

`Track 01 - Combat Readability Polish V1` is ready for human smoke after automated validation.

Goals:

- Improve player rifle hit confirmation and impact readability.
- Improve player damage intake readability.
- Improve Plasma Bolt trajectory, impact and overcharge distinction.
- Improve bot shot tell readability.
- Improve pickup and jump pad readability only where it supports combat decisions.

Delivered:

- HUD event colors and messages for bot tell, damage intake, Plasma hit and overcharge hit.
- Pickup halos/beacons and jump pad launch direction cues.
- Focused tests for scene readability nodes and HUD event contracts.

Non-goals:

- No new weapon.
- No new map/layout.
- No broad damage/health/speed retuning.
- No export, Web/mobile, multiplayer or backend.
- No football/TPS scope.

## Recommended Next Track After Track 01

Choose between:

- deeper FPS bot/combat tuning;
- new arena map/layout;
- projectile/weapon experiment;
- export-readiness pass for the FPS lab.

## Out Of Scope

- Football minigames.
- TPS camera/avatar football work.
- Multiplayer/backend/export unless explicitly planned.
