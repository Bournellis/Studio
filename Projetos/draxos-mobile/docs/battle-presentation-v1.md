# DraxosMobile - Battle Presentation v1

- Status: `IMPLEMENTED_VALIDATED_UNPUBLISHED`
- Last updated: `2026-05-29`
- Scope: client-only presentation pass for `battle_running`, `battle_summary` and `battle_logs`.

## Purpose

Battle Presentation v1 makes the existing server-resolved battle easier to read during real playtest. The player should understand who is fighting, what just happened, who is in danger, what the result was and why returning to the Refugio matters.

This package does not change backend, schema, API, simulator, rewards, ranking, economy, weapons, spells or the `battle_log_v1` contract.
It has not been published to the Internal Alpha site/artifact channel yet.

## Player-Facing Rules

- Keep the running battle fullscreen, portrait-first and inside `BattleSafeFrame`.
- Keep the replay controls simple: `Pular batalha` only.
- Show a compact matchup/progress strip inside the battle layout instead of adding a separate timeline.
- Treat result, rewards and return to base as the important end-of-battle hierarchy.
- Keep logs read-only and scoped to the current battle.
- Avoid internal implementation terms in visible battle UI.

## Implementation Boundaries

- `battle_replay_presenter.gd` owns the fullscreen shell, matchup strip, summary and logs hierarchy.
- `battle_visual_mockup.gd`, `battle_stage_2d.gd` and `battle_log_presenter.gd` own event readability and procedural fallback feedback.
- Unknown or older battle events must not break replay.
- Procedural/fallback visuals remain mandatory; final battle art is out of scope.

## Acceptance

- Battle running, summary and logs fit Android portrait and desktop/web viewports covered by `tools/smoke_responsive_layout.gd`.
- Summary keeps `Voltar e verificar base` as the primary action and does not expose request/history actions.
- `consumable_use` and `heal` are readable in stage feedback and formatted logs.
- Tooltips and readouts use player-facing language and avoid technical leakage.
- Validation includes GUT/client coverage, `tools/smoke_mobile_presentation.gd`, `tools/smoke_responsive_layout.gd`, `tools/smoke_foundation_loop.gd`, `tools/validate.gd`, `validate_foundation.ps1 -Profile Client` and `git diff --check`.

## Validation

Latest local validation on `2026-05-29`:

- GUT `tests/client`: PASS (`119/119`, `1895` asserts).
- `tools/smoke_mobile_presentation.gd`: PASS.
- `tools/smoke_responsive_layout.gd`: PASS, including `battle_running`, `battle_summary` and `battle_logs` at `360x800`, `390x844`, `1280x720` and `1920x1080`.
- `tools/smoke_foundation_loop.gd`: PASS.
- `tools/validate.gd`: PASS (`119/119`, `1895` asserts).
- `validate_foundation.ps1 -Profile Client`: PASS.
- `validate_foundation.ps1 -Profile Quick`: PASS after documentation/status updates.
- `tools/check_agent_ops_foundation.ps1`: PASS after Kanban/status updates.
- `git diff --check`: PASS.

`tools/smoke_battle_replay.gd` remains available for a backend-enabled smoke, but was not required for this client-only merge.
