# Projetos

This directory contains active, conceptual and paused projects for the studio.

- Portfolio source of truth: `../08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Studio snapshot: `../08_Coordenacao_Agentes/Estado_Atual.md`
- Visual dashboard: `../08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Implementacao Ativa

- `draxos-roguelike-cardgame/`: menu-first Draxos roguelike cardgame with Track 02 complete for user playtest: fixed 29-map route, save v5, reward schedule/progression, universal relics, expanded Souls shop, canonical keyword/status tooltips, full keyword engine, promoted class reward cards, elemental enemy galleries, hybrid enemy AI/intent, encounter modes, board formats, field effects, boss hooks, UI readability polish, modular tests, internal foundation directors/services for enemy AI/intent, combat/damage, rewards, Souls shop and BattleRoot presenters, idempotent generated catalog, shared route pacing simulator, AutoRun Gate Pack V1 JSON/CSV/Markdown reports with macro policies, official smoke/quick baselines, explicit gate mode, scorecards, statistical baseline and golden comparison, Scenario Fixtures V1 with `track02_core_v1` deterministic named scenarios, Gameplay Lab V1 with `track02_battle_core_v1` isolated real BattleEngine cases and deterministic legal-action policies, Lab Diff Reporter V1 before/after comparison for AutoRun/Scenario/Battle outputs, Card Impact Pack V1/V2/V3/V4/V4.1/V4.2/V5 with `track02_card_impact_v1`, `track02_card_impact_v2`, `track02_card_impact_v3`, `track02_card_impact_v4`, `track02_card_impact_v4_1`, `track02_card_impact_v4_2` and `track02_card_impact_v5` covering V4/V4.1/V4.2/V5 full active player matrix of 108 player variants plus 30 active enemy cards and 15 audited legacy inactive elemental cards, required player-card effect signatures, V3 isolated target capture, V4 temporary ability power utility signatures, V4.1 card-flow observability for draw/deck/hand/discard deltas, V4.2 explicit card-flow expectations for Colheita variants, V5 required enemy causal signatures, non-damage/enemy derived deltas, support-card contamination reporting and enemy signature quality reporting, Card Impact Smoke Tuning V1, Card Redesign Batch 01, Player Card Redesign Batch 02, Reward Card Redesign Batch 01 Using V4, Reward Card Redesign Batch 02 Utility Using V4, Card Flow Redesign Batch 01 Using V4.1, Enemy Card Redesign Batch 01 Using V5 and Enemy Card Redesign Batch 02 Using V5 Terra before/change/after/compare cycles applied to small card batches, latest accepted V5 enemy batch covering 2 Terra enemy-card changes with 30/30 enemy signatures and 21/21 card-flow checks passing, PASS/WARN/FAIL expectations and JSON/CSV/Markdown reports, foundation closeout/architecture ownership docs, playtest checklist, full-route pacing telemetry and validation green.
  - Card Impact V4 addendum: `track02_card_impact_v4` adds `player_scope=full_active_player_v1`, full active player-card coverage across starter/core/reward cards, class/source coverage summaries, temporary ability power utility signatures and validated 108 player / 30 enemy report-only / 15 legacy inactive coverage with zero structural errors.
  - Card Impact V4.1 addendum: `track02_card_impact_v4_1` preserves V4 coverage and adds card-flow quality/signature coverage for `necro_colheita_das_almas`, `necro_colheita_das_almas_lvl2` and `necro_colheita_das_almas_lvl3`, including `cards_drawn`, `deck_delta`, `hand_delta`, `card_flow_expected`, `card_flow_observed`, Markdown Card Flow Coverage and a lab-only dead-unit prestate for the lvl3 threshold case.
  - Card Impact V4.2 addendum: `track02_card_impact_v4_2` preserves V4.1 coverage and promotes Colheita card-flow into explicit required/watch expectations; same/same before/after/compare passed with 108 player / 30 enemy report-only / 15 legacy inactive coverage, 3 expected card-flow cards and 21/21 expectation checks passing.
  - Card Impact V5 addendum: `track02_card_impact_v5` preserves V4.2 player/card-flow coverage and promotes 30 active enemy cards to required causal signatures; same/same before/after/compare passed with 108 player / 30 enemy required / 15 legacy inactive coverage, 30/30 enemy cards played, 30/30 enemy signatures present, 30 clean signatures and 21/21 Card Flow Expectations passing.
  - Design Lab V1 addendum: `tools/run_design_lab.gd` adds proposal-pack driven lab-only content exploration with `data/lab/design/` mechanic registry/scoring profiles/proposals, in-memory overlay catalog, deterministic grid variants, player/enemy BattleEngine contexts, ranking classifications and `promotion_manifest.json`; sample gate `design_lab_sample_v1` passed with 36 candidates, 3 recommendations and no official catalog mutation.
  - Enemy Card Redesign Batch 01 V5 addendum: six Gelo/Ar/Fogo enemy-card changes passed V5 before/change/after/compare at `user://card_impact/enemy_card_redesign_batch_01_v5` with 6 changed enemy records, 17 metric/effect changes, zero structural errors/status changes/new failures/removed records and 21/21 Card Flow Expectations passing; an unsafe Terra probe was removed after Battle Lab caught Arcano duel/boss regressions.
  - Enemy Card Redesign Batch 02 V5 Terra addendum: two focused Terra enemy-card changes passed V5 before/change/after/compare at `user://card_impact/enemy_card_redesign_batch_02_v5_terra` with `enemy_terra_elemental_tita` attack `3 -> 2`, `enemy_terra_elemental_granito` health `7 -> 8`, 2 changed enemy records, 4 effect changes, zero structural errors/status changes/new failures/removed records and 21/21 Card Flow Expectations passing.
  - Reward Card Redesign Batch 03 V4.2 addendum: twelve reward/card-upgrade variants across Arcano, Invocador and Necromante changed under V4.2; compare passed with 12 impacted target cards, 18 effect changes, zero structural errors/status changes/new failures/removed records, and 21/21 Card Flow Expectations still passing.
  - Card Flow Redesign Batch 01 V4.1 addendum: `draw_if_at_least` now resolves as a bonus draw after normal hand refill; `necro_colheita_das_almas_lvl2` gained `draw_if_at_least=3` and moved Ashes `2 -> 3`; compare passed with 3 changed battle records, 11 effect deltas, zero structural errors/status changes, and Scenario/Run Lab unchanged.
  - Reward Card Redesign Batch 02 Utility V4 addendum: four utility/control/economy variants changed under V4 (`arcano_acelerar_lvl3`, `arcano_vortice`, `arcano_vortice_lvl2`, `necro_colheita_das_almas`); compare passed with 4 changed battle records, 7 metric/effect deltas, zero structural errors/status changes, and Scenario/Run Lab unchanged.
  - Player Card Redesign Batch 02 addendum: six core player upgrades changed under V3 (`arcano_acelerar_lvl2`, `arcano_bola_de_fogo_lvl2`, `invocador_batedor_lvl2`, `invocador_guardiao_lvl2`, `necro_prender_lvl3`, `necro_zumbi_lvl2`); compare passed with 14 metric deltas, 13 effect deltas, zero structural errors/status changes, and macro gates unchanged.
  - Priority/status: `P0_IMPLEMENTACAO`
  - Local agent guide: `draxos-roguelike-cardgame/AGENTS.md`
  - Operational status: `draxos-roguelike-cardgame/implementation/current-status.md`
  - AutoRun Lab: `draxos-roguelike-cardgame/docs/autorun-lab.md`
  - Design Lab: `draxos-roguelike-cardgame/docs/design-lab.md`
  - Validation command: `draxos-roguelike-cardgame/tools/validate.gd`
  - Allowed work: code, validation, playtest, local documentation.
  - Current next step: author player/enemy card and mechanic ideas as Design Lab proposal packs, tune candidates to viable/recommended, then promote manually and protect promoted content with Card Impact V4.2/V5 plus Run Lab gates before full-run feel playtests.

