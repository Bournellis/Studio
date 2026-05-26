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

## Implementacao - Alpha Local

- `draxos-mobile/`: jogo mobile multi-plataforma - mago Draxos (PVP assincrono, base manager, social). Plataformas: Android + PC executavel + PC browser. Backend: Supabase para alpha, com Backend Proprio + Postgres como plano de saida preferido. Batalha 100% simulada no servidor. Track 00 completa, Track 01 completa e Track 02 com Progression Lab/Battle Lab v1 implementados; batalha visual procedural 2D e labs internos estao prontos para a primeira rodada de teste. Track 03 tem design lock completo para Internal Alpha v0: email/senha, dois saves por conta (`normal` e `progression_lab`), Supabase remoto Free, Progression Lab isolado, Base/Social/Competicao/Loja jogaveis, leaderboard sem bots, redeems diarios em Diamante, manifest de updates e playtest fechado Fabio + 1 amigo. Ordem local-first aprovada: implementar no Godot/Supabase local antes de remoto/builds. T03-P08 esta completo com save ativo/isolado, reset separado, Progression Lab server-backed, Base Manager jogavel, Social basico jogavel, Competicao com pontos/top 10/self rank e Loja proof-of-concept com redeems diarios de Diamante, Battle Pass, fila dupla aplicada na Base e pacotes por Diamante.
  - Priority/status: `P2_IMPLEMENTACAO - internal alpha v0 shop proof-of-concept playable`
  - Local agent guide: `draxos-mobile/AGENTS.md`
  - Operational status: `draxos-mobile/implementation/current-status.md`
  - Track 00 scope: `draxos-mobile/implementation/tracks/track-00-first-slice-foundation/scope.md`
  - Track 01 scope: `draxos-mobile/implementation/tracks/track-01-alpha-playtest-hardening/scope.md`
  - Track 02 scope: `draxos-mobile/implementation/tracks/track-02-progression-lab/scope.md`
  - Track 03 scope: `draxos-mobile/implementation/tracks/track-03-internal-alpha-v0/scope.md`
  - Internal Alpha v0 runbook: `draxos-mobile/docs/internal-alpha-v0.md`
  - Internal Alpha remote setup: `draxos-mobile/docs/internal-alpha-remote-setup.md`
  - Internal Alpha v0 checklist: `draxos-mobile/docs/playtest-internal-alpha-v0.md`
  - Playtest checklist: `draxos-mobile/docs/playtest-alpha.md`
  - Progression Lab: `draxos-mobile/docs/progression-lab/README.md`
  - Battle visual mockup: `draxos-mobile/docs/battle-visual-mockup.md`
  - Design pending: `draxos-mobile/docs/design-pending.md`
  - Economy model: `draxos-mobile/docs/economy/README.md`
  - Design archive: `_conceitos/mobile-universe/gdd.md`
  - Allowed work: code, design, documentation, infrastructure setup.
  - Current next step: executar `T03-P09 - Batalha Visual Polish Pequeno`; remoto/builds ficam adiados ate o gameplay local estar pronto.

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
- Use `draxos-mobile/` for all DraxosMobile implementation work - Godot project, Supabase, first slice, alpha hardening and design pending.
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
