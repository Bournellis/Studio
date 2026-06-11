# Track 04E - Web Export Spike & Render Profile V1

- Date: `2026-06-11`
- Branch: `codex/jogodacopa/track04e-web-spike-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track04e`
- Build target: Web single-threaded, Compatibility renderer, no SharedArrayBuffer, no COOP/COEP headers.
- Hotfix: `04E.1 - Night Capture & Source Integrity`
- Verdict: READY FOR NEW PRE-MERGE REVIEW. The Web build boots in local Chrome at 1080p, and game-scene captures now preserve the approved night arena instead of the washed capture path found by Claude.

## Hotfix 04E.1 Root Cause

The red-first capture gate reproduced the bug before any fix. The capture script confirmed the mounted football scene had the correct night environment:

- `WorldEnvironment` present.
- `Environment.tonemap_mode == ACES`.
- `Environment.background_mode == BG_SKY`.
- `ProceduralSkyMaterial.sky_top_color` dark, configured sky luma `2.8`.

The same pre-fix capture failed on the rendered image:

- Active camera: `/root/FootballRoot/RuntimeRoot/FootballChaseCamera/Camera3D`
- Camera FOV: `82.0`
- Camera position: `(0.0, 3.6, 26.4)`
- Camera rotation: `(-11.43338, 0.0, 0.0)`
- Captured sky-region luma: `180.2`
- Gate: luma must be `< 90.0`

Root cause: the runtime evidence path reused the gameplay chase camera. In capture mode that camera sits low inside the arena, with a wide FOV and a top-right sample dominated by bright glass/roof/fog instead of the real night sky. The environment code was not replaced and the real editor game remained night. This was a pre-existing capture-path bug: Track 04D result evidence already used the same washed camera path.

## Hotfix 04E.1 Fix

- Added a named evidence-only camera, `Track04ECaptureCamera`, applied only for capture scenes.
- Centralized all capture camera FOV, near/far, positions and targets in named constants in `football_root.gd`.
- Kept gameplay code unified: no gameplay fork and no render fork.
- Added capture assertions for `WorldEnvironment`, ACES tonemap, `BG_SKY`, dark `sky_top_color`, and rendered sky-region luma `< 90`.
- Added GUT coverage for capture-mode night environment plus current evidence camera.
- Suppressed the result transition pulse only in capture mode so result evidence is not caught mid-fade.
- Removed UTF-8 BOM from the requested `.gd` files and extended `validate.gd` source integrity to reject BOM in `.gd` and `.gdshader`.
- Promoted the night-capture luminance check into the permanent Web/evidence gate.