- `FpsShooter/`: independent PC Windows editor-first Godot 4.6.2 first-person shooter tech probe with a light Draxos visual theme. The first contract is a traditional FPS baseline in a local 1x1 arena against a basic bot. Track 01A Feel/Feedback V1 is complete on top of the bootstrap: agile movement defaults, simple hitscan rifle, HUD crosshair/health bars, hit/miss feedback, damage overlay, round-end feedback, runtime primitive muzzle/tracer/impact effects, synthetic audio and a short bot shot tell.
  - Priority/status: `P2_IMPLEMENTACAO - FPS_SHOOTER_TRACK_01A_FEEL_FEEDBACK_COMPLETE`
  - Local agent guide: `FpsShooter/AGENTS.md`
  - Operational status: `FpsShooter/implementation/current-status.md`
  - Work plan: `FpsShooter/docs/work-plan.md`
  - Reuse map: `FpsShooter/docs/reuse-map.md`
  - Validation reference: `FpsShooter/docs/validation.md`
  - Validation command: `FpsShooter/tools/validate.gd`
  - Allowed work: code, validation, editor playtest and local documentation.
  - Current next step: run the 3-minute editor human smoke for Track 01A and select the next Track 01 focus: arena layout, bot duel behavior or future weapon/projectile variants.

