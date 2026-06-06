# API Endpoints Contract

- Ultima atualizacao: `2026-06-06`
- Status: contrato com `account/*`, `battle/*`, `base/*`, `build/*`, `crafting/*`, `social/*`, `competition/*`, `monetization/*`, `telemetry/*`, `progression-lab/*`, `release/*`, `content/*`, `arena/pve/*`, `modes/*` e `lab-runner/*` implementados local/remoto; Bosque Fogueira Potion Crafting v1 adiciona `POST /crafting/station-craft` como ponte transacional entre progresso duravel do Bosque e consumiveis globais da conta.

Este documento descreve a interface logica entre cliente Godot e Supabase Edge Functions. A implementacao fisica pode organizar funcoes em subpastas, mas os nomes logicos abaixo devem permanecer estaveis para o cliente.

## Regras Gerais

- Transporte: HTTPS REST via HTTPRequest do Godot.
- Versao da API: usar header unico `x-draxos-api-version: 1`. A ausencia do header ainda e tolerada pelos endpoints alpha atuais; valor explicito diferente de `1` deve falhar com `UNSUPPORTED_API_VERSION`.
- Autenticacao: JWT Supabase no header `Authorization: Bearer <token>`. Endpoints migrados para o helper compartilhado de auth tambem verificam o bearer em `/auth/v1/user` antes de usar `auth_user_id`.
- Save ativo: endpoints de gameplay aceitam `x-draxos-save-type: normal|progression_lab`; ausencia do header usa `normal`.
- Internal Alpha: cliente cria sessao Supabase Auth por email/senha; depois chama `/account/bootstrap` com JWT registrado, username e convite para criar o primeiro save.
- Guest dev: cliente ainda pode criar sessao Supabase Auth anonima e chamar `/account/guest`, mas esse fluxo e ferramenta de desenvolvimento/fallback e nao o caminho real da build interna.
- Correlation: cliente envia `request_id` em mutacoes para idempotencia. Mutacoes economicas novas tambem devem enviar `request_hash`, calculado pelo cliente/adapter sobre a intencao canonica, para bloquear reuse malicioso do mesmo `request_id` com outro payload.
- Runtime local atual: `supabase/functions/healthcheck`, `account`, `battle`, `base`, `build`, `crafting`, `social`, `competition`, `monetization`, `telemetry`, `progression-lab`, `release` e `content`, espelhados em `server/functions/`.
- Anti-lock-in: os endpoints logicos deste documento pertencem ao jogo, nao ao Supabase. O cliente Godot e o hub alpha devem depender de `account`, `battle`, `base`, `build`, `crafting`, `social`, `competition`, `monetization`, `telemetry`, `progression-lab`, `release` e `content`, permitindo futura migracao para Backend Proprio + Postgres sem redesenhar o cliente/site.
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

## Envelope V1

Todos os envelopes novos ou ampliados devem declarar `schema_version` quando o payload tiver contrato proprio. Payloads de estado e mutations que retornam estado de superficie devem incluir contexto explicito quando disponivel, alem de metadata de cache/tempo para o cliente renderizar cache imediato e medir refresh:

```json
{
  "schema_version": "account_state_v1",
  "ok": true,
  "api_version": "app_responsiveness_v1",
  "account": {
    "account_profile_id": "uuid",
    "auth_user_id": "uuid"
  },
  "save": {
    "game_save_id": "uuid",
    "save_type": "normal",
    "legacy_player_id": "uuid",
    "ruleset_id": "foundation_ruleset_v0",
    "ruleset_version": 1
  },
  "cache": {
    "surface": "account",
    "generated_at": "2026-06-02T12:00:00.000Z"
  },
  "server_timing": {
    "duration_ms": 42
  }
}
```

Estado esperado para expansao: `account/state`, `base/state`, `build/state`, `crafting/state`, `social/state`, `competition/*`, `monetization/state`, `battle/latest`, `battle/history`, `battle/replay`, `arena/pve/state`, `modes/*` e `lab-runner/*` retornam envelope comum local. Enquanto estiverem em compatibilidade, `player`, `save_type` e `x-draxos-save-type` continuam validos.

Regras de responsividade:

- O cliente pode renderizar snapshot local antes da rede, mas deve sinalizar `source=cache`.
- `cache.generated_at` e `server_timing.duration_ms` sao informativos; nao autorizam resultado otimista.
- Resultado de batalha, duelo de Arena, ranking, recompensa e economia continuam server-authoritative.
- Respostas antigas de refresh nao devem sobrescrever estado mais novo no cliente; a shell usa lifecycle token por superficie.

## Idempotencia V1

Mutacoes economicas novas devem seguir:

- exigir `request_id`;
- exigir `request_hash`;
- reservar idempotencia com status `pending`;
- aplicar estado, ledger e resposta na mesma transacao ou em RPC que falhe sem estado parcial;
- gravar status `completed` com `response_payload`;
- gravar status `failed` com payload seguro quando uma reserva precisar ser encerrada;
- repetir o mesmo `request_id` + `request_hash` retorna o mesmo `response_payload`;
- repetir o mesmo `request_id` com `request_hash` diferente retorna `IDEMPOTENCY_HASH_MISMATCH`.

RPCs de apoio: `reserve_idempotency`, `complete_idempotency`, `fail_idempotency`.

## Mutations V1

As rotas abaixo usam ou reservam RPCs transacionais. O status `ativo` significa
que o adapter HTTP ja chama o RPC v1; `reservado` significa que o RPC existe
como slot contratado, mas a rota ainda precisa migrar o efeito de dominio.

| Endpoint logico | RPC transacional alvo | Status |
|---|---|---|
| `POST /battle/request` | `request_battle_v1` | ativo em `202605300003_remaining_transactional_domain_enforcement.sql` para `FIRST_SLICE_SIM`, que e modo tecnico de simulador/replay do primeiro slice, nao modo de produto; simulacao continua no adapter e persistencia/reward/consumables/ranking/idempotencia entram no RPC |
| `POST /base/collect` | `collect_base_v1` | ativo em `202605300002_transactional_domain_enforcement.sql`; adapter preserva payload de UI e move recursos/ledger/idempotencia para RPC |
| `POST /base/upgrade` | `start_base_upgrade_v1` | ativo em `202605300002_transactional_domain_enforcement.sql`; adapter preserva payload de UI e move gasto/job/ledger/idempotencia para RPC |
| `POST /build/equip` | `equip_build_v1` | ativo em `202605300003_remaining_transactional_domain_enforcement.sql`; build + power são aplicados no mesmo RPC |
| `POST /crafting/craft` | `craft_item_v1` | ativo em `202605300003_remaining_transactional_domain_enforcement.sql`; recurso + item + ledgers entram no mesmo RPC; receitas com `station_id` retornam `STATION_REQUIRED` |
| `POST /crafting/station-craft` | `craft_station_item_v1` | ativo em `202606060003_bosque_fogueira_potion_crafting_v1.sql`; valida Fogueira, checkpoint aceito, progresso duravel, materiais do Bau, recurso global, output e idempotencia |
| `POST /monetization/rewards/claim` | `claim_reward_v1` | ativo em `202605300003_remaining_transactional_domain_enforcement.sql`; claim + XP/recurso/pass/ledger/idempotência entram no mesmo RPC |
| `POST /monetization/alpha-purchase` | `alpha_purchase_v1` | ativo em `202605300003_remaining_transactional_domain_enforcement.sql`; custo/recompensa/premium/compra/ledger/idempotência entram no mesmo RPC |
| `POST /social/guild/create` | `guild_create_v1` | ativo em `202605300003_remaining_transactional_domain_enforcement.sql`; guilda + owner + estruturas + canal + idempotência entram no mesmo RPC |
| `POST /social/guild/join` | `guild_join_v1` | ativo em `202605300003_remaining_transactional_domain_enforcement.sql`; membership + contador + idempotência entram no mesmo RPC |

