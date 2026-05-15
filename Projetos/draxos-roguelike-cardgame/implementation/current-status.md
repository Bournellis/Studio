# Current Status

- Last Updated: `2026-05-15`
- Active Project Name: `draxos-roguelike-cardgame`
- Active Surface: `linear 13-encounter roguelike cardgame slice`
- Active Track: `Track 01 - Playable Run Loop`
- Active Track Status: `P13_REAL_UPGRADES_REWARD_CARDS_VALIDATED`
- Current Operational Baseline: `Godot 4.6.2 Track 01 slice with Arcano/Invocador/Necromante, 3-save local menu with player names, ShipHub Deck/Mapa/Almas overlays, dedicated Deck and Almas screens, RunMap 13-node route, 3 tutorial maps, 9-card cost-1 starter decks, map 2 fixed cost-2 card reward, fixed mana/hand/passive/active rewards, map 6 hand-limit-only reward, real Lvl 2/Lvl 3 card upgrades on maps 3/4/9/12, 2 real new reward cards per class on maps 7/11, save version 3 invalidating v2 while keeping stale saves deletable/overwritable, translucent choice/reward modals, delayed post-combat automatic choices, compact battle HUD, four-stage combat, sacrifice confirmation, adjacent movement/swaps, duel enemy hand/deck/mana AI, Defense hold objective, Regeneracao/Carniça/Remover/Punir mechanics, Necromante Ritual levels with Raio das Cinzas, Invocador once-per-turn +2/+1 passive, paid healing at +5 HP for 10 souls, stronger maps 7-13, expanded VisualAssets map marker layout, and validated 13-map card battle loop`
- Active Goal: `playtest the full 13-map route with real upgrades, new cards, save v3, and stronger late-map pressure`
- Validation: `2026-05-15 real upgrades/reward cards validation green; 65/65 GUT tests passing; 511 asserts; 46 optional PNGs reported missing by design; 4 non-fatal ship overlay alpha debts reported`

## Read Next

- `../AGENTS.md`
- `../../canon/canon-brief.md`
- `../docs/product-brief.md`
- `../docs/game-design-document.md`
- `../docs/design-early-game.md`
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

Playtest the full 13-map route with real upgrades, new cards, save v3, and stronger maps 7-13; then tune difficulty/reward cadence.
