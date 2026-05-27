# API Endpoints Contract

- Ultima atualizacao: `2026-05-27`
- Status: contrato com `account/*`, `battle/*`, `base/*`, `social/*`, `competition/*`, `monetization/*`, `telemetry/*`, `progression-lab/*` e `release/*` implementados local/remoto; `battle/request` aceita `MVP_ONLY` e `FIRST_SLICE_SIM`; Track 03 implementou email/senha via `/account/bootstrap`, selecao de save via `x-draxos-save-type`, reset separado por save, aplicacao server-backed do Progression Lab no save `progression_lab`, Base/Social/Competicao/Loja jogaveis, leaderboard alpha com pontos por batalha normal e manifest/version gate de updates internos

Este documento descreve a interface logica entre cliente Godot e Supabase Edge Functions. A implementacao fisica pode organizar funcoes em subpastas, mas os nomes logicos abaixo devem permanecer estaveis para o cliente.

## Regras Gerais

- Transporte: HTTPS REST via HTTPRequest do Godot.
- Autenticacao: JWT Supabase no header `Authorization: Bearer <token>`.
- Save ativo: endpoints de gameplay aceitam `x-draxos-save-type: normal|progression_lab`; ausencia do header usa `normal`.
- Internal Alpha: cliente cria sessao Supabase Auth por email/senha; depois chama `/account/bootstrap` com JWT registrado, username e convite para criar o primeiro save.
- Guest dev: cliente ainda pode criar sessao Supabase Auth anonima e chamar `/account/guest`, mas esse fluxo e ferramenta de desenvolvimento/fallback e nao o caminho real da build interna.
- Correlation: cliente envia `request_id` em mutacoes para idempotencia.
- Runtime local atual: `supabase/functions/account`, `battle`, `base`, `social`, `competition`, `monetization`, `telemetry`, `progression-lab` e `release`, espelhados em `server/functions/`.
- Anti-lock-in: os endpoints logicos deste documento pertencem ao jogo, nao ao Supabase. O cliente Godot deve depender de `account`, `battle`, `base`, `social`, `competition`, `monetization`, `telemetry`, `progression-lab` e `release`, permitindo futura migracao para Backend Proprio + Postgres sem redesenhar o cliente.
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

## Endpoints De Release

### `GET /release/manifest`

Retorna o manifest publico de updates da Internal Alpha v0.

Status: **implementado em T03-P15**.

Auth: nao exige JWT. Pode receber `apikey` publica quando chamado pelo cliente Godot ou smokes.

Response:

```json
{
  "schema_version": "internal_alpha_manifest_v1",
  "channel": "internal_alpha",
  "latest_version": "0.0.1-alpha.0",
  "latest_version_code": 1,
  "minimum_supported_version": "0.0.1-alpha.0",
  "minimum_supported_version_code": 1,
  "released_at": "2026-05-27T00:00:00Z",
  "requires_save_reset": false,
  "portal_url": "PORTAL_URL_PENDING_T03_P16",
  "notes": ["Primeira release candidate interna."],
  "artifacts": {
    "android": { "label": "Android APK", "url": "ANDROID_APK_URL_PENDING_T03_P16" },
    "pc_windows": { "label": "PC Windows ZIP", "url": "PC_ZIP_URL_PENDING_T03_P16" },
    "web": { "label": "Web", "url": "WEB_GAME_URL_PENDING_T03_P16" }
  }
}
```

Regras do cliente:

- `latest_version_code` maior que o code local mostra update recomendado.
- `minimum_supported_version_code` maior que o code local bloqueia acoes online ate atualizar.
- `requires_save_reset` apenas avisa; reset destrutivo continua manual e documentado.

Contrato detalhado: `update-manifest.md`.

## Endpoints De Conta

### `POST /account/bootstrap`

Cria o save da Internal Alpha v0 para uma conta Supabase Auth registrada por email/senha.

Status: **implementado em T03-P14** para saves `normal` e `progression_lab`.

Headers:

```http
Authorization: Bearer <email_password_jwt>
apikey: <publishable_key>
x-draxos-save-type: normal
```

