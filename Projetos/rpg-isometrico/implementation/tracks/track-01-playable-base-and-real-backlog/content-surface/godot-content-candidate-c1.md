# Godot Content Candidate C1

- Last Updated: `2026-04-23`
- Surface Name: `Godot Content Candidate C1`
- Status: `ADOPTED FOR GATE F07`

## Purpose

This document records the implementation-local content lane explicitly adopted for `Gate F07 - Campaign Content Expansion`.

It does not promote new canon content breadth.

## Chosen Lane

- `Lane C - Deepen C0 Before Breadth`

This means the project is deliberately deepening the current `Heroic + Martelo Heroico` baseline before opening a second race or a second weapon lane.

## Exact IDs In Scope

The F07 candidate deepens campaign infrastructure around the existing baseline and keeps gameplay-content breadth unchanged.

Authored route IDs in scope:

- `blacksmith_campaign`
- `easy`
- `mission_01`
- `mission_02`
- `mission_03`
- `mission_04`
- `mission_05`

Gameplay-content IDs intentionally unchanged:

- `heroic`
- `heroic_hammer`
- `breaker_leap`
- `hammer_impact`
- `heroic_rally`
- `seismic_ring`
- `bastion_tonic`
- `vital_flask`

## Runtime Surfaces

This candidate is expected to affect:

- campaign route authorship through `definitions/campaigns/`
- generated campaign route catalogs under `resources/generated/catalogs/`
- `CampaignStageManager` and `CampaignRoot` route resolution
- campaign validation and smoke coverage

This candidate is not expected to change:

- the public frontend campaign count
- the current one-race / one-weapon gameplay-content baseline
- builder unlock posture from F05

## Validation

- `tools/validate.gd`
- GUT coverage for campaign catalog generation and non-hardcoded route resolution
- `docs/campaign-framework-smoke.md`

## Update Rule

Update this file when the active implementation-local candidate changes or when a later gate deliberately switches away from `Lane C`.
