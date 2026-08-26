# AGENTS.md

## Metadata

- status: `active`
- authority: `operational_contract`
- last_verified: `2026-08-26`
- review_when: `project boundaries, QA or local coordination change`
- supersedes: `FpsPlayground AGENTS before Governance v2`
- superseded_by: `none`

This file governs agent work inside `Projetos/FpsPlayground`.

## Authority And Entry

1. Read `../../08_Coordenacao_Agentes/Prioridades_Estudio.md` for allowed work.
2. Read `implementation/current-status.md` for the local technical baseline and next technical step.
3. Read `STUDIO_CORE.md` when universe, fiction or shared identity is relevant.
4. Read `08_Coordenacao/README.md`, `08_Coordenacao/TRIAGE.md` and the live local card.
5. Use `docs/documentation-index.md` and `qa/QA_INDEX.md` to select the smallest relevant references and checks.

The portfolio authority may not be redefined locally. Local work queues `global_sync_needed` and does not edit the global snapshot.

## Project Boundary

- PC Windows editor-first first-person arena gameplay laboratory.
- `STUDIO_CORE.md` declares `universe_binding: none`; Studio membership does not adopt shared lore, cosmology or aesthetics.
- Owns the three 1x1 arenas, rifle/Plasma combat, pickups, jump pads, duel flow, local telemetry and route-first bot.
- Football/TPS belongs to `../JogoDaCopa`.
- No export, Web/mobile, multiplayer/backend, progression or Draxos economy is implied.
- Another project's lore or mechanics apply only through an explicit local adoption contract and an intentional binding change.

## Local-First Workflow

- Write in an external worktree and branch `codex/fpsplayground/<slug>`.
- Create project-local cards and handoffs under `08_Coordenacao/`; keep pre-cutover global records as history.
- Use gates v3. `Review` is only for an actual pending human decision, and `Done` cannot contain a pending gate.
- Commit documentation, runtime, QA and coordination changes as separate logical stages.
- Never push, fetch, pull, publish or mutate a remote service.

## Human Authority

Automation does not approve movement feel, weapon feel, bot fairness, map quality or tuning. Record evidence and an exact decision when any of those surfaces needs review.

## Architecture

- `autoloads/`: input/bootstrap.
- `gameplay/`: arena rules, combat, player, bot and local telemetry.
- `modes/menu/`: mode entry; `modes/arena/`: arena composition and duel state.
- `modes/shared/`: runtime primitive creation.
- `presentation/`: HUD and transient feedback.
- `tools/`: deterministic scene generation and validation.
- `tests/`: GUT contracts and regressions.

Generated `.tscn` scenes are owned by `tools/bootstrap_scene_generator.gd`; do not hand-edit them as raw text.

## Engineering Health

- Follow `implementation/technical-debt-baseline.md`.
- Existing files above 1,000 lines cannot grow when touched without extraction or a recorded exception.
- A surgical fix of at most 20 lines is allowed only when it adds no responsibility and includes regression coverage.
- Do not start a mass refactor during unrelated work.

## Validation

Use `qa/qa_manifest.json` through the workspace orchestrator. For direct local runtime validation:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd -- --profile=full
```

Fresh worktrees may need a one-time headless editor import before GUT global classes are available. Validators must leave tracked state unchanged.

Before handoff run the proportional QA profile, `git diff --check` and `git status --short`.

## Hard Stops

Stop on a semantic history conflict, ambiguous generated scene or binary, unexpected generator diff, secret, remote/publication attempt, product/priority change or a human gate requiring Fabio's decision.
