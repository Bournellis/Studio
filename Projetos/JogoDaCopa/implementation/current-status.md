# JogoDaCopa - Current Status

- Last updated: `2026-06-13`
- Project: `JogoDaCopa`
- Product/module name: `Copa Arena Futebol`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first TPS football minigames + public Cloudflare Pages Web v1.0.3`
- Active stage: `Post Track 06A - Track 06B Ready`
- Active stage status: `MERGED_LOCAL - Track 06A approved by Claude/Fabio and merged in main as b585b5d2; 06B pre-requisite satisfied`
- Status marker: `JOGO_DA_COPA_TRACK_06A_MATCH_START_FIXES_V1_MERGED`
- Approved plan: Track 06A closed after Claude review and Fabio visual approval; next step is Track 06B - ESC Menu Completo V1. Remote publication remains governed by `../../08_Coordenacao_Agentes/Decisoes/2026-06-12_jogodacopa_publicacao-web-cloudflare.md` and is deferred to 06E.
- Handoffs: `../../08_Coordenacao_Agentes/Handoffs/2026-06-11_codex_jogodacopa_track04b1-character-presentation-v1.md`, `../../08_Coordenacao_Agentes/Handoffs/2026-06-11_codex_jogodacopa_track04b2-feel-ui-fixes-v1.md`, `../../08_Coordenacao_Agentes/Handoffs/2026-06-11_codex_jogodacopa_track04b3-kick-arms-polish-v1.md`, `../../08_Coordenacao_Agentes/Handoffs/2026-06-11_codex_jogodacopa_track04d-match-completeness-v1.md`, `../../08_Coordenacao_Agentes/Handoffs/2026-06-11_codex_jogodacopa_track04c-stadium-visual-v1.md`, `../../08_Coordenacao_Agentes/Handoffs/2026-06-11_codex_jogodacopa_track04e-web-spike-v1.md`, `../../08_Coordenacao_Agentes/Handoffs/2026-06-11_codex_jogodacopa_track04f-web-performance-v1.md`, `../../08_Coordenacao_Agentes/Handoffs/2026-06-12_codex_jogodacopa_track05-web-publication-v1.md`, `../../08_Coordenacao_Agentes/Handoffs/2026-06-12_codex_jogodacopa_track05a-web-stability-hotfix-v1.md`, `../../08_Coordenacao_Agentes/Handoffs/2026-06-12_codex_jogodacopa_track05b-first-minute-smoothness-v1.md`, `../../08_Coordenacao_Agentes/Handoffs/2026-06-12_codex_jogodacopa_track05b1-sensory-feedback-v1.md`, `../../08_Coordenacao_Agentes/Handoffs/2026-06-13_codex_jogodacopa_track06a-match-start-fixes-v1.md`
- Review: `docs/code-review-track04f2-webgl-first-render-stall-v1.md`, `docs/playtest-reports/track-04f2-webgl-stall.md`, `docs/code-review-track04b1-04b2-v1.md`, `docs/code-review-track04c-04d-v1.md`, `docs/code-review-track04e-web-spike-v1.md`, `docs/playtest-reports/track-04f-web-performance.md`, `docs/code-review-track04f-web-performance-v1.md`, `docs/playtest-reports/track-05a-web-stability.md`, `docs/code-review-track05a-web-stability-v1.md`, `docs/playtest-reports/track-05b-first-minute-smoothness.md`, `docs/code-review-track05b-first-minute-v1.md`, `docs/playtest-reports/track-05b1-sensory-feedback.md`, `docs/code-review-track05b1-sensory-feedback-v1.md`, `docs/playtest-reports/track-06a-match-start-fixes.md`, `docs/code-review-track06a-match-start-fixes-v1.md`
- Completed Kanban cards: `../../08_Coordenacao_Agentes/Kanban/Done/2026-06-11_codex_jogodacopa_track04b1-character-presentation-v1.md`, `../../08_Coordenacao_Agentes/Kanban/Done/2026-06-11_codex_jogodacopa_track04b2-feel-ui-fixes-v1.md`, `../../08_Coordenacao_Agentes/Kanban/Done/2026-06-11_codex_jogodacopa_track04b3-kick-arms-polish-v1.md`, `../../08_Coordenacao_Agentes/Kanban/Done/2026-06-11_codex_jogodacopa_track04d-match-completeness-v1.md`, `../../08_Coordenacao_Agentes/Kanban/Done/2026-06-11_codex_jogodacopa_track04c-stadium-visual-v1.md`, `../../08_Coordenacao_Agentes/Kanban/Done/2026-06-11_codex_jogodacopa_track04e-web-spike-v1.md`, `../../08_Coordenacao_Agentes/Kanban/Done/2026-06-11_codex_jogodacopa_hotfix04e1-night-capture.md`, `../../08_Coordenacao_Agentes/Kanban/Done/2026-06-11_codex_jogodacopa_track04f-web-performance-v1.md`, `../../08_Coordenacao_Agentes/Kanban/Done/2026-06-12_codex_jogodacopa_track05a-web-stability-hotfix-v1.md`, `../../08_Coordenacao_Agentes/Kanban/Done/2026-06-12_codex_jogodacopa_track05b-first-minute-smoothness-v1.md`, `../../08_Coordenacao_Agentes/Kanban/Done/2026-06-12_codex_jogodacopa_track05b1-sensory-feedback-v1.md`, `../../08_Coordenacao_Agentes/Kanban/Done/2026-06-13_codex_jogodacopa_track06a-match-start-fixes-v1.md`
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
- Track 04B1 Character Presentation & Animation V1: uniforme procedural por regioes no mesh skinned, cabelo real anexado ao bone `Head`, toon por material `next_pass` sem duplicata T-pose e chute autoral `0.36s` com pe abaixo do quadril.
- Track 04B3 Kick Arms Polish V1: aprovado e mergeado; retunou somente os bracos do `JogoDaCopa_Kick`, mantendo pernas/tronco/timing aprovados; maos ficam abaixo da cabeca e upperarms ficam `<= 25 deg` de abducao nas amostras do clipe.
- Track 04D Match Completeness V1: aprovado pelo review e mergeado em main; pause real com restart/volumes/menu, resultado rico com estatisticas puras, fades curtos, ESC/foco/restart consistentes e hero shot do menu em 1080p/720p.
- Track 04C Stadium Visual Upgrade V1: aprovado pelo review e mergeado em main apos a 04D; arquibancadas profundas, torcida com cores dos dois kits e `crowd_excitement`, teloes maiores, bandeiroes, mastros animados, halos emissive e skyline low-poly sem novas luzes com sombra.
- Track 04E Web Export Spike & Render Profile V1 + Hotfix 04E.1: aprovado pela Claude e mergeado em main; preset Web single-threaded exporta o jogo completo para `builds/web/`, `RenderProfile` central preserva desktop Forward+ e aplica fallbacks Compatibility no Web, e o hotfix corrigiu o caminho de captura lavada usando camera de evidencia noturna com gate de luminancia `< 90`.
- Track 04F Web Performance & Load V1: aprovado pela Claude e mergeado localmente em main; load Web instrumentado, loading com progresso visivel, animacoes UAL processadas em `.res`, cache de avatar/region mask, SubViewports Web on-change, PCK `26.41 MiB`, smoothness pos-warmup PASS; residual de primeiro render/upload WebGL `~16.8s-18.1s` promovido para `Track 04F.2 - WebGL First-Render Stall`.
- Track 05 Web Publication V1: publicado em Cloudflare Pages publico no projeto `copa-arena-futebol`, URL estavel `https://copa-arena-futebol.pages.dev/`, release root `web/v1-copa-arena-futebol-20260612-31e23ea3`, script `tools/publish_web.ps1` com `Plan`/`Package`/`FullPublish`, pacote Brotli para assets maiores que `25 MiB` e smoke remoto PASS sem erros de runtime.
- Track 05A Web Stability Hotfix V1: publicado em Cloudflare Pages publico como `web/v1-copa-arena-futebol-20260612-a850045a` / `v1.0.1+a850045a`; reduz churn por frame de HUD/placares, adiciona gate Chrome 5 min de estabilidade, exibe versao/hash no rodape do menu e validou local/remoto com heap retido < 10%, nodes/caches estaveis e runtime errors `0`.
- Track 05B First-Minute Smoothness V1: publicado em Cloudflare Pages publico como `web/v1-copa-arena-futebol-20260612-ad82384b` / `v1.0.2+ad82384b`; completa warmup antes do overlay, aquece primeiros usos dentro do frustum, corta feedback transiente Web e `AudioStreamPlayer3D`; primeiro minuto local/remoto com todos os primeiros usos provocados teve `0` hitches `>100ms` e runtime errors `0`; local primeira visita ainda carrega em `~13.5s-13.7s`.
- Track 05B.1 Sensory Feedback Re-Introduction V1: aprovado por Claude e mergeado localmente em `main` como `f759dd34`; publicado em Cloudflare Pages publico como `web/v1-copa-arena-futebol-20260612-ef9c5baa` / `v1.0.3+ef9c5baa`; reintroduz APITO, `CONFETTI de gol`, VFX/audio 2D de chute, countdown, jump pad e result/rematch no Web default sem reabrir hitches `>100ms`; audio Web aguarda ativacao do navegador; local primeira visita `~17.8s-18.3s`.
- Track 06A Match Start Fixes V1: aprovado por Claude/Fabio e mergeado localmente em `main` como `b585b5d2`; kickoff inicial dispara countdown uma unica vez, player/bot iniciam olhando para o oponente no kickoff inicial e pos-gol, HUD em jogo nao contem hints/crosshair e os comandos migraram para `FootballHud.CONTROL_HINTS`; validate/export/Web boot/capturas desktop PASS.
- Bot parity covers arcade dash/flip/stun, SUPER usage and boost pad collection.
- Toon experiment screenshots live in `docs/screenshots/track-03e-toon/`.
- Windows export preset `Windows Desktop`; debug export smoke passed to `builds/windows/CopaArenaFutebol.exe`.
- No FPS arena, no weapons, no mobile, no multiplayer/backend.

