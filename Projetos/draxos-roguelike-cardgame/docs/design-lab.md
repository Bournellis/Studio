# Design Lab

- Last Updated: `2026-06-06`
- Status: `DESIGN_LAB_V1_FOUNDATION_COMPLETE`
- Scope: proposal packs, lab-only prototype cards, deterministic numeric variants, battle/enemy contexts, interpretable scoring, reports and promotion manifest.

## Purpose

Design Lab is the creation-side lab for the Draxos roguelike cardgame. Its job is to turn an idea for a card, enemy card, mechanic or encounter into playable numeric candidates before that content touches the official catalog.

It is intentionally separate from Regression Lab/Card Impact. Regression tooling protects accepted Track 02 content. Design Lab explores prototype content and writes only reports plus a promotion manifest.

The first contract is CLI/report-first. Dashboard, replay and automatic patches stay out of V1.

## Entry Point

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_design_lab.gd -- --pack=design_lab_sample_v1 --mode=gate
```

Useful options:

```text
--pack=<id|path>
--card=<id|all>
--cards=<id,id>
--mode=explore|gate
--components=battle,encounter,macro
--profile=<profile_id>
--max-variants=<n>
--out=user://design_lab/<pack_id>
--gate
```

`--max-variants` is a per-card cap. Use a low number while drafting a large pack, then raise it when the ranges look sane.

## Data

Proposal packs live in:

```text
data/lab/design/proposals/
```

Shared lab contracts live in:

```text
data/lab/design/mechanic_registry.json
data/lab/design/scoring_profiles.json
```

The sample pack is:

```text
data/lab/design/proposals/design_lab_sample_v1.json
```

Each proposal card must define:

- `owner`
- `role`
- `design_intent`
- `timing`
- `valid_targets`
- `mechanics`
- `variant_space`
- at least one context through `context_ids` or pack-level `encounter_contexts`

New mechanics can be described before they exist, but they must appear in `mechanic_registry.json`. If their status is `blocked_missing_engine_support`, Design Lab reports the card as `blocked` and does not fake numeric tuning.

## Prototype Overlay

Design Lab starts from the generated official catalog, duplicates it in memory, appends prototype variant cards and optional lab encounters, then discards the overlay after the run.

It never writes:

```text
data/definitions/slice_catalog.json
```

V1 supports:

- `new_card_id` for brand-new lab-only cards.
- `extends_card_id` for variants based on an official card.
- Player cards and enemy cards in the same pack.
- Encounter contexts declared by design intent.

## Variant Generation

`variant_space` expands deterministic numeric grids. Supported V1 field paths include:

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

## Contexts

V1 builds real `BattleEngine` cases through the existing Battle Lab runner.

Player cards use focused target capture and can be tested against contexts like:

- isolated play
- large target
- lane pressure
- low player health
- combo setup when declared later in the pack

Enemy cards use the V5 enemy causal-signature harness:

- enemy commander enabled
- prototype card forced into enemy hand/deck
- one-turn play plus first combat capture
- AI target/slot scoring still goes through `EnemyTurnDirector`

Encounter contexts are data-first so V3 can grow into wave scripts, boss phases, field effects and exact card-entry timings.

## Scoring

Candidates receive:

- `role_fit`
- `power_band`
- `reliability`
- `context_fit`
- `risk`
- `novelty`
- `complexity`

The final classification is one of:

```text
recommended
viable
risky
weak
broken
blocked
```

Design Lab separates "best playable number" from "strongest number". A high value outside the role/profile band increases risk and can lose ranking even if it wins the battle harder.

## Outputs

Each run writes:

```text
design_lab_results.json
design_lab_candidates.csv
design_lab_summary.md
design_lab_gate.md
promotion_manifest.json
```

`promotion_manifest.json` is advisory only. It names selected candidates, suggested numeric diffs and validations to run before manual promotion. It does not patch official content.

## Acceptance Baseline

Current sample gate:

```text
run_design_lab --pack=design_lab_sample_v1 --mode=gate --out=user://design_lab/design_lab_sample_v1_gate
```

Result:

- Gate PASS.
- 36 candidates.
- 3 recommended/viable selected candidates.
- 0 blocked mechanics.
- No official content files changed.

Regression checks after V1:

- `validate.gd`: PASS, 220/220 tests, 1947 asserts.
- `run_card_impact.gd --phase=before --mode=gate --pack=track02_card_impact_v5`: PASS.
- `run_lab.gd --mode=gate --preset=smoke --baseline=track02_smoke_v1`: PASS.
- `run_lab.gd --mode=gate --preset=quick --baseline=track02_quick_v1`: PASS.

Known non-fatal warnings remain the same optional visual/GUT resource warnings already present in the project.

## Roadmap

V1 is the CLI foundation:

- proposal loader
- mechanic registry
- lab-only overlay catalog
- grid variant generation
- battle/enemy contexts
- scoring/reporting
- promotion manifest

V2 should deepen mechanics:

- timing signatures per mechanic
- explicit AI hook declarations
- richer blocked/support status
- mechanic-specific context templates

V3 should deepen encounters:

- wave scripts
- boss phase declarations
- field-effect pressure
- exact entry timing for prototype cards
- expected lane pressure and AI behavior per context

V4 can generate suggested official catalog patches, still requiring manual approval.

V5 can add a local dashboard after report fields stabilize.

V6 can add replay/playtest capture for tuned candidates.