## Implementacao - Arena PVE Inicial

- `draxos-mobile/`: mobile-first Draxos PVE Arena-first async autobattler with Refugio/Base, later PVP, social systems and server-authoritative progression. Platforms: Android app, PC executable and PC browser. Backend alpha: Supabase, with Backend Proprio + Postgres as the preferred long-term exit path. The latest remote Internal Alpha package is `Bosque Overlay Navigation Hotfix v1` from 2026-06-09. Release root: `internal-alpha/v0-bosque-overlay-navigation-hotfix-v1-20260609-9b93e5d`; official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`; direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`; deployment evidence: `https://92cc0579.draxos-mobile-internal-alpha.pages.dev`. The package bumps APK/manifest to `0.0.18-alpha.0` / version code `18`, keeps minimum supported version code `13`, deploys `release`, and keeps the Bosque alive and visible behind Arena/Base/Shop/Social/Profile overlays while world input is paused and `Fechar`/back/Esc return to the same Bosque node without rebootstrap. Fabio reported the initial human playtest OK on 2026-06-09. Bosque Persistent Overlay Shell v1 remains the previous overlay package. Bosque Diegetic Launcher Foundation v1 remains the previous launcher package. Arena PVE Bonus Visual v1 remains the previous Arena package. Bosque Node Cooldown ACK v1 remains the previous Bosque persistence/spawn package. Bosque Resume Exit Lifecycle v1 remains the previous resume/exit package. Bosque Feel & Spawn Authority v1 remains the previous feel/spawn package. Bosque Persistence Rebase v1 remains the previous persistence/operations package. Track 13 release safety and Track 14 agent ops remain preserved operational baselines. Remote manifest smoke, remote artifact smoke, release/CORS smoke and remote Web launch smoke passed; preview loaded the game with release root matched and no runtime errors. Stable Portal/Web are Cloudflare Access protected. Android APK uses `debug_fallback`, accepted for playtest while release signing is deferred to broader Android distribution.
  - Priority/status: `P2_IMPLEMENTACAO - BOSQUE_OVERLAY_NAVIGATION_HOTFIX_V1_PUBLISHED_INTERNAL_ALPHA`
  - Canonical local base for new work after integration: updated `main`; branch mode work from a dedicated worktree using `docs/multi-agent-workflow.md`.
  - Current published package: `Bosque Overlay Navigation Hotfix v1`, release root `internal-alpha/v0-bosque-overlay-navigation-hotfix-v1-20260609-9b93e5d`, preview `https://92cc0579.draxos-mobile-internal-alpha.pages.dev`; fixes overlay `Fechar`, `Voltar`/back and Esc over the live Bosque, pauses world input behind overlays, version code `18`, Web/APK new package and redeployed `release`. Previous overlay package: Bosque Persistent Overlay Shell v1, release root `internal-alpha/v0-bosque-persistent-overlay-shell-v1-20260609-d05081c`, preview `https://a53c1d27.draxos-mobile-internal-alpha.pages.dev`. Previous launcher package: Bosque Diegetic Launcher Foundation v1, release root `internal-alpha/v0-bosque-diegetic-launcher-foundation-v1-20260609-e55ed0c`, preview `https://56b58162.draxos-mobile-internal-alpha.pages.dev`. Previous bootstrap package: Bosque Bootstrap Authority v1, release root `internal-alpha/v0-bosque-bootstrap-authority-v1-20260609-ba99e70`, preview `https://0123894f.draxos-mobile-internal-alpha.pages.dev`. Previous Arena package: Arena PVE Bonus Visual v1, release root `internal-alpha/v0-arena-pve-bonus-visual-v1-20260608-e281d63`, preview `https://6c8bf8e1.draxos-mobile-internal-alpha.pages.dev`. Previous Bosque package: Bosque Node Cooldown ACK v1, release root `internal-alpha/v0-bosque-node-cooldown-ack-v1-20260608-626b4ad`, preview `https://5cce952e.draxos-mobile-internal-alpha.pages.dev`. Previous resume/exit package: Bosque Resume Exit Lifecycle v1, release root `internal-alpha/v0-bosque-resume-exit-lifecycle-v1-20260608-9a0f7c0`, preview `https://39128c59.draxos-mobile-internal-alpha.pages.dev`. Previous feel/spawn package: Bosque Feel & Spawn Authority v1, release root `internal-alpha/v0-bosque-feel-spawn-authority-v1-20260608-70b79c3`, preview `https://16ac3cb7.draxos-mobile-internal-alpha.pages.dev`. Previous persistence/operations package: Bosque Persistence Rebase v1, release root `internal-alpha/v0-bosque-persistence-rebase-v1-20260608-bc23f74`, preview `https://0c0a8dcf.draxos-mobile-internal-alpha.pages.dev`.
  - Local agent guide: `draxos-mobile/AGENTS.md`
  - Agent manual: `draxos-mobile/docs/agent-operating-manual.md`
  - Documentation index: `draxos-mobile/docs/documentation-index.md`
  - Foundation Audit: `draxos-mobile/docs/foundation-app-v0-audit.md`
  - Foundation Expansion Readiness: `draxos-mobile/docs/foundation-expansion-readiness.md`
  - Foundation Loop Audit: `draxos-mobile/docs/foundation-loop-audit.md`
  - Responsive layout contract: `draxos-mobile/docs/foundation-responsive-layout-contract.md`
  - Visual Direction v1: `draxos-mobile/docs/visual-direction-v1.md`
  - Battle Presentation v1: `draxos-mobile/docs/battle-presentation-v1.md`
  - Battle Drama v1.1: `draxos-mobile/docs/battle-drama-v1-1.md`
  - Battle Preparation Complete v1: `draxos-mobile/docs/battle-preparation-complete-v1.md`
  - Behavior/Potion Crafting v1: `draxos-mobile/docs/behavior-potion-crafting-v1.md`
  - Progression Clarity v1: `draxos-mobile/docs/progression-clarity-v1.md`
  - First Session Clarity v1: `draxos-mobile/docs/first-session-clarity-v1.md`
  - Operational status: `draxos-mobile/implementation/current-status.md`
  - Product vision: `draxos-mobile/docs/product-vision.md`
  - PVE Arena initial direction: `draxos-mobile/docs/pve-arena-initial-direction.md`
  - Product brief: `draxos-mobile/docs/product-brief.md`
  - GDD: `draxos-mobile/docs/game-design-document.md`
  - Design pending: `draxos-mobile/docs/design-pending.md`
  - Contracts: `draxos-mobile/docs/contracts/`
  - Lab heuristics contract: `draxos-mobile/docs/contracts/lab-heuristics.md`
  - Latest technical package: `draxos-mobile/implementation/tracks/track-16-behavior-crafting/`
  - Foundation expansion history: `draxos-mobile/implementation/tracks/track-17-foundation-expansion-readiness/`
  - Agent foundation: `draxos-mobile/implementation/tracks/track-14-agent-ops-foundation/`
  - Release safety baseline: `draxos-mobile/implementation/tracks/track-13-validation-release-safety/`
  - Hardening Platform V1 readiness: `draxos-mobile/docs/hardening-platform-v1-readiness-report.md`
  - Foundation Hardening V2 readiness: `draxos-mobile/docs/foundation-hardening-v2-readiness-report.md`
  - Manual walkthrough gate: `draxos-mobile/docs/track-13-manual-walkthrough-gate.md`
  - Internal Alpha handoff: `draxos-mobile/docs/internal-alpha-v0-handoff.md`
  - Release ops: `draxos-mobile/docs/release-ops-checklist.md`
  - Progression Lab: `draxos-mobile/docs/progression-lab/README.md`
  - Battle Lab: `draxos-mobile/docs/battle-lab/README.md`
  - Design archive: `_conceitos/mobile-universe/`
  - Allowed work: code, design, documentation, infrastructure setup.
  - Current next step: focused human playtest of the published Bosque Overlay Navigation Hotfix v1 Web/APK package; future bugs return to the normal bugfix flow if they appear.

