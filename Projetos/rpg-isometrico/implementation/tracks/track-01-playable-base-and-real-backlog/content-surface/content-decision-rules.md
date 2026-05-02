# Content Decision Rules

## Purpose

This document defines how Track 01 should talk about content packages after the Godot-first reset.

It exists to prevent three failures:

1. treating the current Godot baseline as if it were already the final release package
2. reintroducing Unity package language into active docs by habit
3. leaking implementation-local package guesses into canon

## Ownership Boundary

### Canon Owns

- race identity territories
- the loadout contract `Race -> 1 Weapon -> 4 Skills -> 2 Potions`
- long-term product scope
- release-horizon direction such as `1 race` or `2-3 weapons at launch`

### Active Godot Docs Own

- the exact implemented package in `definitions/`
- temporary or working names for Godot package candidates
- the order in which new races, weapons, skills, and potions are authored
- validation expectations for each new package thread

## Naming Rule

Use the following naming pattern in active docs:

- `Godot Content Baseline C0`
- `Godot Content Candidate C1`
- `Godot Content Candidate C2`

The `C` labels are implementation-local sequence labels.

They do not imply:

- release order
- canon status
- parity with Unity-era package labels

## Language Rule

Allowed language in active docs:

- `currently implemented baseline`
- `candidate package`
- `authored next package`
- `content lane`

Disallowed language unless canon explicitly promotes it:

- `official package`
- `current release package`
- `Phase 7 package`
- inherited Unity package names used as if they were still authoritative

## Promotion Rule

A content package should remain implementation-local until at least one of these becomes true:

- canon deliberately adopts it as a stable release-facing package
- release planning explicitly depends on its exact counts
- progression or onboarding canon explicitly references that exact package

If none of those is true, keep the package in active Godot docs only.

## Minimum Inputs Before Opening A New Content Thread

Before opening the next bounded content-authoring thread, active docs should state:

- which content lane is being chosen
- the exact IDs expected to be added or changed
- whether the move increases breadth or only deepens the current baseline
- which runtime surfaces are expected to reflect the new package
- which tests or smoke expectations must expand with it

## Validation Rule

Every future content-package thread should keep:

- `tools/validate.gd`
- canonical loadout validation
- frontend loadout assembly
- the accepted Arena / Survival / Boss runtime baseline
