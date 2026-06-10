# Agent Operating Manual - DraxosMobile

This file is the fast entrypoint for agents working in `Projetos/draxos-mobile`.

**Do not confuse this project with** `Projetos/draxos-roguelike-cardgame/`, the separate Steam roguelike cardgame.

## Current Truth

- Project: `DraxosMobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active operational stage: `Bosque Arena Abandon Recovery Authority v1`
- Active stage status: `BOSQUE_ARENA_ABANDON_RECOVERY_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`
- Latest remote Internal Alpha package: `Bosque Arena Abandon Recovery Authority v1`,
  release root `internal-alpha/v0-bosque-arena-abandon-recovery-authority-v1-20260610-a252241`,
  official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`,
  direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`,
  deployment evidence `https://b149da8f.draxos-mobile-internal-alpha.pages.dev`.
- Build version: `0.0.22-alpha.0` / version code `22`; minimum supported version code `13`.
- Hardening baseline: `Track 13 - Foundation Validation And Release Safety` delivered on `2026-05-28`; compatibility marker: Track 13 validation/release safety.
- Agent baseline: `Track 14 - Agent Operations Foundation` is the current operations/docs foundation; compatibility marker: `TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`.
- Latest technical package: `Track 16 - Behavior And Potion Crafting`, technical context and not the current product focus. Current behavior/potion/crafting state is summarized in `docs/behavior-potion-crafting-v1.md`.
- Immediate product gate: Bosque Arena Abandon Recovery Authority v1 is the latest remote Internal Alpha publication. The next operational step is focused human playtest of this package on Web/APK, especially Bosque landmark prompts/actions, Social text fields/actions, Shop confirmation, Arena resume/abandon and `Fechar`, `Voltar` and Esc returning from Arena/Base/Shop/Social/Profile to the Bosque. Future bugs return to the normal bugfix flow if they appear. Bosque Overlay Interactive Controls Authority v1 remains the previous interactive-controls package (release root `internal-alpha/v0-bosque-overlay-interactive-controls-authority-v1-20260609-d3be1fb`, preview `https://9461e4be.draxos-mobile-internal-alpha.pages.dev`); Bosque Overlay Menu Action Authority v1 remains the previous internal-menu-button package; Bosque Overlay Interaction Authority v1 remains the previous close/back package; Bosque Overlay Navigation Hotfix v1 remains the previous interaction hotfix package; Bosque Persistent Overlay Shell v1 remains the previous overlay package; Bosque Diegetic Launcher Foundation v1 remains the previous launcher package; Bosque Bootstrap Authority v1 remains the previous bootstrap package; product-wise, Arena PVE remains the first approved core and Bosque/Openworld remains an integrated Internal Alpha slice, not approval for broad expansion. Arena PVE Bonus Visual v1 remains the previous Arena package; Bosque Node Cooldown ACK v1 remains the previous Bosque persistence/spawn package; Bosque Resume Exit Lifecycle v1 remains the previous resume/exit package; Bosque Feel & Spawn Authority v1 remains the previous feel/spawn package; Bosque Persistence Rebase v1 remains the previous persistence/operations package; Bosque Session Lifecycle & Durable Structures Hotfix v1 remains the previous expired-session/structures package; Bosque World Hub Domain Separation v1 remains the previous local/account domain package; Bosque Fogueira Potion Crafting v1 remains the previous station-craft package; Bosque Durable Bau Mochila v1 remains the previous durable Openworld progress package; Arena PVE Menu Flow Simplification v1 remains the previous Arena menu package; Bosque Offline-First Checkpoint v1 remains the previous Openworld policy package. Arena/Bosque Visible V2, Arena/Bosque Regression Hotfix, Arena PVE Season 1 Loop v1, Arena Duel Flow Hotfix and Track 21 remain preserved Arena/Autobattler context.
- Previous station-craft package: Bosque Fogueira Potion Crafting v1, release root `internal-alpha/v0-bosque-fogueira-potion-crafting-v1-20260606-cad6d2c`, preview evidence `https://08d00f24.draxos-mobile-internal-alpha.pages.dev`.
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

