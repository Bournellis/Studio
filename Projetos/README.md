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

## Implementacao - Social Basico Publicado

- `draxos-mobile/`: mobile-first Draxos async PVP autobattler with Refugio/Base, social systems and server-authoritative progression. Platforms: Android app, PC executable and PC browser. Backend alpha: Supabase, with Backend Proprio + Postgres as the preferred long-term exit path. Track 13 release safety and Track 14 agent ops are preserved baselines, Track 00-15 are integrated, and Track 16 is the latest technical package. The confirmed Foundation post-login loop remains the accepted baseline: Base -> collect resources -> evolve base -> battle -> receive rewards -> check base again. Foundation Loop UX Pass 01 is implemented, published to Internal Alpha and manually confirmed on Android/Windows/Web on 2026-05-29, including initial-menu Battle Lab/Progression Lab visibility, contained Refugio/Battle screens, APK download without Bearer-token error, static battle-request splash and clear post-login loop. Social Basico Guilda v1 is published on top of that baseline with clearer Social identity, username copy action, Friends/Guild/Chat sections and 8s auto-sync while Social stays open, without backend/schema changes. Visual Direction v1 is implemented locally with surface/action accents, centralized CTA style and panel accents in `core/ui_tokens.gd`, documented in `docs/visual-direction-v1.md`; it is not remotely published yet.
  - Priority/status: `P2_IMPLEMENTACAO - VISUAL_DIRECTION_V1_IMPLEMENTED`
  - Local agent guide: `draxos-mobile/AGENTS.md`
  - Agent manual: `draxos-mobile/docs/agent-operating-manual.md`
  - Documentation index: `draxos-mobile/docs/documentation-index.md`
  - Foundation Audit: `draxos-mobile/docs/foundation-app-v0-audit.md`
  - Foundation Loop Audit: `draxos-mobile/docs/foundation-loop-audit.md`
  - Responsive layout contract: `draxos-mobile/docs/foundation-responsive-layout-contract.md`
  - Visual Direction v1: `draxos-mobile/docs/visual-direction-v1.md`
  - Operational status: `draxos-mobile/implementation/current-status.md`
  - Product vision: `draxos-mobile/docs/product-vision.md`
  - Product brief: `draxos-mobile/docs/product-brief.md`
  - GDD: `draxos-mobile/docs/game-design-document.md`
  - Design pending: `draxos-mobile/docs/design-pending.md`
  - Contracts: `draxos-mobile/docs/contracts/`
  - Latest technical package: `draxos-mobile/implementation/tracks/track-16-behavior-crafting/`
  - Agent foundation: `draxos-mobile/implementation/tracks/track-14-agent-ops-foundation/`
  - Release safety baseline: `draxos-mobile/implementation/tracks/track-13-validation-release-safety/`
  - Manual walkthrough gate: `draxos-mobile/docs/track-13-manual-walkthrough-gate.md`
  - Internal Alpha handoff: `draxos-mobile/docs/internal-alpha-v0-handoff.md`
  - Release ops: `draxos-mobile/docs/release-ops-checklist.md`
  - Progression Lab: `draxos-mobile/docs/progression-lab/README.md`
  - Design archive: `_conceitos/mobile-universe/`
  - Allowed work: code, design, documentation, infrastructure setup.
  - Current next step: validate Social Basico Guilda v1 with two human accounts on the published Internal Alpha build before the next package.

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
- Use `draxos-mobile/` for DraxosMobile implementation: Godot mobile/PC/browser client, Supabase, async autobattler, Base, social, Internal Alpha, release ops, validation and agent foundation.
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
