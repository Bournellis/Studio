# DraxosMobile - Multi-Agent Workflow

- Status: `VIVO`
- Last updated: `2026-06-01`
- Scope: coordination workflow for hardening lanes, mode work and handoffs.
- Current latest Arena loop package: `Track 21 - Arena Loop Unlock And Friction Pass`.

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
9. The lane or mode contract that owns the work.

For Arena PVE or tuning-adjacent work, also read:

1. `docs/pve-arena-initial-direction.md`
2. `docs/pve-arena-v1.md`
3. `implementation/tracks/track-21-arena-loop-unlock-friction/README.md`

For behavior, potion, crafting or consumable work, also read:

1. `docs/behavior-potion-crafting-v1.md`
2. `implementation/tracks/track-16-behavior-crafting/current-status.md`

For release or validation work, also read:

1. `docs/release-ops-checklist.md`
2. `implementation/tracks/track-13-validation-release-safety/release-safety-contract.md`
3. `implementation/tracks/track-13-validation-release-safety/validation-matrix.md`

## Track Reading Rules

Track 21 is the current Arena loop package for agents to use as latest context.
Later link/status hotfixes may be recorded in `implementation/current-status.md`
or portfolio docs, but they do not reopen Track 18/19/20 contracts unless the
current task explicitly says so.

Track 18 remains the implemented Arena PVE domain contract. Track 16 remains a
technical baseline for behavior, potion and crafting systems already in alpha.
Tracks 1 and 2 are historical evidence for alpha hardening, telemetry, labs and
playtest flow. They are not active implementation tracks.

Do not start from Track 4, Track 8, Track 10, Track 15 or Track 16 as the active
product stage. Use them only when a live doc points to a specific detail.

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

Every lane must register a Doing or Handoff note before edits. Use:

- `../../08_Coordenacao_Agentes/Kanban/Doing/YYYY-MM-DD_<agent>_draxos-mobile_<slug>.md`
- `../../08_Coordenacao_Agentes/Handoffs/YYYY-MM-DD_<agent>_draxos-mobile_<slug>.md`

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

## Mode Ownership

| Mode | Current state | Owner lane | Guardrail |
|---|---|---|---|
| `basebuilder` | Active Refugio/Base loop. | `client-shell` + `session-data`. | Base changes must use account/save, ledger and idempotent server mutations. |
| `autobattler` | Active Arena PVE loop. | `backend-schema` + `client-shell` + `validation-release`. | Track 21 is latest Arena loop context; PVP remains later. |
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
3. Kanban/Handoff registration.

Do not mix runtime changes into a docs/coord commit.

## Handoff Protocol

Every final handoff must list:

- files changed;
- commits created;
- docs read;
- validation commands and results;
- blockers and out-of-scope findings;
- next owner/lane.

If the worktree is not clean, list every remaining changed file and why it
remains changed.

## Drift Checks

Before final handoff, run targeted checks appropriate to the lane:

```powershell
rg -n "Remote Lab Runner|Track 19|latest remote|Latest release root|Alvo Track" README.md docs AGENTS.md
rg -n "service_role|sb_secret_|sb_service_|SUPABASE_SERVICE_ROLE" docs ../../08_Coordenacao_Agentes
git diff --check
git status --short
```

Expected nuance: historical docs may still mention older tracks. Live entry
docs should not tell new agents that Track 16, Track 18, Track 19 or Remote Lab
Runner is the latest Arena loop package when Track 21 is the intended current
package for this hardening wave.
