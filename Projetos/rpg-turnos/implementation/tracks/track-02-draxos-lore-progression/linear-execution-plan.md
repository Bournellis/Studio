# Track 02 Linear Execution Plan

- Last Updated: `2026-05-07`
- Status: `ACTIVE_LINEAR_PLAN`
- Execution Owner: `Codex`
- Scope: `RPG Turnos Track 02 - Draxos Lore And Progression Alignment`
- Validation Command: `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd`

## Purpose

This is the operational plan for implementing Track 02 in a single linear sequence.

Each future prompt should execute the next pending prompt in this file, update the relevant records, run validation when runtime or generated content changes, and leave the project in a clear handoff state.

This file does not replace:

- `../../../docs/game-design-document.md`
- `../../../docs/classes/README.md`
- `../../../docs/class-catalog-schema.md`
- `implementation-plan.md`

It defines execution order only.

## Execution Rules

- Work linearly. Do not start a later prompt until the previous prompt is complete.
- One prompt should produce one coherent runtime or documentation checkpoint.
- Keep mechanical IDs stable unless the prompt is explicitly the technical ID migration pass.
- Prefer adding tests before or with runtime changes.
- Regenerate generated resources whenever `data/definitions/slice_catalog.json`, catalog resource schema, or scene-generation inputs change.
- Run the validation command after code, generated resources, scene, data, or test changes.
- For documentation-only prompts, do not run Godot validation unless explicitly requested.
- At the end of each prompt, update this file's execution cursor and prompt status.
- If project status, active next step, baseline, or validation state changes, update `../../current-status.md`.
- If the observable studio snapshot changes, update `../../../../../08_Coordenacao_Agentes/Estado_Atual.md`.
- If a prompt completes a meaningful work item, move or update the matching Kanban record.

## Current Execution Cursor

Next prompt: `P01 - Catalog class resource plumbing`.

Current focus: make the class catalog available to runtime before implementing class behavior.

## Linear Prompt Sequence

| Prompt | Status | Goal | Validation |
|---|---|---|---|
| P00 | complete | Create this linear execution plan and align records. | Documentation-only |
| P01 | pending | Expose `classes` from JSON into generated catalog resources and `ContentLibrary`. | Run validation |
| P02 | pending | Add `selected_class` session/save state and class deck helpers without UI. | Run validation |
| P03 | pending | Implement data-driven hero metadata and hero power kernel for `Assaltante de Vazio`. | Run validation |
| P04 | pending | Implement Assaltante-only effect hooks: `on_destroy` and `on_combat_kill`. | Run validation |
| P05 | pending | Activate Assaltante starter deck through session/deck setup flow. | Run validation |
| P06 | pending | Add class selection screen MVP and route new games through it. | Run validation |
| P07 | pending | Assaltante integration checkpoint: polish labels, tests, docs, and records. | Run validation |
| P08 | pending | Implement Arquiteto core: upkeep triggers and structure repair hero power. | Run validation |
| P09 | pending | Complete Arquiteto support effects and playable starter deck. | Run validation |
| P10 | pending | Implement Dominador core: applied `enjoo`, extended duration, conditional growth. | Run validation |
| P11 | pending | Implement Tecelao core: resonance counter, formula amounts, spell-cast hooks. | Run validation |
| P12 | pending | Implement Vinculador token core: runtime token spawn, tags, non-lethal damage. | Run validation |
| P13 | pending | Complete Vinculador: capture, tag scaling, forced enemy combat. | Run validation |
| P14 | pending | Multi-class regression checkpoint: all five classes selectable and playable. | Run validation |
| P15 | pending | UI/readability design pass: define and implement the minimum playable presentation improvement. | Run validation |
| P16 | pending | Campaign content alignment: mission chain, rewards meaning, class-facing text. | Run validation |
| P17 | pending | RPG progression slice: rank/status state and gated dialogue/mission access. | Run validation |
| P18 | pending | Encounter design pass: one pressure test per class weakness. | Run validation |
| P19 | pending | New content expansion cluster using existing modes. | Run validation |
| P20 | pending | Technical ID and asset migration, with save migration coverage. | Run validation |

## Prompt Details

### P01 - Catalog Class Resource Plumbing

Goal: make the authored class catalog visible to runtime code without changing gameplay.

Expected work:

- Add `classes` to `data/resources/slice_catalog_resource.gd`.
- Generate class dictionaries from `data/definitions/slice_catalog.json` in `tools/content_generator.gd`.
- Add `ContentLibrary` helpers for class lookup, all classes, class hero, class hero power, and class starter deck.
- Add tests proving the 5 classes and their 20-card starter decks are available from the generated catalog.

