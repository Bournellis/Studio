# Track 02 Design Brief - Complete Run Evolution

- Last Updated: `2026-05-18`
- Status: `APPROVED_FOR_IMPLEMENTATION_PLANNING`
- Project: `draxos-roguelike-cardgame`
- Goal: `First complete 29-map version of the game`
- Historical Baseline Dependency: `Track 01 - Playable Run Loop`

## Intent

Track 02 evolved the historical 13-map Track 01 slice into the first complete version of the game.

This is not a fast implementation pass. It is a full production stage divided into linear Codex implementation prompts so each future thread can execute one coherent block, validate it, and hand off the next block safely.

The final result should let the studio test:

- full-run duration, targeting around 90 minutes for a successful run;
- whether 29 fixed maps feel like a complete game arc;
- encounter variety across all current and planned modes;
- all planned keywords in real combat;
- enemy AI behavior and readable enemy intentions;
- reward pacing, deck growth, removals, upgrades, relics, shop value, max HP, max mana, and max hand size;
- visual clarity of the map, battle, rewards, keywords, relics, and enemy intent.

## Approved Product Contract

- The 29-map route is the first complete version of the game.
- The route is fixed and linear for Track 02.
- The player can lose before map 29.
- Difficulty should be moderate because there are no permanent account/meta upgrades.
- Target full-run duration is around 90 minutes for a player who reaches the end.
- The element structure is final for this stage: Terra, Gelo, Ar, Fogo.
- All proposed encounter types are in scope.
- All proposed keywords are in scope.
- Some keywords may be player-facing, enemy-only, or boss-only.
- Every keyword needs a floating tooltip/preview in-game.
- Existing class passives and actives stay intact.
- A new universal run relic system is introduced.
- The first Track 02 balance target uses max mana `6` and max hand size `5`.
- HP starts at `20`; fixed rewards raise it to `30`; shop and relics can raise it further.
- Reward rarity stays `70% common`, `25% rare`, `5% ultra rare`.
- Every map grants Souls plus one main reward category.
- The Souls shop is available between maps and refreshes after victories.
- Future implementation should use the copy-paste prompts in `implementation-prompts.md`.

## Content Inventory

Current real player card baseline per class:

- 3 starter cost-1 cards.
- 1 class cost-2 core card from map 2.
- 2 current new reward cards.
- Total: 6 real base cards per class.

Current placeholder inventory per class:

- 6 placeholder reward cards already exist in `slice_catalog.json`.
- These line up with the proposed Gelo, Ar, and Fogo card pairs.

Track 02 target per class:

- 12 base cards per class:
  - 6 current real cards;
  - 6 promoted cards from the design proposal.
- Every base card should have Lvl 2 and Lvl 3 versions.

Design implication:

- The project has enough authored card slots for the 29-map run if the 6 placeholders per class become real cards.
- The reward system should not offer new cards on too many maps. It should mix new cards, upgrades, relics, max stats, Souls, removal, duplication, and shop decisions.
- Deck growth is intended, but card removal must exist in both map rewards and shop.

## Route Contract

The route remains 29 fixed linear maps.

Target pacing:

- Terra: maps 1-8, onboarding plus first boss.
- Gelo: maps 9-15, control, attrition, first heavier counters.
- Ar: maps 16-22, speed, repositioning, flanks, chaos.
- Fogo: maps 23-29, damage, cascading deaths, final pressure.

Reward cadence is owned by `reward-system.md`.

The route table from `docs/design-proposals/rota-29-mapas.md` remains the backbone, with these production changes:

- Map 14 grants the remaining Gelo card.
- Map 15 grants +5 max HP plus a boss relic, not a permanent slot reward.
- Map 23 grants the final +1 max mana, reaching max mana 6.
- Map 28 grants a rare/ultra relic instead of an undefined class upgrade.

## System Documents

- `reward-system.md`: reward categories, map cadence, rarity, shop defaults, max stat pacing.
- `relics.md`: universal relic rules and initial relic pool.
- `enemy-ai-and-difficulty.md`: enemy AI direction, element behavior, difficulty policy.
- `linear-execution-plan.md`: production stages and acceptance gates.
- `implementation-prompts.md`: copy-paste prompts for future Codex implementation threads.
- `handoff-log.md`: running handoff protocol and per-thread completion log.

## Validation Policy

Documentation-only updates do not require Godot validation.

Every future implementation prompt must run:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/validate.gd
```

UI/map/battle visual changes must also capture screenshots using the existing project screenshot workflow.

Every implementation thread must update `current-status.md`, append `handoff-log.md`, and report the next prompt id.
