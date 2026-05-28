# DraxosMobile - Current Status

- Last updated: `2026-05-28`
- Project: `draxos-mobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `Mobile UX overhaul`
- Active track: `Track 15 - Mobile UX Overhaul`
- Active track status: `TRACK_15_MOBILE_UX_OVERHAUL_ACTIVE`
- Hardening baseline: `Track 13 - Foundation Validation And Release Safety` (`TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`)
- Agent baseline: `Track 14 - Agent Operations Foundation`
- Build channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`

## Baseline

Track 00-14 are integrated on Godot 4.6.2 + Supabase. The project has Android/PC/Web alpha surfaces, email/password account flow, `normal` and `progression_lab` saves, server-authoritative battle, Base/Social/Competition/Shop loops, Progression Lab/Battle Lab, portrait Refugio, fullscreen portrait battle, skip, summary and current-battle logs.

The major foundation baseline is:

- Track 11: live docs, release state, Kanban cleanup, manual walkthrough and first safe `boot.gd` cut.
- Track 12: `boot.gd` decomposed to action contract, account/session flow, surface action flow, battle lifecycle flow and shared surface helpers; current budget is under `1500` lines.
- Track 13: `tools/validate_foundation.ps1`, safe `publish_internal_alpha.ps1` modes, release safety checks, readiness checks and Android/Windows/Web manual gate.
- Track 14: agent operating manual, documentation index, status sync, safe commands and drift guards.

## Active Track 15

Track 15 turns the functional alpha/dev app into a comfortable internal Android portrait app without gameplay, tuning, backend, schema or economy changes.

Current package:

- Entry is a premium pre-login screen with fullscreen visual background, `Entrar` as the first focus, save choice below login, account creation in a modal and internal tools collapsed away from the normal path.
- Refugio is the central hub with visual background, contextual primary action, hotspots for Base/Loja/Social/Arena/Batalha and a small floating Perfil/Ajustes button.
- Back navigation from Refugio-opened surfaces returns to Refugio, including Loja.
- Base, Loja, Social and Competicao are cleaner integrated panels with direct copy, empty states and focused CTAs.
- Battle keeps fullscreen portrait, visual stage, discreet `Pular`, reward/result summary and return/evolution CTA.
- UI foundation has premium dark/gore tokens, larger touch targets, panel/sheet/button styles and normal-flow copy without technical labels.
- Reference assets were selectively promoted into `assets/ux_overhaul/` for runtime use in this test phase.

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
- Latest verified preview: `https://36b1d46c.draxos-mobile-internal-alpha.pages.dev`

The stable Cloudflare Pages domain is protected by Cloudflare Access. Anonymous public validation should use an unprotected preview or an authenticated Access session.

## Risks And Blocks

- Track 15 needs human visual review on Android portrait before further UX expansion or polish commits.
- Manual Android/Windows/Web walkthrough from Track 13 is still required before gameplay features, numeric tuning, account/save migration or remote publication.
- `players.save_type` remains an alpha shortcut. `account_profiles` + `game_saves` is a future migration package.
- Progression/economy remains `REVIEW`; numeric changes need human playthrough and Progression Lab evidence.
- Release scripts are safe by default, but a real `Mode Package` with fresh artifacts is still needed before publication becomes routine.

## Next Step

Review the Track 15 UX checkpoint on Android portrait, especially Entry, Refugio, Battle/Summary, Base and Loja. After approval, continue polish in focused passes or run the Track 13 manual walkthrough before any gameplay/tuning/release work.

Screenshots for the current checkpoint are in `build/track15_mobile_ux_checkpoint/`.

## Validation

Current Track 15 client validation:

```powershell
git diff --check
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_hardening.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_exports.gd
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { .\tools\validate_foundation.ps1 -ProjectDir . -Profile Client -RequireClean:`$false }"
```

Full release/backend validation remains available through `validate_foundation.ps1 -Profile Full -RequireClean:$false` when a gate needs it.

## Read Next

1. `../AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `docs/documentation-index.md`
4. `implementation/tracks/track-15-mobile-ux-overhaul/current-status.md`
5. `implementation/tracks/track-15-mobile-ux-overhaul/scope.md`
6. `implementation/tracks/track-13-validation-release-safety/release-safety-contract.md`
7. `docs/track-13-manual-walkthrough-gate.md`
