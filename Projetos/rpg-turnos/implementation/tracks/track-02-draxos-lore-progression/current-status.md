# Track 02 Current Status

- Last Updated: `2026-05-12` (P08 complete)
- Status: `ACTIVE_LINEAR_PLAN`
- Track Name: `Track 02 - Draxos Lore And Progression Alignment`

## Goal

Turn the current playable C1 slice into the first Draxos campaign slice through controlled content, lore, and progression passes.

The track must preserve the validated card-slot runtime while migrating player-facing content toward the new Draxos invasion premise.

## Current Baseline

- C1 is the sole combat runtime.
- Official battle modes are implemented: `limpar_mesa`, `duelo`, `ondas`, `defesa`, `chefe_multiparte`, and `quebra_cabeca`.
- World progression, one-time encounter rewards, progressive NPC rewards, save/load, and art-ready placeholders exist.
- Runtime validation is green at the latest known baseline: `125/125` GUT tests, 653 asserts, through `tools/validate.gd`.
- Several player-facing catalog names already use Draxos/elemental language.
- The generated catalog now exposes the 3 new classes (Invocador, Arcano, Necromante) with `passiva`, `hero`, `hero_power`, and 20-card placeholder starter decks through `ContentLibrary`. Old 5 classes removed.
- Two new card definitions added: `reforco_aliado` (Invocador buff) and `amplificacao_campo` (Invocador area buff).
- `docs/class-catalog-schema.md` updated with `passiva` field and 3-class hero power reference.
- `GameSession` holds `selected_class` with full save/load compatibility and class deck helpers.
- `BattleEngine` now loads hero power from active class data via `ContentLibrary`; `use_player_hero_power(target)` dispatches data-driven; Preparar Defesa remains no-class fallback.
- `Amplificar` hero power implemented: permanent +2/+0 to chosen ally, cost 1, once per own turn.
- `Comandante de Campo` passive implemented: on player creature summon, highest-ATK ally gains +1/+0 permanent.
- `_apply_permanent_stat_buff` and `_play_stat_buff_spell` infrastructure added; `reforco_aliado` e `amplificacao_campo` are now playable cards.
- `test_class_invocador.gd` added with 14 tests covering passive, hero power, legacy fallback, and buff cards.
- `modes/class_select/class_select.tscn` + `class_select_root.gd` created: displays 3 classes (name, tagline, passiva, hero power); player selects one; session and deck initialized; save written; routes to world.
- `boot_root.gd` updated: Novo jogo routes to `class_select.tscn` instead of `world.tscn`.
- `GameSession.get_battle_config()` now includes `class_id` when a class is selected, wiring P04 hero power dispatch into live battles.
- 6 new P05 tests added to `test_content_and_session.gd`: battle config with/without class, full Invocador selection flow, deck validity, save/load round-trip, battle config persistence.
- **P06 — Invocador is first complete playable class:** hero power button text reads `display_name` from catalog (`"Amplificar"` for Invocador); `battle_root.gd` shows per-slot targeting buttons (`"Amplificar → Slot X"`) instead of a generic hero power button when `effect.target == "any_own_creature"`; class select screen "Hero Power:" label corrected to Portuguese; battle feedback hint de-coupled from "Preparar Defesa" name; 3 new P06 tests in `test_content_and_session.gd` cover hero power label data and empty-class fallback.
- Mechanical IDs remain legacy-compatible and should not be renamed opportunistically.

## Active Planning Rule

Track 02 now executes through `linear-execution-plan.md`.

Each prompt must:

- execute only the next pending prompt in the linear plan
- keep mechanical IDs stable unless explicitly in the ID migration prompt
- update records at the end of the prompt
- run validation after runtime, g