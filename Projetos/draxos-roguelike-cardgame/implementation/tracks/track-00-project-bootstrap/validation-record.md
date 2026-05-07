# Track 00 Validation Record

- Last Updated: `2026-05-07`
- Track: `Track 00 - Project Bootstrap`
- Status: `COMPLETE`
- Final Checkpoint: `P07 - First Playable Checkpoint`

## Final Validation

Command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/validate.gd
```

Result:

- GUT: `21/21 passed`
- Asserts: `148`
- Script result: `[validate] success`

## Delivered Baseline

- Official Godot project scaffold.
- Local Draxos Roguelike docs and status records.
- JSON-driven local catalog and generated resource.
- Boot, ShipHub, RunMap, and Battle placeholder scenes.
- RunSession node selection and completion tracking.
- Simplified local BattleEngine using slot counts.
- Stable 5-card hand, draw-on-play, discard recycle, sacrifice replacement, and automatic attacks.
- First `limpar_mesa` playable placeholder.
- First `chefe_summoner` playable placeholder with scripted boss summons.

## Residual Scope

Track 00 intentionally does not finalize classes, rewards, map encounter chain, enemy scripts, ShipHub systems, or final combat tuning.
