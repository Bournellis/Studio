# Track 10 Current Status

Status: `INTEGRATED_BATTLE_PRESENTATION_READY`

Date: 2026-05-28

## Delivered

- Created the Track 10 documentation set and coordination registry.
- Added `battle_logs` to the app route contract as fullscreen portrait gameplay.
- Reworked `battle_running`:
  - no app chrome;
  - no external header, timeline or side cards outside the stage;
  - `BattleVisualMockup` now supports `stage_only` mode;
  - `BattleStage2D` remains the main duel stage with HP, mana, spells, status, effects and summons;
  - `Pular batalha` is a large lower-right action in the battle layout.
- Reworked `battle_summary`:
  - minimal result screen;
  - primary actions are `Ver logs` and `Voltar ao Refugio`;
  - reward/resource/stat cards are intentionally not shown there.
- Added fullscreen `battle_logs`:
  - shows formatted text events for the current battle;
  - supports `Voltar ao Resultado` and `Voltar ao Refugio`;
  - does not fetch global history by default.
- Tightened `BattleStage2D` label/status positioning so narrow portrait stages do not leak horizontally.
- Updated GUT and smokes for the new battle loop.

## Validation

- `tools/validate.gd`: passed with GUT `98/98` tests and `1208` asserts.
- GUT client complete: passed with `98/98` tests and `1208` asserts.
- `tools/smoke_mobile_presentation.gd`: passed.
- `tools/smoke_foundation_hardening.gd`: passed.
- `tools/smoke_exports.gd`: passed.
- `tools/smoke_battle_replay.gd`: passed against remote Internal Alpha after redeploying the `battle` Edge Function.
- Deno checks for `supabase/functions` and `server/functions`: passed.
- `release_manifest_smoke.ts`: passed against remote Internal Alpha.
- `internal_alpha_remote_smoke.ts` with `DRAXOS_REMOTE_RELEASE_SMOKE=1`: passed.
- `git diff --check`: passed.

## Publication 2026-05-28

- Rebuilt and republished Internal Alpha site/Web/APK/Windows from branch `codex/draxos-mobile/release-update-builds`.
- Android APK: `27,965,106` bytes, SHA-256 `ad6d2579ce003769cfce2536b788c1330abb283d0ae90cc785d1d016ae514ca6`.
- PC Windows ZIP: `36,466,312` bytes, SHA-256 `ad5fb8351bb001604479d95737fc702bb9b0ff6779afb9e3e31692b7bc189031`.
- Web index: `5,442` bytes, SHA-256 `75fdd260b889582cb723256e87ca9867ae35b7cdd3411cbb2ca21ace5585366a`.
- Supabase Storage downloads and web assets returned HTTP 200.
- Cloudflare Pages deployment completed at `https://36b1d46c.draxos-mobile-internal-alpha.pages.dev`.
- Main Pages domain is currently protected by Cloudflare Access, so anonymous HTTP checks return the Access sign-in page rather than the game HTML.

## Guardrails

- No backend, schema, migration, simulator, reward, ranking, economy or `battle_log_v1` changes.
- No final asset import.
- `boot.gd` remains the orchestrator.
- Presenters remain render-only.
