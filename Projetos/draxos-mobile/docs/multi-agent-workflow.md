# DraxosMobile - Multi-Agent Workflow

## Metadata

- status: `living`
- authority: `runbook`
- last_verified: `2026-07-17`
- review_when: `lane ownership or worktree closure changes`
- supersedes: `none`
- superseded_by: `none`

- Status: `VIVO`
- Last updated: `2026-06-09`
- Scope: coordination workflow for hardening lanes, mode work and handoffs.
- Current published package: see `../implementation/current-status.md`.
- Previous hardening/live-doc baseline: `Foundation Hardening V2`.
- Current Arena/Autobattler context: Track 18/20/21 plus preserved Arena PVE packages, including Arena PVE Bonus Visual v1.

## Purpose

This workflow keeps parallel agents from reopening old tracks, editing each
other's worktrees or drifting from the current DraxosMobile product reading.

It is a coordination document only. It does not authorize runtime, schema,
Supabase, Cloudflare, tuning, economy, content or publication changes.

## Authority Stack

Read in this order before touching files:

1. `../../08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `../../Projetos/README.md`
3. `../../08_Coordenacao_Agentes/Estado_Atual.md`
4. `AGENTS.md`
5. `implementation/current-status.md`
6. `docs/documentation-index.md`
7. `docs/agent-operating-manual.md`
8. This file.
9. `docs/hardening-program.md` for long-term refactor/hardening work.
10. The lane or mode contract that owns the work.

For Arena PVE or tuning-adjacent work, also read:

1. `docs/pve-arena-initial-direction.md`
2. Arena section of `docs/game-design-document.md`
3. `docs/contracts/content-definitions.md`
4. `docs/contracts/api-endpoints.md` and `docs/contracts/database-schema.md`

For behavior, potion, crafting or consumable work, also read:

1. Behavior/crafting sections of `docs/game-design-document.md`
2. `docs/contracts/content-definitions.md`, `docs/contracts/api-endpoints.md` and `docs/contracts/database-schema.md`

For release or validation work, also read:

1. `docs/release-ops-checklist.md`
2. `docs/contracts/release-safety.md`
3. `qa/validation-matrix.md`

## Track Reading Rules

The current published Internal Alpha package, release evidence, URLs, versions
and next operational step live in `../implementation/current-status.md`; full
package lineage lives in `release-history.md`.
Foundation Hardening V2 remains the previous baseline for multi-agent and
multi-mode enforcement. Hardening Platform V1 remains the previous platform
baseline. Arena PVE remains the first approved product core; Track 18/20/21 and
the later preserved Arena packages remain Autobattler/Arena context. Bosque/Openworld
is an integrated Internal Alpha slice, not authorization for broad expansion.
Later link/status hotfixes may be recorded in
`implementation/current-status.md` or portfolio docs, but they do not reopen
Track 18/19/20 contracts unless the current task explicitly says so.

Closed tracks remain historical delivery context in `implementation/history.md`
and `implementation/history-ledger/`; they are not active implementation
contracts. Recover an exact removed track file only through the approved
Documentation Lite receipt and baseline Git when a historical question requires it.

## Worktree Rule

Implementation, documentation, contract, backend, client, validation, release
and coordination changes must use a dedicated worktree outside `D:\Estudio`.

Default path:

```text
D:\Estudio-worktrees\draxos-mobile--<agent>--<slug>
```

Codex branch pattern:

```text
codex/draxos-mobile/<slug>
```

Before touching shared files or coordination docs, run:

```powershell
git status --short
git worktree list
```

Never edit another agent's worktree unless Fabio explicitly asks for that
intervention.

## Required Registration

Every lane must register a local Doing or Handoff note before edits. Use:

- `08_Coordenacao/Kanban/Doing/YYYY-MM-DD_<agent>_<slug>.md`
- `08_Coordenacao/Handoffs/YYYY-MM-DD_<agent>_<slug>.md`

Use the DraxosMobile templates:

- `../../08_Coordenacao_Agentes/Templates/DraxosMobile_Hardening_Doing_TEMPLATE.md`
- `../../08_Coordenacao_Agentes/Templates/DraxosMobile_Hardening_Handoff_TEMPLATE.md`

The registration must name branch, worktree, objective, lane, mode if any,
intended files, docs read, validation plan and the next handoff point.

## Hardening Lanes

| Lane | Primary scope | Typical write scope | Minimum validation |
|---|---|---|---|
| `coord-docs` | Agent workflow, templates, entrypoint docs, readiness report and handoff map. | `docs/*.md`, coordination templates, Doing/Handoff notes. | `git diff --check`, targeted `rg` drift checks. |
| `backend-schema` | Contracts, migrations, Edge Functions, server/supabase mirrors and RPCs. | `docs/contracts/`, `server/`, `supabase/`, tests. | Deno checks/tests, mirror/schema checks, no remote mutation without approval. |
| `session-data` | Account/save authority, idempotency, save reset, data ownership and replay/history state. | Account/save contracts, server/supabase functions/tests, client adapters only when needed. | Contract tests, idempotency tests, no `players.save_type` as new authority. |
| `client-shell` | Entry, Refugio, Arena shell, route/state handling, responsive surfaces. | `modes/boot/`, presenters, tests/client, responsive smokes. | GUT/client, `smoke_responsive_layout.gd`, shell budget checks. |
| `mode-scaffolds` | Official mode catalog, mode entry, staged modes and disabled mode affordances. | Mode contracts, registry data, mode shell docs/client/server only if selected. | Mode contract tests, `/modes` checks, no `/minigames` revival. |
| `platform-v1` | Mode Platform V1 readiness, analytics/admin/reward bridge alignment and cross-mode boundaries. | `docs/contracts/minigame-platform-v1.md`, platform docs/tests. | Platform contract tests, foundation expansion readiness checks. |
| `validation-release` | Release safety, local/full gates, publish plan/package and remote read-only smokes. | Release runbooks, validation matrices, reports. | Track 13 gates; remote mutation only with task approval and `-ConfirmRemoteMutation`. |

For long-term hardening, `docs/hardening-program.md` is the change-type matrix
that maps each lane to the minimum validation profile and non-negotiable
account/save, lab-authority and release-safety boundaries.

## Mode Ownership

| Mode | Current state | Owner lane | Guardrail |
|---|---|---|---|
| `basebuilder` | Active Refugio/Base loop. | `client-shell` + `session-data`. | Base changes must use account/save, ledger and idempotent server mutations. |
| `autobattler` | Active Arena PVE loop. | `backend-schema` + `client-shell` + `validation-release`. | Track 21 is preserved Arena loop context; PVP remains later. |
| `openworld` | Internal alpha slice. | `mode-scaffolds` + `platform-v1`. | Keep Openworld Bosque separate from Arena and do not promote broader RPG scope. |
| `towerdefense` | Staged/disabled. | `mode-scaffolds`. | Visible registry only; no playable feature or reward promise. |
| `cardgame` | Staged/disabled. | `mode-scaffolds`. | No mechanical inheritance from `draxos-roguelike-cardgame`. |

## Write Scope Protocol

Use the smallest possible write scope.

- A lane may read any live docs needed for context.
- A lane should only write files declared in its Doing note.
- A lane that discovers another lane's issue records it in Handoff instead of
  editing outside scope.
- Runtime files, migrations, functions and generated data are off limits for
  coord/docs unless Fabio explicitly reassigns the lane.
- Remote publication, deploy, upload, `supabase db push`, secret mutation and
  Wrangler deploy are off limits unless the task explicitly approves remote
  mutation and the command uses `-ConfirmRemoteMutation` where applicable.

## Commit Protocol

Use coherent commits by stage. Suggested split:

1. Coordination/workflow docs.
2. Entrypoint/status link sync.
3. Local coordination registration or compact closure history.

Do not mix runtime changes into a docs/coord commit.

## Handoff Protocol

Every real transfer handoff must list:

- files changed;
- commits created;
- docs read;
- validation commands and results;
- blockers and out-of-scope findings;
- next owner/lane.

If the worktree is not clean, list every remaining changed file and why it
remains changed. A closed handoff is transient and is later absorbed by the
Documentation Lite lifecycle.

## Drift Checks

Before final handoff, run targeted checks appropriate to the lane:

```powershell
rg -n "Remote Lab Runner|Track 19|latest remote|Latest release root|Alvo Track" README.md docs AGENTS.md
rg -n "service_role|sb_secret_|sb_service_|SUPABASE_SERVICE_ROLE" docs ../../08_Coordenacao_Agentes
git diff --check
git status --short
```

Expected nuance: historical docs may still mention older tracks. Live entry
docs should not tell new agents that Track 16, Track 18, Track 19, Track 21,
Remote Lab Runner, Hardening Platform V1, Foundation Hardening V2, Openworld
Main Menu Sync, Technical Hardening, Bosque v3 UX/Feel, Arena PVE First Real Run,
Arena PVE Season 1 Loop v1, Arena/Bosque Regression Hotfix, Arena PVE Menu Flow
Simplification v1, Bosque Fogueira Potion Crafting v1, Bosque Feel & Spawn
Authority v1 or Bosque Bootstrap Authority v1 is the latest remote package.
The current publication must be read from `../implementation/current-status.md`;
Foundation Hardening V2 remains valid as hardening/live-doc baseline, and Track
21 remains valid as Arena loop context.
