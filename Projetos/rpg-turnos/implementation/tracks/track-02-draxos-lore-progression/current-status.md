# Track 02 Current Status

- Last Updated: `2026-05-12` (P04 complete)
- Status: `ACTIVE_LINEAR_PLAN`
- Track Name: `Track 02 - Draxos Lore And Progression Alignment`

## Goal

Turn the current playable C1 slice into the first Draxos campaign slice through controlled content, lore, and progression passes.

The track must preserve the validated card-slot runtime while migrating player-facing content toward the new Draxos invasion premise.

## Current Baseline

- C1 is the sole combat runtime.
- Official battle modes are implemented: `limpar_mesa`, `duelo`, `ondas`, `defesa`, `chefe_multiparte`, and `quebra_cabeca`.
- World progression, one-time encounter rewards, progressive NPC rewards, save/load, and art-ready placeholders exist.
- Runtime validation is green at the latest known baseline: `78/78` (P04 validation pending local run).
- Several player-facing catalog names already use Draxos/elemental language.
- The generated catalog now exposes the 3 new classes (Invocador, Arcano, Necromante) with `passiva`, `hero`, `hero_power`, and 20-card placeholder starter decks through `ContentLibrary`. Old 5 classes removed.
- Two new card definitions added: `reforco_aliado` (Invocador buff) and `amplificacao_campo` (Invocador area buff).
- `docs/class-catalog-schema.md` updated with `passiva` field and 3-class hero power reference.
- `GameSession` holds `selected_class` with full save/load compatibility and class deck helpers.
- `BattleEngine` now loads hero power from active class data via `ContentLibrary`; `use_player_hero_power(target)` dispatches data-driven; Preparar Defesa remains no-class fallback.
- `Amplificar` hero power implemented: permanent +2/+0 to chosen ally, cost 1, once per own turn.
- `Comandante de Campo` passive implemented: on player creature summon, highest-ATK ally gains +1/+0 permanent.
- `_apply_permanent_stat_buff` and `_play_stat_buff_spell` infrastructure added; `reforco_aliado` and `amplificacao_campo` are now playable cards.
- `test_class_invocador.gd` added with 14 tests covering passive, hero power, legacy fallback, and buff cards.
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

Continue with `P05 - Invocador Deck Activation and Class Selection Screen` from `linear-execution-plan.md`.

Expected scope:

- Activate Invocador starter deck through session/deck setup flow
- Create class selection scene (script/tool generation, not raw `.tscn`)
- Route `Novo jogo` to class selection when no class is selected
- Display 3 classes with name, tagline, and one commitment line each
- Confirm selection, persist to save, initialize class deck, enter world
- Add tests for scene routing, session mutation, deck loading, and save/load round-trip

## Do Not Start Yet

- later class engine systems beyond P02
- final planet/crystal naming as hard canon
- broad card economy
- equipment/items
- save-breaking technical ID rename
- final art import

Those depend on decisions or later passes in `implementation-plan.md`.
