# Design Lab

## Metadata

- status: living
- authority: technical_contract
- last_verified: 2026-07-16
- review_when: proposta, scoring, contextos, relatorios ou promocao mudar
- supersedes: none
- superseded_by: none

- Baseline: `DESIGN_LAB_CONTENT_WAVE01`
- Scope: proposal packs, content-wave authoring, context templates, lab-only prototype cards, deterministic numeric variants, official-neighbor comparison, battle/enemy contexts, interpretable scoring, reports and promotion manifest.

## Purpose

Design Lab is the creation-side lab for the Draxos roguelike cardgame. Its job is to turn an idea for a card, enemy card, mechanic or encounter into playable numeric candidates before that content touches the official catalog.

It is intentionally separate from Regression Lab/Card Impact. Regression tooling protects accepted Track 02 content. Design Lab explores prototype content, runs it through deterministic contexts and writes reports plus a promotion manifest.

The current contract is CLI/report-first. Dashboard, replay and automatic catalog patches remain future work.

## Entry Point

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_design_lab.gd -- --pack=design_lab_sample_v1 --mode=gate --max-variants=3
```

Useful options:

```text
--pack=<id|path>
--card=<id|all>
--cards=<id,id>
--mode=explore|gate
--components=battle,encounter
--profile=<profile_id>
--max-variants=<n>
--out=user://design_lab/<pack_id>
--gate
```

`--max-variants` is a per-card cap. Use a low number while drafting a large pack, then raise it when the ranges look sane.

`macro` is reserved for a future run-scale Design Lab component. If requested through `--components`, V1.5 reports a warning and does not claim macro coverage.

## Data

Proposal packs live in:

```text
data/lab/design/proposals/
```

Shared lab contracts live in:

```text
data/lab/design/mechanic_registry.json
data/lab/design/scoring_profiles.json
data/lab/design/context_templates.json
```

Useful built-in packs:

```text
design_lab_sample_v1.json
design_lab_calibration_player_v1.json
design_lab_calibration_enemy_v1.json
design_lab_calibration_mechanics_v1.json
design_lab_pilot_content_v1.json
arcano_cards_wave01.json
invocador_cards_wave01.json
necromante_cards_wave01.json
enemy_cards_wave01.json
mechanics_backlog_wave01.json
```

Each proposal card must define:

- `owner`
- `role`
- `design_intent`
- `timing`
- `valid_targets`
- `mechanics`
- `variant_space`
- at least one context through `context_ids`, `context_template_ids` or pack-level `encounter_contexts`

New mechanics can be described before they exist, but they must appear in `mechanic_registry.json`. If their status is `blocked_missing_engine_support`, Design Lab reports the card as `blocked` and does not fake numeric tuning.

## Mechanic Registry

The registry is now a support matrix, not only a list of names. Each mechanic declares:

- numeric fields that can be tuned
- `effect_actions`, `keyword_ids`, `on_enter_actions` and `on_death_actions`
- expected signature fields proving the mechanic fired
- required context templates
- required BattleEngine, AI and report hooks
- promotion gates before official content adoption

Statuses:

```text
implemented
lab_only
blocked_missing_engine_support
```

The loader rejects packs that reference missing mechanics. Blocked mechanics generate blocked candidates and appear in the report/promotion manifest.

## Context Templates

`context_templates.json` provides reusable battle contexts so authors can describe intent without rewriting harness data in every pack.

Current player templates include:

- `player_isolated`
- `player_empty_board`
- `player_full_board`
- `player_lane_pressure`
- `player_low_health`
- `player_big_target`
- `player_small_swarm`
- `player_combo_setup`
- `player_card_flow_room`

Current enemy templates include:

- `enemy_first_combat`
- `enemy_lane_pressure`
- `enemy_swarm_pressure`
- `enemy_control_pressure`
- `enemy_boss_tool`
- `enemy_ai_choice_context`

Cards can use:

```json
"context_template_ids": ["player_isolated", "player_big_target"]
```

Per-card overrides can be supplied through:

```json
"context_overrides": {
	"player_isolated": {"enemy_health": 120}
}
```

Pack-local `encounter_contexts` still work and are useful for one-off setup.

## Prototype Overlay

Design Lab starts from the generated official catalog, duplicates it in memory, appends prototype variant cards and optional lab encounters, then discards the overlay after the run.

It never writes:

```text
data/definitions/slice_catalog.json
```

Supported authoring forms:

- `new_card_id` for brand-new lab-only cards.
- `extends_card_id` for variants based on an official card.
- Player cards and enemy cards in the same pack.
- Encounter contexts declared by design intent.

## Variant Generation

`variant_space` expands deterministic numeric grids. Supported field paths include:

```text
cost
command_cost
attack
health
effect.amount
effect.count
effect.duration
effect.attack
effect.health
effect.mana
effect.draw_cards
```

Values can be explicit arrays or ranges:

```json
"effect.amount": {"min": 3, "max": 5, "step": 1}
```

Variant ids are stable and readable, for example:

```text
proto_arcano_lanca_eter__cost_1__effect_amount_4
```

## Scoring

Candidates receive interpretable sub-scores:

- `role_fit`
- `power_band`
- `curve_fit`
- `official_neighbor_fit`
- `entry_timing_fit`
- `reliability`
- `context_fit`
- `risk`
- `replacement_safety`
- `redundancy_safety`
- `role_ceiling_safety`
- `novelty`
- `complexity`

The official-neighbor index compares prototypes against existing cards by owner, class, role, cost and approximate power. This is what lets the lab flag:

- direct replacement risk
- redundant cards with no clear new purpose
- values above the role/profile ceiling
- values that pass a harness but are wrong for their intended entry timing

The final classification is one of:

```text
recommended
viable
risky
weak
broken
blocked
```

Design Lab separates "best playable number" from "strongest number". Gate success means each card idea has a recommended or viable candidate and no card idea is blocked by unsupported mechanics. Rejected variants are kept in the report because they explain the shape of the search space.

## Outputs

Each run writes:

```text
design_lab_results.json
design_lab_candidates.csv
design_lab_summary.md
design_lab_gate.md
promotion_manifest.json
```

Reports include:

- top 3 candidates by card
- official-neighbor comparison
- risk notes
- failed contexts
- manual review questions
- blocked mechanics
- promotion manifest summary

`promotion_manifest.json` is advisory only. It names selected candidates, suggested numeric diffs, official neighbors, risk notes, context failures, manual review questions and validations to run before manual promotion. It does not patch official content.

Promotion manifests are structurally validated by `tools/lab/design_lab_promotion_manifest_validator.gd` before outputs are accepted. The validator requires manual approval, promotable classifications (`recommended` or `viable`) and explicit follow-up validations for Design Lab, Card Impact, Run Lab and `validate.gd`.

The operational matrix for deciding which gates to run per change type lives in `docs/hardening-validation-matrix.md`.

## Acceptance Baseline

Current focused gate:

```text
run_design_lab --pack=design_lab_sample_v1 --mode=gate --max-variants=3 --out=user://design_lab/calibration_sample_smoke
```

Result:

- Gate PASS.
- 9 candidates.
- 3 recommended/viable selected candidates.
- 0 blocked mechanics.
- No official content files changed.

Calibration packs:

- `design_lab_calibration_player_v1`: PASS in explore, includes recommended, viable, risky and broken variants.
- `design_lab_calibration_enemy_v1`: PASS in explore, proves enemy causal signature plus AI choice contexts.
- `design_lab_calibration_mechanics_v1`: FAIL by design in explore because `steal_mana` is blocked until engine/lab support exists.

Pilot content pack:

- `design_lab_pilot_content_v1`: first mixed lab-only content pilot with Arcano, Invocador, Necromante, enemy cards and one intentionally blocked future mechanic.
- Full explore: FAIL by design with 93 candidates, 11 recommended/viable selected candidates, 1 blocked mechanic (`steal_mana`) and rejected risky/broken variants kept for diagnosis.
- Promotable subset gate: PASS with 104 candidates, 11 recommended/viable selected candidates and 0 blocked mechanics when excluding the blocked `pilot_arcano_sifao_mana` and the intentionally non-promotable `pilot_enemy_ar_falcao_rapido`.
- The pilot validated CSV multi-card `--card`/`--cards` subset gates and clarified gate reports by separating hard blockers from rejected variant counts.

Content Wave 01 packs:

- `arcano_cards_wave01`: 8 Arcano player-card ideas using implemented damage, control, economy, card-flow and summon mechanics.
- `invocador_cards_wave01`: 8 Invocador player-card ideas focused on summon lines, defenders, lane bodies and buffs.
- `necromante_cards_wave01`: 8 Necromante player-card ideas using summon, poison, economy and buff mechanics.
- `enemy_cards_wave01`: 12 enemy-card ideas across Terra, Gelo, Ar and Fogo. Explore intentionally keeps rejected enemy ideas in the report instead of hiding them.
- `mechanics_backlog_wave01`: 6 future ideas blocked honestly by missing engine/lab support (`steal_mana`, `copy_last_spell`, `lane_shift`, `summon_from_discard`, `life_payment`).

Content Wave 01 validation:

- Arcano full explore: PASS with 48 candidates, 8 selected recommendations, 1 rejected broken variant and 0 blocked mechanics.
- Arcano promotable subset gate: PASS with 83 candidates, 8 selected recommendations and 0 blocked mechanics.
- Invocador full explore: PASS with 48 candidates, 8 selected recommendations and 0 blocked mechanics.
- Invocador promotable subset gate: PASS with 96 candidates, 8 selected recommendations and 0 blocked mechanics.
- Necromante full explore: PASS with 48 candidates, 8 selected recommendations, 6 rejected broken variants and 0 blocked mechanics.
- Necromante promotable subset gate: PASS with 86 candidates, 8 selected recommendations and 0 blocked mechanics.
- Enemy full explore: FAIL by design with 72 candidates, 8 selected recommendations, 24 rejected risky/broken variants and 0 blocked mechanics. The rejected ideas are `enemy_w01_ar_faisca_viva`, `enemy_w01_ar_turbilhao_brutal`, `enemy_w01_fogo_brasa_raivosa` and `enemy_w01_fogo_colosso_carvao`.
- Enemy promotable subset gate: PASS with 78 candidates, 8 selected recommendations and 0 blocked mechanics after excluding the four risky/broken ideas.
- Mechanics backlog explore: FAIL by design with 6 blocked cards and 5 blocked mechanics. No numeric tuning was faked for unsupported mechanics.
- No official content file was changed; all cards remain lab-only proposal content.

## Roadmap

V1/V1.5 is the CLI foundation:

- proposal loader
- mechanic registry V2
- context templates
- official baseline index
- lab-only overlay catalog
- grid variant generation
- battle/enemy contexts
- scoring/reporting
- promotion manifest

V2 should deepen mechanics:

- timing signatures per mechanic
- mechanic-specific AI hooks
- mechanic-specific UI hooks
- richer blocked/support status
- context templates per mechanic family

V3 should deepen encounters:

- wave scripts
- boss phase declarations
- field-effect pressure
- exact entry timing for prototype cards
- expected lane pressure and AI behavior per context

V4 can generate suggested official catalog patches, still requiring manual approval.

V5 can add a local dashboard after report fields stabilize.

V6 can add replay/playtest capture for tuned candidates.
