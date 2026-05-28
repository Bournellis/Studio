# DraxosMobile - Current Status

- Last updated: `2026-05-28`
- Project: `draxos-mobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `Agent operations foundation`
- Active track: `Track 14 - Agent Operations Foundation`
- Active track status: `TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`
- Hardening baseline: `Track 13 - Foundation Validation And Release Safety` (`TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`)
- Build channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`

## Baseline

Track 00-13 are integrated on Godot 4.6.2 + Supabase. The project has Android/PC/Web alpha surfaces, email/password account flow, `normal` and `progression_lab` saves, server-authoritative battle, Base/Social/Competition/Shop alpha loops, Progression Lab/Battle Lab, portrait Refugio as the first playable screen, fullscreen portrait battle, skip, minimal summary and current-battle logs.

The major hardening baseline is:

- Track 11: live docs, release state, Kanban cleanup, manual walkthrough and first safe `boot.gd` cut.
- Track 12: `boot.gd` decomposed to action contract, account/session flow, surface action flow, battle lifecycle flow and shared surface helpers; current budget is under `1500` lines.
- Track 13: `tools/validate_foundation.ps1`, safe `publish_internal_alpha.ps1` modes, release safety checks, readiness checks and Android/Windows/Web manual gate.

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

## Active Track 14

Track 14 does not add gameplay. It reorganizes the project so agents can enter safely, find the live truth quickly, avoid old-track drift and validate without accidental remote mutation.

Current package:

- `AGENTS.md` starts with agent operation, safe commands and hard stops.
- `README.md` is a short project portal instead of a long status archive.
- `docs/agent-operating-manual.md` becomes the detailed agent runbook.
- `docs/documentation-index.md` classifies docs as `VIVO`, `CONTRATO`, `RUNBOOK`, `HISTORICO` or `ARQUIVO_DESIGN`.
- Portfolio and Kanban point to the real current foundation work.
- Product terms are aligned around Instrumento Ritual, Doutrina and Familiar, with `weapon/passive/pet` preserved only as legacy technical field names where needed.

## Risks And Blocks

- Manual Android/Windows/Web walkthrough has not been executed yet. This blocks new features, tuning, account/save migration and release publication.
- `players.save_type` remains an alpha shortcut. `account_profiles` + `game_saves` is a future migration package.
- Progression/economy remains `REVIEW`; numeric changes need human playthrough and Progression Lab evidence.
- Release scripts are safe by default, but a real `Mode Package` with fresh artifacts is still needed before publication becomes routine.
- Presenters/helpers still use dynamic `host.call` boundaries in places. Acceptable for this foundation, but future typed ports would reduce risk.

## Next Step

Finish Track 14 validation and keep the branch clean. After merge, execute the Track 13 manual walkthrough in:

1. Android app.
2. Windows executable.
3. Web preview.
4. Web stable through Cloudflare Access.

Record Entry/Login/Save, Refugio, Base, Battle, Summary, Logs, Social, Competition, Shop and update gate behavior before opening the next gameplay package.

## Validation

Minimum foundation validation:

```powershell
cd <WORKTREE>\Projetos\draxos-mobile
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Full -RequireClean:$false
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
npx -y deno task --cwd server/functions check
npx -y deno task --cwd supabase/functions check
git diff --check
git status --short
```

## Read Next

1. `../AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `docs/documentation-index.md`
4. `implementation/tracks/track-14-agent-ops-foundation/current-status.md`
5. `implementation/tracks/track-13-validation-release-safety/release-safety-contract.md`
6. `docs/track-13-manual-walkthrough-gate.md`
