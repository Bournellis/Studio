# Estudio Agent Workflow - Current

This is the current operational guide for agents working in `D:\Estudio`.

## Authority Order

Read portfolio authority before project-local detail:

1. `08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `AGENTS.md`
3. `Projetos/README.md`
4. `08_Coordenacao_Agentes/Estado_Atual.md`
5. `canon/canon-brief.md`
6. target project `AGENTS.md`, only if the portfolio allows the requested work
7. target project `implementation/current-status.md`

## Current Portfolio

- P0 implementation: `Projetos/draxos-roguelike-cardgame/`
- P2 implementation: `Projetos/draxos-mobile/`
- Read-only design archive: `Projetos/_conceitos/mobile-universe/`
- Paused indefinitely: `Projetos/rpg-isometrico/`
- Paused indefinitely: `Projetos/rpg-turnos/`

## Worktree Rule

Use an external worktree for implementation, documentation, coordination and validation work:

```text
D:\Estudio-worktrees\<projeto>--<agente>--<slug>
```

Use branches like:

- `codex/<projeto>/<slug>` for Codex
- `<agente>/<projeto>/<slug>` for other agents

Register branch, worktree, objective, intended files, base docs and validation plan in Doing or Handoff for substantial work.

## Routing Rules

- Do not import mechanics between projects without a local document adopting the rule.
- Do not treat historical guides, migration notes or paused project docs as current canon.
- Use Fast Lane only for local, bounded work with no canon/product/platform impact.
- Escalate to full read when touching portfolio, canon, shared architecture, product direction, release/publication or multiple projects.
- DraxosMobile current package and next operational step live in its `implementation/current-status.md`; the portfolio snapshot must summarize it without becoming a long release log.

## Handoff Rule

A good handoff names:

- owner and recipient
- branch and worktree
- package/stage preserved
- changed files
- validation commands and result
- explicit blockers
- smallest safe next step
