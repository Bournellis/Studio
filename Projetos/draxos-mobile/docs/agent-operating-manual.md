# DraxosMobile - Agent Operating Manual

- Status: `VIVO`
- Owner: project agents
- Last updated: `2026-06-09`
- Applies to: `Projetos/draxos-mobile/`

This manual explains how agents should operate DraxosMobile without reopening old work, drifting from Foundation Audit or mutating remote infrastructure by accident.

## Source Of Truth

Read live docs in this order:

1. `AGENTS.md` - fast operating rules.
2. `implementation/current-status.md` - short decision snapshot.
3. `docs/documentation-index.md` - where each doc belongs.
4. `docs/foundation-app-v0-audit.md` - historical Foundation Audit compass for closed baseline context.
5. `docs/foundation-expansion-readiness.md` - delivered pre-expansion gate and closeout contract base.
6. `docs/foundation-loop-audit.md` - executed audit of post-login loop ergonomics.
7. `docs/foundation-responsive-layout-contract.md` - required when touching Entry, Refugio, Battle or visual/layout code.
8. `docs/product-vision.md` - local long-term product canon.
9. `docs/pve-arena-initial-direction.md` - approved early-game direction.
10. `docs/game-design-document.md` - implementation reference and mock/substance context.
11. `docs/design-pending.md` - only live register of unresolved design decisions.
12. `docs/multi-agent-workflow.md` - required when coordinating parallel hardening lanes or mode work.
13. `docs/hardening-program.md` - required for long-term refactor/hardening gates across active lanes.

If a historical track conflicts with these docs, the live docs win. If local product design conflicts with shared lore in `../../canon/`, escalate instead of silently choosing.

## Current Stage

Active stage: `BOSQUE_DIEGETIC_LAUNCHER_FOUNDATION_V1_PUBLISHED_INTERNAL_ALPHA`.
Previous hardening baseline marker: `FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA`.

The project is a base implemented for refinement. Bosque Diegetic Launcher Foundation v1 is the latest remote Internal Alpha publication: release root `internal-alpha/v0-bosque-diegetic-launcher-foundation-v1-20260609-e55ed0c`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, preview evidence `https://56b58162.draxos-mobile-internal-alpha.pages.dev`, APK/manifest `0.0.16-alpha.0` / version code `16`, minimum supported version code `13`. It publishes the Bosque diegetic launcher foundation, where five player-facing landmarks open Arena PVE, Refugio/Base, Shop, Social and Profile through shell actions and return to the Bosque when possible. It also preserves the Bootstrap Authority guard that keeps the playable viewport hidden until canonical remote/cache bootstrap completes.

Initial human playtest of the previous Bosque Bootstrap Authority v1 package was reported OK by Fabio on `2026-06-09`: everything tested at that point appeared to work. The current operational next step is focused human playtest of Bosque Diegetic Launcher Foundation v1 on Web/APK, especially landmark prompts/actions, menu routing and `Voltar` returning to the Bosque. Future bugs return to the normal bugfix flow if they appear.

