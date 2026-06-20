# JogoDaCopa Work Plan

- Status: `JOGO_DA_COPA_TRACK09S_HUMAN_APPROVED`
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
- Track 09I Kick Super Controller V1 extracted player kick requests, charged/strong kick routing, SUPER spend/gain helpers and bot kick routing into `football_kick_super_controller.gd`; `FootballRoot` in the current base fell from `995` to `943` lines; published `Super Campeao v1.2.1+7995b06c` after local validate/export, remote menu, first-minute, stability and night luma gates passed; human retest was approved by Fabio before Track 09J.
- Track 09J Ball Contact Controller V1 extracted player ball-control state, passive player-ball contact, ball collision audio and arcade dash/body contact into `football_ball_contact_controller.gd`; `FootballRoot` in that local candidate fell from `943` to `832` lines; local gates passed, but publication failed the remote 5-minute heap gate twice and production was restored to 09I.
- Track 09K Web Heap Hotfix V1 kept the hot contact path in `FootballRoot`, improved the signal locally but still failed the remote stability heap gate; production was restored to 09I.
- Track 09L Web Heap Instrumentation V1 showed the Chrome gate is measuring exposed JS heap in available runs because `wasmHeapBytes` has no samples.
- Track 09M Web Heap Gate Semantics V1 renamed the primary gate to `js_heap_growth` while preserving the legacy `js_wasm_heap_growth` alias; production remained 09I.
- Track 09N Render Settings Controller V1 extracted render/settings orchestration into `football_render_settings_controller.gd`; `FootballRoot` in the current approved public base fell from `1079` to `1051` lines; local validate/export/gzip/Web probe, pre-publication A/B, remote menu, first-minute, stability, luma and human retest gates passed.
- Track 09O Documentation Rebaseline V1 cleaned the documentation map after 09N so living docs, historical plans and raw evidence no longer compete as sources of next-step truth.
- Track 09P Football Session UI Controller V1 extracted intro/pause/menu session flow, ESC target routing, match start, main-menu return and mouse-capture policy into `football_session_ui_controller.gd`; `FootballRoot` fell from `1051` to `974` lines; local import, validate/export/gzip, 90s Chrome Web smoke, remote menu, remote first-minute, remote 5-minute stability, remote luma and human retest gates passed. It is published and approved as `Super Campeao v1.2.1+8863c5b9`; 09N remains the historical approved fallback.
- Track 09Q Football Presentation FX Controller V1 extracted presentation-only arcade emote, boost/skid VFX, goal slow-mo/camera shake, appearance cycling and avatar movement-state updates into `football_presentation_fx_controller.gd`; `FootballRoot` fell from `974` to `919` lines; local import, validate/export/gzip, 90s Chrome Web smoke, Cloudflare publication, remote menu, remote first-minute, remote 5-minute stability, remote luma and human retest gates passed. It is public and approved as `Super Campeao v1.2.1+bb604c77`; 09P remains the latest fallback behind 09Q.
- Track 09R Foot And Camera Hotfix V1 paused reductions to fix two playtest findings: visible avatar feet intersecting the field plane and odd camera pull/tilt during lateral A/D strafe. It lifts only the visible avatar parts by `0.05m` and dampens ball focus during strafe while keeping the camera horizon level; no gameplay collision, physics, scoring, bot, SUPER, HUD, assets or tuning changes. Local red/green tests, validate/export/gzip, `node --check`, 90s Chrome Web smoke, Cloudflare publication, remote menu, remote first-minute, remote 5-minute stability and remote luma gates passed. It was public as `Super Campeao v1.2.1+33ba1a2b`, but was superseded by 09S before human approval because of the residual quick `A/D` camera perception issue.
- Track 09S Camera Strafe Smoothing Hotfix V1 fixes the residual chase-camera tremor/pull reported during quick `A/D` taps by easing the visual ball-focus weight and focus point in `football_chase_camera.gd`; gameplay, physics, movement, bot, ball, scoring, SUPER, HUD, assets and tuning remain unchanged. The focused red/green test, import headless, `tools/validate.gd`, Web export, `node --check`, Chrome local 90s Web smoke, `git diff --check`, doc drift, Cloudflare publication, remote menu, remote first-minute, remote 5-minute stability, remote luma and Fabio/tester human retest gates passed. It is public and approved as `Super Campeao v1.2.1+925f3b9f`.
- Validation targets football resources and tests only.
- FPS arena/shooter scope moved to `../FpsPlayground`.

## Recommended Next Step