Exit criteria:

- Generated catalog exposes 5 classes.
- Every class starter deck has exactly 20 cards and every listed card exists.
- Validation is green.

### P02 - Selected Class Session State

Goal: persist the chosen class as campaign state before adding the selection UI.

Expected work:

- Add `selected_class` to `core/game_session.gd`.
- Add save/load compatibility for old saves without `selected_class`.
- Add `select_class(class_id)`, `has_selected_class()`, and class deck initialization helpers.
- Keep old starter deck fallback for compatibility until class selection is active.
- Add tests for new game, save/load, corrupt/missing save fallback, and invalid class handling.

Exit criteria:

- Session can hold a selected class.
- Existing saves do not crash or lose baseline fallback behavior.
- Validation is green.

### P03 - Assaltante Hero Power Kernel

Goal: replace the hardcoded player hero power path with a data-driven kernel sufficient for Assaltante.

Expected work:

- Pass selected class/hero power config into `BattleEngine.start_battle`.
- Load player hero display name, max health, hero power name, cost, speed, and structured effect from class data.
- Implement `damage` hero power targeting `any_enemy_permanent`.
- Update UI button text and enable/disable rules from active hero power data.
- Add tests for `Disparo de Choque`: cost 1, once per own turn, requires priority, damages an enemy permanent, cannot target missing heroes in non-duel modes.

Exit criteria:

- Assaltante hero power is playable in battle tests.
- Legacy `Preparar Defesa` fallback remains available only when no class is selected.
- Validation is green.

### P04 - Assaltante Effect Hooks

Goal: support the two Assaltante card effects that need engine hooks.

Expected work:

- Implement spell `on_destroy` for `Garra do Vazio`.
- Implement permanent `on_combat_kill` for `Pilhador Implacavel`.
- Ensure hooks work in modes without enemy heroes.
- Add tests covering target destruction, no-trigger cases, draw behavior, bottom-of-deck rules, and outcome checks.

Exit criteria:

- Assaltante's special card effects work in isolation.
- Existing battle tests remain green.

### P05 - Assaltante Deck Activation

Goal: make the Assaltante starter deck the playable selected-class deck.

Expected work:

- Use selected class starter deck as the initial unlocked/selected deck after class selection state is set.
- Ensure deck setup screen can display and validate the Assaltante deck.
- Keep encounter rewards additive and class-agnostic.
- Add tests for class starter deck validation and deck setup population.

Exit criteria:

- Assaltante can enter battle with its real 20-card starter deck.
- Validation is green.

### P06 - Class Selection Screen MVP

Goal: add the blocking class choice before the campaign begins.

Expected work:

- Create a class selection scene through script/tool generation, not raw `.tscn` hand edits.
- Route `Novo jogo` to class selection when no class is selected.
- Display all 5 classes with name, tagline, and one short commitment line.
- Confirm selection, persist it, initialize the class deck, save, and enter the world.
- Add tests for scene layout and session mutation.

Exit criteria:

- New game cannot proceed into the campaign without choosing a class.
- The selected class persists through save/load.
- Validation is green.

### P07 - Assaltante Integration Checkpoint

Goal: close the first playable class slice cleanly.

Expected work:

- Review labels, button text, battle logs, result summaries, and deck setup names.
- Update `implementation/current-status.md`, Track 02 status, and Kanban.
- Record Assaltante as first playable class.
- Keep open systems for other classes explicitly pending.

Exit criteria:

- Assaltante is a coherent playable class from new game to battle result.
- Documentation and studio snapshots point to the next class prompt.

### P08 - Arquiteto Core

Goal: implement shared upkeep trigger infrastructure and the Arquiteto repair hero power.

Expected work:

- Add permanent upkeep trigger processing.
- Implement `heal_permanent` for own damaged structures.
- Add tests for trigger timing, repair legality, and structure-only targeting.

Exit criteria:

- Arquiteto's core identity can be tested without implementing every support card.

### P09 - Arquiteto Completion

Goal: finish the remaining Arquiteto effects required by its starter deck.

Expected work:

- Implement `increase_max_health`.
- Implement `set_state` for own structures with attack.
- Implement `damage_distributed`.
- Add tests around structure deck play patterns.

Exit criteria:

- Arquiteto is selectable and playable with a functioning starter deck.

### P10 - Dominador Core

Goal: implement the Dominador's board-control systems.

Expected work:

- Implement targeted `apply_status`.
- Implement extended `enjoo` duration.
- Implement conditional gain stats if enemies have `enjoo`.
- Implement armor lifesteal from damage.
- Add tests covering creatures, structures, mode independence, and duration boundaries.

Exit criteria:

