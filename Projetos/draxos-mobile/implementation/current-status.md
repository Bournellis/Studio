# DraxosMobile - Current Status

- Last updated: `2026-05-29`
- Project: `draxos-mobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `Internal Alpha`
- Active stage: `Battle Presentation v1`
- Active stage status: `BATTLE_PRESENTATION_V1_PUBLISHED`
- Hardening baseline: `Track 13 - Foundation Validation And Release Safety` (`TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`)
- Agent baseline: `Track 14 - Agent Operations Foundation` (`TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`)
- Latest published package: `Battle Presentation v1`
- Latest technical package: `Track 16 - Behavior And Potion Crafting` (technical context, not current product focus)
- Build channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`

## Baseline

Track 00-15 are integrated on Godot 4.6.2 + Supabase. Track 16 is the latest technical package and has not been promoted as the current product focus.

The implemented base includes Android/PC/Web alpha surfaces, email/password account flow, `normal` and `progression_lab` saves, server-authoritative battle, Base/Social/Competition/Shop loops, Progression Lab/Battle Lab, portrait Refugio, fullscreen portrait battle, skip, summary and current-battle logs.

Current product reading: this is a strong prototype base for refinement. Names, spells, weapons, economy values, Battle Pass, battle flavor, visual identity and premium content are mock/substance used to keep the app from feeling empty, not final design direction.

Immediate loop under audit:

`Base -> collect resources -> evolve base -> battle -> receive rewards -> check base again`

The major foundation baseline is:

- Track 11: live docs, release state, Kanban cleanup, manual walkthrough and first safe `boot.gd` cut.
- Track 12: `boot.gd` decomposed to action contract, account/session flow, surface action flow, battle lifecycle flow and shared surface helpers; current budget is under `1500` lines.
- Track 13: `tools/validate_foundation.ps1`, safe `publish_internal_alpha.ps1` modes, release safety checks, readiness checks and Android/Windows/Web manual gate.
- Track 14: agent operating manual, documentation index, status sync, safe commands and drift guards.
- Track 15: premium internal Android portrait UX for Entry, Refugio, Battle/Summary, Base and Shop without gameplay/backend/economy changes.
- Track 16: behavior, Po de Osso and potion crafting package; technical context and not current product focus.

## Foundation Audit

Foundation Baseline is the active stage. Foundation Audit aligned documents, audited the internal post-login loop and produced the current published baseline before implementation expands.

Documentation alignment is complete, and the first loop audit is recorded in `docs/foundation-loop-audit.md`. The audit conclusion was: the foundation exists technically, but the V0 UX needed a focused pass so the player always understands the next post-login action.

Foundation Loop UX Pass 01 is implemented and published to the Internal Alpha artifact/site channel from branch `codex/draxos-mobile/foundation-loop-ux-pass`. It makes Refugio the operational loop home, adds a visible loop panel, separates unseen battle rewards from old battle history, removes confirmation from routine collection, changes the battle summary return to `Voltar e verificar base`, marks battle results as seen on return, and adds the no-network smoke `tools/smoke_foundation_loop.gd`.

Foundation Responsive Guardrails were applied and published on `2026-05-28` after manual review found the published Web/APK layout clipping Entry tools, Refugio and Battle. The hotfix restores Entry Labs in Internal Alpha, moves Refugio/Battle immersive UI into safe frames, and adds `docs/foundation-responsive-layout-contract.md` plus `tools/smoke_responsive_layout.gd`. The publication used public unlisted APK/PC Storage URLs so mobile downloads do not hit the protected Bearer-token endpoint.

Follow-up refuge/battle hotfixes were published on `2026-05-28` from branch `codex/draxos-mobile/foundation-responsive-guardrails`. They keep Refugio as the post-login session root, keep Labs Dev visible from Refugio, redirect accidental login returns back to Refugio during an active session, and replace the battle-request replay preview with a static battle splash while the real battle opens.

Entry Dev Labs export hotfix was published on `2026-05-28` after manual review showed the published menu still hid Battle Lab and Progression Lab. The root cause was `export_presets.cfg` excluding `dev/**`, so exported builds could not satisfy `ResourceLoader.exists()` for the lab overlays. Internal Alpha exports now package `res://dev/battle_lab/battle_lab_screen.gd` and `res://dev/progression_lab/progression_lab_screen.gd`, and `tools/smoke_exports.gd` prevents this regression.

