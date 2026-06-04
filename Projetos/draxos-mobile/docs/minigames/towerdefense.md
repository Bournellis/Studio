# Towerdefense

- Status: `PLANNED_DISABLED`
- Mode id: `towerdefense`
- Slice id: `tbd`
- Descriptor: `data/definitions/modes/towerdefense/metadata.json`
- Placeholder: `data/definitions/modes/towerdefense/placeholder.json`
- Decision pack: `docs/minigames/towerdefense-decision-pack.md`
- Player-facing entry: hidden
- Internal disabled action: `mode_disabled:towerdefense`
- Route: none

Towerdefense is a future planned/disabled mode identity. The current concept is a static
central mage or tower surviving hordes with spells, pets and upgrades, but this
file is not approval to implement that gameplay.

## Current Scope

- Hidden from the player-facing menu until a playable package is approved.
- No playable scene.
- No session start.
- No reward bridge.
- No local progress format beyond the placeholder scaffold.

## Freeze For This Scaffold

- No tower gameplay.
- No waves, enemies, upgrades or tuning.
- No rewards.
- No backend or schema mutation.

## Future Gate

Towerdefense needs a live design contract, registry/ruleset update, telemetry
plan, disable/rollback plan and validation package before becoming launchable.

## Decision Pack V1

`docs/minigames/towerdefense-decision-pack.md` is the current decision pack.
It keeps the mode planned/disabled and hidden from the player while naming the questions that must be answered
before tower, hordes, spells, pets, upgrades or rewards can be implemented.
