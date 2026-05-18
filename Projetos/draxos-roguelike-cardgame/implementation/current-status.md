# Current Status

- Last Updated: `2026-05-15`
- Active Project Name: `draxos-roguelike-cardgame`
- Active Surface: `linear 29-map complete-run roguelike cardgame production plan`
- Active Track: `Track 02 - Complete Run Evolution`
- Active Track Status: `READY_FOR_IMPLEMENTATION_PLANNING`
- Current Operational Baseline: `Godot 4.6.2 Track 01 slice with Arcano/Invocador/Necromante, 3-save local menu with player names, ShipHub Deck/Mapa/Almas overlays, dedicated Deck and Almas screens, RunMap 13-node route, 3 tutorial maps, 9-card cost-1 starter decks, map 2 fixed cost-2 card reward, fixed mana/hand/passive/active rewards, map 6 hand-limit-only reward, real Lvl 2/Lvl 3 card upgrades on maps 3/4/9/12, rarity-aware reward choices, 2 real new reward cards per class on maps 7/11, save version 4 invalidating v3 and older while keeping stale saves deletable/overwritable, pre-combat discard/rebuy, Souls shop with 3 card-upgrade offers at 20 souls and 1 purchase per combat, translucent choice/reward modals, delayed post-combat automatic choices, compact battle HUD, four-stage combat, sacrifice confirmation, adjacent movement/swaps, allied board-area targets, duel enemy hand/deck/mana AI, Defense hold objective with side-lane pressure, Regeneracao/Carnica/Remover/Suicida mechanics, Necromante Diabrete replacing Punir, Necromante Ritual levels with Raio das Cinzas, Invocador once-per-turn +2/+1 passive, Ordem de Guerra at 0 mana, paid healing at +5 HP for 10 souls, enemy stat tuning around +20% across encounters, expanded VisualAssets map marker layout, and validated 13-map card battle loop`
- Active Goal: `execute Track 02 prompts to evolve the validated 13-map slice into the first complete 29-map run with rewards, relics, full keyword scope, improved enemy AI, expanded shop, and UI/visual upgrades`
- Validation: `2026-05-15 P05 playtest tuning validation green; 67/67 GUT tests passing; 536 asserts; 46 optional PNGs reported missing by design; 4 non-fatal ship overlay alpha debts reported`

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
- `tracks/track-02-complete-run-evolution/current-status.md`
- `tracks/track-02-complete-run-evolution/design-brief.md`
- `tracks/track-02-complete-run-evolution/implementation-prompts.md`

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/validate.gd
```

## Next

Start `T02-P01 - Track 02 Data Contract, Save Version, And Validation Scaffolding` from `tracks/track-02-complete-run-evolution/implementation-prompts.md`.