Manual Android/Windows/Web review passed on `2026-05-29`. The review confirmed Battle Lab and Progression Lab in the initial menu, Refugio/Battle contained in screen bounds, APK download without Bearer-token error, static splash while requesting battle and a clear post-login loop. Foundation Loop UX Pass 01 is therefore the current accepted baseline for the next product decision.

Priority order after baseline confirmation:

1. Internal loop ergonomics.
2. Social.
3. General visual direction.
4. Battle presentation.
5. Weapons, spells, economy, balance and content details.

Internal loop ergonomics, Social Basico Guilda v1, Visual Direction v1, Ossos Inteiros v1 and Battle Presentation v1 have received explicit packages and are published to Internal Alpha. No new code, schema, backend, asset, gameplay or balance work belongs outside an explicit next package decision.

## Battle Presentation v1

Battle Presentation v1 is implemented as a client-only readability pass for the real battle loop. It keeps the existing backend/API/schema, simulator, rewards, ranking, economy, weapons, spells and `battle_log_v1` contract.

- `battle_running` stays fullscreen, without app chrome, inside `BattleSafeFrame`.
- Running battle now has a compact confrontation strip with player vs opponent, lance progress, current state and a touch-safe `Pular batalha` action.
- `BattleVisualMockup`, `BattleStage2D` and `BattleLogPresenter` now present damage, healing, consumable use, status, familiars, summons and battle result with player-facing language.
- `battle_summary` prioritizes the result, opponent, short outcome phrase, reward/resources/ranking when present and the primary CTA `Voltar e verificar base`.
- `battle_logs` remains read-only and scoped to the current battle, with logs formatted for players instead of technical inspection.
- `docs/battle-presentation-v1.md` is the live package note.
- Battle Presentation v1 was published to Internal Alpha on `2026-05-29` after explicit release approval. The publication updated Android APK, PC Windows ZIP, Web assets, the Cloudflare Pages package and portal copy without backend/schema/API changes.
- The public Web package now points to the cache-busted asset root `internal-alpha/v0-battle-presentation-20260529/web`.

## Social Basico Guilda v1

Social Basico Guilda v1 is implemented as the next product package after the confirmed Foundation baseline. It keeps the existing backend/API/schema and focuses on making the current social loop usable by real testers:

- Social screen now highlights account identity, own username, social save badge and clear Friends/Guild/Chat sections.
- Copy/show own username is a local shell action; it does not touch the server.
- Friends by username, guild create/join, member list, read-only guild structures and guild chat keep the existing endpoints.
- Guild chat now has light auto-sync every 8s only while the Social screen is open, pausing outside Social, offline, without account/session, during another action or in local-only Progression Lab.
- Published Internal Alpha builds now include Social Basico Guilda v1. Realtime, direct chat, helps, guild contributions, chat global, moderation/report/block, invites, guild wars and backend/schema changes remain out of scope.

## Latest Technical Package

Track 16 added the first behavior/crafting/consumable package requested by the user. It remains technical context and not the current product focus; Ossos Inteiros v1 only promotes the subset needed to make the published alpha coherent around whole-number Ossos.

- Ossos are represented as whole numbers in the new scale (`1 Osso atual = 0.01 Osso antigo`) and current economy/content/Progression Lab values were rescaled by `100`.
- `po_osso` was added as a whole-number resource, created by crushing Ossos.
- `pocao_vida` and `craft_pocao_vida` were added to content, crafting state and server-authoritative Edge Functions.
- Save-scoped `crafting/*` and `build/*` endpoints manage crafting, consumable inventory, potion slot and spell/potion behavior.
- Battle simulator supports spell behavior, `consumable_use`, one potion use per slot per battle and five `heal` ticks of `4%` max HP.
- Godot Base/Ossario and Refugio preparation panels expose crafting, potion equip/remove and simple behavior toggles.

Ossos Inteiros v1 is now published on top of the Visual Direction v1 build. The remote migration `202605280001_behavior_crafting.sql` is applied, Edge Functions were redeployed, generated Grimoire catalogs now expose whole-number Ossos values, and Base collection preserves sub-one Ossos accrual until at least `1` whole Osso is collectable. This fixes the visible `0.1 osso` class of issue without adding a new schema/API package beyond Track 16.

