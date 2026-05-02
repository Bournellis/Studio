# RPG Turnos Project Brief

## Status

This project brief captures the initial conversation for the provisional project `rpg-turnos`.

The design is intentionally early. These notes are foundation constraints, not a full game design document.

## Identity

`rpg-turnos` is a new RPG project in Godot.

It is mechanically independent from RPG Isometrico, but it may share the same broader lore and setting. RPG Isometrico can be used as a production reference, not as an automatic mechanics source.

## Core Premise

The player controls a character on an explorable map. The character can move freely, choose paths, talk to NPCs, discover encounters, and enter turn-based battles.

The project is not an action RPG. The map is a space for exploration, navigation, interaction, and encounter choice. Combat happens through a turn-based RPG mode.

## Expected Pillars

- Free exploration with a single visible player character.
- Camera and character readability may be inspired by RPG Isometrico.
- NPC conversations and player choices should matter.
- Character state should include level, stats, items, and progression.
- Battle should be turn-based and separated from exploration.
- Systems should be built cleanly before visual commitment.

## Open Decisions

- 2D, 3D, or hybrid presentation.
- Exact camera model and map scale.
- Party size: single-character only or expandable party.
- Dialogue format and choice consequences.
- Encounter transition style.
- Turn order model, resource model, and ability vocabulary.
- How much existing RPG Isometrico code should be reused after review.

## Out Of Scope For The Initial Skeleton

- No playable scene yet.
- No final combat rules.
- No final UI design.
- No final content catalogs.
- No 2D/3D commitment.
- No direct copy of RPG Isometrico action combat systems.

