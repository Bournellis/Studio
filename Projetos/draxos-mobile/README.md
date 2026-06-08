# DraxosMobile

DraxosMobile is the Godot/Supabase project for Android, PC executable and PC browser. It is now a PVE Arena-first async autobattler with Refugio/Base management, later PVP, social systems and server-authoritative progression.

**Status:** `P2_IMPLEMENTACAO - BOSQUE_FEEL_SPAWN_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`
**Baseline:** Bosque Feel & Spawn Authority v1 is the latest remote Internal Alpha package: release root `internal-alpha/v0-bosque-feel-spawn-authority-v1-20260608-70b79c3`, preview `https://16ac3cb7.draxos-mobile-internal-alpha.pages.dev`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/` and direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`. It publishes APK/manifest `0.0.11-alpha.0` / version code `11`, keeps minimum supported version code `11`, preserves operations-v2 persistence, and fixes the player-facing feel around server authority: resource nodes use server-time cooldowns with visual grace, pending collected nodes no longer flicker or revive for one frame, collection is sticky while moving lightly, deposit/craft buttons queue actions without global menu freeze, and server ACKs reconcile without rolling back same-session preview. Bosque Persistence Rebase v1 remains preserved as the previous persistence/operations package. Bosque Session Lifecycle & Durable Structures Hotfix v1 remains preserved as the previous session lifecycle package. Bosque World Hub Domain Separation v1 remains preserved as the previous local/account domain package. Bosque Fogueira Potion Crafting v1 remains preserved as the previous station-craft package. Bosque Durable Bau Mochila v1 remains preserved as the previous durable Openworld progress package. Arena PVE Menu Flow Simplification v1 remains preserved as the previous Arena menu package. Track 13 release safety and Track 14 agent ops remain preserved baselines.
## Current Focus

The project is a strong implemented base for refinement, not a final product and not a content-expansion track.

The Foundation Loop Audit is documented in `docs/foundation-loop-audit.md`. Foundation Loop UX Pass 01 is implemented, published to the Internal Alpha artifact/site channel and manually confirmed on Android/Windows/Web on `2026-05-29` as a historical app-shell UX baseline for the post-login internal loop, not the current product loop:

`Base -> collect resources -> evolve base -> battle -> receive rewards -> check base again`

Social Basico Guilda v1, Visual Direction v1, Battle Presentation v1, Battle Drama v1.1, Battle Preparation Complete v1, Progression Clarity v1, First Session Clarity v1, Foundation Final Polish, Track 18 PVE Arena Initial, Track 19 Arena Consistency Pass, Track 20 Season 1 Arena Calibration, Lab Web Export Guard, Remote Lab Runner, Track 21 Arena Loop Unlock/Friction, Hardening Platform V1, Foundation Hardening V2, First Access Runtime Fix, Bosque Mecanico Basico v2, Openworld Main Menu Sync, Technical Hardening, Bosque v3 UX/Feel, Arena PVE First Real Run + Update Recovery, Arena Duel Flow Hotfix, Arena PVE Season 1 Loop v1, Arena/Bosque Regression Hotfix, Arena/Bosque Visible V2, Bosque Sync Responsiveness v1, Bosque Offline-First Checkpoint v1, Arena PVE Menu Flow Simplification v1, Bosque Durable Bau Mochila v1, Bosque Fogueira Potion Crafting v1, Bosque World Hub Domain Separation v1, Bosque Session Lifecycle & Durable Structures Hotfix v1 and Bosque Persistence Rebase v1 are preserved in the Internal Alpha lineage. Bosque Feel & Spawn Authority v1 is the current published Internal Alpha package for human playtest.

Foundation Hardening V2 makes strict expansion gates, mode decision packs, backend boundary inventory, read-only ops, Android release signing, V2 schema enforcement and remote publication evidence the current baseline before new mode work. Hardening Platform V1 remains the previous multi-agent/mode platform baseline. Track 21 Arena Loop Unlock/Friction remains the Arena/Autobattler context for tutorial of 1 duel, first arenas of 3 duels, locked loadout context, temporary stat buffs, HP reset per duel, no combat cooldown, live-stock potion consumption in Arena, summary-only claim, public buff select endpoint, data-driven Arena selection, XP -> level recalculation on completion and direct continue-in-Arena flow. Remote Lab Runner remains preserved for Battle Lab Dev and Progression Lab Dev in Web export through Edge `lab-runner` with the same Supabase email/password Internal Alpha account gate.