| `POST /build/spell-behavior` | `build_spell_behavior_v1` | ativo em `202605300004_foundation_closeout.sql`; comportamento de spell equipada + idempotencia entram no mesmo RPC |
| `POST /build/potion/equip` | `build_potion_equip_v1` | ativo em `202605300004_foundation_closeout.sql`; slot de pocao + idempotencia entram no mesmo RPC |
| `POST /build/potion-behavior` | `build_potion_behavior_v1` | ativo em `202605300004_foundation_closeout.sql`; comportamento de pocao + idempotencia entram no mesmo RPC |
| `POST /social/friends/add` | `social_friend_add_v1` | ativo em `202605300004_foundation_closeout.sql`; amizade bidirecional + idempotencia entram no mesmo RPC |
| `POST /social/chat/send` | `social_chat_send_v1` | ativo em `202605300004_foundation_closeout.sql`; mensagem/rate-limit + idempotencia entram no mesmo RPC |

Nenhuma rota nova deve expandir economia sem passar para o padrao v1.

## Classificacao De Escopo - Track 05

Todo endpoint atual ou futuro deve declarar um dos escopos abaixo antes de
entrar em codigo, smoke, migration ou documentacao publica de payload.

- `save-scoped`: resolve o jogador pelo save ativo (`x-draxos-save-type`), com
  ausencia do header usando `normal`. Leituras e mutacoes atingem somente esse
  save.
- `account-scoped`: resolve identidade de conta, social ou relacionamento que
  atravessa saves. Pode validar o save ativo, mas nao deve contaminar o save
  `normal` com estado do `progression_lab`.
- `release`: endpoint publico/operacional sem JWT obrigatorio e sem leitura ou
  escrita de gameplay.
- `telemetry`: endpoint de diagnostico/UX; pode associar evento ao save ativo
  quando existir, mas nunca concede recurso, ranking, recompensa ou progresso.
- `mode`: endpoint de leitura/ops por modo, como registry e analytics
  agregados. Exige JWT em V1 e nao concede progresso por si so.
- `admin-internal`: superficie interna de administracao, suporte e diagnostico,
  sempre `service_role`-only e auditavel. Nao ha painel publico nesta etapa.

Regra para endpoints novos: adicionar `Scope: <valor>` na secao do endpoint,
declarar se usa `x-draxos-save-type`, declarar o dono da idempotencia
(`player_id`, identidade social/account ou nenhum) e apontar o teste/smoke
existente ou novo que cobre esse comportamento. Esta Track 05 nao cria endpoint
novo.

### Matriz Atual De Endpoints

