# Projetos

This directory contains active, conceptual, and paused projects for the studio.

Portfolio source of truth: `../08_Coordenacao_Agentes/Prioridades_Estudio.md`
Studio snapshot: `../08_Coordenacao_Agentes/Estado_Atual.md`
Visual dashboard: `../08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Implementacao Ativa

- `draxos-roguelike-cardgame/`: menu-first Draxos roguelike cardgame with ship hub, 13-map mission route, simple board card battles, fixed/choice rewards, and independent mechanics.
  - Priority/status: `P0_IMPLEMENTACAO`
  - Local agent guide: `draxos-roguelike-cardgame/AGENTS.md`
  - Operational status: `draxos-roguelike-cardgame/implementation/current-status.md`
  - Studio snapshot: `../08_Coordenacao_Agentes/Estado_Atual.md`
  - Validation command: `draxos-roguelike-cardgame/tools/validate.gd`
  - Allowed work: code, validation, playtest, local documentation.
  - Current next step: playtest the 13-map route with save v4, pre-combat discard, rarity rewards, Souls upgrade shop, Diabrete, and globally stronger encounters.

## Conceitos em Incubacao

- `_conceitos/RPGMobile/`: conceptual mobile action RPG focused on open-world exploration, combat, loot, free weapon/spell loadouts, and mastery by use; lore deferred.
  - Priority/status: `P1_CONCEITO`
  - Concept status: `_conceitos/RPGMobile/README.md`
  - Allowed work: concept, pitch, design, references.
  - Restriction: do not create code, scenes, implementation assets, or a Godot project without explicit user request.
- `_conceitos/BattleMobile/`: conceptual mobile battle project.
  - Priority/status: `P1_CONCEITO`
  - Concept status: `_conceitos/BattleMobile/README.md`
  - Allowed work: concept, pitch, design, references.
  - Restriction: do not create code, scenes, implementation assets, or a Godot project without explicit user request.

## Pausados por Tempo Indeterminado

- `rpg-isometrico/`: campaign-first isometric action RPG.
  - Priority/status: `PAUSADO_INDEFINIDO`
  - Local agent guide: `rpg-isometrico/AGENTS.md`
  - Operational status: `rpg-isometrico/implementation/current-status.md`
  - Validation reference: `rpg-isometrico/docs/validation.md`
  - Allowed work: historical/contextual consultation only, unless the user explicitly asks to resume work.
- `rpg-turnos/`: provisional turn-based RPG-cardgame with independent mechanics and shared lore context.
  - Priority/status: `PAUSADO_INDEFINIDO`
  - Local agent guide: `rpg-turnos/AGENTS.md`
  - Operational status: `rpg-turnos/implementation/current-status.md`
  - Validation command: `rpg-turnos/tools/validate.gd`
  - Allowed work: historical/contextual consultation only, unless the user explicitly asks to resume work.

## Project Disambiguation

- Use `draxos-roguelike-cardgame/` for the current implementation focus: Draxos roguelike, ship hub, run map, 13-map route, souls/cure loop, lane battles, card/enemy redesign, reward choices, sacrifice/movement/Cinzas tuning, and Track 01 playable run loop.
- Use `_conceitos/RPGMobile/` for RPGMobile concept work only.
- Use `_conceitos/BattleMobile/` for BattleMobile concept work only.
- Use `rpg-isometrico/` only for explicit historical/contextual consultation about the campaign-first isometric action RPG, action loadouts, Arena, Survival, Boss, campaign gates, and real-time combat work.
- Use `rpg-turnos/` only for explicit historical/contextual consultation about the provisional 2D RPG-cardgame with exploration/world flow, NPCs, class select, Track 02 lore/progression work, and the P10 Necromante path.

`Draxos` and `cardgame` are shared vocabulary, not enough to pick `rpg-turnos`. Prefer the portfolio priority, the explicitly named project, or the operational surface above before reading a local project guide.

## Agent Rule

Before working in a project, read:

1. `../08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. the workspace `AGENTS.md`
3. this registry
4. the relevant section of `../08_Coordenacao_Agentes/Estado_Atual.md`
5. the target project's local docs, only if the portfolio status allows the requested work

Do not import mechanics from one project into another unless the target project's local docs explicitly adopt them.

## Future Projects

A future project under `Projetos/` becomes an official implementation project only when it has:

- a local `AGENTS.md`
- a local `implementation/current-status.md`
- an entry in this registry outside `_conceitos/`
- a summary entry in `../08_Coordenacao_Agentes/Estado_Atual.md`

Until then, treat it as experimental, conceptual, or preparatory material.
