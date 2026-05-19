# API Endpoints Contract

- Ultima atualizacao: `2026-05-19`
- Status: contrato inicial antes das Edge Functions reais

Este documento descreve a interface logica entre cliente Godot e Supabase Edge Functions. A implementacao fisica pode organizar funcoes em subpastas, mas os nomes logicos abaixo devem permanecer estaveis para o cliente.

## Regras Gerais

- Transporte: HTTPS REST via HTTPRequest do Godot.
- Autenticacao: JWT Supabase no header `Authorization: Bearer <token>`, exceto criacao inicial de guest.
- Correlation: cliente envia `request_id` em mutacoes para idempotencia.
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

Cria conta guest com codigo de convite.

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
  "session": {
    "access_token": "jwt",
    "refresh_token": "token",
    "expires_at": "iso-8601"
  },
  "player": {
    "id": "uuid",
    "account_type": "guest",
    "level": 1,
    "xp": 0
  }
}
```

Erros minimos: `INVALID_INVITE`, `INVITE_EXHAUSTED`, `ACCOUNT_CREATE_FAILED`.

### `GET /account/state`

Retorna estado minimo do jogador autenticado.

Response MVP:

```json
{
  "ok": true,
  "player": {},
  "resources": {},
  "build": {},
  "last_battle_id": "uuid-or-null"
}
```

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
  "battle": {
    "battle_id": "uuid",
    "schema_version": "battle_log_v1",
    "result": "win",
    "log": {}
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
  "battle": {}
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
