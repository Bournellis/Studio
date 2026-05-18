# AGENTS.md

This file governs agent behavior for `Projetos/draxos-mobile`.

**Nao confundir com:** `Projetos/draxos-roguelike-cardgame/` — projeto Steam separado.

---

## Project Role

DraxosMobile e um jogo mobile multi-plataforma de PVP assincrono com base manager e sistema social. O jogador e um mago Draxos que cresce em poder ao longo do tempo.

Plataformas do primeiro slice: Android (app nativo), PC executavel, PC browser (Godot web export).

Backend: Supabase (Auth, Postgres, Edge Functions, Realtime). Batalha 100% simulada no servidor — o cliente Godot apenas anima o log de eventos recebido.

Este projeto foi promovido de `Projetos/_conceitos/mobile-universe/` em 2026-05-18. Os documentos de conceito originais permanecem em `_conceitos/mobile-universe/` como arquivo de design.

---

## Read Order

### Trabalho substancial (afeta arquitetura, progressao, economia, modos, backend):

1. `../../canon/canon-brief.md`
2. `docs/product-brief.md`
3. `docs/game-design-document.md`
4. `docs/architecture.md`
5. `implementation/current-status.md`
6. este arquivo
7. arquivos tocados

### Trabalho delimitado (UI, bug, feature isolada):

1. `implementation/current-status.md`
2. este arquivo
3. arquivos tocados

---

## Regra De Canon

- Lore compartilhado em `../../canon/` informa o projeto
- Nao importar mecanicas de outros projetos do estudio sem documento local adotando a regra
- Se design local conflita com lore compartilhado, lore ganha ate canon ser atualizado
- Fonte de verdade de design: `docs/game-design-document.md` + `../../Projetos/_conceitos/mobile-universe/gdd.md`

---

## Regra Godot

- Engine: Godot 4.x (versao a confirmar ao inicializar o projeto)
- Language: GDScript only
- Tests: GUT 9.6.0
- Scenes sao editor-owned por padrao — agents nao editam `.tscn` como texto bruto
- Content source: JSON em `data/definitions/`
- Resources gerados em `data/generated/` produzidos por ferramentas locais

---

## Regra De Backend

- Toda logica de jogo autoritativa roda em Supabase Edge Functions — nunca no cliente
- Cliente Godot se comunica com Supabase via HTTPRequest (REST API)
- Batalha: cliente envia "solicitar batalha", recebe log de eventos, anima. Nao executa simulacao
- Recursos (Almas, Energia, Sangue, Cristais, Diamante): mutados apenas via Edge Functions
- Row Level Security (RLS) do Supabase isola dados por jogador
- Schema do banco em `server/schema/`
- Edge Functions em `server/functions/`

---

## Regra De Plataforma

- Mobile (Android): app nativo — unico canal mobile
- Mobile browser: fora do escopo
- PC: executavel nativo + browser (Godot web export)
- iOS: futuro — nao implementar sem decisao explicita

---

## Regra De Seguranca

- Tester de seguranca envolvido desde o alpha
- Vetores prioritarios: autenticacao, integridade de recursos, manipulacao de batalha
- Ver `docs/architecture.md` secao de anti-cheat

---

## Active Track

Start com `implementation/current-status.md`, depois seguir o track ativo.
