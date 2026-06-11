# JogoDaCopa Work Plan

- Status: `JOGO_DA_COPA_TRACK_03F_QUALITY_HOTFIX_V1_COMPLETE`
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
- Track 02H Quality Hotfix V1 resolved review blockers: selected-kit stadium scoreboards, player-local ball indicator, persistent boost/skid emitters, main-menu bot difficulty, removed decorative avatar rig, ball trail hysteresis and cached scoreboard labels.
- Track 02C-bis/02D-bis Real Assets V1 replaced the avatar proxy with real Quaternius skinned humanoids/UAL animation clips and replaced synthetic feedback with real Kenney/Pixabay SFX, jingles and stadium ambience.
- Track 03 Arcade V1 completed the arcade pass: dash/slide/stun/flip, charged kick, SUPER/fireball, boost pads, jump pads, ramps, timer/golden goal/vale-2, emote/confetti and toon experiment toggle OFF by default.
- Track 03F Quality Hotfix V1 fixed SUPER whiff consumption, preserved Quaternius PBR textures under kit tint, documented representative perf methodology and added source integrity validation.
- Validation targets football resources and tests only.
- FPS arena/shooter scope moved to `../FpsPlayground`.

## Recommended Next Step

Human confirmation playtest for `Copa Arena Futebol` hotfix, then decide the next series with Claude.

Focus:

- Confirm SUPER whiff no longer spends the bar or kickoff quota.
- Confirm avatar tint preserves enough texture/PBR readability in play.
- Playtest dash/slide/flip, charged kick, SUPER/fireball and boost/jump pad readability.
- Check real character readability in player/bot silhouettes, kits, hit/slide/push/kick/celebrate states.
- Check real audio mix for kick/bounce/glass/countdown/goal/crowd/menu, including ambience ducking in intro/pause.
- Decide whether the timer default, golden goal and vale-2 should stay as-is.
- Compare toon screenshots ON/OFF and decide if the experiment remains enabled as an option.

## Out Of Scope

- FPS arena/shooter mechanics.
- Weapons.
- Multiplayer/backend/Web/mobile.
- Official FIFA, World Cup, federation or club branding.
