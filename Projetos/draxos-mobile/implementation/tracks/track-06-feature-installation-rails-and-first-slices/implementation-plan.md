# Track 06 - Implementation Plan

## Regra Da Track

Track 06 installs features on top of the Track 05 foundation.

The track is not a tuning pass. It should improve visible capability and service readiness while preserving current economy, combat, rewards, bots, shop numbers, save model and release state.

Expected commit stages:

- `docs:` track, feature rails, registry, service scope and status.
- `contracts:` endpoint docs and tests for scope/idempotency/read-only behavior.
- `backend:` release config and battle history/replay read-only endpoints.
- `client:` feature panels, presenters, runtime config read path and asset hooks.
- `test:` smokes and GUT coverage.
- `integration:` merge, conflict resolution, full validation and status.

## Trilhas Paralelas Oficiais

| Trilha | Prioridade | Trabalho | Dependencia |
|---|---:|---|---|
| T06-A Coordenacao | 0 | Criar Track 06, status, plano, registry de agentes e Kanban | Nenhuma |
| T06-B Feature Rails | 1 | Criar contrato padrao de instalacao de feature, registry e checklist de validacao | T06-A |
| T06-C Runtime Config | 1 | Adicionar config/flags remotas de leitura via release service | T06-A |
| T06-D Perfil/Conta | 2 | Instalar painel de perfil/conta usando estado existente | T06-B |
| T06-E Battle History | 2 | Instalar historico de batalhas e replay por batalha salva | T06-B |
| T06-F Base Routine | 2 | Instalar painel de rotina/proximo objetivo da Base com dados existentes | T06-B |
| T06-G Social QoL | 2 | Melhorar leitura de amigos/guilda/chat sem social realtime | T06-B |
| T06-H Asset Pack 01 | 2 | Instalar primeiro pacote visual seguro usando `AssetIds` e fallback | T06-B |
| T06-I Integracao | 0 final | Integrar C-H, validar matriz Track 05 + smokes novos e atualizar status | T06-C a T06-H |

## T06-A - Coordenacao

Status: `COMPLETE`.

- Criar pasta da Track 06 com `scope.md`, `current-status.md`, `implementation-plan.md`, `feature-registry.md`, `agent-registry.md` e `agent-prompts.md`.
- Atualizar snapshots de portfolio e status local.
- Registrar Doing.
- Nao alterar Godot runtime, Supabase, schema, economia, assets ou endpoints.

Validation: `git diff --check`.

## T06-B - Feature Rails

Status: `READY_FOR_HANDOFF`.

- Transformar `feature-registry.md` em contrato operacional.
- Definir template/checklist por feature: owner, surface, endpoints, service scope, validation, fallback and rollback.
- Registrar as features T06 no registry como `planned` ou `in_progress`.
- Sem runtime gameplay.

Validation: docs checks and `git diff --check`; client validation only if tooling is touched.

Handoff:

- `feature-registry.md` now defines the standard feature installation contract.
- Every Track 06 feature must declare owner, surface, endpoints affected, service scope, smoke/GUT requirement, fallback and rollback before implementation.
- Surface validation is explicit for docs, release/client boot, Hub account/session, Battle, Base, Social, shared visual assets and backend-only services.
- Feature work that discovers schema, tuning, real payment, realtime social, remote publication or account/save migration must stop for decision instead of silently expanding scope.

## T06-C - Runtime Config

Status: `PENDING_AFTER_T06_A`.

- Implementar `GET /release/config` as release-scoped, read-only and no-secret.
- Retornar `runtime_config_v1` with flags for T06 features.
- Add Godot client read path and focused smoke/GUT.
- Document endpoint contract.

Validation: Deno checks, runtime config smoke, `validate.gd`, GUT if client touched, `git diff --check`.

## T06-D - Perfil/Conta

Status: `PENDING_AFTER_T06_B`.

- Install a Profile/Account panel using `SessionStore`, `account/state`, update state and existing session metadata.
- Show username, active save, level, power, auth method and alpha status.
- No new endpoint.

Validation: profile GUT/smoke, `validate.gd`, GUT and `git diff --check`.

## T06-E - Battle History

Status: `PENDING_AFTER_T06_B`.

- Implement `GET /battle/history` and `GET /battle/replay?battle_id=...` as save-scoped read-only endpoints.
- Install battle history UI/replay selection in the Battle surface.
- Do not rerun simulator, mutate battle rewards or alter `battle_log_v1`.

Validation: Deno checks, battle history/replay smoke, `smoke_battle_replay.gd`, GUT and `git diff --check`.

## T06-F - Base Routine

Status: `PENDING_AFTER_T06_B`.

- Add a Base routine/next objective panel using existing Base state payload.
- Cover collect readiness, construction jobs, free slots and next readable upgrade.
- No economy or schema change.

Validation: focused GUT/smoke, `smoke_foundation_surfaces.gd`, GUT and `git diff --check`.

## T06-G - Social QoL

Status: `PENDING_AFTER_T06_B`.

- Improve readability for friends, guild, chat, empty states, refresh state and current messages.
- No realtime, moderation, schema or endpoint expansion unless documented as blocker.

Validation: focused GUT/smoke, `smoke_foundation_surfaces.gd`, GUT and `git diff --check`.

## T06-H - Asset Pack 01

Status: `PENDING_AFTER_T06_B`.

- Install a small safe asset pack through existing `AssetIds` conventions.
- Prefer UI icons, battle icons/fx or small portraits.
- Keep fallback and missing art behavior working.
- No broad visual rework.

Validation: AssetIds/fallback GUT, `validate.gd`, `smoke_exports.gd` and `git diff --check`.

## T06-I - Integracao

Status: `BLOCKED_UNTIL_T06_C_TO_H`.

- Integrate T06-C to T06-H in safe order.
- Resolve conflicts without hiding validation failures.
- Preserve Track 06 guardrails.
- Run full Track 05 matrix plus T06 smokes/tests.
- Update current-status, Track 06 current-status and portfolio snapshots.

Final validation:

- `tools/validate.gd`
- GUT client complete
- `tools/smoke_session_shell.gd`
- `tools/smoke_battle_replay.gd`
- `tools/smoke_foundation_surfaces.gd`
- `tools/smoke_exports.gd`
- new runtime config smoke
- new battle history/replay smoke
- Deno checks for `supabase/functions` and `server/functions`
- `git diff --check`

## Assumptions

- Track 06 uses the `rails + vertical slices` approach.
- Progression Lab remains available, but tuning is not an active objective.
- Assets may enter only as a small safe pack with fallback.
- Supabase remains the alpha backend.
- `players.save_type` remains the short-term account/save model.