| Metodo | Endpoint / funcao | Escopo | Save header | Idempotencia | Observacao |
|---|---|---|---|---|---|
| GET | `/healthcheck` | `release` | Nao | Nao | Healthcheck operacional local/remoto; nao le gameplay. |
| GET | `/release/manifest` | `release` | Nao | Nao | Manifest publico de update/version gate. |
| GET | `/release/config` | `release` | Nao | Nao | Runtime config publico read-only com flags T06; nao le secrets, gameplay state nem tuning. |
| GET | `/release/download` | `release` | Nao | Nao | Gera URL assinada temporaria para APK/PC quando downloads privados estiverem ativos. |
| GET | `/content/grimoire` | `release` | Nao | Nao | Catalogo privado do Grimorio para o hub alpha; exige JWT email/senha com save `normal`. |
| POST | `/lab-runner/battle` | `release` | Nao | Nao | Interno alpha para Web Battle Lab; exige JWT email/senha com save `normal`, nao escreve arquivos e nao muta economia/ranking. |
| POST | `/lab-runner/progression` | `release` | Nao | Nao | Interno alpha para Web Progression Lab; exige JWT email/senha com save `normal`, retorna dados in-memory e nao aplica healthy save. |
| POST | `/account/bootstrap` | `save-scoped` | Sim | `request_id` por save | Cria/recupera o save `normal` ou `progression_lab` de conta registrada; o gate de convite e account-aware. |
| POST | `/account/guest` | `save-scoped` | Sim | `request_id` por save | Fallback dev/local anonimo; cria/recupera o save selecionado. |
| GET | `/account/state` | `save-scoped` | Sim | Nao | Retorna snapshot do save ativo. |
| POST | `/account/saves/reset` | `save-scoped` | Sim | `request_id/request_hash` por save | Reseta apenas o save ativo via RPC v1, exige consistencia entre body/header e preserva estado social account-wide. |
| POST | `/battle/request` | `save-scoped` | Sim | `request_id` por save | Rota tecnica de simulador/replay (`FIRST_SLICE_SIM`) para o primeiro slice; aplica recompensa/ranking do save ativo e bloqueia ranking do Lab, mas nao define o produto atual. |
| GET | `/battle/latest` | `save-scoped` | Sim | Nao | Retorna ultima batalha do save ativo sem reaplicar efeitos. |
| GET | `/battle/history` | `save-scoped` | Sim | Nao | Retorna historico recente do save ativo como sumarios read-only, sem eventos completos. |
| GET | `/battle/replay?battle_id=...` | `save-scoped` | Sim | Nao | Retorna o `battle_log_v1` salvo de uma batalha do save ativo, sem rerodar simulador nem reaplicar recompensa. |
| GET | `/arena/pve/state` | `save-scoped` | Sim | Nao | Projecao leve da Arena PVE: arenas, unlocks, recordes, tentativas recentes e `active_attempt`; nao carrega loadout completo, inventario, potion slots ou spell behaviors. |
| POST | `/arena/pve/start` | `save-scoped` | Sim | `request_id/request_hash` por save | Implementado/publicado para criar tentativa, travar loadout e gerar primeiro inimigo. |
| POST | `/arena/pve/duel/request` | `save-scoped` | Sim | `request_id/request_hash` por save | Implementado/publicado para resolver o proximo duelo da tentativa via simulador server-authoritative; no ultimo duelo aplica recompensa/progresso. |
| POST | `/arena/pve/buff/select` | `save-scoped` | Sim | `request_id/request_hash` por save | Endpoint publico oficial implementado/publicado para escolher 1 buff ofertado apos vitoria. |
| POST | `/arena/pve/claim` | `save-scoped` | Sim | `request_id/request_hash` por save | Implementado/publicado como resumo/ack idempotente; nao muta economia; retorna `arena_state` leve para atualizar selecao sem fetch imediato. |
| POST | `/arena/pve/abandon` | `save-scoped` | Sim | `request_id/request_hash` por save | Implementado/publicado para encerrar tentativa sem recompensa de conclusao. |
| GET | `/base/state` | `save-scoped` | Sim | Nao | Estado server-authoritative da Base do save ativo. |
| POST | `/base/collect` | `save-scoped` | Sim | `request_id/request_hash` por save | Coleta recursos do save ativo via RPC transacional com ledger. |
| POST | `/base/upgrade` | `save-scoped` | Sim | `request_id/request_hash` por save | Inicia upgrade da Base do save ativo via RPC transacional com ledger. |
| GET | `/crafting/state` | `save-scoped` | Sim | Nao | Recursos, Po de Osso, receitas, inventario de consumiveis e slot de pocao. |
| POST | `/crafting/crush-bones` | `save-scoped` | Sim | `request_id/request_hash` por save | Tritura Ossos em Po de Osso sem duplicar por retry. |
| POST | `/crafting/craft` | `save-scoped` | Sim | `request_id/request_hash` por save | Cria consumiveis a partir de receitas server-authoritative sem estacao; receitas de Fogueira retornam `STATION_REQUIRED`. |
| POST | `/crafting/station-craft` | `save-scoped` | Sim | `request_id/request_hash` por save | Cria consumiveis globais em uma estacao validando progresso duravel do Bosque e recursos da conta. |
| GET | `/build/state` | `save-scoped` | Sim | Nao | Loadout atual, opcoes humanizadas, bloqueios, comportamentos e pocao equipada. |
| POST | `/build/equip` | `save-scoped` | Sim | `request_id/request_hash` por save | Equipa instrumento, spells, doutrina e familiar com validacao server-side. |
| POST | `/build/spell-behavior` | `save-scoped` | Sim | `request_id/request_hash` por save | Atualiza comportamento de uma spell equipada. |
| POST | `/build/potion/equip` | `save-scoped` | Sim | `request_id/request_hash` por save | Equipa/remove pocao no slot 1. |
| POST | `/build/potion-behavior` | `save-scoped` | Sim | `request_id/request_hash` por save | Atualiza comportamento da pocao do slot 1. |
| GET | `/social/state` | `account-scoped` | Sim, validado | Nao | Usa identidade social canonica da conta; Lab recebe marcador `lab`. |
| POST | `/social/friends/add` | `account-scoped` | Sim, validado | `request_id/request_hash` na identidade social | Amizade por username na identidade social canonica. |
| POST | `/social/guild/create` | `account-scoped` | Sim, validado | `request_id/request_hash` na identidade social | Cria guilda e membership para a identidade social canonica. |
| POST | `/social/guild/join` | `account-scoped` | Sim, validado | `request_id/request_hash` na identidade social | Entra em guilda pela identidade social canonica. |
| POST | `/social/chat/send` | `account-scoped` | Sim, validado | `request_id/request_hash` na identidade social | Envia chat de guilda; nao concede progresso. |
| GET | `/competition/matchmaking/preview` | `save-scoped` | Sim | Nao | Preview do save ativo; `progression_lab` pode ver preview sem ranquear. |
| GET | `/competition/ranking/current` | `save-scoped` | Sim | Nao | Ranking do save `normal`; Lab retorna exclusao explicita. |
| GET | `/monetization/state` | `save-scoped` | Sim | Nao | Loja/Battle Pass do save ativo. |
| POST | `/monetization/rewards/claim` | `save-scoped` | Sim | `request_id/request_hash` por save | Claim economico do save ativo com ledger. |
| POST | `/monetization/alpha-purchase` | `save-scoped` | Sim | `request_id/request_hash` por save | Compra/redeem alpha do save ativo com ledger; resposta retorna `monetization`, `resources/player` quando afetados e delta `base` quando produto impacta Refugio/fila. |
| POST | `/telemetry/client-event` | `telemetry` | Sim, opcional | Nao | Grava diagnostico client; novos eventos permitidos incluem `request_latency`, `surface_refresh`, `surface_cache_rendered` e `action_latency`; `player_id` pode ser nulo antes de conta/save. |
| POST | `/progression-lab/apply` | `save-scoped` | Sim, exige `progression_lab` | `request_id/request_hash` por save Lab | Interno/gated; aplica healthy save apenas no Lab e nunca escreve no Normal; reset/seed Track 16 acontece dentro da RPC transacional. |
| GET | `/modes/registry` | `mode` | Sim | Nao | Registry dos cinco modos oficiais. |
| GET | `/modes/state?mode_id=<id>` | `save-scoped` | Sim | Nao | Estado de um modo no save ativo; Openworld retorna `active_session` com snapshot/revision quando retomavel. |
| POST | `/modes/session/start` | `save-scoped` | Sim | `request_id/request_hash` por modo/save | Inicia sessao generica para modos que usam Mode sessions. |
| POST | `/modes/session/event` | `save-scoped` | Sim | `request_id/request_hash` por modo/save/revision | Atualiza snapshot remoto de modo event-sourced e rejeita stale revision. |
| POST | `/modes/session/complete` | `save-scoped` | Sim | `request_id/request_hash` por modo/save | Completa sessao e aplica Reward Bridge server-authoritative a partir do snapshot validado. |
| POST | `/modes/session/abandon` | `save-scoped` | Sim | `request_id/request_hash` por modo/save | Abandona sessao iniciada. |
| GET | `/modes/analytics/summary` | `mode` | Sim | Nao | Sumario interno por modo. |
| POST | `/modes/admin/*` | `admin-internal` | Sim + `admin_roles` | `request_id/request_hash` nas mutacoes | Ops de disable/enable, sessao, reconcile e compensacao auditada. |

`mode` analytics e `admin-internal` Mode Ops sao superficies fora do cliente:
o client Godot nao deve expor `modes_ops`, botoes admin ou wrappers diretos
para `/modes/admin/*`.

`admin-internal` existe apenas como RPC `service_role`-only no banco:
`admin_lookup_account_v1`, `admin_battle_diagnostics_v1`,
`resource_reconciliation_report_v1`, `admin_adjust_resource_balance_v1` e
`admin_flag_account_v1`. Mode admin tambem usa RPCs `service_role`-only:
`admin_set_mode_status_v1`, `admin_expire_mode_session_v1` e
`admin_invalidate_mode_session_v1`. Nenhum deles e endpoint publico ou chamada
de cliente.

`/modes` e o contrato ativo da Minigame Platform V1. `/minigames` nao e contrato ativo nesta publicacao.

## Endpoints Internos De Lab Runner

