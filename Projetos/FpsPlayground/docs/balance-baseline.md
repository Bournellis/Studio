# FpsPlayground Balance Baseline

## Metadata

- status: `frozen`
- authority: `historical_record`
- last_verified: `2026-07-16`
- review_when: `a new evidence baseline explicitly supersedes this record`
- supersedes: `none`
- superseded_by: `none`

- Status: Track 12 approved baseline; Track 13 future planning rebaseline.
- Source: Track 11 telemetry plus the approved feel of the current three-arena FPS lab.
- Rule: this document describes interpretation only; it does not change gameplay.

## Healthy Baseline

- Rounds should produce readable causes: damage source, weapon accuracy, pickups and movement routes should explain the result.
- Rifle should remain the primary precision tool, but should not be the only meaningful damage source across many sessions.
- Direct Plasma should appear less often than rifle, with higher impact per hit and higher commitment.
- Plasma Blast should create pressure and near-miss value, not dominate direct damage or rifle timing.
- Overcharge should matter when collected and spent well, but should not decide every duel by itself.
- Bot damage should be present in completed rounds, readable and below player burst.
- Health and overcharge pickups should create route decisions; repeated `nearby_ignored` values are investigation signals, not automatic bugs.
- Jump pad health is best read as trigger/landing parity first. A lower success count can still be acceptable if landings are happening and the route feels good.
- Bot route diversity should show more than one route label in normal sessions.
- Map health should be reviewed per arena; do not tune all arenas from one `Duel Pit V2` session.

## First Approved Readout

Session:

```text
C:\Users\Fabio\AppData\Roaming\Godot\app_userdata\FpsPlayground\telemetry\arena_20260619_202922_2301377
```

Observed:

- Integrity OK: `1344` events in both `events.jsonl` and `summary.json`.
- Lifecycle OK: `15` rounds started, `9` played, `3` match resets and `5` manual restarts.
- Jump pad parity OK: `9` triggers and `9` landings.
- Bot routing active: `7` route labels, including `overcharge`, `jump_pad`, `pressure`, `high`, `flank`, `health` and `engage`.
- Combat watch item: `player_rifle` dealt `88.7%` of total damage in that session.

## Track 14 Candidates From Data

- Review rifle dominance across more sessions before changing damage.
- Compare `Duel Pit V2`, `Relay Foundry V1` and `Crossfire Crucible V1` separately.
- If rifle dominance repeats, test small combat-role changes before touching movement or maps.
- If pickup ignored/contested values repeat, inspect pickup route value before changing pickup strength.
- If jump pad landings fall below triggers in future sessions, inspect route geometry and bot commitment.

## Track 13 Documentation Decision

Track 13 did not change gameplay. It promoted this baseline into the future roadmap and kept the next gameplay recommendation evidence-first: collect multi-arena readouts before tuning weapons, buffs, pickups, bot decisions or map geometry.
