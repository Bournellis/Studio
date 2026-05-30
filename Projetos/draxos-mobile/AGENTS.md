# Agent Operating Manual - DraxosMobile

This file is the fast entrypoint for agents working in `Projetos/draxos-mobile`.

**Do not confuse this project with** `Projetos/draxos-roguelike-cardgame/`, the separate Steam roguelike cardgame.

## Current Truth

- Project: `DraxosMobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active operational stage: `Foundation Audit`
- Active stage status: `FOUNDATION_AUDIT_ACTIVE`
- Hardening baseline: `Track 13 - Foundation Validation And Release Safety` delivered on `2026-05-28`
- Agent baseline: `Track 14 - Agent Operations Foundation` is the current operations/docs foundation.
- Latest technical package: `Track 16 - Behavior And Potion Crafting`, technical context and not the current product focus. Current behavior/potion/crafting state is summarized in `docs/behavior-potion-crafting-v1.md`.
- Immediate product gate: First Session Clarity v1 is published on top of Progression Clarity v1. It should be reviewed on Android/Windows/Web before choosing social, visual, battle or content expansion. Foundation Loop UX Pass 01 is the accepted baseline.

DraxosMobile is an async PVP autobattler with Refugio/Base, social systems and server-authoritative progression. The real product direction is base builder + autobattler + social, with room for future minigames and seasons. Current names, spells, weapons, economy values, battle flavor, visual style and premium systems are mock/substance for evaluation unless a live doc explicitly promotes them.

## Start Here

Read in this order for almost every task:

1. `docs/agent-operating-manual.md`
2. `implementation/current-status.md`
3. `docs/documentation-index.md`
4. `docs/foundation-app-v0-audit.md`
5. `docs/foundation-loop-audit.md`
6. `docs/foundation-responsive-layout-contract.md` when touching Entry, Refugio, Battle or visual/layout code
7. `docs/first-session-clarity-v1.md` when touching first-session guidance, Refugio loop copy, Preparation guidance or battle summary next-step copy
8. `docs/behavior-potion-crafting-v1.md` when touching Ossos, crafting, potions, consumables or behavior
9. The files you intend to touch

For product or design work, also read:

1. `docs/product-vision.md`
2. `docs/product-brief.md`
3. `docs/game-design-document.md`
4. `docs/design-pending.md`

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

## Safe Commands

Run commands from `Projetos/draxos-mobile` unless noted.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Client
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Release
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Full
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
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Package
```

`Mode Upload`, `Mode DeployManifest` and `Mode FullPublish` require explicit user approval and `-ConfirmRemoteMutation`.

For user-approved product packages that require human testing on Android, Windows or Web, publication to Internal Alpha is the default completion step after local validation. Use a fresh versioned release root, export/package/upload/deploy from the same worktree session, and verify the published Web shell against the remote `index.pck`/`index.wasm` sizes before reporting success.

## Hard Stops

- Do not put `service_role`, Supabase secrets, database passwords, keystore passwords or private tokens in client code, exports, portal files, manifests or operational docs.
- Do not run remote publishing modes without explicit user approval and `-ConfirmRemoteMutation`.
- Do not start a new playable feature, numeric tuning pass, weapon/spell/economy pass, potion/consumable expansion, advanced behavior pass, battle presentation pass, final visual pass, `account_profiles/game_saves` migration, iOS work or mobile browser support before Foundation Audit is complete and the user explicitly chooses the next package.
- Do not edit `.tscn` files as raw text unless the user explicitly asks and the change is safer than an editor/tool path.
- Do not publish Entry/Refugio/Battle layout changes unless `tools/smoke_responsive_layout.gd` passes.
- Do not import gameplay rules from other Draxos projects unless this project's live docs explicitly adopt them.
- Do not treat `Projetos/_conceitos/mobile-universe/` as active implementation material. It is design archive only.

## Live Source Rules

- `docs/product-vision.md` is the local long-term product canon until promoted to shared canon.
- `docs/foundation-app-v0-audit.md` is the current product/agent compass for Foundation Audit.
- `docs/foundation-loop-audit.md` is the executed audit for loop ergonomics and the next UX pass criteria.
- `docs/foundation-responsive-layout-contract.md` is the guardrail for responsive Entry Labs, Refugio and Battle safe frames.
- `docs/behavior-potion-crafting-v1.md` is the live bridge for Track 16 behavior, potion and crafting systems already present in the alpha baseline.
- `docs/game-design-document.md` is the authoritative implementation GDD.
- `docs/design-pending.md` is the only live register of unresolved design decisions.
- `docs/documentation-index.md` classifies live docs, contracts, runbooks, history and design archive.
- `implementation/current-status.md` must remain short and decision-oriented; detailed history belongs in `implementation/tracks/`.
- Supabase mirrors under `server/` and `supabase/` must stay aligned.

## Current Handoff

First Session Clarity v1 is the current published handoff inside the broader Foundation Audit. Agents should review it on Android/Windows/Web, including a quick regression pass through Preparation potion/behavior controls and the Refugio -> reward -> base return loop, before expanding implementation. Do not change gameplay tuning, backend/schema, Supabase APIs, economy, content, weapons, spells, potions, crafting, advanced behavior, final visuals or authoritative flows without an explicit package decision.
