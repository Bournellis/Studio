# DraxosMobile - Battle Presentation v1

- Status: `PUBLISHED_INTERNAL_ALPHA`
- Last updated: `2026-05-29`
- Scope: client-only presentation pass for `battle_running`, `battle_summary` and `battle_logs`.

## Purpose

Battle Presentation v1 makes the existing server-resolved battle easier to read during real playtest. The player should understand who is fighting, what just happened, who is in danger, what the result was and why returning to the Refugio matters.

This package does not change backend, schema, API, simulator, rewards, ranking, economy, weapons, spells or the `battle_log_v1` contract.
It was published to the Internal Alpha site/artifact channel on `2026-05-29`.

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

## Publication

- Stable portal: `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Stable Web: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Verified preview: `https://2a470539.draxos-mobile-internal-alpha.pages.dev`
- Web asset root: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-presentation-20260529/web`
- Android APK: `31633429` bytes, SHA256 `e4789c43d83a4ae931d575daca27b10591c5d8f790b9ca2d1e968f8c089ded97`
- PC Windows ZIP: `40101277` bytes, SHA256 `82b3b493ec5384fd18f7f3334d70297997489da7935c84dc193019ddcc6428a5`

The publication uploaded both `internal-alpha/v0-battle-presentation-20260529` and stable `internal-alpha/v0`. Cloudflare Pages stable domain can require Access; unauthenticated verification used the preview URL. `publish_internal_alpha.ps1 -Mode DeployManifest` was blocked before remote secret mutation because `SUPABASE_ACCESS_TOKEN` was not available, so the portal package reads its bundled `manifest.example.json` for the current published links/hashes while the Edge manifest endpoint remains healthy.

## Validation

Latest publication validation on `2026-05-29`:

- `validate_foundation.ps1 -Profile Client`: PASS (`119/119`, `1895` GUT asserts plus runtime/hardening/responsive/export smokes).
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: PASS.
- Supabase Storage upload: PASS for versioned root and stable `internal-alpha/v0`.
- `build_cloudflare_pages_package.ps1`: PASS with versioned Web asset root.
- Cloudflare Pages deploy: PASS, preview `https://2a470539.draxos-mobile-internal-alpha.pages.dev`.
- `server/tests/release_manifest_smoke.ts`: PASS.
- `server/tests/internal_alpha_remote_smoke.ts` with `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS.
- Preview GET and remote HEAD checks: PASS for portal, local packaged manifest, Web `GODOT_CONFIG`, versioned `index.js`/`index.pck`/`index.wasm`, versioned APK and stable APK without Bearer token.

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
