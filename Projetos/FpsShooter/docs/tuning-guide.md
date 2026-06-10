# FPS Playground Tuning Guide

- Last updated: `2026-06-10`
- Status: `TRACK_05_COMPLETE`

## Purpose

This guide records where tuning values live and how to change them without accidentally changing accepted gameplay.

## Tuning Rule

During foundation refactors, move or group values only when behavior remains identical. Changing a value for feel belongs in a gameplay/tuning track with smoke notes.

## Current Tuning Owners

| Domain | Current Owner | Examples |
|---|---|---|
| Player movement and fire | `gameplay/player/fps_player_controller.gd` | move speed, jump, air control, mouse sensitivity, rifle/plasma cooldowns. |
| Arena map | `modes/arena/arena_root.gd` | floor size, spawn positions, jump pads, pickup positions, map markers. |
| Arena pickups | `modes/arena/arena_root.gd` with `gameplay/arena/arena_combat_rules.gd` for respawn choice | pickup radius, health amount, respawn timers. |
| Arena bot | `gameplay/bot/basic_duel_bot.gd` | speed, ideal distance, cooldown, aim error, route intervals, jump values. |
| Football field | `modes/football/football_root.gd` | field size, goals, spawns, goal limit. |
| Football kicks and scoring | `modes/football/football_root.gd` with `gameplay/football/football_match_rules.gd` for pure match math | kick reach, force, lift, contact radius, goal limit. |
| Football ball | `gameplay/football/football_ball.gd` | velocity clamp, reset behavior, physics tuning. |
| Football bot | `gameplay/football/football_bot.gd` | attack/defend movement and kick behavior. |
| Feedback | `presentation/feedback/fps_feedback_controller.gd` | effect colors, lifetimes, audio tones. |

## Target Direction

Track 05 may introduce:

- shared constant files for cross-mode values;
- grouped dictionaries for mode layout values;
- rule helpers that receive tuning values as parameters;
- tests that assert tuning-sensitive behavior.
- shared primitive builders that preserve per-mode material roughness/emission while removing construction duplication.
- pure match/combat helpers that keep the root scenes responsible for authority, signals and feedback.

Track 05 should avoid:

- editor resource pipelines for every value;
- external JSON/toml tuning files;
- broad balance changes;
- replacing accepted constants with values that are only guessed to be better.

## Manual Tuning Checklist

When a later track intentionally changes tuning:

1. State the target feel.
2. Change one cluster at a time.
3. Run automated validation.
4. Run the relevant smoke from `docs/validation.md`.
5. Update this guide if ownership moves.

## Current Accepted Feel

Arena Shooter:

- agile movement;
- readable knockback;
- rifle hitscan stays clean;
- Plasma Bolt is slower, visible and stronger;
- bot is fair, not perfect;
- high pickups require micro-commit;
- no void in `Duel Pit V2`.

Futebol:

- first-person arcade football;
- loose ball physics;
- LMB kick and RMB strong kick;
- match to 3 goals;
- goals are safe and closed;
- bot attacks and defends simply.