Bosque Bootstrap Authority v1 remains the previous bootstrap package: release root `internal-alpha/v0-bosque-bootstrap-authority-v1-20260609-ba99e70`, preview evidence `https://0123894f.draxos-mobile-internal-alpha.pages.dev`. Arena PVE Bonus Visual v1 remains the previous Arena package: release root `internal-alpha/v0-arena-pve-bonus-visual-v1-20260608-e281d63`, preview evidence `https://6c8bf8e1.draxos-mobile-internal-alpha.pages.dev`. It fixes Arena PVE temporary buffs between fights by exporting initial buffed HP/Mana in the battle log and making replay apply `battle_start` before the first action. Bosque Node Cooldown ACK v1 remains the previous Bosque package: release root `internal-alpha/v0-bosque-node-cooldown-ack-v1-20260608-626b4ad`, preview evidence `https://5cce952e.draxos-mobile-internal-alpha.pages.dev`. Bosque Resume Exit Lifecycle v1 remains the previous resume/exit package: release root `internal-alpha/v0-bosque-resume-exit-lifecycle-v1-20260608-9a0f7c0`, preview evidence `https://39128c59.draxos-mobile-internal-alpha.pages.dev`. Bosque Feel & Spawn Authority v1 remains the previous feel/spawn package: release root `internal-alpha/v0-bosque-feel-spawn-authority-v1-20260608-70b79c3`, preview evidence `https://16ac3cb7.draxos-mobile-internal-alpha.pages.dev`. Bosque Persistence Rebase v1 remains the previous persistence/operations package: release root `internal-alpha/v0-bosque-persistence-rebase-v1-20260608-bc23f74`, preview evidence `https://0c0a8dcf.draxos-mobile-internal-alpha.pages.dev`. It made Bosque durable progress server-authoritative through ACK-backed checkpoint operations, persisted `openworld_forest_progress_v2`, stored node cooldowns in `node_state.next_spawn_at`, treated local pending ops/cache as preview/retry only, and persisted/unlocked `Fogueira Estavel I` only after server-confirmed `structures.fogueira_estavel_1`. Bosque Session Lifecycle & Durable Structures Hotfix v1 remains the previous session lifecycle package: release root `internal-alpha/v0-bosque-session-lifecycle-structures-hotfix-v1-20260607-c953b51`, preview evidence `https://8ecac093.draxos-mobile-internal-alpha.pages.dev`. Bosque World Hub Domain Separation v1 remains the previous local/account domain package: release root `internal-alpha/v0-bosque-world-hub-domain-separation-v1-20260606-81ecf05`, preview evidence `https://d1872010.draxos-mobile-internal-alpha.pages.dev`. It separated Bosque-local materials from account resources and introduced `BosqueWorldContext`. Bosque Fogueira Potion Crafting v1 remains the previous station-craft package: release root `internal-alpha/v0-bosque-fogueira-potion-crafting-v1-20260606-cad6d2c`, preview evidence `https://08d00f24.draxos-mobile-internal-alpha.pages.dev`. It introduced the server-authoritative Fogueira bridge for global potions using Bosque chest materials plus account `po_osso`. Bosque Durable Bau Mochila v1 remains the previous durable Openworld progress package: release root `internal-alpha/v0-bosque-durable-bau-mochila-v1-20260606-6e7ca6b`, preview evidence `https://39198a35.draxos-mobile-internal-alpha.pages.dev`. Arena PVE Menu Flow Simplification v1 remains the previous Arena menu package: release root `internal-alpha/v0-arena-pve-menu-flow-simplification-v1-20260606-5d03a68`, preview evidence `https://fdf44707.draxos-mobile-internal-alpha.pages.dev`. Bosque Offline-First Checkpoint v1 remains the previous Openworld policy package: release root `internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22`, preview evidence `https://fa84e109.draxos-mobile-internal-alpha.pages.dev`. Bosque Sync Responsiveness v1 remains the previous Bosque sync package. Arena/Bosque Visible V2, Arena/Bosque Regression Hotfix, Arena PVE Season 1 Loop v1, Arena Duel Flow Hotfix, Arena PVE First Real Run + Update Recovery, Bosque v3 UX/Feel, Technical Hardening and Openworld Main Menu Sync remain preserved previous packages. Foundation Hardening V2 remains the previous hardening/live-doc enforcement baseline and enforcement reference for multi-agent and multi-mode expansion work: release root `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview evidence `https://ca946749.draxos-mobile-internal-alpha.pages.dev`.

Historical app-shell loop baseline from Foundation Loop UX Pass 01, preserved for context but not the current product reading:

`Base -> collect resources -> evolve base -> battle -> receive rewards -> check base again`

The selected first product loop is:

`Refugio -> Arena PVE selection -> start attempt with loadout locked -> duel list -> temporary stat buffs and behavior prep between duels -> rewards -> continue in Arena -> upgrades`

Track 18 through Track 23 remain the Arena PVE/Autobattler context: server-authoritative Arena attempts/steps/progress, public buff select endpoint, Season 1 arena/difficulty matrix, active attempt recovery, no combat cooldown, locked loadout on start, temporary stat buffs, HP reset per duel, live-stock potion consumption in Arena, summary-only claim and continue-in-Arena flow. Arena Menu Flow Simplification v1 adds only menu hierarchy and CTA order on top of that lineage. Remote Lab Runner remains preserved for Battle Lab and Progression Lab in Web export and never exposes service role or mutates economy/ranking/save progress. Operationally, Bosque Diegetic Launcher Foundation v1 is the current published package; product-wise, Arena PVE remains the first approved core and Bosque/Openworld remains an integrated Internal Alpha slice, not approval for broad expansion. Future remote mutation still requires explicit approval and `-ConfirmRemoteMutation`.

Social Basico Guilda v1, Visual Direction v1, Battle Presentation v1, Battle Drama v1.1, Battle Preparation Complete v1, Progression Clarity v1 and First Session Clarity v1 have since been published. Do not open feature expansion outside the Arena PVE initial package.

