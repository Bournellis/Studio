# DraxosMobile - Agent Operating Manual

- Status: `VIVO`
- Owner: project agents
- Last updated: `2026-06-05`
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

If a historical track conflicts with these docs, the live docs win. If local product design conflicts with shared lore in `../../canon/`, escalate instead of silently choosing.

## Current Stage

Active stage: `BOSQUE_V3_UX_FEEL_PUBLISHED_INTERNAL_ALPHA`.
Previous hardening baseline marker: `FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA`.

The project is a base implemented for refinement. First Session Clarity v1 is approved. Foundation Expansion Readiness, Foundation Closeout, Lab Track 16 Alignment and Hardening Platform V1 are delivered. Bosque v3 UX/Feel is the latest remote Internal Alpha publication from `master`, release root `internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, and preview evidence `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`. Technical Hardening remains the previous technical package, release root `internal-alpha/v0-technical-hardening-20260605-8e54a1f`, preview evidence `https://2fe9393e.draxos-mobile-internal-alpha.pages.dev`. Openworld Main Menu Sync remains the previous content package, release root `internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`, preview evidence `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`. Foundation Hardening V2 is the previous hardening/live-doc enforcement baseline, release root `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview evidence `https://ca946749.draxos-mobile-internal-alpha.pages.dev`, and remains the enforcement reference for multi-agent and multi-mode expansion work.

Historical app-shell loop baseline from Foundation Loop UX Pass 01, preserved for context but not the current product reading:

`Base -> collect resources -> evolve base -> battle -> receive rewards -> check base again`

The selected first product loop is:

`Refugio -> Arena PVE selection -> start attempt with loadout locked -> duel list -> temporary stat buffs and behavior prep between duels -> rewards -> continue in Arena -> upgrades`

Track 18 delivers server-authoritative Arena attempts/steps/progress, arena Edge Functions, separate PVE content/reward definitions, a Refugio Arena shell and lab outputs for Arena sequences/attempts. Track 19 tightens that contract: potion stock is live and consumed per duel, public Arena buff selection is `/arena/pve/buff/select`, `/arena/buff/choose` is internal/compatibility only, Arena reward/progress mutation happens on the final `/arena/pve/duel/request`, and `/arena/pve/claim` is summary/ack with `mutates_economy: false`. Track 20 promotes the Season 1 arena tier matrix to labs, generated Edge catalog, backend runtime and client selection by `arena_id + difficulty_id`. Track 21 fixes tutorial unlock by recalculating `players.level` when Arena completion XP is applied, starts attempts directly in the active duel route, and returns from summary to refreshed Arena selection. Hardening Platform V1 adds the multi-agent lane protocol, official mode descriptors, bounded shell/session/backend modules, audited mode admin RPCs, Reward Bridge V1 and expanded validation/release gates. Foundation Hardening V2 then adds strict expansion gates, mode decision packs, backend boundary inventory, read-only ops, Android release signing, V2 schema enforcement and remote publication evidence. First Access Runtime Fix adds immediate local shell rendering for no-cache first access, Arena first-access sync shell without dev fallback actions, repaired local Edge/DatabaseLocal proof and mode live coverage aligned to active Bosque v1. Bosque Mecanico Basico v2 adds the free Bosque minigame reading with optional server-persisted guidance, fixed resource slack, `Encerrar visita` without mandatory objective and procedural blocking `fogueira_estavel_1`. Openworld Main Menu Sync publishes the rollback fix for all 26 Bosque resource nodes and the simplified player-facing main menu to the production Pages URL. Technical Hardening publishes shared verified auth across mutable/lab/release endpoints, request-hash account reset, DB-side Arena reward profiles and extract-only client hotspot refactors without changing tuning/content. Bosque v3 UX/Feel publishes a narrow Bosque polish package with safer resource placement/collision slack, visible proximity/pickup states, clearer collect/deposit/craft/session feedback, fogueira glow, nonblocking landmarks and player-facing visit summaries. Remote Lab Runner remains part of the published alpha and keeps Battle Lab and Progression Lab usable in Web export by calling Edge `lab-runner` with the same Supabase email/password Internal Alpha account gate and registered `normal` save used by the game; it never exposes service role to the client/export and does not mutate economy, ranking, save progress or files. The next step is human review/playtest of the Bosque v3 UX/Feel package, then focused packages from updated `master`. Future remote mutation still requires explicit approval and `-ConfirmRemoteMutation`.

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
- canonical post-hardening base branch: updated `master` after Foundation Hardening V2 is merged.

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
