# Track 16 - Behavior And Potion Crafting Current Status

- Last updated: `2026-05-29`
- Status: `HISTORICO_IMPLEMENTADO_COMO_BASE_TECNICA`
- Branch: `codex/draxos-mobile/track-16-behavior-crafting`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--track-16-behavior-crafting`

## Current State

Track 16 added gameplay/economy/backend systems explicitly requested by the user. It is no longer the active product focus, but its systems are part of the current alpha baseline.

Current live reference: `docs/behavior-potion-crafting-v1.md`.

Publication state after later packages:

- Ossos Inteiros v1 promoted the required Track 16 migration/functions/catalog subset to the remote Internal Alpha baseline.
- Battle Preparation Complete v1 exposes potion equip/remove and simple behavior controls in the Refugio Preparation panel.
- Progression Clarity v1 sits on top of the same data without changing backend/schema/tuning/content.

Implemented:

- Integer Osso scale, `po_osso`, content definitions for `pocao_vida` and `craft_pocao_vida`.
- Schema/migration mirrors for consumables, potion slot, spell behavior, item ledger and default potion slot.
- Save-scoped `crafting/*` and `build/*` Edge Functions mirrored in `server/functions` and `supabase/functions`.
- Battle simulator behavior gates for spells, one potion use per battle slot, `consumable_use` and five heal ticks.
- Godot Base/Ossario crafting panel, Refugio preparation panel and replay tolerance for consumable events.
- Economy and Progression Lab models regenerated in the integer Osso scale.

Still blocked without explicit package decision:

- new potions or consumables;
- broad numeric tuning;
- custom thresholds;
- spell priorities;
- enemy-specific behavior;
- bots using potions by default;
- crafting expansion beyond the first slice.

## Validation

```powershell
npx -y deno task --cwd server/functions check
npx -y deno task --cwd supabase/functions check
npx -y deno test --allow-read server/tests/first_slice_simulator_test.ts
npx -y deno test tools/progression_lab
npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { .\tools\validate_foundation.ps1 -ProjectDir . -Profile Client -RequireClean:`$false }"
git diff --check
git status --short
```

All validation commands above passed locally on 2026-05-28. Godot/GUT emitted the existing UID/orphan warnings but finished with all tests passing.

Later publication and remote validation are recorded in `implementation/current-status.md` under Ossos Inteiros v1 and Battle Preparation Complete v1.
