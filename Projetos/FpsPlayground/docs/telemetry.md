# FpsPlayground Telemetry

- Status: Track 11 approved in human smoke.
- Storage: local Godot `user://telemetry/`.
- Scope: Arena Shooter duel instrumentation only.
- Implementation: `res://gameplay/telemetry/arena_telemetry_recorder.gd`.

## Output Files

- `events.jsonl`: append-only event stream, one JSON object per line.
- `summary.json`: compact session summary for quick playtest review.

The runtime writes files under `user://telemetry/<session_id>/` when local output is enabled.
`summary.json` is flushed after each recorded event, so compact review data stays aligned with `events.jsonl` even if the session is closed or reset before a clean `session_end`.

## Event Families

- `session_start`, `session_end`.
- `round_start`, `round_end`, `round_reset`.
- `shot_fired`, `shot_hit`, `shot_miss`.
- `damage_applied`, `knockback_applied`.
- `plasma_spawned`, `plasma_direct_hit`, `plasma_world_impact`, `plasma_blast`, `plasma_expired`.
- `pickup_spawned`, `pickup_collected`, `pickup_respawned`, `pickup_nearby_ignored`, `pickup_contested`.
- `bot_state_changed`, `bot_route_changed`, `bot_decision`, `bot_windup_started`, `bot_shot_resolved`.
- `movement_sample`, `jump_pad_triggered`, `jump_pad_landing`, `route_blocked`.

## Required Fields

Every event should include:

- `session_id`
- `event`
- `time_msec`
- `round_index`
- `map_id`
- `map_name`

`round_reset` uses `reason=next_round` after a finished round and `reason=manual_restart` when the player presses restart during active play.

Combat events should also include:

- `actor`
- `target`
- `weapon`
- `overcharged`
- `damage`
- `knockback`
- `hit`
- `distance`
- `position`

Bot events should also include:

- `state`
- `route_label`
- `active_route_key`
- `decision_reason`
- `has_line_of_sight`

## Summary Metrics

- Rounds played, winner counts and average round duration.
- Damage by source and actor.
- Shots, hits, misses and accuracy by fired weapon.
- Plasma direct vs blast contribution, with blast pressure tracked under `plasma` and `damage_by_source` instead of weapon accuracy.
- Overcharge pickups, consumed shots and useful overcharge damage.
- Health pickups, effective healing and wasted healing.
- Bot route usage and route diversity.
- Jump pad triggers and landing success.
- Movement samples, average distance between actors and airborne time.

## Manual Review Questions

- Who won each round and how long did it take?
- Which actor and weapon dealt the most damage?
- Did rifle, direct Plasma, Plasma Blast and overcharge contribute as intended?
- Which pickups were collected, ignored nearby or contested?
- Did the bot rotate routes, keep item priorities and complete jump pad routes?
- Did movement samples show suspicious airborne time, stuck distance or failed jump pad landings?

## Non-Goals

- No remote analytics.
- No player identity tracking.
- No balance changes.
- No dashboard-heavy UI in Track 11.
