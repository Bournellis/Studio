# Estudio Agent Workflow - Current

## Metadata

- status: `active`
- authority: `runbook`
- last_verified: `2026-07-17`
- review_when: `authority order, worktree, closure or portfolio-sync contracts change`
- supersedes: `estudio-agent-workflow-current.md before Documentation Lite`
- superseded_by: `none`

This is a compact execution guide. `AGENTS.md` remains the operational contract and portfolio state is never copied here.

## Authority Order

1. `AGENTS.md`.
2. `08_Coordenacao_Agentes/Prioridades_Estudio.md`.
3. `Projetos/README.md`.
4. `08_Coordenacao_Agentes/Estado_Atual.md`.
5. Target project `AGENTS.md`, only if the portfolio permits the requested scope.
6. Target project `implementation/current-status.md`.
7. Target local coordination card, `TRIAGE.md` and `qa/QA_INDEX.md`.

Read `canon/canon-brief.md` only for shared lore or project-boundary questions. Never infer current focus from this guide.

## Worktree Rule

Use an external worktree for implementation, documentation, coordination and validation work:

```text
D:\Estudio-worktrees\<project>--<agent>--<slug>
```

Use `codex/<project>/<slug>` for Codex and `<agent>/<project>/<slug>` for other agents. Register objective, files, base ref and validation in a Doing card. Create a handoff only for a real transfer of responsibility or external state.

## Local-First And Validation

- Keep project-local cards and handoffs under the selected project's `08_Coordenacao/`.
- Queue global projection changes in `08_Coordenacao_Agentes/PortfolioSync_QUEUE.md`; local work does not edit `Estado_Atual.md`.
- Use `Review` only for a pending human decision. Technical work may be integrated and cleaned first.
- Use `tools/validate_estudio.ps1` with the smallest proportional profile.
- Use `tools/close_worktree_powershell.ps1` for a verified local lifecycle. It never pushes.
- Never import mechanics between projects without explicit adoption in the receiving project.

## Handoff Rule

A real handoff names changed files, validation, commit, merge target, post-merge validation, worktree/branch cleanup, blockers and the smallest safe next step.

If responsibility does not change, close the card and do not create a duplicate handoff.
