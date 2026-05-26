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

- `draxos-mobile/`: jogo mobile multi-plataforma - mago Draxos (PVP assincrono, base manager, social). Plataformas: Android + PC executavel + PC browser. Backend: Supabase. Batalha 100% simulada no servidor. Track 00 completa: T00-P01 a T00-P13 concluidos; Track 01 completa com hardening do alpha PC local; Track 02 Progression Lab tooling v1 implementado. Em 2026-05-25 recebeu Character Systems Rework e Source Identity Balance v2 em docs, catalogo, simulador, Edge Functions, seeds/migrations, Godot dev tools e testes: armas viraram Instrumentos Rituais, passivas viraram Doutrinas, pets viraram Familiares, Mental virou familia de status e fontes vivas sao Arcano/Fisico/Fogo/Agua/Gelo/Terra/Vento/Raio/Veneno/Sangue/Morte. Progression Lab gera `25` saves, `75` bots, relatorios HTML/CSV/JSON, seeder local Supabase, cache `.progression_lab_scratch/`, fallback local-only sem Supabase, tela dev-only no Refugio e matriz integrada ao Battle Lab com status `REVIEW`. Batalha e Battle Lab compartilham `BattleVisualMockup` para apresentar `battle_log_v1` com palco procedural 2D estilo luta lateral, personagens parados, ataques, spells, buffs, dano, numeros flutuantes, projeteis simples, cooldowns, tooltips objetivos imediatos durante efeitos, slots front/middle/back, summons, Familiar e HUD basica, sem simular combate no cliente. Battle Lab offline pode gerar scratch runs, montar builds, ver analytics, validar identidade de fonte e assistir replays pelo mesmo mockup visual, sem entrar nos exports; Battle Lab/Progression Lab no Godot tem invocacao Deno sanitizada, wrapper Windows-safe para `npx.cmd`, smoke real `tools/smoke_dev_labs.gd` e smoke visual `tools/smoke_dev_lab_ui.gd`; Battle Lab prioriza amostra de replay com spells visiveis e replay custom aparece em Replay/History; run oficial `2026-05-25_source_identity_balance_v02` gera `3132` batalhas e `212` builds com status `PASS`, duracao media `24.08s`, anti-stall `4.95%`, dominancia em poder proximo maxima `63.46%` e checks de identidade de fonte em `PASS`. T01/T00 seguem com UX alpha, telemetria client nao autoritativa, Monetizacao/Base/Social/Competicao server-authoritative, Godot validate/GUT `36/36` e `206` asserts, exports Android/PC/Web e Supabase local no layout oficial.
  - Priority/status: `P2_IMPLEMENTACAO - source identity balance v2 implemented`
  - Local agent guide: `draxos-mobile/AGENTS.md`
  - Operational status: `draxos-mobile/implementation/current-status.md`
  - Track 00 scope: `draxos-mobile/implementation/tracks/track-00-first-slice-foundation/scope.md`
  - Track 01 scope: `draxos-mobile/implementation/tracks/track-01-alpha-playtest-hardening/scope.md`
  - Track 02 scope: `draxos-mobile/implementation/tracks/track-02-progression-lab/scope.md`
  - Playtest checklist: `draxos-mobile/docs/playtest-alpha.md`
  - Progression Lab: `draxos-mobile/docs/progression-lab/README.md`
  - Battle visual mockup: `draxos-mobile/docs/battle-visual-mockup.md`
  - Design pending: `draxos-mobile/docs/design-pending.md`
  - Economy model: `draxos-mobile/docs/economy/README.md`
  - Design archive: `_conceitos/mobile-universe/gdd.md`
  - Allowed work: code, design, documentation, infrastructure setup.
  - Current next step: rodar Progression Lab com Supabase local, carregar saves 2h-20h manualmente no Godot e usar Battle Lab/relatorios para rodada before/after de premium gap 10h, janelas 15h/20h, poder, recompensa, Defesa/Mental e sensacao de Familiar/Funeral.

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