Track 09S is the current human-approved public Web baseline at `Super Campeao v1.2.1+925f3b9f`. Track 09R is superseded before human approval. Track 09Q is the latest approved fallback at `Super Campeao v1.2.1+bb604c77`. Track 09P remains the fallback behind 09Q at `Super Campeao v1.2.1+8863c5b9`; Track 09N remains the historical approved fallback baseline behind 09P.

Focus:

- Define the next conservative `FootballRoot` reduction or re-evaluate technical scope before opening a new track.
- Keep 09Q as the latest approved fallback behind 09S, with 09P and 09N as older approved fallbacks.
- Prefer orchestration slices that do not alter gameplay, physics, input, bot decisions or assets.
- Preserve existing GUT coverage and add/retarget focused tests when moving public helper contracts.
- Keep Web validation in the loop: `tools/validate.gd`, Web export, gzip gate, local Web boot smoke for loading-sensitive changes, remote 5-minute stability before publication and human retest after publication.

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
- Published as `Super Campeao v1.2.1+7995b06c` / `web/v1-copa-arena-futebol-20260616-7995b06c`.
- Remote menu, first-minute, stability 5min and luma gates passed.
- Human retest of the public 09I build was approved by Fabio before Track 09J.

## Completed Track 09J - Ball Contact Controller V1

- Extracted player ball-control state, passive player-ball contact, ball collision audio and arcade dash/body contact from `football_root.gd` into `modes/football/football_ball_contact_controller.gd`.
- Kept `FootballRoot` wrappers for compatibility with existing tests, signals and call sites.
- Preserved existing ordering in `_physics_process`: cooldowns, player control state, player contact, kick handling, arcade field, arcade action contacts and match-resolution update.
- Measured reduction in the current base: `FootballRoot` `943 -> 832` lines; new controller `125` lines.
- Local gates passed: import headless, `tools/validate.gd`, Web export, gzip `30.60 MiB / 50.00 MiB`, Chrome local boot with `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0` and `firstMinuteHitches=0`.
- Publication was attempted later as `v1.2.1+4678fbea`, but the remote 5-minute heap gate failed twice and production was restored to 09I.

## Completed Track 09K - Web Heap Hotfix V1

- Removed avoidable `Dictionary` allocations from less frequent ball-contact paths while keeping the hot contact path in `FootballRoot`.
- Preserved gameplay, input, bot, physics, scoring, HUD, tuning and assets.
- Local gates passed and local 5-minute comparison improved slightly, but the remote 5-minute heap gate still failed.
- Production was restored to the approved 09I baseline.

## Completed Track 09L - Web Heap Instrumentation V1

- Added heap debug summary output and final-GC/component/window diagnostics to the Chrome probe.
- Confirmed available Chrome runs expose JS heap samples but not real WASM heap samples.
- No publication and no gameplay/runtime change.

## Completed Track 09M - Web Heap Gate Semantics V1

- Renamed the primary stability metric to `js_heap_growth`.
- Preserved `js_wasm_heap_growth` as a legacy alias for old evidence compatibility.
- Confirmed remote 09I still passed under the renamed metric.

## Completed Track 09N - Render Settings Controller V1

- Extracted main-menu settings bridge, `GameSettings` quality integration, runtime render profile refresh, scoreboard viewport resize and pause-menu sensitivity sync into `modes/football/football_render_settings_controller.gd`.
- Measured reduction in the approved public base: `FootballRoot` `1079 -> 1051` lines.
- Local validation, Web export, gzip, local Web probe and pre-publication A/B passed.
- Published as `Super Campeao v1.2.1+5c6520ba`; remote menu, first-minute, stability 5min, luma and human retest gates passed.
- 09N is the historical approved fallback baseline behind 09P.

## Completed Track 09O - Documentation Rebaseline V1

- Rebased the documentation map after 09N approval.
- Marked old plans as historical, refreshed this work plan, compacted the status snapshot and updated bot/tuning contracts.
- No code, export, package or publication change.

## Completed Track 09P - Football Session UI Controller V1

