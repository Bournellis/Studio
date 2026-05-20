# API Endpoints Contract

- Ultima atualizacao: `2026-05-20`
- Status: contrato com `account/guest`, `account/state`, `battle/request` e `battle/latest` implementados localmente; `battle/request` aceita `MVP_ONLY` e `FIRST_SLICE_SIM`

Este documento descreve a interface logica entre cliente Godot e Supabase Edge Functions. A implementacao fisica pode organizar funcoes em subpastas, mas os nomes logicos abaixo devem permanecer estaveis para o cliente.

## Regras Gerais

- Transporte: HTTPS REST via HTTPRequest do Godot.
- Autenticacao: JWT Supabase no header `Authorization: Bearer <token>`.
- Guest MVP: cliente primeiro cria sessao Supabase Auth anonima; depois chama `/account/guest` com o JWT anonimo e codigo de convite.
- Correlation: cliente envia `request_id` em mutacoes para idempotencia.
- Runtime local atual: `supabase/functions/account/index.ts` e `supabase/functions/battle/index.ts`, espelhados em `server/functions/`.
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

Status: **implementado em T00-P07** para `MVP_ONLY`; **completo em T00-P10** para `FIRST_SLICE_SIM`.

Request MVP:

```json
{
  "request_id": "uuid",
  "mode": "MVP_ONLY"
}
```

Request primeiro slice v0:

```json
{
  "request_id": "uuid",
  "mode": "FIRST_SLICE_SIM",
  "opponent_bot_id": "bot_effect_trainer_01"
}
```

`opponent_bot_id` e opcional. Quando ausente, o servidor usa `bot_effect_trainer_01` como bot default do primeiro slice para garantir replay rico contra conta guest inicial.

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

Response primeiro slice v0:

```json
{
  "ok": true,
  "battle_log": {
    "schema_version": "battle_log_v1",
    "battle_id": "uuid",
    "seed": "first_slice:<player_id>:<request_id>",
    "mode": "FIRST_SLICE_SIM",
    "duration": 6.7,
    "participants": {
      "player": { "id": "uuid", "display_name": "Draxos" },
      "opponent": { "id": "bot_effect_trainer_01", "display_name": "Treinador de Efeitos", "is_bot": true }
    },
    "result": {
      "winner": "opponent",
      "reason": "combatant_defeated"
    },
    "events": []
  },
  "rewards": {
    "type": "FIRST_SLICE_SIM",
    "reward_id": "first_slice_battle_loss",
    "resources": {
      "xp": 10,
      "almas": 0.8,
      "energia": 0.4,
      "sangue": 0.2,
      "ossos": 0.04
    }
  }
}
```

Erros minimos: `UNAUTHENTICATED`, `PLAYER_NOT_FOUND`, `INVALID_BOT_ID`, `BATTLE_RATE_LIMITED`, `SIMULATION_FAILED`.

Idempotencia: repetir o mesmo `request_id` retorna o mesmo `battle_id`, `seed`, log e recompensa, sem reaplicar XP/Ossos ou recursos do primeiro slice.

### `GET /battle/latest`

Retorna a ultima batalha do jogador autenticado, sem reaplicar recompensa.

Status: **implementado em T00-P07**.

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
| POST | `/telemetry/client-event` | Registrar evento client-side nao autoritativo |

### `POST /build/equip`

Regras do primeiro slice:

- Cliente envia intencao de equipamento, nunca poder final.
- Servidor valida level, unlock, posse do conteudo e slot disponivel.
- Spell desbloqueada pode ser equipada em qualquer slot de spell liberado.
- Slot de spell 1 abre no level 3, slot 2 no level 7 e slot 3 no level 25.
- Slot de passiva abre no level 10.
- Slot de pet abre no level 15.
- Servidor recalcula `players.power` apos sucesso.

Request logico:

```json
{
  "request_id": "uuid",
  "weapon": { "type": "varinha_magica", "quality": "starter" },
  "spell_slots": [
    { "slot_index": 1, "spell_id": "raio_cosmico" }
  ],
  "passive_id": "foco_astral",
  "pet_id": "familiar_cinzento"
}
```

### `POST /telemetry/client-event`

Evento nao autoritativo para UX e diagnostico. Combate, matchmaking, recompensa e snapshots de build devem ser gravados server-side durante os endpoints autoritativos.

Request logico:

```json
{
  "schema_version": "telemetry_client_v1",
  "event_type": "screen_opened",
  "session_id": "uuid",
  "payload": {}
}
```

## Idempotencia

- Toda mutacao usa `request_id`.
- O servidor deve gravar requests processados por player e tipo de endpoint.
- Repetir o mesmo `request_id` retorna o mesmo resultado sem aplicar recompensa/custo de novo.

## Versionamento

- Mudancas quebrando payload devem criar novo campo `schema_version`.
- Cliente deve tolerar campos extras.
- Servidor deve rejeitar `schema_version` desconhecido apenas quando o payload depender dela.
