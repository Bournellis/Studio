# Codex - FpsPlayground Track 01 Combat Readability Polish V1

- Date: `2026-06-15`
- Agent: `codex`
- Branch: `codex/fpsplayground/track01-combat-readability-polish-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track01-combat-readability-polish-v1`
- Project: `Projetos/FpsPlayground`
- Status: `READY_FOR_HUMAN_SMOKE`

## Objective

Resume `FpsPlayground` after accepted human Arena Shooter regression and improve combat readability in `Duel Pit V2` without expanding scope.

## Intended Files

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/FpsPlayground/implementation/current-status.md`
- `Projetos/FpsPlayground/implementation/tracks/track-01-combat-readability-polish-v1/current-status.md`
- `Projetos/FpsPlayground/docs/work-plan.md`
- `Projetos/FpsPlayground/docs/validation.md`
- `Projetos/FpsPlayground/presentation/feedback/fps_feedback_controller.gd`
- `Projetos/FpsPlayground/presentation/hud/arena_hud.gd`
- `Projetos/FpsPlayground/modes/arena/arena_root.gd`
- `Projetos/FpsPlayground/tests/unit/test_bootstrap.gd`
- `Projetos/FpsPlayground/tests/unit/test_rule_helpers.gd`

## Base Docs Read

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`
- `Projetos/FpsPlayground/AGENTS.md`
- `Projetos/FpsPlayground/implementation/current-status.md`
- `Projetos/FpsPlayground/docs/documentation-index.md`
- `Projetos/FpsPlayground/docs/architecture-overview.md`
- `Projetos/FpsPlayground/docs/work-plan.md`
- `Projetos/FpsPlayground/docs/mode-contract.md`
- `Projetos/FpsPlayground/docs/validation.md`

## Validation Plan

- Baseline: `tools/validate.gd`
- Final: `tools/validate.gd`
- Final hygiene: `git diff --check`, `git status --short`
- Manual smoke to be executed by Fabio/tester from `Projetos/FpsPlayground/docs/validation.md`

## Guardrails

- No football/TPS scope.
- No new weapon, new map, export, Web/mobile, multiplayer or backend.
- Preserve `Duel Pit V2` combat contract and arena flow.
- Prefer localized feedback/HUD polish over broad tuning.

## Next Handoff Point

Human smoke focused on whether combat events are easier to understand.

## Delivered

- HUD event colors/messages for bot tell, player damage, Plasma hit and overcharge hit.
- Health/overcharge pickup halos and beacons.
- Jump pad launch direction cues.
- Focused GUT coverage for readability nodes and HUD event contracts.

## Validation

- Baseline: after one-time fresh worktree import, `tools/validate.gd` PASS, GUT `14/14`, `95` asserts.
- Final: `tools/validate.gd` PASS, GUT `15/15`, `118` asserts.
- Known noise: GUT UID/text-path fallback warnings.
