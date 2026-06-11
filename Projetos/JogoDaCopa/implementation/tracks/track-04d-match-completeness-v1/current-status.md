# Track 04D - Match Completeness V1

- Date: `2026-06-11`
- Branch: `codex/jogodacopa/track04d-match-completeness-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04d-match-completeness-v1`
- Status: `COMPLETE - approved by review and merged to main`
- Source: Fabio direct task from `docs/release-plan.md` final pre-release route
- Review: `docs/code-review-track04c-04d-v1.md`

## Objective

Complete the current `Copa Arena Futebol` mode before web publish with product-level match flow details: real pause menu, rich result screen, short fades, a clearer hero menu shot, consistent ESC behavior and clean restart paths.

## Implementation

- Added a real pause panel on ESC during match play with `Continuar`, `Reiniciar partida`, four audio bus sliders and `Sair ao menu`.
- Added rich result UI with final score, kit swatches/codes, match stat text and `Rematch` / `Sair ao menu` actions.
- Added pure match stat helpers in `football_match_rules.gd` for goals by period, shots, possession by touch counts, supers and longest touch streak.
- Wired `football_root.gd` to collect stats from goals, player/bot shots, touches and result snapshots without changing tap/RMB/rule contracts.
- Added short black fade support for menu load, match start pulse, result flow and return-to-menu transitions.
- Moved the main menu panel to the right on wide screens so the uniformed player preview reads as a visible hero shot with dedicated light and low camera.
- Normalized ESC targets: intro returns to menu, match toggles pause, result returns to menu.
- Kept restart clean across countdown, golden goal, slow-mo and pause/result states.

## Tests

Added/updated coverage in `tests/unit/test_bootstrap.gd` and `tests/unit/test_rule_helpers.gd`:

- Real mouse clicks for pause and result buttons across `1920x1080`, `1366x768` and `1280x720`.
- Pause asserts game tree is actually paused and focus starts on `Continuar`.
- Result asserts rich stat text and real button click paths.
- Menu boot asserts initial focus and hero preview contract.
- Match root stats collection drives result text.
- ESC target helper covers intro, match and result states.
- Restart cleanup covers countdown, golden goal and slow-mo.
- Pure rule-helper test covers match stat collection and summary.

## Evidence

Playtest report:

- `docs/playtest-reports/track-04d-match-completeness-v1.md`

Screenshots:

- `docs/screenshots/track-04d-match-completeness-v1/hero-menu-1920x1080.png`
- `docs/screenshots/track-04d-match-completeness-v1/hero-menu-1280x720.png`
- `docs/screenshots/track-04d-match-completeness-v1/pause-menu-1920x1080.png`
- `docs/screenshots/track-04d-match-completeness-v1/result-stats-simulated-match-1920x1080.png`
- `docs/screenshots/track-04d-match-completeness-v1/fade-frame-01-start.png`
- `docs/screenshots/track-04d-match-completeness-v1/fade-frame-02-black.png`
- `docs/screenshots/track-04d-match-completeness-v1/fade-frame-03-clear.png`

Capture tool:

- `tools/capture_track04d_match_completeness.gd`

## Validation

- One-time headless editor import ran for the new worktree cache.
- Rendered capture ran with Vulkan/Forward+ on NVIDIA GeForce RTX 4070 Ti.
- `tools/validate.gd`: PASS, `79/79` tests, `1186` asserts.
- Source integrity: PASS, `30` `.gd/.gdshader` files outside `addons/`.
- `tools/check_doc_drift.ps1`: PASS.
- `git diff --check`: PASS.
- Known validation noise: existing GUT UID/text-path warnings.
- Rendered capture noise: Godot reports ObjectDB leaked instances at script exit after screenshots are written.

## Boundaries

- No gameplay rule changes to tap/RMB, score resolution, timer/golden goal, bot policy or arena physics.
- Did not touch `field_builder/**`, shaders or avatar files reserved for the parallel 04C thread.
- No push/fetch/pull. Local merge to `main` completed after review approval.

## Handoff

Claude review approved Track 04D in `docs/code-review-track04c-04d-v1.md`, and the branch was merged locally to `main`. The 04D worktree is eligible for prune. `WORKTREE_VERIFIED`.
