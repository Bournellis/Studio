# JogoDaCopa - Current Status

- Last updated: `2026-06-10`
- Project: `JogoDaCopa`
- Product/module name: `Copa Arena Futebol`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first TPS football minigames`
- Active stage: `Track 02 - Quality Upgrade Series V1 (02A-02G)`
- Active stage status: `COMPLETE`
- Status marker: `JOGO_DA_COPA_TRACK_02_QUALITY_UPGRADE_V1_COMPLETE`
- Approved plan: `docs/quality-upgrade-plan.md` (2026-06-10, hybrid visual path; authored-asset track 02C explicitly approved)
- Completed Kanban card: `../../08_Coordenacao_Agentes/Kanban/Done/2026-06-10_codex_jogodacopa_track02-quality-upgrade-series-v1.md`
- Studio focus: `TEMPORARY_SOLE_ACTIVE_PROJECT`

## Current Truth

`JogoDaCopa` is the football/TPS project split from the former `Projetos/FpsShooter` workspace. It owns the independent Copa-inspired football minigame direction. The first playable product surface is now named `Copa Arena Futebol`.

The Arena Shooter work moved to `Projetos/FpsPlayground`.

## Current Scope

- PC Windows editor-first.
- Main menu launches `Copa Arena Futebol` / `Futebol 1x1`.
- Third-person 1x1 football against a bot.
- Match to 3 goals.
- Hybrid Track 02 presentation: procedural night stadium/arena/VFX plus in-repo authored CC0 ball/avatar/branding assets.
- Night `WorldEnvironment` with ACES tonemap, glow, SSAO, fog, procedural sky and stadium spot/key lights.
- Shader pitch with field markings, grid nets, animated crowd bands, country-inspired banners and live stadium scoreboards.
- Closed glass arena with larger field, roof collision, framed glass walls, roofed goals and height-aware goal scoring.
- Loose arcade `RigidBody3D` ball with football-panel shader, trail, squash on kick, higher bounce and extra ground-roll grip.
- Visible third-person humanoid avatars preserving `apply_appearance`, `set_move_state`, `play_kick` and `play_celebrate`.
- Skin tone and country-inspired shirt selection.
- Kickoff countdown, input lock, goal slow-mo, camera shake, boost FOV, kick/goal/boost/skid particles and synthetic in-engine feedback.
- Broadcast-style HUD, offscreen ball indicator, result/rematch panel and polished 3D menu with avatar preview.
- Football bot with prediction, positioned defense, boost, `easy`/`normal`/`hard` presets and alternating kickoff.
- Windows export preset `Windows Desktop`; debug export smoke passed to `builds/windows/CopaArenaFutebol.exe`.
- No FPS arena, no weapons, no Web/mobile, no multiplayer/backend.

## Current Gate

Ready for human playtest focused on `Copa Arena Futebol`: menu-to-match presentation, roofed goal closure, no high-shot ghost goals, glass arena readability, night stadium atmosphere, ball ground grip versus air speed, LMB/RMB shot readability, boost stamina/VFX, bot difficulty/positioning, kickoff alternation, result/rematch flow and Windows debug export launch.

This project remains the studio's temporary sole active implementation focus. Other active projects are paused for a few days unless the user explicitly resumes them.

## Validation

Primary command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Latest result: PASS, 28 tests, 279 asserts.

Export smoke command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-debug "Windows Desktop" "builds/windows/CopaArenaFutebol.exe"
```

Latest result: PASS, exit code `0`.

Manual smoke lives in `docs/validation.md`.

## Read Next

1. `AGENTS.md`
2. `docs/quality-upgrade-plan.md`
3. `docs/publication-readiness.md`
4. `docs/documentation-index.md`
5. `docs/architecture-overview.md`
6. `docs/work-plan.md`
7. `docs/mode-contract.md`
8. `docs/validation.md`
9. `implementation/tracks/track-02g-product-identity-v1/current-status.md`
10. `implementation/tracks/track-02f-bot-match-flow-v1/current-status.md`
11. `implementation/tracks/track-02e-hud-menu-polish-v1/current-status.md`