Status: **implementado e publicado remotamente para Web Labs no pacote Remote
Lab Runner**.

Scope: `release`.

Auth comum: exige JWT Supabase de conta email/senha da Internal Alpha, nao
anonima, com save `normal` registrado. Essa e a mesma allowlist operacional do
Supabase usada para entrar no jogo; nao ha lista separada para Labs.

Save header: nao usa `x-draxos-save-type`. O endpoint apenas verifica que a
conta tem acesso alpha normal antes de gerar dados de diagnostico.

Idempotencia: nao se aplica; endpoints nao mutam banco, arquivos, recursos,
ranking, XP, progresso, potion stock ou ledger.

### `POST /lab-runner/battle`

Executa Battle Lab em memoria para o Web export, usando o simulador tecnico e o
modelo lab versionado. Substitui o processo local `npx/deno` quando o browser
nao pode iniciar executaveis.

Request:

```json
{
  "request": {
    "mode": "run",
    "run_id": "scratch_2026-05-31T14-46-59"
  }
}
```

Response minima:

```json
{
  "schema_version": "battle_lab_response_v1",
  "ok": true,
  "runner": "remote",
  "mutates_files": false,
  "status": "PASS",
  "summary": {},
  "checks": [],
  "outliers": [],
  "arena_sequences": [],
  "replays": []
}
```

Regras:

- `mode: replay` retorna replay custom de sessao.
- `mode: run` retorna resumo, checks, outliers, sequencias de Arena PVE e
  amostras de replay em memoria.
- Nao grava `docs/battle-lab/generated`, `.battle_lab_scratch` nem
  `docs/battle-lab/runs`.
- `Arquivar Run Oficial` continua fluxo local/editor.

### `POST /lab-runner/progression`

Executa Progression Lab em memoria para o Web export e retorna o dataset
calculado para a tela.

Request:

```json
{}
```

Response minima:

```json
{
  "schema_version": "progression_lab_remote_response_v1",
  "ok": true,
  "runner": "remote",
  "mutates_files": false,
  "status": "REVIEW",
  "summary": {},
  "data": {}
}
```

Regras:

- Nao grava `docs/progression-lab/generated` nem
  `.progression_lab_scratch`.
- Nao substitui `POST /progression-lab/apply`.
- Aplicacao de healthy save continua restrita ao endpoint separado
  `progression-lab/apply`, ao save `progression_lab`.

## Endpoints De Arena PVE v1

Status: **implementado/publicado em Track 18; Track 19 Arena Consistency Pass publicado**.

Contrato de produto: `../pve-arena-v1.md`.

Regras comuns:

- Scope: `save-scoped`.
- Save authority: resolver e travar `game_saves.id`; `players.save_type` fica apenas como compatibilidade alpha.
- Idempotencia: mutacoes exigem `request_id` e `request_hash`.
- Ruleset: toda tentativa, duelo e recompensa persistem `ruleset_publication_id`, `ruleset_id`, `ruleset_version`, `ruleset_content_hash`, `ruleset_simulator_hash` e `ruleset_schema_version`.
- Ranking: Arena PVE v1 nao insere nem atualiza `ranking`.
- Cooldown: nenhum endpoint de Arena PVE pode impor cooldown de combate.
- Loadout: `arena/pve/start` grava snapshot/hash de loadout; endpoints seguintes nao aceitam troca de loadout.
- Comportamento: ajustes simples entre duelos devem reutilizar `build/spell-behavior` e `build/potion-behavior` ate haver contrato proprio.
- Recompensa: perfis calibraveis vivem em `arena_reward_profiles` e espelham `data/definitions/arena_rewards.json`; o ultimo `/arena/pve/duel/request` da tentativa aplica recompensa/progresso e ledger `arena_pve_v1`; `/arena/pve/claim` e apenas resumo/ack idempotente, retorna `mutates_economy: false` e inclui `arena_state` leve para o cliente voltar a selecao sem buscar `/arena/pve/state` imediatamente.
- Buff endpoint publico: novos clients, docs e smokes devem usar `/arena/pve/buff/select`. `/arena/buff/choose` existe apenas como alias interno/compatibilidade.

### `GET /arena/pve/state`

Leitura do estado de Arena PVE do save ativo.

Response contratada:

```json
{
  "ok": true,
  "schema_version": "pve_arena_state_v1",
  "arenas": [],
  "active_attempt": null,
  "records": [],
  "reward_limits": {
    "daily_key": "2026-05-31",
    "weekly_key": "2026-W22"
  }
}
```

### `POST /arena/pve/start`

Cria ou recupera tentativa ativa de arena.

Request:

```json
{
  "request_id": "uuid",
  "request_hash": "sha256:...",
  "arena_id": "arena_cinzas_curta",
  "difficulty_tier": 1
}
```

Response minima:

```json
{
  "ok": true,
  "schema_version": "pve_arena_attempt_v1",
  "attempt": {
    "attempt_id": "uuid",
    "arena_id": "arena_cinzas_curta",
    "difficulty_tier": 1,
    "duel_index": 1,
    "duel_count": 3,
    "state": "active",
    "locked_loadout_hash": "sha256:...",
    "next_enemy_id": "pve_aprendiz_cinzas"
  }
}
```

Erros minimos: `INVALID_ARENA`, `ARENA_LOCKED`, `ACTIVE_ARENA_ATTEMPT_EXISTS`, `INVALID_REQUEST_ID`, `IDEMPOTENCY_HASH_MISMATCH`, `ARENA_START_FAILED`.

### `POST /arena/pve/duel/request`

Resolve o proximo duelo da tentativa. O servidor seleciona o inimigo da sequencia, aplica buffs acumulados, reseta HP para 100% no inicio do duelo e grava battle log `battle_log_v1` com metadata de arena. Quando este request resolve o ultimo duelo da tentativa, ele tambem aplica recompensa/progresso, ledger `arena_pve_v1` e response idempotente.

Request:

```json
{
  "request_id": "uuid",
  "request_hash": "sha256:...",
  "attempt_id": "uuid"
}
```

Erros minimos: `ARENA_ATTEMPT_NOT_FOUND`, `ARENA_ATTEMPT_NOT_ACTIVE`, `ARENA_DUEL_ALREADY_RESOLVED`, `ARENA_DUEL_FAILED`, `IDEMPOTENCY_HASH_MISMATCH`.

### `POST /arena/pve/buff/select`

Endpoint publico oficial para escolher 1 buff de uma oferta gerada pelo servidor depois de uma vitoria que ainda tem proximo duelo. O alias `/arena/buff/choose` deve ser tratado apenas como compatibilidade interna.

Request:

```json
{
  "request_id": "uuid",
  "request_hash": "sha256:...",
  "attempt_id": "uuid",
  "offer_id": "uuid",
  "buff_id": "arena_buff_potencia_menor"
}
```

