# JogoDaCopa - Current Status

- Last updated: `2026-06-10`
- Project: `JogoDaCopa`
- Product/module name: `Copa Arena Futebol`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first TPS football minigames`
- Active stage: `Track 03 - Arcade Series V1`
- Active stage status: `COMPLETE`
- Status marker: `JOGO_DA_COPA_TRACK_03E_TOON_LOOK_EXPERIMENT_V1_COMPLETE`
- Approved plan: `docs/arcade-upgrade-plan.md` (2026-06-10, Track 03 Arcade V1 complete)
- Completed Kanban card: `../../08_Coordenacao_Agentes/Kanban/Done/2026-06-10_codex_jogodacopa_track03-arcade-series-v1.md`
- Studio focus: `TEMPORARY_SOLE_ACTIVE_PROJECT`

## Current Truth

`JogoDaCopa` is the football/TPS project split from the former `Projetos/FpsShooter` workspace. It owns the independent Copa-inspired football minigame direction. The first playable product surface is now named `Copa Arena Futebol`.

The Arena Shooter work moved to `Projetos/FpsPlayground`.

## Current Scope

- PC Windows editor-first.
- Main menu launches `Copa Arena Futebol` / `Futebol 1x1`.
- Third-person 1x1 football against a bot.
- Default match mode is 3-minute timer; `3 gols` mode remains selectable and unchanged.
- Hybrid Track 02 presentation: procedural night stadium/arena/VFX plus in-repo authored CC0 ball/branding assets and procedural avatar proxy.
- Night `WorldEnvironment` with ACES tonemap, glow, SSAO, fog, procedural sky and stadium spot/key lights.
- Shader pitch with field markings, grid nets, animated crowd bands, country-inspired banners and live stadium scoreboards.
- Closed glass arena with larger field, roof collision, framed glass walls, roofed goals and height-aware goal scoring.
- Loose arcade `RigidBody3D` ball with football-panel shader, hysteresis trail, squash on kick, higher bounce and extra ground-roll grip.
- Visible third-person humanoid procedural avatars preserving `apply_appearance`, `set_move_state`, `play_kick` and `play_celebrate`; decorative unskinned rig removed until 02C-bis real asset integration.
- Skin tone and country-inspired shirt selection.
- Kickoff countdown, input lock, goal slow-mo, camera shake, boost FOV, transient kick/goal bursts, persistent boost/skid particles and synthetic in-engine feedback.
- Broadcast-style HUD, offscreen ball indicator, result/rematch panel and polished 3D menu with avatar preview.
- Football bot with prediction, positioned defense, boost, main-menu selectable `easy`/`normal`/`hard` presets and alternating kickoff.
- Track 02H review fixes: stadium scoreboards use selected kit codes, offscreen ball indicator uses player-local basis, scoreboards cache label references, bot difficulty has non-debug API and HUD visibility.
- Track 03 Arcade V1: dash/slide/stun/flip, charged kick, SUPER shot, fireball, boost pads, jump pads, ramps, timer/golden goal/vale-2/emote and toon experiment toggle default OFF.
- Bot parity covers arcade dash/flip/stun, SUPER usage and boost pad collection.
- Toon experiment screenshots live in `docs/screenshots/track-03e-toon/`.
- Windows export preset `Windows Desktop`; debug export smoke passed to `builds/windows/CopaArenaFutebol.exe`.
- No FPS arena, no weapons, no Web/mobile, no multiplayer/backend.

## Current Gate

Ready for human arcade playtest focused on Track 03: dash/slide/flip readability, charged kick and SUPER cadence, boost/jump pad routing, timer/golden goal/vale-2 flow, bot parity and whether the toon toggle should stay. Fabio also needs to decide whether to manually download CC0 assets for 02C-bis character and 02D-bis audio.

This project remains the studio's temporary sole active implementation focus. Other active projects are paused for a few days unless the user explicitly resumes them.

## Validation

Primary command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Latest result: PASS, 46 tests, 426 asserts.

Export smoke command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-debug "Windows Desktop" "builds/windows/CopaArenaFutebol.exe"
```

Latest result: PASS, exit code `0`.

Manual smoke lives in `docs/validation.md`.

## Read Next

1. `AGENTS.md`
2. `docs/arcade-upgrade-plan.md`
3. `docs/publication-readiness.md`
4. `docs/documentation-index.md`
5. `docs/architecture-overview.md`
6. `docs/work-plan.md`
7. `docs/mode-contract.md`
8. `docs/validation.md`
9. `implementation/tracks/track-03e-toon-look-experiment-v1/current-status.md`
10. `implementation/tracks/track-03d-arcade-match-flavor-v1/current-status.md`
11. `implementation/tracks/track-03b-arcade-field-v1/current-status.md`
