# DraxosMobile

DraxosMobile is the Godot/Supabase project for Android, PC executable and PC browser. It is now a PVE Arena-first async autobattler with Refugio/Base management, later PVP, social systems and server-authoritative progression.

**Status:** `P2_IMPLEMENTACAO - BOSQUE_V3_UX_FEEL_PUBLISHED_INTERNAL_ALPHA`
**Baseline:** Bosque v3 UX/Feel is the latest remote Internal Alpha package: release root `internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45`, preview `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/` and direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`. It publishes a narrow Bosque polish package: safer resource placement/collision slack, clearer collect/deposit/craft/session feedback, visible proximity/pickup states, fogueira glow, nonblocking landmarks and player-facing visit summaries. Technical Hardening remains preserved inside this release as the previous technical package. Openworld Main Menu Sync remains the previous content package and is preserved inside this release. Bosque Mecanico Basico v2 remains the previous Bosque guidance package. Foundation Hardening V2 remains the previous multi-mode expansion enforcement baseline. Track 13 release safety and Track 14 agent ops remain preserved baselines. Track 16 is technical behavior/potion/crafting context. Track 18 Arena PVE Initial, Track 20 Season 1 Arena Calibration, Track 21 Arena Loop Unlock/Friction and Remote Lab Runner remain preserved Arena/Autobattler/Lab context, not the current platform baseline.

## Current Focus

The project is a strong implemented base for refinement, not a final product and not a content-expansion track.

The Foundation Loop Audit is documented in `docs/foundation-loop-audit.md`. Foundation Loop UX Pass 01 is implemented, published to the Internal Alpha artifact/site channel and manually confirmed on Android/Windows/Web on `2026-05-29` as a historical app-shell UX baseline for the post-login internal loop, not the current product loop:

`Base -> collect resources -> evolve base -> battle -> receive rewards -> check base again`

Social Basico Guilda v1, Visual Direction v1, Battle Presentation v1, Battle Drama v1.1, Battle Preparation Complete v1, Progression Clarity v1, First Session Clarity v1, Foundation Final Polish, Track 18 PVE Arena Initial, Track 19 Arena Consistency Pass, Track 20 Season 1 Arena Calibration, Lab Web Export Guard, Remote Lab Runner, Track 21 Arena Loop Unlock/Friction, Hardening Platform V1, Foundation Hardening V2, First Access Runtime Fix, Bosque Mecanico Basico v2, Openworld Main Menu Sync and Technical Hardening are preserved in the Internal Alpha lineage. Bosque v3 UX/Feel is the current published Internal Alpha package for human playtest.

Foundation Hardening V2 makes strict expansion gates, mode decision packs, backend boundary inventory, read-only ops, Android release signing, V2 schema enforcement and remote publication evidence the current baseline before new mode work. Hardening Platform V1 remains the previous multi-agent/mode platform baseline. Track 21 Arena Loop Unlock/Friction remains the Arena/Autobattler context for tutorial of 1 duel, first arenas of 3 duels, locked loadout context, temporary stat buffs, HP reset per duel, no combat cooldown, live-stock potion consumption in Arena, summary-only claim, public buff select endpoint, data-driven Arena selection, XP -> level recalculation on completion and direct continue-in-Arena flow. Remote Lab Runner remains preserved for Battle Lab Dev and Progression Lab Dev in Web export through Edge `lab-runner` with the same Supabase email/password Internal Alpha account gate.

Behavior And Potion Crafting v1 is implemented as technical baseline: Ossos inteiros, Po de Osso, Pocao de Vida, crafting inicial, one potion slot and simple spell/potion use preferences are documented in `docs/behavior-potion-crafting-v1.md`. Treat this as existing foundation, not as permission to expand tuning, economy, new potions or advanced behavior without a new package decision.

Current content, names, spells, weapons, economy values, battle flavor, visual style and premium systems exist to give substance to the prototype. Treat them as mock/substance for evaluation, not as final game direction or current tuning priorities.

## For Agents

Start with:

1. `AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `implementation/current-status.md`
4. `docs/documentation-index.md`
5. `docs/multi-agent-workflow.md`
6. `docs/foundation-hardening-v2-readiness-report.md`
7. `docs/pve-arena-initial-direction.md`
8. `docs/foundation-app-v0-audit.md`
9. `docs/foundation-loop-audit.md`
10. `docs/progression-clarity-v1.md`
11. `docs/first-session-clarity-v1.md`
12. `docs/behavior-potion-crafting-v1.md` when touching Ossos, crafting, potions, consumables or behavior.

