# DraxosMobile - Current Status

- Last updated: `2026-05-28`
- Project: `draxos-mobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `Foundation Audit`
- Active stage: `Foundation Audit`
- Active stage status: `FOUNDATION_AUDIT_ACTIVE`
- Hardening baseline: `Track 13 - Foundation Validation And Release Safety` (`TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`)
- Agent baseline: `Track 14 - Agent Operations Foundation` (`TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`)
- Latest technical package: `Track 16 - Behavior And Potion Crafting` (local, not current product focus)
- Build channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`

## Baseline

Track 00-15 are integrated on Godot 4.6.2 + Supabase. Track 16 is the latest local technical package and has not been promoted as the current product focus.

The implemented base includes Android/PC/Web alpha surfaces, email/password account flow, `normal` and `progression_lab` saves, server-authoritative battle, Base/Social/Competition/Shop loops, Progression Lab/Battle Lab, portrait Refugio, fullscreen portrait battle, skip, summary and current-battle logs.

Current product reading: this is a strong prototype base for refinement. Names, spells, weapons, economy values, Battle Pass, battle flavor, visual identity and premium content are mock/substance used to keep the app from feeling empty, not final design direction.

Immediate loop under audit:

`Base -> collect resources -> evolve base -> battle -> receive rewards -> check base again`

The major foundation baseline is:

- Track 11: live docs, release state, Kanban cleanup, manual walkthrough and first safe `boot.gd` cut.
- Track 12: `boot.gd` decomposed to action contract, account/session flow, surface action flow, battle lifecycle flow and shared surface helpers; current budget is under `1500` lines.
- Track 13: `tools/validate_foundation.ps1`, safe `publish_internal_alpha.ps1` modes, release safety checks, readiness checks and Android/Windows/Web manual gate.
- Track 14: agent operating manual, documentation index, status sync, safe commands and drift guards.
- Track 15: premium internal Android portrait UX for Entry, Refugio, Battle/Summary, Base and Shop without gameplay/backend/economy changes.
- Track 16: behavior, Po de Osso and potion crafting package; local and not remotely published.

## Foundation Audit

Foundation Audit is the active stage. It must align documents and then audit the internal post-login loop before implementation expands.

Priority order after the docs are aligned:

1. Internal loop ergonomics.
2. Social.
3. General visual direction.
4. Battle presentation.
5. Weapons, spells, economy, balance and content details.

No new code, schema, backend, asset, gameplay or balance work belongs to this documentation alignment package.

## Latest Technical Package

Track 16 added the first behavior/crafting/consumable package requested by the user. The package is still local and has not been published remotely.

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

- Track 16 is not remotely published; Supabase migrations/functions must be deployed deliberately if this package is promoted later.
- Foundation Audit must complete before implementation expansion.
- Manual Android/Windows/Web walkthrough from Track 13 is still required before remote publication.
- `players.save_type` remains an alpha shortcut. `account_profiles` + `game_saves` is a future migration package.
- Progression/economy remains mock/substance and not the current tuning focus.
- Release scripts are safe by default, but a real `Mode Package` with fresh artifacts is still needed before publication becomes routine.

## Next Step

Complete Foundation Audit documentation alignment, then audit the post-login loop in the app: collect resources, upgrade base, battle, receive rewards and return to/check base again.

## Validation

Documentation/foundation validation for this stage:

```powershell
git diff --check
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick -RequireClean:$false
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_agent_ops_foundation.ps1 -ProjectDir .
```

Full release/backend validation remains available through `validate_foundation.ps1 -Profile Full -RequireClean:$false` when a gate needs it.

## Read Next

1. `../AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `docs/documentation-index.md`
4. `docs/foundation-app-v0-audit.md`
5. `docs/product-vision.md`
6. `docs/product-brief.md`
7. `docs/design-pending.md`
