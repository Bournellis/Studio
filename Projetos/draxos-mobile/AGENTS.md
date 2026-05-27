# AGENTS.md

This file governs agent behavior for `Projetos/draxos-mobile`.

**Nao confundir com:** `Projetos/draxos-roguelike-cardgame/` - projeto Steam separado.

---

## Project Role

DraxosMobile e um jogo mobile multi-plataforma de PVP assincrono com base manager e sistema social. O jogador e um mago Draxos que cresce em poder ao longo do tempo.

Plataformas do primeiro slice: Android app nativo, PC executavel, PC browser via Godot web export.

Backend: Supabase Auth, Postgres, Edge Functions e Realtime. Batalha 100% simulada no servidor; o cliente Godot apenas anima o log de eventos recebido.

Este projeto foi promovido de `Projetos/_conceitos/mobile-universe/` em 2026-05-18. Os documentos originais em `../_conceitos/mobile-universe/` sao arquivo historico de design.

---

## Regra Multi-Agente E Git

- Por padrao, trabalhe em worktree propria fora de `D:\Estudio`: `D:\Estudio-worktrees\draxos-mobile--<agente>--<slug>`.
- Branch padrao Codex: `codex/draxos-mobile/<slug>`. Outros agentes: `<agente>/draxos-mobile/<slug>`.
- Nao edite a worktree de outro agente e nao use a worktree principal `D:\Estudio` para implementacao, salvo pedido explicito.
- Antes de tocar `AGENTS.md`, `../../canon/`, `../../08_Coordenacao_Agentes/` ou `../README.md`, rode `git status --short`, `git worktree list` e leia os docs de coordenacao.
- Registre no inicio em Kanban/Doing ou Handoff: worktree, branch, objetivo, arquivos pretendidos, base lida, validacao planejada e proximo ponto de handoff.
- Commits devem ser por etapa logica: documentacao, contrato, backend, client Godot, validacao, publicacao e coordenacao.

---

## Read Order

### Fast Lane Pos-Handoff / Track 04

1. `implementation/current-status.md`
2. `implementation/tracks/track-04-post-handoff-hardening-and-hub-modularization/current-status.md`
3. `implementation/tracks/track-04-post-handoff-hardening-and-hub-modularization/scope.md`
4. `implementation/tracks/track-04-post-handoff-hardening-and-hub-modularization/implementation-plan.md`
5. `docs/internal-alpha-v0-handoff.md`
6. `docs/product-vision.md`
7. `docs/design-pending.md`
8. `docs/contracts/`
9. `docs/reuse-map.md`
10. este arquivo
11. arquivos tocados

### Trabalho substancial

Use quando afetar arquitetura, progressao, economia, modos, backend, contratos ou escopo.

1. `../../canon/canon-brief.md`
2. `docs/product-vision.md`
3. `docs/product-brief.md`
4. `docs/game-design-document.md`
5. `docs/design-pending.md`
6. `docs/pre-implementation-decisions.md`
7. `docs/architecture.md`
8. `docs/contracts/`
9. `implementation/current-status.md`
10. `implementation/tracks/track-04-post-handoff-hardening-and-hub-modularization/`
11. este arquivo
12. arquivos tocados

### Trabalho delimitado

1. `implementation/current-status.md`
2. este arquivo
3. arquivos tocados

---

## Mapa De Documentos

