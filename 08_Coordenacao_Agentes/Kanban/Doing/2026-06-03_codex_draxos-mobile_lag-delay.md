# DraxosMobile - Lag Delay Responsiveness Pass

- Date: `2026-06-03`
- Agent: `codex`
- Project: `Projetos/draxos-mobile`
- Coordination branch: `codex/draxos-mobile/lag-delay-coord`
- Coordination worktree: `D:\Estudio-worktrees\draxos-mobile--codex--lag-delay-coord`
- Base branch/commit: `master` / `247cbae`
- Remote publication: not authorized for this package yet.
- Remote account validation: authorized by Fabio, using an approved account only.
- Remote database migrations/RPC: authorized after local validation.
- API breaking changes: allowed for Internal Alpha.
- Platforms in scope: Web, Android APK, PC.
- Branches to consider: all current DraxosMobile branches/worktrees, including post-publication branches.

## Objective

Reduce perceived and measured lag-delay across DraxosMobile without changing the
Supabase/Cloudflare provider stack. Keep battle, reward, ranking and economy
server-authoritative. Improve immediate feedback, reduce unnecessary round trips,
parallelize server reads, add projected state/RPCs where useful, return mutation
deltas, and produce before/after latency evidence.

## Lanes

1. `coord-integration`: reconcile branches, own merge order, coordinate worktrees,
   keep handoffs current and integrate lane outputs.
2. `backend-state`: reduce Edge Function latency for state endpoints, add
   lightweight projections/RPCs/views, parallelize independent reads and keep
   `server/` + `supabase/` mirrors aligned.
3. `client-shell`: centralize surface refresh/cache behavior, ensure immediate
   cache/shell rendering, lifecycle-token stale response protection and
   surface-scoped busy behavior.
4. `mutations-deltas`: make mutations return affected surface deltas and remove
   redundant client fetch-after-mutation paths.
5. `telemetry-validation`: expand latency telemetry/log snapshots, run local and
   remote approved-account measurements, compare before/after across Web/APK/PC.

## Initial Read Set

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`

## Intended Write Scope

- Coordination/handoff notes for this package.
- DraxosMobile docs/contracts only when needed to record API or validation
  contract updates.
- `Projetos/draxos-mobile/server/` and `Projetos/draxos-mobile/supabase/` for
  backend state, migrations/RPCs and Edge Function mirrors.
- `Projetos/draxos-mobile/online/`, `modes/boot/`, presenters and client tests
  for shell/cache/busy/telemetry behavior.
- `Projetos/draxos-mobile/tests/`, `server/tests/`, `supabase/tests/` and tools
  only as needed for measurement/validation.

## Validation Plan

- Baseline latency report before code changes.
- Godot validate, GUT client and `ClientQuick`.
- Deno checks/tests for `server/functions` and `supabase/functions`.
- `DatabaseLocal` after schema/RPC work.
- `ServerQuick`, `ReleaseDryRun`, `smoke_responsive_layout.gd` when UI surfaces
  are touched.
- `FullLocal` before handoff.
- Remote read-only measurement first.
- Remote approved-account mutation measurement only after local validation.
- No Internal Alpha publication until Fabio gives explicit approval.

## Handoff Point

Initial handoff after branch reconciliation, baseline latency inventory and lane
implementation proposals are complete. Final handoff must include files changed,
commits, validation results, remote measurement evidence and any blockers.
