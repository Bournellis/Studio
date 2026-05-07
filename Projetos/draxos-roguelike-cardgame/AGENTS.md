# AGENTS.md

This file governs agent behavior for `Projetos/draxos-roguelike-cardgame`.

## Project Role

`draxos-roguelike-cardgame` is a new Godot project for a Draxos roguelike cardgame.

It is not a variant of `rpg-turnos`. It shares Draxos lore, broad campaign premise, possible characters, and possible class fantasy, but it owns its own card rules, deck size, mana/resource model, draw model, run structure, hub flow, and encounter pacing.

Current identity:

- menu-first roguelike cardgame
- Draxos ship / ether-plasm base as the main hub
- mission map with linear progress and optional steps
- card battles presented as a simple board with player and enemy facing each other
- board complexity is only slot capacity per side for now
- no free RPG exploration map
- no Slay the Spire-style combat presentation

## Read Order

Before substantial work:

1. `../../canon/canon-brief.md`
2. `../../canon/lore/shared-lore.md`
3. `../../canon/lore/draxos-invasion.md`
4. `docs/product-brief.md`
5. `docs/game-design-document.md`
6. `docs/architecture.md`
7. `docs/reuse-map.md`
8. `implementation/current-status.md`
9. this file
10. touched files

For bounded implementation work:

1. `../../canon/canon-brief.md`
2. `implementation/current-status.md`
3. this file
4. touched files

## Canon Rule

Shared lore may inform this project. Mechanics from `rpg-turnos` and `rpg-isometrico` are references only unless this project's local docs explicitly adopt them.

If local design conflicts with shared lore, shared lore wins until canon is updated.

## Godot Rule

- Engine: Godot `4.6.2-stable`
- Language: GDScript only
- Tests: GUT `9.6.0`
- Content source of truth: local JSON definitions under `data/definitions/`
- Generated resources under `data/generated/` are produced by validation

Do not hand-edit `.tscn` files as raw text. If scenes need generation or repair, use a Godot script/tool.

## Reuse Rule

The project was bootstrapped from narrow pieces of `Projetos/rpg-turnos`.

Allowed reuse:

- Godot validation pattern
- content generation pattern
- UI tokens and asset-id seams
- reusable card/slot UI controls
- `battle_engine.gd` as a temporary fork

Required divergence:

- remove RPG Turnos route, terrain, elevation, neutral-slot, RPG exploration, campaign reward, and deck economy assumptions before treating combat as final
- define new deck, mana/resource, draw, run, and reward rules locally

## Active Track

Start with `implementation/tracks/track-00-project-bootstrap/linear-execution-plan.md`.
