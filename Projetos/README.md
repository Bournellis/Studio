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

- `draxos-mobile/`: jogo mobile multi-plataforma - mago Draxos (PVP assincrono, base manager, social). Plataformas: Android + PC executavel + PC browser. Backend: Supabase. Batalha 100% simulada no servidor. Track 00 completa: T00-P01 a T00-P13 concluidos; pronto para playtest alpha. T00-P13 entregou Monetizacao v0 server-authoritative com Battle Pass, Diamante alpha, rewards diarias/semanais, premium alpha, claims free/premium, ledger/idempotencia, fluxo minimo no Godot e export smoke Android/PC/Web. T00-P12 entregou Social/Competicao v0 server-authoritative com guilda alpha, chat por polling, matchmaking preview com fallback de bot, ranking de season sem bots, RLS e fluxo minimo no Godot. T00-P11 entregou Base Manager v0 server-authoritative com estruturas permanentes, fila de construcao, coleta offline, `base/state`, `base/collect`, `base/upgrade`, ledger, idempotencia e fluxo minimo no Godot. T00-P10 entregou conteudo real inicial, catalogo ampliado, seeds de bots `FIRST_SLICE`, simulador server-authoritative com DoTs/status/resistencias/passivas/pets/summons/anti-stall, modo `FIRST_SLICE_SIM`, recompensas XP/Almas/Energia/Sangue/Ossos, smoke runtime Supabase e replay rico no cliente. Godot project minimo tem boot hub alpha com abas/telas rolaveis, Voltar/Esc e confirmacoes simples, autoloads de fundacao, validate integrado, GUT, runtime Supabase local no layout oficial `supabase/`, migrations MVP/base/social/ranking/monetizacao, healthcheck, conta guest no gateway local, cliente de sessao Godot com Auth anonimo + cache nao autoritativo e endpoints server-authoritative idempotentes. Baseline de design inclui cap 40, levels permanentes, unlocks de spell/passiva/pet, base v0 implementavel, missoes/onboarding v0, monetizacao/recompensas v0, social/ranking/chat v0, combate real/simulador, matchmaking por poder, bots iniciais, telemetria minima, schema de build, UX alpha com Refugio, baseline calibravel de economia/simulador de seasons e guilda S1 com bonus ate 5%.
  - Priority/status: `P2_IMPLEMENTACAO - alpha ready`
  - Local agent guide: `draxos-mobile/AGENTS.md`
  - Operational status: `draxos-mobile/implementation/current-status.md`
  - Track 00 scope: `draxos-mobile/implementation/tracks/track-00-first-slice-foundation/scope.md`
  - Design pending: `draxos-mobile/docs/design-pending.md`
  - Economy model: `draxos-mobile/docs/economy/README.md`
  - Design archive: `_conceitos/mobile-universe/gdd.md`
  - Allowed work: code, design, documentation, infrastructure setup.
  - Current next step: executar playtest alpha do primeiro slice.

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