Bosque Arena Abandon Recovery Authority v1 is the latest remote Internal Alpha publication. Fabio reported after the previous package that the Arena still could not be cancelled in an open attempt, so this package adds confirmed abandon recovery, stale local attempt cleanup, post-abandon release verification and Web diagnostics for `lastArenaOperation`. New DraxosMobile agents should branch from updated `main`, use a dedicated worktree and follow `docs/multi-agent-workflow.md`. Latest remote preview evidence: `https://b149da8f.draxos-mobile-internal-alpha.pages.dev`; release root: `internal-alpha/v0-bosque-arena-abandon-recovery-authority-v1-20260610-a252241`; official URL remains `https://draxos-mobile-internal-alpha.pages.dev/`; direct Web URL remains `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`. APK: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/download?artifact=android`. PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/download?artifact=pc_windows`.

The current package keeps the integrated Bosque alive and visible behind Arena/Base/Shop/Social/Profile overlays, pauses world input while an overlay is open, returns focus to the same Bosque node without rebootstrap, and proves close/back/Esc, Social text input, Shop confirmation and Arena resume/abandon through real Web click/keyboard smokes on the published preview. Arena PVE remains the first approved product core; Bosque/Openworld is an integrated Internal Alpha slice and does not authorize broader expansion by itself. Bosque Overlay Menu Action Authority v1 remains the previous internal-menu-button package: release root `internal-alpha/v0-bosque-overlay-menu-action-authority-v1-20260609-aa9402d`, preview evidence `https://5f04e6ae.draxos-mobile-internal-alpha.pages.dev`. Bosque Overlay Navigation Hotfix v1 remains the previous interaction hotfix package: release root `internal-alpha/v0-bosque-overlay-navigation-hotfix-v1-20260609-9b93e5d`, preview evidence `https://92cc0579.draxos-mobile-internal-alpha.pages.dev`. Bosque Diegetic Launcher Foundation v1 remains the previous launcher package: release root `internal-alpha/v0-bosque-diegetic-launcher-foundation-v1-20260609-e55ed0c`, preview evidence `https://56b58162.draxos-mobile-internal-alpha.pages.dev`. Arena PVE Bonus Visual v1 remains the previous Arena package: release root `internal-alpha/v0-arena-pve-bonus-visual-v1-20260608-e281d63`, preview evidence `https://6c8bf8e1.draxos-mobile-internal-alpha.pages.dev`. Bosque Node Cooldown ACK v1 remains the previous Bosque package: release root `internal-alpha/v0-bosque-node-cooldown-ack-v1-20260608-626b4ad`, preview evidence `https://5cce952e.draxos-mobile-internal-alpha.pages.dev`. Bosque Resume Exit Lifecycle v1 remains the previous resume/exit package: release root `internal-alpha/v0-bosque-resume-exit-lifecycle-v1-20260608-9a0f7c0`, preview evidence `https://39128c59.draxos-mobile-internal-alpha.pages.dev`. Bosque Feel & Spawn Authority v1 remains the previous feel/spawn package: release root `internal-alpha/v0-bosque-feel-spawn-authority-v1-20260608-70b79c3`, preview evidence `https://16ac3cb7.draxos-mobile-internal-alpha.pages.dev`. Bosque Persistence Rebase v1 remains the previous persistence/operations package with migrations `202606080001_openworld_bosque_persistence_rebase_v1.sql` and `202606080002_openworld_bosque_jsonb_object_length_hotfix_v1.sql`: release root `internal-alpha/v0-bosque-persistence-rebase-v1-20260608-bc23f74`, preview evidence `https://0c0a8dcf.draxos-mobile-internal-alpha.pages.dev`. Station craft stays server-authoritative and uses `Bau do Bosque` plus `Conta/Ossario`; Bosque World Hub Domain Separation v1 remains the previous local/account resource package. Bosque Fogueira Potion Crafting v1 remains the previous station-craft package. Bosque Durable Bau Mochila v1, Arena PVE Menu Flow Simplification v1, Bosque Offline-First Checkpoint v1, Bosque Sync Responsiveness v1, Arena/Bosque Visible V2 and Arena/Bosque Regression Hotfix remain preserved earlier baselines. Do not change gameplay tuning, Supabase APIs, economy, content, weapons, spells, potions, crafting, advanced behavior, final visuals or authoritative flows without an explicit package decision.
