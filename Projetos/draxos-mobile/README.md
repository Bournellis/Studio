# DraxosMobile

Jogo mobile multi-plataforma de PVP assincrono com base manager, progressao de personagem e sistema social. O jogador e um mago Draxos que cresce em poder ao longo do tempo.

**Nao confundir com:** `draxos-roguelike-cardgame` — projeto Steam separado.

Status: `P2_IMPLEMENTACAO — bootstrap`

---

## Current Shape

- Projeto promovido de conceito para implementavel em 2026-05-18
- Godot project ainda nao inicializado — proxima acao e Track 00
- Design completo do primeiro slice: PVP Autobattler + Base Manager + Social
- Backend definido: Supabase (Auth, Postgres, Edge Functions)
- Plataformas: Android + PC executavel + PC browser

---

## Primeiro Slice

| Sistema | Status |
|---|---|
| Character Autobattler PVP assincrono | Design completo |
| Base Manager com estruturas de producao | Design completo |
| Sistema social (amigos, guilda, chat) | Design completo |
| Infraestrutura (Supabase, contas, matchmaking) | Design completo |
| Godot project inicializado | Pendente — Track 00 |
| Supabase project configurado | Pendente — Track 00 |

---

## Directory Map

```
draxos-mobile/
├── AGENTS.md               — governanca de agentes
├── README.md               — este arquivo
├── docs/
│   ├── product-brief.md    — escopo e decisoes de produto
│   ├── game-design-document.md — GDD de implementacao
│   └── architecture.md     — arquitetura tecnica Godot + Supabase
├── implementation/
│   ├── current-status.md   — status operacional atual
│   └── tracks/
│       └── track-00-first-slice-foundation/
├── server/
│   ├── schema/             — schema Postgres e migrations
│   └── functions/          — Supabase Edge Functions
├── core/                   — contratos, tipos, helpers
├── data/
│   └── definitions/        — JSON de conteudo (builds, bots, estruturas)
├── ui/                     — interface do jogador
├── modes/                  — boot, base manager, batalha, social
├── social/                 — guild, amigos, chat
├── tools/                  — validate.gd e ferramentas de geracao
├── tests/                  — testes GUT
└── addons/                 — GUT e outros addons
```

---

## Start Here

1. `AGENTS.md`
2. `implementation/current-status.md`
3. `docs/product-brief.md`
4. `docs/game-design-document.md`
5. `docs/architecture.md`
