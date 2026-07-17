# FpsPlayground Implementation History

## Metadata

- status: `frozen`
- authority: `historical_record`
- last_verified: `2026-07-17`
- review_when: `a completed track, human decision or retained source needs historical correction`
- supersedes: `implementation/history.md before Documentation Lite v2`
- superseded_by: `none`

This record is the compact entry point for completed implementation lineage. The live baseline remains solely in `current-status.md`.

All 36 source records remain in `tracks/` during pre-cutover. The links below keep each result recoverable without placing those records in the normal documentation route.

## Interpretation Rules

- Records dated before the `2026-06-10` split may use `FpsShooter`, include football/TPS work or name `Duel Pit V1`. They are antecedents, not current FPS scope.
- Duplicate track numbers identify different historical slices. The source path, not the display number alone, identifies a record.
- Historical validation counts describe the point-in-time suite. The current acceptance baseline is the one in `current-status.md` and `../qa/QA_INDEX.md`.
- `APPROVED`, `APPROVED_BY_FABIO` and `HUMAN_APPROVED` are preserved only where the source records them. Technical completion never implies approval of another feel, tuning or publication gate.

## Human Decisions And Preserved Gates

- Fabio rejected the Track 08 movement experiment on `2026-06-19` and explicitly preferred the previous player feel. The experiment never entered `main`; the pre-Track-08 movement remains the chosen baseline.
- Rejection evidence: [global Done record](../../../08_Coordenacao_Agentes/Kanban/Done/2026-06-19_codex_fpsplayground_track08-movement-feel-discarded.md).
- Track 14I debugger cleanup was human-approved on `2026-06-25`. It changed tooling/addon integration only and did not approve a new gameplay baseline.
- Future movement feel, weapon feel, bot fairness, map quality and tuning decisions remain Fabio-owned. No such decision is pending in the current `../08_Coordenacao/TRIAGE.md`.
- Build, export, publication, remote services and physical-device authority were never granted by this lineage.

## Preserved Source Lineage

