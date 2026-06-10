# JogoDaCopa - Current Status

- Last updated: `2026-06-10`
- Project: `JogoDaCopa`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first TPS football minigames`
- Active stage: `Project Split Foundation V1`
- Active stage status: `COMPLETE`
- Status marker: `JOGO_DA_COPA_PROJECT_SPLIT_FOUNDATION_COMPLETE`

## Current Truth

`JogoDaCopa` is the football/TPS project split from the former `Projetos/FpsShooter` workspace. It owns the World Cup-inspired football minigame direction.

The Arena Shooter work moved to `Projetos/FpsPlayground`.

## Current Scope

- PC Windows editor-first.
- Main menu with `Futebol 1x1`.
- Third-person 1x1 football against a bot.
- Match to 3 goals.
- Runtime primitive stadium, closed goals, procedural avatars and synthetic feedback.
- Skin tone and country-inspired shirt selection.
- Loose arcade ball physics with lightweight possession, dribble nudges and near-front kick assist.
- Football bot attack/defend baseline.
- No FPS arena, no weapons, no shooter combat loop, no export, no Web/mobile, no multiplayer/backend.

## Current Gate

Ready for editor playtest focused on `Futebol 1x1`: camera, possession, dribble nudges, assisted kicks, bot approach and avatar readability.

## Validation

Primary command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Manual smoke lives in `docs/validation.md`.

## Read Next

1. `AGENTS.md`
2. `docs/documentation-index.md`
3. `docs/architecture-overview.md`
4. `docs/work-plan.md`
5. `docs/mode-contract.md`
6. `docs/validation.md`
7. `implementation/tracks/track-00-project-split-foundation-v1/current-status.md`