## Release Snapshot

| Artifact | Bytes | SHA256 |
|---|---:|---|
| Android APK | `31633429` | `e4789c43d83a4ae931d575daca27b10591c5d8f790b9ca2d1e968f8c089ded97` |
| PC Windows ZIP | `40101277` | `82b3b493ec5384fd18f7f3334d70297997489da7935c84dc193019ddcc6428a5` |
| Web index | `5442` | `4a80d29956931a8363587ed01b4e1a7890b3858205dd243b41432ccd8d9e7582` |

Links:

- Supabase remote: `https://armxgipvnbbshzqawklw.supabase.co`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Stable portal: `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Stable Web: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Latest verified preview: `https://2a470539.draxos-mobile-internal-alpha.pages.dev`
- Web asset root: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-presentation-20260529/web`

Battle Presentation v1 was published to the Internal Alpha artifact/site channel on `2026-05-29`. The stable root `internal-alpha/v0` carries the latest APK/PC package, and Web assets were uploaded to `internal-alpha/v0-battle-presentation-20260529` so browser caches cannot reuse older `index.js`, `index.pck` or `index.wasm` paths. APK/PC downloads are public unlisted Storage URLs again, avoiding the earlier direct-download Bearer-token error while keeping the stable Cloudflare Pages domain behind Access. Public unauthenticated Web validation should use the verified preview URL or an authenticated Access session. The Edge manifest endpoint remains healthy, but the release override was not updated during this publication because the local environment did not include `SUPABASE_ACCESS_TOKEN`; the portal package now reads its bundled `manifest.example.json` for published links/hashes.

## Visual Direction v1

Visual Direction v1 is implemented and published as the next refinement package after Social Basico Guilda v1. It did not change backend, schema, API, gameplay, economy, content tuning or final art.

- `docs/visual-direction-v1.md` is the live direction document for this package.
- `core/ui_tokens.gd` now owns surface accents, action accents, CTA selection and shared panel/button style helpers.
- Entry, Refugio drawer actions, shell action buttons, output panels and Base/Social/Competition/Shop panels now use the same restrained surface accent contract.
- Touch targets, responsive frames, first-screen Refugio anchors and battle safe frames remain in the existing Foundation Responsive contract.

## Risks And Blocks

- Track 16 migration/functions/catalog changes needed for Ossos Inteiros v1 are deployed. Further crafting, behavior, tuning, economy or content expansion still needs its own explicit package decision.
- Foundation Loop UX Pass 01 is the accepted current V0 UX baseline after manual Android/Windows/Web review on `2026-05-29`; Social Basico Guilda v1 and Battle Presentation v1 are now available in the published Internal Alpha build for human validation.
- Battle Presentation v1 is published to Internal Alpha with public APK/PC downloads and a cache-busted Web asset root; it still needs manual Android/Windows/Web confirmation on the stable site/app channels.
- Edge release manifest override needs `SUPABASE_ACCESS_TOKEN` available in the release environment for future `publish_internal_alpha.ps1 -Mode DeployManifest` runs. This publication kept the endpoint healthy and used the packaged portal manifest as the published-link source.
- Track 13 release safety remains the baseline for any future publication or wider-access gate.
- `players.save_type` remains an alpha shortcut. `account_profiles` + `game_saves` is a future migration package.
- Progression/economy remains mock/substance and not the current tuning focus.
- Release scripts are safe by default; remote mutation remains opt-in with `-ConfirmRemoteMutation`.

## Next Step

Manually review published Battle Presentation v1 on Android, Windows and Web, then choose the next product package. Keep direct chat, helps, contributions, moderation, tuning numbers, weapons, spells, economy and broader replay controls out of scope until they receive their own explicit package.

## Validation

Latest validation for Battle Presentation v1 publication on `2026-05-29`:

- One-time Godot `--headless --import`: PASS in fresh publication worktree.
- `validate_foundation.ps1 -Profile Client`: PASS, including `tools/validate.gd`, GUT `tests/client` (`119/119`, `1895` asserts), runtime/hardening/responsive/export smokes.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: PASS for `internal-alpha/v0-battle-presentation-20260529`.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: PASS.
- Supabase Storage upload: PASS for `internal-alpha/v0-battle-presentation-20260529` and stable `internal-alpha/v0`.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-presentation-20260529/web`: PASS.
- Cloudflare Pages deploy: PASS, verified preview `https://2a470539.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`: BLOCKED before remote secret mutation because `SUPABASE_ACCESS_TOKEN` was not available; Edge manifest endpoint remained healthy and portal was adjusted to read bundled `manifest.example.json`.
- `server/tests/release_manifest_smoke.ts`: PASS against remote Supabase.
- `server/tests/internal_alpha_remote_smoke.ts` with `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS.
- Preview GET checks: PASS for `/portal/index.html`, `/portal/manifest.example.json` and `/web/index.html` with versioned Web asset root.
- Remote HEAD checks: PASS for versioned `index.js` (`315759` bytes), `index.pck` (`4227948` bytes), `index.wasm` (`37695054` bytes), versioned APK (`31633429` bytes) and stable APK (`31633429` bytes), all without Bearer token.

Latest validation for Ossos Inteiros v1 publication on `2026-05-29`:

- `npx -y deno test --allow-read server/tests/integer_bones_contract_test.ts`: PASS.
- `npx -y deno check server/functions/base/index.ts supabase/functions/base/index.ts server/functions/content/index.ts supabase/functions/content/index.ts server/tests/integer_bones_contract_test.ts`: PASS.
- `npx -y deno test --allow-read server/tests/foundation_contracts_test.ts server/tests/integer_bones_contract_test.ts`: PASS.
- `validate_foundation.ps1 -Profile Client`: PASS after one-time Godot import in the fresh worktree.
- `validate_foundation.ps1 -Profile Quick`: PASS after server config and smoke updates.
- Supabase remote migration push: PASS; local/remote migrations aligned through `202605280001_behavior_crafting.sql`.
- Supabase Edge Function deploy: PASS for gameplay/release functions touched by the package.
- Remote smokes: PASS for `base_manager_smoke.ts`, `monetization_rewards_smoke.ts`, `grimoire_catalog_smoke.ts` and `first_slice_battle_smoke.ts`.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: PASS.
- Supabase Storage upload with CLI `2.98.0`: PASS for `internal-alpha/v0` and `internal-alpha/v0-integer-bones-20260529`.
- Cloudflare Pages deploy: PASS, preview `https://d7a31bf6.draxos-mobile-internal-alpha.pages.dev`.
- Supabase release manifest override + `release` function deploy: PASS.
- Remote release smokes: PASS for `release_manifest_smoke.ts`, `release_artifacts_remote_smoke.ts`, `internal_alpha_remote_smoke.ts` with `DRAXOS_REMOTE_RELEASE_SMOKE=1`, and `grimoire_catalog_smoke.ts`.
- Direct APK HEAD without Bearer token: PASS, `200`, `31629333` bytes, `application/vnd.android.package-archive`.
- Cache-bust preview checks: PASS for `/portal/index.html` with public APK link, `/web/index.html` with `GODOT_CONFIG` and the versioned asset root, plus remote HEAD `200` for versioned `index.js`, `index.pck` and `index.wasm`.

