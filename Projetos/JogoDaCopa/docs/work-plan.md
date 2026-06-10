# JogoDaCopa Work Plan

- Status: `JOGO_DA_COPA_TRACK_01C_ARENA_STADIUM_VISUAL_REWORK_COMPLETE`
- Current surface: TPS football minigames.

## North Star

Grow `JogoDaCopa` as a festive football minigame collection. The first playable module is a fast third-person 1x1 football duel against a bot.

## Complete Baseline

- Project split from `FpsShooter` into `JogoDaCopa`.
- Menu launches only `Futebol 1x1`.
- Football mode preserves the accepted third-person camera, visible avatar, country-inspired kits and bot approach baseline.
- Track 01A re-centered the feel around a closed arcade arena: larger field/goals, glass walls, roof collision, bouncy loose ball, tighter kick assist and player boost/stamina.
- Track 01B tuned the active arena feel: more ground grip while preserving air speed, higher bounce, 20% narrower and 50% taller goals, slightly stronger LMB kick and a clearer lifted RMB shot.
- Track 01C reworked the arena presentation: roofed/closed goal boxes, height-aware goal scoring, readable glass frames, field markings, stadium seating, country-inspired banners, scoreboards and light rigs.
- Validation now targets football resources and tests only.
- FPS arena/shooter scope moved to `../FpsPlayground`.

## Recommended Next Track

Run editor playtest focused on the visual arena/stadium pass plus the tuned ball/goal/kick feel. Then choose between:

- character/avatar quality upgrade;
- ball/wall/ceiling rebound tuning;
- bot football decision upgrade;
- boost/stamina tuning and player mobility polish;
- additional football minigame shell;
- product/export identity for the first Copa module.

## Out Of Scope

- FPS arena/shooter mechanics.
- Weapons.
- Multiplayer/backend/export unless explicitly planned.
