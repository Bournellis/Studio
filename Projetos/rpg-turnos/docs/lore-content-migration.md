# Lore Content Migration

- Last Updated: `2026-05-12`
- Status: `planning`
- Lore Authority: `../../Projetos/draxos-roguelike-cardgame/docs/lore-campaign.md`
- Depends On: `lore-campaign.md`, `../../canon/lore/draxos-invasion.md`

## Purpose

This document tracks how current placeholder content in RPG Turnos should migrate into the Draxos invasion setting.

The naming source of truth is the Draxos roguelike lore. Do not invent names or story details here — wait for them to be defined in the shared lore first, then apply them to RPG Turnos.

## Migration Principles

- Keep mechanical IDs stable until a rename pass has test coverage.
- Change player-facing `display_name`, text, dialogue, and encounter labels before changing IDs.
- Rename in small groups: hero and hub first, then first mission chain, then cards, then assets.
- Every rename should preserve the current battle rule being tested unless the task explicitly changes mechanics.

## Future Technical ID Migration

Current IDs such as `emboscada_na_ponte`, `duelista_bandido`, `goblin_ponte`, `campeao_guilda`, `dragao_jovem`, and portrait asset IDs such as `portrait_npc_viajante` are technical legacy IDs.

They are not active lore.

Do not rename them opportunistically. A future ID migration must be planned as a dedicated compatibility pass covering:

- save migration
- tests and validation contracts
- generated `.tres` resources
- scene references
- asset ID mappings
- content JSON references

## Current Placeholder To Lore Role

| Current Placeholder Area | New Lore Role |
|---|---|
| player hero placeholder | Draxos commander — first playable class TBD |
| single NPC / traveler | Draxos subordinate or specialist in the ether-plasm base |
| world map | mission hub from the Draxos ether-plasm base into elemental-planet regions |
| bridge encounters | early strategic-area operations on the elemental planet |
| bandit duel | direct confrontation with an elemental champion, guardian, or rival operator |
| fortress/desfiladeiro | fortified elemental region or approach to volcanic/crystal territory |
| waves/defense/boss/puzzle modes | mission objectives, not separate story arcs |
| starter deck | first Draxos class kit: astral commands, ether constructs, bound forces, or controlled elemental pressure |
| reward cards | status gains, new astral techniques, captured elemental forces, or equipment-like mission assets |
| current old creature labels | placeholders for Draxos constructs, enslaved beings, local elementals, or hostile defenders |

## First Rename Pass Candidate

The first runtime-facing pass should be intentionally narrow:

1. Update hero display name to a Draxos commander label consistent with the roguelike.
2. Update the NPC dialogue from "traveler gives a card" to a Draxos command or subordinate briefing.
3. Update the first encounter chain display names to mission-style labels.
4. Keep card mechanics and card IDs unchanged.
5. Run validation after JSON/resource regeneration.

## Decisions Needed Before Card Renaming

These decisions must come from the shared lore or the roguelike first:

- first playable class name and its Draxos identity
- whether the starter deck represents personal spells, squad commands, ether constructs, enslaved elementals, or a mix
- whether enemy cards represent elementals, defenders, the unknown helper race, or Draxos rivals
- how dark the Draxos perspective should feel in direct UI text
- whether early rewards are earned promotions, confiscated forces, or unlocked astral techniques
