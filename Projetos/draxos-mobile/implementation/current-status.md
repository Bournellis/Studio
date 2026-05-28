# DraxosMobile - Current Status

- Last updated: `2026-05-28`
- Project: `draxos-mobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `Behavior, bone dust and potion crafting`
- Active track: `Track 16 - Behavior And Potion Crafting`
- Active track status: `TRACK_16_BEHAVIOR_CRAFTING_ACTIVE`
- Hardening baseline: `Track 13 - Foundation Validation And Release Safety` (`TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`)
- Agent baseline: `Track 14 - Agent Operations Foundation`
- Build channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`

## Baseline

Track 00-15 are integrated on Godot 4.6.2 + Supabase. The project has Android/PC/Web alpha surfaces, email/password account flow, `normal` and `progression_lab` saves, server-authoritative battle, Base/Social/Competition/Shop loops, Progression Lab/Battle Lab, portrait Refugio, fullscreen portrait battle, skip, summary and current-battle logs.

The major foundation baseline is:

- Track 11: live docs, release state, Kanban cleanup, manual walkthrough and first safe `boot.gd` cut.
- Track 12: `boot.gd` decomposed to action contract, account/session flow, surface action flow, battle lifecycle flow and shared surface helpers; current budget is under `1500` lines.
- Track 13: `tools/validate_foundation.ps1`, safe `publish_internal_alpha.ps1` modes, release safety checks, readiness checks and Android/Windows/Web manual gate.
- Track 14: agent operating manual, documentation index, status sync, safe commands and drift guards.
- Track 15: premium internal Android portrait UX for Entry, Refugio, Battle/Summary, Base and Shop without gameplay/backend/economy changes.

## Active Track 16

Track 16 adds the first behavior/crafting/consumable package requested by the user. The package is still local and has not been published remotely.

Current package:

- Ossos are represented as whole numbers in the new scale (`1 Osso atual = 0.01 Osso antigo`) and current economy/content/Progression Lab values were rescaled by `100`.
- `po_osso` was added as a whole-number resource, created by crushing Ossos.
- `pocao_vida` and `craft_pocao_vida` were added to content, crafting state and server-authoritative Edge Functions.
- Save-scoped `crafting/*` and `build/*` endpoints manage crafting, consumable inventory, potion slot and spell/potion behavior.
- Battle simulator supports spell behavior, `consumable_use`, one potion use per slot per battle and five `heal` ticks of `4%` max HP.
- Godot Base/Ossario and Refugio preparation panels expose crafting, potion equip/remove and simple behavior toggles.

## Release Snapshot

| Artifact | Bytes | SHA256 |
|---|---:|---|
| Android APK | `27965106` | `ad6d2579ce003769cfce2536b788c1330abb283d0ae90cc785d1d016ae514ca6` |
| PC Windows ZIP | `36466312` | `ad5fb8351bb001604479d95737fc702bb9b0ff6779afb9e3e31692b7bc189031` |
| Web index | `5442` | `75fdd260b889582cb723256e87ca9867ae35b7cdd3411cbb2ca21ace5585366a` |

Links:

- Supabase remote: `https://armxgipvnbbshzqawklw.supabase.co`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Stable portal: `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Stable Web: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Latest verified preview: `https://b16705ab.draxos-mobile-internal-alpha.pages.dev`

The stable Cloudflare Pages domain is protected by Cloudflare Access. Anonymous public validation should use an unprotected preview or an authenticated Access session.

## Risks And Blocks

- Track 16 is not remotely published; Supabase migrations/functions must be deployed deliberately if this package is promoted.
- Manual Android/Windows/Web walkthrough from Track 13 is still required before remote publication.
- `players.save_type` remains an alpha shortcut. `account_profiles` + `game_saves` is a future migration package.
- Progression/economy remains `REVIEW`; Track 16 only applies the required Osso rescale and first potion baseline.
- Release scripts are safe by default, but a real `Mode Package` with fresh artifacts is still needed before publication becomes routine.

## Next Step

Review Track 16 locally in the normal save: craft Po de Osso, create/equip Pocao de Vida, set behavior and run a battle where the potion triggers. Then run the Track 13 manual walkthrough before any remote publication.

## Validation

Current Track 16 validation:

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
```

Full release/backend validation remains available through `validate_foundation.ps1 -Profile Full -RequireClean:$false` when a gate needs it.

## Read Next

1. `../AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `docs/documentation-index.md`
4. `implementation/tracks/track-16-behavior-crafting/current-status.md`
5. `implementation/tracks/track-16-behavior-crafting/scope.md`
6. `implementation/tracks/track-13-validation-release-safety/release-safety-contract.md`
7. `docs/track-13-manual-walkthrough-gate.md`
