# Current Status

- Last Updated: `2026-06-25`
- Project: `draxos-roguelike-cardgame`
- Portfolio status: `P0_IMPLEMENTACAO`
- Active surface: `Design Lab Calibration V1 before player/enemy card and mechanic content expansion`
- Preserved long-form history: `implementation/tracks/track-02-complete-run-evolution/status-history-2026-06-06-design-lab-v1.md`

## Current Truth

Track 02 remains a complete Godot 4.6.2 roguelike cardgame baseline with fixed 29-map route, save/snapshot v5, reward schedule, relics, expanded Souls shop, keyword/status tooltips, complete Track 02 keyword mechanics, enemy galleries, hybrid enemy AI/intent, encounter modes, board formats, field effects, boss hooks, readability polish and modular validation.

Design Lab Calibration V1 is now the recommended bridge from card/mechanic/enemy idea to playable numeric candidates before official content promotion. It uses proposal packs, mechanic registry V2, scoring profiles, context templates, official-neighbor comparison, lab-only overlay catalog variants, deterministic BattleEngine contexts, ranked candidates and promotion manifests without mutating `data/definitions/slice_catalog.json`.

Card Impact V5 remains the recommended regression harness before broad enemy-card redesigns. Card Impact V4.2 remains the default player-card-flow regression harness. Earlier V1-V4.1 packs remain preserved historical baselines.

## Active Goal

Expand player/enemy cards, mechanics and encounter contexts through Design Lab proposal packs before full-run feel playtests.

## Current Gate

Author the next player/enemy card and mechanic ideas as Design Lab packs using `context_template_ids`, tune candidates to viable/recommended, then promote manually and protect promoted content with Card Impact V4.2/V5 plus Run Lab smoke/quick before full-run feel playtests.

## Validation Snapshot

- Design Lab sample gate `design_lab_sample_v1 --max-variants=3`: PASS with 9 candidates, 3 selected recommendations and 0 blocked mechanics.
- Design Lab calibration packs: player PASS in explore with rejected high-risk variants; enemy PASS in explore through causal/AI contexts; mechanics FAIL by design when `steal_mana` is blocked.
- Design Lab promotion manifests include official neighbors, risk notes, context failures and manual review questions while preserving manual approval and required validation gates.
- `validate.gd`: PASS at 225/225 GUT tests and 1969 asserts after Design Lab Calibration V1.
- Card Impact V5 official before gate: PASS with zero structural errors, zero new failures and zero removed records.
- Run Lab smoke/quick official gates: PASS.
- Known optional visual asset, GUT resource and ship alpha warnings remain non-fatal.

## Read Next

1. `AGENTS.md`
2. `docs/design-lab.md`
3. `docs/autorun-lab.md`
4. `docs/playtest-track-02.md`
5. `docs/foundation-closeout.md`
6. `implementation/tracks/track-02-complete-run-evolution/status-history-2026-06-06-design-lab-v1.md`

## Preserved History

The long baseline, validation addendums, Card Impact V1-V5 details, Enemy Card Redesign Batch 02 Using V5 Terra, Design Lab V1 Foundation and prior validation notes were moved to `implementation/tracks/track-02-complete-run-evolution/status-history-2026-06-06-design-lab-v1.md`.
