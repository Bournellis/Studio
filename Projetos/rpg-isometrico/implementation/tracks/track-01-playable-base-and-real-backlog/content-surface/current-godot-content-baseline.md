# Current Godot Content Baseline

- Last Updated: `2026-04-21`
- Surface Name: `Godot Content Baseline C0`
- Status: `IMPLEMENTED`

## Purpose

This document records the exact gameplay content currently authored in the active Godot project.

It is a factual implementation snapshot, not a release promise and not a canon-level package declaration.

## Current Authored Set

### Races

- `heroic`

Source:

- `definitions/races/heroic.json`

### Weapons

- `heroic_hammer`

Source:

- `definitions/weapons/heroic_hammer.json`

### Skills

- `breaker_leap`
- `hammer_impact`
- `heroic_rally`
- `seismic_ring`

Sources:

- `definitions/skills/breaker_leap.json`
- `definitions/skills/hammer_impact.json`
- `definitions/skills/heroic_rally.json`
- `definitions/skills/seismic_ring.json`

### Potions

- `bastion_tonic`
- `vital_flask`

Sources:

- `definitions/potions/bastion_tonic.json`
- `definitions/potions/vital_flask.json`

## Current Baseline Statement

Today, the active Godot project implements one valid canonical loadout surface:

`Heroic -> Martelo Heroico -> 4 skills -> 2 potions`

This baseline is enough to support:

- the shared frontend loadout flow
- Arena
- Survival
- Boss
- automated loadout validation
- generated Godot resource catalogs

## What C0 Proves

- the Godot content pipeline can author JSON definitions and generate runtime resources
- the canonical loadout contract is live in the active project
- one complete race/weapon package is already sufficient to support the accepted local baseline

## What C0 Does Not Mean

- C0 is not automatically the launch package
- C0 is not automatically the long-term Heroic package
- C0 does not imply that canon has chosen exact future weapon or potion counts
- C0 does not imply that broader content work has already been opened

## Update Rule

Update this file only when the exact implemented content set in `definitions/` changes.

Do not update it for:

- product-level race territories
- release-horizon speculation
- package ideas that are not yet authored
