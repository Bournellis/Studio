# Track 02 Validation And Tuning Notes

- Last Updated: `2026-06-05`
- Prompt: `AUTORUN-LAB-V1`
- Status: `READY_FOR_USER_PLAYTEST`

## Validation Summary

- Godot validation command: green.
- GUT: `108/108` tests passing, `1304` asserts.
- Full-route pacing smoke: `29/29` maps completed.
- Estimated route turns: `217`.
- Estimated HP loss across route: `116`.
- Deaths in deterministic smoke: `0`.
- Souls earned/spent/left: `362 / 291 / 71`.
- Final deck size: `38`.
- Relic count: `6`.
- Shop usage count: `21`.
- Shared simulator: `tools/route_pacing_simulator.gd`.
- AutoRun Lab: `tools/run_lab.gd` now supports presets, case matrices, macro policies, detailed JSON, compatibility CSV/JSON, aggregate JSON/CSV/Markdown reports, timeline records and statistical baseline comparison through `tools/lab/`.
- Golden metrics: `tools/run_lab_golden_metrics.gd` protects Arcano seed `20260518` exact metrics and checks Invocador/Necromante completion/no-death contracts.
- Run Lab parity: `--compare-golden --require-golden` passes for Arcano, Invocador, and Necromante with seed `20260518`.
- AutoRun quick matrix: `--preset=quick --seed-start=20260518 --seed-count=10 --compare-baseline` passes 30 macro-route cases and writes reports under `user://run_lab/autorun_lab_quick`.
- Foundation Pass 4 added the golden comparison harness without changing route metrics or gameplay behavior.
- Foundation Pass 5 moved Souls shop offers/mutations/sync into `core/run_shop_service.gd` behind `RunSession` wrappers without changing route metrics, shop economy, or gameplay behavior.
- Foundation Pass 6 moved BattleRoot HUD/objective readouts and combat FX filtering/text/state projection into pure presenters without changing route metrics, UI layout, drag/drop, or gameplay behavior.
- Foundation Pass 7 added `tools/catalog_source_loader.gd` and GUT coverage for single-JSON semantic equivalence plus future catalog domains without changing route metrics, generated resource semantics, or gameplay behavior.
- Foundation Pass 8 moved staged combat, manual attack, slot damage, hero damage, and destruction queue handling into `battle/combat_resolution_director.gd` with wrapper/director parity coverage and without changing route metrics or gameplay behavior.
- Foundation Pass 9 closed the foundation review in docs only, added `docs/foundation-closeout.md`, refreshed the architecture ownership map, and separated product/playtest follow-up from optional technical extraction debt.

## First Tuning Pass

- Reward schedule remains unchanged.
- Shop prices remain at the approved Track 02 defaults.
- Enemy global stats were not inflated; difficulty remains driven by element identity, AI, modes, field effects, and boss hooks.
- Upgrade rewards no longer add extra deck copies by rarity in Track 02. This keeps upgrade rewards as level improvements and moved the deterministic full-route smoke from `43` final cards to `38`, matching the first-test deck-size target.
- Current full-route smoke leans recovery-heavy, with repeated healing purchases and two max HP purchases. That is acceptable for user playtest because there is no permanent account progression yet.

## Screenshots

Captured at `1280x720` and `960x540` in:

- `D:\Estudio\builds\draxos-roguelike-cardgame\visual-screenshots\run_map_*.png`
- `D:\Estudio\builds\draxos-roguelike-cardgame\visual-screenshots\reward_screen_*.png`
- `D:\Estudio\builds\draxos-roguelike-cardgame\visual-screenshots\shop_relic_*.png`
- `D:\Estudio\builds\draxos-roguelike-cardgame\visual-screenshots\keyword_tooltip_*.png`
- `D:\Estudio\builds\draxos-roguelike-cardgame\visual-screenshots\enemy_intent_*.png`
- `D:\Estudio\builds\draxos-roguelike-cardgame\visual-screenshots\late_board_battle_*.png`

## Product And Playtest Follow-Up

- Manual playtest remains the next production step and should use `docs/playtest-track-02.md`.
- Balance changes should come from observed human runs, with AutoRun Lab used for regression, distribution checks and tuning comparison rather than as the final verdict.
- Sort playtest results into blocking bugs, tuning, UX clarity, and content/art debt before implementation.

## Remaining Technical Debt

- Final card/enemy art is still placeholder-driven where PNGs are absent.
- Four ship overlay alpha warnings remain non-fatal asset debt.
- The full-route smoke is deterministic validation telemetry, not a human balance verdict.
- Further BattleRoot, field-effect, boss-hook, or catalog-source splitting is optional future foundation work and is not required before Track 02 playtest.
