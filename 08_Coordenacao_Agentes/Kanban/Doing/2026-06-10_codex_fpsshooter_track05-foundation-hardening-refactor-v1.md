# Codex - FpsShooter Track 05 Foundation Hardening & Refactor V1

- Date: `2026-06-10`
- Agent: `codex`
- Project: `Projetos/FpsShooter`
- Branch: `codex/fpsshooter/track05-foundation-hardening-refactor-v1`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--track05-foundation-hardening-refactor-v1`
- Objective: execute a full documentation, hardening and refactor track for `FPS Playground`, covering both `Arena Shooter` and `Futebol`, while preserving accepted gameplay behavior.

## Base Docs Read

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/FpsShooter/AGENTS.md`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/docs/work-plan.md`
- `Projetos/FpsShooter/docs/reuse-map.md`

## Intended Scope

- Documentation index, architecture overview, codebase audit, mode contract, bot contract, tuning guide, validation profiles and publication readiness.
- Validation/tooling hardening.
- Runtime primitive and tuning foundation extraction.
- Arena/Futebol layout and rule extraction where safe.
- Bot hardening and contract extraction where safe.
- Test suite split and helper extraction.
- Track 05 status and portfolio closeout.

## Validation Plan

- Run the current baseline before edits.
- Run `res://tools/validate.gd` after each logical phase.
- Run `git diff --check` before every commit.
- Commit documentation, tooling, runtime refactor, rules/bot/test hardening and closeout separately.
- Merge into `main` only after final validation passes from the dedicated worktree.

## Handoff Point

- Done note with commit hashes, validation results, residual risks and merge status.
