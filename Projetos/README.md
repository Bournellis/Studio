# Projetos

This directory contains active, conceptual, and paused projects for the studio.

Portfolio source of truth: `../08_Coordenacao_Agentes/Prioridades_Estudio.md`
Studio snapshot: `../08_Coordenacao_Agentes/Estado_Atual.md`
Visual dashboard: `../08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Implementacao Ativa

- `draxos-roguelike-cardgame/`: menu-first Draxos roguelike cardgame with Track 02 complete for user playtest: fixed 29-map route, save v5, reward schedule/progression, universal relics, expanded Souls shop, canonical keyword/status tooltips, full keyword engine, promoted class reward cards, elemental enemy galleries, hybrid enemy AI, visible enemy intent, encounter modes, board formats, field effects, boss hooks, UI readability polish, full-route pacing telemetry, and validation green.
  - Priority/status: `P0_IMPLEMENTACAO`
  - Local agent guide: `draxos-roguelike-cardgame/AGENTS.md`
  - Operational status: `draxos-roguelike-cardgame/implementation/current-status.md`
  - Studio snapshot: `../08_Coordenacao_Agentes/Estado_Atual.md`
  - Validation command: `draxos-roguelike-cardgame/tools/validate.gd`
  - Allowed work: code, validation, playtest, local documentation.
  - Current next step: user playtest of the Track 02 complete-run build.

## Implementacao - Bootstrap

- `draxos-mobile/`: jogo mobile multi-plataforma - mago Draxos (PVP assincrono, base manager, social). Plataformas: Android + PC executavel + PC browser. Backend: Supabase. Batalha 100% simulada no servidor. Track 00 em bootstrap: T00-P01, T00-P02A, T00-P02B, T00-P03, T00-P04 e T00-P05 concluidos com Godot project minimo, autoloads de fundacao, validate integrado, GUT, catalogo `MVP_ONLY`, runtime Supabase local no layout oficial `supabase/`, migrations MVP, healthcheck e conta guest no gateway local.
  - Priority/status: `P2_IMPLEMENTACAO - bootstrap`
  - Local agent guide: `draxos-mobile/AGENTS.md`
  - Operational status: `draxos-mobile/implementation/current-status.md`
  - Track 00 scope: `draxos-mobile/implementation/tracks/track-00-first-slice-foundation/scope.md`
  - Design pending: `draxos-mobile/docs/design-pending.md`
  - Design archive: `_conceitos/mobile-universe/gdd.md`
  - Allowed work: code, design, documentation, infrastructure setup.
  - Current next step: implementar `T00-P06 - Cliente Account/Session Shell`.

## Arquivo De Design

- `_conceitos/mobile-universe/`: arquivo de design do DraxosMobile. Promovido para `draxos-mobile/` em 2026-05-18. Preservado como referencia de design - nao e o projeto ativo.
  - Priority/status: `ARQUIVO_DESIGN`
  - GDD completo: `_conceitos/mobile-universe/gdd.md`
  - Decisoes historicas: `_conceitos/mobile-universe/pendencias.md`
  - Allowed work: leitura e referencia de design apenas.

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

- Use `draxos-roguelike-cardgame/` for the current implementation focus: Draxos roguelike, ship hub, run map, 29-map complete-run evolution, reward/relic/shop systems, full keyword scope, enemy AI/intent, lane battles, card/enemy redesign, sacrifice/movement/Cinzas tuning, and Track 02 production prompts.
- Use `draxos-mobile/` for all DraxosMobile implementation work - Godot project, Supabase, MVP tecnico minimo, first slice and design pending.
- Use `_conceitos/mobile-universe/` for design reference only - not the active project.
- Use `rpg-isometrico/` only for explicit historical/contextual consultation about the campaign-first isometric action RPG.
- Use `rpg-turnos/` only for explicit historical/contextual consultation about the provisional 2D RPG-cardgame.

`Draxos` and `cardgame` are shared vocabulary, not enough to pick `rpg-turnos`. Prefer the portfolio priority, the explicitly named project, or the operational surface above before reading a local project guide.

## Agent Rule

Before working in a project, read:

1. `../08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. the workspace `AGENTS.md`
3. this registry
4. the relevant section of `../08_Coordenacao_Agentes/Estado_Atual.md`
5. the target project's local docs, only if the portfolio status allows the requested work

Do not import mechanics from one project into another unless the target project's local docs explicitly adopt them.

## Future Projects

A future project under `Projetos/` becomes an official implementation project only when it has:

- a local `AGENTS.md`
- a local `implementation/current-status.md`
- an entry in this registry outside `_conceitos/`
- a summary entry in `../08_Coordenacao_Agentes/Estado_Atual.md`

Until then, treat it as experimental, conceptual, or preparatory material.
