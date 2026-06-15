# Track 03 - Arena Tactical Context Proof V1

- Status: `READY_FOR_HUMAN_SMOKE`
- Started: `2026-06-15`
- Owner: Codex
- Branch: `codex/fpsplayground/track03-arena-tactical-context-proof-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track03-arena-tactical-context-proof-v1`
- Base: Track 02 bot tactical movement approved by Fabio.

## Goal

Prove that the bot tactical movement work is not locked to `Duel Pit V2`.

The project should support at least two playable arena layouts that publish their own tactical context. The bot should receive the active arena context and continue selecting pressure, flank, cover, retreat, health, overcharge, high ground and jump pad routes without code-level dependence on one map.

## Planned Work

1. Document the Track 03 scope, validation and tactical layout contract. DONE
2. Extract arena layout data into a small catalog. DONE
3. Preserve `Duel Pit V2` as the default layout. DONE
4. Add `Relay Foundry V1` as a second arena with distinct geometry and tactical routes. DONE
5. Add arena selection from the main menu. DONE
6. Add automated tests for multi-arena context and selection. DONE
7. Run validation and prepare human smoke instructions. DONE

## Delivered

- `ArenaLayoutCatalog` with `duel_pit_v2` and `relay_foundry_v1`.
- `ArenaRelayFoundryLayoutBuilder` with distinct geometry, cover, platforms, pickups and jump pads.
- `FpsArenaRoot` consuming active layout data for spawns, pickups, jump pads, tactical context and bot arena extent.
- Main menu buttons for `Arena Shooter - Duel Pit V2` and `Arena Shooter - Relay Foundry V1`.
- Tests covering menu selection, layout catalog distinction and runtime bot context in both arenas.

## Acceptance Criteria

- `Duel Pit V2` remains playable and selected by default.
- `Relay Foundry V1` is selectable and playable from the menu.
- Each arena has a distinct tactical context label and tactical point set.
- The bot receives the active arena context after spawn, restart and awareness updates.
- Pickups and jump pads are configured from the active layout.
- Automated validation covers both arena contexts.
- Manual smoke asks Fabio/tester to verify bot movement on both arenas.

## Non-Goals

- New weapons.
- Heavy aim/damage tuning.
- Multiplayer/backend/export/Web/mobile.
- Replacing the Arena Shooter identity or final visual art.

## Validation Plan

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Latest result:

```text
PASS, GUT 20/20, 175 asserts
```

Manual smoke:

- Launch `Arena Shooter - Duel Pit V2`.
- Launch `Arena Shooter - Relay Foundry V1`.
- In both arenas, verify bot pressure, non-repeating route movement, pickups, jump pads, restart with `R`, pause menu and return to menu.

## Handoff

- Human smoke pending.
- Push pending: Fabio via GitHub Desktop (`origin` remote is Fabio-only).
