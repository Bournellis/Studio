# Agent Operating Manual - DraxosMobile

This file is the fast entrypoint for agents working in `Projetos/draxos-mobile`.

**Do not confuse this project with** `Projetos/draxos-roguelike-cardgame/`, the separate Steam roguelike cardgame.

## Current Truth

- Project: `DraxosMobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active operational stage: `Arena/Bosque Regression Hotfix`
- Active stage status: `PUBLISHED_INTERNAL_ALPHA`
- Latest remote Internal Alpha package: `Arena/Bosque Regression Hotfix`,
  release root `internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f`,
  official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`,
  direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`,
  deployment evidence `https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev`.
- Hardening baseline: `Track 13 - Foundation Validation And Release Safety` delivered on `2026-05-28`; compatibility marker: Track 13 validation/release safety.
- Agent baseline: `Track 14 - Agent Operations Foundation` is the current operations/docs foundation; compatibility marker: `TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`.
- Latest technical package: `Track 16 - Behavior And Potion Crafting`, technical context and not the current product focus. Current behavior/potion/crafting state is summarized in `docs/behavior-potion-crafting-v1.md`.
- Immediate product gate: Arena/Bosque Regression Hotfix is the latest remote Internal Alpha publication for human playtest. It preserves Arena PVE Season 1 Loop v1, then restores Preparacao before Arena start, during active attempts and in pending buff choice, and restores Bosque deposit/craft feedback plus pending-event flush before leaving integrated sessions. Arena PVE Season 1 Loop v1 remains the previous Season 1 package for grouped arenas/difficulties, progress, next-step guidance, reward preview and remote pending-buff recovery through `/arena/pve/state`. Arena Duel Flow Hotfix remains the previous hotfix package for Preparacao/behavior in the active-duel menu and selected buff -> `Resolver duelo`. Foundation Hardening V2 remains the previous hardening/live-doc enforcement baseline. Track 21 remains preserved Autobattler/Arena PVE context for no combat cooldown, locked loadout on start, temporary stat buffs, HP reset per duel, live-stock potion consumption in Arena, summary-only claim, public buff select endpoint, data-driven Arena list, Season 1 tier matrix, tutorial XP -> level recalculation, direct start into active Arena and continue-in-Arena summary flow.
- Previous hardening guard baseline: Foundation Hardening V2, release root `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview evidence `https://ca946749.draxos-mobile-internal-alpha.pages.dev`.

DraxosMobile is now a PVE Arena-first async autobattler with Refugio/Base, later PVP, social systems and server-authoritative progression. The real product direction is base builder + Arena PVE + later PVP/social, with room for future minigames and seasons. Current names, spells, weapons, economy values, battle flavor, visual style and premium systems are mock/substance for evaluation unless a live doc explicitly promotes them.

## Start Here

Read in this order for almost every task:

1. `docs/agent-operating-manual.md`
2. `implementation/current-status.md`
3. `docs/documentation-index.md`
4. `docs/multi-agent-workflow.md` when coordinating parallel hardening lanes or mode work
5. `docs/foundation-app-v0-audit.md`
6. `docs/foundation-expansion-readiness.md`
7. `docs/foundation-loop-audit.md`
8. `docs/foundation-responsive-layout-contract.md` when touching Entry, Refugio, Battle or visual/layout code
9. `docs/first-session-clarity-v1.md` when touching first-session guidance, Refugio loop copy, Preparation guidance or battle summary next-step copy
10. `docs/behavior-potion-crafting-v1.md` when touching Ossos, crafting, potions, consumables or behavior
11. `docs/pve-arena-initial-direction.md` when touching product direction, battles, rewards, tuning, onboarding or PVP
12. The files you intend to touch

For product or design work, also read:

1. `docs/product-vision.md`
2. `docs/pve-arena-initial-direction.md`
3. `docs/product-brief.md`
4. `docs/game-design-document.md`
5. `docs/design-pending.md`

For release, validation or publication work, also read:

1. `implementation/tracks/track-13-validation-release-safety/release-safety-contract.md`
2. `implementation/tracks/track-13-validation-release-safety/validation-matrix.md`
3. `docs/release-ops-checklist.md`
4. `docs/track-13-manual-walkthrough-gate.md`

## Worktree And Branch Rules

- Do not implement in `D:\Estudio` unless the user explicitly asks for direct work there.
- Use a dedicated worktree outside the main root: `D:\Estudio-worktrees\draxos-mobile--<agent>--<slug>`.
- Codex branches use `codex/draxos-mobile/<slug>`.
- Do not edit another agent's worktree without explicit user direction.
- Before touching shared files (`AGENTS.md`, `../../canon/`, `../../08_Coordenacao_Agentes/`, `../README.md`), run `git status --short`, `git worktree list` and read the coordination snapshot.
- Register active work in `../../08_Coordenacao_Agentes/Kanban/Doing/` or a handoff note with branch, worktree, objective, intended files, docs read, validation plan and next handoff point.
- For hardening lanes and mode work, use `docs/multi-agent-workflow.md` plus `../../08_Coordenacao_Agentes/Templates/DraxosMobile_Hardening_Doing_TEMPLATE.md` or `../../08_Coordenacao_Agentes/Templates/DraxosMobile_Hardening_Handoff_TEMPLATE.md`.

## Safe Commands

