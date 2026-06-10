# JogoDaCopa Work Plan

- Status: `JOGO_DA_COPA_TRACK_02_QUALITY_UPGRADE_V1_COMPLETE`
- Product/module name: `Copa Arena Futebol`
- Current surface: TPS football minigames.

## North Star

Grow `JogoDaCopa` as a festive football minigame collection. The first playable module is `Copa Arena Futebol`, a fast third-person 1x1 football duel against a bot.

## Complete Baseline

- Project split from `FpsShooter` into `JogoDaCopa`.
- Menu launches only the football module.
- Football mode preserves the accepted third-person camera, visible avatar, country-inspired kits and bot approach baseline.
- Track 01A re-centered the feel around a closed arcade arena: larger field/goals, glass walls, roof collision, bouncy loose ball, tighter kick assist and player boost/stamina.
- Track 01B tuned the active arena feel: more ground grip while preserving air speed, higher bounce, 20% narrower and 50% taller goals, slightly stronger LMB kick and a clearer lifted RMB shot.
- Track 01C reworked the arena presentation: roofed/closed goal boxes, height-aware goal scoring, readable glass frames, field markings, stadium seating, country-inspired banners, scoreboards and light rigs.
- Track 02 Quality Upgrade V1 completed the visual/game-feel/product pass: render lighting, shader pitch/arena, authored CC0 ball/avatar assets, VFX/game feel, HUD/menu polish, bot/match-flow upgrade and product identity/export smoke.
- Validation targets football resources and tests only.
- FPS arena/shooter scope moved to `../FpsPlayground`.

## Recommended Next Track

Human playtest and tuning pass for `Copa Arena Futebol`.

Focus:

- Launch the Windows debug export and editor scene.
- Verify menu -> match -> result -> rematch flow.
- Check readability of glass arena, roofed goals, height-aware scoring and stadium lighting.
- Compare ball ground grip versus air speed, LMB/RMB shot readability and boost stamina/VFX.
- Test bot `easy`/`normal`/`hard`, prediction, defense and alternating kickoff.
- Record any tuning deltas before selecting the next implementation track.

## Out Of Scope

- FPS arena/shooter mechanics.
- Weapons.
- Multiplayer/backend/Web/mobile.
- Official FIFA, World Cup, federation or club branding.