| Source record | Historical outcome | Result retained |
|---|---|---|
| [Track 00 Project Bootstrap](tracks/track-00-project-bootstrap/current-status.md) | `COMPLETE` | First editor-playable `FpsShooter` duel baseline; no export or platform expansion. |
| [Track 00 Project Split Foundation](tracks/track-00-project-split-foundation-v1/current-status.md) | `COMPLETE` | Created FPS-only `FpsPlayground`, removed football from the active surface; `14/14` tests. |
| [Track 01 Arena 1x1](tracks/track-01-arena-1x1-v1/current-status.md) | Historical `ACTIVE`, superseded | Parent slice assembled 01A-01D: feel, bot, map and knockback. |
| [Track 01A Feel/Feedback](tracks/track-01a-feel-feedback-v1/current-status.md) | `COMPLETE` | Direct movement and readable rifle/HUD/bot tell baseline; `10/10`, `94` asserts. |
| [Track 01B Bot Duelista](tracks/track-01b-bot-duelist-v1/current-status.md) | `COMPLETE` | Fair line-of-sight bot, deterministic misses and vertical awareness; `17/17`, `132` asserts. |
| [Track 01C Arena Layout](tracks/track-01c-arena-layout-v1/current-status.md) | `COMPLETE` | Delivered `Duel Pit V1`, protected spawns, cover and ramps; `19/19`, `186` asserts. |
| [Track 01D Knockback Movement Combat](tracks/track-01d-knockback-movement-combat-v1/current-status.md) | `COMPLETE` | Directional clamped knockback and feedback; `20/20`, `203` asserts. |
| [Track 01 Combat Readability](tracks/track-01-combat-readability-polish-v1/current-status.md) | `APPROVED` by Fabio | HUD combat messages, pickup beacons and jump-pad cues; `15/15`, `118` asserts. |
| [Track 02A Combat Loop Expansion](tracks/track-02a-combat-loop-expansion-v1/current-status.md) | `COMPLETE` | Plasma Bolt, health/overcharge pickups and bot item/dodge behavior; `30/30`, `253` asserts. |
| [Track 02A Bot Pressure/Jump Hotfix](tracks/track-02a-bot-pressure-jump-hotfix-v1/current-status.md) | `COMPLETE` | Ready-shot priority and simple bot jumping; `29/29`, `249` asserts. |
| [Track 02A Plasma Damage Hotfix](tracks/track-02a-plasma-damage-hotfix-v1/current-status.md) | `COMPLETE` | Crosshair-convergent Plasma path and radius-aware collision; `30/30`, `253` asserts. |
| [Track 02 Bot Tactical Movement](tracks/track-02-bot-tactical-movement-v1/current-status.md) | `APPROVED` by Fabio | Arena-agnostic tactical context and route scoring; `18/18`, `135` asserts. |
| [Track 03 Tactical Context Proof](tracks/track-03-arena-tactical-context-proof-v1/current-status.md) | `LOCALLY_VALIDATED` | Added `Relay Foundry V1` and multi-arena context; `20/20`, `175` asserts. Human feedback continued in Track 04. |
| [Track 03A Vertical Arena No Void](tracks/track-03a-vertical-arena-fall-pressure-v1/current-status.md) | `COMPLETE` | Delivered `Duel Pit V2`, high pickups and jump pads without void rules; `33/33`, `279` asserts. |
| [Track 03B Arena Flow/Route Tuning](tracks/track-03b-arena-flow-route-tuning-v1/current-status.md) | `COMPLETE` | Clarified vertical routes, item commitment and bot route debug; `36/36`, `297` asserts. |
| [Track 04 Movement/Bot](tracks/track-04-arena-movement-flow-bot-navigation-v1/current-status.md) | `APPROVED_BY_FABIO` | Rebuilt foundry flow and staged navigation; map approved, bot improved; `23/23`, `201` asserts. |
| [Track 04B Bot Pickup Commitment](tracks/track-04b-bot-pickup-commitment-v1/current-status.md) | `DELIVERED` | Nearby useful pickups can interrupt combat movement; `25/25`, `211` asserts. No standalone human approval recorded. |
| [Track 05 Foundation Hardening](tracks/track-05-foundation-hardening-refactor-v1/current-status.md) | `COMPLETE` | Pre-split docs/tooling/helper extraction, including historical football scope; `51/51`, `386` asserts. |
| [Track 05 Quake Duel Route Control](tracks/track-05-quake-duel-route-control-bot-v1/current-status.md) | `APPROVED_BY_FABIO` | Route-first movement, combat overlay, item priorities and jump-pad commitment; `28/28`, `229` asserts. |
| [Track 05B Long Jump Pad First Try](tracks/track-05b-long-jump-pad-first-try-v1/current-status.md) | `APPROVED` by Fabio | Route-distance launch and committed first-attempt foundry traversal; `30/30`, `238` asserts. |
| [Track 06 Arena Variety/Bot Generalization](tracks/track-06-arena-variety-bot-generalization-v1/current-status.md) | `APPROVED_BY_FABIO` | Added `Crossfire Crucible V1` without map-specific bot code; `32/32`, `289` asserts. |
| [Track 07 Match Flow/Duel UX](tracks/track-07-match-flow-duel-ux-v1/current-status.md) | `APPROVED_BASELINE` | First-to-3 rounds, score, reset and persistent HUD across three arenas; `34/34`, `340` asserts. |
| [Track 09 Combat Sandbox](tracks/track-09-combat-sandbox-expansion-v1/current-status.md) | `APPROVED_BASELINE` | Added Plasma world-impact blast after rejecting Track 08; movement stayed unchanged; `39/39`, `371` asserts. |
| [Track 10 Combat Balance/Weapon Roles](tracks/track-10-combat-balance-weapon-roles-v1/current-status.md) | `APPROVED_BASELINE` | Fixed rifle, direct Plasma, blast, overcharge and bot-pressure role contracts; `43/43`, `396` asserts. |
| [Track 11 Complete Telemetry](tracks/track-11-complete-telemetry-v1/current-status.md) | `HUMAN_SMOKE_APPROVED` | Local gameplay-neutral JSONL/summary telemetry; approved session had `1,344` aligned events; `49/49`, `464` asserts. |
| [Track 12 Telemetry Readout](tracks/track-12-telemetry-readout-balance-baseline-v1/current-status.md) | `APPROVED_BY_FABIO` | One session flagged rifle at `88.7%` as observation, not tuning truth; `53/53`, `496` asserts. |
| [Track 13 Documentation Rebaseline](tracks/track-13-documentation-rebaseline-future-roadmap-v1/current-status.md) | `COMPLETE` | Rebased docs and proposed evidence-first future order without gameplay changes; `53/53`, `496` asserts. |
| [Track 14A Refactor Safety Net](tracks/track-14a-refactor-safety-net-v1/current-status.md) | `LOCAL_VALIDATED` | Established regression guardrails and the surgical hardening sequence; `53/53`, `496` asserts. |
| [Track 14B Arena Root Boundary](tracks/track-14b-arena-root-boundary-v1/current-status.md) | `LOCAL_VALIDATED` | Extracted HUD snapshot/status construction; `54/54`, `505` asserts. |
| [Track 14C Combat Pipeline](tracks/track-14c-combat-pipeline-extraction-v1/current-status.md) | `LOCAL_VALIDATED` | Extracted combat telemetry payloads and pure Plasma blast math; `57/57`, `525` asserts. |
| [Track 14D Pickups/Jump Pads](tracks/track-14d-pickups-jump-pads-extraction-v1/current-status.md) | `MERGED_LOCAL` | Extracted pickup state, respawn and jump-pad contracts; `59/59`, `552` asserts. |
| [Track 14E Bot Decision Boundary](tracks/track-14e-bot-decision-boundary-v1/current-status.md) | `APPROVED` by Fabio/tester | Extracted item/route scoring while preserving route-first behavior; `62/62`, `564` asserts. |
| [Track 14F Cleanup/Documentation](tracks/track-14f-cleanup-documentation-v1/current-status.md) | `MERGED_LOCAL` | Removed transitional wrappers and recorded hotspot sizes; `62/62`, `564` asserts. |
| [Track 14G Surgical Expansion Hardening](tracks/track-14g-surgical-expansion-hardening-v1/current-status.md) | `MERGED_LOCAL` | Extracted movement, projectile, HUD feedback and telemetry helpers; `66/66`, `593` asserts. |
| [Track 14H Long Pad Hotfix](tracks/track-14h-bot-long-jump-pad-hotfix-v1/current-status.md) | `MERGED_LOCAL` | Restored bot-only foundry launch; player force preserved; `67/67`, `599` asserts. No current gate is open. |
| [Track 14I Godot Debugger Cleanup](tracks/track-14i-godot-debugger-cleanup-v1/current-status.md) | `HUMAN_APPROVED` | Corrected GUT UID paths and headless startup/shutdown noise; runtime behavior unchanged; `67/67`, `599` asserts. |

## Superseded Document Lineage

- `../docs/arena-shooter-future-roadmap.md` is the preserved Track 13 roadmap.
  Its valid sequence and guardrails now live in `../docs/work-plan.md`, `../docs/arena-tactical-layouts.md`, `../docs/tuning-guide.md`, `../docs/bot-contract.md` and `../docs/telemetry.md`.
- `../docs/codebase-audit-track05.md` is a frozen pre-split audit. Current ownership/risk belongs to `../docs/architecture-overview.md` and `technical-debt-baseline.md`.
- `../docs/refactor-hardening-roadmap.md` is a frozen Track 14 completion summary. Delivered boundaries are mapped above; prospective controls belong to `technical-debt-baseline.md`.
- `../docs/reuse-map.md` remains a frozen boundary note. Current cross-project rules live in `../AGENTS.md` and the workspace governance contract.

Git history remains the final recovery layer. No track, audit, summary or roadmap source was deleted in this pre-cutover curation.
