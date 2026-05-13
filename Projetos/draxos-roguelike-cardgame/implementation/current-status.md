# Current Status

- Last Updated: `2026-05-13`
- Active Project Name: `draxos-roguelike-cardgame`
- Active Surface: `linear 10-encounter roguelike cardgame slice`
- Active Track: `Track 01 - Playable Run Loop`
- Active Track Status: `P11_SACRIFICE_MOVEMENT_NECRO_TUNING_VALIDATED`
- Current Operational Baseline: `Godot 4.6.2 Track 01 slice with Arcano/Invocador/Necromante, 3-save local menu with player names, mandatory player-name modal after class choice, ShipHub Deck/Mapa/Almas positioned overlays, dedicated Deck and Almas screens, Deck starter fallback, RunMap next-node selection, ESC-safe secondary screens, centered/scrolling battle choice/sacrifice modals, compact battle HUD hero targets, passive/active class tokens with hover details, four-stage combat with simultaneous front damage, sequential overflow, staged FX/logs, death removal synced to damage FX, area spell targeting for Tempestade Arcana, confirmed sacrifice when summoning over allied creatures, adjacent allied movement swaps that consume both units' movement, enemy commander hand/deck/mana AI that plays after combat in duels, Defense map reworked as a real objective hold, Survive map lightly buffed, Necromante passive reward unlocking active level 1 and active reward upgrading to level 2, Barreira Arcana with Defensor, autosave outside battle, victory reward modal, paid healing at +5 HP for 10 souls, expanded VisualAssets for main menu/class portraits/ship overlays, and the validated 10-node card battle loop`
- Active Goal: `playtest the sacrifice/movement/Cinzas tuning pass across the full 10-map route, replace alpha-debt ship overlay art, then define remaining rewards`
- Validation: `2026-05-13 sacrifice/movement/Cinzas/tuning validation green; 58/58 GUT tests passing; 409 asserts; 33 optional PNGs reported missing by design; 4 non-fatal ship overlay alpha debts reported`

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

Playtest the sacrifice/movement/Cinzas tuning pass across the full 10-map route, replace transparent ship overlay art for Mapa/Deck/Almas, then define the remaining non-soul rewards.
