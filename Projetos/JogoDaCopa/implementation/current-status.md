# JogoDaCopa - Current Status

- Last updated: `2026-06-20`
- Project: `JogoDaCopa`
- Product/module name: `Super Campeao`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first TPS football minigames + public Cloudflare Pages Web`
- Public deployment: `Super Campeao v1.2.1+39054f31`
- Active stage status: `PUBLISHED_REMOTE_GATES_PASSED_HUMAN_RETEST_PENDING - Track 10C Web Goal Feedback Heap-Safe`
- Status marker: `JOGO_DA_COPA_TRACK10C_PUBLISHED_REMOTE_GATES_PASSED_HUMAN_RETEST_PENDING`
- Documentation baseline: `Track 10C Web Goal Feedback Heap-Safe V1`

## Current Truth

`JogoDaCopa` is the football/TPS project split from the former `Projetos/FpsShooter` workspace. It owns the independent football minigame direction. The first playable public product surface is `Super Campeao`, currently published on Cloudflare Pages as `v1.2.1+39054f31`.

Track 10C is published with remote automated gates passed and human retest pending. It keeps the Web goal visual pulse by using the existing three pooled sphere markers, but removes goal audio from the default Web path. The default Web feedback key is now `goal_visual`; `goal_audio` and the legacy `goal` key remain opt-in query paths only. Local headless import, `tools/validate.gd`, Web export/gzip, `node --check`, 90s Chrome visual-only smoke and 5-minute Chrome stability passed on 2026-06-20. Cloudflare publication also passed remote menu, first-minute, 5-minute stability, night luma and stable URL confirmation gates. The remote 5-minute gate showed `js_heap_growth -0.59%`, peak `+2.31%`, worst 5s FPS `142.2`, `firstMinuteHitches=0`, and `feedback.web_goal_mode visual=true audio=false`.

Track 10B is a blocked publication attempt. It reintroduced default Web goal feedback with a Web-lite path: three pooled visual markers plus the short `goal_jingle` after browser audio activation. The heavy Web `crowd_goal`, particle-burst and dynamic-light goal package remained disabled; the PC/Windows full goal package remained unchanged. Local headless import, `tools/validate.gd`, Web export, `node --check`, 90s Chrome probes with and without audio unlock, and 5-minute Chrome stability passed on 2026-06-20. The 2026-06-20 Cloudflare publication attempt passed remote menu and first-minute gates, but failed the remote 5-minute heap gate with `js_heap_growth +13.85%` against the `<10%` limit. Production was rolled back to Track 10A and the public URL confirmed `web/v1-copa-arena-futebol-20260620-fc3c72bb`.

Track 10A is the latest human-approved fallback baseline behind 10C. It decomposes the football HUD pause menu by moving pause menu construction, tabs, restart confirmation, fullscreen/quality/sensitivity callbacks and pause settings synchronization into `football_hud_pause_menu_controller.gd`. `football_hud.gd` fell from `1512` to `1148` lines. Node paths, existing signals, restart confirmation behavior and real-click pause menu tests are preserved. Local headless import, `tools/validate.gd`, Web export, `node --check`, 90s Chrome Web smoke, `git diff --check`, doc drift, 3-resolution screenshot evidence, Cloudflare publication, remote menu, remote first-minute, remote 5-minute stability, remote luma gates and Fabio/tester human retest passed on 2026-06-20.

Track 09S is the latest human-approved fallback baseline behind 10A. It fixes the residual chase-camera tremor/pull reported during quick `A/D` taps by smoothing the visual ball-focus weight and focus point in `football_chase_camera.gd`. It keeps `snap_to_target()` setup/reset behavior and goal-focus punch, and does not change gameplay collision, physics, scoring, bot, SUPER, HUD, assets or match tuning. The focused red test failed before the fix and passed after it; local import, `tools/validate.gd`, Web export, `node --check`, 90s Chrome Web smoke, `git diff --check`, doc drift, Cloudflare publication, remote menu, remote first-minute, remote 5-minute stability, remote luma gates and Fabio/tester human retest passed.

Track 09R is superseded by 09S before human approval. It fixed visible avatar feet entering the field plane and reduced sustained lateral strafe ball pull, but Fabio/tester reported a remaining quick `A/D` tap camera perception issue. Automated local and remote gates passed for 09R.

Track 09Q is the latest approved fallback baseline behind 09S. It extracted presentation-only arcade emote, boost/skid VFX, goal slow-mo/camera shake, appearance cycling and avatar movement-state updates into `football_presentation_fx_controller.gd`; `FootballRoot` fell from `974` to `919` lines. Local import, `tools/validate.gd`, Web export/gzip, `node --check`, 90s Chrome Web smoke, Cloudflare publication, remote menu, remote first-minute, remote 5-minute stability, remote luma and Fabio/tester human retest gates passed.

Track 09P remains the latest fallback baseline behind 09Q. It extracted session/UI orchestration into `football_session_ui_controller.gd`, reduced `FootballRoot` from `1051` to `974` lines, passed local import, validate/export/gzip, 90s Chrome Web smoke, remote menu, remote first-minute, remote 5-minute stability, remote luma gates and Fabio/tester human retest on 2026-06-19.

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
- Kickoff countdown, input lock, goal slow-mo, camera shake, boost FOV, transient kick/goal feedback, persistent boost/skid particles, real SFX/jingles/crowd ambience and synthetic referee whistle only. Web uses a lightweight default goal path; PC keeps the full goal package.
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
- `football_presentation_fx_controller.gd`: presentation-only arcade emote, boost/skid VFX, goal slow-mo/camera shake, appearance cycling and avatar movement-state updates.
- `presentation/hud/football_hud_pause_menu_controller.gd`: pause menu construction, tabs, restart confirmation and pause settings synchronization behind the `FootballHud` facade.

## Current Gate

`Super Campeao v1.2.1+39054f31` is public at `https://copa-arena-futebol.pages.dev/` with release root `web/v1-copa-arena-futebol-20260620-39054f31`. Track 10C passed remote automated gates and awaits Fabio/tester human retest. Track 10A remains the latest human-approved fallback; Track 10B was attempted and rolled back on 2026-06-20 after the remote 5-minute heap gate failed.

