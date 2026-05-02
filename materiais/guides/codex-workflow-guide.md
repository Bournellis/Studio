# Codex Workflow Guide

This guide explains how to work with Codex efficiently in the `D:\Estudio` workspace, with special attention to thread hygiene and keeping the active Godot project aligned with shared canon.

## Core Model

- Codex is the primary implementation and canon-maintenance agent.
- `canon/` is the shared source of truth for product identity, gameplay contracts, architecture, roadmap, and platform direction.
- `Projetos/rpg-isometrico/` is the active Godot implementation surface.
- Track 02 is the active operational line unless `Projetos/rpg-isometrico/implementation/current-status.md` says otherwise.
- The current gate is whichever gate is named by `implementation/current-status.md`; if it says `TBD`, no implementation gate is active yet.
- `phase-g1/` through `phase-g4/` are closed Godot validation history, not the active workstream.
- `migration/` and external Unity material are historical context only.

## When To Keep The Same Thread

Keep the same thread when:
- you are continuing the same bounded task
- the same files or module slice are still in play
- you are fixing regressions discovered from the work that just happened
- the current thread still reflects the same active track goal and validation context
- the follow-up depends heavily on the conversation that already happened

Good examples:
- "The same loadout bug still exists in one more screen. Continue."
- "The validation failed after this runtime change. Fix it."
- "Keep going on the currently selected gate slice."

## When To Open A New Thread

Open a new thread when:
- the goal changes materially
- you switch from implementation to review or planning
- you move from local code work to canon or architecture work
- the current thread has become noisy, stale, or mixed with unrelated concerns
- you want a historical investigation that should not pollute active-track context
- a previous task is complete and you are starting a new bounded unit of work

Good examples:
- finish a bugfix thread, then open a new thread for a design review
- finish a runtime slice, then open a new thread to review the next gate
- open a separate thread for historical G3/G4 research

## Best Way To Start A Thread

The best opening message is short, explicit, and scoped.

Always try to include:
- the goal
- whether this is implementation, review, planning, canon, or historical work
- whether Codex may use the bounded read order if safe
- files or folders already known to matter
- validation expectations
- whether canon changes are allowed

## Recommended Opening Patterns

### 1. Bounded implementation

```text
Tipo: Implementation
Objetivo: corrigir {bug curto} na superficie ativa de Godot.
Rota: bounded read order se seguro; sem canon changes.
Escopo:
- Projetos/rpg-isometrico/modes/frontend/
- Projetos/rpg-isometrico/presentation/results/
Validacao: rode ou preserve validate.gd + GUT conforme o risco da mudanca.
```

### 2. Review

```text
Tipo: Review
Objetivo: revisar regressao e risco em {arquivos/tema}.
Rota: bounded read order.
Regra: nao implemente ainda.
Escopo:
- Projetos/rpg-isometrico/modes/campaign/
- Projetos/rpg-isometrico/tests/unit/
```

### 3. Canon or architecture update

```text
Tipo: Canon
Objetivo: atualizar/decidir {regra de produto, arquitetura, progressao ou plataforma}.
Rota: leia a rota canonica completa.
Regra: pode atualizar canon e os arquivos operacionais necessarios.
```

### 4. Track or gate planning

```text
Tipo: Gate
Objetivo: planejar ou revisar {gate/slice} da Track 02.
Rota: leia canon, implementation/current-status.md, current-status da track, implementation-map e o gate ativo se houver um nomeado.
Regra: atualize docs operacionais se o estado mudar.
```

### 5. Historical lookup

```text
Tipo: Historical
Objetivo: consultar {tema historico}.
Rota: bounded read order + caminhos historicos explicitos.
Regra: nao tratar historico como canon atual.
Paths:
- migration/
- Projetos/rpg-isometrico/implementation/phase-g4/
```

## Bounded Route Vs Deep Route

Use the bounded route when the task is local, clear, and not changing canon.

Use the deep route when the task involves:
- product identity
- architecture boundaries
- shared contracts
- progression
- networking or persistence rules
- platform rules
- track or gate planning
- ambiguous multi-system changes

## Canonical Read Routes

For substantial work, follow `D:\Estudio\AGENTS.md`.

For bounded work, start with:

1. `canon/canon-brief.md`
2. `Projetos/rpg-isometrico/AGENTS.md`
3. `Projetos/rpg-isometrico/implementation/current-status.md`
4. the touched files

For active Track 02 work, also read:

1. `Projetos/rpg-isometrico/implementation/tracks/track-02-canonical-product-foundation/current-status.md`
2. `Projetos/rpg-isometrico/implementation/tracks/track-02-canonical-product-foundation/implementation-map.md`
3. the active gate named by `implementation/current-status.md`, only when one is explicitly selected
4. `Projetos/rpg-isometrico/docs/validation.md`

## How To Keep Token Cost Low

- Ask for one main goal per thread.
- Point to exact files or folders whenever you already know them.
- Say "no canon changes" when the task is implementation-only.
- Say "review only" when you do not want code changes yet.
- Do not ask for whole-project analysis unless you really want whole-project analysis.
- Use the bounded route for local work.
- Use historical paths explicitly instead of letting searches wander through closed phases.
- Rely on `.rgignore` for normal active-surface searches, and use explicit paths or `rg --no-ignore` only when you intentionally need history.

## Working With Sidecar Agents

If you want another model or agent to help, keep it advisory and bounded.

Best practice:
- let Codex remain the main execution thread
- give the sidecar only the specific files and question needed
- keep canon, active track scope, and validation decisions in Codex
- integrate accepted conclusions back into repo files through Codex

## Operational Reminders

- `canon/` is shared canon.
- `Projetos/rpg-isometrico/implementation/current-status.md` is the active operational hub.
- `implementation/tracks/` is the active work area.
- `implementation/phase-g1/` through `phase-g4/` are historical validation records.
- `tools/validate.gd` plus GUT are the Godot validation baseline.
- If operational state changes, update the active status, active track, relevant gate, and execution log as appropriate.
- If canon changes, update the canonical docs explicitly.

## Practical Rule Of Thumb

If you can describe the task in one sentence and point to a small file set, keep the thread and use the bounded route.

If you need to redefine the problem before coding, open a new thread and use the deep route.
