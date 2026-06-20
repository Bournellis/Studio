# Track 10C - Web Goal Feedback Heap-Safe V1

- Date: `2026-06-20`
- Branch: `codex/jogodacopa/track10c-web-goal-feedback-heap-safe-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track10c-web-goal-feedback-heap-safe-v1`
- Public baseline preserved before publication: Track 10A `Super Campeao v1.2.1+fc3c72bb`
- Result: local validated publication candidate.

## Scope

Reintroduce a more satisfying Web goal moment after Track 10B failed the remote 5-minute heap gate.

In scope:

- Default Web goal visual feedback.
- Heap-safe Web goal mode split.
- Local Chrome performance evidence.

Out of scope:

- Gameplay, physics, ball, bot, scoring, SUPER, HUD behavior, camera movement and tuning.
- PC/Windows goal package changes.
- Web `crowd_goal`, Web particle burst and Web dynamic light.
- Default Web goal audio.

## Implementation

- Replaced the default Web feedback key `goal` with `goal_visual`.
- Kept the Web goal visual path as the existing three pooled `MeshInstance3D` sphere markers.
- Added a separate `goal_audio` opt-in key for the short `goal_jingle`.
- Kept the legacy `goal` query key as an explicit opt-in that enables both visual and audio for diagnostics/backward compatibility.
- Default Web goal mode is now `visual=true audio=false`.
- PC/Windows keeps the existing full goal package: large burst, secondary burst, light, `goal_jingle`, `crowd_goal` and ambience boost.
- Updated the GUT contract to assert default Web feedback includes `goal_visual` and excludes `goal_audio`, `goal` and `crowd_goal`.

## Files Touched

- `presentation/feedback/fps_feedback_controller.gd`
- `tests/unit/test_render_profile.gd`
- `implementation/current-status.md`
- `docs/work-plan.md`
- `docs/documentation-index.md`
- `docs/playtest-reports/track-10c-web-goal-feedback-heap-safe.md`
- `docs/playtest-reports/track-10c-data/`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-20_codex_jogodacopa_track10c-web-goal-feedback-heap-safe-v1.md`

## Audio Decision

Track 10B showed that the local gate tolerated the short `goal_jingle`, but the remote 5-minute heap gate failed with `js_heap_growth +13.85%`. Track 10C therefore keeps the visual goal pulse in the default Web path and removes goal audio from default Web execution.

Audio is not deleted. It remains available through `jdc_web_feedback=goal_audio` or the legacy `jdc_web_feedback=goal` diagnostic path, but it is not part of the default public Web candidate.

## Validation

Commands:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --editor --quit --path .
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-release "Web" "builds/web/index.html"
node --check tools/track04f_chrome_probe.mjs
node tools/track04f_chrome_probe.mjs --chrome="C:\Program Files\Google\Chrome\Application\chrome.exe" --web-dir=builds/web --duration-ms=90000 --first-minute-gate=1 --first-minute-duration-ms=60000 --label=10c-local-web-goal-visual-only --out-dir=docs/playtest-reports/track-10c-data --fail-on-runtime-errors=1 --http-port=8079 --cdp-port=9279 --screenshot-at-ms=45000
node tools/track04f_chrome_probe.mjs --chrome="C:\Program Files\Google\Chrome\Application\chrome.exe" --web-dir=builds/web --duration-ms=300000 --stability-gate=1 --stability-warmup-ms=30000 --first-minute-gate=1 --first-minute-duration-ms=60000 --label=10c-local-web-goal-visual-only-5min --out-dir=docs/playtest-reports/track-10c-data --fail-on-runtime-errors=1 --http-port=8080 --cdp-port=9280 --screenshot-at-ms=45000
```

Results:

- Headless editor import: PASS.
- `tools/validate.gd`: PASS, `108/108` tests, `1840` asserts, `62` source files checked.
- Web export: PASS.
- Web gzip gate: PASS, `30.62 MiB / 50.00 MiB`.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- 90s Web visual-only goal probe: PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- 5min Web visual-only stability probe: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`, `js_heap_growth -8.10%`, peak `+1.10%`, worst 5s FPS `137.4`.
- Godot counters/caches stayed stable in the 5min probe.
- Goal mode events confirmed `visual=true audio=false` across `5` observed Web goal events.

Evidence:

- `docs/playtest-reports/track-10c-data/10c-local-web-goal-visual-only.json`
- `docs/playtest-reports/track-10c-data/10c-local-web-goal-visual-only.png`
- `docs/playtest-reports/track-10c-data/10c-local-web-goal-visual-only-5min.json`
- `docs/playtest-reports/track-10c-data/10c-local-web-goal-visual-only-5min.png`

## Next Step

Publish Track 10C only if the local branch is committed cleanly, then run remote menu, remote first-minute and remote 5-minute stability gates. If the remote heap gate fails, rollback to Track 10A immediately and keep 10C as a blocked publication attempt.
