# DraxosMobile — Architecture

- Ultima atualizacao: `2026-05-18`

---

## Stack

| Camada | Tecnologia |
|---|---|
| Client | Godot 4.x (GDScript) |
| Backend | Supabase (Auth, Postgres, Edge Functions, Realtime) |
| Comunicacao | REST via HTTPRequest do Godot |
| Autenticacao | JWT (Supabase Auth) + Google OAuth2 |
| Testes | GUT 9.6.0 |

---

## Plataformas E Exports

| Plataforma | Export Godot | Notas |
|---|---|---|
| Android | Android APK | App nativo — unico canal mobile |
| PC Windows/Linux | Executavel nativo | .zip |
| PC Browser | HTML5/WebAssembly | Godot web export |
| Mobile browser | — | Fora do escopo |
| iOS | — | Futuro |

Input adaptado por plataforma: `InputEventScreenTouch` (Android) / `InputEventMouseButton` (PC/Browser).

---

## Arquitetura De Conta

```
Boot
 └─► Tem token salvo?
      ├─ Sim → validar token → entrar
      └─ Nao → tela de entrada
               ├─ Jogar como guest → criar conta anonima (Supabase anon)
               ├─ Login email/senha
               └─ Google Sign-In (OAuth2)

Guest pode migrar para conta registrada a qualquer momento — progresso preservado.
Alpha: criacao de conta (inclusive guest) exige codigo de convite.
```

---

## Arquitetura De Batalha

O cliente Godot **nunca simula batalha**. Fluxo completo:

```
Cliente                          Servidor (Edge Function)
  │                                      │
  ├─► POST /battle/request ─────────────►│
  │                                      ├─ selecionar oponente (pool real + bots)
  │                                      ├─ simular batalha completa
  │                                      ├─ gravar resultado + atualizar recursos
  │                                      ├─ atualizar ranking
  │                                      └─ retornar { resultado, log_eventos }
  │◄─────────────────────────────────────┤
  └─► animar log_eventos na tela
```

**Log de eventos** e uma sequencia timestampada:
```json
[
  { "t": 0.0,  "tipo": "ataque_arma",   "dano": 15 },
  { "t": 0.8,  "tipo": "spell",         "spell": "Raio Cosmico", "dano": 25 },
  { "t": 1.6,  "tipo": "dot_tick",      "status": "Queimando", "dano": 6 },
  { "t": 30.2, "tipo": "anti_stall",    "dano": 103 },
  { "t": 30.8, "tipo": "resultado",     "vencedor": "jogador" }
]
```

O cliente interpola eventos na linha do tempo da animacao. Velocidade 1x/2x/skip sem afetar resultado.

**Desconexao:** batalha ja esta resolvida no servidor. Cliente busca o log na reconexao.

---

## Dados Autoritativos No Servidor

O cliente **nunca** envia dados que alteram estado de jogo diretamente.

| Dado | Onde vive |
|---|---|
| Recursos (Almas, Energia, Sangue, Cristais, Diamante) | Postgres — mutado so por Edge Functions |
| Level, XP, build (arma/spells/passiva/pet) | Postgres |
| Resultado de batalhas, ranking | Postgres — calculado no servidor |
| Dados de guilda | Postgres |
| Pool de oponentes | Postgres — selecionado pelo servidor |
| Preferencias de UI, cache de animacao | Local — sem impacto em progressao |
| Producao da base | Calculada no servidor na reconexao (delta × taxa) |

**Row Level Security (RLS):** cada jogador acessa apenas seus proprios dados.

---

## Matchmaking

```
POST /battle/request
  └─► calcular poder do solicitante
  └─► filtrar pool por faixa de poder (±X — a calibrar)
  └─► sortear oponente (real ou bot simulado)
  └─► iniciar simulacao
```

**Builds simuladas:** contas-fantasma com builds aleatorias por faixa de poder. Populadas antes do alpha. Nao aparecem em rankings.

---

## Ranking

- Pontos de arena por season
- Vitoria: +pontos (mais pontos contra oponentes mais fortes)
- Derrota: -pontos (mais pontos perdidos contra oponentes mais fracos)
- Snapshot do ranking ao fim de cada season
- Formula exata: a calibrar com dados reais

---

## Politica Offline

| Situacao | Comportamento |
|---|---|
| Sem internet | Estado cacheado exibido, batalha desabilitada |
| Producao da base offline | Servidor calcula delta na reconexao |
| Desconexao durante batalha | Resultado ja gravado — cliente busca log |
| Coleta offline | Servidor acumula (respeitando limite de armazenamento) |

---

## Anti-Cheat

| Vetor | Mitigacao |
|---|---|
| Forjar resultado | Batalha 100% servidor |
| Injetar recursos | Edge Functions validam toda mutacao |
| Escolher oponente facil | Servidor controla matchmaking |
| Farm abusivo | Rate limiting no endpoint de batalha |
| Acesso a dados alheios | RLS do Supabase |
| Engenharia reversa do oponente | Log retorna apenas eventos animaveis — nao o build completo |

---

## Estrutura De Pastas — Codigo

```
draxos-mobile/
├── server/
│   ├── schema/         — migrations Postgres (.sql)
│   └── functions/      — Edge Functions (TypeScript/Deno)
│       ├── battle/     — simulacao, matchmaking, resultado
│       ├── account/    — guest, register, login, migration
│       ├── base/       — upgrades, producao, coleta
│       └── social/     — guild, amigos, ajudas, chat
├── core/               — contratos GDScript, tipos, helpers HTTP
├── data/
│   └── definitions/    — JSON de conteudo (spells, passivas, pets, bots)
├── modes/              — boot, base manager, batalha, social, menu
├── ui/                 — componentes de interface
├── social/             — guild UI, chat, amigos
├── tools/              — validate.gd, geracao de bots, migracao de dados
└── tests/              — GUT tests
```

---

## Supabase — Tabelas Principais (Schema Inicial)

| Tabela | Conteudo |
|---|---|
| `players` | id, username, tipo_conta, level, xp, poder |
| `builds` | player_id, arma_level, spell_levels[], pet_level, passiva_levels[] |
| `resources` | player_id, almas, energia, sangue, cristais, diamante |
| `base_structures` | player_id, estrutura_id, level, ultima_coleta |
| `battles` | id, atacante_id, defensor_id, resultado, log, created_at |
| `ranking` | player_id, season, pontos, posicao |
| `guilds` | id, nome, level, membros[] |
| `guild_structures` | guild_id, estrutura_id, level |
| `chat_messages` | id, canal_id, autor_id, texto, created_at |
| `bot_builds` | id, poder, build_data, faixa |

Schema detalhado em `server/schema/`.
