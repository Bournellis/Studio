# Track 08 - Implementation Plan

## Regra Da Track

Track 08 hardens the foundation after Track 07 without expanding product scope.

Expected commit stages:

- `docs:` track, gap report, prompts, status and coordination.
- `client-shell:` route/back/orientation contract helpers and tests.
- `client-session:` session/save/cache/runtime-config invariants and diagnostics.
- `client-ui:` touch, scroll, button and responsive layout contract helpers and tests.
- `client-battle:` battle mode fullscreen/summary/replay contract coverage.
- `contracts:` endpoint/feature/asset checks without new service behavior.
- `test:` hardening smoke and validation matrix.
- `integration:` merge, validation and portfolio/status update.

## Trilhas Paralelas Oficiais

| Trilha | Prioridade | Trabalho | Dependencia |
|---|---:|---|---|
| T08-A Coordenacao/Audit | 0 | Abrir Track 08, registrar gap report e Kanban | Nenhuma |
| T08-B App Shell Lifecycle | 1 | Consolidar contrato de rotas/back/orientacao | T08-A |
| T08-C Session/Save Boundary | 1 | Endurecer invariantes de sessao, save, cache e runtime config | T08-A |
| T08-D Mobile UI Contract | 1 | Centralizar regras de touch, scroll, botoes e layout responsivo | T08-A |
| T08-E Battle Mode Contract | 2 | Formalizar batalha como modo fullscreen landscape com summary seguro | T08-B |
| T08-F Service/Asset Contract Checks | 2 | Checagens leves de contratos, endpoint scopes, registry e assets | T08-A |
| T08-G Validation Harness | 3 | Criar smoke final de hardening e matriz quick/full/release atualizada | T08-B a T08-F |
| T08-H Integracao | 0 final | Integrar, resolver conflitos, validar matriz e atualizar status/portfolio | T08-B a T08-G |

## T08-A - Coordenacao/Audit

Status: `COMPLETE`.

- Create Track 08 docs, registry, prompts and gap report.
- Update project status, local AGENTS and portfolio snapshots.
- Register Doing entry.
- Do not change Godot runtime, backend, schema, economy, assets or release state.

Validation: `git diff --check`.

## T08-B - App Shell Lifecycle

Status: `COMPLETE`.

- Consolidate route/back/orientation contract after Track 07.
- Extract a small route helper only if it reduces risk and is easy to test.
- Cover legacy aliases, Refugio root, back stack, `battle_running` landscape and summary/refuge return.
- Keep `boot.gd` as orchestrator.

Validation: `validate.gd`, GUT and `git diff --check` passed in `codex/draxos-mobile/t08-app-shell-lifecycle`.

## T08-C - Session/Save Boundary

Status: `COMPLETE`.

- Harden invariants for normal vs `progression_lab`, local-only cache, runtime config fallback and per-surface snapshots.
- Add non-secret `diagnostics_snapshot` if useful for internal debug.
- Do not alter Auth, HTTP contracts, schema, `players.save_type` or public payloads.

Validation: `test_session_shell.gd`, `validate.gd`, GUT and `git diff --check` passed in `codex/draxos-mobile/t08-session-save-boundary`.

## T08-D - Mobile UI Contract

Status: `COMPLETE`.

- Centralize minimum touch target, drag threshold, scrollbar/touch policy and responsive layout rules.
- Reuse `DraxosTouchScrollContainer` and existing shell helpers.
- Avoid redesign, asset swaps or broad UI rework.

Validation: focused GUT, `smoke_mobile_presentation.gd`, `validate.gd` and `git diff --check` passed in `codex/draxos-mobile/t08-mobile-ui-contract`.

## T08-E - Battle Mode Contract

Status: `COMPLETE`.

- Formalize battle/replay as fullscreen gameplay mode.
- Cover no app chrome, landscape route, safe skip, mandatory summary, read-only replay/history and Refugio return.
- Do not touch simulator, rewards, ranking, `battle_log_v1` or battle endpoints.

