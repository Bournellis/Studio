# JogoDaCopa - Current Status

- Last updated: `2026-06-11`
- Project: `JogoDaCopa`
- Product/module name: `Copa Arena Futebol`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first TPS football minigames`
- Active stage: `Track 04B2 - Feel & UI Fixes V1`
- Active stage status: `WORKTREE_VERIFIED - pending Claude review`
- Status marker: `JOGO_DA_COPA_TRACK_04B2_FEEL_UI_FIXES_V1_WORKTREE_VERIFIED`
- Approved plan: Fabio direct task `Track 04B2 - Feel & UI Fixes V1` (2026-06-11)
- Handoff: `../../08_Coordenacao_Agentes/Handoffs/2026-06-11_codex_jogodacopa_track04b2-feel-ui-fixes-v1.md`
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
- Track 03F Quality Hotfix V1: SUPER whiffs do not spend bar/quota, real avatar tint preserves PBR textures, perf sample records representative window metadata and validation catches truncated `.gd`/`.gdshader` sources.
- Track 03G Playtest Findings V1: menu responsivo, aparencia somente na intro pre-kickoff, dash player/bot `20.75` por `0.28s`, bot com hold defensivo no kickoff do player e defesa aerea, camera com raycast clamp/spawn seguro no kickoff do bot, reset seguro da bola e marcador/anunciador de kickoff.
- Track 03H Avatar Parity & Animation Drift Fix V1: bot e player usam modelo real na cena montada, corpo primitivo do combatant fica oculto em ambos, falhas de modelo real emitem `push_error`, clipes UAL tem root motion horizontal/yaw removido e a pose e travada contra drift.
- Track 03I Menu Interaction Fix V1: menu principal voltou a receber clique real; `MainMenuRoot` agora sincroniza ao viewport, `MenuSafeArea`/`MenuScroll` foram removidos, e o teste de clique real cobre todos os controles interativos em `1920x1080`, `1366x768` e `1280x720`.
- Track 03K Animation Pose Restore V2: o strip manual de keyframes da 03H foi substituido por remocao completa das tracks do bone `root` nos clipes UAL; `pelvis` e demais bones permanecem originais, restaurando pose em pe e vida da animacao enquanto o drift de mundo segue coberto por teste.
- Track 03L Arena Seal & Character Facing V2: arena estanque com vidros ate o teto, painel frontal alto sobre os gols, rodape/rampas 03B removidos, CCD da bola ativo e avatar visual do player girando pela direcao de movimento sem alterar camera/mira/chute.
- Track 03L.1 Facing Evidence V1: lacunas do review da Claude fechadas com teste automatizado de facing no avatar, capturas de corrida em curva/parada/rebote alto e `docs/playtest-reports/track-03l-arena.md`.
- Track 04B2 Feel & UI Fixes V1: dash player/bot agora usa curva integrada com aceleracao e distancia `5.3m`; pulo/flip sem input direcional fica vertical puro; result panel libera mouse, trava input e foca Revanche; intro/pause/result tem clique real em 3 resolucoes; preview do menu ganhou camera/luz de heroi e teste anti-tela-preta.
- Bot parity covers arcade dash/flip/stun, SUPER usage and boost pad collection.
- Toon experiment screenshots live in `docs/screenshots/track-03e-toon/`.
- Windows export preset `Windows Desktop`; debug export smoke passed to `builds/windows/CopaArenaFutebol.exe`.
- No FPS arena, no weapons, no Web/mobile, no multiplayer/backend.

## Current Gate

Ready for Claude review of Track 04B2 in branch `codex/jogodacopa/track04b2-feel-ui-fixes-v1`. Do not merge to `main` until review passes. After review, Fabio confirmation playtest should focus on dash body feel, stationary vs moving jump, result panel clickability and menu preview framing. Final feel remains a human-eye gate.

This project remains the studio's temporary sole active implementation focus. Other active projects are paused for a few days unless the user explicitly resumes them.

## Validation

Primary command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Latest result: PASS for Track 04B2 full validation, 70 tests, 930 asserts, including source integrity check for 28 `.gd/.gdshader` files outside `addons/`.

Latest performance sample: windowed 1920x1080, vsync off, display `Windows`, average `719.3fps`, min warmed instant `462.3fps`, `0/360` frames below 60.

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
13. `implementation/tracks/track-03f-quality-hotfix-v1/current-status.md`
14. `implementation/tracks/track-03g-playtest-findings-v1/current-status.md`
15. `implementation/tracks/track-03h-avatar-parity-drift-v1/current-status.md`
16. `implementation/tracks/track-03i-menu-interaction-fix-v1/current-status.md`
17. `implementation/tracks/track-03k-animation-pose-restore-v2/current-status.md`
18. `implementation/tracks/track-03l-arena-seal-facing-v2/current-status.md`
19. `implementation/tracks/track-03l1-facing-evidence-v1/current-status.md`
20. `implementation/tracks/track-04b2-feel-ui-fixes-v1/current-status.md`
