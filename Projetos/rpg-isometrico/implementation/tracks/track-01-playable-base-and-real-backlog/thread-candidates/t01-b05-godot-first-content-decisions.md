# T01-B05 - Godot-First Content Decisions

## Status

- Defined: `2026-04-21`
- Decision State: `No content lane chosen yet`

## Purpose

Create the explicit active-doc surface that will govern Godot content-package decisions after the local baseline was accepted and stabilized.

## Why This Thread Exists

Track 01 started from a validated runtime base, but the content language inherited from older Unity planning could no longer be trusted as the active source for Godot.

That created a gap:

- canon correctly kept long-term product identity
- the Godot project correctly implemented one small valid package
- active docs still lacked the explicit place where the next package decision should live

This thread closes that gap without pretending the next package has already been chosen.

## Deliverables

- `content-surface/current-godot-content-baseline.md`
- `content-surface/content-decision-rules.md`
- `content-surface/candidate-lanes.md`

## Current Baseline

At the moment this thread is defined, the active Godot content package is:

`Heroic -> Martelo Heroico -> 4 skills -> 2 potions`

That baseline is recorded as `Godot Content Baseline C0`.

## Scope

- define how content-package language should work in active Godot docs
- record the exact current authored baseline
- list the content lanes that are still compatible with canon and current implementation
- make the next choice explicit without forcing that choice prematurely

## Non-Goals

- choosing the next weapon or race by implication
- reopening Unity package language
- promoting a Godot-local package directly into canon
- broad content implementation inside the same thread

## Exit Criteria

This thread is considered defined when:

- the active track has one explicit place for current Godot content state
- the canon versus implementation ownership boundary is written down
- active docs list the available next content lanes
- the next planning step can choose a lane without reopening the documentation reset
