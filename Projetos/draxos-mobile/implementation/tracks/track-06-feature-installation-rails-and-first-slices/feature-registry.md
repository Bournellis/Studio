# Track 06 - Feature Registry And Installation Rails

- Last Updated: `2026-05-27`
- Owner: `Track 06 agents`
- Status: `T06-D_PROFILE_READY_FOR_INTEGRATION`
- Depends On: `T06-A_ON_MASTER`

## Objetivo

Este documento e o contrato operacional para instalar features na Track 06.

Antes de qualquer feature virar runtime, endpoint, teste ou asset, ela deve ter um card completo neste registry. O card precisa declarar owner, surface, endpoints afetados, escopo de servico, validacao obrigatoria, fallback e rollback.

T06-B nao instala gameplay, economia, schema, endpoint, asset final ou tuning. Ela cria os trilhos para que T06-C a T06-H possam trabalhar em paralelo sem quebrar a fundacao Track 05.

## Status Permitidos

| Status | Uso |
|---|---|
| `PLANNED` | Feature registrada, ainda sem implementacao. |
| `IN_PROGRESS` | Worktree ativa trabalhando na feature. |
| `READY_FOR_INTEGRATION` | Feature entregue pelo agente, validada e pronta para T06-I. |
| `INTEGRATED` | Feature integrada na branch de integracao. |
| `BLOCKED` | Feature parou por decisao, dependencia ou validacao falha. |
| `DEFERRED` | Feature retirada da Track 06 sem implementacao runtime. |

## Contrato Obrigatorio Por Feature

Cada feature deve preencher os campos abaixo antes de tocar runtime:

| Campo | Regra |
|---|---|
| `Feature ID` | ID estavel, em `SCREAMING_SNAKE_CASE` quando for feature tecnica. |
| `Owner` | Trilha/agente responsavel, ex.: `T06-C Runtime Config`. |
| `Surface` | Area player-facing ou operacional afetada. |
| `Status` | Um dos status permitidos acima. |
| `Endpoints affected` | Lista de endpoints novos, alterados ou existentes usados pela feature; use `none` para docs/assets puros. |
| `Service scope` | Um dos escopos Track 05: `save-scoped`, `account-scoped`, `release`, `telemetry`, `admin-future` ou `none`. |
| `Service contract notes` | Para endpoints: auth, `x-draxos-save-type`, idempotencia, leitura/mutacao e erro/fallback esperado. |
| `Client files` | Arquivos Godot/client previstos ou `none`. |
| `Backend files` | Edge Functions, server mirror, tests ou `none`. |
| `Smoke required` | Smoke obrigatorio ou `N/A docs-only` com justificativa. |
| `GUT required` | GUT obrigatorio ou `N/A docs-only/backend-only` com justificativa. |
| `Other validation` | Deno checks, `validate.gd`, `smoke_exports.gd`, `git diff --check` ou outra validacao especifica. |
| `Fallback` | Comportamento quando endpoint/config/asset/dados estiverem ausentes ou offline. |
| `Rollback` | Como desligar ou remover a feature sem corromper save, release ou UX. |
| `Guardrail notes` | Declaracao explicita do que a feature nao pode alterar. |
| `Handoff notes` | O que T06-I deve integrar, revisar ou deixar bloqueado. |

Campos `TBD`, `unknown` ou vazios bloqueiam a implementacao. Se uma feature descobrir que precisa de schema, tuning, pagamento real, realtime social, publicacao remota ou `account_profiles` + `game_saves`, o agente deve registrar o bloqueio e parar para decisao.

## Service Scope Rule

A taxonomia vem de Track 05 e deve continuar igual:

| Escopo | Regra de instalacao |
|---|---|
| `save-scoped` | Resolve estado pelo save ativo `normal` ou `progression_lab`; ausencia de `x-draxos-save-type` usa `normal`. A feature deve declarar se le, muta ou apenas apresenta o save. |
| `account-scoped` | Opera identidade ou relacionamento de conta atravessando saves. A feature deve declarar qual identidade e canonica e como evita contaminar Normal com Lab. |
| `release` | Superficie publica/operacional sem gameplay state, recurso, recompensa, ranking ou save. Nao pode expor secrets. |
| `telemetry` | Diagnostico/UX; nunca concede progresso, ranking, recurso ou recompensa. |
| `admin-future` | Reservado para administracao futura; exige decisao separada e nao deve aparecer como endpoint publico de gameplay por padrao. |
| `none` | Docs, assets locais ou UI que nao chamam backend. |

