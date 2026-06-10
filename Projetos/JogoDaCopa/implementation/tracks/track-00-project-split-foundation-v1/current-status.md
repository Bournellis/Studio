# Track 00 - Project Split Foundation V1

- Last updated: `2026-06-10`
- Status: `COMPLETE`
- Status marker: `JOGO_DA_COPA_PROJECT_SPLIT_FOUNDATION_COMPLETE`

## Goal

Create `JogoDaCopa` as the TPS football minigame successor of the former football mode inside `FpsShooter`.

## Delivered

- Project folder created at `Projetos/JogoDaCopa`.
- Arena Shooter/FPS arena files removed from the active project surface.
- Main menu now launches only `Futebol 1x1`.
- Scene generation and validation now target menu + football only.
- GUT coverage now focuses on football scene assembly, avatar, ball control, kick assist, camera, scoring and football rule contracts.
- Local docs updated for the split.

## Validation

- `tools/validate.gd`: PASS on 2026-06-10, 22/22 GUT tests passing.
- A one-time headless editor import was required before validation because this is a fresh Godot project copy.
- Godot reported non-blocking GUT UID/text-path warnings during validation in the fresh split worktree.