## Current Gate

Track 06A Match Start Fixes V1 is approved by Claude/Fabio and merged locally in `main` as merge commit `b585b5d2`. The public Web baseline remains `v1.0.3+ef9c5baa` at `https://copa-arena-futebol.pages.dev/`; no 06A/06B publication before 06E. Next step: Track 06B - ESC Menu Completo V1 from main with 06A available.

This project remains the studio's temporary sole active implementation focus. Other active projects are paused for a few days unless the user explicitly resumes them.

## Validation

Primary command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Latest main result after Track 06A merge closure: PASS, 91 tests, 1298 asserts, including Web gzip transfer gate `30.29 MiB / 50.00 MiB`, source integrity check for 37 `.gd/.gdshader` files outside `addons/` and UTF-8 BOM rejection.

Latest remote Web smoke: `docs/playtest-reports/track-05b1-data/05b1-remote-first-minute-gate-final-ef9c5baa.json` and `docs/playtest-reports/track-05b1-data/05b1-remote-stability-5min-final-ef9c5baa-pass2.json` at `https://copa-arena-futebol.pages.dev/`, release root `web/v1-copa-arena-futebol-20260612-ef9c5baa` matched, page errors `0`, runtime console errors `0`, first-minute hitches `0`, stability gate PASS.

Export smoke command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-debug "Windows Desktop" "builds/windows/CopaArenaFutebol.exe"
```

Latest result: PASS, exit code `0`.

Web export smoke command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-release "Web" "builds/web/index.html"
```