- Extracted session/UI orchestration from `football_root.gd` into `modes/football/football_session_ui_controller.gd`.
- Moved `_input`, `_get_escape_target`, `_start_match`, `_set_intro_open`, `_set_menu_open`, `_return_to_main_menu`, `_return_to_main_menu_async` and `_capture_mouse_if_playing` bodies behind `FootballRoot` wrappers.
- Preserved gameplay, physics, bot, ball, kick/SUPER, scoring, HUD visual, assets and tuning.
- Measured reduction in the local candidate: `FootballRoot` `1051 -> 974` lines; new controller `119` lines.
- Local gates passed: import headless, `tools/validate.gd`, Web export, gzip `30.60 MiB / 50.00 MiB`, Chrome local 90s Web smoke with `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0` and `js_heap_growth -1.26%`.
- Published as `Super Campeao v1.2.1+8863c5b9`; remote menu, first-minute, stability 5min, luma and human retest gates passed.
- Human retest was approved by Fabio/tester on 2026-06-19; 09P remains an approved fallback and 09N remains the historical approved fallback behind it.

## Completed Track 09Q - Football Presentation FX Controller V1

- Extracted presentation-only arcade emote, boost/skid VFX, goal slow-mo/camera shake, appearance cycling and avatar movement-state updates into `modes/football/football_presentation_fx_controller.gd`.
- Preserved gameplay, physics, bot, ball contact, kick/SUPER, scoring, HUD visual, assets, tuning, Web loading and `_physics_process` ordering.
- Measured reduction in the local candidate: `FootballRoot` `974 -> 919` lines; new controller `98` lines.
- Local gates passed: import headless, `tools/validate.gd`, Web export, gzip `30.61 MiB / 50.00 MiB`, `node --check tools/track04f_chrome_probe.mjs`, Chrome local 90s Web smoke with `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0` and `js_heap_growth -10.20%`.
- Published as `Super Campeao v1.2.1+bb604c77`; remote menu, first-minute, stability 5min and luma gates passed.
- Human retest was approved by Fabio/tester on 2026-06-19; 09Q is the latest human-approved fallback while 09R awaits human retest, and 09P remains the fallback behind 09Q.

## Completed Track 09R - Foot And Camera Hotfix V1

- Paused further `FootballRoot` reduction to fix playtest findings before continuing structural work.
- Fixed visible avatar foot/boot field clipping by lifting only `AvatarParts` with `REAL_MODEL_FIELD_CLEARANCE_OFFSET = 0.05`; collision, player body and gameplay remain unchanged.
- Fixed lateral A/D camera feel by reducing ball-focus pull when lateral velocity dominates and by rebuilding the chase-camera basis with a level horizon.
- Added focused red/green tests for visible mesh field clearance and lateral strafe camera ball-focus/horizon behavior.
- Local gates passed: import headless, `tools/validate.gd`, Web export, gzip `30.61 MiB / 50.00 MiB`, `node --check tools/track04f_chrome_probe.mjs`, Chrome local 90s Web smoke with `pageErrors=0`, `consoleErrorCount=0` and `stabilityPassed=true`.
- Evidence: `docs/playtest-reports/track-09r-foot-camera-hotfix.md` and `docs/playtest-reports/track-09r-data/`.
- Published as `Super Campeao v1.2.1+33ba1a2b`; remote menu, first-minute, stability 5min and luma gates passed.
- Human retest is pending; 09Q remains the latest human-approved fallback baseline.

## Completed Track 09S - Camera Strafe Smoothing Hotfix V1

- Paused further `FootballRoot` reduction to fix the residual quick `A/D` chase-camera perception issue reported after 09R.
- Smoothed the chase-camera ball-focus weight and final focus point so short lateral taps do not snap the look-at target.
- Preserved `snap_to_target()` setup/reset behavior and goal-focus punch.
- Preserved gameplay, physics, player movement, bot, ball, scoring, SUPER, HUD, assets and match tuning.
- Added focused red/green coverage for quick lateral tap focus shift.
- Local gates passed: import headless, `tools/validate.gd` (`107/107`, `1835` asserts), Web export, `node --check tools/track04f_chrome_probe.mjs`, Chrome local 90s Web smoke with `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0` and `stabilityPassed=true`, `git diff --check` and doc drift.
- Published as `Super Campeao v1.2.1+925f3b9f`; remote menu, first-minute, stability 5min and luma gates passed.
- Evidence: `docs/playtest-reports/track-09s-camera-strafe-smoothing-hotfix.md` and `docs/playtest-reports/track-09s-data/`.
- Human retest approved by Fabio/tester on 2026-06-20; 09S is the current approved public baseline and 09Q remains the latest approved fallback.

## Out Of Scope

- FPS arena/shooter mechanics.
- Weapons.
- Multiplayer, backend, official mobile browser support or new platform expansion beyond the current PC/Web surface.
- Official FIFA, World Cup, federation or club branding.
