# Stage G2-02 - Scene Ownership And Runtime Anchors

## Goal

Turn the playable flow into editor-owned scenes with explicit runtime anchors, keeping the same bounded gameplay scope.

## Required Outcome

- `frontend.tscn` is an authored scene with stable named UI anchors
- `arena.tscn` is an authored scene with stable world, spawn, runtime, and presentation anchors
- runtime scripts use the authored scene structure instead of building the entire shell from scratch
- the scene bootstrap helper no longer overwrites authored scenes during validation
- automated validation protects the new scene ownership baseline

## Scope

- frontend scene ownership
- arena scene ownership
- runtime anchor cleanup
- non-destructive bootstrap behavior
- validation updates for scene structure

## Non-Goals

- new gameplay mechanics
- more content breadth
- online features
- mobile support
- progression expansion