Request:

```json
{
  "invite_code": "ALPHA-TEST",
  "username": "draxos_tester",
  "device_label": "optional",
  "request_id": "uuid"
}
```

Regras:

- O JWT nao pode ser anonimo.
- O primeiro save da conta exige `invite_code` valido e `username`.
- `username` usa 3 a 24 caracteres: letras minusculas, numeros ou `_`.
- Quando `x-draxos-save-type = progression_lab`, o servidor cria o save Lab isolado com sufixo social `*_lab`.
- Depois que a conta ja possui um save, criar o outro save da mesma conta nao consome novo convite.
- Repetir o mesmo `request_id` para o save criado retorna o mesmo payload.

Response:

```json
{
  "ok": true,
  "player": {
    "id": "uuid",
    "username": "draxos_tester",
    "save_type": "normal",
    "account_type": "registered",
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
    "weapon_type": "varinha_cinzas",
    "weapon_quality": "starter",
    "weapon_level": 1,
    "spell_slots": ["sussurro_medo"],
    "spells_unlocked": ["sussurro_medo"],
    "pet_id": "corvo_pressagio",
    "pet_level": 1,
    "passive_id": "doutrina_pavor",
    "passive_level": 1
  }
}
```

Erros minimos: `UNAUTHENTICATED`, `AUTH_REQUIRES_EMAIL`, `INVALID_INVITE`, `INVITE_EXHAUSTED`, `INVALID_USERNAME`, `USERNAME_TAKEN`, `ACCOUNT_ALREADY_CREATED`, `ACCOUNT_CREATE_FAILED`.

### `POST /account/guest`

Cria o estado de jogo para uma sessao guest anonima ja autenticada. Na Internal Alpha v0 este fluxo fica como fallback dev/local; a build real usa `/account/bootstrap`.

Status: **implementado em T00-P05**, atualizado em `T03-P03B` para `save_type` e restringido em `T03-P14` a JWT anonimo.

Headers:

```http
Authorization: Bearer <anonymous_jwt>
apikey: <anon_or_publishable_key>
x-draxos-save-type: normal
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
    "save_type": "normal",
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
    "weapon_type": "varinha_cinzas",
    "weapon_quality": "starter",
    "weapon_level": 1,
    "spell_slots": ["sussurro_medo"],
    "spells_unlocked": ["sussurro_medo"],
    "pet_id": "corvo_pressagio",
    "pet_level": 1,
    "passive_id": "doutrina_pavor",
    "passive_level": 1
  }
}
```

Erros minimos: `UNAUTHENTICATED`, `AUTH_NOT_ANONYMOUS`, `INVALID_INVITE`, `INVITE_EXHAUSTED`, `ACCOUNT_ALREADY_CREATED`, `ACCOUNT_CREATE_FAILED`.

Idempotencia: repetir o mesmo `request_id` para a mesma sessao anonima retorna o mesmo payload sem consumir outro uso do convite.

### `GET /account/state`

Retorna estado minimo do jogador autenticado.

Status: **implementado em T00-P05**, atualizado em `T03-P03B` para `save_type` e validado em `T03-P14` com JWT anonimo e JWT email/senha.

Response MVP:

```json
{
  "ok": true,
  "player": {
    "id": "uuid",
    "username": "guest_xxxxxxxx",
    "save_type": "normal",
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
    "weapon_type": "varinha_cinzas",
    "weapon_quality": "starter",
    "weapon_level": 1,
    "spell_slots": ["sussurro_medo"],
    "spells_unlocked": ["sussurro_medo"],
    "pet_id": "corvo_pressagio",
    "pet_level": 1,
    "passive_id": "doutrina_pavor",
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
Em `T03-P07`, `FIRST_SLICE_SIM` tambem retorna `competition` e aplica pontos de arena no save `normal`. O save `progression_lab` recebe `excluded_reason = PROGRESSION_LAB_DOES_NOT_RANK`.

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
  },
  "competition": {
    "ranked": true,
    "season": { "id": "season_001", "display_name": "Season 1 Alpha" },
    "result": "loss",
    "scoring_model": "alpha_v0_power_adjusted",
    "arena_delta": 0,
    "arena_delta_raw": -5,
    "player_power": 50,
    "opponent_power": 180,
    "opponent": {
      "id": "bot_effect_trainer_01",
      "power": 180,
      "power_band": "band_002",
      "is_bot": true,
      "is_ranked": false
    },
    "ranking": {
      "season_id": "season_001",
      "player_id": "uuid",
      "arena_points": 0,
      "wins": 0,
      "losses": 1
    }
  }
}
```

