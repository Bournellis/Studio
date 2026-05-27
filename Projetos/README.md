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

## Implementacao - Internal Alpha

- `draxos-mobile/`: jogo mobile multi-plataforma - mago Draxos (PVP assincrono, base manager, social). Plataformas: Android + PC executavel + PC browser. Backend: Supabase para alpha, com Backend Proprio + Postgres como plano de saida preferido. Batalha 100% simulada no servidor. Track 00 completa, Track 01 completa e Track 02 com Progression Lab/Battle Lab v1 implementados; batalha visual procedural 2D e labs internos estao prontos. Track 03 esta completa para Internal Alpha v0: design lock, email/senha, dois saves por conta (`normal` e `progression_lab`), Supabase remoto Free, Progression Lab isolado, Base/Social/Competicao/Loja jogaveis, leaderboard sem bots, redeems diarios em Diamante, manifest de updates, exports Android/PC/Web, publicacao unlisted, passada Android UI, QA remoto automatizado, handoff final e testes Fabio + tester aprovados. Track 04 consolidou presenters render-only do Hub, plano de modularizacao, relatorio Progression/Economia e decisao Account/Save Gate mantendo `players.save_type` no curto prazo. Track 05 esta integrada como fundacao validada antes de assets reais e novos servicos. Track 06 esta integrada com feature rails e primeiras features. Track 07 esta integrada com apresentacao/layout mobile-first. Track 08 esta ativa para hardening da fundacao: app shell lifecycle, session/save boundary, mobile UI contract, battle mode contract, service/asset checks e validation harness. Handoff: `draxos-mobile/docs/internal-alpha-v0-handoff.md`.
  - Priority/status: `P2_IMPLEMENTACAO - Track 08 ACTIVE_FOUNDATION_HARDENING`
  - Local agent guide: `draxos-mobile/AGENTS.md`
  - Operational status: `draxos-mobile/implementation/current-status.md`
  - Product vision: `draxos-mobile/docs/product-vision.md`
  - Track 00 scope: `draxos-mobile/implementation/tracks/track-00-first-slice-foundation/scope.md`
  - Track 01 scope: `draxos-mobile/implementation/tracks/track-01-alpha-playtest-hardening/scope.md`
  - Track 02 scope: `draxos-mobile/implementation/tracks/track-02-progression-lab/scope.md`
  - Track 03 scope: `draxos-mobile/implementation/tracks/track-03-internal-alpha-v0/scope.md`
  - Track 04 scope: `draxos-mobile/implementation/tracks/track-04-post-handoff-hardening-and-hub-modularization/scope.md`
  - Track 05 scope: `draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/scope.md`
  - Track 06 scope: `draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/scope.md`
  - Track 07 scope: `draxos-mobile/implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/scope.md`
  - Track 08 scope: `draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/scope.md`
  - Internal Alpha v0 runbook: `draxos-mobile/docs/internal-alpha-v0.md`
  - Internal Alpha remote setup: `draxos-mobile/docs/internal-alpha-remote-setup.md`
  - Internal Alpha release plan: `draxos-mobile/docs/internal-alpha-release-plan.md`
  - Internal Alpha static hosting: `draxos-mobile/docs/internal-alpha-static-hosting.md`
  - Supabase remote tutorial: `draxos-mobile/docs/supabase-remote-tutorial.md`
  - Internal Alpha portal base: `draxos-mobile/portal/internal-alpha/`
  - Internal Alpha v0 checklist: `draxos-mobile/docs/playtest-internal-alpha-v0.md`
  - Internal Alpha v0 handoff: `draxos-mobile/docs/internal-alpha-v0-handoff.md`
  - Playtest checklist: `draxos-mobile/docs/playtest-alpha.md`
  - Progression Lab: `draxos-mobile/docs/progression-lab/README.md`
  - Battle visual mockup: `draxos-mobile/docs/battle-visual-mockup.md`
  - Design pending: `draxos-mobile/docs/design-pending.md`
  - Economy model: `draxos-mobile/docs/economy/README.md`
  - Design archive: `_conceitos/mobile-universe/gdd.md`
  - Allowed work: code, design, documentation, infrastructure setup.
  - Current next step: integrar T08-A e executar T08-B/T08-C/T08-D/T08-F em paralelo.

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

Multi-agent default:

- Use a dedicated worktree outside `D:\Estudio`: `D:\Estudio-worktrees\<projeto>--<agente>--<slug>`.
- Use branch `codex/<projeto>/<slug>` for Codex or `<agente>/<projeto>/<slug>` for non-Codex agents.
- Register branch, worktree, objective, intended files, base docs read and validation plan in Kanban/Doing or Handoffs before editing.
- Commit each logical stage separately. Avoid mega commits that mix documentation, contracts, backend, client, validation and publication.
- Before editing shared portfolio/canon/coordination files, check `git status --short`, `git worktree list` and the coordination docs.
- Do not edit another agent's worktree unless the user explicitly asks for that intervention.

## Future Projects

A future project under `Projetos/` becomes an official implementation project only when it has:

- a local `AGENTS.md`
- a local `implementation/current-status.md`
- an entry in this registry outside `_conceitos/`
- a summary entry in `../08_Coordenacao_Agentes/Estado_Atual.md`

Until then, treat it as experimental, conceptual, or preparatory material.
