# DraxosMobile - Current Status

- Last updated: `2026-05-28`
- Project: `draxos-mobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `Foundation Audit`
- Active stage: `Foundation Audit`
- Active stage status: `FOUNDATION_AUDIT_ACTIVE`
- Hardening baseline: `Track 13 - Foundation Validation And Release Safety` (`TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`)
- Agent baseline: `Track 14 - Agent Operations Foundation` (`TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`)
- Latest technical package: `Track 16 - Behavior And Potion Crafting` (technical context, not current product focus)
- Build channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`

## Baseline

Track 00-15 are integrated on Godot 4.6.2 + Supabase. Track 16 is the latest technical package and has not been promoted as the current product focus.

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
- Track 16: behavior, Po de Osso and potion crafting package; technical context and not current product focus.

## Foundation Audit

Foundation Audit is the active stage. It must align documents and then audit the internal post-login loop before implementation expands.

Documentation alignment is complete, and the first loop audit is recorded in `docs/foundation-loop-audit.md`. The audit conclusion was: the foundation exists technically, but the V0 UX needed a focused pass so the player always understands the next post-login action.

Foundation Loop UX Pass 01 is implemented and published to the Internal Alpha artifact/site channel from branch `codex/draxos-mobile/foundation-loop-ux-pass`. It makes Refugio the operational loop home, adds a visible loop panel, separates unseen battle rewards from old battle history, removes confirmation from routine collection, changes the battle summary return to `Voltar e verificar base`, marks battle results as seen on return, and adds the no-network smoke `tools/smoke_foundation_loop.gd`.

Foundation Responsive Guardrails were applied and published on `2026-05-28` after manual review found the published Web/APK layout clipping Entry tools, Refugio and Battle. The hotfix restores Entry Labs in Internal Alpha, moves Refugio/Battle immersive UI into safe frames, and adds `docs/foundation-responsive-layout-contract.md` plus `tools/smoke_responsive_layout.gd`. The publication used public unlisted APK/PC Storage URLs so mobile downloads do not hit the protected Bearer-token endpoint.

Follow-up refuge/battle hotfixes were published on `2026-05-28` from branch `codex/draxos-mobile/foundation-responsive-guardrails`. They keep Refugio as the post-login session root, keep Labs Dev visible from Refugio, redirect accidental login returns back to Refugio during an active session, and replace the battle-request replay preview with a static battle splash while the real battle opens.

Entry Dev Labs export hotfix is implemented locally after manual review showed the published menu still hid Battle Lab and Progression Lab. The root cause was `export_presets.cfg` excluding `dev/**`, so exported builds could not satisfy `ResourceLoader.exists()` for the lab overlays. Local exports now package `res://dev/battle_lab/battle_lab_screen.gd` and `res://dev/progression_lab/progression_lab_screen.gd`, and `tools/smoke_exports.gd` prevents this regression.

Priority order after the docs are aligned:

1. Internal loop ergonomics.
2. Social.
3. General visual direction.
4. Battle presentation.
5. Weapons, spells, economy, balance and content details.

No new code, schema, backend, asset, gameplay or balance work belongs to this documentation alignment package.

## Latest Technical Package

Track 16 added the first behavior/crafting/consumable package requested by the user. It remains technical context and not the current product focus; this publication did not separately promote Track 16 schema/backend work.

- Ossos are represented as whole numbers in the new scale (`1 Osso atual = 0.01 Osso antigo`) and current economy/content/Progression Lab values were rescaled by `100`.
- `po_osso` was added as a whole-number resource, created by crushing Ossos.
- `pocao_vida` and `craft_pocao_vida` were added to content, crafting state and server-authoritative Edge Functions.
- Save-scoped `crafting/*` and `build/*` endpoints manage crafting, consumable inventory, potion slot and spell/potion behavior.
- Battle simulator supports spell behavior, `consumable_use`, one potion use per slot per battle and five `heal` ticks of `4%` max HP.
- Godot Base/Ossario and Refugio preparation panels expose crafting, potion equip/remove and simple behavior toggles.

## Release Snapshot

| Artifact | Bytes | SHA256 |
|---|---:|---|
| Android APK | `31567507` | `7e96dded13578764ff2cbcb84f795830e3aab371dde7754748c898f135e4de5e` |
| PC Windows ZIP | `40035466` | `bccf2cecb4459f16cf68dcb4a43698128d76ae6fa25cd7ece3779656bbba8ecf` |
| Web index | `5442` | `7769cf8acb38daffe1006683416cebfa82d42993b5a2e3a8e51a444a01718f27` |

Links:

- Supabase remote: `https://armxgipvnbbshzqawklw.supabase.co`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Stable portal: `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Stable Web: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Latest verified preview: `https://34c70f2f.draxos-mobile-internal-alpha.pages.dev`

The stable Cloudflare Pages domain is protected by Cloudflare Access. Anonymous public validation should use an unprotected preview or an authenticated Access session. APK/PC downloads currently use unlisted public Supabase Storage URLs so testers can download directly from mobile after passing the portal link.

## Risks And Blocks

- Track 16 schema/backend work was not separately promoted in this publication; Supabase migrations/functions for that package must still be deployed deliberately if Track 16 becomes product focus later.
- Foundation Loop UX Pass 01 is published, but it still needs manual Android/Windows/Web review before it becomes the accepted V0 UX baseline.
- Track 13 manual Android/Windows/Web walkthrough is still required before widening access beyond the current internal/private audience.
- `players.save_type` remains an alpha shortcut. `account_profiles` + `game_saves` is a future migration package.
- Progression/economy remains mock/substance and not the current tuning focus.
- Release scripts are safe by default; remote mutation remains opt-in with `-ConfirmRemoteMutation`.

## Next Step

Publish the Entry Dev Labs export hotfix, then manually review Android/Windows/Web again: Entry Labs visible in the initial menu, Refugio contained, Battle contained, APK download works without Bearer-token error, battle request shows only the static splash before opening, loop CTA is obvious, and reward return sends the player back to base intent.

## Validation

Documentation/foundation validation for this stage:

```powershell
git diff --check
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_agent_ops_foundation.ps1 -ProjectDir .
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_loop.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_hardening.gd
```

Full release/backend validation remains available through `validate_foundation.ps1 -Profile Full` when a gate needs it.

Note: on a fresh worktree, run the Godot `--import` step once before headless smokes if global class names are not yet registered.

## Read Next

1. `../AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `docs/documentation-index.md`
4. `docs/foundation-app-v0-audit.md`
5. `docs/foundation-loop-audit.md`
6. `docs/product-vision.md`
7. `docs/product-brief.md`
8. `docs/design-pending.md`