Erros minimos: `UNAUTHENTICATED`, `PLAYER_NOT_FOUND`, `INVALID_BOT_ID`, `BATTLE_RATE_LIMITED`, `SIMULATION_FAILED`.

Idempotencia: repetir o mesmo `request_id` retorna o mesmo `battle_id`, `seed`, log, recompensa e payload competitivo, sem reaplicar XP/Ossos, recursos ou pontos de arena do primeiro slice.

`competition.arena_delta_raw` e o resultado direto da formula. `competition.arena_delta` e o delta aplicado depois do piso minimo de `0` pontos.

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

## Endpoints Planejados - Internal Alpha v0

Estes contratos sao alvo da Track 03 e ainda podem receber ajuste fino em `T03-P01`, antes da implementacao funcional.

### Supabase Auth email/senha

O cliente usa Supabase Auth nativo para email/senha:

- signup/login com email e senha;
- JWT Supabase no header `Authorization`;
- email confirmation desligado no projeto alpha;
- convite/flag alpha validado por Edge Function antes de criar/liberar saves.

### `POST /account/alpha/bootstrap`

Cria ou recupera a estrutura de conta do Internal Alpha v0 apos login email/senha.

Responsabilidades:

- validar JWT;
- validar convite/flag alpha;
- criar perfil alpha se necessario;
- garantir os saves `normal` e `progression_lab`;
- retornar resumo do save ativo e permissoes internas.

Request logico:

```json
{
  "invite_code": "ALPHA-TEST",
  "device_label": "optional",
  "request_id": "uuid"
}
```

### `GET /account/saves`

Retorna os dois saves da conta autenticada.

Response logico:

```json
{
  "ok": true,
  "saves": [
    { "save_type": "normal", "level": 1, "power": 0, "updated_at": "iso-date" },
    { "save_type": "progression_lab", "level": 10, "power": 500, "updated_at": "iso-date" }
  ]
}
```

### `POST /account/saves/reset`

Reseta apenas o save solicitado.

Status: **implementado localmente em T03-P03C**.

Headers:

```http
Authorization: Bearer <jwt>
apikey: <anon_or_publishable_key>
x-draxos-save-type: normal
```

Request logico:

```json
{
  "request_id": "uuid",
  "save_type": "normal"
}
```

Regras:

- `save_type` deve ser `normal` ou `progression_lab`.
- `save_type` no body, quando enviado, deve bater com `x-draxos-save-type`.
- Reset de um save nao altera o outro.
- Reset reconstrui o mesmo `player_id` para estado inicial: player level/xp/power, resources, build, base, batalha, ranking, social, loja, jobs, claims e compras alpha daquele save.
- Reset limpa ou desassocia telemetria daquele player, mas nao afeta o outro save da mesma conta.
- Reset grava ledger/audit alpha em `resource_transactions`.
- Repetir o mesmo `request_id` retorna o mesmo payload.

Response logico:

```json
{
  "ok": true,
  "reset": {
    "save_type": "normal",
    "player_id": "uuid",
    "request_id": "uuid"
  },
  "player": {},
  "resources": {},
  "build": {},
  "last_battle_id": null
}
```

### `POST /progression-lab/apply`

Aplica um estado gerado pelo Progression Lab no save `progression_lab`.

Status: **implementado localmente em T03-P04**.

Headers:

```http
Authorization: Bearer <jwt>
apikey: <anon_or_publishable_key>
x-draxos-save-type: progression_lab
```

