# RPG Turnos Project Brief

## Status

This project brief captures the initial conversation for the provisional project `rpg-turnos`.

The design is intentionally early. These notes are foundation constraints, not a full game design document.

Current combat rules are now governed by `game-design-document.md` version `0.3`. Any older mention in this brief of energy starting at 1, a 10-card deck, or undecided C1 status is historical.

## Identity

`rpg-turnos` is a new RPG project in Godot.

It is mechanically independent from RPG Isometrico, but it may share the same broader lore and setting. RPG Isometrico can be used as a production reference, not as an automatic mechanics source.

## Core Premise

The player controls a character on an explorable map. The character can move freely, choose paths, talk to NPCs, discover encounters, and enter turn-based card-slot battles.

The project is not an action RPG. The map is a space for exploration, navigation, interaction, and encounter choice. Combat happens through a turn-based RPG-cardgame mode.

In combat, the character is the hero/player of the battle. The hero does not move on the combat board. The player uses cards, hero abilities, equipment, stats, and campaign rewards to control fixed slots, lanes, terrain, and encounter objectives.

## Expected Pillars

- Free exploration with a single visible player character.
- Camera and character readability may be inspired by RPG Isometrico.
- NPC conversations and player choices should matter.
- Character state should include level, stats, items, and progression.
- The game baseline is singleplayer; future co-op is possible but not an active requirement.
- The deck evolves with RPG progression.
- The player chooses the setup/deck loadout before entering each combat.
- Energy starts at 1, scales by round, and may change through hero choice or abilities.
- Defeat reloads the game to the pre-combat state with no negative consequence.
- Battle should be turn-based, card-driven, and separated from exploration.
- The battle board should be an arena of fixed slots, not a tactical movement grid.
- Creatures, structures, and support permanents can occupy slots; spells and commands usually do not.
- Encounters may use different board shapes, objectives, waves, enemy heroes, or boss parts.
- Systems should be built cleanly before visual commitment.

## Open Decisions

- 2D, 3D, or hybrid presentation.
- Exact camera model and map scale.
- Party size: single-character only or expandable party.
- Dialogue format and choice consequences.
- Encounter transition style.
- Turn order model, resource model, and ability vocabulary.
- Exact deckbuilding constraints and card acquisition model.
- Whether Command/Presence is promoted after the first prototype.
- Exact hero stat names and progression rules.
- How much existing RPG Isometrico code should be reused after review.

## Out Of Scope For The Initial Skeleton

- No playable scene yet.
- No final combat rules.
- No final UI design.
- No final content catalogs.
- No 2D/3D commitment.
- No direct copy of RPG Isometrico action combat systems.