Validation: `smoke_battle_replay.gd`, battle fullscreen/summary GUT, `validate.gd` and `git diff --check` passed in `codex/draxos-mobile/t08-battle-mode-contract`.

## T08-F - Service/Asset Contract Checks

Status: `COMPLETE`.

- Add lightweight checks for endpoint matrix scopes, feature registry completeness and `AssetIds` fallback stability.
- No endpoints, schema, migrations, final assets or services.

Delivered in `codex/draxos-mobile/t08-service-asset-contracts`:

- `server/tests/foundation_contracts_test.ts` checks `docs/contracts/api-endpoints.md` endpoint matrix scopes and Track 06 feature card completeness.
- `tests/client/test_content_foundation.gd` now locks optional missing-art fallback ids separately from installed Pack 01 ids.
- `server/tests/README.md` documents the no-Supabase foundation contract test command.

Validation: Deno check/test/lint for `foundation_contracts_test.ts`, `validate.gd`, GUT client and `git diff --check`.

## T08-G - Validation Harness

Status: `COMPLETE`.

- Add `tools/smoke_foundation_hardening.gd`.
- Update tools docs and Track 08 validation matrix.
- Smoke should cover routes, back stack, session/save boundary, touch/layout contract and battle mode without network where possible.

Delivered in `codex/draxos-mobile/t08-integration`:

- `tools/smoke_foundation_hardening.gd` covers route/back aliases, mobile touch/layout contract, session/save/runtime config boundary and battle fullscreen/summary contract without network.
- `tools/README.md` documents the smoke command.
- `tools/validate.gd` now verifies the smoke resource exists.

Validation: `smoke_foundation_hardening.gd` passed in headless mode.

## Validation Matrix

| Package | Purpose | Commands |
|---|---|---|
| Quick | Local foundation sanity before small client changes | `tools/validate.gd`, `tools/smoke_foundation_hardening.gd`, `git diff --check` |
| Full | Integration confidence for Track 08 and future feature tracks | Quick package plus GUT complete, `smoke_session_shell.gd`, `smoke_runtime_config.gd`, `smoke_mobile_presentation.gd`, `smoke_foundation_surfaces.gd`, `smoke_battle_replay.gd`, `smoke_exports.gd` |
| Release | Readiness before build/export/publication tasks | Full package plus release/export checks already documented in `docs/release-ops-checklist.md`; do not publish unless a release task explicitly authorizes it |
| Remote | Remote Supabase/portal confidence | Run only with approved remote env and publishable key; no service role in client/smokes |

## T08-H - Integracao

Status: `COMPLETE`.

- Integrate T08-B to T08-G safely.
- Resolve conflicts without hiding validation failures.
- Run final validation matrix.
- Update current-status, Track 08 status and portfolio snapshots.

Final validation:

- `tools/validate.gd`
- GUT client complete
- `tools/smoke_session_shell.gd`
- `tools/smoke_runtime_config.gd`
- `tools/smoke_mobile_presentation.gd`
- `tools/smoke_foundation_hardening.gd`
- `tools/smoke_foundation_surfaces.gd`
- `tools/smoke_battle_replay.gd`
- `tools/smoke_exports.gd`
- Deno checks if applicable
- `git diff --check`

Final result: passed in `codex/draxos-mobile/t08-integration`. `smoke_battle_replay.gd` required serving the current `battle` function locally with `BATTLE_FUNCTION_URL=http://127.0.0.1:8000` because the default Edge Runtime on `127.0.0.1:54321` was still serving an older `battle` function without `/battle/history`.

## Assumptions

- `boot.gd` remains the orchestrator.
- `players.save_type` remains for this phase.
- Foundation hardening comes before the next feature/assets/services track.
- No tuning, gameplay, endpoint, schema, asset final or release publication is part of Track 08.
