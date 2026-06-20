# JogoDaCopa - Current Status

- Last updated: `2026-06-19`
- Project: `JogoDaCopa`
- Product/module name: `Super Campeao`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first TPS football minigames + public Cloudflare Pages Web`
- Public baseline: `Super Campeao v1.2.1+8863c5b9`
- Active stage status: `PUBLISHED_APPROVED - Track 09P public baseline approved`
- Status marker: `JOGO_DA_COPA_TRACK09P_PUBLISHED_APPROVED`
- Documentation baseline: `Track 09P Session UI Controller V1`

## Current Truth

`JogoDaCopa` is the football/TPS project split from the former `Projetos/FpsShooter` workspace. It owns the independent football minigame direction. The first playable public product surface is `Super Campeao`, published on Cloudflare Pages as `v1.2.1+8863c5b9`.

Track 09P is the current approved public baseline. It extracted session/UI orchestration into `football_session_ui_controller.gd`, reduced `FootballRoot` from `1051` to `974` lines, passed local import, validate/export/gzip, 90s Chrome Web smoke, remote menu, remote first-minute, remote 5-minute stability, remote luma gates and Fabio/tester human retest on 2026-06-19.

Track 09N remains the historical approved fallback baseline behind 09P. It extracted render/settings orchestration into `football_render_settings_controller.gd`, reduced `FootballRoot` from `1079` to `1051` lines, passed local validation, passed pre-publication A/B, passed remote menu/first-minute/stability/luma gates and passed human retest.

Tracks 09J and 09K are not approved public baselines because their 2026-06-19 publication attempts failed the remote heap gate; production was restored to 09I before 09L/09M diagnostics. Track 09L/09M clarified that the active Chrome stability metric is exposed JS heap, now named `js_heap_growth`.

The Arena Shooter work moved to `Projetos/FpsPlayground`.

## Current Scope

- PC Windows editor-first plus Web export/publication gate.
- Main menu launches public `Super Campeao`.
- Third-person 1x1 football against a bot.
- Default match mode is `3 minutos`; `3 gols` mode remains selectable.
- Closed glass arena with larger field, roof collision, framed glass walls, roofed goals and height-aware goal scoring.
- Loose arcade `RigidBody3D` ball with football-panel shader, hysteresis trail, squash on kick, higher bounce and extra ground-roll grip.
- Visible third-person real skinned humanoid avatars, player male and bot female, with UAL animation clips plus authored kick animation.
- Skin tone and country-inspired shirt selection.
- Kickoff countdown, input lock, goal slow-mo, camera shake, boost FOV, transient kick/goal bursts, persistent boost/skid particles, real SFX/jingles/crowd ambience and synthetic referee whistle only.
- Broadcast-style HUD, offscreen ball indicator, result/rematch panel and polished 3D menu with avatar preview.
- Football bot with prediction, positioned defense, boost, main-menu selectable `easy`/`normal`/`hard` presets and alternating kickoff.
- Arcade mechanics adopted locally: dash/slide/stun/flip, charged kick, SUPER shot/fireball, boost pads, jump pads, timer/golden goal/vale-2 and emote.
- No FPS arena, no weapons, no mobile, no multiplayer/backend.

## Current Architecture

- `modes/football/football_root.gd`: facade/orchestrator for lifecycle, compatibility wrappers, debug/test APIs and gameplay loop ordering.
- `football_world_environment.gd`: night world environment and stadium key light construction.
- `football_capture_director.gd`: capture-scene meta handling and evidence camera setup.
- `football_scoreboard_controller.gd`: stadium scoreboard label/viewport cache and update cadence.
- `football_perf_scenario.gd`: perf probe scenario steps, feedback filtering and stability sample extras.
- `football_web_loading_controller.gd`: Web loading overlay, first-render warmup, first-use feedback warmup and loading settle probes.
- `football_runtime_spawner.gd`: runtime node construction and signal wiring.
- `football_match_flow_controller.gd`: kickoff/reset/countdown/input lock/touch kickoff.
- `football_match_presentation_controller.gd`: HUD/result snapshots, HUD/scoreboard refresh and result statistics text.
- `football_arcade_field_controller.gd`: boost pad and jump pad node collection/reset/cooldown/respawn.
- `football_match_resolution_controller.gd`: restart state, goal reset timer, goal detection side effects, scoring, timer/golden goal, match finish and stats.
- `football_kick_super_controller.gd`: player kick requests, charged/strong kick routing, SUPER spend/gain rules and bot kick routing.
- `football_render_settings_controller.gd`: main-menu settings bridge, `GameSettings` quality integration, runtime render-profile refresh, scoreboard viewport resize and pause-menu sensitivity sync.
- `football_session_ui_controller.gd`: intro/pause/menu session flow, ESC target routing, match start, main-menu return and mouse-capture policy.

## Current Gate

`Super Campeao v1.2.1+8863c5b9` is public at `https://copa-arena-futebol.pages.dev/` with release root `web/v1-copa-arena-futebol-20260619-8863c5b9`.

Latest publication:

- Local validation: `tools/validate.gd` PASS, `104/104` tests, `1826` asserts, `59` source files checked.
- Web package/export: PASS.
- Web gzip transfer: `30.60 MiB / 50.00 MiB`.
- Remote menu: PASS.
- Remote first minute: PASS, `firstMinuteHitches=0`.
- Remote stability 5min: PASS, `js_heap_growth +2.15%`, peak `+7.18%`, `wasmSampleCount=0`.
- Remote night luma: PASS, `6.525 < 90`.
- Human retest: approved by Fabio/tester on 2026-06-19.

Track 09N remains the historical approved fallback baseline behind 09P. Track 09I remains the historical approved fallback behind 09N.

## Validation

Primary command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Export smoke command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-debug "Windows Desktop" "builds/windows/CopaArenaFutebol.exe"
```

Docs-only validation:

```powershell
D:\Estudio\tools\check_doc_drift.ps1
git diff --check
```

Latest code and publication validation is the Track 09P gate listed above. Track 09O was documentation-only and did not change code, scenes, assets, export or publication.

## Documentation Map

- Start here: `docs/documentation-index.md`.
- Living technical plan: `docs/work-plan.md`.
- Current publication package: `docs/publication-readiness.md`.
- Release history: `docs/release-history.md`.
- Architecture: `docs/architecture-overview.md`.
- Contracts: `docs/mode-contract.md`, `docs/bot-contract.md`, `docs/tuning-guide.md`.
- Validation guide: `docs/validation.md`, `docs/validation-profiles.md`.
- Evidence reports and raw JSON/PNG: `docs/playtest-reports/`.

## Next Step

Plan the next conservative `FootballRoot` reduction or re-evaluate the architecture before opening another slice. Keep any next slice conservative: no gameplay, physics, input, bot decision, HUD visual, asset or tuning change unless Fabio explicitly opens a tuning/design track.