Request logico:

```json
{
  "request_id": "uuid",
  "profile_id": "free_100_rewards",
  "milestone_id": "10h",
  "save_id": "free_100_rewards_10h"
}
```

Regras:

- endpoint interno/gated;
- exige permissao alpha interna;
- nunca escreve no save `normal`;
- nao atualiza ranking/social normal;
- payload referencia perfil/milestone/save gerado e o servidor valida contra o catalogo versionado de healthy saves;
- a aplicacao substitui player level/xp/power, resources, build, base, job ativo e Battle Pass do save `progression_lab`;
- a aplicacao limpa batalha, ranking, social vinculado ao player do Lab quando existir, loja anterior, jobs, claims, compras alpha, ledger e idempotencias de acoes daquele save;
- repetir o mesmo `request_id` retorna o mesmo payload;
- usar `x-draxos-save-type: normal` retorna `PROGRESSION_LAB_SAVE_REQUIRED`.

Response logico:

```json
{
  "ok": true,
  "applied": {
    "save_type": "progression_lab",
    "player_id": "uuid",
    "request_id": "uuid",
    "save_id": "free_100_rewards_10h",
    "profile_id": "free_100_rewards",
    "milestone_id": "10h"
  },
  "progression_lab": {
    "save_id": "free_100_rewards_10h",
    "profile_id": "free_100_rewards",
    "milestone_id": "10h",
    "local_only": false
  },
  "player": {},
  "resources": {},
  "build": {},
  "last_battle_id": null
}
```

### Save ativo nos endpoints de gameplay

Implementado localmente em `T03-P03B` por header HTTP:

- `x-draxos-save-type: normal` usa o save normal;
- `x-draxos-save-type: progression_lab` usa o save isolado de laboratorio;
- ausencia do header usa `normal`;
- valores diferentes retornam `INVALID_SAVE_TYPE`;
- `account`, `battle`, `base`, `competition`, `monetization` e `telemetry` resolvem o player pelo save ativo;
- `social` valida o save ativo, mas usa a identidade social de conta: o save `normal` e canonico quando existir; `progression_lab` aparece com marcador `lab` sem criar ranking;
- `competition/ranking/current` retorna `excluded_reason = PROGRESSION_LAB_DOES_NOT_RANK` no save de lab;
- permissao interna remota fina ainda fica para a etapa de auth/email e deploy remoto.

## Endpoints Do Primeiro Slice Completo

| Metodo | Endpoint | Responsabilidade |
|---|---|---|
| POST | `/account/register` | Converter ou criar conta email/senha |
| POST | `/account/google/link` | Vincular Google Sign-In |
| POST | `/account/refresh` | Renovar sessao quando necessario |
| GET | `/player/profile` | Perfil, level, XP, poder e season |
| POST | `/build/equip` | Equipar instrumento ritual, spells, doutrina/passiva e familiar/pet |
| POST | `/upgrade/request` | Solicitar upgrade de instrumento, spell, familiar, doutrina, stats ou construcao |
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
| POST | `/monetization/alpha-purchase` | Redeem/compra alpha simulada de Diamante, Premium, fila dupla e pacotes |
| POST | `/telemetry/client-event` | Registrar evento client-side nao autoritativo |

### `POST /build/equip`

Regras do primeiro slice:

- Cliente envia intencao de equipamento, nunca poder final.
- Servidor valida level, unlock, posse do conteudo e slot disponivel.
- Spell desbloqueada pode ser equipada em qualquer slot de spell liberado.
- Slot de spell 1 abre no level 3, slot 2 no level 7 e slot 3 no level 25.
- Slot de doutrina/passiva abre no level 10.
- Slot de familiar/pet abre no level 15.
- Servidor recalcula `players.power` apos sucesso.

Request logico:

```json
{
  "request_id": "uuid",
  "weapon": { "type": "varinha_cinzas", "quality": "starter" },
  "spell_slots": [
    { "slot_index": 1, "spell_id": "sussurro_medo" }
  ],
  "passive_id": "doutrina_pavor",
  "pet_id": "corvo_pressagio"
}
```

