# Production Status

- Last Updated: `2026-05-28`
- Status: `Track 02 complete-run build ready for user playtest`

## Current Reality

The project is the Estudio P0 implementation workspace for the menu-first Draxos roguelike cardgame. The live baseline is Track 02, not the older Track 01 slice.

Track 02 currently includes:

- fixed linear route with 29 maps across Terra, Gelo, Ar, and Fogo;
- save/snapshot version 5;
- three playable classes: Arcano, Invocador, Necromante;
- 8 reward cards per class with Lvl 2 and Lvl 3 upgrades;
- production reward schedule, utility rewards, relic rewards, universal relics, and expanded Souls shop;
- full Track 02 keyword/status vocabulary and implemented keyword engine;
- Terra/Gelo/Ar/Fogo enemy galleries, deterministic hybrid enemy AI, and visible enemy intent;
- encounter modes, board formats, field effects, and boss hooks for maps 8/15/22/29;
- modular GUT suites, generated catalog hashing, shared route pacing simulator, local Run Lab CSV/JSON output with Track 02 golden comparison, and internal directors/services for enemy AI/intent, rewards, Souls shop, battle preview data, HUD/objective readouts, and combat FX presentation.

## Validation

Latest green local baseline:

- GUT: `102/102` tests, `1252` asserts.
- Full-route smoke: `29/29` maps, 217 estimated turns, 116 HP loss, 0 deaths.
- Arcano seed `20260518`: 362 Souls earned, 291 spent, 71 left, 38-card final deck, 6 relics, 21 shop actions.
- Run Lab: `--compare-golden --require-golden` passes for Arcano, Invocador, and Necromante with seed `20260518`; Arcano is exact-golden protected and all three complete `29/29` without death.

Known non-fatal debt remains optional missing PNG art and ship overlay alpha warnings.

## Historical Material

Track 01 docs, 13-map notes, save v3/v4 references, and early reward/shop notes are historical implementation context. They are not the live production status unless a current Track 02 doc explicitly adopts them.

## Next Production Step

Run a human playtest of the complete Track 02 route using `docs/playtest-track-02.md`, then tune difficulty, shop economy, relic value, and pacing from observed feedback.
