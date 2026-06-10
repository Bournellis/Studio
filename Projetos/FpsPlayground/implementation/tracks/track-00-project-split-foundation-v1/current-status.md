# Track 00 - Project Split Foundation V1

- Last updated: `2026-06-10`
- Status: `COMPLETE`
- Status marker: `FPS_PLAYGROUND_PROJECT_SPLIT_FOUNDATION_COMPLETE`

## Goal

Create `FpsPlayground` as the FPS-only successor of the former `FpsShooter` tech probe.

## Delivered

- Project folder moved to `Projetos/FpsPlayground`.
- Football/TPS files removed from the active project surface.
- Main menu now launches only `Arena Shooter`.
- Scene generation and validation now target menu + arena only.
- GUT coverage now focuses on arena scene assembly, FPS input, combat, pickups, bot and helper contracts.
- Local docs updated for the split.

## Validation

- `tools/validate.gd`: PASS on 2026-06-10, 14/14 GUT tests passing.
- Godot reported non-blocking GUT UID/text-path warnings during validation in the fresh split worktree.