Behavior/potion/crafting is implemented as technical baseline: Ossos inteiros, Po de Osso, Fogueira station crafting, simple potions, one potion slot and simple spell/potion use preferences are documented in `docs/behavior-potion-crafting-v1.md`. Treat this as existing foundation, not as permission to expand tuning, economy, additional potions or advanced behavior without a new package decision.

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
4. Playtest the published Bosque Feel & Spawn Authority v1 package first, focusing collection feel, no progress-bar restarts during light movement, no one-frame node flicker, no same-session rollback after ACK, deposit/craft/menu responsiveness, node cooldown persistence after relog, Fogueira persistence only after server ACK, station craft sources (`Bau do Bosque` + `Conta/Ossario`) and Arena potion equip/effects across APK/Web refresh. Preserve Arena PVE Menu Flow Simplification v1 regression coverage: Arena selection order, single recommended CTA, Preparacao before start, active attempt recovery, `Resolver duelo`/`Escolher buff` ordering and behavior controls between fights.
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
- Version: `0.0.11-alpha.0`
- Version code: `11`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Stable portal/Web: Cloudflare Access protected.
- Current verified preview: `https://16ac3cb7.draxos-mobile-internal-alpha.pages.dev`
- Current release root: `internal-alpha/v0-bosque-feel-spawn-authority-v1-20260608-70b79c3`
- Current APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-feel-spawn-authority-v1-20260608-70b79c3/downloads/draxos-mobile-alpha.apk`
- Current PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-feel-spawn-authority-v1-20260608-70b79c3/downloads/draxos-mobile-alpha.zip`
- Current APK SHA256: `ba036f905d569510f572ea988345846a07bc6cf99691ae384a95d2ab2d61c0a7`
- Current PC ZIP SHA256: `583979a6d14c0dbd4bd934ede19bd5c7b500a0f6b2ef714fffb57d2dfc86671a`
- Current Web Index SHA256: `062dfaae2c468070b2e3cb712045daa0fe2fb9fafe8c2429a2e39993c913f59a`
- Previous persistence package: Bosque Persistence Rebase v1 remains the previous persistence/operations package.
- Previous persistence verified preview: `https://0c0a8dcf.draxos-mobile-internal-alpha.pages.dev`
- Previous persistence release root: `internal-alpha/v0-bosque-persistence-rebase-v1-20260608-bc23f74`
- Previous session-lifecycle package: Bosque Session Lifecycle & Durable Structures Hotfix v1 remains the previous expired-session/structures package.
- Previous session-lifecycle verified preview: `https://8ecac093.draxos-mobile-internal-alpha.pages.dev`
- Previous session-lifecycle release root: `internal-alpha/v0-bosque-session-lifecycle-structures-hotfix-v1-20260607-c953b51`
- Previous local/account domain package: Bosque World Hub Domain Separation v1 remains the previous local/account domain package.
- Previous local/account domain verified preview: `https://d1872010.draxos-mobile-internal-alpha.pages.dev`
- Previous local/account domain release root: `internal-alpha/v0-bosque-world-hub-domain-separation-v1-20260606-81ecf05`
- Previous station-craft package: Bosque Fogueira Potion Crafting v1 remains the previous station-craft package.
- Previous station-craft verified preview: `https://08d00f24.draxos-mobile-internal-alpha.pages.dev`
- Previous station-craft release root: `internal-alpha/v0-bosque-fogueira-potion-crafting-v1-20260606-cad6d2c`
- Previous durable Openworld package: Bosque Durable Bau Mochila v1 remains the previous durable progress package.
- Previous durable Openworld verified preview: `https://39198a35.draxos-mobile-internal-alpha.pages.dev`
- Previous durable Openworld release root: `internal-alpha/v0-bosque-durable-bau-mochila-v1-20260606-6e7ca6b`
- Previous Arena menu package: Arena PVE Menu Flow Simplification v1 remains the previous Arena menu package.
- Previous Arena menu verified preview: `https://fdf44707.draxos-mobile-internal-alpha.pages.dev`
- Previous Arena menu release root: `internal-alpha/v0-arena-pve-menu-flow-simplification-v1-20260606-5d03a68`
- Previous Openworld policy package: Bosque Offline-First Checkpoint v1 remains the previous Openworld/Bosque policy package.
- Previous Openworld policy verified preview: `https://fa84e109.draxos-mobile-internal-alpha.pages.dev`
- Previous Openworld policy release root: `internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22`
- Previous Bosque sync package: Bosque Sync Responsiveness v1 remains the previous Bosque sync package.
- Previous Bosque sync verified preview: `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`
- Previous Bosque sync release root: `internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95`
- Previous visible package: Arena/Bosque Visible V2 remains the previous visible package.
- Previous visible verified preview: `https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev`
- Previous visible release root: `internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5`
- Previous hardening guard: Foundation Hardening V2 remains the previous hardening/live-doc enforcement baseline.
- Previous hardening verified preview: `https://ca946749.draxos-mobile-internal-alpha.pages.dev`
- Previous hardening release root: `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`
- Known release risk: Android APK uses `debug_fallback`; configure or reuse the release keystore before broader Android distribution.
