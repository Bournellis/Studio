# FPS Playground Documentation Index

- Last updated: `2026-06-10`
- Status: `TRACK_06A_COMPLETE`

## Purpose

This index is the first stop for agents working on `Projetos/FpsShooter`. The project folder keeps the historical name `FpsShooter`, while the playable identity is `FPS Playground`.

## Read Order

For product, implementation or refactor work:

1. `AGENTS.md`
2. `implementation/current-status.md`
3. `docs/documentation-index.md`
4. `docs/architecture-overview.md`
5. `docs/work-plan.md`
6. `docs/mode-contract.md`
7. `docs/validation.md`
8. `docs/reuse-map.md`
9. The active track under `implementation/tracks/`
10. Touched code and tests

For validation-only work:

1. `implementation/current-status.md`
2. `docs/validation.md`
3. `docs/validation-profiles.md`
4. `tools/validate.gd`
5. Touched tests

For bot work:

1. `docs/bot-contract.md`
2. `docs/mode-contract.md`
3. `gameplay/bot/basic_duel_bot.gd`
4. `modes/arena/arena_root.gd`
5. Bot-related tests

For tuning work:

1. `docs/tuning-guide.md`
2. Active mode root
3. Active gameplay script
4. Smoke checklist in `docs/validation.md`

## Live Documents

| Document | Authority |
|---|---|
| `AGENTS.md` | Local operating rules, boundaries and architecture map. |
| `README.md` | Human-facing project summary and validation command. |
| `implementation/current-status.md` | Current truth, latest baseline and active gate. |
| `docs/work-plan.md` | Track roadmap and future scope boundaries. |
| `docs/reuse-map.md` | What can be reused from other studio projects and what cannot. |
| `docs/validation.md` | Manual and automated validation checklist. |
| `docs/architecture-overview.md` | Current runtime architecture and target boundaries. |
| `docs/mode-contract.md` | Standard contract for playable modes. |
| `docs/bot-contract.md` | Bot behavior, signals, debug and ownership contracts. |
| `docs/tuning-guide.md` | Tuning ownership and where values should live. |
| `docs/validation-profiles.md` | Validation profiles and known warnings. |
| `docs/publication-readiness.md` | Future professional publication checklist. |
| `docs/codebase-audit-track05.md` | Track 05 audit, risks and refactor order. |
| `docs/avatar-visual-contract.md` | Runtime avatar, appearance and animation contract for Futebol visuals. |

## Implementation Tracks

Track history lives in `implementation/tracks/`. Completed tracks are historical baselines, not active instructions, unless current status explicitly points to them.

Latest gameplay track:

- `implementation/tracks/track-06a-avatar-visual-foundation-v1/current-status.md`

## Source Boundaries

| Path | Responsibility |
|---|---|
| `autoloads/` | Input/bootstrap only. |
| `gameplay/combat/` | Health, damage, knockback and shared combat body behavior. |
| `gameplay/player/` | FPS movement, camera, aiming and player fire requests. |
| `gameplay/bot/` | Arena bot decisions, movement, shot requests and debug. |
| `gameplay/avatar/` | Runtime procedural avatar visuals, appearance catalog and presentation-only animation. |
| `gameplay/football/` | Football ball and football bot behavior. |
| `modes/menu/` | Main menu and mode selection. |
| `modes/arena/` | Arena mode composition, map assembly and round authority. |
| `modes/football/` | Football mode composition, field assembly and match authority. |
| `modes/shared/` | Shared mode contracts, primitive builders and mode utilities. |
| `presentation/` | HUD and runtime feedback/audio. |
| `tools/` | Scene generation, validation and local automation. |
| `tests/` | GUT coverage and helpers. |

## Hard Rules

- Do not silently import gameplay, economy, backend or progression systems from other studio projects.
- Do not hand-edit generated `.tscn` files as raw text; update `tools/bootstrap_scene_generator.gd` or source scripts.
- Do not add new gameplay during foundation refactors unless Fabio explicitly asks.
- Preserve accepted feel in both `Arena Shooter` and `Futebol`.
- Keep `tools/validate.gd` green after each logical change.
