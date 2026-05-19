# DraxosMobile - Architecture

- Ultima atualizacao: `2026-05-19`

---

## Stack

| Camada | Tecnologia |
|---|---|
| Client | Godot `4.6.2-stable` (GDScript) |
| Backend | Supabase Auth, Postgres, Edge Functions, Realtime |
| Comunicacao | REST via HTTPRequest do Godot |
| Autenticacao | JWT Supabase, Auth anonimo para guest MVP, Google OAuth2 futuro |
| Testes client | GUT `9.6.0` |
| Testes server | Deno/TypeScript tests para Edge Functions |

---

## Status Tecnico Atual

- `T00-P01` completo: projeto Godot, boot scene, `ProjectInfo`, validate e GUT.
- `T00-P02A` completo: migration MVP, tabelas iniciais, RLS base, seed tecnico e healthcheck standalone.
- `T00-P02B` completo: layout oficial `supabase/`, Docker Desktop, Deno via `npx`, `supabase db reset` e healthcheck pelo gateway local.
- `T00-P03` completo: autoloads `UiTokens`, `AssetIds`, `ContentLibrary`, `.gutconfig.json` e validate integrado.
- `T00-P04` completo: fixtures `MVP_ONLY`, JSONs de conteudo e catalogo gerado.
- `T00-P05` completo: conta guest MVP, convite `ALPHA-TEST`, `account/guest`, `account/state`, RPC idempotente e bloqueio de escrita direta do cliente.

---

## Contratos

Antes de criar codigo ou migrations, consulte:

- `contracts/api-endpoints.md`
- `contracts/battle-event-log.md`
- `contracts/database-schema.md`
- `contracts/content-definitions.md`
- `reuse-map.md`

`supabase/` e a fonte de execucao local da Supabase CLI. `server/schema/` e `server/functions/` permanecem como espelho organizado do backend enquanto o bootstrap ainda esta pequeno.

Deno e Supabase CLI sao validados via `npx -y deno` e `npx -y supabase` nesta maquina.

Runtime local validado:

- Studio: `http://127.0.0.1:54323`
- Project URL: `http://127.0.0.1:54321`
- Database: `postgresql://postgres:postgres@127.0.0.1:54322/postgres`
- Edge Functions: `http://127.0.0.1:54321/functions/v1`

---

## Fundacao Client Godot

Autoloads atuais:

| Autoload | Arquivo | Responsabilidade |
|---|---|---|
| `UiTokens` | `core/ui_tokens.gd` | Cores, estilos e tokens semanticos de UI |
| `AssetIds` | `core/asset_ids.gd` | Manifesto de ids visuais e fallback enquanto assets nao existem |
| `ContentLibrary` | `data/content_library.gd` | Gerar/carregar catalogo de conteudo e expor consultas por collection/id |

Regras:

- Autoloads nao possuem autoridade economica ou de batalha.
- `ContentLibrary` pode gerar catalogo local para UI, fixtures e testes.
- `SessionStore` ainda nao existe; entra em `T00-P06` como cache local nao autoritativo.

---

## Pipeline De Conteudo

```text
data/definitions/*.json
  -> tools/content_generator.gd
  -> data/generated/draxos_mobile_catalog.tres
  -> ContentLibrary
  -> UI/tests/client
```

Arquivos esperados:

- `spells.json`
- `pets.json`
- `passives.json`
- `weapons.json`
- `base_structures.json`
- `bot_builds.json`
- `power_bands.json`
- `battle_fixtures.json`
- `rewards.json`

Fixtures `MVP_ONLY` provam arquitetura, nao balanceamento final.

---

## Politica De Reuso

Referencia viva: `reuse-map.md`.

- Reutilizar diretamente: configuracao GUT, padrao de validate, centralizacao de tokens e asset ids.
- Adaptar: content generation multi-arquivo, ContentLibrary e padroes de session/cache local.
- Vetar: BattleEngines, card/deck/mana/run map, campanha action, saves autoritativos e regras de gameplay de outros projetos.

---

## Plataformas E Exports

| Plataforma | Export Godot | Notas |
|---|---|---|
| Android | Android APK | App nativo, unico canal mobile |
| PC Windows/Linux | Executavel nativo | `.zip` |
| PC Browser | HTML5/WebAssembly | Godot web export |
| Mobile browser | - | Fora do escopo |
| iOS | - | Futuro |

Input adaptado por plataforma: `InputEventScreenTouch` para Android e `InputEventMouseButton` para PC/browser.

---

## Arquitetura De Conta

Fluxo completo do primeiro slice:

```text
Boot
  -> Tem token salvo?
       -> Sim: validar token e entrar
       -> Nao: tela de entrada
            -> Jogar como guest com codigo de convite
            -> Login email/senha
            -> Google Sign-In
```

Guest pode migrar para conta registrada sem perder progresso.

MVP tecnico implementa apenas guest com codigo de convite.

