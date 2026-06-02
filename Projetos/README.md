# Projetos

This directory contains active, conceptual and paused projects for the studio.

- Portfolio source of truth: `../08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Studio snapshot: `../08_Coordenacao_Agentes/Estado_Atual.md`
- Visual dashboard: `../08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Implementacao Ativa

- `draxos-roguelike-cardgame/`: menu-first Draxos roguelike cardgame with Track 02 complete for user playtest: fixed 29-map route, save v5, reward schedule/progression, universal relics, expanded Souls shop, keyword/status tooltips, keyword engine, enemy AI/intent, encounter modes, board formats, field effects, boss hooks, readability polish, pacing telemetry and validation green.
  - Priority/status: `P0_IMPLEMENTACAO`
  - Local agent guide: `draxos-roguelike-cardgame/AGENTS.md`
  - Operational status: `draxos-roguelike-cardgame/implementation/current-status.md`
  - Validation command: `draxos-roguelike-cardgame/tools/validate.gd`
  - Allowed work: code, validation, playtest, local documentation.
  - Current next step: user playtest of the Track 02 complete-run build.

## Implementacao - Arena PVE Inicial

- `draxos-mobile/`: mobile-first Draxos PVE Arena-first async autobattler with Refugio/Base, later PVP, social systems and server-authoritative progression. Platforms: Android app, PC executable and PC browser. Backend alpha: Supabase, with Backend Proprio + Postgres as the preferred long-term exit path. Web Launch Resilience is the latest remote Internal Alpha package and was human-validated on 2026-06-02 as functioning through the Web production flow. Release root: `internal-alpha/v0-web-launch-resilience-20260602-49dc5ea`; production URL: `https://draxos-mobile-internal-alpha.pages.dev`; deployment evidence: `https://9ba71c4e.draxos-mobile-internal-alpha.pages.dev`. The Web shell now embeds release/asset root diagnostics, cache-busts local Web assets by release root, shows a readable 20s splash watchdog, reports `engine.startGame` failures clearly and cleans old caches/service workers selectively when the release root changes without deleting Supabase session/localStorage data. Remote Chrome/CDP smoke on the preview hash left the splash in 6715 ms and captured `build/diagnostics/web-launch-remote-20260602-042353/web-launch-remote.png`; anonymous production fixed-domain reads can return Cloudflare Access, as expected. `index.pck` (`4611048`) and `index.wasm` (`37695054`) match remote `Content-Length`. No gameplay, backend, schema, migration, endpoint, economy, tuning, content or Reward Bridge change was added. Android APK uses `debug_fallback`, accepted for playtest while release signing is deferred to broader Android distribution. Refugio Visual Cleanup remains the previous visual package: release root `internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0`; Openworld QoL regression fix remains the previous functional package: release root `internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129`; Foundation Hardening V2 is the latest remote Internal Alpha baseline for hardening/live-doc gates and remains the previous hardening/multi-mode gate baseline for this package: release root `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`; Hardening Platform V1 remains the previous mode-platform baseline. Track 13 release safety and Track 14 agent ops remain preserved baselines. Track 21 Arena Loop Unlock/Friction remains the Autobattler/Arena PVE context; Web Battle Lab/Progression Lab remain served by Edge Function `lab-runner` behind the same Supabase email/password alpha account gate.
  - Priority/status: `P2_IMPLEMENTACAO - WEB_LAUNCH_RESILIENCE_PUBLISHED_INTERNAL_ALPHA`
  - Canonical local base for new work after integration: updated `master`; branch mode work from a dedicated worktree using `docs/multi-agent-workflow.md`.
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
  - Active foundation package: `draxos-mobile/implementation/tracks/track-17-foundation-expansion-readiness/`
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
  - Current next step: Web Launch Resilience is closed after human confirmation; decide the next dedicated visual cleanup package or resume Openworld functional playtest from updated `master`.

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
