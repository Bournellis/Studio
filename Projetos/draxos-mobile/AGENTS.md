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
- Latest technical package: `Track 16 - Behavior And Potion Crafting`, local and not the current product focus.
- Immediate product gate: run Foundation Audit before implementation expansion. Focus on the post-login loop: Base -> collect resources -> evolve base -> battle -> receive rewards -> check base again.

DraxosMobile is an async PVP autobattler with Refugio/Base, social systems and server-authoritative progression. The real product direction is base builder + autobattler + social, with room for future minigames and seasons. Current names, spells, weapons, economy values, battle flavor, visual style and premium systems are mock/substance for evaluation unless a live doc explicitly promotes them.

## Start Here

Read in this order for almost every task:

1. `docs/agent-operating-manual.md`
2. `implementation/current-status.md`
3. `docs/documentation-index.md`
4. `docs/foundation-app-v0-audit.md`
5. The files you intend to touch

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
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick -RequireClean:$false
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Client -RequireClean:$false
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Release -RequireClean:$false
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Full -RequireClean:$false
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
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

## Hard Stops

- Do not put `service_role`, Supabase secrets, database passwords, keystore passwords or private tokens in client code, exports, portal files, manifests or operational docs.
- Do not run remote publishing modes without explicit user approval and `-ConfirmRemoteMutation`.
- Do not start a new playable feature, numeric tuning pass, weapon/spell/economy pass, battle presentation pass, final visual pass, `account_profiles/game_saves` migration, iOS work or mobile browser support before Foundation Audit is complete and the user explicitly chooses the next package.
- Do not edit `.tscn` files as raw text unless the user explicitly asks and the change is safer than an editor/tool path.
- Do not import gameplay rules from other Draxos projects unless this project's live docs explicitly adopt them.
- Do not treat `Projetos/_conceitos/mobile-universe/` as active implementation material. It is design archive only.

## Live Source Rules

- `docs/product-vision.md` is the local long-term product canon until promoted to shared canon.
- `docs/foundation-app-v0-audit.md` is the current product/agent compass for Foundation Audit.
- `docs/game-design-document.md` is the authoritative implementation GDD.
- `docs/design-pending.md` is the only live register of unresolved design decisions.
- `docs/documentation-index.md` classifies live docs, contracts, runbooks, history and design archive.
- `implementation/current-status.md` must remain short and decision-oriented; detailed history belongs in `implementation/tracks/`.
- Supabase mirrors under `server/` and `supabase/` must stay aligned.

## Current Handoff

Foundation Audit is the active handoff. Agents must align docs and then audit the post-login internal loop before expanding implementation. Do not change gameplay tuning, backend/schema, Supabase APIs, economy, content, weapons, spells, final visuals or authoritative flows during this documentation package.
