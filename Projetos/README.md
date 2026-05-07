# Projetos

This directory contains active and emerging Godot projects for the studio.

## Project Registry

- `rpg-isometrico/`: campaign-first isometric action RPG.
  - Local agent guide: `rpg-isometrico/AGENTS.md`
  - Operational status: `rpg-isometrico/implementation/current-status.md`
  - Studio snapshot: `../08_Coordenacao_Agentes/Estado_Atual.md`
  - Validation reference: `rpg-isometrico/docs/validation.md`
- `rpg-turnos/`: provisional turn-based RPG-cardgame with independent mechanics and shared lore context.
  - Local agent guide: `rpg-turnos/AGENTS.md`
  - Operational status: `rpg-turnos/implementation/current-status.md`
  - Studio snapshot: `../08_Coordenacao_Agentes/Estado_Atual.md`
  - Validation command: `rpg-turnos/tools/validate.gd`
- `draxos-roguelike-cardgame/`: menu-first Draxos roguelike cardgame with ship hub, mission map, simple board card battles, and independent mechanics.
  - Local agent guide: `draxos-roguelike-cardgame/AGENTS.md`
  - Operational status: `draxos-roguelike-cardgame/implementation/current-status.md`
  - Studio snapshot: `../08_Coordenacao_Agentes/Estado_Atual.md`
  - Validation command: `draxos-roguelike-cardgame/tools/validate.gd`

## Agent Rule

Before working in a project, read the workspace `AGENTS.md`, this registry, the relevant section of `../08_Coordenacao_Agentes/Estado_Atual.md`, then that project's `AGENTS.md` and `implementation/current-status.md`.

Do not import mechanics from one project into another unless the target project's local docs explicitly adopt them.

## Future Projects

A future project under `Projetos/` becomes an official active project only when it has:

- a local `AGENTS.md`
- a local `implementation/current-status.md`
- an entry in this registry
- a summary entry in `../08_Coordenacao_Agentes/Estado_Atual.md`

Until then, treat it as experimental or preparatory material.