### `GET /base/state`

Status: **implementado em T00-P11; enriquecido para UI jogavel em T03-P05**.

Retorna o estado server-authoritative da Base v0. Ao carregar, o servidor conclui jobs vencidos antes de montar o payload.

Response v0:

```json
{
  "ok": true,
  "resources": {},
  "base": {
    "server_time": "2026-05-26T12:00:00.000Z",
    "construction_slots": 1,
    "structures": [
      {
        "structure_id": "nucleo_energia",
        "display_name": "Nucleo de Energia",
        "description": "Produz Energia, o gargalo principal das construcoes da base.",
        "benefit_label": "Energia para evoluir predios",
        "level": 0,
        "max_level": 40,
        "produces": "energia",
        "daily_production": 0,
        "storage_cap": 0,
        "pending_collectable": 0,
        "next_level": 1,
        "upgrade_cost": { "energia": 20 },
        "upgrade_duration_seconds": 120,
        "can_upgrade": false,
        "blocked_reason": "INSUFFICIENT_RESOURCES",
        "blocked_message": "Energia insuficiente para iniciar este upgrade.",
        "active_job": null
      }
    ],
    "jobs": []
  }
}
```

Campos de apresentacao como `description`, `benefit_label`, `upgrade_cost`, `upgrade_duration_seconds`, `can_upgrade`, `blocked_reason`, `blocked_message`, `active_job` e `jobs[].remaining_seconds` sao calculados no servidor para a UI nao precisar replicar regras economicas.

### `POST /base/collect`

Status: **implementado em T00-P11; usado pela UI jogavel da Base em T03-P05**.

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

Status: **implementado em T00-P12** como `GET /competition/matchmaking/preview`, refinado em `T03-P07`.

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
    "candidate_count": 6,
    "bots_included_in_leaderboard": false,
    "fallback_reason": "BOT_ALPHA_POOL"
  }
}
```

### `GET /ranking/current`

Status: **implementado em T00-P12** como `GET /competition/ranking/current`, refinado em `T03-P07`.

Retorna ranking da season ativa, cria a linha do jogador com `0` pontos quando necessario, limita a lista visivel ao top 10, inclui `self.rank` mesmo quando o jogador estiver fora do top e informa o modelo `alpha_v0_power_adjusted`. Bots nao entram no ranking, mas batalhas normais contra bots podem alterar pontos do jogador no alpha interno. No save `progression_lab`, retorna `self = null`, `entries = []` e `excluded_reason = PROGRESSION_LAB_DOES_NOT_RANK`.

### `GET /social/state`

Status: **implementado em T00-P12** e refinado em `T03-P06`.

Retorna identidade social de conta, amigos enriquecidos com username, guilda, membros, estruturas de guilda e ultimas mensagens de chat de guilda visiveis ao jogador. No save `progression_lab`, o payload traz `identity.viewer_badge = "lab"` e usa o save `normal` como identidade social canonica quando ele existir.

### `POST /friends/add`

Status: **implementado em T00-P12** como `POST /social/friends/add` e refinado em `T03-P06`.

Adiciona amizade aceita por username no alpha. Mutacao idempotente por `request_id`. Erros esperados: `USER_NOT_FOUND`, `INVALID_FRIEND`, `INVALID_REQUEST_ID`.

### `POST /guild/create`

Status: **implementado em T00-P12** como `POST /social/guild/create` e refinado em `T03-P06`.

Cria uma guilda alpha, adiciona o jogador como owner, cria as quatro estruturas de guilda v0 e canal de chat da guilda. Mutacao idempotente por `request_id`.

### `POST /guild/join`

Status: **implementado em T03-P06** como `POST /social/guild/join`.

Entra em uma guilda existente pelo nome. Mutacao idempotente por `request_id`. Erros esperados: `GUILD_NOT_FOUND`, `GUILD_ALREADY_JOINED`, `GUILD_FULL`, `INVALID_GUILD_NAME`.

### `POST /chat/send`

Status: **implementado em T00-P12** como `POST /social/chat/send` e refinado em `T03-P06`.

Envia mensagem para o chat de guilda por polling. Requer o jogador estar em guilda. Mutacao idempotente por `request_id`, limite de 280 caracteres e rate limit alpha por usuario/canal. Erros esperados: `GUILD_REQUIRED`, `EMPTY_MESSAGE`, `CHAT_RATE_LIMITED`.

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
    "shop_summary": {
      "environment": "internal_alpha_v0",
      "currency": "diamante",
      "diamond_balance": 0,
      "premium_unlocked": false,
      "daily_redeem_period_key": "2026-05-20",
      "daily_redeems_total": 4,
      "daily_redeems_claimed": 0,
      "reset_timezone": "America/Sao_Paulo"
    },
    "claimed": [],
    "alpha_purchases": [],
    "period_keys": {
      "daily": "2026-05-20",
      "weekly": "2026-W21",
      "battle_pass": "bp_s1_01",
      "alpha_redeem_daily": "2026-05-20"
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
  "product_id": "alpha_redeem_premium"
}
```