Endpoint novo ou renomeado deve atualizar `docs/contracts/api-endpoints.md` na mesma entrega da feature. Endpoint existente usado sem alteracao deve ser declarado no registry como `existing` e apontar o smoke/GUT que cobre a surface.

## Validation Rule By Surface

Toda feature runtime deve declarar ao menos um smoke ou GUT focado. Features com cliente Godot devem rodar `validate.gd` e GUT conforme a surface. Features backend devem rodar Deno checks e smoke de contrato. Features docs-only rodam `git diff --check` e registram `Smoke required: N/A docs-only`.

| Surface | Smoke required | GUT required | Other validation |
|---|---|---|---|
| docs/coordination | `N/A docs-only` | `N/A docs-only` | `git diff --check` |
| release/client boot | Runtime config smoke | GUT para read path/fallback client quando Godot for tocado | Deno checks se endpoint existir, `validate.gd`, `git diff --check` |
| Hub account/session | Profile/session smoke ou extensao de `smoke_session_shell.gd` | Profile/presenter GUT | `validate.gd`, GUT completo, `git diff --check` |
| Battle tab | Battle history/replay smoke e `smoke_battle_replay.gd` | Battle history/replay presenter GUT | Deno checks se endpoint existir, `validate.gd`, `git diff --check` |
| Base tab | `smoke_foundation_surfaces.gd` cobrindo rotina da Base | Base routine/presenter GUT | `validate.gd`, GUT completo, `git diff --check` |
| Social tab | `smoke_foundation_surfaces.gd` cobrindo Social | Social readability/presenter GUT | `validate.gd`, GUT completo, `git diff --check` |
| shared UI/battle visuals | Smoke visual/export quando alterar asset hooks | AssetIds/fallback GUT | `validate.gd`, `smoke_exports.gd`, `git diff --check` |
| backend-only service | Endpoint smoke Deno | `N/A backend-only` | Deno checks em `supabase/functions` e `server/functions`, `git diff --check` |

Se a feature tocar tooling/client por acidente, o minimo passa a ser `validate.gd`, GUT client e `git diff --check`, mesmo que o plano original fosse docs-only.

## Fallback Rule

- Runtime config deve cair para flags conservadoras quando o endpoint falhar.
- Read-only endpoints devem mostrar estado vazio/erro legivel sem mutar save.
- Client UI deve continuar utilizavel sem dados opcionais, arte final ou resposta remota.
- Assets devem manter fallback nativo via `AssetIds`.
- Social QoL nao pode depender de realtime.
- Battle history nao pode rerodar simulador nem reaplicar recompensa.

## Rollback Rule

Rollback deve ser simples e local:

1. Desligar entrada de UI ou flag da feature.
2. Reverter arquivos isolados da feature.
3. Manter saves, rewards, ranking, release manifest e remote state intactos.
4. Se endpoint novo existir, garantir que clientes sem a feature continuem funcionando.
5. Registrar qualquer passo manual restante no handoff.

## Registry Summary

