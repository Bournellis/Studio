# DraxosMobile - Implementation History

## Metadata

- status: `historical`
- authority: `historical_record`
- last_verified: `2026-07-17`
- review_when: `a historical result is corrected or a new delivery track closes`
- supersedes: `direct routing from living docs into individual track status files`
- superseded_by: `none`

This is the compact route into implementation history. It does not define current state, priority, product approval or the next step. The living technical snapshot remains `current-status.md`; package lineage remains `../docs/release-history.md`.

## Track Index

| Track | Preserved result | Historical source |
|---|---|---|
| 00 | First-slice foundation complete | `tracks/track-00-first-slice-foundation/current-status.md` |
| 01 | PC local alpha playtest baseline complete | `tracks/track-01-alpha-playtest-hardening/current-status.md` |
| 02 | Progression/Battle Lab calibration history; never a current tuning approval | `tracks/track-02-progression-lab/current-status.md` |
| 03 | Internal Alpha v0 handoff complete through T03-P18 | `tracks/track-03-internal-alpha-v0/current-status.md` |
| 04 | Post-handoff hardening integrated into Track 05 | `tracks/track-04-post-handoff-hardening-and-hub-modularization/current-status.md` |
| 05 | Foundation stabilization and asset/service readiness integrated | `tracks/track-05-foundation-stabilization-and-asset-service-readiness/current-status.md` |
| 06 | Feature installation rails and first slices integrated | `tracks/track-06-feature-installation-rails-and-first-slices/current-status.md` |
| 07 | Mobile presentation loop and layout rework integrated | `tracks/track-07-mobile-presentation-loop-and-layout-rework/current-status.md` |
| 08 | Foundation review and hardening integrated | `tracks/track-08-foundation-review-and-hardening/current-status.md` |
| 09 | Portrait, entry and Refugio scene/visual loop integrated | `tracks/track-09-portrait-entry-refuge-scene-and-visual-loop-rework/current-status.md` |
| 10 | Battle presentation rework integrated | `tracks/track-10-battle-presentation-rework/current-status.md` |
| 11 | Product foundation consolidation integrated | `tracks/track-11-product-foundation-consolidation/current-status.md` |
| 12 | Boot decomposition delivered | `tracks/track-12-boot-decomposition/current-status.md` |
| 13 | Validation and release safety delivered | `tracks/track-13-validation-release-safety/current-status.md` |
| 14 | Agent operations foundation marker preserved | `tracks/track-14-agent-ops-foundation/current-status.md` |
| 15 | Mobile UX overhaul activity marker preserved as history | `tracks/track-15-mobile-ux-overhaul/current-status.md` |
| 16 | Behavior and potion crafting preserved as an implemented technical base | `tracks/track-16-behavior-crafting/current-status.md` |
| 17 | Foundation final polish delivered | `tracks/track-17-foundation-expansion-readiness/README.md` |
| 18 | Initial PVE Arena delivery history | `tracks/track-18-pve-arena-initial/README.md` |
| 20 | Season 1 Arena calibration package published; values remain subject to gates | `tracks/track-20-season-1-arena-calibration/README.md` |
| 21 | Arena loop unlock/friction package published | `tracks/track-21-arena-loop-unlock-friction/README.md` |
| 22 | Technical hardening package published | `tracks/track-22-technical-hardening/README.md` |
| 23 | First-real-run Arena package published | `tracks/track-23-arena-pve-first-real-run/README.md` |

Track 19 has no retained directory. Its package facts are preserved in `../docs/release-history.md` and Git history; this router does not invent a replacement track.

## Decision And Contract Lineage

- Open/calibratable/deferred product decisions: `../docs/design-pending.md`.
- Resolved product decisions and prior rationale: `../docs/design-resolved-archive.md`.
- Current Arena proof: `DMOB-D082` remains open with `ARENA_CORE_NEEDS_UX_FIX` plus `ARENA_CORE_NOT_PROVEN`.
- Feature installation authority: `../docs/contracts/feature-registry.md`; Track 06 is retained as delivery evidence.
- Release safety authority: `../docs/contracts/release-safety.md`; Track 13 is retained as delivery evidence.
- QA profile authority: `../qa/validation-matrix.md` and `../qa/qa_manifest.json`.
- Packages, previews, partial publication outcomes and immutable roots: `../docs/release-history.md`.

## Reading Rule

Use track files only to answer historical questions. Do not restore their old status, next-step text, package pointers or approvals into living routers. Git is the recovery layer for detail removed by documented curation.
