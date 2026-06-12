# Track 04F.2 - WebGL First-Render Stall V1

- Status: `REVIEW_READY_WITH_RESIDUAL`
- Branch: `codex/jogodacopa/track04f2-webgl-first-render-stall-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04f2-webgl-first-render-stall-v1`
- Goal: eliminate the first WebGL render/upload stall when entering the match in Chrome local first visit.

## Baseline A

- Evidence: `docs/playtest-reports/track-04f-data/04f2-a-baseline-web-click-materials.json`
- Chrome first-visit click path: p50 `6.9ms`, p95 `7.0ms`, p99 `13.9ms`, max `18829.1ms`, `5` hitches > `50ms`.
- Load timeline: `menu.play_pressed` at `3117.1ms`, `football.ready.begin` at `3478.3ms`, `football.spawn_runtime.end` at `4295.8ms`, `football.restart_play_initial.begin` at `22472.7ms`, `football.ready.end` at `22635.4ms`.
- Material count: `467` meshes, `467` material refs, `467` unique materials, `331` StandardMaterial3D refs, `136` ShaderMaterial refs, `24` variants.
- Highest duplication categories: estandes `124` unique Standard materials, torcida `114` unique ShaderMaterial refs, banners `88` unique materials, neon `54` unique materials, vidro `43` unique materials.

## Result

- B1 retained: material/mesh sharing reduced unique materials `467 -> 79`; Chrome ready after Play `19.52s -> 8.81s`.
- C7 retained: incremental first-render warmup keeps core field/ball/avatar plus first two glass nodes under overlay, defers remaining decorative arena in background.
- Final retained evidence: `docs/playtest-reports/track-04f-data/04f2-c7-core-glass-prefetch-web-click.json`.
- Final loading result: overlay after Play `4.23s`; max frame in Play -> overlay window `972.4ms`; PCK `26.43 MiB`; `validate.gd` full PASS (`86/86`, `1264` asserts); Web export PASS.
- Reverted by measurement: crowd MultiMesh, threaded scene load, unit BoxMesh scaling, stand/skyline MultiMesh, full pre-overlay arena warmup, VFX cache, VFX explicit warmup, GPUParticles pool, silent audio warmup.
- Residual: 120s post-warmup smoothness still FAILs on first-use VFX/audio (`event.confetti_vfx` `1298.8ms`, `event.kick_vfx` `1132.0ms`). Recommended follow-up: Track 04F.3 or review decision on VFX/audio first-use.

## Handoff

- Report: `docs/playtest-reports/track-04f2-webgl-stall.md`
- Awaiting Claude pre-merge review before main merge.
