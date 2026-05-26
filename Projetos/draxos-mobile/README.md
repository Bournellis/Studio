# DraxosMobile

Jogo mobile multi-plataforma de PVP assincrono com base manager, progressao de personagem e sistema social. O jogador e um mago Draxos que cresce em poder ao longo do tempo.

**Nao confundir com:** `draxos-roguelike-cardgame` - projeto Steam separado.

Status: `P2_IMPLEMENTACAO - internal alpha v0 design lock + backend strategy complete`

---

## Current Shape

- Track 00 completa: Godot client, Supabase local, auth guest, batalha server-authoritative, Base, Social/Competicao, Monetizacao, pipeline de conteudo, exports e testes.
- Track 01 completa: hardening do alpha PC local, telemetria client nao autoritativa, reset seguro de sessao local, smokes de loop alpha e checklist de playtest.
- Track 02 com tooling v1 implementado: Progression Lab gera 25 estados saudaveis, saves Supabase locais, bot pool, recomendacoes de poder, matriz no Battle Lab e fluxo manual de teste no Godot para as primeiras 2h-20h.
- Track 03 com design lock e estrategia backend completos: Internal Alpha v0 documentada para email/senha, dois saves por conta, Supabase remoto Free, plano de saida para Backend Proprio + Postgres, Progression Lab isolado, Base/Social/Competicao/Loja jogaveis, leaderboard sem bots, redeems diarios em Diamante, manifest de updates e playtest fechado Fabio + 1 amigo.
- Rework de personagem 2026-05-25 implementado em docs, catalogo e simulador: armas viraram Instrumentos Rituais, passivas viraram Doutrinas, pets viraram Familiares, Mental e familia de status, e as fontes vivas sao Arcano/Fisico/Fogo/Agua/Gelo/Terra/Vento/Raio/Veneno/Sangue/Morte.
- Battle Lab offline + dev-only no Godot implementado: `tools/battle_lab/` gera HTML/CSV/JSON/replays em `docs/battle-lab/generated/`, arquiva runs oficiais em `docs/battle-lab/runs/`, compara deltas, marca compatibilidade/stale e pode ser aberto no editor pelo Refugio para montar builds e assistir replays debug 2D; exports excluem a ferramenta. A rodada atual mede o rework de personagem e preserva o baseline 2026-05-21 apenas como historico pre-rework.
- Supabase runtime local configurado em `supabase/`: Docker Desktop, `npx supabase`, `npx deno`, migrations MVP/base/social/ranking/monetizacao, Auth anonimo, healthcheck e Edge Functions `account/*`, `battle/*`, `base/*`, `social/*`, `competition/*`, `monetization/*` e `telemetry/*`.
- Conta guest alpha implementada: `account/guest`, `account/state`, convite `ALPHA-TEST`, fixture inicial de player/resources/build, cache local nao autoritativo e escrita direta do cliente bloqueada.
- Reuso conservador documentado em `docs/reuse-map.md`; padroes tecnicos foram adotados sem importar gameplay de outros projetos.
- Backend definido: Supabase Auth, Postgres, Edge Functions e Realtime.
- Plataformas do primeiro slice: Android + PC executavel + PC browser.

---

## Track 00

| Nivel | Objetivo | Status |
|---|---|---|
| MVP tecnico minimo | Provar Godot 4.6.2 + Supabase com guest, battle fixture server-authoritative e log animavel placeholder | Completo |
| Primeiro slice completo | PVP autobattler, base manager, social, ranking, bots, conta, economia, Battle Pass/Diamante, validacao e exports | Completo para alpha |

## Track 01

| Objetivo | Status |
|---|---|
| Hardening do alpha PC local sem expandir modos ou mecanicas | Completo |
| Telemetria client nao autoritativa em `telemetry_events` | Completo |
| Smoke guest -> state -> battle -> base -> social -> competition -> shop | Completo |
| Checklist e template de feedback de playtest | Completo |

## Track 02

| Objetivo | Status |
|---|---|
| Progression Lab para saves saudaveis 2h-20h, perfis economicos, bots, poder e teste manual no Godot | Tooling v1 implementado; falta rodada manual com Supabase local |

## Track 03

| Objetivo | Status |
|---|---|
| Build fechada Internal Alpha v0 com conta email/senha, dois saves, backend remoto, updates e features principais funcionais | Documentada e pronta para implementacao |

---

## Primeiro Slice Completo

| Sistema | Status |
|---|---|
| Character Autobattler PVP assincrono | Alpha implementado |
| Base Manager com estruturas de producao | Alpha implementado |
| Sistema social (amigos, guilda, chat) | Alpha implementado |
| Infraestrutura (Supabase, contas, matchmaking) | Alpha implementado |
| Godot project inicializado | Completo - T00-P01 |
| Supabase base standalone | Completo - T00-P02A |
| Supabase runtime local | Completo - T00-P02B |
| Fundacao client reutilizavel | Completo - T00-P03 |
| Fixtures MVP e catalogo gerado | Completo - T00-P04 |
| Conta Guest MVP | Completo - T00-P05 |
| Batalha, replay, Base, Social, Competicao e Monetizacao | Completo - T00-P07 a T00-P13 |
| Alpha Playtest Hardening | Completo - Track 01 |
| Battle Lab, historico, replay dev e tuning de fonte/arquetipo | Completo - baseline v02 2026-05-21 |
| Progression Lab, saves saudaveis e teste manual por milestone | Tooling v1 implementado - Track 02 |

---

## Directory Map

```
draxos-mobile/
|-- AGENTS.md
|-- README.md
|-- docs/
|   |-- battle-lab/
|   |-- progression-lab/
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
|       |-- track-00-first-slice-foundation/
|           |-- current-status.md
|           |-- scope.md
|           |-- mvp-technical-definition.md
|           |-- implementation-plan.md
|           `-- implementation-prompts.md
|       |-- track-01-alpha-playtest-hardening/
|           |-- current-status.md
|           |-- scope.md
|           `-- implementation-plan.md
|       |-- track-02-progression-lab/
|           |-- current-status.md
|           |-- scope.md
|           `-- implementation-plan.md
|       `-- track-03-internal-alpha-v0/
|           |-- current-status.md
|           |-- scope.md
|           `-- implementation-plan.md
|-- server/
|-- supabase/
|-- core/
|-- data/
|-- dev/
|-- ui/
|-- modes/
|-- social/
|-- tools/
|   |-- battle_lab/
|   |-- progression_lab/
|-- tests/
`-- addons/
```

---

## Start Here

1. `AGENTS.md`
2. `implementation/current-status.md`
3. `implementation/tracks/track-03-internal-alpha-v0/current-status.md`
4. `implementation/tracks/track-03-internal-alpha-v0/scope.md`
5. `docs/internal-alpha-v0.md`
6. `docs/internal-alpha-v0-design-lock.md`
7. `docs/design-pending.md`
