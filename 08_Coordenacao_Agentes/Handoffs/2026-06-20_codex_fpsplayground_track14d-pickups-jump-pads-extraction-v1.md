# Handoff - FpsPlayground Track 14D Pickups And Jump Pads Extraction V1

- Status: `READY_FOR_REVIEW`
- Branch: `codex/fpsplayground/track14d-pickups-jump-pads-extraction-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track14d-pickups-jump-pads-extraction-v1`
- Objective: extract pickup and jump pad runtime helper boundaries from `modes/arena/arena_root.gd` without changing approved pickup behavior, jump pad force, map geometry, movement feel, bot route commitment or telemetry fields.
- Intended files: `Projetos/FpsPlayground/modes/arena/*`, `Projetos/FpsPlayground/tests/unit/*`, `Projetos/FpsPlayground/docs/*`, `Projetos/FpsPlayground/implementation/*`, `08_Coordenacao_Agentes/Estado_Atual.md`, `08_Coordenacao_Agentes/Prioridades_Estudio.md`.
- Base docs read: `Prioridades_Estudio.md`, workspace `AGENTS.md`, `Projetos/README.md`, `Estado_Atual.md`, `Projetos/FpsPlayground/AGENTS.md`, `implementation/current-status.md`, `docs/refactor-hardening-roadmap.md`, `docs/architecture-overview.md`, `docs/work-plan.md`, `docs/validation.md`.
- Validation: `git diff --check` PASS; `tools/check_doc_drift.ps1` PASS; `tools/validate.gd` quick/full PASS `59/59`, `552 asserts`.
- Next handoff point: Fabio reviews Track 14D; next recommended implementation track is `Track 14E - Bot Decision Boundary V1`.
