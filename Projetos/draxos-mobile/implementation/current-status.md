# DraxosMobile - Current Status

- Last updated: `2026-05-31`
- Project: `draxos-mobile`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `Internal Alpha`
- Active stage: `Remote Lab Runner`
- Active stage status: `REMOTE_LAB_RUNNER_LOCAL_VALIDATED`
- Hardening baseline: `Track 13 - Foundation Validation And Release Safety`
  (`TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`)
- Agent baseline: `Track 14 - Agent Operations Foundation`
  (`TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`)
- Latest published remote package: `Lab Web Export Guard Hotfix`
- Latest implemented package: `Remote Lab Runner` on branch
  `codex/draxos-mobile/remote-lab-runner`.
- Active follow-up: publish/deploy the `lab-runner` Edge Function and updated
  Web/Android/PC package, then human playtest Arena PVE plus Web Battle
  Lab/Progression Lab remote generation.
- Latest technical package: `Track 16 - Behavior And Potion Crafting` (technical
  context, not current product focus; current state summarized in
  `docs/behavior-potion-crafting-v1.md`)
- Build channel: `internal_alpha`
- Version: `0.0.1-alpha.0`
- Version code: `1`

## Baseline

Track 00-15 are integrated on Godot 4.6.2 + Supabase. Track 16 is the latest
technical package and has not been promoted as the current product focus. Its
live bridge document is `docs/behavior-potion-crafting-v1.md`.

The implemented base includes Android/PC/Web alpha surfaces, email/password
account flow, `normal` and `progression_lab` saves, server-authoritative battle,
Base/Social/Competition/Shop loops, Progression Lab/Battle Lab, portrait
Refugio, fullscreen portrait battle, skip, summary and current-battle logs.
Track 18 now adds the published Arena PVE-first implementation branch with
server-authoritative attempts, steps, temporary buffs, completion rewards,
client shell routes and arena-specific lab outputs.
Track 19 now aligns the same package for consistency before tuning: potions are
consumed from live stock per Arena duel, claim is read as summary/ack only, the
public buff endpoint is `/arena/pve/buff/select`, the client lists remote Arena
data, and the labs report Arena PVE sequence sanity targets.
Lab Web Export Guard is the current remote hotfix over Track 19: Battle Lab Dev
and Progression Lab Dev now detect Web export before calling `OS.execute`,
disable local-process actions in the browser and keep PC/editor Lab generation
available.
Remote Lab Runner is the current local follow-up over that hotfix: Web Battle
Lab and Progression Lab can call Supabase Edge `lab-runner` with the same
email/password Internal Alpha account gate used by the game, without exposing
service role to the client or mutating economy/ranking/progress.

Current product reading: this is a strong prototype base for refinement. The
current product direction is Arena PVE initial, documented in
`docs/pve-arena-initial-direction.md`. Names, spells, weapons, economy values,
Battle Pass, battle flavor, visual identity and premium content are
mock/substance used to keep the app from feeling empty, not final design
direction unless the Arena PVE package explicitly promotes them.

Historical foundation shell loop from Foundation Loop UX Pass 01
(app-shell baseline, not the current product loop):

`Base -> collect resources -> evolve base -> battle -> receive rewards -> check base again`

Product loop now selected for the current package:

`Refugio -> Arena PVE -> lock loadout -> duel list -> temporary stat buffs and behavior prep between duels -> rewards -> upgrades`

The major foundation baseline is:

- Track 11: live docs, release state, Kanban cleanup, manual walkthrough and
  first safe `boot.gd` cut.
- Track 12 + Foundation Final Polish: `boot.gd` stays as a thin scene-facing
  shell, action/runtime flow lives behind dedicated scripts, and
  `hub_surface_presenter.gd` stays a facade under the final shell budget.
- Track 13: `tools/validate_foundation.ps1`, safe `publish_internal_alpha.ps1`
  modes, release safety checks, readiness checks and Android/Windows/Web manual
  gate.
- Track 14: agent operating manual, documentation index, status sync, safe
  commands and drift guards.
- Track 15: premium internal Android portrait UX for Entry, Refugio,
  Battle/Summary, Base and Shop without gameplay/backend/economy changes.
- Track 16: behavior, Po de Osso and potion crafting package; technical context
  and not current product focus.
- Lab Track 16 Alignment: Battle Lab and Progression Lab now model Track 16
  potion slots, potion crafting stock, `po_osso`, default potion behavior and
  spell behavior toggles as lab-only evidence before tuning.

## Track 18 - PVE Arena Initial

On `2026-05-31`, the product direction changed from PVP-first to Arena
PVE-first. Track 18 is implemented and published from
`codex/draxos-mobile/pve-arena-integration` to Internal Alpha.

- tutorial starts with 1 guided duel;
- first real arenas start with 3 duels;
- v1 data includes 3, 4, 5 and 6-duel arenas;
- longer arenas unlock later and keep scaling difficulty;
- loadout is locked before the arena;
- HP resets to 100% before every duel;
- between duels, the player chooses 1 of 3 temporary stat buffs;
- behavior can be adjusted before the next enemy;
- combat has no cooldown;
- rewards are controlled by first clears, completion, difficulty, records,
  repeat reduction, daily/weekly limits and season caps;
- PVP moves to a later competitive package, with bots only as fallback or
  simulation while playerbase grows.

Implemented and published in Track 18:

- `docs/pve-arena-v1.md` and contract docs define Arena PVE as a domain
  separate from PVP/ranking.
- `pve_arenas`, `pve_enemies`, `arena_buffs` and `arena_rewards` are registered
  in `foundation_ruleset_v0`.
- `arena_attempts`, `arena_attempt_steps` and `arena_progress` are
  server-authoritative via transactional RPCs.
- Edge Functions expose `arena/pve/state`, `arena/pve/start`,
  `arena/pve/duel/request`, `arena/pve/buff/select`, `arena/pve/claim` and
  `arena/pve/abandon`, mirrored in `server/` and `supabase/`.
- Arena PVE reward/progress mutation happens on the final
  `arena/pve/duel/request`; `arena/pve/claim` is a summary/ack endpoint and
  returns `mutates_economy: false`.
- Refugio now points the main CTA to Arena PVE, with selection, locked-loadout,
  active attempt, replay, buff choice and summary surfaces.
- Battle Lab now emits `battle_lab_arena_sequences.csv`; Progression Lab now
  emits `arena_progression_checks.csv` and models attempts/duels/clear rate
  instead of treating PVP battles as the early loop.

Validation and publication completed for Track 18:

- `git diff --check`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `npx -y deno test --allow-read --allow-write tools/battle_lab/battle_lab_test.ts`
- `npx -y deno test --allow-read --allow-write tools/progression_lab/progression_lab_test.ts`
- `npx -y deno test --allow-read server/tests/foundation_ruleset_test.ts`
- Godot `tools/validate.gd` after a one-time headless editor import: 134/134
  tests, 2310 assertions.
- `tools/validate_foundation.ps1 -Profile Full -RequireClean`: passed after
  Track 18 integration.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: passed using
  the ignored local Internal Alpha env file; Android export mode:
  `debug_fallback`.
- `tools/publish_internal_alpha.ps1 -Mode Plan`: passed.
- `tools/publish_internal_alpha.ps1 -Mode Package`: passed and produced the
  local package at `build/internal-alpha/publish`.
- `tools/publish_internal_alpha.ps1 -Mode Upload -PublicDownloads
  -ConfirmRemoteMutation`: passed for release root
  `internal-alpha/v0-pve-arena-entry-20260531-6cbc853`.
- `tools/build_cloudflare_pages_package.ps1`: passed with Web assets rooted at
  the versioned Supabase Storage path.
