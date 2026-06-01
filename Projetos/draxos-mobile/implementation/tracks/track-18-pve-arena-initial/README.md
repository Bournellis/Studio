# Track 18 - PVE Arena Initial

- Status: `ACTIVE`
- Started: `2026-05-31`
- Branch: `codex/draxos-mobile/pve-arena-integration`
- Base: Foundation Final Polish plus `PVE_ARENA_INITIAL_DIRECTION_APPROVED`

## Objective

Make DraxosMobile start as a PVE Arena-first async autobattler: tutorial of 1 duel, first real arenas of 3 duels, locked loadout, temporary stat buffs, HP reset per duel, no combat cooldown, and PVP reserved for a later competitive package.

## Workstreams

- Contracts/content: Arena PVE docs, API/content contracts and data definitions.
- Backend: arena attempts, steps, progress, transactional rewards and Edge Functions.
- Client/labs: Arena shell, session state, Supabase client methods, Battle Lab and Progression Lab modeling.
- Validation/release: integration matrix, local gates and Internal Alpha package plan.

## Non-Goals

- PVP as initial core.
- Combat cooldowns.
- HP survival between duels.
- New final assets, weapons, spells or potions.
- Advanced enemy-specific behavior or custom thresholds.
- Remote publication without explicit approval and `-ConfirmRemoteMutation`.

## Acceptance

- Arena PVE tutorial and first 3-duel arena are playable through the client shell.
- Arena PVE rewards/progress are server-authoritative and idempotent.
- PVE Arena never mutates ranking.
- Labs can report arena clear rate, step failure and early progression pressure.
- Full local validation gate is green or any blocker is documented with exact command output and next action.

## Validation Reference

Use `validation-matrix.md` as the Track 18 acceptance and manual playtest source.
