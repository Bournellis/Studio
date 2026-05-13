# Current Status

- Last Updated: `2026-05-12`
- Active Project Name: `draxos-roguelike-cardgame`
- Active Surface: `linear 10-encounter roguelike cardgame slice`
- Active Track: `Track 01 - Playable Run Loop`
- Active Track Status: `P05_LINEAR_10_MAP_SLICE_VALIDATED`
- Current Operational Baseline: `Godot 4.6.2 Track 01 slice with Arcano, Invocador, and Necromante; mana inicial 2; starter decks without cost 3 cards; RunSession health, max mana, souls, completed nodes, automatic rewards, passive unlock and active unlock state; 10 linear RunMap nodes covering limpar_mesa, ondas, duelo, defesa_posicao, sobreviver_turnos, and chefe_summoner; automatic rewards on maps 2/3/5/7; front-lane combat with simultaneous damage, direct lane damage, iniciativa, regeneracao, waves, defense objective, survive turns, duel hero kill, boss health and scripted summons; explicit enemy commander encounter flag with HP/mana/cardback HUD prep for duel maps; class passives locked until map 5 and class actives hidden/locked until map 7; VisualAssets manifest/autoload, provisional 16:9 backgrounds, ShipHub 4-hotspot visual menu, RunMap route lines over the planet, Battle objective HUD with player HP/mana/resource dock, right-side end-turn button, ESC pause menu, log button only, portrait battle cards, hand cards with floating base mana/ATK/HP badges and spell-only mana badges, field card slots with floating current ATK/HP and base mana cost, screenshot capture tool, and validation green 48/48`
- Active Goal: `playtest full 10-map route, then redesign cards/enemies and distribute remaining rewards`
- Validation: `2026-05-12 Track 01 battle HUD refresh validation green; 48/48 GUT tests passing; 434 asserts; 37 optional PNGs reported missing by design`

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

Playtest the full 10-map route, then redesign cards/enemies and define the remaining non-soul rewards.
