# DraxosMobile - Agent Operating Manual

- Status: `VIVO`
- Owner: project agents
- Last updated: `2026-05-28`
- Applies to: `Projetos/draxos-mobile/`

This manual explains how agents should operate DraxosMobile without reopening old work, drifting from the current track or mutating remote infrastructure by accident.

## Source Of Truth

Read live docs in this order:

1. `AGENTS.md` - fast operating rules.
2. `implementation/current-status.md` - short decision snapshot.
3. `docs/documentation-index.md` - where each doc belongs.
4. `docs/product-vision.md` - local long-term product canon.
5. `docs/game-design-document.md` - authoritative implementation design.
6. `docs/design-pending.md` - only live register of unresolved design decisions.
7. `implementation/tracks/track-14-agent-ops-foundation/` - current agent foundation work.

If a historical track conflicts with these docs, the live docs win. If local product design conflicts with shared lore in `../../canon/`, escalate instead of silently choosing.

## Current Baseline

The hardening base is `Track 13 - Foundation Validation And Release Safety`, delivered on `2026-05-28`. Preserve these deliverables:

- Kanban cleanup from Track 11.
- Short status and release-state sync from Track 11.
- Manual walkthrough docs from Track 11 and Track 13.
- Boot decomposition from Track 12.
- `tools/validate_foundation.ps1`.
- Safe release modes in `tools/publish_internal_alpha.ps1`.
- Release safety/readiness checks.

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

For Track 14, the only DraxosMobile Doing card should be the agent-ops foundation card. Historical DraxosMobile cards belong in `Kanban/Done/`.

## Read Order By Task

| Task type | Required docs |
|---|---|
| Small code fix | `AGENTS.md`, `implementation/current-status.md`, touched files |
| Agent/doc operation | `AGENTS.md`, this manual, `docs/documentation-index.md`, active track |
| Product/design | `docs/product-vision.md`, `docs/product-brief.md`, `docs/game-design-document.md`, `docs/design-pending.md` |
| Backend/contracts | `docs/architecture.md`, `docs/contracts/`, `server/schema/`, `server/functions/`, `supabase/` mirrors |
| Godot client | `AGENTS.md`, `modes/boot/surfaces/README.md`, relevant tests, relevant flow/presenter |
| Release/publication | `docs/release-ops-checklist.md`, Track 13 release safety contract, `tools/README.md` |
| Manual QA | `docs/track-13-manual-walkthrough-gate.md`, `docs/internal-alpha-v0-handoff.md` |

## Validation By Task

Use the smallest profile that proves the change, then broaden when touching shared foundations.

| Change | Minimum validation |
|---|---|
| Docs only | `git diff --check`; `validate_foundation.ps1 -Profile Quick -RequireClean:$false` when docs affect status/operation |
| PowerShell tools | `validate_foundation.ps1 -Profile Release -RequireClean:$false` |
| Godot client | Godot `validate.gd`, GUT client, then `validate_foundation.ps1 -Profile Client -RequireClean:$false` |
| Backend/functions | `npx -y deno task --cwd server/functions check` and `npx -y deno task --cwd supabase/functions check` |
| Release safety | `validate_foundation.ps1 -Profile Release -RequireClean:$false` plus `tools/check_release_safety.ps1` |
| Foundation or cross-cutting work | `validate_foundation.ps1 -Profile Full -RequireClean:$false` plus explicit Godot/GUT/Deno commands |

Default full gate:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Full -RequireClean:$false
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
npx -y deno task --cwd server/functions check
npx -y deno task --cwd supabase/functions check
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

- feature gameplay after Track 13 without manual walkthrough results;
- numeric tuning without human playthrough and Progression Lab evidence;
- account/save migration from `players.save_type` to `account_profiles/game_saves`;
- iOS or mobile browser support;
- final asset production;
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

Keep `implementation/current-status.md` short. Put detailed history, logs and validation notes in the active track directory.
