# JogoDaCopa - Current Status

- Last updated: `2026-06-10`
- Project: `JogoDaCopa`
- Product/module name: `Copa Arena Futebol`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first TPS football minigames`
- Active stage: `Track 02C-bis/02D-bis - Real Assets V1`
- Active stage status: `COMPLETE`
- Status marker: `JOGO_DA_COPA_TRACK_02CBIS_02DBIS_REAL_ASSETS_V1_COMPLETE`
- Approved plan: `docs/quality-upgrade-plan.md` (2026-06-10, 02C-bis/02D-bis real assets complete after manual asset download)
- Completed Kanban card: `../../08_Coordenacao_Agentes/Kanban/Done/2026-06-10_codex_jogodacopa_track02cbis-02dbis-real-assets-v1.md`
- Studio focus: `TEMPORARY_SOLE_ACTIVE_PROJECT`

## Current Truth

`JogoDaCopa` is the football/TPS project split from the former `Projetos/FpsShooter` workspace. It owns the independent Copa-inspired football minigame direction. The first playable product surface is now named `Copa Arena Futebol`.

The Arena Shooter work moved to `Projetos/FpsPlayground`.

## Current Scope

- PC Windows editor-first.
- Main menu launches `Copa Arena Futebol` / `Futebol 1x1`.
- Third-person 1x1 football against a bot.
- Default match mode is 3-minute timer; `3 gols` mode remains selectable and unchanged.
- Hybrid Track 02 presentation: procedural night stadium/arena/VFX plus in-repo authored CC0 ball/branding assets, real Quaternius humanoid avatars and real Kenney/Pixabay audio.
- Night `WorldEnvironment` with ACES tonemap, glow, SSAO, fog, procedural sky and stadium spot/key lights.
- Shader pitch with field markings, grid nets, animated crowd bands, country-inspired banners and live stadium scoreboards.
- Closed glass arena with larger field, roof collision, framed glass walls, roofed goals and height-aware goal scoring.
- Loose arcade `RigidBody3D` ball with football-panel shader, hysteresis trail, squash on kick, higher bounce and extra ground-roll grip.
- Visible third-person real skinned humanoid avatars preserving `apply_appearance`, `set_move_state`, `play_kick` and `play_celebrate`; player uses male model and bot uses female model with UAL animation clips plus authored kick animation.
- Skin tone and country-inspired shirt selection.
- Kickoff countdown, input lock, goal slow-mo, camera shake, boost FOV, transient kick/goal bursts, persistent boost/skid particles, real SFX/jingles/crowd ambience and synthetic referee whistle only.
- Broadcast-style HUD, offscreen ball indicator, result/rematch panel and polished 3D menu with avatar preview.
- Football bot with prediction, positioned defense, boost, main-menu selectable `easy`/`normal`/`hard` presets and alternating kickoff.
- Track 02H review fixes: stadium scoreboards use selected kit codes, offscreen ball indicator uses player-local basis, scoreboards cache label references, bot difficulty has non-debug API and HUD visibility.
- Track 03 Arcade V1: dash/slide/stun/flip, charged kick, SUPER shot, fireball, boost pads, jump pads, ramps, timer/golden goal/vale-2/emote and toon experiment toggle default OFF.
- Bot parity covers arcade dash/flip/stun, SUPER usage and boost pad collection.
- Toon experiment screenshots live in `docs/screenshots/track-03e-toon/`.
- Windows export preset `Windows Desktop`; debug export smoke passed to `builds/windows/CopaArenaFutebol.exe`.
- No FPS arena, no weapons, no Web/mobile, no multiplayer/backend.

## Current Gate

Ready for full human playtest focused on the combined playable: Track 03 arcade mechanics plus 02C-bis real character readability and 02D-bis real audio mix.

This project remains the studio's temporary sole active implementation focus. Other active projects are paused for a few days unless the user explicitly resumes them.

## Validation

Primary command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Latest result: PASS, 48 tests, 459 asserts.

Latest performance sample: average `145.4fps`, min warmed instant `124.0fps`, `0/360` frames below 60.

Export smoke command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-debug "Windows Desktop" "builds/windows/CopaArenaFutebol.exe"
```

Latest result: PASS, exit code `0`.

Manual smoke lives in `docs/validation.md`.

## Read Next

1. `AGENTS.md`
2. `docs/quality-upgrade-plan.md`
3. `docs/arcade-upgrade-plan.md`
4. `docs/publication-readiness.md`
5. `docs/documentation-index.md`
6. `docs/architecture-overview.md`
7. `docs/work-plan.md`
8. `docs/mode-contract.md`
9. `docs/validation.md`
10. `implementation/tracks/track-02cbis-real-character-v1/current-status.md`
11. `implementation/tracks/track-02dbis-real-audio-v1/current-status.md`
12. `implementation/tracks/track-03e-toon-look-experiment-v1/current-status.md`