Product IDs v0:

- `alpha_redeem_small`: redeem diario pequeno, credita 150 Diamantes.
- `alpha_redeem_medium`: redeem diario medio, credita 500 Diamantes.
- `alpha_redeem_large`: redeem diario grande, credita 1200 Diamantes.
- `alpha_redeem_premium`: redeem diario premium, credita 3000 Diamantes.
- `alpha_battle_pass_premium`: gasta 1200 Diamantes e libera trilha premium do Battle Pass atual.
- `alpha_double_construction_queue`: gasta 900 Diamantes e libera 2 slots de construcao na Base do save.
- `alpha_energy_pack_small`: gasta 80 Diamantes e credita 80 Energia.
- `alpha_resource_pack_medium`: gasta 250 Diamantes e credita pacote misto de Almas, Energia, Sangue, Cristais e Ossos.

Regras:

- Redeems diarios entregam apenas Diamante, sao por save e resetam a meia-noite `America/Sao_Paulo`.
- `alpha_redeem_premium` deve cobrir Battle Pass + fila dupla + conveniencias principais da loja alpha do build.
- Repetir o mesmo `request_id` retorna o mesmo payload.
- Novo `request_id` para redeem ja resgatado no mesmo dia retorna `already_redeemed=true` sem duplicar recurso.
- Novo `request_id` para produto unico ja ativo retorna `already_owned=true` sem cobrar de novo.

Erros minimos: `UNAUTHENTICATED`, `PLAYER_NOT_FOUND`, `INVALID_REQUEST_ID`, `INVALID_PRODUCT`, `INSUFFICIENT_RESOURCES`, `ALPHA_PURCHASE_FAILED`.

### `POST /telemetry/client-event`

Evento nao autoritativo para UX e diagnostico. Combate, matchmaking, recompensa e snapshots de build devem ser gravados server-side durante os endpoints autoritativos.

Status: **implementado em Track 01**.

Request logico:

```json
{
  "schema_version": "telemetry_client_v1",
  "event_type": "screen_opened",
  "session_id": "uuid",
  "payload": {}
}
```

Regras:

- Requer JWT Supabase no header `Authorization`.
- Aceita `player_id = null` quando a sessao anonima ainda nao criou `players` via `account/guest`.
- Grava sempre `source = "client"` em `telemetry_events`.
- Escreve apenas telemetria; nunca muta recursos, ranking, recompensas, base, batalha ou estado social.
- Rejeita schema desconhecido com `UNSUPPORTED_SCHEMA`.

## Idempotencia

- Toda mutacao usa `request_id`.
- O servidor deve gravar requests processados por player e tipo de endpoint.
- Repetir o mesmo `request_id` retorna o mesmo resultado sem aplicar recompensa/custo de novo.

## Versionamento

- Mudancas quebrando payload devem criar novo campo `schema_version`.
- Cliente deve tolerar campos extras.
- Servidor deve rejeitar `schema_version` desconhecido apenas quando o payload depender dela.