Latest validation for Visual Direction v1 publication on `2026-05-29`:

- One-time Godot `--headless --import`: PASS in fresh publication worktree.
- `validate_foundation.ps1 -Profile Client`: PASS, including `git diff --check`, PowerShell parse, server/supabase mirrors, Deno release typecheck light, structural readiness, `tools/validate.gd`, GUT `tests/client` (`119/119`, `1880` asserts), `tools/smoke_runtime_config.gd`, `tools/smoke_foundation_hardening.gd`, `tools/smoke_responsive_layout.gd` and `tools/smoke_exports.gd`.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan`: PASS.
- `publish_internal_alpha.ps1 -Mode Package`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- Cloudflare Pages deploy: PASS, preview `https://6a6ae522.draxos-mobile-internal-alpha.pages.dev`.
- Supabase Storage upload: PASS with Supabase CLI `2.98.0`, protected downloads enabled.
- Supabase release manifest override + `release` function deploy: PASS.
- `server/tests/release_manifest_smoke.ts`: PASS against remote Supabase.
- `server/tests/release_download_smoke.ts`: PASS with signed HEAD checks for Android and PC downloads.
- `server/tests/internal_alpha_remote_smoke.ts` with `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS.
- Preview GET checks: PASS for `/portal/index.html` (`Draxos Alpha`) and `/web/index.html` (`GODOT_CONFIG`).
- Web cache-bust hotfix after browser check: PASS. `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-web-20260529-visual-direction-v1 -ConfirmRemoteMutation` uploaded versioned Web assets, `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-web-20260529-visual-direction-v1/web` rewrote the loader URLs, and Cloudflare Pages deploy produced preview `https://5477aaf9.draxos-mobile-internal-alpha.pages.dev`.
- Cache-bust preview checks: PASS for `/portal/index.html` (`Draxos Alpha`), `/web/index.html` (`GODOT_CONFIG` and versioned asset root), and remote HEAD `200` for versioned `index.js`, `index.pck` and `index.wasm`.
- `tools/check_agent_ops_foundation.ps1`: PASS after status updates.
- `validate_foundation.ps1 -Profile Quick`: PASS after status updates.
- `git diff --check`: PASS.

