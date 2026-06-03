# Minigame Platform V1 Contract

- Contract id: `MINIGAME_PLATFORM_V1`
- Public API: `/modes`
- Historical name: Minigame Platform
- Active client route: `mode_shell`
- Active client action: `open_mode_shell:<mode_id>`
- Deprecated without active backcompat: `/minigames`, `minigame_shell`, `open_minigame_shell`

V1 promove a plataforma de um unico prototipo para um registry unico de modos oficiais: `Basebuilder`, `Autobattler`, `Towerdefense`, `Cardgame` e `Openworld`.

## Registry

O registry e server-authoritative em `mode_registry`, com mirror client em `DraxosModeShellRegistry`.

Obrigatorio por modo:

- `mode_id`
- `display_name`
- `status`
- `release_channel`
- `default_slice_id`
- `active_ruleset_id`
- `active_ruleset_version`
- `metadata.public_cta`
- `metadata.surface`

Rows V1:

- `basebuilder/refugio`: active.
- `autobattler/pve_arena`: active.
- `openworld/forest`: active on `internal_alpha`.
- `towerdefense/tbd`: planned_disabled.
- `cardgame/tbd`: planned_disabled.

## Endpoints

Todos exigem JWT e `x-draxos-api-version: 1`. Endpoints save-scoped exigem `x-draxos-save-type`. Mutacoes exigem `request_id` e `request_hash`.

| Method | Endpoint | Uso |
| --- | --- | --- |
| GET | `/modes/registry` | Lista modos e rulesets |
| GET | `/modes/state?mode_id=<id>` | Estado save-scoped de um modo |
| POST | `/modes/session/start` | Inicia sessao generica quando o modo usa Mode sessions |
| POST | `/modes/session/event` | Registra evento/revision e atualiza snapshot remoto da sessao |
| POST | `/modes/session/complete` | Completa sessao e aplica reward bridge |
| POST | `/modes/session/abandon` | Abandona sessao started |
| GET | `/modes/analytics/summary?mode_id=<id>` | Sumario operacional por modo |
| GET | `/modes/admin/me` | Verifica acesso admin |
| POST | `/modes/admin/disable` | Pausa modo para novas sessoes |
| POST | `/modes/admin/enable` | Reabilita modo |
| POST | `/modes/admin/session/expire` | Expira sessao |
| POST | `/modes/admin/session/invalidate` | Invalida sessao com motivo |
| POST | `/modes/admin/reconcile` | Diagnostico read-only de sessoes/claims; usa `request_id` apenas para correlacao |
| POST | `/modes/admin/compensate` | Compensacao limitada via RPC auditada com `request_id` e `request_hash` |

## Session Defaults

`mode_limit_policies` declara os defaults de playtest:

- `max_active_sessions = 1`
- `start_cooldown_seconds = 10`
- `session_expiry_seconds = 7200`
- `daily_start_limit = 100`
- reward cap por ruleset

## Mode Behavior

- `basebuilder`: usa endpoints core de Base; nao usa generic session V1.
- `autobattler`: usa `arena/pve/*` e build atual; nao usa generic session V1.
- `openworld`: usa `openworld/forest` com state/resume, start, event, complete, abandon, snapshot remoto e Reward Bridge.
- `towerdefense`: registry visivel, start retorna `MODE_DISABLED`.
- `cardgame`: registry visivel, start retorna `MODE_DISABLED`.

## Reward Bridge

Contrato detalhado: `docs/contracts/reward-bridge-v1.md`.

Recompensa real so pode ser aplicada pelo servidor:

- RPC/service role;
- `mode_reward_claims`;
- `resource_transactions`;
- idempotencia por `endpoint + request_id + request_hash + scope_id`;
- bloqueio de `progression_lab`;
- resposta com `schema_version`, `mode`, `session`, `reward`, `resources`, `limits` e `server_time`.

Para `openworld/forest`, o complete usa `expected_revision` e calcula recompensa
exclusivamente de `mode_sessions.snapshot_payload`. Campos client-side como
`deposited_items` e `activity_score` nao sao autoridade de recompensa.

## Admin/Ops

Admin e gated por `admin_roles`. O cliente nunca recebe service role.

Ops pode:

- investigar sessoes, claims e falhas;
- pausar/habilitar modo;
- expirar/invalidar sessao;
- reconciliar estado;
- aplicar compensacao limitada por `admin_adjust_resource_balance_v1`.

Mutacoes admin devem chamar RPC auditada, nao `PATCH` direto da Edge Function:

- `admin_set_mode_status_v1`;
- `admin_expire_mode_session_v1`;
- `admin_invalidate_mode_session_v1`.
- `admin_adjust_resource_balance_v1`.

`/modes/admin/reconcile` e a excecao read-only atual: ele nao corrige estado,
nao grava audit log e nao usa `request_hash`. Se passar a mutar, precisa virar
uma nova operacao auditada.

## Analytics

Schema: `mode_analytics_v1`.

Eventos:

- `mode_hub_shown`
- `mode_card_shown`
- `mode_card_selected`
- `mode_start_requested`
- `mode_start_failed`
- `mode_session_started`
- `mode_session_abandoned`
- `mode_session_completed`
- `mode_reward_applied`
- `mode_exit`
- `mode_disabled_seen`
- `mode_ops_action`

Dimensoes obrigatorias:

- `mode_id`
- `slice_id`
- `ruleset_id`
- `ruleset_version`
- `release_channel`
- `entry_surface`
- `save_type`
- `app_platform`
- `client_version`
- `session_id` quando houver
- `request_id` quando houver
- `error_code` quando houver
