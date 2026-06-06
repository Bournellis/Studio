# Projetos

This directory contains active, conceptual and paused projects for the studio.

- Portfolio source of truth: `../08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Studio snapshot: `../08_Coordenacao_Agentes/Estado_Atual.md`
- Visual dashboard: `../08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Implementacao Ativa

- `draxos-roguelike-cardgame/`: menu-first Draxos roguelike cardgame with Track 02 complete for user playtest: fixed 29-map route, save v5, reward schedule/progression, universal relics, expanded Souls shop, canonical keyword/status tooltips, full keyword engine, promoted class reward cards, elemental enemy galleries, hybrid enemy AI/intent, encounter modes, board formats, field effects, boss hooks, UI readability polish, modular tests, internal foundation directors/services for enemy AI/intent, combat/damage, rewards, Souls shop and BattleRoot presenters, idempotent generated catalog, shared route pacing simulator, AutoRun Gate Pack V1 JSON/CSV/Markdown reports with macro policies, official smoke/quick baselines, explicit gate mode, scorecards, statistical baseline and golden comparison, Scenario Fixtures V1 with `track02_core_v1` deterministic named scenarios, Gameplay Lab V1 with `track02_battle_core_v1` isolated real BattleEngine cases and deterministic legal-action policies, Lab Diff Reporter V1 before/after comparison for AutoRun/Scenario/Battle outputs, Card Impact Pack V1/V2 with `track02_card_impact_v1` and `track02_card_impact_v2` covering 84 active card cases plus 15 audited legacy inactive elemental cards, V2 required player-card effect signatures, non-damage derived deltas, support-card contamination reporting and report-only enemy signature schema, first Card Impact Smoke Tuning V1 and Card Redesign Batch 01 before/change/after/compare cycles applied to small card batches, Batch 01 damage-harness calibration and Arcano effect deltas, PASS/WARN/FAIL expectations and JSON/CSV/Markdown reports, foundation closeout/architecture ownership docs, playtest checklist, full-route pacing telemetry and validation green.
  - Priority/status: `P0_IMPLEMENTACAO`
  - Local agent guide: `draxos-roguelike-cardgame/AGENTS.md`
  - Operational status: `draxos-roguelike-cardgame/implementation/current-status.md`
  - AutoRun Lab: `draxos-roguelike-cardgame/docs/autorun-lab.md`
  - Validation command: `draxos-roguelike-cardgame/tools/validate.gd`
  - Allowed work: code, validation, playtest, local documentation.
  - Current next step: reduce `card_focus_legal` ambiguity with isolated target-card capture before broad card redesigns; Track 02 remains ready for user playtest of the complete-run build.

## Implementacao - Arena PVE Inicial

- `draxos-mobile/`: mobile-first Draxos PVE Arena-first async autobattler with Refugio/Base, later PVP, social systems and server-authoritative progression. Platforms: Android app, PC executable and PC browser. Backend alpha: Supabase, with Backend Proprio + Postgres as the preferred long-term exit path. The latest remote Internal Alpha package is `Bosque Sync Responsiveness v1` from 2026-06-05. Release root: `internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95`; official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`; direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`; deployment evidence: `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`. The package applies remote migration `202606050003_openworld_bosque_collect_batch_v1.sql`, bumps APK/manifest to `0.0.3-alpha.0` / version code `3`, restores Bosque collection/deposit/craft local-first responsiveness via `collect_batch` and keeps completion/reward server-authoritative. Arena/Bosque Visible V2 remains the previous visible package (`internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5`, evidence `https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev`). Arena/Bosque Regression Hotfix, Arena PVE Season 1 Loop v1, Arena Duel Flow Hotfix, Arena PVE First Real Run + Update Recovery, Bosque v3 UX/Feel, Technical Hardening and Openworld Main Menu Sync remain preserved previous packages. Export, public Storage upload, Cloudflare Pages production branch `main`, release manifest, Edge Function `release` deploy, remote artifacts smoke, remote Web launch smoke and read-only release/CORS smoke passed; preview loaded the game with release root matched and no runtime errors. Stable Portal/Web are Cloudflare Access protected. Android APK uses `debug_fallback`, accepted for playtest while release signing is deferred to broader Android distribution. Track 13 release safety and Track 14 agent ops remain preserved baselines.
  - Priority/status: `P2_IMPLEMENTACAO - BOSQUE_SYNC_RESPONSIVENESS_V1_PUBLISHED_INTERNAL_ALPHA`
  - Canonical local base for new work after integration: updated `main`; branch mode work from a dedicated worktree using `docs/multi-agent-workflow.md`.
  - Current published package: `Bosque Sync Responsiveness v1`, release root `internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95`, preview `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`; applies `collect_batch`, version code `3`, Web/APK new package and preserves Arena/Bosque Visible V2 as previous visible package. Previous visible package: Arena/Bosque Visible V2, release root `internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5`, preview `https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev`. Previous Season 1 package: Arena PVE Season 1 Loop v1, release root `internal-alpha/v0-arena-pve-season1-loop-v1-20260605-c8baf32`, preview `https://d7333659.draxos-mobile-internal-alpha.pages.dev`. Previous duel-flow hotfix package: Arena Duel Flow Hotfix, release root `internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174`, preview `https://0536635b.draxos-mobile-internal-alpha.pages.dev`. Previous Arena package: Arena PVE First Real Run + Update Recovery, release root `internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a`, preview `https://2c020d09.draxos-mobile-internal-alpha.pages.dev`.
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
  - Current next step: human playtest of published Bosque Sync Responsiveness v1: collect 10+ resources quickly, deposit during pending sync, craft, leave/reopen, confirm persistence of pocket/chest/nodes, and recheck Arena Preparacao plus buff -> Resolver duelo regressions.

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
