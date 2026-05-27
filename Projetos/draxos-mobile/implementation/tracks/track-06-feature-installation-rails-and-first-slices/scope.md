# Track 06 - Feature Installation Rails And First Feature Slices

- Status: `ACTIVE_FEATURE_INSTALLATION`
- Started: `2026-05-27`
- Depends On: `T05_INTEGRATED_FOUNDATION_READY`

## Goal

Install the first visible feature slices on top of the Track 05 foundation without making tuning the priority.

Track 06 creates the standard rails for future feature work and then installs a small set of low-risk vertical slices: runtime config, profile/account, battle history, Base routine, Social quality-of-life and the first safe visual asset pack.

## In Scope

- Official feature installation contract and registry.
- Runtime config endpoint and client read path for feature flags.
- Profile/account panel using existing session/account state.
- Battle history and replay read-only flow for saved battles.
- Base routine panel using existing Base payloads.
- Social QoL for friends, guild and chat readability.
- First small asset pack through `AssetIds`, with fallback still valid.
- Integration against the Track 05 validation matrix and new smokes/tests.

## Out Of Scope

- Economy, power, reward, bot, shop or combat tuning.
- Migration to `account_profiles` + `game_saves`.
- Payment real, iOS, mobile browser, realtime social or remote publication.
- New gameplay modes or broad visual rework.
- Client-authoritative gameplay, rewards, resources or ranking.
- Schema changes unless a feature documents a blocker and stops for decision.

## Guardrails

- Keep `players.save_type` in the short term.
- Keep Supabase as the alpha backend.
- New endpoints must declare Track 05 service scope: `release`, `save-scoped`, `account-scoped`, `telemetry` or `admin-future`.
- Runtime config must not expose secrets, service-role data or mutable gameplay state.
- Battle history/replay must not reapply rewards or rerun the simulator.
- Client presenters stay render-oriented; actions, session, network and telemetry remain owned by the Hub orchestration unless explicitly documented.
- Missing art must remain allowed for all asset hooks.

## Completion Criteria

- Track 06 docs, Kanban entry and portfolio status are current.
- Feature rails define owner, surface, endpoints, service scope, validation, fallback and rollback.
- Runtime config is available as a release-scoped read-only service and covered by smoke/GUT.
- Profile/account, battle history, Base routine, Social QoL and asset pack slices are installed with focused coverage.
- Integration validates Track 05 matrix plus new T06 smokes/tests.
- Status documents make clear that no tuning, account/save migration or remote publication happened in Track 06.
