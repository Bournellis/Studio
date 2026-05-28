# DraxosMobile

DraxosMobile is the Godot/Supabase project for Android, PC executable and PC browser. It is an async PVP autobattler with Refugio/Base management, social systems and server-authoritative progression.

**Status:** `P2_IMPLEMENTACAO - Track 14 TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`  
**Baseline:** Track 00-13 integrated; Track 13 delivered foundation validation and release safety on `2026-05-28`.

## For Agents

Start with:

1. `AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `implementation/current-status.md`
4. `docs/documentation-index.md`

Do not start from old Track 04/08/10 notes. They are history unless a live doc points to them for context.

## Current Gate

Before any new feature, numeric tuning, account/save migration, assets-final pass or remote publication:

1. Run the real Android / Windows / Web walkthrough in `docs/track-13-manual-walkthrough-gate.md`.
2. Record results in the active track or handoff.
3. Keep release publishing in `Mode Plan` or `Mode Package` unless the user explicitly approves remote mutation.

## Safe Validation

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

## Where Things Live

| Need | Read |
|---|---|
| Agent operation | `docs/agent-operating-manual.md` |
| Current state | `implementation/current-status.md` |
| Documentation map | `docs/documentation-index.md` |
| Product canon local | `docs/product-vision.md` |
| Implementation GDD | `docs/game-design-document.md` |
| Pending decisions | `docs/design-pending.md` |
| Contracts | `docs/contracts/` |
| Release ops | `docs/release-ops-checklist.md` |
| Manual gate | `docs/track-13-manual-walkthrough-gate.md` |
| Track 14 work | `implementation/tracks/track-14-agent-ops-foundation/` |
| Historical concept archive | `../_conceitos/mobile-universe/` |

## Do Not Touch Casually

- `../_conceitos/mobile-universe/`: archive only.
- Remote Supabase/Cloudflare publication: opt-in only.
- Account/save migration from `players.save_type` to `account_profiles/game_saves`: separate future package.
- Tuning numbers: blocked until human walkthrough and Progression Lab review.
- Secrets: never in client, exports, portal, manifest or docs.

## Release Snapshot

- Channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Stable portal/Web: Cloudflare Access protected.
- Latest verified preview: `https://b16705ab.draxos-mobile-internal-alpha.pages.dev`
