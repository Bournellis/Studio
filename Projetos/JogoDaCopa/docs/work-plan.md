# JogoDaCopa Work Plan

- Status: `JOGO_DA_COPA_TRACK09I_KICK_SUPER_CONTROLLER_LOCAL_VALIDATED`
- Product/module name: `Super Campeao`
- Current surface: TPS football minigames.

## North Star

Grow `JogoDaCopa` as a festive football minigame collection. The first playable public module is `Super Campeao`, a fast third-person 1x1 football duel against a bot.

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
- Track 03 Arcade V1 completed the arcade pass: dash/slide/stun/flip, charged kick, SUPER/fireball, boost pads, jump pads, ramps, timer/golden goal/vale-2 and emote/confetti.
- Track 03F Quality Hotfix V1 fixed SUPER whiff consumption, preserved Quaternius PBR textures under kit tint, documented representative perf methodology and added source integrity validation.
- Track 08 Super Campeao UI removed the old Toon experiment from active runtime/UI and rebranded the local game surface to `Super Campeao`; the first publication attempt was rolled back after a first-minute remote hitch.
- Track 08A Ball Glass Hitch Hotfix republished `Super Campeao v1.2.1+6ef3074c`; remote menu, first minute, 5-minute stability and night luma gates passed.
- Track 09A FootballRoot Extraction published `Super Campeao v1.2.1+ff9cb389`; remote gates passed and human retest was accepted by Fabio.
- Track 09B FootballRoot Web Loading Controller V1 extracted the Web loading/warmup flow into `football_web_loading_controller.gd`; local validate, Web export and Web boot smoke passed.
- Track 09C FootballRoot Runtime Spawner V1 extracted runtime node creation/wiring into `football_runtime_spawner.gd`; local validate, Web export and Web boot smoke passed.
- Track 09D Football Match Flow Controller V1 extracted kickoff/reset/countdown/input lock flow into `football_match_flow_controller.gd`; local validate, Web export and Web boot smoke passed.
- Track 09E Football Match Presentation Controller V1 extracted HUD/result presentation snapshots into `football_match_presentation_controller.gd`; local validate, Web export and Web boot smoke passed.
- Track 09F Football Arcade Field Controller V1 extracted boost pad and jump pad field orchestration into `football_arcade_field_controller.gd`; published `Super Campeao v1.2.1+a75cfe57` after local validate/export and remote menu, first-minute, stability rerun and night luma gates passed; human retest was approved by Fabio.
- Track 09G Football Match Resolution Controller V1 extracted match restart, goal reset, goal detection side effects, scoring orchestration, timer/golden goal, match finish and shot/goal stats into `football_match_resolution_controller.gd`; local validate, Web export, gzip gate and Web boot smoke passed; publication attempt passed menu and first-minute gates but failed remote 5-minute stability twice on JS/WASM heap (`+15.42%` and `+15.35%`), then rolled back to 09F.
- Track 09H Web Heap Hotfix V1 removed a per-frame `Dictionary` allocation from the timer clock path in `football_match_resolution_controller.gd`; published `Super Campeao v1.2.1+4a323fab` after local validate/export, remote menu, first-minute, 5-minute stability and night luma gates passed.
- Track 09I Kick Super Controller V1 extracted player kick requests, charged/strong kick routing, SUPER spend/gain helpers and bot kick routing into `football_kick_super_controller.gd`; `FootballRoot` in the current base fell from `995` to `943` lines; local validate, Web export, gzip gate and Web boot smoke passed.
- Validation targets football resources and tests only.
- FPS arena/shooter scope moved to `../FpsPlayground`.

## Recommended Next Step

Publish Track 09I only if the public build should receive this internal reduction now; otherwise continue with Track 09J as another local-only reduction. The current public baseline remains `Super Campeao v1.2.1+4a323fab`; Track 09I is local-validated and has no intended gameplay/UX delta.

Focus:

- Prefer orchestration slices that do not alter gameplay, physics, input, bot decisions or assets.
- Preserve existing GUT coverage and add/retarget focused tests when moving public helper contracts.
- Keep Web validation in the loop: `tools/validate.gd`, Web export, gzip gate, local Web boot smoke for loading-sensitive changes and remote 5-minute stability before publication.

## Completed Track 09G - Football Match Resolution Controller V1

- Extracted goal detection orchestration, goal registration side effects, match timer/golden goal transitions, match finish and restart state reset from `football_root.gd` into `modes/football/football_match_resolution_controller.gd`.
- Keep `gameplay/football/football_match_rules.gd` as the pure rules owner for score math, goal detection and timer resolution.
- Keep `football_match_presentation_controller.gd` as the HUD/result snapshot owner.
- Keep `football_match_flow_controller.gd` as the kickoff/countdown/input-lock/reset-position owner.
- Keep `FootballRoot` as the compatibility facade for debug/test APIs and existing internal call sites.
- Measured reduction: `FootballRoot` `1295 -> 1178` lines; no gameplay or public UX delta intended.

## Completed Track 09H - Web Heap Hotfix V1

- Paused further `FootballRoot` reduction to investigate the 09G remote heap failure.
- Removed the per-frame timer-state `Dictionary` allocation from `FootballMatchResolutionController.update_match_clock()`.
- Kept the same timer behavior: time remaining returns early, tie activates `golden_goal`, non-tie ends the match with `player_score > bot_score`.
- `FootballRoot` stayed at `1178` lines; `football_match_resolution_controller.gd` changed from `174` to `168` lines.
- Local gates passed, including Chrome 5min stability with heap final `+6.81%` under the `10%` limit.
- Published as `Super Campeao v1.2.1+4a323fab` / `web/v1-copa-arena-futebol-20260615-4a323fab`.
- Remote menu, first-minute, stability 5min, luma and human retest gates passed.

## Completed Track 09I - Kick Super Controller V1

- Extracted player LMB kick, charged kick, RMB strong/SUPER routing, bot kick request handling and SUPER meter helpers from `football_root.gd` into `modes/football/football_kick_super_controller.gd`.
- Kept `FootballRoot` wrappers for player/bot signal compatibility and Web warmup call sites.
- Left loose-ball contact, dash/body contact, ball collision audio and `_physics_process` ordering in `FootballRoot` for a later bounded reduction.
- Measured reduction in the current base: `FootballRoot` `995 -> 943` lines; new controller `76` lines.
- Local gates passed: import headless, `tools/validate.gd`, Web export, gzip `30.60 MiB / 50.00 MiB`, Chrome local boot with `firstMinuteHitches=0`, `pageErrors=0` and `consoleErrorCount=0`.

## Out Of Scope

- FPS arena/shooter mechanics.
- Weapons.
- Multiplayer, backend, official mobile browser support or new platform expansion beyond the current PC/Web surface.
- Official FIFA, World Cup, federation or club branding.
