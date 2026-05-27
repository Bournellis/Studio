# T05-D - Service Contract Scope

- Data: `2026-05-27`
- Status: `READY_FOR_INTEGRATION`
- Branch: `codex/draxos-mobile/t05-service-contracts`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t05-service-contracts`

## Objetivo

Preparar a fundacao de servicos da Track 05 classificando endpoints e Edge
Functions existentes sem criar servico novo, schema novo ou migration.

## Guardrails

- Nao criar `account_profiles` ou `game_saves`.
- Nao alterar schema, migrations, economia, ranking, simulador, loja ou payload
  publico.
- Nao publicar remoto nem alterar manifest remoto real.
- Manter `players.save_type` e `x-draxos-save-type` como modelo da Track 05.

## Taxonomia

| Escopo | Definicao |
|---|---|
| `save-scoped` | Resolve o estado pelo save ativo `normal` ou `progression_lab`; ausencia de header usa `normal`. |
| `account-scoped` | Opera identidade ou relacionamento de conta atravessando saves; pode validar save ativo, mas nao mistura Lab com Normal. |
| `release` | Superficie publica/operacional sem estado de gameplay. |
| `telemetry` | Diagnostico/UX; nunca concede recompensa, ranking, recurso ou progresso. |
| `admin-future` | Administracao futura de convites, suporte, moderacao, entitlement ou publicacao; nao existe endpoint implementado neste escopo agora. |

Todo endpoint futuro deve declarar um desses valores no contrato antes de
codigo, migration ou smoke.

## Edge Functions Atuais

| Funcao | Escopo primario | Endpoints |
|---|---|---|
| `healthcheck` | `release` | `GET /healthcheck` |
| `release` | `release` | `GET /release/manifest` |
| `account` | `save-scoped` | `POST /account/bootstrap`, `POST /account/guest`, `GET /account/state`, `POST /account/saves/reset` |
| `battle` | `save-scoped` | `POST /battle/request`, `GET /battle/latest` |
| `base` | `save-scoped` | `GET /base/state`, `POST /base/collect`, `POST /base/upgrade` |
| `social` | `account-scoped` | `GET /social/state`, `POST /social/friends/add`, `POST /social/guild/create`, `POST /social/guild/join`, `POST /social/chat/send` |
| `competition` | `save-scoped` | `GET /competition/matchmaking/preview`, `GET /competition/ranking/current` |
| `monetization` | `save-scoped` | `GET /monetization/state`, `POST /monetization/rewards/claim`, `POST /monetization/alpha-purchase` |
| `telemetry` | `telemetry` | `POST /telemetry/client-event` |
| `progression-lab` | `save-scoped` | `POST /progression-lab/apply` |

## Endpoint Rules

- `save-scoped` endpoints must use `saveTypeFromRequest()` or an equivalent
  future adapter and must define whether missing `x-draxos-save-type` defaults
  to `normal`.
- `account-scoped` endpoints must state which account identity owns the action.
  Today Social resolves the normal save as canonical identity when available
  and marks Lab viewers explicitly.
- Mutations must name the idempotency owner. Current mutations use
  `idempotency_keys` keyed by the active/canonical `player_id`, endpoint and
  `request_id`.
- `release` endpoints must not read or write gameplay state.
- `telemetry` endpoints must write only telemetry and must reject attempts to
  mutate gameplay, resources, ranking, rewards or social state.
- `admin-future` endpoints need a separate authorization decision and must not
  be added as public gameplay endpoints by default.

## Current Coverage

No new Deno test was added in T05-D because this package is documentation-only
and existing behavior smokes already cover scope/idempotency for the implemented
runtime:

- `two_save_context_smoke.ts`: save header, Normal/Lab isolation and Lab ranking
  exclusion.
- `reset_save_context_smoke.ts`: save reset idempotency and body/header mismatch.
- `progression_lab_apply_smoke.ts`: Lab-only apply, Normal preservation and
  idempotency.
- `battle_request_smoke.ts` and `first_slice_battle_smoke.ts`: battle
  idempotency and rewards/ranking behavior.
- `base_manager_smoke.ts`, `social_competition_smoke.ts`,
  `monetization_rewards_smoke.ts` and `client_telemetry_smoke.ts`: scoped
  server behavior for Base, Social/Competition, Shop and Telemetry.
- `release_manifest_smoke.ts`: release manifest contract.

## Validation

- Pass: `npx -y deno task --cwd supabase/functions check`.
- Pass: `npx -y deno task --cwd server/functions check`.
- Pass: `git diff --check`.

## Handoff Para T05-H

T05-H should treat `docs/contracts/api-endpoints.md` as the current endpoint
scope registry. If another Track 05 branch adds endpoints, it must add or update
the scope row before integration. If a future account-wide service is needed,
open a dedicated contract/schema decision instead of silently extending
`players.save_type`.