## Arquivo De Design

- `_conceitos/mobile-universe/`: design archive for DraxosMobile. Promoted to `draxos-mobile/` on `2026-05-18`; preserved only as reference.
  - Priority/status: `ARQUIVO_DESIGN`
  - Historical GDD: `_conceitos/mobile-universe/gdd.md`
  - Historical decisions: `_conceitos/mobile-universe/pendencias.md`
  - Allowed work: read-only design reference.

## Pausados Por Tempo Indeterminado

- `rpg-isometrico/`: campaign-first isometric action RPG.
  - Priority/status: `PAUSADO_INDEFINIDO`
  - Local agent guide: `rpg-isometrico/AGENTS.md`
  - Operational status: `rpg-isometrico/implementation/current-status.md`
  - Validation reference: `rpg-isometrico/docs/validation.md`
  - Allowed work: historical/contextual consultation only, unless the user explicitly asks to resume work.

- `rpg-turnos/`: provisional turn-based RPG-cardgame with independent mechanics and shared lore context.
  - Priority/status: `PAUSADO_INDEFINIDO`
  - Local agent guide: `rpg-turnos/AGENTS.md`
  - Operational status: `rpg-turnos/implementation/current-status.md`
  - Validation command: `rpg-turnos/tools/validate.gd`
  - Allowed work: historical/contextual consultation only, unless the user explicitly asks to resume work.

