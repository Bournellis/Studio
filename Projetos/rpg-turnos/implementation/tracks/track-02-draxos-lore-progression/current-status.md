# Track 02 Current Status

- Last Updated: `2026-05-07`
- Status: `ACTIVE_LINEAR_PLAN`
- Track Name: `Track 02 - Draxos Lore And Progression Alignment`

## Goal

Turn the current playable C1 slice into the first Draxos campaign slice through controlled content, lore, and progression passes.

The track must preserve the validated card-slot runtime while migrating player-facing content toward the new Draxos invasion premise.

## Current Baseline

- C1 is the sole combat runtime.
- Official battle modes are implemented: `limpar_mesa`, `duelo`, `ondas`, `defesa`, `chefe_multiparte`, and `quebra_cabeca`.
- World progression, one-time encounter rewards, progressive NPC rewards, save/load, and art-ready placeholders exist.
- Runtime validation is green at the latest known baseline: `77/77`.
- Several player-facing catalog names already use Draxos/elemental language.
- Mechanical IDs remain legacy-compatible and should not be renamed opportunistically.

## Active Planning Rule

Track 02 now executes through `linear-execution-plan.md`.

Each prompt must:

- execute only the next pending prompt in the linear plan
- keep mechanical IDs stable unless explicitly in the ID migration prompt
- update records at the end of the prompt
- run validation after runtime, generated-resource, scene, data, or test changes

Each pass should still change one player-facing or runtime layer at a time:

1. story labels and dialogue
2. class fantasy
3. mission chain framing
4. card text and reward meaning
5. RPG progression systems
6. new content volume
7. technical ID and asset migration

## Next Implementation Candidate

Start with `P01 - Catalog class resource plumbing` from `linear-execution-plan.md`.

Expected scope:

- expose the authored `classes` array from JSON into generated catalog resources
- add `ContentLibrary` class helpers
- add tests proving the 5 classes and their 20-card starter decks are available
- no mechanical ID renames
- no battle rule changes
- regenerate resources and run validation

## Do Not Start Yet

- later class engine systems beyond P01
- final planet/crystal naming as hard canon
- broad card economy
- equipment/items
- save-breaking technical ID rename
- final art import

Those depend on decisions or later passes in `implementation-plan.md`.
