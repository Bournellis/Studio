# Current Status

- Last Updated: `2026-05-13`
- Active Project Name: `draxos-roguelike-cardgame`
- Active Surface: `linear 10-encounter roguelike cardgame slice`
- Active Track: `Track 01 - Playable Run Loop`
- Active Track Status: `P05_REDRAWN_CARD_BATTLE_BASELINE_VALIDATED`
- Current Operational Baseline: `Godot 4.6.2 Track 01 slice with Arcano, Invocador, and Necromante; mana inicial 2; redesigned 12-card starter decks with 4 card types x 3 copies and base hand limit 3; RunSession health, max mana, max hand size, souls, completed nodes, automatic rewards, passive unlock and active unlock state; 10 linear RunMap nodes covering limpar_mesa, ondas, duelo, defesa_posicao, sobreviver_turnos, and chefe_summoner; automatic rewards on maps 2/3/5/7 with map 3 granting +1 hand limit; combat cycle using Resolver Combate then maintenance/script, no summoning sickness and no separate enemy combat turn; front-lane combat with simultaneous damage, direct lane damage, iniciativa, defensor, reviver, enfraquecer, prender, promover, dynamic poder de habilidade, regeneracao, waves, defense objective, survive turns, duel hero kill, boss health and scripted summons; explicit enemy commander encounter flag with HP/mana/cardback HUD prep for duel maps; class passives locked until map 5 and class actives hidden/locked until map 7; VisualAssets manifest/autoload, state-aware card text, provisional 16:9 backgrounds, ShipHub 4-hotspot visual menu, RunMap route lines over the planet, Battle objective HUD with player HP/mana/resource dock, right-side Resolver Combate button, ESC pause menu, log button only, portrait battle cards, hand cards with floating base mana/ATK/HP badges and spell-only mana badges, field card slots with floating current ATK/HP and base mana cost, screenshot capture tool, and validation green 12/12`
- Active Goal: `playtest the redesigned 10-map route, tune enemy pressure against the new decks/mechanics, and distribute remaining rewards`
- Validation: `2026-05-13 Track 01 redesigned battle/card validation green; 12/12 GUT tests passing; 114 asserts; 28 optional PNGs reported missing by design`

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

Playtest the redesigned 10-map route, tune enemy pressure against the new decks/mechanics, and define the remaining non-soul rewards.
