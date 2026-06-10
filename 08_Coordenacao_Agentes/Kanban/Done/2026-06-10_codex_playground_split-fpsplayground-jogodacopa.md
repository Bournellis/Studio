# Codex - Playground Split FpsPlayground / JogoDaCopa

- Date: `2026-06-10`
- Agent: `codex`
- Branch: `codex/playground/split-fpsplayground-jogodacopa`
- Worktree: `D:\Estudio-worktrees\Playground--codex--split-fpsplayground-jogodacopa`
- Status: `DONE`

## Objective

Split the former `Projetos/FpsShooter` tech probe into two official Godot projects:

- `Projetos/FpsPlayground`: FPS laboratory preserving the accepted Arena Shooter baseline.
- `Projetos/JogoDaCopa`: football/minigames project preserving the accepted third-person `Futebol` baseline.

## Delivered

- Renamed the old implementation folder to `Projetos/FpsPlayground`.
- Created `Projetos/JogoDaCopa` from the accepted football branch of the same codebase.
- Removed football/TPS surface from `FpsPlayground`.
- Removed Arena Shooter/FPS surface from `JogoDaCopa`.
- Updated menus, bootstrap generation, validation scripts, tests and local docs for each project.
- Updated portfolio routing in `AGENTS.md`, `Prioridades_Estudio.md`, `Estado_Atual.md` and `Projetos/README.md`.

## Validation

- `Projetos/FpsPlayground/tools/validate.gd`: PASS, 14/14 GUT tests passing.
- `Projetos/JogoDaCopa/tools/validate.gd`: PASS, 22/22 GUT tests passing.
- `Projetos/JogoDaCopa` required one headless editor import before validation because it is a fresh Godot project copy.
- Godot reported non-blocking GUT UID/text-path warnings in both project validations.

## Next Step

- `FpsPlayground`: editor regression playtest of Arena Shooter.
- `JogoDaCopa`: editor playtest of `Futebol` and planning the next football minigame/gameplay track.
