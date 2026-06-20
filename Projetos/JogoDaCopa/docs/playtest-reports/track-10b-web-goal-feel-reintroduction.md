# Track 10B - Web Goal Feel Reintroduction V1

- Date: `2026-06-20`
- Branch: `codex/JogoDaCopa/track10b-web-goal-feel-reintroduction-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track10b-web-goal-feel-reintroduction-v1`
- Public baseline preserved: Track 10A `Super Campeao v1.2.1+fc3c72bb`
- Result: local validated, not published.

## Scope

Reintroduce a more satisfying Web goal moment without accepting active-match freezes.

In scope:

- Default Web goal feedback.
- Web-safe visual goal pulse.
- Short Web goal audio attempt.
- Local Chrome performance evidence.

Out of scope:

- Gameplay, physics, ball, bot, scoring, SUPER, HUD behavior, camera movement and tuning.
- PC/Windows goal package changes.
- Cloudflare publication.

## Implementation

- Added `goal` back to `WEB_DEFAULT_FEEDBACK_EFFECTS`.
- Replaced the Web goal path with `_spawn_web_goal_lite()`.
- The Web goal path now uses three pooled `MeshInstance3D` sphere markers.
- The Web goal path plays only `goal_jingle` through 2D UI audio after browser activation.
- The Web goal path does not play `crowd_goal`, spawn a Web particle burst or spawn a Web dynamic light.
- PC/Windows keeps the existing full goal package: large burst, secondary burst, light, `goal_jingle`, `crowd_goal` and ambience boost.
- Changed UI audio lazy loading to load only the requested stream, instead of loading every real audio stream on first Web UI playback.
- Added a GUT contract asserting default Web feedback includes `goal` and not `crowd_goal`.

## Files Touched

- `presentation/feedback/fps_feedback_controller.gd`
- `tests/unit/test_render_profile.gd`
- `implementation/current-status.md`
- `docs/work-plan.md`
- `docs/documentation-index.md`
- `docs/architecture-overview.md`
- `docs/playtest-reports/track-10b-web-goal-feel-reintroduction.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Kanban/Done/2026-06-20_codex_jogodacopa_track10b-web-goal-feel-reintroduction-v1.md`

## Audio Decision

The short `goal_jingle` stays enabled for Web because the audio-unlock probe showed safe timings:

- First `goal_jingle` lazy load: `0.6ms`.
- First `goal_jingle` play call: `5.7ms`.
- Later `goal_jingle` play calls: about `1.2ms`.
- `crowd_goal` did not appear in the Web goal path.

The heavier crowd MP3 remains out of default Web goal feedback. This is intentional: the previous full `goal` package caused large first-minute hitches when forced on Web, and the product need here is goal punch without active-match freeze.

## Validation

Commands:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --editor --quit --path .
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-release "Web" "builds/web/index.html"
node --check tools/track04f_chrome_probe.mjs
node tools/track04f_chrome_probe.mjs --chrome="C:\Program Files\Google\Chrome\Application\chrome.exe" --web-dir=builds/web --duration-ms=90000 --first-minute-gate=1 --first-minute-duration-ms=60000 --label=10b-local-web-goal-lite --out-dir=docs/playtest-reports/track-10b-data --fail-on-runtime-errors=1 --http-port=8076 --cdp-port=9266 --screenshot-at-ms=45000
node tools/track04f_chrome_probe.mjs --chrome="C:\Program Files\Google\Chrome\Application\chrome.exe" --web-dir=builds/web --duration-ms=90000 --first-minute-gate=1 --first-minute-duration-ms=60000 --press-play=1 --label=10b-local-web-goal-lite-audio-unlock --out-dir=docs/playtest-reports/track-10b-data --fail-on-runtime-errors=1 --http-port=8077 --cdp-port=9267 --screenshot-at-ms=45000
node tools/track04f_chrome_probe.mjs --chrome="C:\Program Files\Google\Chrome\Application\chrome.exe" --web-dir=builds/web --duration-ms=300000 --stability-gate=1 --stability-warmup-ms=30000 --first-minute-gate=1 --first-minute-duration-ms=60000 --label=10b-local-web-goal-lite-5min --out-dir=docs/playtest-reports/track-10b-data --fail-on-runtime-errors=1 --http-port=8078 --cdp-port=9268 --screenshot-at-ms=45000
```

Results:

- Headless editor import: PASS.
- `tools/validate.gd`: PASS, `108/108` tests, `1838` asserts, `62` source files checked, Web gzip `30.62 MiB / 50.00 MiB`.
- Web export: PASS.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- 90s Web goal-lite probe: PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- 90s Web goal-lite audio-unlock probe: PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`, `goal_jingle` played.
- 5min Web stability probe: PASS, `firstMinuteHitches=0`, `js_heap_growth -8.36%`, worst 5s FPS `121`.
- Active-match goal windows in 5min probe: `hitchCount=0`, max frame about `13.8ms`.

Evidence:

- `docs/playtest-reports/track-10b-data/10b-local-web-goal-lite.json`
- `docs/playtest-reports/track-10b-data/10b-local-web-goal-lite.png`
- `docs/playtest-reports/track-10b-data/10b-local-web-goal-lite-audio-unlock.json`
- `docs/playtest-reports/track-10b-data/10b-local-web-goal-lite-audio-unlock.png`
- `docs/playtest-reports/track-10b-data/10b-local-web-goal-lite-5min.json`
- `docs/playtest-reports/track-10b-data/10b-local-web-goal-lite-5min.png`

## Notes

The 5min JSON still contains large warmup/first-use hitches before `event.visible_match_start`. They are outside the active-match acceptance window and match the existing Web warmup behavior. After `event.visible_match_start`, the observed goal windows passed with no hitches.

## Next Step

Promote Track 10B to publication only if the lightweight Web goal feel is accepted. Publication still needs the usual remote menu, first-minute, 5-minute stability, luma and human retest gates.
