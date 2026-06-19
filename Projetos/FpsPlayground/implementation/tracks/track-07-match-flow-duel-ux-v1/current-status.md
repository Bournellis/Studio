# Track 07 - Match Flow And Duel UX V1

- Status: `PLANNED_READY_FOR_EXECUTION`
- Planned: `2026-06-19`
- Owner: Codex
- Recommended execution branch: `codex/fpsplayground/track07-match-flow-duel-ux-v1`
- Recommended worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track07-match-flow-duel-ux-v1`
- Base: Track 06 approved by Fabio on 2026-06-19.

## Why This Track Comes Next

Track 06 proved that the current arena/bot foundation works across three layouts. The next risk is not combat depth yet; it is repeatability.

Right now the Arena Shooter is still closer to a lab round: someone dies, the HUD says who won, and `R` restarts. That is useful for testing, but it is not enough for repeated duel feedback. Track 07 should make the loop feel like a deliberate 1x1 duel without changing weapons, damage, bot aim or movement balance.

## Product Goal

Turn Arena Shooter into a clean repeatable duel session:

- the player understands the current arena, round state, score and result;
- round endings are readable and not just transient event text;
- `R` remains the fast replay input;
- pause/menu flow remains reliable;
- arena reselection remains simple;
- all three approved arenas keep their current movement and bot behavior.

## Required Pre-Step Documentation

Before implementation, read and keep open:

1. `Projetos/FpsPlayground/AGENTS.md`
2. `Projetos/FpsPlayground/implementation/current-status.md`
3. `Projetos/FpsPlayground/docs/work-plan.md`
4. `Projetos/FpsPlayground/docs/mode-contract.md`
5. `Projetos/FpsPlayground/docs/architecture-overview.md`
6. `Projetos/FpsPlayground/docs/validation.md`
7. `Projetos/FpsPlayground/docs/bot-route-control.md`
8. `Projetos/FpsPlayground/docs/arena-tactical-layouts.md`
9. `Projetos/FpsPlayground/modes/arena/arena_root.gd`
10. `Projetos/FpsPlayground/presentation/hud/arena_hud.gd`
11. `Projetos/FpsPlayground/tests/unit/test_bootstrap.gd`

## Current Baseline

Current runtime already has:

- `round_ended` and `round_status` in `arena_root.gd`;
- death handlers for player and bot;
- `R` bound to `restart_round`;
- pause menu with resume, sensitivity and main menu;
- HUD snapshot with health, pickups, bot state, route and hint;
- transient `show_round_end(player_won)` event feedback.

Track 07 should build on these pieces instead of replacing the arena root wholesale.

## Implementation Plan

### Step 1 - Define Duel State Contract

Create a small explicit duel/match contract around the existing round state.

Recommended model:

- `round_state`: playing, player_round_win, bot_round_win, match_over.
- `player_score` and `bot_score`.
- `round_index`, starting at 1.
- `score_to_win`, as a local constant, recommended `3`.
- `last_round_winner`, stored as `player`, `bot` or empty.

Keep this state in `arena_root.gd` first unless implementation pressure proves it deserves a small helper under `gameplay/arena/`.

Acceptance:

- score starts at `0 - 0`;
- first death increments only the winner score once;
- repeated death signals after round end cannot double-score;
- `restart_round()` starts the next round without losing the current match score;
- a dedicated new-match/reset path clears score and round index.

### Step 2 - Clarify Restart/New Match Behavior

Preserve the current fast `R` behavior, but make it intentional.

Recommended behavior:

- During active play: `R` restarts the current duel session as a new match only if explicitly implemented and documented; otherwise keep it as next-round reset after result. Choose one behavior and test it.
- After a round result and before match over: `R` starts the next round, score preserved.
- After match over: `R` starts a fresh match, score reset.
- Pause menu should add a clear `Reiniciar duelo` or `Novo duelo` action if the HUD needs more than the current resume/menu buttons.

Preferred Track 07 choice:

- `R` means "continue the duel flow": next round after a round result, new match after match over.
- A pause-menu `Novo duelo` button resets score at any time.

Acceptance:

- player never needs to return to the main menu to play another round;
- new match reset is available and clear;
- returning to menu still unpauses the tree and releases mouse capture;
- arena selection from the main menu still starts clean state.

### Step 3 - HUD Score And Result UX

Update `ArenaHud` so duel state is persistent and scannable, not only transient event text.

Recommended additions:

- score line: `Player 1  x  0 Bot` or equivalent compact label;
- round line: `Round 2 / First to 3`;
- result line/panel state for round win, round loss, match win and match loss;
- hint text that changes by state:
  - playing: combat controls;
  - round ended: `R next round | Esc menu`;
  - match over: `R new match | Esc menu`.

Keep the HUD utilitarian. Do not turn this into a full menu redesign.

Acceptance:

- score/result information survives longer than the transient event label;
- result state is visible without reading debug bot flow text;
- health/combat/pickup readability from previous tracks remains visible;
- no text overlap in the existing status panel.

### Step 4 - Round Transition Safety

Make round transitions robust for all three arena layouts.

Implementation notes:

- clear active projectiles on each round start;
- reset pickups and vertical hazards exactly as today;
- reset player/bot health, overcharge and positions;
- reset bot target/context without losing active layout;
- keep `last_jump_pad_id` and HUD transient feedback clean after reset;
- decide whether player/bot score persists across pause menu and next round.

Acceptance:

- no projectile or pickup state leaks between rounds;
- bot starts each round in a valid tactical state;
- player camera/mouse capture returns correctly after next round;
- active arena id does not reset accidentally to default layout.

### Step 5 - Match Completion

Add match-over logic once either score reaches `score_to_win`.

Recommended behavior:

- round win increments score;
- if score reaches target, set match over;
- disable combat/projectile/pickup processing while match over, same as current round end;
- HUD shows final winner and new-match instruction;
- `R` starts fresh match.

Acceptance:

- match winner is deterministic;
- score cannot exceed target through duplicate death events;
- result feedback differentiates round result from match result enough for smoke testing;
- no new combat tuning is introduced.

### Step 6 - Menu And Arena Selection Polish

Keep scope tight but reduce friction around repeated tests.

Recommended scope:

- ensure all three arena buttons launch clean score `0 - 0`;
- consider adding current arena name to HUD score/result area;
- preserve pause menu return to main menu;
- avoid adding a map voting flow or complex settings screen in this track.

Acceptance:

- `Duel Pit V2`, `Relay Foundry V1` and `Crossfire Crucible V1` all start with clean match state;
- returning to menu and selecting another arena does not preserve old score;
- existing menu tests remain stable.

### Step 7 - Automated Validation

Add focused tests around state, not broad visual polish.

Expected tests:

- arena boots with score labels/result nodes available;
- bot death increments player score once;
- player death increments bot score once;
- duplicate death after `round_ended` does not double-score;
- next round preserves score and increments round index;
- match over triggers when score reaches target;
- new match reset clears score and round index;
- all three layouts can start with clean duel state.

Prefer testing through public/debug helpers on `arena_root.gd` instead of simulating full player combat when a direct helper is clearer.

### Step 8 - Documentation And Handoff

Update:

- `docs/mode-contract.md` with the duel flow contract;
- `docs/validation.md` with Track 07 manual smoke;
- `docs/work-plan.md` and `implementation/current-status.md`;
- Track 07 current-status with delivered notes when implemented.

Acceptance:

- docs identify the new score/restart contract;
- validation command passes;
- smoke checklist is clear enough for Fabio/tester.

## Automated Validation Targets

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
git diff --check
powershell -ExecutionPolicy Bypass -File D:\Estudio\tools\check_doc_drift.ps1
git status --short
```

