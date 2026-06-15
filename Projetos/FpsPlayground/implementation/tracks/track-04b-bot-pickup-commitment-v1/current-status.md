# Track 04B - Bot Pickup Commitment V1

- Status: `DOING`
- Started: `2026-06-15`
- Owner: Codex
- Branch: `codex/fpsplayground/track04b-bot-pickup-commitment-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track04b-bot-pickup-commitment-v1`
- Base: Track 04 merged; smoke reported map approved and bot improved, with pickup commitment issue.

## Human Smoke Input

Fabio reported:

- map approved;
- bot is better;
- bot sometimes ignores HP/boost even when beside the pickup.

## Goal

Make the bot commit to useful nearby pickups without turning it into a passive item collector.

## Scope

- Add local pickup commitment thresholds for health and overcharge.
- Let the bot interrupt strafe/engage/cooldown decisions for nearby useful pickups.
- Keep distant overcharge contesting conservative.
- Add automated tests for nearby health and nearby boost.

## Non-Goals

- No aim/damage tuning.
- No map/layout changes.
- No new weapon.
- No export/publication.

## Validation Plan

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
git diff --check
git status --short
```