- `npx -y wrangler pages deploy`: passed, preview
  `https://c185369d.draxos-mobile-internal-alpha.pages.dev`.
- `tools/publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads
  -ConfirmRemoteMutation`: passed, manifest now points to the Track 18 preview.
- `server/tests/release_manifest_smoke.ts`: passed remotely.
- `server/tests/release_artifacts_remote_smoke.ts`: passed remotely for
  manifest, Portal, Web, APK and PC ZIP.
- `server/tests/internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`: passed remotely.

Published Internal Alpha artifacts:

- Portal:
  `https://c185369d.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web:
  `https://c185369d.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-pve-arena-entry-20260531-6cbc853/downloads/draxos-mobile-alpha.apk`
  (`31737628` bytes).
- PC Windows ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-pve-arena-entry-20260531-6cbc853/downloads/draxos-mobile-alpha.zip`
  (`40196236` bytes).
- Manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

Remaining after publication: run human playtest of the Arena PVE tutorial,
3-duel arena, preparation/loadout lock, buff choice, defeat/conclusion summary
and return-to-Refugio loop in Web/APK/PC.

## Track 19 - Arena Consistency Pass

Track 19 is implemented and published remotely on
`codex/draxos-mobile/arena-consistency-pass` as a consistency package over the
published Track 18 Arena PVE baseline.

Implemented in Track 19:

- Arena PVE potion use now treats the equipped potion as locked loadout intent,
  but consumes live `player_consumables` stock per duel through
  `arena_record_duel_v1` and `item_transactions` source `arena_pve_v1`.
- `arena/pve/duel/request` passes simulator consumable usage to the RPC; retry
  with the same idempotency key does not duplicate potion consumption, reward,
  step progression or ledger effects.
- `/arena/pve/claim` remains a compatibility endpoint for summary/ack and
  returns `reward_already_applied` plus `mutates_economy: false`.
- `/arena/pve/buff/select` is the public buff endpoint; `/arena/buff/choose`
  remains compatibility alias only.
- The Refugio Arena surface renders all arenas from `arena_state.arenas` with
  `arena_start:<arena_id>` actions, disabled locked entries and fixture buttons
  only as dev fallback.
- Attempt summary, preparation and active-attempt copy now distinguish locked
  loadout, editable behavior and already-applied rewards.
- `foundation_ruleset_v0` now declares
  `primary_product_mode: PVE_ARENA_INITIAL`; `FIRST_SLICE_SIM` remains a
  technical simulator/replay mode.
- Battle Lab and Progression Lab now report Arena PVE attempt/sequence language,
  potion pressure and sanity clear-rate targets for 1/3/4/5/6 duel arenas.

Validation and publication completed for Track 19:

- `tools/validate_foundation.ps1 -Profile Full -RequireClean`: passed.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: passed using
  the ignored local Internal Alpha env file; Android export mode:
  `debug_fallback`.
- `tools/publish_internal_alpha.ps1 -Mode Plan`: passed.
- `tools/publish_internal_alpha.ps1 -Mode Package`: passed and produced
  `build/internal-alpha/publish`.
- `tools/publish_internal_alpha.ps1 -Mode Upload -PublicDownloads
  -ConfirmRemoteMutation`: passed for release root
  `internal-alpha/v0-arena-consistency-pass-20260531-0865e43`.
- `tools/build_cloudflare_pages_package.ps1`: passed with Web assets rooted at
  the versioned Supabase Storage path.
- `npx -y wrangler pages deploy`: passed, preview
  `https://168dc669.draxos-mobile-internal-alpha.pages.dev`.
- `tools/publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads
  -ConfirmRemoteMutation`: passed, manifest now points to the Track 19 preview.
- `server/tests/release_manifest_smoke.ts`: passed remotely.
- `server/tests/release_artifacts_remote_smoke.ts`: passed remotely for
  manifest, Portal, Web, APK and PC ZIP.
- `server/tests/internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`: passed remotely.

Published Track 19 Internal Alpha artifacts:

- Portal:
  `https://168dc669.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web:
  `https://168dc669.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-arena-consistency-pass-20260531-0865e43/downloads/draxos-mobile-alpha.apk`
  (`31741724` bytes).
- PC Windows ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-arena-consistency-pass-20260531-0865e43/downloads/draxos-mobile-alpha.zip`
  (`40201184` bytes).
- Manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

Next after Track 19: playtest the Arena PVE tutorial and 3-duel arena, confirm
the potion and summary behavior manually, then choose the focused tuning pass.

## Lab Web Export Guard Hotfix

Lab Web Export Guard is implemented and published remotely on
`codex/draxos-mobile/lab-web-export-guard` as a client hotfix over Track 19.

Implemented in the hotfix:

- Battle Lab Dev and Progression Lab Dev detect Web export before calling
  `OS.execute`.
- Buttons that require local `npx/deno` are disabled in the browser and expose
  a clear message to use PC/editor for local generation.
- PC/editor Lab generation remains unchanged.
- Tests simulate process-unavailable mode so the Web guard stays protected.

Validation and publication completed:

- `git diff --check`
- GUT client: `138/138`, `2364` asserts.
- `tools/smoke_dev_lab_ui.gd`: passed.
- `tools/validate.gd`: passed.
- `tools/smoke_responsive_layout.gd`: passed.
- `tools/smoke_exports.gd`: passed.
- `tools/validate_foundation.ps1 -Profile Client`: passed.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: passed using
  the ignored local Internal Alpha env file; Android export mode:
  `debug_fallback`.
- `tools/publish_internal_alpha.ps1 -Mode Plan`: passed.
- `tools/publish_internal_alpha.ps1 -Mode Package`: passed.
- `tools/publish_internal_alpha.ps1 -Mode Upload -PublicDownloads
  -ConfirmRemoteMutation`: passed for release root
  `internal-alpha/v0-lab-web-export-guard-20260531-9a415c3`.
- `tools/build_cloudflare_pages_package.ps1`: passed with Web assets rooted at
  the versioned Supabase Storage path.
- `npx -y wrangler pages deploy`: passed, preview
  `https://fc60138d.draxos-mobile-internal-alpha.pages.dev`.
- `tools/publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads
  -ConfirmRemoteMutation`: passed, manifest now points to the hotfix preview.
- `server/tests/release_manifest_smoke.ts`: passed remotely.
- `server/tests/release_artifacts_remote_smoke.ts`: passed remotely for
  manifest, Portal, Web, APK and PC ZIP.
- `server/tests/internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`: passed remotely.

Published hotfix Internal Alpha artifacts:

- Portal:
  `https://fc60138d.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web:
  `https://fc60138d.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-lab-web-export-guard-20260531-9a415c3/downloads/draxos-mobile-alpha.apk`
  (`31741724` bytes,
  `b23b88839f57fee70fd161d412ef78d6ea2a23300e01f0a731f36db6ab0749de`).
