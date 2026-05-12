# Current Status

- Last Updated: `2026-05-12`
- Active Project Name: `draxos-roguelike-cardgame`
- Active Surface: `visual-led menu and HUD class slice`
- Active Track: `Track 01 - Playable Run Loop`
- Active Track Status: `P05_MENU_HUD_REFORM_VALIDATED`
- Current Operational Baseline: `Godot 4.6.2 mechanical slice with Arcano, Invocador, and Necromante class options; 15-card mockup decks; deterministic deck shuffle and discard recycle; RunSession mana, health, souls, pending rewards and paid healing; clear-board and waves encounters; drag-and-drop battle targeting for hand cards and class spells; hover card preview; Necromante ritual choice modal; initial Fluxo, buffs, Protecao/Voadora/Regeneracao, Cinzas, death hooks, debuffs, reanimation, waves, boss summons, VisualAssets manifest/autoload, optional asset fallback reporting, provisional 16:9 backgrounds, ShipHub 4-hotspot visual menu, RunMap route lines over the planet, Battle classic cardgame HUD with compact ticker, safe frame overlay metadata, portrait battle cards, screenshot capture tool, and validation green 32/32`
- Active Goal: `add priority card art PNGs, normalize provisional background/frame assets, then playtest and tune balance/readability`
- Validation: `2026-05-12 Track 01 menu/HUD reform validation green; 32/32 GUT tests passing; 245 asserts; screenshots captured for ShipHub/RunMap/Battle at 1280x720 and 960x540; 31 optional PNGs reported missing by design`

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

Add priority card arts, replace/normalize provisional frames and backgrounds where needed, then playtest Arcano, Invocador, and Necromante against `pouso_elemental` and `ondas_iniciais`.