Do not start from old Track 04/08/10/15/16 notes. They are history or technical context unless a live doc points to them for a specific detail.

## Current Gate

Before any new feature, numeric tuning, assets-final pass, battle presentation pass or social expansion:

1. Read `docs/foundation-hardening-v2-readiness-report.md` and `docs/multi-agent-workflow.md`.
2. Treat Foundation Hardening V2 as the current multi-mode expansion enforcement baseline. Treat Foundation Loop UX Pass 01 as historical app-shell UX baseline, and Track 18/20/21 plus Remote Lab Runner as Arena/Autobattler/Lab context; then follow `docs/pve-arena-initial-direction.md` before expanding PVP, social, visuals, battle presentation, base builder or content systems.
3. Keep release publishing in `Mode Plan` or `Mode Package` unless the user explicitly approves remote mutation.
4. Playtest the published Bosque v3 UX/Feel package first, focusing resource collision comfort, collect/deposit/craft/session feedback and the main menu/Bosque/Arena paths.
5. Run `validate_foundation.ps1 -Profile Full -RequireClean` with local Supabase/Edge active before tuning work starts, and run the real Android / Windows / Web walkthrough in `docs/track-13-manual-walkthrough-gate.md` before future remote publications.

## Safe Validation

```powershell
cd <WORKTREE>\Projetos\draxos-mobile
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Full -RequireClean
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
| Multi-agent hardening workflow | `docs/multi-agent-workflow.md` |
| Hardening readiness report | `docs/foundation-hardening-v2-readiness-report.md` |
| Arena PVE initial direction | `docs/pve-arena-initial-direction.md` |
| Arena PVE implemented contract | `docs/pve-arena-v1.md` |
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
- `players.save_type` as new account/save authority: blocked. `account_profiles/game_saves` are the current foundation authority; `players.save_type` is compatibility only.
- Tuning numbers, weapons, spells, Battle Pass, economy and final visual identity: blocked unless required by the approved Arena PVE initial package.
- Secrets: never in client, exports, portal, manifest or docs.

## Release Snapshot

- Channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Stable portal/Web: Cloudflare Access protected.
- Current verified preview: `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`
- Current release root: `internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45`
- Current APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45/downloads/draxos-mobile-alpha.apk`
- Current PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45/downloads/draxos-mobile-alpha.zip`
- Previous content package: Openworld Main Menu Sync remains the previous content package.
- Previous content verified preview: `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`
- Previous content release root: `internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`
- Previous Bosque v2 verified preview: `https://ae049df9.draxos-mobile-internal-alpha.pages.dev`
- Previous Bosque v2 release root: `internal-alpha/v0-bosque-v2-guidance-20260604-7c2d981`
- Previous hardening guard: Foundation Hardening V2 remains the previous hardening/live-doc enforcement baseline.
- Previous hardening verified preview: `https://ca946749.draxos-mobile-internal-alpha.pages.dev`
- Previous hardening release root: `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`
- Previous hardening APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4/downloads/draxos-mobile-alpha.apk`
- Previous hardening PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4/downloads/draxos-mobile-alpha.zip`
- Known release risk: Android APK uses `debug_fallback`; configure or reuse the release keystore before broader Android distribution.