## Commands

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --editor --quit --path .
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --path . -s res://tools/capture_track04e_web_spike.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-release "Web" "builds/web/index.html"
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --path . -s res://tools/performance_sample.gd --label=track04e1-night-capture-hotfix
```

Chrome smoke served `builds/web/` over local HTTP and opened:

- `/index.html`
- `/index.html?jdc_capture=kickoff`
- `/index.html?jdc_capture=goal`
- `/index.html?jdc_capture=result`
- `/index.html?jdc_capture=play`

## Evidence

| Scene | Desktop Forward+ | Web Compatibility |
|---|---|---|
| Menu hero | ![desktop menu](../screenshots/track-04e-web-spike/desktop-menu-hero-1920x1080.png) | ![web menu](../screenshots/track-04e-web-spike/web-menu-hero-1920x1080.png) |
| Kickoff | ![desktop kickoff](../screenshots/track-04e-web-spike/desktop-kickoff-1920x1080.png) | ![web kickoff](../screenshots/track-04e-web-spike/web-kickoff-1920x1080.png) |
| Goal | ![desktop goal](../screenshots/track-04e-web-spike/desktop-goal-1920x1080.png) | ![web goal](../screenshots/track-04e-web-spike/web-goal-1920x1080.png) |
| Result | ![desktop result](../screenshots/track-04e-web-spike/desktop-result-1920x1080.png) | ![web result](../screenshots/track-04e-web-spike/web-result-1920x1080.png) |
| Play | ![desktop play](../screenshots/track-04e-web-spike/desktop-play-1920x1080.png) | ![web play](../screenshots/track-04e-web-spike/web-play-1920x1080.png) |

Extra Web performance frame:

![web play performance](../screenshots/track-04e-web-spike/web-play-performance-1920x1080.png)

## Night Luminance Gate

Sample region: right-side upper sky window, `x=62%-96%`, `y=4%-28%`, same region used by the capture script. Game-scene captures must stay below luma `90.0` on a 0-255 scale.

| Scene | Desktop luma | Web luma | Verdict |
|---|---:|---:|---|
| Kickoff | `60.2` | `10.9` | PASS |
| Goal | `64.0` | `29.5` | PASS |
| Result | `75.8` | `6.4` | PASS |
| Play | `60.2` | `10.9` | PASS |

The menu hero is not part of the night-sky luma gate because it is a menu presentation shot, not a mounted game-scene capture.

## Export Contract

- Web preset output: `builds/web/index.html`.
- `variant/thread_support=false`.
- `variant/extensions_support=false`.
- `progressive_web_app/ensure_cross_origin_isolation_headers=false`.
- Generated HTML contains `GODOT_THREADS_ENABLED = false`.
- Final Chrome boot smoke after export: canvas `1920x1080`, screenshot `1345589` bytes, local HTTP only.
- Full recapture smoke: no page errors; known `RenderProfile` fallback warnings only.

## Renderer Inventory

| Item | Desktop Forward+ | Web Compatibility | Verdict |
|---|---|---|---|
| Glow/bloom | Stronger glow around glass frames, stadium lights, ball/VFX emissives and banners. | Glow is flatter/weaker; `RenderProfile` raises Web emissive multipliers. | PASS with expected fallback; Fabio visual review still required. |
| SSAO | Enabled in the desktop profile. | Disabled by Web profile; fake AO intent comes from ambient/fog/shadow tuning. | EXPECTED FALLBACK. |
| Fog | ACES night fog gives deeper stadium volume. | Compatibility fog remains lighter to avoid a muddy Web image. | PASS after night capture fix. |
| Sky | Dark procedural night sky, luma gate passes. | Darker/cleaner Compatibility capture, luma gate passes. | PASS. |
| Pitch shader | Field stripes, center circle and markings render. | Field stripes and markings render with flatter lighting. | PASS. |
| Nets shader | Grid nets and goal frames render with desktop glow. | Nets and frames render; glow is less pronounced. | PASS. |
| Crowd/stands shader | Crowd bands, team colors, banners and stands render. | Crowd/stands render with flatter lighting and Web fallback brightness. | PASS. |
| Ball shader | Panel shader, trail and fireball contract intact. | Panel shader renders; Web emission scale applied. | PASS. |
| Uniform regions | PBR texture/tint and regional kit colors preserved. | Kit colors render; Web fallback does not affect gameplay. | PASS. |
| Fireball/VFX | Desktop VFX brighter and fuller. | Web transient particles are reduced and emissives boosted for readability. | PASS with performance fallback. |
| SubViewports | Stadium scoreboards and menu preview use desktop sizes. | Web profile uses lower SubViewport sizes for scoreboards and menu preview. | PASS; no blank preview observed. |
| Particles | Full desktop particle amount. | Web profile reduces transient particle amount. | PASS; visible and within budget. |
| Audio autoplay | Desktop uses the normal Godot audio flow. | Browser audio still follows autoplay policy; first user interaction is required before audible playback. | EXPECTED BROWSER POLICY. |
| `user://` save | Desktop uses local user data. | Web contract is `user://` via IndexedDB. No manual save loop was exercised in this spike because persistence UI is not a gameplay feature yet. | CONTRACT RECORDED. |
| CCD da bola | Existing `continuous_cd` coverage remains. | Same gameplay code/path; Chrome smoke produced no runtime errors. | PASS. |
| Performance | Desktop Forward+ real window: average `600.2fps`, min warmed instant `374.1fps`, `0/360` below 60. | Chrome Web rAF sample: average `142.3fps`, mean `7.03ms`, p95 `7.0ms`, max `13.9ms`, `180` samples. | PASS for local 1080p smoke. |

## Validation Results

- Red-first capture gate before fix: FAIL as expected, rendered sky luma `180.2` against `< 90.0`.
- Capture rerun after fix: PASS, desktop game-scene luma values `60.2`, `64.0`, `75.8`, `60.2`.
- Full validation: PASS, 86 tests, 1264 asserts.
- Source integrity: PASS, 33 `.gd/.gdshader` files outside `addons/`; UTF-8 BOM now rejected by the gate.
- Web export: PASS, exit code `0`, single-threaded.
- Chrome smoke: PASS, canvas `1920x1080`, final CDP screenshot `1345589` bytes.
- Desktop performance sample: PASS, 0/360 frames below 60.
- Web performance sample: PASS, rAF average `142.3fps`.

## Known Noise

- Godot/GUT UID text-path warnings still appear during import/export/validation and are existing accepted noise when tests pass.
- Web export still reports an ObjectDB leak warning on exit while returning code `0`; this is existing Godot/editor export noise for this project path, not a gameplay boot failure.
- The Web runtime intentionally logs known `RenderProfile` warnings once for Compatibility fallbacks. Silent fallback is not allowed; unknown runtime divergence must emit `push_error`.

## Handoff

Stop on branch for mandatory Claude pre-merge review and Fabio visual parity decision. Track 04E changes platform/render behavior and Hotfix 04E.1 changes the evidence capture path, so this must not be merged without review.