Modelo escolhido em `DMOB-D042`:

1. Cliente cria uma sessao via Supabase Auth anonimo nativo.
2. Cliente chama `POST /account/guest` com `Authorization: Bearer <anonymous_jwt>`, `invite_code` e `request_id`.
3. Edge Function valida convite e cria `players`, `resources` e `builds` usando service role.
4. Progresso guest fica vinculado a `players.auth_user_id`.
5. Conversao futura para conta registrada preserva `players.id`.

Implementado em `T00-P05`:

- `POST /account/guest`: valida JWT anonimo, `invite_code` e `request_id`, chama RPC `create_guest_account` e retorna player/resources/build inicial.
- `GET /account/state`: recupera player/resources/build e `last_battle_id` para a sessao autenticada.
- `create_guest_account`: RPC `SECURITY DEFINER` com execute restrito a `service_role`, seed `ALPHA-TEST` e idempotencia por `idempotency_keys`.
- Cliente Godot ainda nao chama esses endpoints diretamente; HTTP client e `SessionStore` entram em `T00-P06`.

---

## Arquitetura De Batalha

O cliente Godot nunca simula batalha.

```text
Cliente
  -> POST /battle/request
Servidor
  -> seleciona oponente
  -> simula batalha completa
  -> grava resultado e recompensa
  -> retorna battle_log_v1
Cliente
  -> anima log recebido
```

Desconexao durante batalha nao altera resultado, porque o resultado ja foi gravado antes do cliente animar.

Contrato do log: `contracts/battle-event-log.md`.

---

## Dados Autoritativos No Servidor

| Dado | Onde vive |
|---|---|
| Recursos | Postgres, mutado so por Edge Functions |
| Level, XP e build | Postgres |
| Resultado de batalhas e ranking | Postgres, calculado no servidor |
| Dados de guilda e social | Postgres |
| Pool de oponentes | Postgres |
| Preferencias de UI e cache visual | Local, sem impacto em progressao |
| Producao da base | Calculada no servidor na reconexao |

RLS deve impedir acesso indevido. Mutacoes economicas devem usar idempotencia e ledger.

Regra resolvida em `DMOB-D043`: cliente nao recebe policies de insert/update/delete para estado autoritativo no MVP. Escritas em `players`, `resources`, `builds`, `battles`, `idempotency_keys` e `resource_transactions` passam por Edge Functions com service role.

---

## Matchmaking E Ranking

MVP tecnico usa bot fixture `mvp_training_bot`.

Primeiro slice completo:

- Calcula poder do solicitante.
- Filtra pool por faixa de poder.
- Sorteia oponente real ou bot simulado.
- Bots simulados nao aparecem em ranking.
- Ranking usa pontos de arena por season e snapshot no encerramento.

Formula final e faixa inicial estao registradas em `design-pending.md`.

---

## Politica Offline

| Situacao | Comportamento |
|---|---|
| Sem internet | Estado cacheado exibido, batalha e chat desabilitados |
| Producao da base offline | Servidor calcula delta na reconexao |
| Desconexao durante batalha | Cliente busca log gravado |
| Coleta offline | Servidor acumula respeitando armazenamento |

---

## Anti-Cheat

| Vetor | Mitigacao |
|---|---|
| Forjar resultado | Batalha 100% servidor |
| Injetar recursos | Edge Functions validam toda mutacao |
| Escolher oponente facil | Servidor controla matchmaking |
| Farm abusivo | Rate limiting no endpoint de batalha |
| Acesso a dados alheios | RLS do Supabase |
| Duplicar recompensa | Idempotencia por `request_id` e ledger |
| Engenharia reversa do oponente | Log retorna eventos animaveis, nao build completa |

---

## Estrutura De Pastas - Codigo

```text
draxos-mobile/
|-- supabase/
|   |-- config.toml
|   |-- migrations/
|   `-- functions/
|       |-- account/
|       |-- healthcheck/
|       `-- _shared/
|-- server/
|   |-- schema/
|   `-- functions/
|-- core/
|-- data/
|   |-- definitions/
|   |-- generated/
|   `-- resources/
|-- modes/
|-- ui/
|-- social/
|-- tools/
`-- tests/
```

---

## Pendencias Arquiteturais

Pendencias vivas:

- Chat: politica de retencao/delecao/moderacao (`DMOB-D023`).
- Telemetria minima (`DMOB-D024`).
- Schema de build para spells desbloqueadas/equipadas (`DMOB-D026`).

Pendencias operacionais resolvidas em 2026-05-19:

- Layout Supabase CLI (`DMOB-D040`): `supabase/`.
- Ambiente local (`DMOB-D041`): Docker Desktop + Supabase CLI via `npx` + Deno via `npx`.
- Modelo de conta guest (`DMOB-D042`): Supabase Auth anonimo nativo + Edge Function com convite.
- Escrita SQL service-role-only (`DMOB-D043`): sem write policies client-side para estado autoritativo no MVP.