- PC Windows ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-lab-web-export-guard-20260531-9a415c3/downloads/draxos-mobile-alpha.zip`
  (`40202687` bytes,
  `1c937191561f0f1a39df0c4234eb183faf4be553afa057f9a6fd8613fbaf2e23`).
- Manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

Next after hotfix: playtest the Arena PVE tutorial and 3-duel arena, confirm
that Battle Lab Dev no longer tries to start `npx/deno` in Web export, then
choose the focused tuning pass.

## Remote Lab Runner

Remote Lab Runner is implemented locally on
`codex/draxos-mobile/remote-lab-runner` as the follow-up to Lab Web Export
Guard. It is not yet the latest published Internal Alpha package until the Edge
Function and client package are deployed.

Implemented in this package:

- New mirrored Edge Function `lab-runner` exposes `POST /lab-runner/battle` and
  `POST /lab-runner/progression`.
- Access uses the same Internal Alpha Supabase account gate as the game: JWT
  from a non-anonymous email/password account with a registered `normal` save. No
  separate Lab allowlist exists.
- Service role is used only inside the Edge Function to verify alpha access.
  The client/export never receives service role or secrets.
- Battle Lab Web can generate remote scratch runs and custom replay samples in
  memory when local `npx/deno` is unavailable.
- Progression Lab Web can generate the report data in memory when local
  `npx/deno` is unavailable.
- Remote runner does not write `docs/**`, `.battle_lab_scratch/**` or
  `.progression_lab_scratch/**`, does not archive official runs and does not
  mutate reward, XP, resources, ranking, potion stock, saves or ledger.

Local validation completed:

- `npx -y deno check server/functions/lab-runner/index.ts`
- `npx -y deno check supabase/functions/lab-runner/index.ts`
- `npx -y deno check server/functions/lab-runner/index.ts server/tests/lab_runner_contract_test.ts`
- `npx -y deno check supabase/functions/lab-runner/index.ts`
- `npx -y deno test --allow-read server/tests/lab_runner_contract_test.ts`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `npx -y deno test --allow-read server/tests/lab_heuristics_contract_test.ts server/tests/lab_runner_contract_test.ts`
- `tools/check_agent_ops_foundation.ps1`: PASS.
- `tools/validate_foundation.ps1 -Profile Quick`: PASS.
- Godot `tools/validate.gd`: PASS (`138/138`, `2364` asserts).

Pending before human Web test: deploy the `lab-runner` Edge Function, publish a
new Internal Alpha package and run the remote release smokes.

## Foundation Audit

Foundation Expansion Readiness/Foundation Closeout is the delivered foundation
gate. Foundation Audit aligned
documents, audited the internal post-login loop and produced the current
published baseline before implementation expands.

Documentation alignment is complete, and the first loop audit is recorded in
`docs/foundation-loop-audit.md`. The audit conclusion was: the foundation exists
technically, but the V0 UX needed a focused pass so the player always
understands the next post-login action.

Foundation Loop UX Pass 01 is implemented and published to the Internal Alpha
artifact/site channel from branch `codex/draxos-mobile/foundation-loop-ux-pass`.
It makes Refugio the operational loop home, adds a visible loop panel, separates
unseen battle rewards from old battle history, removes confirmation from routine
collection, changes the battle summary return to `Voltar e verificar base`,
marks battle results as seen on return, and adds the no-network smoke
`tools/smoke_foundation_loop.gd`.

Foundation Responsive Guardrails were applied and published on `2026-05-28`
after manual review found the published Web/APK layout clipping Entry tools,
Refugio and Battle. The hotfix restores Entry Labs in Internal Alpha, moves
Refugio/Battle immersive UI into safe frames, and adds
`docs/foundation-responsive-layout-contract.md` plus
`tools/smoke_responsive_layout.gd`. The publication used public unlisted APK/PC
Storage URLs so mobile downloads do not hit the protected Bearer-token endpoint.

Follow-up refuge/battle hotfixes were published on `2026-05-28` from branch
`codex/draxos-mobile/foundation-responsive-guardrails`. They keep Refugio as the
post-login session root, keep Labs Dev visible from Refugio, redirect accidental
login returns back to Refugio during an active session, and replace the
battle-request replay preview with a static battle splash while the real battle
opens.

Entry Dev Labs export hotfix was published on `2026-05-28` after manual review
showed the published menu still hid Battle Lab and Progression Lab. The root
cause was `export_presets.cfg` excluding `dev/**`, so exported builds could not
satisfy `ResourceLoader.exists()` for the lab overlays. Internal Alpha exports
now package `res://dev/battle_lab/battle_lab_screen.gd` and
`res://dev/progression_lab/progression_lab_screen.gd`, and
`tools/smoke_exports.gd` prevents this regression.

Manual Android/Windows/Web review passed on `2026-05-29`. The review confirmed
Battle Lab and Progression Lab in the initial menu, Refugio/Battle contained in
screen bounds, APK download without Bearer-token error, static splash while
requesting battle and a clear post-login loop. Foundation Loop UX Pass 01 is
therefore the accepted historical app-shell baseline; the current product loop
is Arena PVE.

Priority order after baseline confirmation:

1. Arena PVE initial product/tuning package.
2. Integrated leveling/upgrades/rewards/power calibration.
3. Base/preparation support for Arena PVE.
4. PVP posterior, with controlled bot fallback.
5. Social/competition after the PVE/PVP routine is clear.

Internal loop ergonomics, Social Basico Guilda v1, Visual Direction v1, Ossos
Inteiros v1, Battle Presentation v1, Battle Drama v1.1, Battle Preparation v1,
Battle Preparation Complete v1, Progression Clarity v1 and First Session Clarity
v1 have received explicit packages and are published to Internal Alpha. No new
code, schema, backend, asset, gameplay or balance work belongs outside an
explicit next package decision.

## First Session Clarity v1

First Session Clarity v1 is implemented, published and manually approved as the
current client-only first-session guidance package. It does not change backend,
schema, migrations, simulator, rewards, economy, tuning, weapons, spells,
potions, behavior or catalog content.

- Refugio now shows a persistent first-session hint inside the `Progresso`
  panel.
- The contextual Refugio CTA now explains reward, collection, base evolution and
  battle as one cycle.
- Preparation now gives a short first-session reading cue before loadout
  details.
- Battle summary now includes `Proximo passo`, connecting rewards back to
  collection, base evolution and the next battle.
- `tools/smoke_foundation_loop.gd` protects reward, collection, upgrade and
  summary guidance.
- `portal/internal-alpha/index.html` now uses `DraxosMobile Alpha`, matching the
  remote release smoke contract.
- Validation completed on `2026-05-30`: one-time Godot import in the fresh
  worktree, `git diff --check`, `tools/smoke_foundation_loop.gd`, GUT client
  (`123/123`, `1990` asserts), `tools/smoke_responsive_layout.gd`,
  `validate_foundation.ps1 -Profile Client`, publication checks and
  `server/tests/release_artifacts_remote_smoke.ts` passed.
- First Session Clarity v1 was published to Internal Alpha on `2026-05-30` with
  release root `internal-alpha/v0-first-session-clarity-v1-20260530`, public Web
  preview
  `https://f2ead4bd.draxos-mobile-internal-alpha.pages.dev/web/index.html`,
  public APK
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-first-session-clarity-v1-20260530/downloads/draxos-mobile-alpha.apk`
  and public PC ZIP
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-first-session-clarity-v1-20260530/downloads/draxos-mobile-alpha.zip`.
- Manual review on `2026-05-30` approved the package as clearer. The project
  remains active in P2; do not open an initial-loop motivation package by
  default.

Recommended next package: Arena PVE initial. Lab evidence is now aligned with
Track 16, but it still must be extended to arena sequences before promoting
numeric tuning.

## Foundation Expansion Readiness

Foundation Expansion Readiness is the delivered pre-expansion package. It
prepares DraxosMobile for production future, parallel agent work and larger
feature lanes without changing the published player-facing UX.

Delivered in the current branch:

- `docs/foundation-expansion-readiness.md` defines the multiagent lane matrix
  and contract-first gate.
- `docs/contracts/account-save.md` makes `account_profiles` + `game_saves` the
  account/save authority, with `players.save_type` as compatibility only.
- `docs/contracts/ruleset-registry.md` records the approved third path:
  repo-generated ruleset as authorship source and database registry as
  publication record.
- `docs/contracts/minigame-integration.md` blocks real minigames until entry,
  data, cost, reward, telemetry, admin and rollback are explicit.
- `docs/contracts/admin-ops.md` defines minimum auditable admin/support
  operations.
- `docs/contracts/lab-heuristics.md` fences Progression Lab and Battle Lab as
  lab-only diagnostic/authoring tools, records current model IDs and blocks
  tuning promotion without explicit package/ruleset validation.
- Migration `202605300001_foundation_expansion_readiness.sql` adds
  `account_profiles`, `game_saves`, `ruleset_registry`, `admin_audit_log`,
  idempotency v1 fields and ruleset metadata columns.
- Migration `202605300002_transactional_domain_enforcement.sql` promotes Base
  collect/upgrade to real v1 transactional RPCs with `game_saves`,
  `request_hash`, ruleset metadata, resource ledger and service-role-only
  grants.
- Migration `202605300003_remaining_transactional_domain_enforcement.sql`
  promotes `battle/request` (`FIRST_SLICE_SIM`, technical simulator/replay mode
  rather than current product mode), rewards claim, alpha purchase, build equip,
  crafting craft/crush-bones and guild create/join to v1 transactional RPCs
  with `game_saves`, `request_hash`, ruleset metadata, ledger/idempotency and
  service-role-only grants.
- Migration `202605300004_foundation_closeout.sql` corrects
  `ruleset_registry` to immutable `publication_id`, updates the active
  `foundation_ruleset_v0` simulator hash, persists ruleset hashes in
  `game_saves` and history rows, adds `state_version`/`season_context`, creates
  internal admin RPCs and promotes build spell behavior, potion equip/behavior,
  friend add and chat send to v1 transactional/idempotent RPCs.
- Edge Functions now enforce `x-draxos-api-version: 1` when the header is
  present, still tolerate absence during alpha, and reject other explicit
  values with `UNSUPPORTED_API_VERSION`.
- `foundation_ruleset_v0` is generated with content/simulator hashes and
  mirrored into server/supabase shared modules.
- `battle/request`, `battle/latest`, `battle/history` and `battle/replay` expose
  ruleset metadata for new battles/log reads, using row-persisted hashes for
  new rows and `FOUNDATION_RULESET` fallback only for old rows.
- `base/state`, `base/collect` and `base/upgrade` now use the Base transactional
  RPC path while preserving the current UI payload contract.
- `battle`, `build`, `crafting`, `monetization` and `social` adapters now
  compute canonical `request_hash`, resolve `game_saves` and call domain RPCs
  while preserving the current client payload shape where the UI depends on it.
- `server/tests/transactional_rpc_live_test.ts` now proves
  rollback/retry/idempotency against a reset local Supabase Postgres stack for
  battle rewards, build equip, crafting, reward claim, alpha purchase and guild
  create/join.
- `server/tests/transactional_edge_rpc_smoke.ts` now proves the local Edge
  Function HTTP path over the v1 RPC adapters for base, battle, build, crafting,
  monetization and social, including the Closeout endpoints
  `build/spell-behavior`, `build/potion/equip`, `build/potion-behavior`,
  `social/friends/add`, `social/chat/send` and API version failure.
- `server/functions/_shared/base_domain.ts`,
  `server/functions/_shared/battle_log_projection.ts`,
  `server/functions/_shared/battle_combatants.ts`,
  `server/functions/_shared/progression_domain.ts` and
  `server/functions/_shared/economy_domain.ts` continue the portable
  domain-service split with mirrored Supabase modules and Deno contract tests
  for Base rules/projection, saved battle log projection, battle player/bot
  combatant mapping, build payload/unlocks/equip validation, runtime power,
  battle helper projection, rewards/products and crafting/monetization
  source-sink payloads.
- Battle Lab Godot power display now matches the Battle Lab TypeScript runner
  weights, and `server/tests/lab_heuristics_contract_test.ts` guards Lab model
  IDs, Battle Lab power weights, Progression Lab profile/milestone selectors and
  ruleset model hashing. The same test now also keeps Lab generators
  offline/adapter-free, keeps the Progression Lab seeder local-only and blocks
  server runtime imports from dev Lab generators/screens.
- `DraxosOperationState` and `DraxosAppShellActionRouter` create client shell
  contracts without adding feature rules to `boot.gd`; the real action path now
  routes through the action router and busy/error state is scoped by operation.
- `SupabaseClient` sends API version and `request_hash`, while `SessionStore`
  persists pending idempotent mutations so retries reuse the same
  `request_id/request_hash`.
- `ROUTE_MINIGAME_SHELL` and `open_minigame_shell:<id>` exist only as a
  disabled/dev placeholder: no reward, ranking, economy, migration or public
  feature promise.
- `tools/check_foundation_expansion_readiness.ps1` is the read-only structural
  gate and is called from `validate_foundation.ps1`. Full profile now requires
  local Supabase RPC, Edge RPC and admin/RLS smokes instead of silently skipping
  them.

This package does not implement a new gameplay feature, new social loop or new
minigame. Remaining balance/content expansion should now start only after an
explicit package choice, with Lab heuristics treated as evidence instead of
runtime authority.

## Foundation Final Polish

Foundation Final Polish is the last hardening pass before tuning. It does not
add gameplay, economy, social expansion or minigame rewards. It was published
to Internal Alpha after explicit release approval on `2026-05-30`.

- Live docs now identify Foundation Closeout and Lab Track 16 Alignment as
  delivered; the final Full validation passed on the canonical local branch.
- New agents should branch locally from `codex/draxos-mobile/foundation-final-polish`
  at the final validated HEAD until a merge/push decision exists.
- `modes/boot/boot.gd` is a thin shell facade and
  `modes/boot/surfaces/hub_surface_presenter.gd` is a facade under automated
  line budgets in `validate_foundation.ps1`.
- `SessionStore` exposes read-only domain slices/snapshots, and touched
  presenters read those snapshots instead of public mutable dictionaries.
- Client source guards now block presenter calls to Supabase, direct telemetry,
  direct `SessionStore` mutations and direct `create_request_id()` outside the
  approved shell paths.
- `server/tests/foundation_admin_rls_live_smoke.ts` proves local RLS/admin:
  `anon/authenticated` cannot execute admin RPCs, `service_role` can lookup,
  reconcile, diagnose, adjust resources with ledger/audit/idempotency and flag
  accounts, and `admin_audit_log` is not client-readable.
- `validate_foundation.ps1 -Profile Full` includes local Supabase RPC, local
  Edge RPC and local admin/RLS smokes; if the local stack is not active, Full
  fails instead of skipping silently.
- Internal Alpha publication used release root
  `internal-alpha/v0-foundation-final-polish-20260530-8c658f6`, public
  Cloudflare preview
  `https://721dc985.draxos-mobile-internal-alpha.pages.dev/web/index.html`,
  public APK
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-final-polish-20260530-8c658f6/downloads/draxos-mobile-alpha.apk`
  and public PC ZIP
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-final-polish-20260530-8c658f6/downloads/draxos-mobile-alpha.zip`.
- Publication validation passed: `validate_foundation.ps1 -Profile Release`,
  export Android/PC/Web, `publish_internal_alpha.ps1 -Mode Plan`, `Package`,
  `Upload -ConfirmRemoteMutation`, Cloudflare Pages deploy, `DeployManifest
  -ConfirmRemoteMutation`, `release_manifest_smoke.ts`,
  `release_artifacts_remote_smoke.ts`, `internal_alpha_remote_smoke.ts` with
  release manifest check, and a direct preview shell check confirming
  `GODOT_CONFIG`, versioned Web asset root and `index.pck` size match.
- Known release risk: Android was exported with `debug_fallback` because no
  release keystore was configured in the local env used for publication.

Closeout validation on this branch:

- Deno check: `server/functions` PASS and `supabase/functions` PASS.
- Static foundation contract tests: PASS (`57` tests through
  `validate_foundation.ps1 -Profile Quick` before local Supabase/Edge gated
  steps).
- Godot validate: PASS (`132/132`, `2052` asserts) after the client shell retry
  changes.
- `supabase migration up --local`: PASS for
  `202605300004_foundation_closeout.sql`.
- `validate_foundation.ps1 -Profile Full`: PASS with local Supabase RPC and
  local Edge RPC smokes included.

Lab Track 16 Alignment validation on this branch:

- Battle Lab model/generator now emits Track 16 potion-enabled,
  potion-disabled and spell-behavior-disabled scenarios. The generated report is
  `REVIEW` because anti-stall rate is `6.4%` against the current lab threshold
  of `<=5%`; this is tuning evidence, not an automatic balance change.
- Progression Lab model/generator now emits healthy saves with `po_osso`,
  `craft_pocao_vida`, `pocao_vida`, potion slot state, inventory and spell
  behaviors, plus potion affordability, crafting pressure and preparation
  readiness artifacts.
- Progression Lab apply/seeding now preserves generated consumable, potion slot
  and spell behavior state for lab snapshots instead of wiping Track 16 state.
- Validation: `npx -y deno test tools/battle_lab tools/progression_lab` PASS,
  `npx -y deno test --allow-read server/tests/lab_heuristics_contract_test.ts`
  PASS, Deno check for `server/functions` and `supabase/functions` PASS, GUT
  client PASS (`132/132`, `2057` asserts), `tools/smoke_dev_labs.gd` PASS and
  `validate_foundation.ps1 -Profile Quick` PASS. The Quick gate caught and then
  confirmed the corrected `foundation_ruleset_v0` content hash mirrored in the
  Closeout migration seed.

Historical handoff: Foundation Final Polish unlocked the Arena PVE initial
package. That recommendation is now superseded by Track 18 being published;
use the Track 18 section and Next Step above for current work. Do not start
unrelated base builder, PVP, social or minigame work implicitly from the
Foundation Final Polish branch.

## Progression Clarity v1

Progression Clarity v1 is implemented and published as a client-only readability
layer over the existing account/build/battle snapshots. It does not change
backend, schema, migrations, simulator, rewards, economy, tuning, weapons,
spells or catalog content.

- Refugio now has a compact `Progresso` panel in the immersive home layout with
  level, power and the next visible milestone.
- Preparation now shows `Proximos marcos`, derived from current build state,
  lock reasons and known unlock levels.
- Battle summary now includes `Progresso`, showing current level/power, battle
  XP when present and the next milestone without claiming resource balances were
  refreshed.
- `modes/boot/surfaces/progression_clarity_presenter.gd` centralizes
  player-facing progression copy.
- `docs/progression-clarity-v1.md` is the live package note.
- Validation completed on `2026-05-29`: GUT client passed with `123/123` tests
  and `1984` asserts; `tools/smoke_foundation_loop.gd`,
  `tools/smoke_responsive_layout.gd`, `validate_foundation.ps1 -Profile Client`
  and `git diff --check` passed. `tools/smoke_foundation_surfaces.gd` remained
  blocked locally because Supabase local was unavailable.
- Progression Clarity v1 was published to Internal Alpha on `2026-05-29` with
  release root `internal-alpha/v0-progression-clarity-v1-20260529`, public
  Cloudflare Pages preview
  `https://3cf22c65.draxos-mobile-internal-alpha.pages.dev/web`, public APK
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-progression-clarity-v1-20260529/downloads/draxos-mobile-alpha.apk`
  and public PC ZIP
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-progression-clarity-v1-20260529/downloads/draxos-mobile-alpha.zip`.

## Battle Preparation Complete v1

Battle Preparation Complete v1 is implemented and published as the current
loadout package for the Refugio preparation hotspot. It promotes the previous
explanatory panel into a real pre-battle editor while keeping simulator, tuning,
economy, new content, migrations and advanced tactics out of scope.

- Refugio keeps the existing `Preparacao` hotspot and no new route was added.
- The Preparation panel now opens with `Pronto para batalha` and summarizes
  power, ritual instrument, equipped skills, doctrine, familiar, potion and
  simple behavior presets.
- The player can equip an instrument, equip/remove skills in positions 1/2/3,
  equip/remove doctrine, equip/remove familiar and keep potion/behavior controls
  from Track 16.
- The server implements `POST /build/equip`, validates catalog ids, unlock
  levels and duplicate skills, updates `builds` and recalculates
  `players.power`; the client never sends final power.
- `GET /build/state` returns enriched humanized equipment options and lock
  reasons so the UI does not need to show raw ids.
- Export presets now exclude `assets/referenciaimagens/**`, which is
  moodboard/reference only, reducing published APK/ZIP/PCK sizes enough for the
  current Storage/Pages flow.
- `docs/battle-preparation-complete-v1.md` is the live package note;
  `docs/battle-preparation-v1.md` is historical context.
- Battle Preparation Complete v1 was published to Internal Alpha on `2026-05-29`
  with public unlisted APK/PC downloads, a cache-busted Web asset root and
  verified public Cloudflare Pages preview
  `https://0fee1018.draxos-mobile-internal-alpha.pages.dev/web`.
- The Web package points to
  `internal-alpha/v0-battle-preparation-complete-v1-20260529/web`, with
  equip-feedback hotfix PCK
  `internal-alpha/v0-battle-preparation-complete-v1-20260529-hotfix4/web/index.pck`.

## Battle Presentation v1

Battle Presentation v1 is implemented as a client-only readability pass for the
real battle loop. It keeps the existing backend/API/schema, simulator, rewards,
ranking, economy, weapons, spells and `battle_log_v1` contract.

- `battle_running` stays fullscreen, without app chrome, inside
  `BattleSafeFrame`.
- Running battle now has a compact confrontation strip with player vs opponent,
  lance progress, current state and a touch-safe `Pular batalha` action.
- `BattleVisualMockup`, `BattleStage2D` and `BattleLogPresenter` now present
  damage, healing, consumable use, status, familiars, summons and battle result
  with player-facing language.
- `battle_summary` prioritizes the result, opponent, short outcome phrase,
  reward/resources/ranking when present and the primary CTA
  `Voltar e verificar base`.
- `battle_logs` remains read-only and scoped to the current battle, with logs
  formatted for players instead of technical inspection.
- `docs/battle-presentation-v1.md` is the live package note.
- Battle Presentation v1 was published to Internal Alpha on `2026-05-29` after
  explicit release approval. The publication updated Android APK, PC Windows
  ZIP, Web assets, the Cloudflare Pages package and portal copy without
  backend/schema/API changes.
- The public Web package now points to the cache-busted asset root
  `internal-alpha/v0-battle-presentation-20260529/web`.

## Battle Drama v1.1

Battle Drama v1.1 is implemented and published as the client-only follow-up
after Web review showed Battle Presentation v1 was technically updated but still
looked too much like a mock/debug arena.

- `BattleStage2D` now has stronger side lighting, clash focus, softer floor
  guides and less empty marker noise.
- `BattleActorMarker` now draws a larger robed combatant silhouette with staff,
  aura, barrier read and stronger pulse feedback.
- The current-lance callout is wider and more legible, with the event name and
  player-facing effect on the first line.
- Empty status/cooldown rows no longer render dash icons that read like debug
  placeholders.
- Familiar and summon markers are slightly larger while preserving tooltips and
  replay state.
- The compact battle readout now uses player-facing pressure language for life,
  effects, waits and allies.
- `docs/battle-drama-v1-1.md` is the live package note.
- Battle Drama v1.1 was published to Internal Alpha on `2026-05-29` from branch
  `codex/draxos-mobile/battle-drama-v1-1`.
- The verified public preview is
  `https://7261c476.draxos-mobile-internal-alpha.pages.dev/web/index.html`, and
  its Web shell points to `internal-alpha/v0-battle-drama-v1-1-20260529/web`.
- The stable Cloudflare Pages domain was redeployed, but public unauthenticated
  GET still returns the Cloudflare Access page; use the verified preview URL or
  an authenticated Access session for human Web review.

## Social Basico Guilda v1

Social Basico Guilda v1 is implemented as the next product package after the
confirmed Foundation baseline. It keeps the existing backend/API/schema and
focuses on making the current social loop usable by real testers:

- Social screen now highlights account identity, own username, social save badge
  and clear Friends/Guild/Chat sections.
- Copy/show own username is a local shell action; it does not touch the server.
- Friends by username, guild create/join, member list, read-only guild
  structures and guild chat keep the existing endpoints.
- Guild chat now has light auto-sync every 8s only while the Social screen is
  open, pausing outside Social, offline, without account/session, during another
  action or in local-only Progression Lab.
- Published Internal Alpha builds now include Social Basico Guilda v1. Realtime,
  direct chat, helps, guild contributions, chat global, moderation/report/block,
  invites, guild wars and backend/schema changes remain out of scope.

## Latest Technical Package

Track 16 added the first behavior/crafting/consumable package requested by the
user. It remains technical context and not the current product focus;
`docs/behavior-potion-crafting-v1.md` is the current live summary. Ossos
Inteiros v1 only promotes the subset needed to make the published alpha coherent
around whole-number Ossos.

- Ossos are represented as whole numbers in the new scale
  (`1 Osso atual = 0.01 Osso antigo`) and current economy/content/Progression
  Lab values were rescaled by `100`.
- `po_osso` was added as a whole-number resource, created by crushing Ossos.
- `pocao_vida` and `craft_pocao_vida` were added to content, crafting state and
  server-authoritative Edge Functions.
- Save-scoped `crafting/*` and `build/*` endpoints manage crafting, consumable
  inventory, potion slot and spell/potion behavior.
- Battle simulator supports spell behavior, `consumable_use`, one potion use per
  slot per battle and five `heal` ticks of `4%` max HP.
- Godot Base/Ossario and Refugio preparation panels expose crafting, potion
  equip/remove and simple behavior toggles.
- Battle Preparation Complete v1 is the published product surface for potion
  equip/remove and simple behavior controls; further potion, behavior, crafting,
  tuning or economy expansion still needs a new explicit package.

Ossos Inteiros v1 is now published on top of the Visual Direction v1 build. The
remote migration `202605280001_behavior_crafting.sql` is applied, Edge Functions
were redeployed, generated Grimoire catalogs now expose whole-number Ossos
values, and Base collection preserves sub-one Ossos accrual until at least `1`
whole Osso is collectable. This fixes the visible `0.1 osso` class of issue
without adding a new schema/API package beyond Track 16.

## Release Snapshot

| Artifact       |      Bytes | SHA256                                                             |
| -------------- | ---------: | ------------------------------------------------------------------ |
| Android APK    | `31649813` | `118cce77d40ebc2cefd73728e738244c6b3615c63d3efdcd2c88ade7eb05cc8a` |
| PC Windows ZIP | `40118021` | `0955e062e3831e9c952e4d40369682b92a4d03922c1904de44d3b0fc04636e0a` |
| Web index      |     `5442` | `ddd5061f0fc7b17907474fa577e90767d501f0a5b2b56d8ff6d0e2a71db2b858` |

Links:

- Supabase remote: `https://armxgipvnbbshzqawklw.supabase.co`
- Manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Stable portal:
  `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Stable Web: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Latest verified preview:
  `https://0fee1018.draxos-mobile-internal-alpha.pages.dev`
- Web asset root:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-preparation-complete-v1-20260529/web`
- Web hotfix pack:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-preparation-complete-v1-20260529-hotfix4/web/index.pck`

Battle Preparation Complete v1 was published to the Internal Alpha artifact/site
channel on `2026-05-29`. Android APK, PC ZIP and Web assets were uploaded to
`internal-alpha/v0-battle-preparation-complete-v1-20260529`; Web assets use the
versioned root so browser caches cannot reuse older `index.js`, `index.pck` or
`index.wasm` paths. Web hotfixes later republished the Cloudflare Pages shell at
`https://d8f2e0a7.draxos-mobile-internal-alpha.pages.dev/web`, using local
loader assets in Pages and hotfix PCK `4247612` bytes to avoid the exported
`content_generator.gd` preload parse error and to fix the Preparation popup
visual regression where Refugio/Batalhar showed through the panel. APK/PC
downloads are public unlisted Storage URLs. The stable Cloudflare Pages domain
remains behind Access for public unauthenticated checks. The Edge manifest
endpoint remains healthy, but the release override was not updated during this
publication because the local environment did not include
`SUPABASE_ACCESS_TOKEN`; the portal package reads its bundled
`manifest.example.json` for published links/hashes.

Preparation equip-feedback hotfix was published on `2026-05-29` after Web review
showed `Equipar` looked silent in the Preparation popup. The client now
keeps/reopens the Preparation panel after equip and behavior actions, shows
`Ultima escolha: ...`, refreshes the equipped item state, prunes stale popup
action buttons during refresh, and keeps `boot.gd` under the Track 12 shell
budget. Validation passed with GUT client (`122/122`),
`validate_foundation.ps1 -Profile Client`, `smoke_responsive_layout.gd`,
`smoke_foundation_loop.gd` and `git diff --check`.
`smoke_foundation_surfaces.gd` was blocked by `NETWORK_UNAVAILABLE` against
local Supabase, not by this change. Export/upload/deploy passed with hotfix PCK
`4242428` bytes, public APK/ZIP HEAD checks and Browser visual review confirming
a real `Equipar` click changes `Athame Hematico` to `Em uso` in the published
Web preview
`https://0fee1018.draxos-mobile-internal-alpha.pages.dev/web?cachebust=hotfix4`.

## Visual Direction v1

Visual Direction v1 is implemented and published as the next refinement package
after Social Basico Guilda v1. It did not change backend, schema, API, gameplay,
economy, content tuning or final art.

- `docs/visual-direction-v1.md` is the live direction document for this package.
- `core/ui_tokens.gd` now owns surface accents, action accents, CTA selection
  and shared panel/button style helpers.
- Entry, Refugio drawer actions, shell action buttons, output panels and
  Base/Social/Competition/Shop panels now use the same restrained surface accent
  contract.
- Touch targets, responsive frames, first-screen Refugio anchors and battle safe
  frames remain in the existing Foundation Responsive contract.

## Risks And Blocks

- Track 16 migration/functions/catalog changes needed for Ossos Inteiros v1 are
  deployed. Further crafting, behavior, tuning, economy or content expansion
  still needs its own explicit package decision.
- Foundation Loop UX Pass 01 is the accepted historical V0 app-shell UX
  baseline after manual Android/Windows/Web review on `2026-05-29`; Social
  Basico Guilda v1, Battle Presentation v1, Battle Drama v1.1 and Battle
  Preparation Complete v1 are now available in the published Internal Alpha
  build for human validation.
- Battle Preparation Complete v1 is published to Internal Alpha with public
  APK/PC downloads, a cache-busted Web asset root and no-store Cloudflare Pages
  headers; Web/mobile visual confirmation passed on the latest preview, while
  Android/Windows still need manual confirmation.
- Edge release manifest override needs `SUPABASE_ACCESS_TOKEN` available in the
  release environment for future
  `publish_internal_alpha.ps1 -Mode DeployManifest` runs. This publication kept
  the endpoint healthy and used the packaged portal manifest as the
  published-link source.
- Track 13 release safety remains the baseline for any future publication or
  wider-access gate.
- `players.save_type` remains as alpha compatibility only. `account_profiles` +
  `game_saves` now exists as the foundation model; future account/save features
  should not use `players.save_type` as primary authority.
- Progression/economy remains mock/substance and not the current tuning focus.
- Release scripts are safe by default; remote mutation remains opt-in with
  `-ConfirmRemoteMutation`.

## Next Step

Lab Web Export Guard is now the latest Internal Alpha publication:
`codex/draxos-mobile/lab-web-export-guard`, release root
`internal-alpha/v0-lab-web-export-guard-20260531-9a415c3`, preview
`https://fc60138d.draxos-mobile-internal-alpha.pages.dev/web/index.html`.
The next product step is human playtest and tuning notes for the Arena PVE
tutorial/3-duel loop, including potion consumption, remote arena selection,
buff selection, summary/claim behavior and the Web Lab guard. Do not open PVP,
victory prediction, opponent counter-picks, custom thresholds, enemy-specific
behavior, spell priorities, direct chat, helps, contributions, moderation,
tuning numbers, new weapons, new spells, economy, new potions, crafting
expansion or broader replay controls beyond the Arena PVE package without its
own package decision.

## Validation

Latest validation for Battle Preparation Complete v1 publication on
`2026-05-29`:

- `npx -y deno check server/functions/build/index.ts supabase/functions/build/index.ts server/tests/build_equip_smoke.ts`:
  PASS.
- `npx -y deno test --allow-read server/tests/foundation_contracts_test.ts`:
  PASS.
- Remote `server/tests/build_equip_smoke.ts`: PASS against Supabase Internal
  Alpha after `build` function deploy.
- GUT `tests/client`: PASS through `tools/validate.gd` (`121/121`).
- `tools/smoke_foundation_loop.gd`: PASS.
- `tools/smoke_responsive_layout.gd`: PASS.
- `tools/validate.gd`: PASS.
- `validate_foundation.ps1 -Profile Client`: PASS, including
  `tools/validate.gd`, GUT `tests/client`, runtime/hardening/responsive/export
  smokes and `git diff --check`.
- `tools/smoke_foundation_surfaces.gd`: BLOCKED at anonymous auth with
  `NETWORK_UNAVAILABLE`; local/remote backend availability is outside the
  client-only package.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export
  mode `debug_fallback`.
- `export_presets.cfg` now excludes `assets/referenciaimagens/**`, keeping
  moodboard assets out of runtime exports and reducing APK/ZIP/PCK below current
  upload limits.
- Supabase Storage bucket file limit was raised to `209715200` bytes for
  Internal Alpha release buckets.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: PASS for
  `internal-alpha/v0-battle-preparation-complete-v1-20260529`.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: PASS.
- Supabase Storage upload: PASS for versioned APK/ZIP/Web.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-preparation-complete-v1-20260529/web`:
  PASS.
- Cloudflare Pages deploy: PASS, verified preview
  `https://17ea0fa1.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`:
  BLOCKED before remote secret mutation because `SUPABASE_ACCESS_TOKEN` was not
  available.
- Preview GET checks: PASS for
  `https://17ea0fa1.draxos-mobile-internal-alpha.pages.dev/web` with versioned
  Web asset root and `GODOT_CONFIG.fileSizes.index.pck = 4247020`.
- Remote HEAD checks: PASS for versioned `index.pck` (`4247020` bytes),
  `index.wasm` (`37695054` bytes), Android APK (`31649813` bytes) and PC ZIP
  (`40118021` bytes), all without Bearer token.
- Web hotfix after visual review: PASS. `tools/validate.gd` passed (`121/121`),
  `tools/smoke_exports.gd` passed, `tools/check_release_safety.ps1` passed,
  `git diff --check` passed,
  `export_internal_alpha.ps1 -AllowAndroidDebugFallback` passed, hotfix
  `index.pck` uploaded to
  `internal-alpha/v0-battle-preparation-complete-v1-20260529-hotfix1/web/index.pck`
  (`4247356` bytes),
  `build_cloudflare_pages_package.ps1 -MainPackUrl <hotfix-pck>` passed,
  Cloudflare Pages deploy passed with preview
  `https://dc29916b.draxos-mobile-internal-alpha.pages.dev/web`, and Browser
  visual review confirmed the Preparation panel opens in Web/mobile with
  readable Instrumento, Habilidades, Doutrina, Familiar and Pocao sections.
- Preparation popup visual hotfix: PASS. GUT `tests/client` passed (`121/121`,
  `1941` asserts), `tools/smoke_responsive_layout.gd` passed, `git diff --check`
  passed, `export_internal_alpha.ps1 -AllowAndroidDebugFallback` passed, hotfix
  `index.pck` uploaded to
  `internal-alpha/v0-battle-preparation-complete-v1-20260529-hotfix3/web/index.pck`
  (`4247612` bytes), Cloudflare Pages deploy passed with preview
  `https://d8f2e0a7.draxos-mobile-internal-alpha.pages.dev/web`, public HEAD
  check confirmed the hotfix PCK, and Browser visual review confirmed the mobile
  Preparation popup is opaque/full-height and no longer exposes the Refugio
  `Batalhar` CTA behind it.

Latest validation for Battle Drama v1.1 publication on `2026-05-29`:

- One-time Godot `--headless --import`: PASS in fresh worktree.
- GUT `tests/client`: PASS (`119/119`, `1896` asserts).
- `tools/smoke_responsive_layout.gd`: PASS.
- `validate_foundation.ps1 -Profile Client`: PASS, including
  `tools/validate.gd`, GUT `tests/client`, runtime/hardening/responsive/export
  smokes and `git diff --check`.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export
  mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: PASS for
  `internal-alpha/v0-battle-drama-v1-1-20260529`.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -PublicDownloads -ConfirmRemoteMutation`:
  PASS for versioned Storage APK/ZIP/Web and portal manifest package.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-drama-v1-1-20260529/web`:
  PASS.
- Cloudflare Pages deploy: PASS, verified preview
  `https://7261c476.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`:
  BLOCKED before remote secret mutation because `SUPABASE_ACCESS_TOKEN` was not
  available.
- Preview GET checks: PASS for `/web/index.html` with versioned Web asset root
  and `GODOT_CONFIG.fileSizes.index.pck = 4230188`.
- Remote HEAD checks: PASS for versioned `index.js` (`315759` bytes),
  `index.pck` (`4230188` bytes), `index.wasm` (`37695054` bytes), Android APK
  (`31637525` bytes) and PC ZIP (`40103282` bytes), all without Bearer token.

Latest validation for Battle Presentation v1 publication on `2026-05-29`:

- One-time Godot `--headless --import`: PASS in fresh publication worktree.
- `validate_foundation.ps1 -Profile Client`: PASS, including
  `tools/validate.gd`, GUT `tests/client` (`119/119`, `1895` asserts),
  runtime/hardening/responsive/export smokes.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export
  mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: PASS for
  `internal-alpha/v0-battle-presentation-20260529`.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: PASS.
- Supabase Storage upload: PASS for
  `internal-alpha/v0-battle-presentation-20260529` and stable
  `internal-alpha/v0`.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-presentation-20260529/web`:
  PASS.
- Cloudflare Pages deploy: PASS, verified preview
  `https://2a470539.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`:
  BLOCKED before remote secret mutation because `SUPABASE_ACCESS_TOKEN` was not
  available; Edge manifest endpoint remained healthy and portal was adjusted to
  read bundled `manifest.example.json`.
- `server/tests/release_manifest_smoke.ts`: PASS against remote Supabase.
- `server/tests/internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS.
- Preview GET checks: PASS for `/portal/index.html`,
  `/portal/manifest.example.json` and `/web/index.html` with versioned Web asset
  root.
- Remote HEAD checks: PASS for versioned `index.js` (`315759` bytes),
  `index.pck` (`4227948` bytes), `index.wasm` (`37695054` bytes), versioned APK
  (`31633429` bytes) and stable APK (`31633429` bytes), all without Bearer
  token.

Latest validation for Ossos Inteiros v1 publication on `2026-05-29`:

- `npx -y deno test --allow-read server/tests/integer_bones_contract_test.ts`:
  PASS.
- `npx -y deno check server/functions/base/index.ts supabase/functions/base/index.ts server/functions/content/index.ts supabase/functions/content/index.ts server/tests/integer_bones_contract_test.ts`:
  PASS.
- `npx -y deno test --allow-read server/tests/foundation_contracts_test.ts server/tests/integer_bones_contract_test.ts`:
  PASS.
- `validate_foundation.ps1 -Profile Client`: PASS after one-time Godot import in
  the fresh worktree.
- `validate_foundation.ps1 -Profile Quick`: PASS after server config and smoke
  updates.
- Supabase remote migration push: PASS; local/remote migrations aligned through
  `202605280001_behavior_crafting.sql`.
- Supabase Edge Function deploy: PASS for gameplay/release functions touched by
  the package.
- Remote smokes: PASS for `base_manager_smoke.ts`,
  `monetization_rewards_smoke.ts`, `grimoire_catalog_smoke.ts` and
  `first_slice_battle_smoke.ts`.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export
  mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: PASS.
- Supabase Storage upload with CLI `2.98.0`: PASS for `internal-alpha/v0` and
  `internal-alpha/v0-integer-bones-20260529`.
- Cloudflare Pages deploy: PASS, preview
  `https://d7a31bf6.draxos-mobile-internal-alpha.pages.dev`.
- Supabase release manifest override + `release` function deploy: PASS.
- Remote release smokes: PASS for `release_manifest_smoke.ts`,
  `release_artifacts_remote_smoke.ts`, `internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`, and `grimoire_catalog_smoke.ts`.
- Direct APK HEAD without Bearer token: PASS, `200`, `31629333` bytes,
  `application/vnd.android.package-archive`.
- Cache-bust preview checks: PASS for `/portal/index.html` with public APK link,
  `/web/index.html` with `GODOT_CONFIG` and the versioned asset root, plus
  remote HEAD `200` for versioned `index.js`, `index.pck` and `index.wasm`.

Latest validation for Visual Direction v1 publication on `2026-05-29`:

- One-time Godot `--headless --import`: PASS in fresh publication worktree.
- `validate_foundation.ps1 -Profile Client`: PASS, including `git diff --check`,
  PowerShell parse, server/supabase mirrors, Deno release typecheck light,
  structural readiness, `tools/validate.gd`, GUT `tests/client` (`119/119`,
  `1880` asserts), `tools/smoke_runtime_config.gd`,
  `tools/smoke_foundation_hardening.gd`, `tools/smoke_responsive_layout.gd` and
  `tools/smoke_exports.gd`.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export
  mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan`: PASS.
- `publish_internal_alpha.ps1 -Mode Package`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- Cloudflare Pages deploy: PASS, preview
  `https://6a6ae522.draxos-mobile-internal-alpha.pages.dev`.
- Supabase Storage upload: PASS with Supabase CLI `2.98.0`, protected downloads
  enabled.
- Supabase release manifest override + `release` function deploy: PASS.
- `server/tests/release_manifest_smoke.ts`: PASS against remote Supabase.
- `server/tests/release_download_smoke.ts`: PASS with signed HEAD checks for
  Android and PC downloads.
- `server/tests/internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS.
- Preview GET checks: PASS for `/portal/index.html` (`Draxos Alpha`) and
  `/web/index.html` (`GODOT_CONFIG`).
- Web cache-bust hotfix after browser check: PASS.
  `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-web-20260529-visual-direction-v1 -ConfirmRemoteMutation`
  uploaded versioned Web assets,
  `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-web-20260529-visual-direction-v1/web`
  rewrote the loader URLs, and Cloudflare Pages deploy produced preview
  `https://5477aaf9.draxos-mobile-internal-alpha.pages.dev`.
- Cache-bust preview checks: PASS for `/portal/index.html` (`Draxos Alpha`),
  `/web/index.html` (`GODOT_CONFIG` and versioned asset root), and remote HEAD
  `200` for versioned `index.js`, `index.pck` and `index.wasm`.
- `tools/check_agent_ops_foundation.ps1`: PASS after status updates.
- `validate_foundation.ps1 -Profile Quick`: PASS after status updates.
- `git diff --check`: PASS.

Latest validation for Social Basico Guilda v1 publication on `2026-05-29`:

- `validate_foundation.ps1 -Profile Full`: PASS, including `tools/validate.gd`,
  GUT `tests/client` (`117/117`, `1857` asserts),
  runtime/hardening/responsive/export smokes, release typecheck, Track 13
  readiness and Track 14 agent ops checks.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export
  mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan`: PASS.
- `publish_internal_alpha.ps1 -Mode Package`: PASS.
- Cloudflare Pages deploy: PASS, preview
  `https://483a73f3.draxos-mobile-internal-alpha.pages.dev`.
- Supabase Storage upload: PASS, `25` files uploaded across public site assets
  and protected downloads.
- Supabase release manifest override + `release` function deploy: PASS.
- `server/tests/release_manifest_smoke.ts`: PASS against remote Supabase.
- `server/tests/release_download_smoke.ts`: PASS with signed HEAD checks for
  Android and PC downloads.
- `server/tests/internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS.
- Preview GET checks: PASS for `/portal/index.html` (`Draxos Alpha`) and
  `/web/index.html` (`GODOT_CONFIG`).
- `git diff --check`: PASS.
- `server/tests/release_artifacts_remote_smoke.ts`: unauthenticated artifact
  probe returns `401` for protected downloads by design; use
  `release_download_smoke.ts` for the signed download contract.

Latest validation for Battle Presentation v1 local merge on `2026-05-29`:

- GUT `tests/client`: PASS (`119/119`, `1895` asserts).
- `tools/smoke_mobile_presentation.gd`: PASS.
- `tools/smoke_responsive_layout.gd`: PASS, including `battle_running`,
  `battle_summary` and `battle_logs` at `360x800`, `390x844`, `1280x720` and
  `1920x1080`.
- `tools/smoke_foundation_loop.gd`: PASS.
- `tools/validate.gd`: PASS (`119/119`, `1895` asserts).
- `validate_foundation.ps1 -Profile Client`: PASS, including `git diff --check`,
  PowerShell parse, server/supabase mirrors, Deno release typecheck light,
  structural readiness, `tools/validate.gd`, GUT `tests/client`,
  `tools/smoke_runtime_config.gd`, `tools/smoke_foundation_hardening.gd`,
  `tools/smoke_responsive_layout.gd` and `tools/smoke_exports.gd`.
- `validate_foundation.ps1 -Profile Quick`: PASS after documentation/status
  updates.
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

Full release/backend validation remains available through
`validate_foundation.ps1 -Profile Full` when a gate needs it.

Note: on a fresh worktree, run the Godot `--import` step once before headless
smokes if global class names are not yet registered.

## Read Next

1. `../AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `docs/documentation-index.md`
4. `docs/foundation-app-v0-audit.md`
5. `docs/foundation-loop-audit.md`
6. `docs/pve-arena-initial-direction.md`
7. `docs/product-vision.md`
8. `docs/product-brief.md`
9. `docs/design-pending.md`
