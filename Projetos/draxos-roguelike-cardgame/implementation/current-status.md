# Current Status

- Last Updated: `2026-05-15`
- Active Project Name: `draxos-roguelike-cardgame`
- Active Surface: `linear 13-encounter roguelike cardgame slice`
- Active Track: `Track 01 - Playable Run Loop`
- Active Track Status: `P12_EARLY_GAME_REWARD_UPDATE_VALIDATED`
- Current Operational Baseline: `Godot 4.6.2 Track 01 slice with Arcano/Invocador/Necromante, 3-save local menu with player names, ShipHub Deck/Mapa/Almas overlays, dedicated Deck and Almas screens, RunMap 13-node route, 3 tutorial maps, 9-card cost-1 starter decks, map 2 fixed cost-2 card reward, fixed mana/hand/passive/active rewards, 1-in-3 placeholder upgrade rewards, 1-in-3 placeholder new-card rewards, card upgrade count tracking, save version 2 invalidating old route saves, battle reward choice modal, compact battle HUD, four-stage combat, sacrifice confirmation, adjacent movement/swaps, duel enemy hand/deck/mana AI, Defense hold objective, Necromante Ritual levels with Raio das Cinzas, Invocador once-per-turn +2/+1 passive, Barreira Arcana cost 1 1/3 Defensor, paid healing at +5 HP for 10 souls, expanded VisualAssets map marker layout, and validated 13-map card battle loop`
- Active Goal: `design final upgrade branches and class reward cards, then playtest the full 13-map route`
- Validation: `2026-05-15 early-game reward update validation green; 59/59 GUT tests passing; 442 asserts; 40 optional PNGs reported missing by design; 4 non-fatal ship overlay alpha debts reported`

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

Run a design session for exact upgrade branches and class reward cards, then playtest the full 13-map route.
