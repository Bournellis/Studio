# Track 10D - Web Goal Golden Pop Hotfix V1

- Date: `2026-06-20`
- Branch: `codex/jogodacopa/track10d-web-goal-golden-pop-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track10d-web-goal-golden-pop-hotfix-v1`
- Public baseline before publication: Track 10C `Super Campeao v1.2.1+39054f31`
- Result: local validated; publication pending at this report stage.

## Scope

Track 10D fixes the human playtest perception that Track 10C's Web goal feedback was technically present but too subtle to notice.

In scope:

- Make the default Web goal visual feedback obvious with a larger, higher and longer-lived golden sphere pop.
- Lower the stadium ambience bed and the temporary goal ambience lift so the goal moment has more contrast.
- Preserve the Track 10C heap-safe default Web audio decision.

Out of scope:

- Gameplay, physics, ball, bot, scoring, SUPER, HUD behavior, camera movement and match tuning.
- PC/Windows full goal package changes.
- Default Web `goal_jingle`, `crowd_goal`, particle burst or dynamic light.

## Implementation

- Kept the default Web feedback key as `goal_visual`.
- Kept default Web goal audio disabled: `feedback.web_goal_mode visual=true audio=false`.
- Increased the main Web goal marker from a small `0.38m` sphere with `0.32s` lifetime to a golden `0.86m` sphere with `0.76s` lifetime.
- Raised the main marker height to `1.18m` and enlarged the two secondary markers.
- Reduced stadium ambience during play from `-14.0 dB` to `-18.0 dB`.
- Reduced the goal ambience lift from `-8.5 dB` to `-15.0 dB`.
- Added a GUT contract test asserting the visible Web goal pop and quieter ambience thresholds.

## Files Touched

- `presentation/feedback/fps_feedback_controller.gd`
- `tests/unit/test_render_profile.gd`
- `docs/playtest-reports/track-10d-web-goal-golden-pop-hotfix.md`
- `docs/playtest-reports/track-10d-data/`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-20_codex_jogodacopa_track10d-web-goal-golden-pop-hotfix-v1.md`

## Audio Decision

Track 10D does not re-enable default Web goal audio. Track 10B already showed that adding Web goal audio could pass local gates but fail the remote 5-minute heap gate. This hotfix therefore improves the goal feel through a more readable visual event and a quieter ambience bed.

The audio assets remain available for PC/Windows and explicit diagnostic opt-ins; they are not part of the public Web default path.

## Validation

Commands:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --editor --quit --path .
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-release "Web" "builds/web/index.html"
node --check tools/track04f_chrome_probe.mjs
node tools/track04f_chrome_probe.mjs --chrome="C:\Program Files\Google\Chrome\Application\chrome.exe" --web-dir=builds/web --duration-ms=90000 --stability-gate=1 --stability-warmup-ms=30000 --label=10d-local-web-golden-pop --out-dir=docs/playtest-reports/track-10d-data --http-port=8090 --cdp-port=9290
node tools/track04f_chrome_probe.mjs --chrome="C:\Program Files\Google\Chrome\Application\chrome.exe" --web-dir=builds/web --duration-ms=300000 --stability-gate=1 --stability-warmup-ms=30000 --label=10d-local-web-golden-pop-5min --out-dir=docs/playtest-reports/track-10d-data --http-port=8091 --cdp-port=9291
git diff --check
D:\Estudio\tools\check_doc_drift.ps1
```

Results:

- Headless editor import: PASS.
- `tools/validate.gd`: PASS after final test update, `108/108` tests, `1844` asserts, `62` source files checked.
- Web export: PASS.
- Web gzip gate: PASS, `30.62 MiB / 50.00 MiB`.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- 90s Web golden-pop probe: PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- 5min Web golden-pop stability probe: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`, `js_heap_growth +9.42%`, peak `+15.85%`, worst 5s FPS `127.6`.
- Godot counters/caches stayed stable in the 5min probe.
- Goal mode events confirmed `visual=true audio=false` across `5` observed Web goal events.

Evidence:

- `docs/playtest-reports/track-10d-data/10d-local-web-golden-pop.json`
- `docs/playtest-reports/track-10d-data/10d-local-web-golden-pop.png`
- `docs/playtest-reports/track-10d-data/10d-local-web-golden-pop-5min.json`
- `docs/playtest-reports/track-10d-data/10d-local-web-golden-pop-5min.png`

## Interpretation

Track 10D deliberately spends a small amount of visual presence to make the goal readable without reopening the default Web audio path. The local 5-minute gate passed, but retained JS heap was close to the `10%` limit. Publication must therefore include the full remote 5-minute stability gate before this can be treated as a safe public candidate.

## Next Step

If merged and published, run remote menu, first-minute, 5-minute stability, night luma and stable URL confirmation gates. Human retest remains required before marking 10D as the approved public baseline.