Latest branch result: PASS, exit code `0`, single-threaded `GODOT_THREADS_ENABLED=false`.

Manual smoke lives in `docs/validation.md`.

## Read Next

1. `AGENTS.md`
2. `docs/quality-upgrade-plan.md`
3. `docs/arcade-upgrade-plan.md`
4. `docs/publication-readiness.md`
5. `docs/release-history.md`
6. `docs/documentation-index.md`
7. `docs/architecture-overview.md`
8. `docs/work-plan.md`
9. `docs/mode-contract.md`
10. `docs/validation.md`
11. `implementation/tracks/track-05-web-publication/current-status.md`
12. `implementation/tracks/track-02cbis-real-character-v1/current-status.md`
13. `implementation/tracks/track-02dbis-real-audio-v1/current-status.md`
14. `implementation/tracks/track-03e-toon-look-experiment-v1/current-status.md`
15. `implementation/tracks/track-03f-quality-hotfix-v1/current-status.md`
16. `implementation/tracks/track-03g-playtest-findings-v1/current-status.md`
17. `implementation/tracks/track-03h-avatar-parity-drift-v1/current-status.md`
18. `implementation/tracks/track-03i-menu-interaction-fix-v1/current-status.md`
19. `implementation/tracks/track-03k-animation-pose-restore-v2/current-status.md`
20. `implementation/tracks/track-03l-arena-seal-facing-v2/current-status.md`
21. `implementation/tracks/track-03l1-facing-evidence-v1/current-status.md`
22. `implementation/tracks/track-04b1-character-presentation-v1/current-status.md`
23. `implementation/tracks/track-04b2-feel-ui-fixes-v1/current-status.md`
24. `implementation/tracks/track-04b3-kick-arms-polish-v1/current-status.md`
25. `implementation/tracks/track-04d-match-completeness-v1/current-status.md`
26. `implementation/tracks/track-04e-web-spike-v1/current-status.md`