Erros minimos: `ARENA_ATTEMPT_NOT_FOUND`, `BUFF_OFFER_NOT_FOUND`, `BUFF_NOT_OFFERED`, `BUFF_ALREADY_SELECTED`, `ARENA_BUFF_SELECT_FAILED`.

### `POST /arena/pve/claim`

Retorna resumo/ack idempotente da tentativa concluida ou encerrada. Claim calcula e devolve `request_hash`, mas nao usa `idempotency_keys`, nao chama RPC, nao aplica recompensa, nao grava ledger economico, nao altera ranking e nao muda XP/recursos; recompensa/progresso sao aplicados no ultimo `/arena/pve/duel/request`.

Request:

```json
{
  "request_id": "uuid",
  "request_hash": "sha256:...",
  "attempt_id": "uuid"
}
```

Response minima:

```json
{
  "ok": true,
  "schema_version": "arena_claim_response_v1",
  "endpoint": "arena/pve/claim",
  "arena_state": {
    "ok": true,
    "schema_version": "pve_arena_state_v1",
    "arenas": [],
    "attempts": [],
    "active_attempt": null,
    "progress": {},
    "records": []
  },
  "attempt": {},
  "progress": {},
  "resources": {},
  "reward_payload": {},
  "reward_already_applied": true,
  "mutates_economy": false,
  "ranking": { "mutated": false, "reason": "ARENA_PVE_DOES_NOT_RANK" }
}
```

Erros minimos: `ARENA_ATTEMPT_NOT_COMPLETE`, `ARENA_CLAIM_FAILED`, `IDEMPOTENCY_HASH_MISMATCH`.

### `POST /arena/pve/abandon`

Encerra tentativa ativa sem recompensa de conclusao. Duels ja gravados continuam legiveis via battle history/replay.

Request:

```json
{
  "request_id": "uuid",
  "request_hash": "sha256:...",
  "attempt_id": "uuid"
}
```

## Endpoints De Conteudo

### `GET /content/grimoire`

Retorna o catalogo privado do Grimorio usado pelo hub alpha.

Status: **implementado no upgrade do site em 2026-05-27**.

Scope: `release`.

Auth: exige JWT Supabase de conta email/senha com save `normal` registrado na alpha. JWT anonimo e conta sem alpha sao rejeitados.

Response:

```json
{
  "ok": true,
  "schema_version": "grimoire_catalog_v1",
  "catalog_version": "internal_alpha_v0",
  "source": "data/definitions",
  "collections": {
    "weapons": [],
    "spells": [],
    "doutrines": [],
    "familiars": [],
    "base_structures": [],
    "rewards": [],
    "power_bands": [],
    "bot_archetypes": []
  },
  "counts": {}
}
```

Regras:

- Conteudo vem de `data/definitions/*.json` via `tools/generate_grimoire_catalog.ts`.
- O endpoint nao retorna dados de jogadores, ranking, email, saves ou recursos pessoais.
- Erros minimos: `UNAUTHENTICATED`, `AUTH_REQUIRES_EMAIL`, `ALPHA_ACCESS_REQUIRED`, `METHOD_NOT_ALLOWED`.

## Endpoints De Release

### `GET /healthcheck`

Retorna healthcheck operacional da funcao local/remota.

Status: **implementado em T00-P02B**.

Scope: `release`.

Auth: nao exige JWT.

Response:

```json
{
  "ok": true,
  "service": "draxos-mobile",
  "function": "healthcheck",
  "track": "Track 00 - First Slice Foundation",
  "schema_version": "mvp_foundation_v1"
}
```

### `GET /release/manifest`

Retorna o manifest publico de updates da Internal Alpha v0.

Status: **contrato vivo; fallback estatico alinhado ao pacote publicado atual**.

