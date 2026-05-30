# DraxosMobile

DraxosMobile is the Godot/Supabase project for Android, PC executable and PC browser. It is an async PVP autobattler with Refugio/Base management, social systems and server-authoritative progression.

**Status:** `P2_IMPLEMENTACAO - FIRST_SESSION_CLARITY_V1_PUBLISHED`
**Baseline:** Track 00-15 integrated; Track 13 release safety and Track 14 agent ops baseline preserved; Track 16 is the latest technical package and has not been promoted as the current product focus. Its current behavior/potion/crafting state is summarized in `docs/behavior-potion-crafting-v1.md`.

## Current Focus

The project is a strong implemented base for refinement, not a final product and not a content-expansion track.

The Foundation Loop Audit is documented in `docs/foundation-loop-audit.md`. Foundation Loop UX Pass 01 is implemented, published to the Internal Alpha artifact/site channel and manually confirmed on Android/Windows/Web on `2026-05-29` as the current UX baseline for the post-login internal loop:

`Base -> collect resources -> evolve base -> battle -> receive rewards -> check base again`

Social Basico Guilda v1, Visual Direction v1, Battle Presentation v1, Battle Drama v1.1, Battle Preparation Complete v1, Progression Clarity v1 and First Session Clarity v1 are published on the Internal Alpha channel. Refugio, Preparacao and battle summary now explain level, power, battle XP, next milestones and the next first-session action using existing snapshots.

First Session Clarity v1 keeps the same foundation and adds client-only guidance so the first session reads as Refugio -> collect -> evolve -> prepare -> battle -> reward -> return to base. The package is documented in `docs/first-session-clarity-v1.md`.

Behavior And Potion Crafting v1 is implemented as technical baseline: Ossos inteiros, Po de Osso, Pocao de Vida, crafting inicial, one potion slot and simple spell/potion use preferences are documented in `docs/behavior-potion-crafting-v1.md`. Treat this as existing foundation, not as permission to expand tuning, economy, new potions or advanced behavior without a new package decision.

Current content, names, spells, weapons, economy values, battle flavor, visual style and premium systems exist to give substance to the prototype. Treat them as mock/substance for evaluation, not as final game direction or current tuning priorities.

## For Agents

Start with:

1. `AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `implementation/current-status.md`
4. `docs/documentation-index.md`
5. `docs/foundation-app-v0-audit.md`
6. `docs/foundation-loop-audit.md`
7. `docs/progression-clarity-v1.md`
8. `docs/first-session-clarity-v1.md`
9. `docs/behavior-potion-crafting-v1.md` when touching Ossos, crafting, potions, consumables or behavior.

Do not start from old Track 04/08/10/15/16 notes. They are history or technical context unless a live doc points to them for a specific detail.

## Current Gate

Before any new feature, numeric tuning, account/save migration, assets-final pass, battle presentation pass or social expansion:

1. Read `docs/foundation-loop-audit.md`.
2. Treat Foundation Loop UX Pass 01, Social Basico Guilda v1, Visual Direction v1, Battle Presentation v1, Battle Drama v1.1, Battle Preparation Complete v1, Progression Clarity v1 and First Session Clarity v1 as the accepted published baseline, then choose an explicit next package before expanding social, visuals, battle presentation or content systems.
3. Keep release publishing in `Mode Plan` or `Mode Package` unless the user explicitly approves remote mutation.
4. Run the real Android / Windows / Web walkthrough in `docs/track-13-manual-walkthrough-gate.md` before any remote publication.

## Safe Validation

```powershell
cd <WORKTREE>\Projetos\draxos-mobile
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Full
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_loop.gd
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
| Foundation Loop Audit | `docs/foundation-loop-audit.md` |
| Visual Direction v1 | `docs/visual-direction-v1.md` |
| Progression Clarity v1 | `docs/progression-clarity-v1.md` |
| First Session Clarity v1 | `docs/first-session-clarity-v1.md` |
| Behavior/potions/crafting | `docs/behavior-potion-crafting-v1.md` |
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
- Tuning numbers, weapons, spells, Battle Pass, economy and final visual identity: blocked until an explicit package decision after the loop UX pass.
- Secrets: never in client, exports, portal, manifest or docs.

## Release Snapshot

- Channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Stable portal/Web: Cloudflare Access protected.
- Latest verified preview: `https://f2ead4bd.draxos-mobile-internal-alpha.pages.dev/web/index.html`