## Project Disambiguation

- Use `draxos-roguelike-cardgame/` for the current P0 implementation focus: roguelike cardgame, ship hub, run map, complete-run route, Souls, relics, keyword engine, enemy intent and lane battles.
- Use `draxos-mobile/` for DraxosMobile implementation: Godot mobile/PC/browser client, Supabase, Arena PVE-first async autobattler, Base, later PVP/social, Internal Alpha, release ops, validation and agent foundation.
- Use `FpsShooter/` for the independent FPS tech probe: PC Windows editor-first, first-person controller, arena 1x1, bot shooter, hitscan, knockback, jump pads/platforms/void in future tracks, and light Draxos visual theme only.
- Use `_conceitos/mobile-universe/` only as design reference for DraxosMobile.
- Use `rpg-isometrico/` only for explicit historical/contextual consultation about the isometric action RPG.
- Use `rpg-turnos/` only for explicit historical/contextual consultation about the 2D turn-based RPG-cardgame.

`Draxos` alone is shared vocabulary and does not select a paused project. Prefer portfolio priority, explicit project name and operational terms above.

## Agent Rule

Before working in a project, read:

1. `../08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. the workspace `AGENTS.md`
3. this registry
4. the relevant section of `../08_Coordenacao_Agentes/Estado_Atual.md`
5. the target project's local `AGENTS.md` and current status if the portfolio status allows the requested work

Multi-agent default:

- Use a dedicated worktree outside `D:\Estudio`: `D:\Estudio-worktrees\<projeto>--<agente>--<slug>`.
- Use branch `codex/<projeto>/<slug>` for Codex or `<agente>/<projeto>/<slug>` for non-Codex agents.
- Register branch, worktree, objective, intended files, base docs read and validation plan in Kanban/Doing or Handoffs before editing.
- Commit each logical stage separately.
- Before editing shared portfolio/canon/coordination files, check `git status --short`, `git worktree list` and coordination docs.
- Do not edit another agent's worktree unless the user explicitly asks for that intervention.

## Future Projects

A future project under `Projetos/` becomes an official implementation project only when it has:

- a local `AGENTS.md`;
- a local `implementation/current-status.md`;
- an entry in this registry outside `_conceitos/`;
- a summary entry in `../08_Coordenacao_Agentes/Estado_Atual.md`.

Until then, treat it as experimental, conceptual or preparatory material.