Scope: `release`.

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
  "released_at": "2026-06-05T07:40:08Z",
  "requires_save_reset": false,
  "portal_url": "https://draxos-mobile-internal-alpha.pages.dev/",
  "notes": [
    "Bosque v3 UX/Feel publicado na URL principal de Internal Alpha.",
    "Bosque v3 UX/Feel melhora colisao/spawn, feedback de coleta, deposito, craft, fogueira, landmarks e resumo de visita no Bosque.",
    "Technical Hardening e Openworld Main Menu Sync seguem preservados dentro deste pacote."
  ],
  "artifacts": {
    "android": { "label": "Android APK", "url": "https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45/downloads/draxos-mobile-alpha.apk", "sha256": "4455af96d285a2ac3f5d8268d5d044ff4933eb10303dfbe113d3aba0811efaa5", "auth_required": "false" },
    "pc_windows": { "label": "PC Windows ZIP", "url": "https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45/downloads/draxos-mobile-alpha.zip", "sha256": "bd2ce982a4bba80eedbd8ff165537dbe4bdc49183139d6e5b8e7e598cff85f93", "auth_required": "false" },
    "web": { "label": "Web", "url": "https://draxos-mobile-internal-alpha.pages.dev/web/index.html" }
  }
}
```

Regras do cliente:

- `latest_version_code` maior que o code local mostra update recomendado.
- `minimum_supported_version_code` maior que o code local bloqueia acoes online ate atualizar.
- `requires_save_reset` apenas avisa; reset destrutivo continua manual e documentado.

Contrato detalhado: `update-manifest.md`.

### `GET /release/download`

Gera URL assinada temporaria para baixar artefatos privados da Internal Alpha v0 quando o manifest aponta APK/PC para a funcao em vez de Storage publico.

Status: **implementado no upgrade do site em 2026-05-27**.

Scope: `release`.

Auth: exige JWT Supabase de conta email/senha com save `normal` registrado na alpha. JWT anonimo e conta sem alpha sao rejeitados.

Query:

```text
artifact=android
artifact=pc_windows
```

Response:

```json
{
  "ok": true,
  "artifact": "android",
  "url": "https://...signed...",
  "expires_in": 300
}
```

Regras:

- JWT anonimo nao pode baixar builds.
- Conta email/senha sem save alpha `normal` recebe `ALPHA_ACCESS_REQUIRED`.
- A Edge Function usa service role apenas no servidor para verificar acesso e gerar URL assinada.
- APK/PC ZIP vivem no bucket privado `draxos-internal-alpha-private` quando downloads privados estiverem ativos.
- A URL retornada deve usar rota valida de Supabase Storage; caminhos assinados sem prefixo de Storage sao normalizados pela funcao.
- Web build continua abrindo pelo Cloudflare Pages; assets grandes do Web export continuam em Storage publico enquanto houver limite de tamanho no Pages.

### `GET /release/config`

Retorna a runtime config publica do cliente para flags de instalacao da Track 06.

Status: **implementado em T06-C**.

Scope: `release`.

Auth: nao exige JWT. Pode receber `apikey` publica quando chamado pelo cliente Godot ou smokes.

Save header: nao usa `x-draxos-save-type`.

Idempotencia: nao se aplica; endpoint e read-only e nao muta estado remoto.

Response:

```json
{
  "schema_version": "runtime_config_v1",
  "channel": "internal_alpha",
  "config_version": "track23-online-actions-hotfix",
  "generated_at": "2026-06-05T09:23:46Z",
  "features": {
    "profile_account_panel": false,
    "battle_history_replay": false,
    "base_routine_panel": false,
    "social_qol_readability": false,
    "asset_pack_01_safe": false
  },
  "client": {
    "offline_fallback_allowed": true,
    "config_refresh_seconds": 900
  },
  "guardrails": {
    "release_scoped": true,
    "read_only": false,
    "no_service_role": true,
    "no_secrets": true,
    "no_player_state": true,
    "no_gameplay_tuning": true,
    "mutable_gameplay_state": true
  }
}
```

Regras:

- O payload deve conter apenas configuracao release-scoped e flags conhecidas.
- O payload nao contem service role, secrets, JWT, player/save state, recursos, builds, battle logs, ranking ou parametros de tuning.
- Em pacote publicado de Internal Alpha com servicos online ativos, `read_only` deve ser `false` e `mutable_gameplay_state` deve ser `true`; a autoridade da mutacao continua nos endpoints server-side.
- Overrides operacionais podem alterar apenas campos allowlisted pelo service; flags desconhecidas sao ignoradas.
- O cliente deve tolerar indisponibilidade usando fallback conservador: todas as flags T06 ficam `false`, `offline_fallback_allowed` fica `true` e nenhuma acao online e destravada por config ausente.

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
`FIRST_SLICE_SIM` e um modo tecnico do simulador/replay do primeiro slice. Ele continua valido para compatibilidade, historico, labs e leitura de batalha salva, mas nao e leitura de produto atual depois da decisao Arena PVE-first. Em `T03-P07`, `FIRST_SLICE_SIM` tambem retorna `competition` e aplica pontos de arena no save `normal`. O save `progression_lab` recebe `excluded_reason = PROGRESSION_LAB_DOES_NOT_RANK`.

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
      "ossos": 4
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

### `GET /battle/history`

Retorna a lista recente de batalhas salvas do save ativo, sem eventos completos.

Status: **implementado em T06-E**.

Scope: `save-scoped`.

Headers:

```http
Authorization: Bearer <jwt>
apikey: <anon_or_publishable_key>
x-draxos-save-type: normal
```

Query params:

- `limit`: opcional, default `10`, maximo `20`.

Response:

```json
{
  "ok": true,
  "schema_version": "battle_history_v1",
  "save_type": "normal",
  "history": [
    {
      "battle_id": "uuid",
      "created_at": "iso-date",
      "schema_version": "battle_log_v1",
      "mode": "FIRST_SLICE_SIM",
      "duration": 31.2,
      "event_count": 30,
      "opponent": {
        "id": "bot_effect_trainer_01",
        "display_name": "Treinador da Primeira Ruina",
        "is_bot": true
      },
      "result": { "winner": "player", "reason": "combatant_defeated" },
      "rewards": {
        "type": "FIRST_SLICE_SIM",
        "resources": { "xp": 10, "almas": 0.8 }
      }
    }
  ]
}
```

Regras:

- Usa o mesmo `x-draxos-save-type` dos endpoints de gameplay; ausencia usa `normal`.
- Lista apenas batalhas cujo `attacker_id` pertence ao save ativo.
- Nao retorna `event_log` completo; a UI deve chamar `/battle/replay` para reproduzir uma batalha.
- Nao muta recursos, ranking, recompensas, idempotencia ou telemetria.

Erros minimos: `UNAUTHENTICATED`, `INVALID_SAVE_TYPE`, `PLAYER_NOT_FOUND`, `BATTLE_HISTORY_READ_FAILED`.

### `GET /battle/replay?battle_id=...`

Retorna o replay completo salvo para uma batalha do save ativo, sem recalcular combate.

Status: **implementado em T06-E**.

Scope: `save-scoped`.

Headers:

```http
Authorization: Bearer <jwt>
apikey: <anon_or_publishable_key>
x-draxos-save-type: normal
```

Query params:

- `battle_id`: UUID obrigatorio.

Response:

```json
{
  "ok": true,
  "battle_log": {
    "schema_version": "battle_log_v1",
    "battle_id": "uuid",
    "seed": "first_slice:<player_id>:<request_id>",
    "mode": "FIRST_SLICE_SIM",
    "duration": 31.2,
    "participants": {},
    "result": {},
    "events": []
  },
  "rewards": {},
  "replay": {
    "battle_id": "uuid",
    "created_at": "iso-date",
    "save_type": "normal",
    "read_only": true
  }
}
```

Regras:

- `battle_id` precisa pertencer ao save ativo; uma batalha do outro save retorna `BATTLE_NOT_FOUND`.
- O servidor reconstrui o envelope `battle_log_v1` a partir da linha salva em `battles`; nao chama simulador.
- A resposta pode ser aplicada no cliente como snapshot de replay, mas nao deve alterar recursos locais.
- Nao reaplica recompensa, XP, arena points, ranking, recursos ou ledger.

Erros minimos: `UNAUTHENTICATED`, `INVALID_SAVE_TYPE`, `INVALID_BATTLE_ID`, `PLAYER_NOT_FOUND`, `BATTLE_NOT_FOUND`, `BATTLE_REPLAY_READ_FAILED`.

## Endpoints Planejados - Internal Alpha v0

Nota Track 05: esta secao e historica/futura. Endpoints ja implementados foram
classificados na matriz atual acima. Qualquer endpoint ainda nao implementado
ou renomeado daqui deve ganhar `Scope: <save-scoped|account-scoped|release|telemetry|admin-future>`
antes de virar codigo, migration ou smoke.

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

Status: **implementado localmente; Track 22 pacote 4c promoveu reset v1 com `request_hash` obrigatorio**.

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
  "request_hash": "sha256:...",
  "save_type": "normal"
}
```

Regras:

- `request_hash` e obrigatorio; chamadas sem hash retornam `INVALID_REQUEST_HASH`.
- `save_type` deve ser `normal` ou `progression_lab`.
- `save_type` no body, quando enviado, deve bater com `x-draxos-save-type`.
- Reset de um save nao altera o outro.
- Reset reconstrui o mesmo `player_id` para estado inicial: player level/xp/power, resources, build, base, batalha, ranking, Arena, Modes, Track 16, loja, jobs, claims e compras alpha daquele save.
- Reset limpa ou desassocia telemetria daquele player, mas nao afeta o outro save da mesma conta.
- Reset preserva social/guilda/chat/amizades account-wide; wipe total de conta fica fora deste endpoint.
- Reset grava ledger/audit alpha em `resource_transactions`.
- Repetir o mesmo `request_id` + `request_hash` retorna o mesmo payload.
- Repetir o mesmo `request_id` com `request_hash` diferente retorna `IDEMPOTENCY_HASH_MISMATCH`.

Response logico:

