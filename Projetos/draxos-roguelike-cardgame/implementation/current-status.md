# Current Status

- Last Updated: `2026-06-25`
- Project: `draxos-roguelike-cardgame`
- Portfolio status: `P0_IMPLEMENTACAO`
- Active surface: `Design Lab Content Wave 01 before manual promotion`
- Preserved long-form history: `implementation/tracks/track-02-complete-run-evolution/status-history-2026-06-06-design-lab-v1.md`

## Current Truth

Track 02 remains a complete Godot 4.6.2 roguelike cardgame baseline with fixed 29-map route, save/snapshot v5, reward schedule, relics, expanded Souls shop, keyword/status tooltips, complete Track 02 keyword mechanics, enemy galleries, hybrid enemy AI/intent, encounter modes, board formats, field effects, boss hooks, readability polish and modular validation.

Design Lab Content Wave 01 is now the current bridge from card/mechanic/enemy idea to playable numeric candidates before official content promotion. It uses proposal packs, mechanic registry V2, scoring profiles, context templates, official-neighbor comparison, lab-only overlay catalog variants, deterministic BattleEngine contexts, ranked candidates and promotion manifests without mutating `data/definitions/slice_catalog.json`.

Card Impact V5 remains the recommended regression harness before broad enemy-card redesigns. Card Impact V4.2 remains the default player-card-flow regression harness. Earlier V1-V4.1 packs remain preserved historical baselines.

## Active Goal

Review Content Wave 01 candidates, decide which cards should be manually promoted, and choose the first blocked mechanics that deserve engine/lab support before full-run feel playtests.

## Current Gate

Use `arcano_cards_wave01`, `invocador_cards_wave01`, `necromante_cards_wave01`, `enemy_cards_wave01` and `mechanics_backlog_wave01` as the first real authoring wave. Promote only manually approved recommended/viable candidates, keep unsupported mechanics blocked until engine/lab support exists, then protect promoted player/enemy content with Card Impact V4.2/V5 plus Run Lab smoke/quick before full-run feel playtests.

## Validation Snapshot

- Design Lab sample gate `design_lab_sample_v1 --max-variants=3`: PASS with 9 candidates, 3 selected recommendations and 0 blocked mechanics.
- Design Lab calibration packs: player PASS in explore with rejected high-risk variants; enemy PASS in explore through causal/AI contexts; mechanics FAIL by design when `steal_mana` is blocked.
- Design Lab pilot content full explore: FAIL by design with 93 candidates, 11 selected recommendations, 1 blocked mechanic and useful rejected risky/broken variants.
- Design Lab pilot content promotable subset gate: PASS with 104 candidates, 11 selected recommendations and 0 blocked mechanics.
- Design Lab Content Wave 01 player explores: Arcano PASS 48 candidates/8 recommendations, Invocador PASS 48/8, Necromante PASS 48/8. Promotable subset gates passed with Arcano 83/8, Invocador 96/8 and Necromante 86/8.
- Design Lab Content Wave 01 enemy explore: FAIL by design with 72 candidates, 8 selected recommendations and 24 rejected risky/broken variants. Promotable subset gate passed with 78 candidates and 8 selected recommendations after excluding the four risky/broken enemy ideas.
- Design Lab Content Wave 01 mechanics backlog: FAIL by design with 6 blocked cards and 5 blocked mechanics (`steal_mana`, `copy_last_spell`, `lane_shift`, `summon_from_discard`, `life_payment`), with no fake numeric tuning.
- Design Lab promotion manifests include official neighbors, risk notes, context failures and manual review questions while preserving manual approval and required validation gates.
- `validate.gd`: PASS at 226/226 GUT tests and 1975 asserts after Design Lab Content Wave 01.
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
