# Current Status

- Last Updated: `2026-05-07`
- Active Project Name: `draxos-roguelike-cardgame`
- Active Surface: `mechanical class slice`
- Active Track: `Track 01 - Playable Run Loop`
- Active Track Status: `P04_MECHANICAL_CLASS_SLICE_VALIDATED`
- Current Operational Baseline: `Godot 4.6.2 mechanical slice with Arcano, Invocador, and Necromante class options; 15-card mockup decks; deterministic deck shuffle on battle start and discard recycle; RunSession mana, health, souls, pending rewards and paid healing; clear-board and waves encounters from docs; class active button in Battle; initial Fluxo, permanent buffs, Protecao/Voadora/Regeneracao, Cinzas, death hooks, debuffs, reanimation, waves, boss summons, and validation green 22/22`
- Active Goal: `iterate balance and UX on the first playable class/encounter slice`
- Validation: `2026-05-08 Track 01 mechanical slice validation green; 22/22 GUT tests passing; 165 asserts`

## Read Next

- `../AGENTS.md`
- `../../canon/canon-brief.md`
- `../docs/product-brief.md`
- `../docs/game-design-document.md`
- `../docs/architecture.md`
- `../docs/reuse-map.md`
- `tracks/track-00-project-bootstrap/current-status.md`
- `tracks/track-00-project-bootstrap/linear-execution-plan.md`
- `tracks/track-01-playable-run-loop/current-status.md`
- `tracks/track-01-playable-run-loop/linear-execution-plan.md`

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/validate.gd
```

## Next

Playtest Arcano, Invocador, and Necromante against `pouso_elemental` and `ondas_iniciais`; tune class decks, targeting UX, and encounter numbers.