- Dominador is selectable and playable with a functioning starter deck.

### P11 - Tecelao Core

Goal: implement resonance and spell sequencing.

Expected work:

- Add volatile battle `resonance` state.
- Increment resonance on resolved spell casts.
- Reset resonance at discard/end-of-turn boundary.
- Implement `amount: resonance`, `resonance_x2`, `resonance_override`, and `resonance_bonus`.
- Implement `on_spell_cast` and milestone once-per-turn behavior.
- Add tests for sequencing and reset behavior.

Exit criteria:

- Tecelao is selectable and playable with a functioning starter deck.

### P12 - Vinculador Token Core

Goal: implement runtime linked-token support before capture mechanics.

Expected work:

- Represent runtime tokens that do not return to deck.
- Add `vinculado` tags.
- Implement `spawn_vinculada`.
- Implement non-lethal damage.
- Add tests for destruction, slot placement, and deck cycling exclusions.

Exit criteria:

- Vinculador token effects can be tested safely.

### P13 - Vinculador Completion

Goal: finish Vinculador-specific capture and control effects.

Expected work:

- Implement `capture` hero power.
- Implement `count_own_tag` scaling.
- Implement `on_any_enemy_destroyed`.
- Implement `force_combat` between enemy permanents.
- Add tests across objective modes.

Exit criteria:

- Vinculador is selectable and playable with a functioning starter deck.

### P14 - Multi-Class Regression Checkpoint

Goal: lock the class system as the new baseline.

Expected work:

- Add or update regression tests that start battles with each class.
- Confirm no class card depends on enemy hero presence.
- Update docs and snapshots to mark Stage 2 class implementation complete.

Exit criteria:

- All 5 classes are playable.
- Validation is green.
- Next work moves to presentation and campaign alignment.

### P15 - UI/Readability Pass

Goal: make the current playable experience easier to test.

Expected work:

- Start with a short design decision inside this prompt.
- Improve the most blocking UI/readability issue first.
- Preserve existing no-final-art placeholder strategy.
- Add layout tests if affected.

Exit criteria:

- The game is more readable for test play without final art.

### P16 - Campaign Content Alignment

Goal: align mission chain, rewards, and text around Draxos operation logic.

Expected work:

- Assign mission purpose to each existing encounter.
- Review rewards meaning after classes are playable.
- Keep technical IDs stable.
- Update content docs and generated resources.

Exit criteria:

- The existing map reads as a coherent Draxos operation arc.

### P17 - RPG Progression Slice

Goal: add the first explicit RPG progression layer.

Expected work:

- Define the minimal progression unit: rank, status, level, or hybrid.
- Add session/save state.
- Gate dialogue or mission access through progression.
- Add tests for persistence and progression unlocks.

Exit criteria:

- Player growth maps to the novice Draxos rising in team status.

### P18 - Encounter Design Pass

Goal: make encounters pressure the five class identities.

Expected work:

- Add or adjust at least one encounter pressure point per class weakness.
- Use existing modes before adding new rules.
- Add tests for new objective/data assumptions.

Exit criteria:

- Each class has at least one encounter that stresses its weakness.

### P19 - New Content Expansion Cluster

Goal: add a small campaign content cluster only after systems are stable.

Expected work:

- Add a small set of encounters, boards, rewards, and mission text.
- Keep every new piece tied to an operational purpose.
- Validate generated resources and tests.

Exit criteria:

- New content expands the campaign without changing core rules unnecessarily.

### P20 - Technical ID And Asset Migration

Goal: clean legacy IDs after player-facing naming has stabilized.

Expected work:

- Plan and implement save migration.
- Rename technical IDs in data, generated resources, tests, scenes, and `AssetIds`.
- Keep compatibility for existing saves where needed.

Exit criteria:

- Technical IDs match stable terminology without breaking saves or generated content.

## Required End-Of-Prompt Record Updates

Every implementation prompt must leave the following record trail:

- This file: prompt status and `Current Execution Cursor`.
- `../../current-status.md`: latest baseline, validation, and next prompt when observable status changes.
- `current-status.md`: Track 02 local status and next action.
- `implementation-plan.md`: only if the stage-level plan changes.
- `../../../../../08_Coordenacao_Agentes/Estado_Atual.md`: only if studio snapshot changes.
- Kanban: update the active Doing card or move it when a larger milestone closes.

## Current Blockers

- None for P01.

Known future dependencies:

- P06 depends on P01-P05.
- P08-P13 depend on the class selection and class starter deck plumbing.
- P16 should wait until at least P14, because reward/card meaning depends on the playable class baseline.
- P20 must wait until player-facing naming stabilizes.