| Feature ID | Owner | Surface | Status | Endpoints affected | Service scope | Smoke required | GUT required |
|---|---|---|---|---|---|---|---|
| `T06_FEATURE_RAILS` | `T06-B Feature Rails` | docs/coordination | `READY_FOR_INTEGRATION` | none | none | `N/A docs-only` | `N/A docs-only` |
| `RUNTIME_CONFIG_V1` | `T06-C Runtime Config` | release/client boot | `READY_FOR_INTEGRATION` | new `GET /release/config` | `release` | runtime config smoke | runtime config read path/fallback GUT |
| `PROFILE_ACCOUNT_PANEL` | `T06-D Perfil/Conta` | Hub account/session | `READY_FOR_INTEGRATION` | existing `GET /account/state` | `save-scoped` existing read | `smoke_session_shell.gd` profile summary extension | profile/presenter GUT |
| `BATTLE_HISTORY_REPLAY` | `T06-E Battle History` | Battle tab | `READY_FOR_INTEGRATION` | new `GET /battle/history`, new `GET /battle/replay?battle_id=...` | `save-scoped` read-only | `battle_history_replay_smoke.ts` and `smoke_battle_replay.gd` | battle history/replay presenter GUT |
| `BASE_ROUTINE_PANEL` | `T06-F Base Routine` | Base tab | `READY_FOR_INTEGRATION` | existing `GET /base/state` | `save-scoped` existing read | `smoke_foundation_surfaces.gd` Base coverage | Base routine/presenter GUT |
| `SOCIAL_QOL_READABILITY` | `T06-G Social QoL` | Social tab | `READY_FOR_INTEGRATION` | existing `GET /social/state` and current social actions | `account-scoped` existing behavior | `smoke_foundation_surfaces.gd` Social coverage passed | Social readability/presenter GUT passed |
| `ASSET_PACK_01_SAFE` | `T06-H Asset Pack 01` | shared UI/battle visuals | `READY_FOR_INTEGRATION` | none | none | `smoke_exports.gd` | AssetIds/fallback GUT |

## Feature Cards

### `T06_FEATURE_RAILS`

- Owner: `T06-B Feature Rails`
- Surface: docs/coordination
- Status: `READY_FOR_INTEGRATION`
- Endpoints affected: none
- Service scope: none
- Service contract notes: creates installation contract only; no endpoint contract is changed.
- Client files: none
- Backend files: none
- Smoke required: `N/A docs-only`
- GUT required: `N/A docs-only`
- Other validation: `git diff --check`
- Fallback: if a later feature lacks a card, implementation is blocked until the card is completed.
- Rollback: revert this docs package; no runtime state exists.
- Guardrail notes: no gameplay runtime, economy, schema, endpoint, asset final, release publication or remote mutation.
- Handoff notes: T06-D to T06-H must copy this template before implementation.

### `RUNTIME_CONFIG_V1`

- Owner: `T06-C Runtime Config`
- Surface: release/client boot
- Status: `READY_FOR_INTEGRATION`
- Endpoints affected: new `GET /release/config`
- Service scope: `release`
- Service contract notes: no JWT required; no `x-draxos-save-type`; no idempotency; read-only; response uses `runtime_config_v1`, allowlisted T06 flags and must not include secrets, service-role data, mutable gameplay state, player/save state or release publication controls.
- Client files: `online/runtime_config.gd`, `online/backend_config.gd`, `online/supabase_client.gd`, `online/session_store.gd`, `modes/boot/boot.gd`.
- Backend files: `supabase/functions/release/index.ts`, `server/functions/release/index.ts`, `server/tests/runtime_config_smoke.ts`.
- Smoke required: `tools/smoke_runtime_config.gd`.
- GUT required: runtime config read path/fallback coverage in `tests/client/test_session_shell.gd`.
- Other validation: Deno checks for `supabase/functions` and `server/functions`, `deno check server/tests/runtime_config_smoke.ts`, direct Deno serve of release functions with manifest/config smokes, `validate.gd`, GUT client, `git diff --check`.
- Fallback: client normalizes invalid/unavailable runtime config to `runtime_config_v1` fallback with all T06 feature flags `false`, `offline_fallback_allowed = true` and no online action unlocked.
- Rollback: revert endpoint route, `RuntimeConfig` client helper, Boot fetch and related tests/docs; `GET /release/manifest` remains independent.
- Guardrail notes: no remote publication, no manifest mutation, no gameplay tuning, no schema, no secrets, no service role and no player/save state.
- Handoff notes: T06-I must verify config defaults before integrating feature slices behind flags. Supabase local at `127.0.0.1:54321` may still serve the old release function until restarted/redeployed; no remote state was changed by T06-C.

### `PROFILE_ACCOUNT_PANEL`

