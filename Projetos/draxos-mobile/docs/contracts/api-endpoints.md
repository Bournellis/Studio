# API Endpoints Contract

- Ultima atualizacao: `2026-05-19`
- Status: contrato MVP com `account/guest` e `account/state` implementados localmente

Este documento descreve a interface logica entre cliente Godot e Supabase Edge Functions. A implementacao fisica pode organizar funcoes em subpastas, mas os nomes logicos abaixo devem permanecer estaveis para o cliente.

## Regras Gerais

- Transporte: HTTPS REST via HTTPRequest do Godot.
- Autenticacao: JWT Supabase no header `Authorization: Bearer <token>`.
- Guest MVP: cliente primeiro cria sessao Supabase Auth anonima; depois chama `/account/guest` com o JWT anonimo e codigo de convite.
- Correlation: cliente envia `request_id` em mutacoes para idempotencia.
- Runtime local atual: `supabase/functions/account/index.ts`, espelhado em `server/functions/account/index.ts`.
- Resposta de erro padrao:

```json
{
  "ok": false,
  "error": {
    "code": "string",
    "message": "string"
  }
}
```

## Endpoints MVP Tecnico

### `POST /account/guest`

Cria o estado de jogo para uma sessao guest anonima ja autenticada.

Status: **implementado em T00-P05**.

Headers:

```http
Authorization: Bearer <anonymous_jwt>
apikey: <anon_or_publishable_key>
```

Request:

```json
{
  "invite_code": "ALPHA-TEST",
  "device_label": "optional",
  "request_id": "uuid"
}
```

Response:

```json
{
  "ok": true,
  "player": {
    "id": "uuid",
    "username": "guest_xxxxxxxx",
    "account_type": "guest",
    "level": 1,
    "xp": 0,
    "power": 0
  },
  "resources": {
    "almas": 0,
    "energia": 0,
    "sangue": 0,
    "cristais": 0,
    "ossos": 0,
    "diamante": 0
  },
  "build": {
    "weapon_type": "varinha_magica",
    "weapon_quality": "starter",
    "weapon_level": 1,
    "spell_slots": ["raio_cosmico"],
    "spells_unlocked": ["raio_cosmico"],
    "pet_id": "familiar_cinzento",
    "pet_level": 1,
    "passive_id": "foco_astral",
    "passive_level": 1
  }
}
```

Erros minimos: `UNAUTHENTICATED`, `INVALID_INVITE`, `INVITE_EXHAUSTED`, `ACCOUNT_ALREADY_CREATED`, `ACCOUNT_CREATE_FAILED`.

Idempotencia: repetir o mesmo `request_id` para a mesma sessao anonima retorna o mesmo payload sem consumir outro uso do convite.

### `GET /account/state`

Retorna estado minimo do jogador autenticado.

Status: **implementado em T00-P05**.

Response MVP:

```json
{
  "ok": true,
  "player": {
    "id": "uuid",
    "username": "guest_xxxxxxxx",
    "account_type": "guest",
    "level": 1,
    "xp": 0,
    "power": 0,
    "created_at": "iso-date",
    "updated_at": "iso-date"
  },
  "resources": {
    "player_id": "uuid",
    "almas": 0,
    "energia": 0,
    "sangue": 0,
    "cristais": 0,
    "ossos": 0,
    "diamante": 0,
    "updated_at": "iso-date"
  },
  "build": {
    "player_id": "uuid",
    "weapon_type": "varinha_magica",
    "weapon_quality": "starter",
    "weapon_level": 1,
    "spell_slots": ["raio_cosmico"],
    "spells_unlocked": ["raio_cosmico"],
    "pet_id": "familiar_cinzento",
    "pet_level": 1,
    "passive_id": "foco_astral",
    "passive_level": 1,
    "updated_at": "iso-date"
  },
  "last_battle_id": null
}
```

Erros minimos: `UNAUTHENTICATED`, `PLAYER_NOT_FOUND`, `ACCOUNT_STATE_INCOMPLETE`, `STATE_READ_FAILED`.

### `POST /battle/request`

Solicita batalha server-authoritative.

Request MVP:

```json
{
  "request_id": "uuid",
  "mode": "MVP_ONLY"
}
```

Response MVP:

```json
{
  "ok": true,
  "battle_log": {
    "schema_version": "battle_log_v1",
    "battle_id": "uuid",
    "seed": "string",
    "mode": "MVP_ONLY",
    "duration": 4.2,
    "participants": {
      "player": { "id": "uuid", "display_name": "Draxos" },
      "opponent": { "id": "mvp_training_bot", "display_name": "Bot de Treino", "is_bot": true }
    },
    "result": {
      "winner": "player",
      "reason": "opponent_defeated"
    },
    "events": []
  },
  "rewards": {
    "type": "MVP_ONLY"
  }
}
```

Erros minimos: `UNAUTHENTICATED`, `PLAYER_NOT_FOUND`, `BATTLE_RATE_LIMITED`, `SIMULATION_FAILED`.

### `GET /battle/latest`

Retorna a ultima batalha do jogador autenticado, sem reaplicar recompensa.

Response:

```json
{
  "ok": true,
  "battle_log": {}
}
```

## Endpoints Do Primeiro Slice Completo

| Metodo | Endpoint | Responsabilidade |
|---|---|---|
| POST | `/account/register` | Converter ou criar conta email/senha |
| POST | `/account/google/link` | Vincular Google Sign-In |
| POST | `/account/refresh` | Renovar sessao quando necessario |
| GET | `/player/profile` | Perfil, level, XP, poder e season |
| POST | `/build/equip` | Equipar arma, spells, passiva e pet |
| POST | `/upgrade/request` | Solicitar upgrade de arma, spell, pet, passiva, stats ou construcao |
| POST | `/base/collect` | Coletar recursos acumulados |
| POST | `/base/help/request` | Pedir ajuda em construcao |
| POST | `/base/help/send` | Enviar ajuda a amigo/guilda |
| GET | `/matchmaking/preview` | Exibir faixa e disponibilidade sem escolher oponente |
| GET | `/ranking/current` | Ranking da season atual |
| POST | `/friends/add` | Adicionar amigo por username ou codigo |
| GET | `/friends/list` | Listar amigos |
| POST | `/guild/create` | Criar guilda |
| POST | `/guild/join` | Entrar em guilda |
| GET | `/guild/state` | Estado da guilda, membros e construcoes |
| POST | `/guild/contribute` | Contribuir recursos para guilda |
| GET | `/chat/poll` | Buscar mensagens por canal |
| POST | `/chat/send` | Enviar mensagem direct/guilda |
| GET | `/battle-pass/state` | Estado do passe atual |
| POST | `/rewards/claim` | Coletar recompensa diaria/semanal/passe |

## Idempotencia

- Toda mutacao usa `request_id`.
- O servidor deve gravar requests processados por player e tipo de endpoint.
- Repetir o mesmo `request_id` retorna o mesmo resultado sem aplicar recompensa/custo de novo.

## Versionamento

- Mudancas quebrando payload devem criar novo campo `schema_version`.
- Cliente deve tolerar campos extras.
- Servidor deve rejeitar `schema_version` desconhecido apenas quando o payload depender dela.
