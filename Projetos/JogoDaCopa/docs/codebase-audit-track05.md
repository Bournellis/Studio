# JogoDaCopa Codebase Audit

This document is a historical Track 05 audit. Keep it as context for why the Web hardening work happened; do not use it as the current project status. Current status lives in `../implementation/current-status.md`, and publication history lives in `release-history.md`.

## Historical Risk Areas That Still Matter

- `modes/football/football_root.gd` owns many responsibilities and should be split further as football grows.
- The local player still reuses the old movement/input controller.
- Legacy `Fps*` naming remains in reused player/combat/feedback classes and should be renamed or wrapped gradually.
- Web performance remains release-critical; every release still needs the Web export, first-minute and stability gates.

## Historical Strengths Still Valid

- Scene generation is deterministic.
- Validation is local and broad.
- Historical note: Football rules, avatar behavior, camera focus and the earlier possession/kick assist pass had focused coverage before the later arcade arena direction removed possession lock.

## Superseded Notes

- Character visuals are no longer only procedural primitives: the current game uses real Quaternius skinned humanoids with UAL animation clips.
- Export readiness is active: the public Web surface is published through Cloudflare Pages and tracked in `publication-readiness.md` and `release-history.md`.