## Manual Smoke Targets

- Launch each arena from the menu and confirm score starts `0 - 0`.
- Win one round and confirm player score increments once.
- Lose one round and confirm bot score increments once.
- Press `R` after a round result and confirm next round starts clean with score preserved.
- Reach match win/loss target and confirm final result is readable.
- Press `R` after match over and confirm a fresh match starts with score reset.
- Pause during active play, resume, then return to menu.
- Return to menu after a match and select a different arena; confirm score does not leak.
- Confirm bot movement/combat still feels like Track 06: route-first, item-aware and able to shoot as overlay.

## Non-Goals

- No new weapons, projectiles, pickups or combat balance tuning.
- No bot difficulty spike.
- No arena geometry changes unless a Track 07 UI issue exposes an obvious blocker.
- No export/Web/mobile/multiplayer/backend.
- No full settings menu.
- No progression, economy, unlocks or profile persistence.
- No final art pass.

## Risks And Guardrails

- Risk: score logic can accidentally double-count deaths. Guardrail: idempotent round-end tests.
- Risk: `R` semantics can become confusing. Guardrail: one documented behavior, HUD hint and tests.
- Risk: HUD can become crowded. Guardrail: compact labels and no new large panels unless result state needs it.
- Risk: match UX can hide movement/bot regressions. Guardrail: smoke all three arenas after implementation.
- Risk: implementation can become a state-machine rewrite. Guardrail: build around current `round_ended`, `round_status`, HUD snapshot and restart flow.

## Handoff Criteria

Track 07 can move to Review when:

- score/round/match state is implemented and tested;
- HUD shows score, round and result clearly;
- `R`/pause/menu behavior is documented and validated;
- all three arenas start and reset cleanly;
- full validation passes;
- docs and smoke checklist are updated.
