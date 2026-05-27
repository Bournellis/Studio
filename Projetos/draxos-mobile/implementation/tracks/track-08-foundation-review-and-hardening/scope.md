# Track 08 - Foundation Review And Hardening

- Status: `ACTIVE_FOUNDATION_HARDENING`
- Started: `2026-05-27`
- Depends On: `T07_INTEGRATED_PRESENTATION_READY`

## Goal

Harden the post-Track 07 foundation before installing larger features, assets or services.

Track 08 turns the current mobile-first shell, session/save handling, input/layout behavior, battle mode, validation harness and contracts into a stable base for future tracks. It is a moderate hardening pass, not a rewrite.

## In Scope

- Internal route, back stack and orientation contract.
- Session/save/cache/runtime-config invariants and non-secret diagnostics.
- Touch, scroll, button target and portrait/landscape UI contract.
- Battle/replay as a fullscreen landscape gameplay mode with safe skip, summary and return flow.
- Lightweight contract checks for endpoint scopes, feature registry and asset ids/fallback.
- New foundation hardening smoke and updated validation matrix.
- Track docs, Kanban, agent registry and portfolio snapshots.

## Out Of Scope

- New gameplay, economy, reward, ranking, shop, bot, power or combat tuning.
- New public backend endpoint, Supabase schema or migration.
- `account_profiles` + `game_saves` migration.
- Payment real, iOS, mobile browser as a primary target, social realtime or remote publication.
- Final asset imports or broad visual rework.
- Large split of `boot.gd`; only small helpers are allowed when low risk and testable.

## Completion Criteria

- Track 08 docs, registry, prompts, gap report and portfolio snapshots are current.
- App shell route/back/orientation behavior is covered by explicit contract tests.
- Session/save/cache/runtime config boundaries are covered by focused tests without exposing secrets.
- Mobile touch/layout rules are centralized enough for future surfaces to reuse.
- Battle fullscreen mode has contract coverage for skip, summary, replay/history and return to Refugio.
- Contract checks catch missing endpoint scopes, incomplete feature cards and asset id/fallback regressions where cheap.
- Final integration passes the Track 08 validation matrix.