| Pergunta | Documento |
|---|---|
| Visao longa, pilares, anti-pilares e limites de produto | `docs/product-vision.md` |
| O que e o jogo, quais plataformas, escopo do slice | `docs/product-brief.md` |
| Como um sistema funciona | `docs/game-design-document.md` |
| O que ainda precisa de design | `docs/design-pending.md` |
| Por que uma decisao foi tomada | `docs/pre-implementation-decisions.md` |
| Stack e arquitetura tecnica | `docs/architecture.md` |
| O que pode ser reutilizado de outros projetos | `docs/reuse-map.md` |
| API, log de batalha, schema e conteudo | `docs/contracts/` |
| Escopo da Track 00 | `implementation/tracks/track-00-first-slice-foundation/scope.md` |
| Escopo da Track 01 | `implementation/tracks/track-01-alpha-playtest-hardening/scope.md` |
| Status da Track 01 | `implementation/tracks/track-01-alpha-playtest-hardening/current-status.md` |
| Escopo da Track 02 | `implementation/tracks/track-02-progression-lab/scope.md` |
| Status da Track 02 | `implementation/tracks/track-02-progression-lab/current-status.md` |
| Escopo da Track 03 | `implementation/tracks/track-03-internal-alpha-v0/scope.md` |
| Plano da Track 03 | `implementation/tracks/track-03-internal-alpha-v0/implementation-plan.md` |
| Status da Track 03 | `implementation/tracks/track-03-internal-alpha-v0/current-status.md` |
| Escopo da Track 04 | `implementation/tracks/track-04-post-handoff-hardening-and-hub-modularization/scope.md` |
| Plano da Track 04 | `implementation/tracks/track-04-post-handoff-hardening-and-hub-modularization/implementation-plan.md` |
| Status da Track 04 | `implementation/tracks/track-04-post-handoff-hardening-and-hub-modularization/current-status.md` |
| Escopo da Track 05 | `implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/scope.md` |
| Plano da Track 05 | `implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/implementation-plan.md` |
| Status da Track 05 | `implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/current-status.md` |
| Escopo da Track 06 | `implementation/tracks/track-06-feature-installation-rails-and-first-slices/scope.md` |
| Plano da Track 06 | `implementation/tracks/track-06-feature-installation-rails-and-first-slices/implementation-plan.md` |
| Status da Track 06 | `implementation/tracks/track-06-feature-installation-rails-and-first-slices/current-status.md` |
| Feature registry da Track 06 | `implementation/tracks/track-06-feature-installation-rails-and-first-slices/feature-registry.md` |
| Escopo da Track 07 | `implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/scope.md` |
| Plano da Track 07 | `implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/implementation-plan.md` |
| Status da Track 07 | `implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/current-status.md` |
| Runbook Internal Alpha v0 | `docs/internal-alpha-v0.md` |
| Setup remoto Internal Alpha v0 | `docs/internal-alpha-remote-setup.md` |
| Host estatico Internal Alpha v0 | `docs/internal-alpha-static-hosting.md` |
| Design Lock Internal Alpha v0 | `docs/internal-alpha-v0-design-lock.md` |
| Checklist Internal Alpha v0 | `docs/playtest-internal-alpha-v0.md` |
| Handoff Internal Alpha v0 | `docs/internal-alpha-v0-handoff.md` |
| MVP tecnico minimo | `implementation/tracks/track-00-first-slice-foundation/mvp-technical-definition.md` |
| Sequencia de execucao | `implementation/tracks/track-00-first-slice-foundation/implementation-plan.md` |
| Prompts atomicos para agentes | `implementation/tracks/track-00-first-slice-foundation/implementation-prompts.md` |
| Status operacional | `implementation/current-status.md` |
| GDD historico completo | `../_conceitos/mobile-universe/gdd.md` |

**Regra de conflito:** `docs/game-design-document.md` e a referencia autoritativa para implementacao. `../_conceitos/mobile-universe/gdd.md` e historico; consulte para contexto, nao para sobrepor documento local vivo.

---

## Regra De Canon

- Lore compartilhado em `../../canon/` informa o projeto.
- `docs/product-vision.md` e a fonte viva local para visao longa de produto ate eventual promocao de partes ao canon compartilhado.
- Nao importar mecanicas de outros projetos do estudio sem documento local adotando a regra.
- Reuso tecnico permitido vive em `docs/reuse-map.md`; gameplay de outros projetos continua vetado por padrao.
- Se design local conflita com lore compartilhado, lore prevalece ate o canon ser atualizado.

---

## Regra Godot

- Engine: Godot `4.6.2-stable`.
- Language: GDScript only.
- Tests: GUT `9.6.0`.
- Scenes sao editor-owned por padrao; agentes nao editam `.tscn` como texto bruto.
- Content source: JSON em `data/definitions/`.
- Resources gerados em `data/generated/` sao produzidos por ferramentas locais.

---

## Regra De Backend

- Toda logica de jogo autoritativa roda em Supabase Edge Functions, nunca no cliente.
- Cliente Godot se comunica com Supabase via HTTPRequest REST.
- Batalha: cliente envia intencao, recebe log, anima. Nao executa simulacao.
- Recursos sao mutados apenas via Edge Functions.
- Row Level Security (RLS) isola dados por jogador.
- Contratos vivem em `docs/contracts/`.
- Schema vivo ficara em `server/schema/` quando migrations existirem.
- Edge Functions ficam em `server/functions/`.

---

## Regra De Plataforma

- Android: app nativo, unico canal mobile do primeiro slice.
- PC: executavel nativo + PC browser.
- Mobile browser: fora do escopo.
- iOS: futuro; nao implementar sem decisao explicita.

---

## Regra De Design Pending

- Nao inventar design durante implementacao.
- Se faltar decisao, registrar em `docs/design-pending.md` com categoria de bloqueio.
- Ao resolver uma pendencia, atualizar `docs/design-pending.md` e o documento destino no mesmo commit.

---

## Active Track

Track ativa: `Track 07 - Mobile Presentation Loop And Layout Rework` (`ACTIVE_PRESENTATION_REWORK`).

Comece por `implementation/current-status.md` e siga `implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/current-status.md`.
