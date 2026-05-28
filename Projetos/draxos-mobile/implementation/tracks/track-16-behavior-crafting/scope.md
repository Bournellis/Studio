# Track 16 - Behavior And Potion Crafting Scope

- Status: `ACTIVE`
- Start date: `2026-05-28`
- Branch: `codex/draxos-mobile/track-16-behavior-crafting`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--track-16-behavior-crafting`
- Base: `master` at `5922fcb`

## Goal

Implement the first server-authoritative consumable and behavior package for DraxosMobile: integer Ossos, Po de Osso, potion crafting, one potion slot and behavior rules for spells and potions.

## Decisions

- Ossos are re-scaled globally by `100` so they are represented as whole numbers.
- `po_osso` is a new whole-number resource derived by crushing Ossos.
- Conversion: `1 Osso -> 1 Po de Osso`.
- `pocao_vida` costs `50 po_osso`.
- The first potion slot unlocks at level 1 and starts empty.
- The first potion default behavior is enabled at `Vida < 40%`.
- Behavior v1 only checks the user's own Vida and Mana.

## In Scope

- Schema, mirrors, contracts and docs for resources, consumables, crafting and behavior.
- Save-scoped Edge Functions for crafting and build behavior.
- Server battle simulator support for spell behavior, potion consumption and healing over time.
- Content definitions for potions and crafting recipes.
- Godot UI panels for crafting and preparation.
- Deno and GUT coverage for the new contracts.

## Out Of Scope

- Payment, iOS, mobile browser, release publication and account/save migration.
- Broad numeric tuning outside the required Osso scaling and potion baseline.
- Bots using potions by default.
