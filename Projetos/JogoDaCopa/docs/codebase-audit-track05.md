# JogoDaCopa Codebase Audit

The Track 05 hardening work remains useful as historical context, but `JogoDaCopa` is now a smaller football-only project after the split.

## Current Risk Areas

- `modes/football/football_root.gd` owns many responsibilities and should be split further as football grows.
- The local player still reuses the old movement/input controller.
- Character visuals are procedural primitives, not final art.
- Export readiness is not active.

## Current Strengths

- Scene generation is deterministic.
- Validation is local and fast.
- Historical note: Football rules, avatar behavior, camera focus and the earlier possession/kick assist pass had focused coverage before the later arcade arena direction removed possession lock.
