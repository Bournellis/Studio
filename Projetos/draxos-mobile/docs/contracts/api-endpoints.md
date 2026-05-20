# API Endpoints Contract

- Ultima atualizacao: `2026-05-20`
- Status: contrato com `account/*`, `battle/*`, `base/*`, `social/*`, `competition/*` e `monetization/*` implementados localmente; `battle/request` aceita `MVP_ONLY` e `FIRST_SLICE_SIM`

Este documento descreve a interface logica entre cliente Godot e Supabase Edge Functions. A implementacao fisica pode organizar funcoes em subpastas, mas os nomes logicos abaixo devem permanecer estaveis para o cliente.

## Regras Gerais

- Transporte: HTTPS REST via HTTPRequest do Godot.
- Autenticacao: JWT Supabase no header `Authorization: Bearer <token>`.
- Guest MVP: cliente primeiro cria sessao Supabase Auth anonima; depois chama `/account/guest` com o JWT anonimo e codigo de convite.
- Correlation: cliente envia `request_id` em mutacoes para idempotencia.
- Runtime local atual: `supabase/functions/account`, `battle`, `base`, `social`, `competition` e `monetization`, espelhados em `server/functions/`.
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
| GET | `/base/state` | Ler estruturas, fila, producao pendente e recursos |
| POST | `/base/upgrade` | Iniciar upgrade de estrutura permanente |
| POST | `/base/collect` | Coletar recursos acumulados offline |
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
| GET | `/monetization/state` | Estado do passe atual, recompensas, produtos alpha e claims |
| POST | `/monetization/rewards/claim` | Coletar recompensa diaria/semanal/passe |
| POST | `/monetization/alpha-purchase` | Compra alpha simulada de Premium/Diamante/pacotes |
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

### `GET /base/state`

Status: **implementado em T00-P11**.

Retorna o estado server-authoritative da Base v0. Ao carregar, o servidor conclui jobs vencidos antes de montar o payload.

Response v0:

```json
{
  "ok": true,
  "resources": {},
  "base": {
    "construction_slots": 1,
    "structures": [
      {
        "structure_id": "nucleo_energia",
        "display_name": "Nucleo de Energia",
        "level": 0,
        "produces": "energia",
        "daily_production": 0,
        "storage_cap": 0,
        "pending_collectable": 0
      }
    ],
    "jobs": []
  }
}
```

### `POST /base/collect`

Status: **implementado em T00-P11**.

Coleta producao offline de todas as estruturas produtoras, respeitando storage por estrutura. O cliente envia somente a intencao e um `request_id`; deltas sao calculados no servidor e gravados em `resource_transactions`.

Request:

```json
{
  "request_id": "uuid"
}
```

Erros minimos: `UNAUTHENTICATED`, `PLAYER_NOT_FOUND`, `INVALID_REQUEST_ID`, `BASE_COLLECT_FAILED`.

Idempotencia: repetir o mesmo `request_id` retorna o mesmo payload e nao duplica recurso nem ledger.

### `POST /base/upgrade`

Status: **implementado em T00-P11**.

Inicia upgrade de uma estrutura permanente da base. O servidor valida estrutura, fila, cap de level do jogador, custo em Energia e jobs ativos da mesma estrutura.

Request:

```json
{
  "request_id": "uuid",
  "structure_id": "nucleo_energia"
}
```

Erros minimos: `UNAUTHENTICATED`, `PLAYER_NOT_FOUND`, `INVALID_STRUCTURE`, `CONSTRUCTION_QUEUE_FULL`, `STRUCTURE_ALREADY_UPGRADING`, `LEVEL_CAP_REACHED`, `INSUFFICIENT_RESOURCES`, `BASE_UPGRADE_FAILED`.

Idempotencia: repetir o mesmo `request_id` retorna o mesmo job/payload e nao gasta Energia novamente.

### `GET /matchmaking/preview`

Status: **implementado em T00-P12** como `GET /competition/matchmaking/preview`.

Retorna a leitura server-authoritative da faixa de matchmaking e o fallback de bot do alpha. O cliente nao escolhe oponente nem envia poder final.

Response v0:

