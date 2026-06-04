# Foundation Closeout

- Last Updated: `2026-06-04`
- Status: `FOUNDATION_REVIEW_CLOSED_FOR_PLAYTEST`
- Baseline: `Track 02 complete-run build`

## Purpose

This document closes the foundation-hardening sequence for the Draxos Roguelike Cardgame. It records the live ownership map after the hardening passes and separates technical foundation debt from product/playtest follow-up.

The foundation is considered ready for human Track 02 playtest. Automated validation and Run Lab golden metrics protect regressions, but they do not replace a manual run.

## Live Baseline

- Fixed linear 29-map route.
- Save and RunSession snapshot version `5`.
- Three classes: Arcano, Invocador, Necromante.
- Production reward schedule, universal relics, expanded Souls shop and reward category state.
- Full Track 02 keyword/status vocabulary and implemented keyword engine.
- Deterministic hybrid enemy AI, visible enemy intent, encounter modes, board formats, field effects and boss hooks.
- Modular GUT suites, shared route pacing simulator, Run Lab JSON/CSV output and golden comparison.
- Idempotent generated catalog hash and catalog source loader seam for future domain splits.
- Internal directors/services for enemy AI/intent, combat/damage, rewards, Souls shop and BattleRoot presenters.

## Ownership Map

| Area | Owner | Supporting Files | Contract |
|---|---|---|---|
| Portfolio/status | Studio coordination docs | `../../../08_Coordenacao_Agentes/Estado_Atual.md`, `../../README.md`, local `implementation/current-status.md` | Keep snapshots compact and decision-oriented. |
| Product direction | Local docs | `docs/product-brief.md`, `docs/game-design-document.md`, `docs/production-status.md` | Track 02 is the live product baseline; Track 01 material is historical. |
| Run state | `core/run_session.gd` | `core/run_reward_service.gd`, `core/run_shop_service.gd` | `RunSession` owns state and public wrappers; services mutate through compatible delegation. |
| Save/load | `core/save_manager.gd` | `RunSession` snapshot payloads | Save/snapshot v5 is the live format; older saves are stale but deletable/overwritable. |
| Catalog | `data/definitions/slice_catalog.json` | `tools/catalog_source_loader.gd`, `tools/content_generator.gd`, `data/generated/slice_catalog.tres` | JSON remains source of truth; generated `.tres` writes only when semantic hash changes. |
| Battle rules | `battle/battle_engine.gd` | `enemy_turn_director.gd`, `enemy_intent_director.gd`, `combat_resolution_director.gd`, `field_effect_director.gd`, `boss_director.gd`, `keyword_status_hooks.gd` | `BattleEngine` stays the compatibility facade; directors own extracted internal slices. |
| Battle UI | `modes/battle/battle_root.gd` | `battle_preview_presenter.gd`, `battle_hud_presenter.gd`, `battle_combat_fx_presenter.gd`, `enemy_intent_panel_presenter.gd` | `BattleRoot` still owns scene composition; presenters own pure readout/projection data. |
| Validation | `tools/validate.gd` | modular `tests/unit/*.gd` | Validation generates data/scenes, checks contracts, runs shared route smoke and GUT. |
| Telemetry | `tools/route_pacing_simulator.gd` | `tools/run_lab.gd`, `tools/run_lab_golden_metrics.gd` | Run Lab is for regression/tuning comparison, not human playtest replacement. |
| Playtest | Human checklist | `docs/playtest-track-02.md`, `implementation/tracks/track-02-complete-run-evolution/validation-and-tuning-notes.md` | Human feedback decides balance, clarity and fun. |

## Technical Foundation Debt

- Optional final card/enemy PNG art is still placeholder-driven where assets are absent.
- Four ship overlay alpha warnings remain non-fatal visual asset debt.
- `BattleRoot` can still be reduced in future small passes by extracting board/hand rebuilders and modal builders, but current layout is covered and stable.
- Field effects and boss phase hooks can be extracted further only if future work needs it; do not split them just for file-size aesthetics.
- The catalog source loader is ready for domain splits, but `slice_catalog.json` should remain single-source until content iteration needs smaller authored files.

## Product And Playtest Backlog

- Run at least one manual Track 02 attempt per class.
- Collect bugs, balance notes and UI confusion using `docs/playtest-track-02.md`.
- Sort findings into blocking bugs, tuning, UX clarity and content/art debt before opening the next implementation branch.
- Do not rebalance shop costs, rewards, enemies or route pacing from Run Lab alone.

## Non-Goals After Closeout

- No new Track 02 content is implied by this closeout.
- No catalog split is required before playtest.
- No additional BattleEngine extraction is required before playtest.
- No DraxosMobile, RPG Turnos or RPG Isometrico mechanic should be imported into this project without an explicit local adoption document.