Latest validation for Social Basico Guilda v1 publication on `2026-05-29`:

- `validate_foundation.ps1 -Profile Full`: PASS, including `tools/validate.gd`, GUT `tests/client` (`117/117`, `1857` asserts), runtime/hardening/responsive/export smokes, release typecheck, Track 13 readiness and Track 14 agent ops checks.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan`: PASS.
- `publish_internal_alpha.ps1 -Mode Package`: PASS.
- Cloudflare Pages deploy: PASS, preview `https://483a73f3.draxos-mobile-internal-alpha.pages.dev`.
- Supabase Storage upload: PASS, `25` files uploaded across public site assets and protected downloads.
- Supabase release manifest override + `release` function deploy: PASS.
- `server/tests/release_manifest_smoke.ts`: PASS against remote Supabase.
- `server/tests/release_download_smoke.ts`: PASS with signed HEAD checks for Android and PC downloads.
- `server/tests/internal_alpha_remote_smoke.ts` with `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS.
- Preview GET checks: PASS for `/portal/index.html` (`Draxos Alpha`) and `/web/index.html` (`GODOT_CONFIG`).
- `git diff --check`: PASS.
- `server/tests/release_artifacts_remote_smoke.ts`: unauthenticated artifact probe returns `401` for protected downloads by design; use `release_download_smoke.ts` for the signed download contract.

Latest validation for Battle Presentation v1 local merge on `2026-05-29`:

- GUT `tests/client`: PASS (`119/119`, `1895` asserts).
- `tools/smoke_mobile_presentation.gd`: PASS.
- `tools/smoke_responsive_layout.gd`: PASS, including `battle_running`, `battle_summary` and `battle_logs` at `360x800`, `390x844`, `1280x720` and `1920x1080`.
- `tools/smoke_foundation_loop.gd`: PASS.
- `tools/validate.gd`: PASS (`119/119`, `1895` asserts).
- `validate_foundation.ps1 -Profile Client`: PASS, including `git diff --check`, PowerShell parse, server/supabase mirrors, Deno release typecheck light, structural readiness, `tools/validate.gd`, GUT `tests/client`, `tools/smoke_runtime_config.gd`, `tools/smoke_foundation_hardening.gd`, `tools/smoke_responsive_layout.gd` and `tools/smoke_exports.gd`.
- `validate_foundation.ps1 -Profile Quick`: PASS after documentation/status updates.
- `tools/check_agent_ops_foundation.ps1`: PASS after Kanban/status updates.
- `git diff --check`: PASS.

Documentation/foundation validation for this stage:

```powershell
git diff --check
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_agent_ops_foundation.ps1 -ProjectDir .
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_loop.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_hardening.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
```

Full release/backend validation remains available through `validate_foundation.ps1 -Profile Full` when a gate needs it.

Note: on a fresh worktree, run the Godot `--import` step once before headless smokes if global class names are not yet registered.

## Read Next

1. `../AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `docs/documentation-index.md`
4. `docs/foundation-app-v0-audit.md`
5. `docs/foundation-loop-audit.md`
6. `docs/product-vision.md`
7. `docs/product-brief.md`
8. `docs/design-pending.md`