Latest publication:

- Local validation: `tools/validate.gd` PASS, `108/108` tests, `1840` asserts, `62` source files checked.
- Web package/export: PASS.
- Web package assets: raw `index.pck` `28013492` bytes, raw `index.wasm` `37695054` bytes, packaged Brotli `index.pck` `20838619` bytes and packaged Brotli `index.wasm` `6608968` bytes, each packaged asset below the `26214400` byte Cloudflare Pages asset limit.
- Remote menu: PASS.
- Remote first minute: PASS, `firstMinuteHitches=0`.
- Remote stability 5min: PASS, `js_heap_growth -0.59%`, peak `+2.31%`, `wasmSampleCount=0`, worst 5s FPS window `142.2`.
- Remote night luma: PASS, `6.525 < 90`.
- Stable URL confirmation: PASS, `https://copa-arena-futebol.pages.dev/` served `web/v1-copa-arena-futebol-20260620-39054f31`.
- Human retest: pending for Track 10C. Track 10A remains the latest human-approved fallback baseline.

Track 10B validation and blocked publication:

- Headless editor import: PASS.
- `tools/validate.gd`: PASS, `108/108` tests, `1838` asserts, `62` source files checked.
- Web export/gzip: PASS, `30.62 MiB / 50.00 MiB`.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- Chrome local 90s Web smoke: PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Chrome local 90s Web smoke with audio unlock: PASS, `goal_jingle` loaded in `0.6ms` and played; `crowd_goal` stayed out of the goal path.
- Chrome local 5min stability: PASS, `firstMinuteHitches=0`, active-match goal windows `hitchCount=0`, `js_heap_growth -8.36%`, worst 5s FPS `121`.
- Cloudflare publication attempt: `Super Campeao v1.2.1+317999b0`, release root `web/v1-copa-arena-futebol-20260620-317999b0`, preview `https://35b5b340.copa-arena-futebol.pages.dev`.
- Remote menu: PASS, release root matched, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: FAIL only on `js_heap_growth +13.85%` against the `<10%` gate; peak `+17.71%`, `wasmSampleCount=0`, counters/caches stable, worst 5s FPS `117.2`.
- Rollback: Track 10A redeployed as `web/v1-copa-arena-futebol-20260620-fc3c72bb`, preview `https://f375997e.copa-arena-futebol.pages.dev`; stable URL confirmation PASS.

Track 10C local validation:

- Headless editor import: PASS.
- `tools/validate.gd`: PASS, `108/108` tests, `1840` asserts, `62` source files checked.
- Web export/gzip: PASS, `30.62 MiB / 50.00 MiB`.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- Chrome local 90s Web visual-only smoke: PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Chrome local 5min stability: PASS, `firstMinuteHitches=0`, `js_heap_growth -8.10%`, peak `+1.10%`, worst 5s FPS `137.4`, Godot counters/caches stable.
- Web goal feedback mode observed: `visual=true audio=false`.

Track 10C publication validation:

- Cloudflare publication: `Super Campeao v1.2.1+39054f31`, release root `web/v1-copa-arena-futebol-20260620-39054f31`, preview `https://c50815e2.copa-arena-futebol.pages.dev`.
- Remote menu: PASS, release root matched, `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `event.visible_match_start`, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, `js_heap_growth -0.59%`, peak `+2.31%`, worst 5s FPS `142.2`, Godot counters/caches stable.
- Remote night luma: PASS, `luma_0_255=6.525 < 90`.
- Stable URL confirmation: PASS, `https://copa-arena-futebol.pages.dev/` served `web/v1-copa-arena-futebol-20260620-39054f31`.

Track 09S local validation:

- Headless editor import: PASS.
- Focused red/green test: PASS after fix.
- `tools/validate.gd`: PASS, `107/107` tests, `1835` asserts, `60` source files checked.
- Web export: PASS.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- Chrome local 90s Web smoke: PASS, `pageErrors=0`, `consoleErrorCount=0`, `stabilityPassed=true`, `firstMinuteHitches=0`.
- `git diff --check`: PASS.
- `D:\Estudio\tools\check_doc_drift.ps1`: PASS.

Track 09Q remains the latest approved fallback baseline behind 09S. Track 09P remains the fallback behind 09Q. Track 09N remains the historical approved fallback behind 09P.

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

Latest public deployment is Track 10C: local and remote automated gates passed with Web visual-only goal feedback and no default Web goal audio; Fabio/tester human retest is pending. Latest human-approved fallback is Track 10A. Latest blocked publication attempt is Track 10B: local gates passed, remote menu and first-minute passed, remote 5-minute stability failed on `js_heap_growth +13.85%`, and production was rolled back to Track 10A with confirmation.

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

Fabio/tester should run the human retest on `https://copa-arena-futebol.pages.dev/` for Track 10C. If approved, mark 10C as the approved public baseline; if rejected, decide between rollback to 10A or a focused hotfix.
