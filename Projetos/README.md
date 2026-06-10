# Projetos

This directory contains active, conceptual and paused projects for the studio.

- Portfolio source of truth: `../08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Studio snapshot: `../08_Coordenacao_Agentes/Estado_Atual.md`
- Visual dashboard: `../08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

This registry describes stable project identity and entry points only. Status, markers, baselines and next steps live in the two files above and in each project's `implementation/current-status.md`.

## Registry

- `JogoDaCopa/`: independent PC Windows editor-first Godot football/minigames project (`Copa Arena Futebol`, third-person Futebol vs bot, Copa-style stadium). Split from the former FPS Playground on 2026-06-10.
  - Agent guide: `JogoDaCopa/AGENTS.md` | Status: `JogoDaCopa/implementation/current-status.md`
  - Plans: `JogoDaCopa/docs/work-plan.md`, `JogoDaCopa/docs/quality-upgrade-plan.md` | Validation: `JogoDaCopa/tools/validate.gd`

- `FpsPlayground/`: independent PC Windows editor-first Godot FPS laboratory (Arena Shooter, hitscan rifle, Plasma Bolt, jump pads, vertical-aware bot) with a light Draxos visual theme. Split from the former `FpsShooter/FPS Playground` on 2026-06-10. `FpsShooter` is a legacy name and routes here unless the request is about football/Copa.
  - Agent guide: `FpsPlayground/AGENTS.md` | Status: `FpsPlayground/implementation/current-status.md`
  - Plans: `FpsPlayground/docs/work-plan.md` | Validation: `FpsPlayground/tools/validate.gd`

- `draxos-roguelike-cardgame/`: menu-first Draxos roguelike cardgame for Steam/PC: ship hub, run map, Souls/relics, keyword engine, enemy intent, lane battles, simulation labs (AutoRun, Card Impact, Design Lab).
  - Agent guide: `draxos-roguelike-cardgame/AGENTS.md` | Status: `draxos-roguelike-cardgame/implementation/current-status.md`
  - Labs: `draxos-roguelike-cardgame/docs/autorun-lab.md`, `draxos-roguelike-cardgame/docs/design-lab.md` | Validation: `draxos-roguelike-cardgame/tools/validate.gd`

- `draxos-mobile/`: mobile-first Draxos PVE Arena-first async autobattler with Refugio/Base, later PVP/social, server-authoritative progression. Platforms: Android app, PC executable, PC browser. Backend alpha: Supabase (Backend Proprio + Postgres as the preferred long-term exit path).
  - Agent guide: `draxos-mobile/AGENTS.md` | Status: `draxos-mobile/implementation/current-status.md`
  - Release history: `draxos-mobile/docs/release-history.md` | Doc map: `draxos-mobile/docs/documentation-index.md`
  - Product: `draxos-mobile/docs/product-vision.md`, `draxos-mobile/docs/pve-arena-initial-direction.md`, `draxos-mobile/docs/game-design-document.md`

- `_conceitos/mobile-universe/`: read-only design archive for DraxosMobile, promoted to `draxos-mobile/` on 2026-05-18. No code, scenes or assets from here.

- `rpg-isometrico/`: campaign-first isometric action RPG.
  - Agent guide: `rpg-isometrico/AGENTS.md` | Status: `rpg-isometrico/implementation/current-status.md`

- `rpg-turnos/`: turn-based RPG-cardgame with independent mechanics and shared lore context.
  - Agent guide: `rpg-turnos/AGENTS.md` | Status: `rpg-turnos/implementation/current-status.md`

## Project Disambiguation

Route by request domain, then confirm allowed work in `Prioridades_Estudio.md`:

- football/Copa/ball/goals/shirts -> `JogoDaCopa/`
- FPS/arena 1x1/hitscan/jump pads -> `FpsPlayground/`
- roguelike/ship hub/run map/Souls/relics/lanes -> `draxos-roguelike-cardgame/`
- mobile/browser client/Supabase/async autobattler/Base/Internal Alpha -> `draxos-mobile/`
- isometric action campaign -> `rpg-isometrico/` | turn-based board/cards exploration RPG -> `rpg-turnos/`

`Draxos` alone is shared vocabulary and does not select a project.

## Agent Rule

Before working in a project, read:

1. `../08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. the workspace `AGENTS.md`
3. this registry
4. the relevant section of `../08_Coordenacao_Agentes/Estado_Atual.md`
5. the target project's local `AGENTS.md` and current status if the portfolio status allows the requested work

Multi-agent default: dedicated worktree outside `D:\Estudio` (`D:\Estudio-worktrees\<projeto>--<agente>--<slug>`), branch `codex/<projeto>/<slug>` (Codex) or `<agente>/<projeto>/<slug>`, register work in Kanban/Doing or Handoffs before editing, commit each logical stage separately, never edit another agent's worktree.

## Future Projects

A future project under `Projetos/` becomes an official implementation project only when it has:

- a local `AGENTS.md`;
- a local `implementation/current-status.md`;
- an entry in this registry outside `_conceitos/`;
- a summary entry in `../08_Coordenacao_Agentes/Estado_Atual.md`.

Until then, treat it as experimental, conceptual or preparatory material.