- Owner: `T06-D Perfil/Conta`
- Surface: Hub account/session
- Status: `READY_FOR_INTEGRATION`
- Endpoints affected: existing `GET /account/state` only
- Service scope: `save-scoped` existing read
- Service contract notes: no endpoint change; `boot.gd` continues to call `GET /account/state` through the existing refresh/recover paths with the active `x-draxos-save-type`; the panel only renders `SessionStore` session metadata, current account/save snapshot, update gate and alpha channel state.
- Client files: `modes/boot/surfaces/hub_account_surface_presenter.gd`, `modes/boot/surfaces/hub_surface_presenter.gd`.
- Backend files: none.
- Smoke required: focused extension of `tools/smoke_session_shell.gd` to validate account/profile summary data after `account/state`.
- GUT required: profile/presenter GUT in `tests/client/test_boot_mobile_ui.gd`.
- Other validation: `validate.gd`, GUT client, `smoke_session_shell.gd`, `git diff --check`.
- Fallback: show available session metadata and clear empty state when account snapshot is missing.
- Rollback: remove UI entry/presenter and keep existing account/session flow.
- Guardrail notes: no Auth change, no SessionStore persisted contract change, no schema, no economy, no combat, no ranking, no manifest mutation and no new endpoint.
- Handoff notes: profile/account panel is read-only and save-aware; T06-I should integrate the presenter/test/smoke docs and keep actions/session/network/telemetry in `boot.gd`.

### `BATTLE_HISTORY_REPLAY`

- Owner: `T06-E Battle History`
- Surface: Battle tab
- Status: `READY_FOR_INTEGRATION`
- Endpoints affected: new `GET /battle/history`, new `GET /battle/replay?battle_id=...`
- Service scope: `save-scoped` read-only
- Service contract notes: JWT required; uses active `x-draxos-save-type` with absence defaulting to `normal`; no idempotency because both endpoints are GET/read-only; `history` returns recent saved battle summaries; `replay` returns the stored `battle_log_v1` for a battle owned by the active save; must never rerun simulator, reapply rewards or mutate ranking/resources.
- Client files: `online/supabase_client.gd`, `modes/boot/boot.gd`, `modes/boot/surfaces/battle_replay_presenter.gd`, `tools/smoke_battle_replay.gd`, focused `tests/client` coverage.
- Backend files: `supabase/functions/battle/index.ts`, `server/functions/battle/index.ts`, `server/tests/battle_history_replay_smoke.ts`, `server/tests/README.md`.
- Smoke required: `server/tests/battle_history_replay_smoke.ts` and `tools/smoke_battle_replay.gd`.
- GUT required: battle history/replay presenter GUT in `tests/client`.
- Other validation: Deno checks, `validate.gd`, GUT client, `git diff --check`.
- Fallback: show empty history or readable load error; latest battle flow remains available.
- Rollback: disable history UI and remove read-only endpoints while preserving `battle/request`, `battle/latest` and stored battle rows.
- Guardrail notes: no simulator, reward, ranking, economy, `battle_log_v1` or schema change unless blocked and escalated.
- Handoff notes: delivered with Deno checks, direct-function battle history smoke, `smoke_battle_replay.gd`, `validate.gd`, GUT client and `git diff --check`; T06-I should verify saved replay is read-only, active-save scoped and does not change account state after replay fetch.

### `BASE_ROUTINE_PANEL`

- Owner: `T06-F Base Routine`
- Surface: Base tab
- Status: `READY_FOR_INTEGRATION`
- Endpoints affected: existing `GET /base/state` only
- Service scope: `save-scoped` existing read
- Service contract notes: no endpoint change; uses existing Base presentation payload for collect readiness, construction jobs, free slots and next upgrade.
- Client files: `modes/boot/surfaces/base_surface_presenter.gd`, `tests/client/test_boot_mobile_ui.gd`, `tools/smoke_foundation_surfaces.gd`.
- Backend files: none expected.
- Smoke required: `smoke_foundation_surfaces.gd` Base coverage; passed in T06-F.
- GUT required: Base routine/presenter GUT in `test_boot_mobile_ui.gd`; passed in T06-F.
- Other validation: `validate.gd`, GUT client complete, `git diff --check`.
- Fallback: show no-ready-action state when payload is empty or offline.
- Rollback: remove routine panel and keep existing Base state/actions.
- Guardrail notes: no economy tuning, no endpoint, no schema, no queue rule change.
- Handoff notes: T06-I should verify routine remains derived from existing `base/state` presentation payload and keep `base/*` endpoints/actions unchanged.