Track 16 remains the latest technical package, but it is not the current product focus. Its current behavior/potion/crafting state is summarized in `docs/behavior-potion-crafting-v1.md`. Current spells, weapons, economy values, Battle Pass, battle flavor and visual identity are mock/substance, not priority areas.

Foundation Expansion Readiness adds:

- `account_profiles` + `game_saves` as account/save authority;
- `foundation_ruleset_v0` generated from repo sources and registered in database;
- idempotency v1 with `request_hash`, `scope_id` and `pending/completed/failed`;
- admin audit log and reconciliation scaffold;
- `DraxosOperationState` and `DraxosAppShellActionRouter` as client shell contracts;
- minigame/admin/account-save/ruleset contracts.

Foundation Final Polish adds:

- `boot.gd`, `boot_runtime.gd`, `hub_surface_presenter.gd` and `hub_surface_full_presenter.gd` budgets guarded by validation; oversized runtime/presenter files are blockers, not accepted hardening state;
- read-only `SessionStore` domain slices for presenters touched by the split;
- source guards against presenters calling Supabase, telemetry, direct mutations or direct request-id creation;
- `foundation_admin_rls_live_smoke.ts` proving local RLS/admin behavior with
  `anon/authenticated` blocked by grants and `service_role` allowed;
- canonical post-hardening base branch: updated `main` after Foundation Hardening V2 and later Arena packages are merged.

## Current Baseline

The hardening base is `Track 13 - Foundation Validation And Release Safety`, delivered on `2026-05-28`. Preserve these deliverables:

- Kanban cleanup from Track 11.
- Short status and release-state sync from Track 11.
- Manual walkthrough docs from Track 11 and Track 13.
- Boot decomposition from Track 12.
- `tools/validate_foundation.ps1`.
- Safe release modes in `tools/publish_internal_alpha.ps1`.
- Release safety/readiness checks.
- Track 14 agent operating manual, documentation index and drift guards.

Do not reimplement those systems unless validation proves they regressed.

## Worktree And Coordination

Default branch and worktree:

```text
D:\Estudio-worktrees\draxos-mobile--codex--<slug>
codex/draxos-mobile/<slug>
```

Before editing shared coordination or project entry docs:

```powershell
git status --short
git worktree list
```

Register work in `../../08_Coordenacao_Agentes/Kanban/Doing/` or a handoff note. Include:

- objective;
- branch and worktree;
- base branch/commit;
- intended files;
- docs already read;
- validation plan;
- next handoff point.

For parallel hardening lanes or mode work, use `docs/multi-agent-workflow.md`
and the DraxosMobile templates in `../../08_Coordenacao_Agentes/Templates/`.
Those templates force lane, mode, write scope, latest Track 21 context and
remote-mutation status into the handoff.

For Foundation Audit, the expected DraxosMobile Doing card must state the branch, worktree and current loop/UX objective. Historical DraxosMobile cards belong in `Kanban/Done/`.

## Read Order By Task

| Task type | Required docs |
|---|---|
| Small code fix | `AGENTS.md`, `implementation/current-status.md`, touched files |
| Agent/doc operation | `AGENTS.md`, this manual, `docs/documentation-index.md`, `docs/foundation-app-v0-audit.md`, `docs/foundation-loop-audit.md` |
| Multi-agent hardening | `AGENTS.md`, this manual, `docs/multi-agent-workflow.md`, `docs/documentation-index.md`, `docs/foundation-hardening-v2-readiness-report.md` |
| Long-term refactor/hardening | `AGENTS.md`, this manual, `docs/hardening-program.md`, `docs/multi-agent-workflow.md`, touched lane contracts |
| Product/design | `docs/product-vision.md`, `docs/pve-arena-initial-direction.md`, `docs/product-brief.md`, `docs/game-design-document.md`, `docs/design-pending.md` |
| Backend/contracts | `docs/architecture.md`, `docs/contracts/`, `server/schema/`, `server/functions/`, `supabase/` mirrors |
| Foundation expansion/final polish | `docs/foundation-expansion-readiness.md`, `docs/contracts/account-save.md`, `docs/contracts/ruleset-registry.md`, `docs/contracts/admin-ops.md`, `docs/contracts/minigame-integration.md` |
| Crafting/potions/behavior | `docs/behavior-potion-crafting-v1.md`, `docs/contracts/api-endpoints.md`, `docs/contracts/database-schema.md`, `docs/contracts/content-definitions.md`, `docs/contracts/battle-event-log.md` |
| Godot client | `AGENTS.md`, `modes/boot/surfaces/README.md`, relevant tests, relevant flow/presenter |
| Entry/Refugio/Battle layout | `docs/foundation-responsive-layout-contract.md`, `tools/smoke_responsive_layout.gd`, relevant UI tests |
| Release/publication | `docs/release-ops-checklist.md`, Track 13 release safety contract, `tools/README.md` |
| Manual QA | `docs/track-13-manual-walkthrough-gate.md`, `docs/internal-alpha-v0-handoff.md` |

