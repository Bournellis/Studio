# Game Mode Standard

## 1. Purpose

This document defines the mandatory shared structure for playable modes across implementations.

Every engine may realize these layers differently, but the responsibilities must remain stable.

---

## 2. Standard Layers

Every game mode should define clear equivalents of:

1. `Launch Context`
2. `Bootstrap`
3. `Session Manager`
4. `Game Loop`
5. `Simulation Context`
6. `HUD Presenter`
7. `Results Presenter`

---

## 3. Layer Responsibilities

### 3.1 Launch Context

Carries pre-match or pre-mission data from the frontend into the playable scene.

Must include:

- selected loadout
- mode-specific launch parameters

Rules:

- read once by bootstrap
- cleared immediately after bootstrap consumes it

### 3.2 Bootstrap

Owns initial scene assembly.

Must:

- read launch context
- wire gameplay, presentation, and results seams
- avoid becoming a game-logic owner

### 3.3 Session Manager

Owns the lifecycle/state machine of the match or mission.

Typical states:

- loading
- pre-match
- in progress
- session end

### 3.4 Game Loop

Owns tick-level win/loss progression and mode-specific flow.

Rules:

- one clear source of truth for end conditions
- does not directly own results UI

### 3.5 Simulation Context

Owns runtime events that other systems observe.

Rules:

- emits events
- does not become a second game-rules owner

### 3.6 HUD Presenter

Owns in-match player-facing UI and mode-specific HUD binding.

Rules:

- shared combat-shell behavior should stay unified where intended
- mode-specific additions should remain modular, not become separate drifting HUD families

### 3.7 Results Presenter

Owns end-of-match or end-of-mission presentation and return flow to the frontend.

Rules:

- result submission and post-match navigation connect here, not inside combat logic

---

## 4. Shared Gameplay Rules

All modes must preserve:

- fixed isometric camera identity
- loadout lock at session start
- canonical loadout shape
- clean separation between gameplay rules and player-facing UI

---

## 5. Intentional Divergence

These areas may diverge by mode or engine implementation:

- enemy AI
- wave logic
- boss scripting
- online transport details
- scene-authoring techniques

These divergences must not break the standard layer responsibilities.