### `SOCIAL_QOL_READABILITY`

- Owner: `T06-G Social QoL`
- Surface: Social tab
- Status: `READY_FOR_INTEGRATION`
- Endpoints affected: existing `GET /social/state` and current social actions only
- Service scope: `account-scoped` existing behavior
- Service contract notes: no endpoint change expected; preserves polling/chat/ranking boundaries and current account identity rules.
- Client files: `modes/boot/surfaces/social_surface_presenter.gd`, `tests/client/test_boot_mobile_ui.gd`, `tools/smoke_foundation_surfaces.gd`.
- Backend files: none.
- Smoke required: `smoke_foundation_surfaces.gd` Social coverage passed in T06-G.
- GUT required: Social readability/presenter GUT passed through `tests/client/test_boot_mobile_ui.gd`.
- Other validation: `validate.gd`, GUT client complete and `git diff --check` passed in T06-G.
- Fallback: clear empty states for no friends, no guild, no messages and offline refresh failure.
- Rollback: remove readability UI changes and keep existing social actions.
- Guardrail notes: no realtime, moderation, schema, endpoint expansion, ranking change or Lab leaderboard leakage.
- Handoff notes: T06-I should review the new refresh/polling panel, empty states and current message formatting while preserving the existing Social endpoint/action flow.

### `ASSET_PACK_01_SAFE`

- Owner: `T06-H Asset Pack 01`
- Surface: shared UI/battle visuals
- Status: `READY_FOR_INTEGRATION`
- Endpoints affected: none
- Service scope: none
- Service contract notes: no backend service.
- Client files: `assets/ui/icon_guest.png`, `assets/ui/icon_battle.png`, `assets/ui/icon_result.png`, `assets/portraits/portrait_draxos_mage.png`, `assets/portraits/portrait_training_bot.png`, `assets/battle/icons/*.png`, `core/asset_ids.gd`, `ui/battle_symbol_icon.gd`, `ui/battle_stage_2d.gd`, `tests/client/test_content_foundation.gd`.
- Backend files: none.
- Smoke required: `smoke_exports.gd` because the package adds runtime PNGs and a safe battle icon hook.
- GUT required: AssetIds/fallback GUT in `tests/client/test_content_foundation.gd`.
- Other validation: `validate.gd`, full GUT client, `smoke_exports.gd`, `git diff --check`.
- Fallback: uninstalled ids such as `boot_background`, `placeholder_card` and `battle_fx_hit` still return `null`; `BattleSymbolIcon` renders its native label/circle fallback when a texture is missing.
- Rollback: remove the PNG files and the optional `BattleSymbolIcon`/`BattleStage2D` hook; existing ids and procedural/native visuals continue to render.
- Guardrail notes: no backend, schema, economy, tuning, remote asset, broad visual rework, required art dependency or publication change.
- Handoff notes: T06-I should integrate the PNG subset and confirm missing-art fallback plus exports after conflict resolution.

## Template For New Feature Cards

```text
### `FEATURE_ID`

- Owner:
- Surface:
- Status:
- Endpoints affected:
- Service scope:
- Service contract notes:
- Client files:
- Backend files:
- Smoke required:
- GUT required:
- Other validation:
- Fallback:
- Rollback:
- Guardrail notes:
- Handoff notes:
```

## Ready For Integration Checklist

Before a feature can move to `READY_FOR_INTEGRATION`, the agent must confirm:

- Registry card has no `TBD`, empty field or ambiguous endpoint scope.
- Endpoint contract is documented before or with runtime code.
- Required smoke/GUT for the surface passed or the feature is docs-only with justification.
- `git diff --check` passed.
- Any touched client/tooling ran `validate.gd` and GUT client.
- Any touched backend ran Deno checks and endpoint smoke.
- Fallback and rollback were tested or explicitly reasoned in the handoff.
- Guardrails remain true: no tuning, no account/save migration, no payment real, no realtime social, no publication remota, no secrets in client/export.
