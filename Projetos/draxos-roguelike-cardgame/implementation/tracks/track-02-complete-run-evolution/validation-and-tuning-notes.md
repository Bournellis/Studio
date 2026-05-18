# Track 02 Validation And Tuning Notes

- Last Updated: `2026-05-18`
- Prompt: `T02-P09`
- Status: `READY_FOR_USER_PLAYTEST`

## Validation Summary

- Godot validation command: green.
- GUT: `93/93` tests passing, `1119` asserts.
- Full-route pacing smoke: `29/29` maps completed.
- Estimated route turns: `217`.
- Estimated HP loss across route: `116`.
- Deaths in deterministic smoke: `0`.
- Souls earned/spent/left: `362 / 291 / 71`.
- Final deck size: `38`.
- Relic count: `6`.
- Shop usage count: `21`.

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
