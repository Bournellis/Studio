# JogoDaCopa Work Plan

- Status: `JOGO_DA_COPA_TRACK_03_ARCADE_SERIES_V1_REGISTERED`
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
- Validation targets football resources and tests only.
- FPS arena/shooter scope moved to `../FpsPlayground`.

## Recommended Next Track

Serie Track 03 Arcade V1 for `Copa Arena Futebol`, following `docs/arcade-upgrade-plan.md`.

Focus:

- Implement `03A -> 03C -> 03B -> 03D -> 03E` in one dedicated worktree.
- Preserve Track 02 feel contracts, especially tap LMB/RMB force/lift regressions.
- Keep bot parity in the same track for dash/flip/stun, super/carga and boost-pad collection.
- Route all new ball impulse through `FootballBall3D.kick()` and keep base ball physics untouched.
- Keep `RENDER_TOON_ENABLED` default OFF and generate ON/OFF screenshots for Fabio decision.
- After the series, return to human arcade playtest plus 02C-bis/02D-bis asset decisions.

## Out Of Scope

- FPS arena/shooter mechanics.
- Weapons.
- Multiplayer/backend/Web/mobile.
- Official FIFA, World Cup, federation or club branding.
