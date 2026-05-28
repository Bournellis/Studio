# DraxosMobile

DraxosMobile is the Godot/Supabase project for Android, PC executable and PC browser. It is an async PVP autobattler with Refugio/Base management, social systems and server-authoritative progression.

**Status:** `P2_IMPLEMENTACAO - FOUNDATION_AUDIT_ACTIVE`
**Baseline:** Track 00-15 integrated; Track 13 release safety and Track 14 agent ops baseline preserved; Track 16 is the latest local technical package and has not been promoted as the current product focus.

## Current Focus

The project is a strong implemented base for refinement, not a final product and not a content-expansion track.

The immediate focus is Foundation Audit for the post-login internal loop:

`Base -> collect resources -> evolve base -> battle -> receive rewards -> check base again`

Current content, names, spells, weapons, economy values, battle flavor, visual style and premium systems exist to give substance to the prototype. Treat them as mock/substance for evaluation, not as final game direction or current tuning priorities.

## For Agents

Start with:

1. `AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `implementation/current-status.md`
4. `docs/documentation-index.md`
5. `docs/foundation-app-v0-audit.md`

Do not start from old Track 04/08/10/15/16 notes. They are history or technical context unless a live doc points to them for a specific detail.

## Current Gate

Before any new feature, numeric tuning, account/save migration, assets-final pass, battle presentation pass, social expansion or remote publication:

1. Complete Foundation Audit for the post-login loop.
2. Record whether the current UX makes collect, upgrade, battle, reward and return-to-base obvious.
3. Keep release publishing in `Mode Plan` or `Mode Package` unless the user explicitly approves remote mutation.
4. Run the real Android / Windows / Web walkthrough in `docs/track-13-manual-walkthrough-gate.md` before any remote publication.

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
| Foundation Audit | `docs/foundation-app-v0-audit.md` |
| Product canon local | `docs/product-vision.md` |
| Implementation GDD | `docs/game-design-document.md` |
| Pending decisions | `docs/design-pending.md` |
| Contracts | `docs/contracts/` |
| Release ops | `docs/release-ops-checklist.md` |
| Manual gate | `docs/track-13-manual-walkthrough-gate.md` |
| Last technical package | `implementation/tracks/track-16-behavior-crafting/` |
| Historical concept archive | `../_conceitos/mobile-universe/` |

## Do Not Touch Casually

- `../_conceitos/mobile-universe/`: archive only.
- Remote Supabase/Cloudflare publication: opt-in only.
- Account/save migration from `players.save_type` to `account_profiles/game_saves`: separate future package.
- Tuning numbers, weapons, spells, Battle Pass, economy and final visual identity: blocked until Foundation Audit and explicit user decision.
- Secrets: never in client, exports, portal, manifest or docs.

## Release Snapshot

- Channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Stable portal/Web: Cloudflare Access protected.
- Latest verified preview: `https://b16705ab.draxos-mobile-internal-alpha.pages.dev`
