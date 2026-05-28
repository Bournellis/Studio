# Track 16 - Behavior And Potion Crafting Current Status

- Last updated: `2026-05-28`
- Status: `TRACK_16_BEHAVIOR_CRAFTING_ACTIVE`
- Branch: `codex/draxos-mobile/track-16-behavior-crafting`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--track-16-behavior-crafting`

## Current State

Track 16 is implemented locally on the worktree. This package adds gameplay/economy/backend systems explicitly requested by the user and remains unpublished remotely.

Implemented:

- Integer Osso scale, `po_osso`, content definitions for `pocao_vida` and `craft_pocao_vida`.
- Schema/migration mirrors for consumables, potion slot, spell behavior, item ledger and default potion slot.
- Save-scoped `crafting/*` and `build/*` Edge Functions mirrored in `server/functions` and `supabase/functions`.
- Battle simulator behavior gates for spells, one potion use per battle slot, `consumable_use` and five heal ticks.
- Godot Base/Ossario crafting panel, Refugio preparation panel and replay tolerance for consumable events.
- Economy and Progression Lab models regenerated in the integer Osso scale.

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