## Validation By Task

Use the smallest profile that proves the change, then broaden when touching shared foundations.

| Change | Minimum validation |
|---|---|
| Docs only | `git diff --check`; `validate_foundation.ps1 -Profile DocsOnly` when docs affect status/operation |
| Hardening/refactor setup | `validate_foundation.ps1 -Profile DocsOnly`, including `tools/check_hardening_contracts.ps1` |
| PowerShell tools | `validate_foundation.ps1 -Profile ReleaseDryRun` |
| Godot client | Godot `validate.gd`, GUT client, then `validate_foundation.ps1 -Profile ClientQuick` |
| Entry/Refugio/Battle layout | `tools/smoke_responsive_layout.gd` plus relevant GUT/client validation |
| Backend/functions | `npx -y deno task --cwd server/functions check` and `npx -y deno task --cwd supabase/functions check` |
| Mode platform | `validate_foundation.ps1 -Profile ModePlatform` |
| Database/RLS local | `validate_foundation.ps1 -Profile DatabaseLocal` when local Supabase/Edge stack is running |
| Release safety | `validate_foundation.ps1 -Profile ReleaseDryRun` plus `tools/check_release_safety.ps1` |
| Foundation or cross-cutting work | `validate_foundation.ps1 -Profile FullLocal` plus explicit Godot/GUT/Deno commands when needed |
| Foundation expansion readiness | `tools/check_foundation_expansion_readiness.ps1`, Deno ruleset/schema tests, GUT shell contracts, then `validate_foundation.ps1 -Profile ServerQuick` or broader |

Default full gate:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile FullLocal -RequireClean
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd
npx -y deno task --cwd server/functions check
npx -y deno task --cwd supabase/functions check
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .
git diff --check
git status --short
```

## Release Safety

`tools/publish_internal_alpha.ps1` is intentionally safe by default:

- `Mode Plan`: default; produces a plan and performs no local package, upload, deploy, secret update or remote verification.
- `Mode Package`: creates local packages only and requires a fresh versioned `-ReleaseRoot`.
- `Mode Upload`, `Mode DeployManifest`, `Mode FullPublish`: remote mutation; requires explicit user approval, a fresh versioned `-ReleaseRoot` and `-ConfirmRemoteMutation`.

`validate_foundation.ps1 -Profile FullPublish` is disabled by design. Use the validation runner for `ReleaseDryRun`, `FullLocal` or targeted gates, then publish through `publish_internal_alpha.ps1` only in an approved publication task.

Never run remote mutation modes as a drive-by validation step.

## Prohibited Or Escalated Work

Do not start these outside the approved Arena PVE initial package without explicit user direction and a fresh track/package:

- feature gameplay or content expansion unrelated to Arena PVE initial;
- PVP-first, social expansion, visual-general or battle-presentation work before the Arena PVE package proves the early loop;
- numeric tuning without Arena PVE Battle Lab/Progression Lab evidence and human playthrough;
- weapons, spells, Battle Pass or economy pass while they are still mock/substance, except where Arena PVE rewards/power require a narrow documented value;
- new potions, consumable expansion, custom thresholds, spell priorities, enemy-specific behavior or behavior tuning outside an explicit package;
- bypassing `account_profiles/game_saves` for new account/save work;
- iOS or mobile browser support;
- final asset production;
- publishing visual/layout changes before `tools/smoke_responsive_layout.gd` passes;
- remote publication;
- secret handling outside ignored local env files.

Do not place secret-like values in:

- Godot client files;
- portal files;
- manifest examples;
- exported artifacts;
- docs meant for agents;
- Git history.

## Handoff Expected

Every handoff should say:

- what changed;
- what remains blocked;
- validation commands and results;
- whether generated files appeared under `build/` or caches;
- whether the worktree is clean;
- next safe action for the following agent.

Keep `implementation/current-status.md` short. Put detailed history, logs and validation notes in the Foundation Audit handoff, Kanban Done card or relevant historical track directory.
