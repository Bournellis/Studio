# Track 04F.2 - WebGL First-Render Stall V1

- Status: `IN_PROGRESS`
- Branch: `codex/jogodacopa/track04f2-webgl-first-render-stall-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04f2-webgl-first-render-stall-v1`
- Goal: eliminate the first WebGL render/upload stall when entering the match in Chrome local first visit.

## Baseline A

- Evidence: `docs/playtest-reports/track-04f-data/04f2-a-baseline-web-click-materials.json`
- Chrome first-visit click path: p50 `6.9ms`, p95 `7.0ms`, p99 `13.9ms`, max `18829.1ms`, `5` hitches > `50ms`.
- Load timeline: `menu.play_pressed` at `3117.1ms`, `football.ready.begin` at `3478.3ms`, `football.spawn_runtime.end` at `4295.8ms`, `football.restart_play_initial.begin` at `22472.7ms`, `football.ready.end` at `22635.4ms`.
- Material count: `467` meshes, `467` material refs, `467` unique materials, `331` StandardMaterial3D refs, `136` ShaderMaterial refs, `24` variants.
- Highest duplication categories: estandes `124` unique Standard materials, torcida `114` unique ShaderMaterial refs, banners `88` unique materials, neon `54` unique materials, vidro `43` unique materials.

## Next

- 04F2-B: consolidate material/mesh duplication and measure each optimization in isolation. Revert any change that fails to improve the measured stall.