```json
{
  "ok": true,
  "matchmaking": {
    "player_power": 50,
    "tolerances": [
      { "after_seconds": 0, "max_difference_percent": 10 },
      { "after_seconds": 5, "max_difference_percent": 20 },
      { "after_seconds": 15, "max_difference_percent": 35 }
    ],
    "selected_opponent": {
      "id": "mvp_training_bot",
      "power": 50,
      "power_band": "MVP_ONLY",
      "is_bot": true,
      "is_ranked": false
    },
    "fallback_reason": "BOT_ALPHA_POOL"
  }
}
```

### `GET /ranking/current`

Status: **implementado em T00-P12** como `GET /competition/ranking/current`.

Retorna ranking da season ativa e cria a linha do jogador com `0` pontos quando necessario. Bots nao entram no ranking.

### `GET /social/state`

Status: **implementado em T00-P12**.

Retorna amigos, guilda, membros, estruturas de guilda e ultimas mensagens de chat de guilda visiveis ao jogador.

### `POST /friends/add`

Status: **implementado em T00-P12** como `POST /social/friends/add`.

Adiciona amizade aceita por username no alpha. Mutacao idempotente por `request_id`.

### `POST /guild/create`

Status: **implementado em T00-P12** como `POST /social/guild/create`.

Cria uma guilda alpha, adiciona o jogador como owner, cria as quatro estruturas de guilda v0 e canal de chat da guilda. Mutacao idempotente por `request_id`.

### `POST /chat/send`

Status: **implementado em T00-P12** como `POST /social/chat/send`.

Envia mensagem para o chat de guilda por polling. Requer o jogador estar em guilda. Mutacao idempotente por `request_id`.

### `GET /monetization/state`

Status: **implementado em T00-P13**.

Retorna estado server-authoritative da Loja alpha: Battle Pass ativo, progresso do jogador, recompensas diarias/semanais, rewards free/premium do passe, produtos alpha e claims recentes.

Response v0:

```json
{
  "ok": true,
  "player": {},
  "resources": {},
  "monetization": {
    "battle_pass": {
      "pass": {
        "id": "bp_s1_01",
        "season_id": "season_001",
        "display_name": "Battle Pass Alpha 01"
      },
      "progress": {
        "pass_xp": 0,
        "premium_unlocked": false
      },
      "rewards": []
    },
    "daily_rewards": [],
    "weekly_rewards": [],
    "alpha_products": [],
    "claimed": [],
    "period_keys": {
      "daily": "2026-05-20",
      "weekly": "2026-W21",
      "battle_pass": "bp_s1_01"
    }
  }
}
```

### `POST /monetization/rewards/claim`

Status: **implementado em T00-P13**.

Coleta recompensa diaria, semanal ou de Battle Pass. O cliente envia somente `reward_id` e `request_id`; XP, recursos, premium requirement, periodo e ledger sao decididos no servidor.

Request:

```json
{
  "request_id": "uuid",
  "reward_id": "daily_collect_base"
}
```

Reward IDs v0:

- Daily: `daily_first_victory`, `daily_second_victory`, `daily_third_victory`, `daily_collect_base`, `daily_build_or_upgrade`.
- Weekly: `weekly_arena_participation`, `weekly_arena_mastery`, `weekly_refuge_routine`.
- Battle Pass: `bp_free_tier_1`, `bp_premium_tier_1`.

Erros minimos: `UNAUTHENTICATED`, `PLAYER_NOT_FOUND`, `INVALID_REQUEST_ID`, `INVALID_REWARD`, `PREMIUM_REQUIRED`, `REWARD_CLAIM_FAILED`.

Idempotencia: repetir o mesmo `request_id` retorna o mesmo payload. Novo `request_id` para reward ja resgatada no mesmo periodo retorna `already_claimed=true` sem duplicar recurso.

### `POST /monetization/alpha-purchase`

Status: **implementado em T00-P13**.

Executa compra alpha simulada, sem gateway real de pagamento. Mutacoes continuam server-authoritative, com ledger e idempotencia.

Request:

```json
{
  "request_id": "uuid",
  "product_id": "alpha_diamante_500"
}
```

Product IDs v0:

- `alpha_battle_pass_premium`: libera trilha premium do Battle Pass atual.
- `alpha_diamante_500`: credita 500 Diamantes para teste alpha.
- `alpha_energy_pack_small`: gasta 80 Diamantes e credita 80 Energia.

Erros minimos: `UNAUTHENTICATED`, `PLAYER_NOT_FOUND`, `INVALID_REQUEST_ID`, `INVALID_PRODUCT`, `INSUFFICIENT_RESOURCES`, `ALPHA_PURCHASE_FAILED`.

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
