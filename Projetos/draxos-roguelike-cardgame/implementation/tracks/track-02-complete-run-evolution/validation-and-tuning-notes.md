# Track 02 Validation And Tuning Notes

- Last Updated: `2026-06-03`
- Prompt: `FOUNDATION-HARDENING-7`
- Status: `READY_FOR_USER_PLAYTEST`

## Validation Summary

- Godot validation command: green.
- GUT: `103/103` tests passing, `1271` asserts.
- Full-route pacing smoke: `29/29` maps completed.
- Estimated route turns: `217`.
- Estimated HP loss across route: `116`.
- Deaths in deterministic smoke: `0`.
- Souls earned/spent/left: `362 / 291 / 71`.
- Final deck size: `38`.
- Relic count: `6`.
- Shop usage count: `21`.
- Shared simulator: `tools/route_pacing_simulator.gd`.
- Golden metrics: `tools/run_lab_golden_metrics.gd` protects Arcano seed `20260518` exact metrics and checks Invocador/Necromante completion/no-death contracts.
- Run Lab parity: `--compare-golden --require-golden` passes for Arcano, Invocador, and Necromante with seed `20260518`.
- Foundation Pass 4 added the golden comparison harness without changing route metrics or gameplay behavior.
- Foundation Pass 5 moved Souls shop offers/mutations/sync into `core/run_shop_service.gd` behind `RunSession` wrappers without changing route metrics, shop economy, or gameplay behavior.
- Foundation Pass 6 moved BattleRoot HUD/objective readouts and combat FX filtering/text/state projection into pure presenters without changing route metrics, UI layout, drag/drop, or gameplay behavior.
- Foundation Pass 7 added `tools/catalog_source_loader.gd` and GUT coverage for single-JSON semantic equivalence plus future catalog domains without changing route metrics, generated resource semantics, or gameplay behavior.

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

## Remaining Known Debt

- Final card/enemy art is still placeholder-driven where PNGs are absent.
- Four ship overlay alpha warnings remain non-fatal asset debt.
- The full-route smoke is deterministic validation telemetry, not a human balance verdict.
- Human checklist lives at `docs/playtest-track-02.md`.