```json
{
  "ok": true,
  "reset": {
    "save_type": "normal",
    "player_id": "uuid",
    "game_save_id": "uuid",
    "request_id": "uuid",
    "request_hash": "sha256:...",
    "preserved_account_social": true
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
Foundation Solidification Follow-up adiciona `request_hash` obrigatorio e reset
Track 16 dentro da RPC transacional.

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
  "request_hash": "sha256:...",
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
- a RPC tambem reseta/recria `player_consumables`, `player_potion_slots`, `player_spell_behaviors` e `item_transactions` do save Lab a partir do healthy save;
- repetir o mesmo `request_id` + `request_hash` retorna o mesmo payload;
- repetir o mesmo `request_id` com `request_hash` diferente retorna `IDEMPOTENCY_HASH_MISMATCH`;
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
| GET | `/crafting/state` | Ler recursos, receitas, inventario de consumiveis e slot de pocao |
| POST | `/crafting/crush-bones` | Converter Ossos em Po de Osso |
| POST | `/crafting/craft` | Criar consumivel por receita sem estacao |
| POST | `/crafting/station-craft` | Criar consumivel global em uma estacao, como a Fogueira do Bosque |
| GET | `/build/state` | Ler spells equipadas, comportamentos e pocao equipada |
| POST | `/build/spell-behavior` | Configurar comportamento de uma spell equipada |
| POST | `/build/potion/equip` | Equipar ou remover pocao do slot 1 |
| POST | `/build/potion-behavior` | Configurar comportamento da pocao equipada |
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
| POST | `/monetization/rewards/claim` | Resgatar recompensa diaria/semanal/passe |
| POST | `/monetization/alpha-purchase` | Redeem/compra alpha simulada de Diamante, Premium, fila dupla e pacotes |
| POST | `/telemetry/client-event` | Registrar evento client-side nao autoritativo |

### `POST /build/equip`

Status: **implementado em Battle Preparation Complete v1 em 2026-05-29**.

Scope: `save-scoped`. Usa `x-draxos-save-type`. Mutacao idempotente por `request_id` no save ativo.

Regras do primeiro slice, agora ativas no runtime:

- Cliente envia intencao de equipamento, nunca poder final.
- Campos omitidos nao mudam.
- `spell_id`, `passive_id` e `pet_id` podem ser `null` para remover.
- Instrumento ritual nao pode ficar vazio.
- Servidor valida catalogo habilitado, level, unlock e posicao disponivel.
- Spell desbloqueada pode ser equipada em qualquer slot de spell liberado.
- Slot de spell 1 abre no level 3, slot 2 no level 7 e slot 3 no level 25.
- Slot de doutrina/passiva abre no level 10.
- Slot de familiar/pet abre no level 15.
- A mesma spell nao pode ocupar duas posicoes.
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

Response v1 retorna o mesmo shape de `GET /build/state`, com `player.power` atualizado:

```json
{
  "ok": true,
  "player": { "power": 260 },
  "build": { "weapon_type": "varinha_cinzas" },
  "combat_build": {
    "power": 260,
    "weapon_type": "varinha_cinzas",
    "spell_slots": [
      { "slot_index": 1, "spell_id": "sussurro_medo", "unlocked": true }
    ],
    "passive_id": "doutrina_pavor",
    "pet_id": "corvo_pressagio",
    "equipment_options": {
      "weapons": [{ "id": "varinha_cinzas", "display_name": "Varinha de Cinzas" }],
      "spells": [{ "id": "sussurro_medo", "display_name": "Sussurro do Medo" }],
      "doutrines": [{ "id": "doutrina_pavor", "display_name": "Doutrina do Pavor" }],
      "familiars": [{ "id": "corvo_pressagio", "display_name": "Corvo de Pressagio" }]
    }
  }
}
```

Erros minimos: `INVALID_REQUEST_ID`, `INVALID_WEAPON`, `INVALID_WEAPON_QUALITY`, `WEAPON_LOCKED`, `INVALID_SPELL`, `SPELL_LOCKED`, `SPELL_SLOT_LOCKED`, `DUPLICATE_SPELL`, `INVALID_DOCTRINE`, `DOCTRINE_LOCKED`, `INVALID_FAMILIAR`, `FAMILIAR_LOCKED`, `BUILD_EQUIP_FAILED`, `POWER_UPDATE_FAILED`.

### `GET /crafting/state`

Status: **implementado em Track 16**.

Scope: `save-scoped`. Usa `x-draxos-save-type`. Read-only, sem idempotencia.

Retorna recursos relevantes, catalogo de pocoes/receitas, inventario de consumiveis e slot de pocao do save ativo.

Response v1 inclui:

```json
{
  "ok": true,
  "resources": { "ossos": 100, "po_osso": 50 },
  "potions": [{ "id": "pocao_vida" }, { "id": "pocao_foco" }, { "id": "pocao_resguardo" }],
  "recipes": [{ "id": "craft_pocao_vida", "station": { "station_id": "fogueira_estavel_1" } }],
  "inventory": [{ "item_id": "pocao_vida", "quantity": 1 }],
  "potion_slots": [{ "slot_index": 1, "potion_id": null }]
}
```

### `POST /crafting/crush-bones`

Status: **implementado em Track 16**.

Converte `amount` Ossos em `amount` Po de Osso, sempre inteiro. Mutacao idempotente por `request_id`, com ledger em `resource_transactions`.

Request:

```json
{
  "request_id": "uuid",
  "amount": 1
}
```

Erros minimos: `INVALID_REQUEST_ID`, `INVALID_AMOUNT`, `INSUFFICIENT_BONES`, `RESOURCE_UPDATE_FAILED`.

### `POST /crafting/craft`

Status: **implementado em Track 16**.

Executa receita server-authoritative sem estacao. Receitas que declaram `station_id`, incluindo as receitas de Fogueira v1, devem retornar `STATION_REQUIRED` nesta rota para impedir craft direto pela Base.

Request:

```json
{
  "request_id": "uuid",
  "recipe_id": "craft_pocao_vida",
  "quantity": 1
}
```

Erros minimos: `INVALID_RECIPE`, `INVALID_QUANTITY`, `INSUFFICIENT_RESOURCES`, `STATION_REQUIRED`, `CRAFT_FAILED`.

### `POST /crafting/station-craft`

Status: **implementado em Bosque Fogueira Potion Crafting v1**.

Scope: `save-scoped`. Usa `x-draxos-save-type`.

Executa receita server-authoritative em uma estacao construida. A Fogueira v1 usa materiais do `Bau` duravel do Bosque e recursos globais da conta para criar consumiveis globais. O cliente deve salvar checkpoint pendente antes desta chamada e enviar a revisao duravel esperada.

Request minimo:

```json
{
  "request_id": "uuid",
  "request_hash": "sha256",
  "recipe_id": "craft_pocao_vida",
  "quantity": 1,
  "station_context": {
    "mode_id": "openworld",
    "slice_id": "forest",
    "session_id": "uuid",
    "station_id": "fogueira_estavel_1",
    "expected_progress_revision": 3
  }
}
```

Regras:

- exige `request_id/request_hash` e idempotencia v1;
- valida save ativo, sessao ativa do Bosque, ruleset, Fogueira construida e revisao duravel;
- consome materiais do `mode_progress.progress_payload.chest`;
- consome recursos globais como `po_osso` de `resources`;
- cria ou incrementa `player_consumables`;
- atualiza o snapshot da sessao ativa e o progresso duravel aceito;
- registra `item_transactions` e auditoria `mode_session_events.event_type = station_craft`;
- falha sem mutacao parcial quando faltar Fogueira, checkpoint, revisao, material do Bau ou recurso global.

Response minima:

```json
{
  "ok": true,
  "crafting": {},
  "resources": { "po_osso": 25 },
  "durable_progress": {
    "schema_version": "openworld_forest_progress_v1",
    "progress_revision": 4,
    "chest": { "folha": 0, "cogumelo": 0 }
  },
  "station_craft": {
    "recipe_id": "craft_pocao_vida",
    "station_id": "fogueira_estavel_1",
    "outputs": [{ "item_id": "pocao_vida", "quantity": 1 }]
  }
}
```

Erros minimos: `INVALID_RECIPE`, `INVALID_QUANTITY`, `STATION_REQUIRED`, `STATION_NOT_BUILT`, `MODE_CHECKPOINT_REQUIRED`, `PROGRESS_REVISION_MISMATCH`, `INSUFFICIENT_OPENWORLD_MATERIALS`, `INSUFFICIENT_RESOURCES`, `CRAFT_FAILED`.

### `GET /build/state`

Status: **implementado em Track 16** e estendido em Battle Preparation Complete v1.

Scope: `save-scoped`. Usa `x-draxos-save-type`. Retorna loadout atual, spells equipadas, opcoes humanizadas, bloqueios, comportamentos salvos, inventario resumido e slot de pocao.

Extensao Battle Preparation Complete v1:

- `combat_build.power` reflete o poder recalculado pelo servidor;
- `combat_build.weapon_type`, `weapon_quality`, `passive_id`, `pet_id` e `spell_slots` descrevem o loadout vivo;
- `combat_build.equipment_options` lista `weapons`, `spells`, `doutrines` e `familiars` com `display_name`, `unlocked`, `locked_reason` e `equipped`;
- o cliente usa esses nomes/status para nao depender de ids crus na Preparacao.

Comportamento v1:

- campos: `enabled`, `hp.mode`, `hp.percent`, `mana.mode`, `mana.percent`;
- `mode` aceita `ignore`, `below` ou `above`;
- percentuais aceitos: `0..100`;
- spell sem comportamento salvo mantem baseline: usar quando pronta, com mana e cooldown validos;
- Pocao de Vida usa default `enabled=true`, `hp below 40`, mana ignorada.

### `POST /build/spell-behavior`

Status: **implementado em Track 16**.

Atualiza comportamento de uma spell equipada. Ataque basico e Doutrina nao passam por este contrato.

Request:

```json
{
  "request_id": "uuid",
  "spell_id": "sussurro_medo",
  "behavior": {
    "enabled": true,
    "hp": { "mode": "ignore", "percent": 0 },
    "mana": { "mode": "ignore", "percent": 0 }
  }
}
```

### `POST /build/potion/equip`

Status: **implementado em Track 16**.

Equipa qualquer item listado em `POTIONS` no slot 1 ou remove a pocao com `item_id: null`. Equipar exige estoque no inventario; remover nao consome item.

### `POST /build/potion-behavior`

Status: **implementado em Track 16**.

Atualiza o comportamento da pocao do slot 1. A configuracao pode permanecer salva mesmo quando o estoque chega a zero; nesse caso a batalha nao consome nem cura.

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

Status: **implementado em T00-P11; usado pela UI jogavel da Base em T03-P05;
promovido para RPC transacional v1 em 2026-05-30**.

Coleta producao offline de todas as estruturas produtoras, respeitando storage por estrutura. O cliente envia somente a intencao e um `request_id`; deltas sao calculados no servidor e gravados em `resource_transactions`.

Request:

```json
{
  "request_id": "uuid",
  "request_hash": "sha256:..."
}
```

Compatibilidade alpha: se `request_hash` ainda nao vier do cliente, o adapter
HTTP calcula um hash canonico da intencao e chama `collect_base_v1`. Chamada
direta ao RPC exige `request_hash`.

Erros minimos: `UNAUTHENTICATED`, `PLAYER_NOT_FOUND`, `INVALID_REQUEST_ID`, `BASE_COLLECT_FAILED`.

Idempotencia: repetir o mesmo `request_id` retorna o mesmo payload e nao duplica recurso nem ledger.

### `POST /base/upgrade`

Status: **implementado em T00-P11; promovido para RPC transacional v1 em
2026-05-30**.

Inicia upgrade de uma estrutura permanente da base. O servidor valida estrutura, fila, cap de level do jogador, custo em Energia e jobs ativos da mesma estrutura.

Request:

```json
{
  "request_id": "uuid",
  "request_hash": "sha256:...",
  "structure_id": "nucleo_energia"
}
```

Compatibilidade alpha: se `request_hash` ainda nao vier do cliente, o adapter
HTTP calcula um hash canonico de `request_id + save_type + structure_id` e
chama `start_base_upgrade_v1`. Chamada direta ao RPC exige `request_hash`.

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

Resgata recompensa diaria, semanal ou de Battle Pass. O cliente envia somente `reward_id` e `request_id`; XP, recursos, premium requirement, periodo e ledger sao decididos no servidor.

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
- Eventos de latencia client-side devem manter payload diagnostico local/remoto
  com estes campos quando aplicaveis: `surface`, `endpoint`, `method`,
  `action_id`, `scope_id`, `duration_ms`, `response_code`, `ok`, `fail`,
  `used_cache`, `rendered_from_cache`, `server_timing` e `save_type`.
- `request_latency` mede uma chamada HTTP logica e deve usar o endpoint
  normalizado do cliente, como `base/state` ou `arena/pve/state`.
- `surface_refresh` mede a conclusao de refresh de superficie e preserva se a
  superficie havia renderizado cache local antes da resposta.
- `surface_cache_rendered` e emitido quando uma superficie usa snapshot local
  antes da rede; `duration_ms` e `response_code` podem ser `0`.
- `action_latency` mede a duracao percebida da acao do jogador. Acoes sem
  mutation direta podem deixar `endpoint` e `method` vazios, mas devem manter
  `action_id`, `scope_id`, `duration_ms`, `ok` e `fail`.

## Idempotencia

- Toda mutacao usa `request_id`.
- O servidor deve gravar requests processados por player e tipo de endpoint.
- Repetir o mesmo `request_id` retorna o mesmo resultado sem aplicar recompensa/custo de novo.

## Versionamento

- Mudancas quebrando payload devem criar novo campo `schema_version`.
- Cliente deve tolerar campos extras.
- Servidor deve rejeitar `schema_version` desconhecido apenas quando o payload depender dela.
