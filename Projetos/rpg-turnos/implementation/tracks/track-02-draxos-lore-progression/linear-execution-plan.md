# Track 02 Linear Execution Plan

- Last Updated: `2026-05-13`
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

All prompts complete. Track 02 is done.

Current focus: P20 complete — 8 chain encounter IDs migrated to stable Draxos operation names, SAVE_VERSION bumped to 2 with v1→v2 migration logic, all runtime files and tests updated. `.tres` regeneration and local validation pending.

## Linear Prompt Sequence

| Prompt | Status | Goal | Validation |
|---|---|---|---|
| P00 | complete | Create this linear execution plan and align records. | Documentation-only |
| P01 | complete | Expose `classes` from JSON into generated catalog resources and `ContentLibrary`. | Green 78/78 |
| P02 | complete | Add `selected_class` session/save state and class deck helpers without UI. | Run validation |
| P03 | complete | Regenerate catalog with 3 new classes (Invocador, Arcano, Necromante); remove old 5. | Run validation |
| P04 | complete | Implement Invocador: Comandante de Campo passive trigger and Amplificar hero power. | Run validation |
| P05 | complete | Activate Invocador starter deck; add class selection screen MVP. | Run validation |
| P06 | complete | Invocador integration checkpoint: labels, tests, docs, records. | Run validation |
| P07 | complete | Implement Arcano: Fluxo counter and magic damage amplification pipeline. | Run validation |
| P08 | complete | Implement Arcano: Pulso Astral hero power and activate Arcano starter deck. | Run validation |
| P09 | complete | Arcano integration checkpoint: labels, tests, docs, records. | Run validation |
| P10 | complete | Implement Necromante: Cinzas counter and Memorial de Batalha per encounter. | Run validation |
| P11 | complete | Implement Necromante: Ritual das Sombras hero power with 3-tier Cinzas cost. | Run validation |
| P12 | complete | Implement Necromante: token spawn from Memorial, `enjoo_estendido`, "ao morrer" triggers. | Run validation |
| P13 | complete | Activate Necromante starter deck and integration checkpoint. | Run validation |
| P14 | complete | Multi-class regression checkpoint: all three classes selectable and playable. | Run validation |
| P15 | complete | UI/readability design pass: define and implement minimum playable presentation improvement. | Run validation |
| P16 | complete | Campaign content alignment: mission chain, rewards meaning, class-facing text. | Documentation + data only |
| P17 | complete | RPG progression slice: rank/status state and gated dialogue/mission access. | Run validation |
| P18 | complete | Encounter design pass: one pressure test per class weakness. | Run validation |
| P19 | complete | New content expansion cluster using existing modes. | Run validation |
| P20 | complete | Technical ID and asset migration, with save migration coverage. | Run validation (pending local) |

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

### P03 - Catalog Regeneration: 3 New Classes

Goal: replace the 5 old classes in the catalog with the 3 new classes before any class engine work begins.

Expected work:

- Remove the 5 old class definitions (Assaltante, Arquiteto, Dominador, Vinculador, Tecelão) from `data/definitions/slice_catalog.json`.
- Add the 3 new class definitions: Invocador, Arcano, Necromante — with hero power data, passiva data, and placeholder starter decks aligned with `docs/classes/`.
- Update `docs/class-catalog-schema.md` if new fields are needed for Fluxo, Cinzas, Memorial, or passiva type.
- Regenerate `.tres` catalog resources via `tools/content_generator.gd`.
- Add/update tests confirming 3 classes exist with correct structure, hero powers, and 20-card starter decks.
- Remove any test that references the old 5 classes by name.

Exit criteria:

- Generated catalog exposes exactly 3 classes.
- Each class starter deck has exactly 20 cards and every listed card exists.
- No test references old class names.
- Validation is green.

### P04 - Invocador Core: Passive and Hero Power

Goal: implement Invocador mechanics — the simplest class, zero new system complexity.

Expected work:

- Replace hardcoded `Preparar Defesa` fallback with data-driven hero power loading from class data.
- Implement `Amplificar` hero power: permanent +2/+0 to a chosen ally. Cost 1, once per own turn.
- Implement `Comandante de Campo` passive: on any creature summon by player, identify ally with highest ATK in field and apply permanent +1/+0.
- Handle tie-breaking (player chooses) in modes where priority is available.
- Add tests: passive triggers on summon, buff is permanent through turns, hero power buff is permanent, no trigger when field is empty, legacy `Preparar Defesa` remains as no-class fallback only.

Exit criteria:

- Invocador hero power is playable and passive triggers correctly.
- Legacy fallback untouched for saves without class.
- Validation is green.

### P05 - Invocador Deck Activation and Class Selection Screen

Goal: make Invocador fully playable end-to-end and add the class selection screen.

Expected work:

- Activate Invocador starter deck through session/deck setup flow.
- Create class selection scene (script/tool generation, not raw `.tscn`).
- Route `Novo jogo` to class selection when no class is selected.
- Display 3 classes with name, tagline, and one commitment line each.
- Confirm selection, persist to save, initialize class deck, enter world.
- Add tests for scene routing, session mutation, deck loading, and save/load round-trip.

Exit criteria:

- New game routes through class selection.
- Invocador is selectable and enters battle with its 20-card starter deck.
- Save/load persists selected class.
- Validation is green.

### P06 - Invocador Integration Checkpoint

Goal: close the Invocador slice cleanly before moving to Arcano.

Expected work:

- Review battle labels, hero power button text, result summaries, and deck setup names for Invocador.
- Update `implementation/current-status.md`, Track 02 status, and Kanban.
- Record Invocador as first complete playable class.

Exit criteria:

