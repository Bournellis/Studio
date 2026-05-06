# Track 02 Current Status

- Last Updated: `2026-05-06`
- Status: `PLANNED`
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

Each pass should change one player-facing layer at a time:

1. story labels and dialogue
2. class fantasy
3. mission chain framing
4. card text and reward meaning
5. RPG progression systems
6. new content volume
7. technical ID and asset migration

## First Implementation Candidate

Start with Pass 01 from `implementation-plan.md`: a narrow runtime-facing lore pass.

Expected scope:

- hero and enemy display labels if any placeholders remain
- hub NPC/command briefing text
- first mission chain labels and short mission notes
- no mechanical ID renames
- no new cards
- no battle rule changes
- regenerate resources and run validation

## Do Not Start Yet

- multiple playable classes
- final planet/crystal naming as hard canon
- broad card economy
- equipment/items
- save-breaking technical ID rename
- final art import

Those depend on decisions or later passes in `implementation-plan.md`.
