# FpsPlayground Telemetry Readout

- Status: Track 12 approved; Track 13 documentation rebaseline complete.
- Scope: local report tool for Track 11 telemetry sessions.
- Runner: `res://tools/telemetry_readout.gd`.
- Analyzer: `res://gameplay/telemetry/telemetry_readout_analyzer.gd`.

## Commands

Read the latest session under Godot `user://telemetry`:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\FpsPlayground -s res://tools/telemetry_readout.gd -- --latest
```

Read one explicit session:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\FpsPlayground -s res://tools/telemetry_readout.gd -- --session="C:\Users\Fabio\AppData\Roaming\Godot\app_userdata\FpsPlayground\telemetry\arena_20260619_202922_2301377"
```

Use `--json` for the full structured readout.

## Report Sections

- Integrity: confirms `events.jsonl`, `summary.json` and event counts are aligned.
- Lifecycle: rounds, match resets, manual restarts and final session reason.
- Rounds: winners, duration, score and end health.
- Combat: damage by actor/source and weapon accuracy rows.
- Plasma and overcharge: direct/blast contribution, consumed shots and useful damage.
- Pickups: spawned/collected counters and per-kind healing/contest/ignored data.
- Bot: states, routes, decisions, route diversity and line-of-sight ratio.
- Movement: sample counts, speeds, distance, airborne samples and jump pad landing rate.
- Alerts: `ERROR`, `WARN` and `WATCH` notes for quick balance review.

## Human Use

The readout is evidence, not automatic tuning. Use it to choose the next track, then confirm changes through playtest. Track 12 did not alter movement, maps, jump pads, weapons, pickups or bot behavior.

The recommended next use is `Track 14 - Multi-Arena Balance Baseline V1`: compare readouts from all current arenas before changing weapon values, pickups, buffs, bot behavior or map geometry.