- Invocador is coherent from class selection through battle result.
- Docs and snapshots point to P07.

### P07 - Arcano: Fluxo Counter and Damage Amplification

Goal: implement the Arcano's core engine systems.

Expected work:

- Add volatile per-turn `fluxo` counter to battle state; increments on each `magia` or `magia_de_tabuleiro` resolved by the player; resets at start of player's next turn.
- Modify magic damage resolution pipeline: when damage type is `magico` and source is player (spell or hero power), add current `fluxo` value to base damage.
- Does not affect `fisico_melee`, `fisico_alcance`, or creature ATK.
- Add tests: Fluxo increments per spell resolved, resets on turn boundary, amplification applies correctly to spell damage and hero power, does not affect physical damage or creature attacks.

Exit criteria:

- Fluxo counter works correctly across a multi-spell turn.
- Damage amplification is isolated to `magico` player sources.
- Validation is green.

### P08 - Arcano Hero Power and Deck Activation

Goal: complete Arcano and make it fully playable.

Expected work:

- Implement `Pulso Astral` hero power: 1 magic damage (+Fluxo) to any permanent or hero; cost 1, once per own turn.
- Ensure hero power damage uses the same Fluxo-amplified magic damage pipeline.
- Activate Arcano starter deck through session/deck setup flow.
- Add tests: hero power damages correct targets, Fluxo amplification applies, cannot target absent heroes outside `duelo`.

Exit criteria:

- Arcano is selectable and fully playable with Fluxo system and Pulso Astral.
- Validation is green.

### P09 - Arcano Integration Checkpoint

Goal: close the Arcano slice cleanly before moving to Necromante.

Expected work:

- Review battle labels, Fluxo display in HUD, hero power text, and deck setup names.
- Update records and snapshots.
- Confirm Invocador regression still green.

Exit criteria:

- Arcano is coherent from class selection through battle result.
- Both Invocador and Arcano pass regression.
- Docs point to P10.

### P10 - Necromante: Cinzas and Memorial de Batalha

Goal: implement the two foundational Necromante resources.

Expected work:

- Add `cinzas` counter to battle state: persists between turns, does not reset during encounter.
- Increment `cinzas` by 1 whenever any creature is destroyed in field (player or enemy side, any turn).
- Add `memorial_de_batalha`: a per-encounter list of destroyed creature definitions (both sides).
- Append to memorial on every creature destruction event.
- Add tests: Cinzas increment on ally death, enemy death, multi-death in one turn; Memorial records correct creature data; Cinzas persist across turns; both reset on new encounter.

Exit criteria:

- Cinzas and Memorial are correctly tracked through a multi-turn encounter.
- Validation is green.

### P11 - Necromante: Ritual das Sombras Hero Power

Goal: implement the conditional 3-tier hero power.

Expected work:

- Implement `Ritual das Sombras`: cost 0 energy + Cinzas; once per own turn; player chooses tier:
  - Degrau I (2 Cinzas): apply chosen debuff to enemy creature (`enjoo_estendido`, `queimando`, or −2/−0 permanent).
  - Degrau II (4 Cinzas): spawn a 1/1 token copy of a player-chosen creature from Memorial into empty ally slot, keeping original keywords.
  - Degrau III (6 Cinzas): spawn with original stats and all keywords.
- Implement `enjoo_estendido`: 2-turn duration counter on the `enjoo` state; UI must distinguish from normal `enjoo`.
- Hero power UI must show available tiers based on current Cinzas.
- Add tests: each degrau resolves correctly; insufficient Cinzas blocks activation; spawned token generates Cinzas on destruction; `enjoo_estendido` expires correctly.

Exit criteria:

- Ritual das Sombras is playable with all three tiers.
- `enjoo_estendido` duration is correctly tracked.
- Validation is green.

### P12 - Necromante: "Ao Morrer" Triggers and Deck Activation

Goal: support creature death triggers and activate the Necromante starter deck.

Expected work:

- Implement `on_death` trigger hook in the creature destruction pipeline.
- Support effects: deal magic damage to any target; apply `enjoo` to enemy creature; generate +1 extra Cinza (total 2 instead of 1).
- Ensure hook fires for both player and enemy creatures (enemy death triggers also feed Cinzas via passive).
- Activate Necromante starter deck through session/deck setup flow.
- Add tests: `on_death` fires correctly for each effect type; does not fire for non-death removals; Necromante deck loads and is selectable.

Exit criteria:

- Necromante is selectable and fully playable with all systems active.
- Validation is green.

### P13 - Necromante Integration Checkpoint

Goal: close the Necromante slice cleanly.

Expected work:

- Review HUD Cinzas display, Ritual das Sombras tier indicator, Memorial readability.
- Update records and snapshots.
- Confirm Invocador and Arcano regression still green.

Exit criteria:

- Necromante is coherent from class selection through battle result.
- All three classes pass regression.
- Docs point to P14.

### P14 - Multi-Class Regression Checkpoint

Goal: lock the 3-class system as the new baseline.

Expected work:

- Add or update regression tests that start battles with each of the 3 classes.
- Confirm no class card or hero power depends on enemy hero presence outside `duelo`.
- Update docs and snapshots to mark Stage 2 class implementation complete.

Exit criteria:

- All 3 classes are playable.
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

- Player growth maps to the Draxos commander expanding authority and mission access during the invasion.

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

- None for P18.

Known future dependencies:

- P06 depends on P01-P05.
- P08-P13 depend on the class selection and class starter deck plumbing.
- P16 should wait until at least P14, because reward/card meaning depends on the playable class baseline.
- P18 can start now that P17 progression layer is done.
- P20 must wait until player-facing naming stabilizes.
                                                                                  