# DraxosMobile

Jogo mobile multi-plataforma de PVP assincrono com base manager, progressao de personagem e sistema social. O jogador e um mago Draxos que cresce em poder ao longo do tempo.

**Nao confundir com:** `draxos-roguelike-cardgame` - projeto Steam separado.

Status: `P2_IMPLEMENTACAO - bootstrap`

---

## Current Shape

- Projeto promovido de conceito para implementavel em 2026-05-18.
- Preparacao documental da Track 00 definida em 2026-05-19.
- Godot project inicializado com boot minimo, validate, GUT, autoloads de fundacao e catalogo de conteudo gerado.
- Supabase runtime local configurado em `supabase/`: Docker Desktop, `npx supabase`, `npx deno`, migrations MVP, Auth anonimo, healthcheck e conta guest no gateway local.
- Conta guest MVP implementada: `account/guest`, `account/state`, convite `ALPHA-TEST`, fixture inicial de player/resources/build e escrita direta do cliente bloqueada.
- Reuso conservador documentado em `docs/reuse-map.md`; padroes tecnicos foram adotados sem importar gameplay de outros projetos.
- Track 00 tem dois niveis: MVP tecnico minimo e primeiro slice completo.
- Backend definido: Supabase Auth, Postgres, Edge Functions e Realtime.
- Plataformas do primeiro slice: Android + PC executavel + PC browser.

---

## Track 00

| Nivel | Objetivo | Status |
|---|---|---|
| MVP tecnico minimo | Provar Godot 4.6.2 + Supabase com guest, battle fixture server-authoritative e log animavel placeholder | Definido em docs |
| Primeiro slice completo | PVP autobattler, base manager, social, ranking, bots, conta, economia, Battle Pass/Diamante, validacao e exports | Escopo definido; design pendente registrado |

---

## Primeiro Slice Completo

| Sistema | Status |
|---|---|
| Character Autobattler PVP assincrono | Escopo definido |
| Base Manager com estruturas de producao | Escopo definido; design pendente registrado |
| Sistema social (amigos, guilda, chat) | Escopo definido; design pendente registrado |
| Infraestrutura (Supabase, contas, matchmaking) | Contratos iniciais definidos |
| Godot project inicializado | Completo - T00-P01 |
| Supabase base standalone | Completo - T00-P02A |
| Supabase runtime local | Completo - T00-P02B |
| Fundacao client reutilizavel | Completo - T00-P03 |
| Fixtures MVP e catalogo gerado | Completo - T00-P04 |
| Conta Guest MVP | Completo - T00-P05 |

---

## Directory Map

```
draxos-mobile/
|-- AGENTS.md
|-- README.md
|-- docs/
|   |-- product-brief.md
|   |-- game-design-document.md
|   |-- design-pending.md
|   |-- reuse-map.md
|   |-- pre-implementation-decisions.md
|   |-- architecture.md
|   `-- contracts/
|       |-- api-endpoints.md
|       |-- battle-event-log.md
|       |-- database-schema.md
|       `-- content-definitions.md
|-- implementation/
|   |-- current-status.md
|   `-- tracks/
|       `-- track-00-first-slice-foundation/
|           |-- current-status.md
|           |-- scope.md
|           |-- mvp-technical-definition.md
|           |-- implementation-plan.md
|           `-- implementation-prompts.md
|-- server/
|-- supabase/
|-- core/
|-- data/
|-- ui/
|-- modes/
|-- social/
|-- tools/
|-- tests/
`-- addons/
```

---

## Start Here

1. `AGENTS.md`
2. `implementation/current-status.md`
3. `implementation/tracks/track-00-first-slice-foundation/current-status.md`
4. `docs/reuse-map.md`
5. `docs/design-pending.md`
6. `implementation/tracks/track-00-first-slice-foundation/implementation-prompts.md`
