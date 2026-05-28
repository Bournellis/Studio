# Track 14 - Agent Operations Foundation Scope

- Status: `ACTIVE`
- Start date: `2026-05-28`
- Base: `codex/draxos-mobile/track-13-validation-release-safety`
- Branch: `codex/draxos-mobile/agent-ops-foundation`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--agent-ops-foundation`

## Goal

Create a long-term operational foundation for agents working on DraxosMobile. The project should be easy to enter, hard to misread and safe to validate without accidental remote mutation.

## In Scope

- Reconcile Track 11-13 hardening output and preserve good deliverables.
- Rewrite agent entrypoints: `AGENTS.md`, `README.md`, `implementation/current-status.md`.
- Add `docs/agent-operating-manual.md`.
- Add `docs/documentation-index.md` with `VIVO`, `CONTRATO`, `RUNBOOK`, `HISTORICO` and `ARQUIVO_DESIGN`.
- Keep Kanban Doing focused on the active agent-ops foundation work.
- Update studio portfolio docs and visual panel to the real current track.
- Align product terminology around Instrumento Ritual, Doutrina and Familiar.
- Keep release publication opt-in and protected.
- Add validation guard for the new agent foundation.

## Out Of Scope

- Playable feature work.
- Numeric tuning.
- Migration from `players.save_type` to `account_profiles/game_saves`.
- iOS or mobile browser work.
- Final production assets.
- Remote publication or remote mutation.

## Acceptance Criteria

- A new agent can identify active track/status and safe commands from `AGENTS.md` in under two minutes.
- `README.md`, `AGENTS.md`, `implementation/current-status.md`, `Prioridades_Estudio.md`, `Estado_Atual.md` and `Projetos/README.md` agree on active track and next gate.
- Kanban Doing has no obsolete DraxosMobile cards.
- No live entrypoint instructs agents to start from Track 04, Track 08 or Track 10.
- `tools/validate_foundation.ps1` remains the main validation runner.
- Remote publication still requires explicit mode and `-ConfirmRemoteMutation`.
- No secret/service-role wording introduces operational leakage into client, portal, manifest or docs.
