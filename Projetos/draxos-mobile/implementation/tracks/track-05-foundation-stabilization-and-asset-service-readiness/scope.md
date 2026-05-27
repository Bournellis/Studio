# Track 05 - Foundation Stabilization And Asset/Service Readiness

- Status: `ACTIVE_FOUNDATION_STABILIZATION`
- Started: `2026-05-27`
- Depends On: `T04_A_TO_H_INTEGRATED`

## Goal

Stabilize the DraxosMobile foundation before real assets and new services enter implementation.

Track 05 is not a product expansion track. It prepares the project to accept assets and service work safely by consolidating validation, Hub ownership, operational contracts, asset readiness, release readiness and the Progression Lab human review pack.

## In Scope

- Official quick/full/release/remote validation matrix.
- Focused smokes for Base, Shop, Social and Competition when missing.
- Hub/presenter foundation hardening without changing behavior.
- Service scope documentation for current endpoints and future endpoints.
- Asset pipeline conventions and tests without final art.
- Progression Lab human runbook and tuning decision criteria.
- Release ops checklist for manifest, exports and publication readiness.
- Integration and status updates for Track 05.

## Out Of Scope

- Real assets or final art import.
- New gameplay modes or expanded product scope.
- Economy, power, reward, bot, shop or combat number changes.
- Payment real, monetization production, iOS or mobile browser.
- Migration to `account_profiles` + `game_saves`.
- Backend Proprio implementation.
- New gameplay services beyond validation/contract hardening.

## Guardrails

- Keep `players.save_type` for this track.
- Keep Supabase as the alpha backend.
- Keep client non-authoritative for battle, rewards, resources, ranking and economy.
- Do not mix Hub refactors with schema/backend changes.
- Every endpoint touched by docs/tests must declare whether it is `save-scoped`, `account-scoped`, `release`, `telemetry` or `admin-future`.
- Every asset hook must keep fallback behavior working when art is missing.

## Completion Criteria

- Track 05 docs and portfolio status are current.
- Quick/full/release validation matrix is documented and executable.
- Focused smokes exist or are explicitly justified as covered elsewhere.
- Hub/presenter ownership is stable and tested.
- Asset pipeline is ready for real files without requiring art now.
- Service scope rules are documented without schema migration.
- Progression human pack is ready to run before tuning.
- Release ops checklist is documented without publishing.
- Final integration validates green and updates status.
