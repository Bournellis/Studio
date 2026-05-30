# DraxosMobile - Agent Operating Manual

- Status: `VIVO`
- Owner: project agents
- Last updated: `2026-05-30`
- Applies to: `Projetos/draxos-mobile/`

This manual explains how agents should operate DraxosMobile without reopening old work, drifting from Foundation Audit or mutating remote infrastructure by accident.

## Source Of Truth

Read live docs in this order:

1. `AGENTS.md` - fast operating rules.
2. `implementation/current-status.md` - short decision snapshot.
3. `docs/documentation-index.md` - where each doc belongs.
4. `docs/foundation-app-v0-audit.md` - current Foundation Audit compass.
5. `docs/foundation-expansion-readiness.md` - active pre-expansion gate.
6. `docs/foundation-loop-audit.md` - executed audit of post-login loop ergonomics.
7. `docs/foundation-responsive-layout-contract.md` - required when touching Entry, Refugio, Battle or visual/layout code.
8. `docs/product-vision.md` - local long-term product canon.
9. `docs/game-design-document.md` - implementation reference and mock/substance context.
10. `docs/design-pending.md` - only live register of unresolved design decisions.

If a historical track conflicts with these docs, the live docs win. If local product design conflicts with shared lore in `../../canon/`, escalate instead of silently choosing.

## Current Stage

Active stage: `FOUNDATION_EXPANSION_READINESS_ACTIVE`.

The project is a base implemented for refinement. First Session Clarity v1 is approved. The current work is Foundation Expansion Readiness: hardening the foundation for production future, parallel agents, account/save authority, ruleset publication, admin auditability and client shell split before expanding base builder, autobattler, social or minigames.

The accepted loop baseline remains:

`Base -> collect resources -> evolve base -> battle -> receive rewards -> check base again`

Social Basico Guilda v1, Visual Direction v1, Battle Presentation v1, Battle Drama v1.1, Battle Preparation Complete v1, Progression Clarity v1 and First Session Clarity v1 have since been published. Do not open feature expansion until the readiness gate is green.

Track 16 remains the latest technical package, but it is not the current product focus. Its current behavior/potion/crafting state is summarized in `docs/behavior-potion-crafting-v1.md`. Current spells, weapons, economy values, Battle Pass, battle flavor and visual identity are mock/substance, not priority areas.

Foundation Expansion Readiness adds:

- `account_profiles` + `game_saves` as account/save authority;
- `foundation_ruleset_v0` generated from repo sources and registered in database;
- idempotency v1 with `request_hash`, `scope_id` and `pending/completed/failed`;
- admin audit log and reconciliation scaffold;
- `DraxosOperationState` and `DraxosAppShellActionRouter` as client shell contracts;
- minigame/admin/account-save/ruleset contracts.

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

For Foundation Audit, the expected DraxosMobile Doing card must state the branch, worktree and current loop/UX objective. Historical DraxosMobile cards belong in `Kanban/Done/`.

## Read Order By Task

| Task type | Required docs |
|---|---|
| Small code fix | `AGENTS.md`, `implementation/current-status.md`, touched files |
| Agent/doc operation | `AGENTS.md`, this manual, `docs/documentation-index.md`, `docs/foundation-app-v0-audit.md`, `docs/foundation-loop-audit.md` |
| Product/design | `docs/product-vision.md`, `docs/product-brief.md`, `docs/game-design-document.md`, `docs/design-pending.md` |
| Backend/contracts | `docs/architecture.md`, `docs/contracts/`, `server/schema/`, `server/functions/`, `supabase/` mirrors |
| Foundation expansion | `docs/foundation-expansion-readiness.md`, `docs/contracts/account-save.md`, `docs/contracts/ruleset-registry.md`, `docs/contracts/admin-ops.md`, `docs/contracts/minigame-integration.md` |
| Crafting/potions/behavior | `docs/behavior-potion-crafting-v1.md`, `docs/contracts/api-endpoints.md`, `docs/contracts/database-schema.md`, `docs/contracts/content-definitions.md`, `docs/contracts/battle-event-log.md` |
| Godot client | `AGENTS.md`, `modes/boot/surfaces/README.md`, relevant tests, relevant flow/presenter |
| Entry/Refugio/Battle layout | `docs/foundation-responsive-layout-contract.md`, `tools/smoke_responsive_layout.gd`, relevant UI tests |
| Release/publication | `docs/release-ops-checklist.md`, Track 13 release safety contract, `tools/README.md` |
| Manual QA | `docs/track-13-manual-walkthrough-gate.md`, `docs/internal-alpha-v0-handoff.md` |

## Validation By Task

Use the smallest profile that proves the change, then broaden when touching shared foundations.

| Change | Minimum validation |
|---|---|
| Docs only | `git diff --check`; `validate_foundation.ps1 -Profile Quick` when docs affect status/operation |
| PowerShell tools | `validate_foundation.ps1 -Profile Release` |
| Godot client | Godot `validate.gd`, GUT client, then `validate_foundation.ps1 -Profile Client` |
| Entry/Refugio/Battle layout | `tools/smoke_responsive_layout.gd` plus relevant GUT/client validation |
| Backend/functions | `npx -y deno task --cwd server/functions check` and `npx -y deno task --cwd supabase/functions check` |
| Release safety | `validate_foundation.ps1 -Profile Release` plus `tools/check_release_safety.ps1` |
| Foundation or cross-cutting work | `validate_foundation.ps1 -Profile Full` plus explicit Godot/GUT/Deno commands |
| Foundation expansion readiness | `tools/check_foundation_expansion_readiness.ps1`, Deno ruleset/schema tests, GUT shell contracts, then `validate_foundation.ps1 -Profile Quick` or broader |

Default full gate:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Full
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
- `Mode Package`: creates local packages only.
- `Mode Upload`, `Mode DeployManifest`, `Mode FullPublish`: remote mutation; requires explicit user approval and `-ConfirmRemoteMutation`.

Never run remote mutation modes as a drive-by validation step.

## Prohibited Or Escalated Work

Do not start these without explicit user direction and a fresh track/package:

- feature gameplay or content expansion before Foundation Loop UX Pass 01 is manually reviewed;
- social expansion before Foundation Loop UX Pass 01 is manually reviewed;
- visual-general or battle-presentation work before the loop and social order is explicitly chosen;
- numeric tuning without human playthrough and Progression Lab evidence;
- weapons, spells, Battle Pass or economy pass while they are still mock/substance;
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
