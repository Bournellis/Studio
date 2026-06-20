# FpsPlayground - Track 14G Surgical Expansion Hardening V1

- Status: `IN_PROGRESS`
- Branch: `codex/fpsplayground/track14g-surgical-expansion-hardening-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track14g-surgical-expansion-hardening-v1`
- Objective: execute surgical hardening around bot movement, projectile runtime, HUD feedback and telemetry events before the next gameplay evidence track.
- Intended files: `Projetos/FpsPlayground/gameplay/bot/*`, `Projetos/FpsPlayground/modes/arena/*`, `Projetos/FpsPlayground/presentation/hud/*`, `Projetos/FpsPlayground/tests/unit/*`, local docs/status.
- Base docs read: workspace `AGENTS.md`, `Prioridades_Estudio.md`, `Projetos/README.md`, `Estado_Atual.md`, `Projetos/FpsPlayground/AGENTS.md`, `implementation/current-status.md`, `docs/refactor-hardening-roadmap.md`.
- Validation plan: `git diff --check`; quick Godot validation after each code stage; full Godot validation and doc drift check at closeout.
- Guardrail: no gameplay, movement feel, jump pad force, map geometry, weapon value, pickup, bot decision or telemetry schema change.
- Next handoff point: Track 14G local validated; next gameplay step remains `Multi-Arena Balance Baseline V1`.
