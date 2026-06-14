# DraxosMobile - Arena PVE Product Proof

- Status: `VIVO`
- Last updated: `2026-06-14`
- Scope: human playtest protocol and product decision gate for Arena PVE.

This document defines how DraxosMobile proves the Arena PVE core before opening
new expansion. It does not approve tuning, PVP, economy changes, new content,
visual finalization or broad Openworld work by itself.

## Purpose

The labs show that the Arena PVE foundation is technically plausible. The next
question is product clarity:

- does a tester understand what to do after login?
- does the tutorial lead naturally into the first real arena?
- does the three-duel run feel like the core loop?
- do buff choice, reward, abandon and resume behave clearly?
- does the loop create enough confidence to tune values rather than change
  direction?

## Required Baseline

Before running this proof:

- no known blocker in account/login/update gate;
- Arena selection can load from server state;
- tutorial can start and finish;
- first real three-duel arena can start after tutorial unlock;
- active attempt recovery, abandon and resume are available;
- Social/Shop/Bosque overlay bugs are not blocking Arena access;
- `DocsOnly`, `ClientQuick` and relevant Arena server tests are either green or
  their failures are explicitly unrelated to the test.

## Human Playtest Script

Use a fresh or intentionally reset normal save.

1. Open the Internal Alpha build and log in.
2. Confirm the first visible route makes Arena reachable without hunting.
3. Open Arena PVE.
4. Start the tutorial arena.
5. Resolve the tutorial duel.
6. Read the summary and use the primary continue path.
7. Confirm the first real three-duel arena is unlocked and recommended.
8. Start the first real arena.
9. Resolve duel 1.
10. Choose one temporary buff.
11. Resolve duel 2.
12. Choose one temporary buff.
13. Resolve duel 3.
14. Confirm final reward/progress summary.
15. Return to Arena selection.
16. Start another attempt, then abandon it.
17. Start another attempt, leave the Arena route, return and resume it.
18. If possible, simulate refresh/reopen and confirm active attempt recovery.

## Observation Checklist

Record each item as `PASS`, `ISSUE` or `BLOCKED`.

| Area | Question |
|---|---|
| First route | Does the player know where Arena is? |
| Arena selection | Is tutorial vs first real arena understandable? |
| Unlock | Does tutorial completion visibly unlock the next step? |
| Start | Is loadout lock explained without extra friction? |
| Duel replay | Does the result feel authoritative and readable enough for alpha? |
| Buff choice | Does the player understand buff is temporary and applies next duel? |
| Run progress | Is duel count/current step clear? |
| Summary | Does final summary explain reward and next step? |
| Reward trust | Does reward feel server-owned, not a separate claim button promise? |
| Abandon | Is abandon clear, confirmed and unrewarded? |
| Resume | Does active attempt recovery avoid stuck states? |
| Layout | Does Android portrait and PC browser stay inside safe frames? |
| Bosque shell | Does Bosque help navigation or distract from Arena core? |

## Evidence To Capture

- build/channel and package pointer from `implementation/current-status.md`;
- tester name or role;
- platform: Web authenticated, Android APK or PC build;
- save type;
- screenshots/video timestamps for each issue;
- final tester sentence: "I think the core loop is..." in their own words;
- list of blockers before any tuning decision.

## Decision Gate

After playtest, choose exactly one next product direction:

| Decision | Meaning | Allowed next work |
|---|---|---|
| `ARENA_CORE_READY_FOR_TUNING` | Loop is understood and playable; issues are numeric/readability. | Focused tuning of `CALIBRAVEL_ALPHA`, anti-stall, duration and reward pacing. |
| `ARENA_CORE_NEEDS_UX_FIX` | Loop direction is right, but UI/recovery/replay blocks clarity. | UX/client fixes only; no economy/content expansion. |
| `ARENA_CORE_NOT_PROVEN` | Tester does not understand or want the loop yet. | Rework Arena flow/readability before any expansion. |
| `BOSQUE_SHELL_DISTRACTS` | Bosque gets in the way of Arena proof. | Freeze/soften Bosque entry and make Arena path more direct. |

Do not choose broad Openworld, PVP, new economy or content expansion from this
proof unless Fabio makes a separate explicit decision.

## Lab Follow-Up

Only after a human result exists:

- compare complaints against Battle Lab and Progression Lab;
- investigate current `REVIEW` items such as long battle rate and anti-stall;
- adjust one variable family at a time;
- rerun labs and a short human spot-check after each tuning package.

## Exit Criteria

Arena PVE is stable enough to continue when:

- one full tutorial -> three-duel run path completes without stuck state;
- abandon/resume/reopen do not strand the save;
- rewards are understandable and not duplicated;
- tester can describe the loop without agent explanation;
- remaining issues are classified as tuning/readability rather than direction.
