# Stage G3-08 - Arena Expansion And Enclosure

## Goal

Give the combat slice a larger battlefield, a more generous camera read, and clearer physical boundaries.

## Required Outcome

- the orthographic camera shows more of the fight at once without breaking the fixed player-centered framing
- the arena floor is materially larger than the previous slice
- closed perimeter walls frame the fight area
- a few internal wall blocks add spatial variety without collapsing the simple bot loop
- automated validation keeps the new arena layout protected

## Scope

- camera zoom-out for the fixed arena camera
- larger floor and boundary ring
- perimeter wall generation
- interior obstacle generation
- runtime assertions and smoke updates for the new arena layout

## Non-Goals

- navigation/pathfinding refactors
- new combat mechanics
- content breadth expansion
- mobile-specific layout changes
