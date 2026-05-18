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

- `_conceitos/mobile-universe/`: projeto mobile multi-partes — mago intergalatico maligno, cartoon gore, primeiro slice com Character Autobattler PVP simples, Base Manager, amigos e guilda; PVP assincrono estilo Hero Wars como duelo sidescroller com finalizacoes brutais, Almas por vitoria, derrota sem recompensa e batalhas infinitas com recompensa decrescente ate zerar; upgrades iniciais de 1 arma, 3 spells e 2 passivas; futuros itens/pocoes/pets/arvores mais elaboradas; modos futuros (PVE Autobattler narrativo com ultimate/spells, PVP Cardgame Roguelike, Hero Defense, Open World RPG) conectados por conta/base em intensidades diferentes. Substitui RPGMobile e BattleMobile.
  - Priority/status: `P1_CONCEITO`
  - Concept status: `_conceitos/mobile-universe/README.md`
  - GDD: `_conceitos/mobile-universe/gdd.md`
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
- Use `_conceitos/mobile-universe/` for Mobile Universe concept work only.
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
