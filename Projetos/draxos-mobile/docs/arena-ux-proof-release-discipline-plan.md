# DraxosMobile - Arena UX Proof And Release Discipline Plan

- Status: `VIVO`
- Last updated: `2026-06-15`
- Scope: next Arena UX/readability/recovery package, human proof gate and release discipline before any new official package.

This plan separates implementation, human validation and publication so the
next Arena package proves the core loop before opening tuning, economy,
content, PVP, final visuals or broad Openworld work.

## Objective

Prepare one narrow Arena candidate that makes this path understandable without
agent explanation:

`login -> find Arena -> tutorial -> first real three-duel arena -> temporary buffs -> final summary -> abandon -> resume/reopen`

The package should answer one question only: can the Arena PVE core be
understood and repeated as the first product loop?

## Work Split

| Type | Owner | Output |
|---|---|---|
| Documentation | Agent | This plan, release gate, pending decision consistency and handoff notes. |
| Implementation | Agent | Arena UX/readability/recovery changes plus interaction smokes. |
| Human proof | Fabio/tester | Playtest evidence and one product verdict in `docs/arena-pve-product-proof.md`. |
| Publication decision | Fabio | Explicit approval to publish, hold, or rework. |

## Required Order

1. Keep the current published package as the baseline in `implementation/current-status.md`.
2. Implement only Arena UX/readability/recovery and tests in a dedicated worktree.
3. Validate locally with the smallest sufficient client/docs/server gates.
4. Produce a candidate for human proof.
5. Run the human proof script in `docs/arena-pve-product-proof.md`.
6. Record the verdict before any official package promotion.
7. Open tuning only if the verdict becomes `ARENA_CORE_READY_FOR_TUNING`.

If a candidate needs a remote preview, that preview is still a remote mutation
and requires explicit approval plus the normal release safety guardrails. A
preview URL or local candidate does not by itself authorize manifest deployment
or a new official package.

## Anti Micro-Release Gate

The next Arena product package must not use the old loop:

`publish official package -> human finds basic UX bug -> publish hotfix -> repeat`

Use this loop instead:

`candidate -> automated validation -> human proof -> verdict -> official package or rework`

Rules:

- Basic navigation, focus, modal, back/Esc, abandon/resume or summary bugs found
  during human proof go back into the same candidate when practical.
- Do not create a new official package for every small UX issue found in proof.
- Do not update release history as a successful package until Fabio approves
  the package path.
- Do not treat a passing smoke as product proof; it only proves the candidate is
  safe enough to play.

## Implementation Boundaries

Allowed in the next implementation package:

- clearer Arena entry from the first visible route;
- tutorial-to-first-real-arena guidance;
- three-duel progress readability;
- temporary buff explanation and next-duel feedback;
- final reward/progress/next-step summary clarity;
- abandon, resume and reopen recovery clarity;
- interaction smokes for the bugs that historically escaped automated tests.

Not allowed without a new explicit decision:

- numeric tuning, economy or reward value changes;
- new content, enemies, spells, weapons, potions or final art;
- PVP or social expansion;
- broad Openworld/Bosque expansion;
- new remote schema, functions, ledger behavior or publication.

## Candidate Acceptance Checklist

Before human proof, the candidate should show evidence for:

| Area | Required evidence |
|---|---|
| Route clarity | Arena is reachable without hunting from the first visible route. |
| Tutorial | Tutorial starts, resolves and points to the first real arena. |
| Unlock | Tutorial completion visibly unlocks/recommends the next step. |
| Run progress | Duel count and current step are visible during a three-duel attempt. |
| Buffs | Buff choice says it is temporary and shows the next-duel effect. |
| Summary | Final summary explains rewards/progress and the next action. |
| Abandon | Abandon is confirmed, clear and unrewarded. |
| Resume | Leaving/reopening does not strand an active attempt. |
| Layout | Android portrait and PC browser stay inside safe frames. |
| Bosque shell | Bosque does not hide or confuse the Arena path. |

## Verdict Handling

After human proof, record exactly one of:

- `ARENA_CORE_READY_FOR_TUNING`
- `ARENA_CORE_NEEDS_UX_FIX`
- `ARENA_CORE_NOT_PROVEN`
- `BOSQUE_SHELL_DISTRACTS`

If the verdict is not `ARENA_CORE_READY_FOR_TUNING`, keep tuning, economy,
content expansion, PVP, visual finalization and broad Openworld work blocked.

## Next Handoff

The next implementation agent should use this plan, `docs/arena-pve-product-proof.md`
and `implementation/current-status.md` as the entry point for the Arena
UX/readability/recovery package.