Run commands from `Projetos/draxos-mobile` unless noted.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile DocsOnly
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ServerQuick
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile FullLocal -RequireClean
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd
npx -y deno task --cwd server/functions check
npx -y deno task --cwd supabase/functions check
git diff --check
git status --short
```

Release scripts are safe by default:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Plan
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Package -ReleaseRoot "internal-alpha/v0-<package-slug>-YYYYMMDD-<shortsha>"
```

`Mode Upload`, `Mode DeployManifest` and `Mode FullPublish` require explicit user approval, a versioned `-ReleaseRoot` and `-ConfirmRemoteMutation`. `validate_foundation.ps1 -Profile FullPublish` is disabled; validate first, then publish only through `publish_internal_alpha.ps1`.

For user-approved product packages that require human testing on Android, Windows or Web, publication to Internal Alpha is the default completion step after local validation. Use a fresh versioned release root, export/package/upload/deploy from the same worktree session, and verify the published Web shell against the remote `index.pck`/`index.wasm` sizes before reporting success.

## Hard Stops

- Do not put `service_role`, Supabase secrets, database passwords, keystore passwords or private tokens in client code, exports, portal files, manifests or operational docs.
- Do not run remote publishing modes without explicit user approval and `-ConfirmRemoteMutation`.
- Do not start a new playable feature, numeric tuning pass, weapon/spell/economy pass, potion/consumable expansion, advanced behavior pass, battle presentation pass, final visual pass, iOS work or mobile browser support outside the approved Arena PVE initial package.
- Do not create new account/save, social, reward or minigame state that bypasses `account_profiles/game_saves`, ruleset registry, idempotency v1 or the relevant contract docs.
- Do not edit `.tscn` files as raw text unless the user explicitly asks and the change is safer than an editor/tool path.
- Do not publish Entry/Refugio/Battle layout changes unless `tools/smoke_responsive_layout.gd` passes.
- Do not import gameplay rules from other Draxos projects unless this project's live docs explicitly adopt them.
- Do not treat `Projetos/_conceitos/mobile-universe/` as active implementation material. It is design archive only.

## Live Source Rules

- `docs/product-vision.md` is the local long-term product canon until promoted to shared canon.
- `docs/pve-arena-initial-direction.md` is the live early-game direction: Arena PVE first, PVP later, no combat cooldown, locked loadout, temporary stat buffs and duel-list scaling.
- `docs/foundation-app-v0-audit.md` is the product/agent compass for the accepted Foundation Audit baseline.
- `docs/foundation-expansion-readiness.md` is the delivered pre-expansion gate and closeout contract base.
- `docs/foundation-loop-audit.md` is the executed audit for loop ergonomics and the next UX pass criteria.
- `docs/foundation-responsive-layout-contract.md` is the guardrail for responsive Entry Labs, Refugio and Battle safe frames.
- `docs/behavior-potion-crafting-v1.md` is the live bridge for Track 16 behavior, potion and crafting systems already present in the alpha baseline.
- `docs/game-design-document.md` is the authoritative implementation GDD.
- `docs/design-pending.md` is the only live register of unresolved design decisions.
- `docs/documentation-index.md` classifies live docs, contracts, runbooks, history and design archive.
- `docs/multi-agent-workflow.md` governs parallel hardening lanes, mode scope and handoff expectations.
- `docs/foundation-hardening-v2-readiness-report.md` is the published readiness report for the current multi-mode expansion enforcement baseline.
- `implementation/current-status.md` must remain short and decision-oriented; detailed history belongs in `implementation/tracks/`.
- Supabase mirrors under `server/` and `supabase/` must stay aligned.

## Current Handoff

Arena/Bosque Regression Hotfix is the latest remote Internal Alpha publication on `main`. New DraxosMobile agents should branch from updated `main`, use a dedicated worktree and follow `docs/multi-agent-workflow.md`. Latest remote preview evidence: `https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev`; release root: `internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f`; official URL remains `https://draxos-mobile-internal-alpha.pages.dev/`. Arena PVE Season 1 Loop v1 remains the previous Season 1 package: `internal-alpha/v0-arena-pve-season1-loop-v1-20260605-c8baf32`, preview evidence `https://d7333659.draxos-mobile-internal-alpha.pages.dev`. Arena Duel Flow Hotfix remains the previous hotfix package: `internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174`, preview evidence `https://0536635b.draxos-mobile-internal-alpha.pages.dev`. Arena PVE First Real Run + Update Recovery remains the previous Arena package: `internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a`, preview evidence `https://2c020d09.draxos-mobile-internal-alpha.pages.dev`. Bosque v3 UX/Feel remains the previous content/polish package: `internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45`, preview evidence `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`. Openworld Main Menu Sync remains the previous Openworld content package: `internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`, preview evidence `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`. Foundation Hardening V2 remains the previous hardening/live-doc enforcement baseline: `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview evidence `https://ca946749.draxos-mobile-internal-alpha.pages.dev`. Track 21 remains the preserved Arena PVE/Autobattler context, extended by Track 23 update recovery, Arena Duel Flow Hotfix, Arena PVE Season 1 Loop v1 and Arena/Bosque Regression Hotfix. Do not change gameplay tuning, Supabase APIs, economy, content, weapons, spells, potions, crafting, advanced behavior, final visuals or authoritative flows without an explicit package decision.
