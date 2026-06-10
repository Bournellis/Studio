# JogoDaCopa - Current Status

- Last updated: `2026-06-10`
- Project: `JogoDaCopa`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first TPS football minigames`
- Active stage: `Track 01C - Arena Stadium Visual Rework V1`
- Active stage status: `COMPLETE`
- Status marker: `JOGO_DA_COPA_TRACK_01C_ARENA_STADIUM_VISUAL_REWORK_COMPLETE`
- Studio focus: `TEMPORARY_SOLE_ACTIVE_PROJECT`

## Current Truth

`JogoDaCopa` is the football/TPS project split from the former `Projetos/FpsShooter` workspace. It owns the World Cup-inspired football minigame direction.

The Arena Shooter work moved to `Projetos/FpsPlayground`.

## Current Scope

- PC Windows editor-first.
- Main menu with `Futebol 1x1`.
- Third-person 1x1 football against a bot.
- Match to 3 goals.
- Runtime primitive stadium, closed roofed goals, procedural avatars and synthetic feedback.
- Skin tone and country-inspired shirt selection.
- Loose arcade ball physics with no possession lock, tighter kick assist, higher bounce, air-friendly damping and extra ground-roll grip.
- Closed glass arena with larger field, 20% narrower and 50% taller roofed goals, high glass walls, roof collision, visible glass frames, stadium seating, country-inspired banners, decorative scoreboards and light rigs.
- LMB kick is slightly stronger; RMB strong kick keeps forward punch and now lifts the ball clearly.
- Player speed boost on `Shift` with stamina HUD.
- Football bot attack/defend baseline.
- No FPS arena, no weapons, no shooter combat loop, no export, no Web/mobile, no multiplayer/backend.

## Current Gate

Ready for editor playtest focused on `Futebol 1x1`: roofed goal closure, no high-shot ghost goals, glass arena readability, Copa stadium atmosphere, ball ground grip versus air speed, higher bounce, LMB/RMB shot readability, boost stamina, bot approach and TPS camera readability.

This project is the studio's temporary sole active implementation focus. Other active projects are paused for a few days unless the user explicitly resumes them.

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
7. `implementation/tracks/track-01c-arena-stadium-visual-rework-v1/current-status.md`
8. `implementation/tracks/track-01b-ball-goal-kick-tuning-v1/current-status.md`
9. `implementation/tracks/track-01a-arcade-arena-boost-v1/current-status.md`
