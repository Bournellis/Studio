# Current Status

- Last Updated: `2026-05-13`
- Active Project Name: `draxos-roguelike-cardgame`
- Active Surface: `linear 10-encounter roguelike cardgame slice`
- Active Track: `Track 01 - Playable Run Loop`
- Active Track Status: `P09_BATTLE_HUD_LAYOUT_VALIDATED`
- Current Operational Baseline: `Godot 4.6.2 Track 01 slice with Arcano/Invocador/Necromante, 3-slot local save menu, forced class-pick modal on new game, ShipHub Deck/Mapa/Almas navigation as positioned scene overlays without run-state panel, dedicated Deck and Almas screens, Deck starter fallback, RunMap next-node selection, ESC-safe secondary screens, centered/scrolling battle choice modals, compact battle HUD composition for dense encounters, area spell targeting for Tempestade Arcana, drag movement for allied creatures, enemy commander hand/deck/mana AI for duels, stronger survive/boss openings, autosave outside battle, victory reward modal, paid healing at +5 HP for 10 souls, expanded VisualAssets for main menu/class portraits/ship overlays, and the validated 10-node card battle loop`
- Active Goal: `playtest the reformed route and battle pressure, replace alpha-debt ship overlay art, then distribute remaining rewards`
- Validation: `2026-05-13 battle HUD layout validation green; 35/35 GUT tests passing; 276 asserts; 33 optional PNGs reported missing by design; 4 non-fatal ship overlay alpha debts reported`

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

Playtest the reformed route and battle pressure, replace transparent ship overlay art for Mapa/Deck/Almas, then define the remaining non-soul rewards.
