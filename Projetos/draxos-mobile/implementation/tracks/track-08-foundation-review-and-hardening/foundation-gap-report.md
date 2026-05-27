# Track 08 - Foundation Gap Report

- Date: `2026-05-27`
- Baseline: Track 07 `INTEGRATED_PRESENTATION_READY`

## Summary

The foundation is good enough to support the next evolution, but the post-Track 07 app now needs explicit contracts so future agents do not rediscover or fork behavior in separate places.

Track 08 should harden existing behavior rather than add capability. The main risk is structural drift: routes, touch rules, session/save assumptions, battle fullscreen lifecycle and validation commands are all correct enough now, but not yet difficult to break.

## Gaps To Address

| Area | Current Signal | Risk | Track 08 Response |
|---|---|---|---|
| App shell lifecycle | Routes/back/orientation live in `boot.gd` and tests | Future surfaces may add route behavior inconsistently | Small route contract/helper plus focused GUT |
| Session/save boundary | `SessionStore` handles normal/Lab/cache/runtime config | UI may treat local-only or fallback config as online state | Non-secret diagnostics and invariant tests |
| Mobile UI contract | Touch scroll exists and buttons use helper | Future buttons/scroll panels may regress drag/tap behavior | Centralize reusable constants/helpers and tests |
| Battle mode | Fullscreen battle/summary works | Future battle changes may reintroduce app chrome or unsafe replay behavior | Explicit battle mode contract coverage |
| Service contracts | Endpoint scopes documented | New endpoints/features may skip registry or scope fields | Lightweight docs/contract checks |
| Assets | `AssetIds` fallback exists and Asset Pack 01 installed | Real assets may accidentally become required | Asset id/fallback checks stay in validation |
| Validation | Many smokes exist | Agents may miss the right combination | Track 08 hardening smoke + quick/full/release matrix |

## Non-Goals

- No broad `boot.gd` rewrite.
- No schema migration.
- No new endpoint.
- No tuning.
- No final assets.
- No remote publication.

## Recommended Execution

1. Open T08-A and merge it to master.
2. Run T08-B, T08-C, T08-D and T08-F in parallel.
3. Run T08-E after T08-B.
4. Run T08-G after B-F.
5. Integrate in T08-H and mark the project ready for the next feature/assets/services track.
