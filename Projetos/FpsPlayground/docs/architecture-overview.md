# FpsPlayground Architecture Overview

## Metadata

- status: `active`
- authority: `technical_contract`
- last_verified: `2026-07-17`
- review_when: `module ownership or dependency direction changes`
- supersedes: `none`
- superseded_by: `none`

`FpsPlayground` is the FPS-only project after the split from `FpsShooter`.

## Ownership

- `modes/menu/`: project entry and Arena Shooter launch.
- `modes/arena/`: arena assembly, round state, combat pipeline helpers, projectile runtime helpers, pickup/jump pad rules, player shot resolution, bot shot resolution, pickups and HUD snapshot/status building.
- `modes/shared/`: runtime primitive creation.
- `gameplay/player/`: first-person player controller, camera, rifle and Plasma Bolt requests.
- `gameplay/combat/`: combatant health, damage and knockback.
- `gameplay/bot/`: arena duel bot, decision model, movement execution helpers, deterministic aim and visibility helpers.
- `gameplay/arena/`: pure arena rule helpers.
- `gameplay/telemetry/`: local arena event recording, event facade and readout analysis.
- `presentation/hud/`: arena HUD and transient feedback state helpers.
- `presentation/feedback/`: primitive effects and synthetic audio.
- `tools/`: scene generation and validation.
- `tests/`: GUT coverage for arena and helper contracts.

## Boundary

Football/TPS minigames are not part of this project. They live in `../JogoDaCopa`.

## Current Risk Areas

- `modes/arena/arena_root.gd` remains the largest runtime authority object.
- Track 14B moved HUD snapshot/status building into `modes/arena/arena_hud_snapshot_builder.gd`.
- Track 14C moved combat telemetry payload construction and pure Plasma blast math into `modes/arena/arena_combat_pipeline.gd`.
- Track 14D moved pickup state/respawn and jump pad cooldown/launch math into `modes/arena/arena_pickup_jump_pad_rules.gd`.
- Track 14E moved bot item priority, tactical scoring and route-hold checks into `gameplay/bot/bot_decision_model.gd`.
- Track 14F removed dead private wrappers left after the bot decision extraction and recorded the post-hardening code-size baseline.
- Track 14G moved bot movement execution helpers, projectile runtime, HUD feedback state and telemetry event emission into focused helpers.
- `gameplay/bot/basic_duel_bot.gd` still owns bot state, physics integration, aim execution and combat overlay.
- `tests/unit/test_bootstrap.gd` is valuable but broad; future refactors should keep the coverage while moving new tests into narrower files when practical.
- Future weapons, buffs and pickup rules should be planned before adding more combat branches to `arena_root.gd`.
- Telemetry should stay local and gameplay-neutral unless a future analytics track explicitly changes that.

## Future Direction

- Keep layout builders responsible for geometry.
- Keep bot behavior driven by arena tactical context, not map ids.
- Keep combat role contracts testable before adding new weapon inputs or UI.
- Prefer small extraction tracks when `arena_root.gd` receives a new responsibility.
- Follow `work-plan.md` for authorized sequencing and `../implementation/technical-debt-baseline.md` when a planned change touches a hotspot.
