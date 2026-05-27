# Track 07 - Implementation Plan

## Regra Da Track

Track 07 is a presentation loop and layout rework. It should make the current systems feel like a mobile-first app and a landscape autobattler without changing gameplay authority or backend contracts.

Expected commit stages:

- `docs:` track, scope, route contract, status and coordination.
- `client-shell:` route stack, orientation helpers, Back behavior and touch/scroll foundation.
- `client-refugio:` full-screen Refugio home, altar/hotspots and account panel.
- `client-surfaces:` Base, Social, Competition and Shop as internal screens.
- `client-battle:` full-screen landscape battle/replay and summary.
- `test:` GUT and smoke coverage for mobile presentation, portrait/landscape and PC/Web compatibility.
- `integration:` merge, conflict resolution, validation and portfolio/status update.

## Trilhas Paralelas Oficiais

| Trilha | Prioridade | Trabalho | Dependencia |
|---|---:|---|---|
| T07-A Coordenacao | 0 | Criar Track 07, status, plano, registry de agentes e Kanban | Nenhuma |
| T07-B App Shell/Foundation | 1 | Definir contrato de rotas, orientacao, back stack e scroll/touch foundation | T07-A |
| T07-C Refugio/Home | 2 | Transformar Refugio em home full screen com altar, menus e conta/login limpos | T07-B |
| T07-D App Screens | 2 | Adaptar Base, Social, Competicao e Loja para telas internas portrait/landscape | T07-B |
| T07-E Battle Fullscreen | 2 | Executar autobattler fullscreen landscape, skip bottom-right e resumo final | T07-B |
| T07-F PC/Web + Validation | 3 | Garantir desktop/browser, smoke de layout e regressao touch/scroll | T07-C a T07-E |
| T07-G Integracao | 0 final | Integrar, resolver conflitos, validar matriz e atualizar status/portfolio | T07-C a T07-F |

## Route Contract

Official routes for Track 07:

- `refuge_home`
- `account`
- `base`
- `social`
- `competition`
- `shop`
- `battle_entry`
- `battle_running`
- `battle_summary`
- `battle_lab`
- `progression_lab`

Back behavior:

- `refuge_home` is the root.
- Internal app screens push onto the route stack and can return to the previous route.
- Modal/panel routes close before leaving the current screen.
- `battle_running` owns its gameplay chrome and skip action.
- `battle_summary` can return to `refuge_home`, replay, or open battle history.

Orientation behavior:

- Non-gameplay routes support portrait and landscape.
- `battle_running` requests landscape on Android and restores the app orientation when exiting to summary or Refugio.
- PC/Web render a landscape battle frame inside the available window instead of relying on OS rotation.

## T07-A - Coordenacao

Status: `IN_PROGRESS`.

- Criar pasta da Track 07 com `scope.md`, `current-status.md`, `implementation-plan.md`, `agent-registry.md` e `agent-prompts.md`.
- Atualizar snapshots de portfolio e status local.
- Registrar Doing.
- Nao alterar runtime Godot, backend, schema, economia ou assets finais.

Validation: `git diff --check`.

## T07-B - App Shell/Foundation

Status: `COMPLETE_VALIDATED`.

- Add route constants and stack helpers.
- Replace global tab/list navigation with route-driven shell rendering.
- Add orientation helper functions with Android-only landscape lock for `battle_running`.
- Add mobile scroll/touch helper behavior so drag can begin over buttons after threshold while tap still works.
- Enlarge scroll affordance/touch target.
- Keep content presenters render-only where practical.

Handoff:

- Route ids are now normalized through the Boot shell; `hub`, `battle` and `monetization` remain accepted as compatibility aliases.
- The old global tab navigation row has been removed from the shell; navigation should be opened from Refugio hotspots and internal Back.
- `DraxosTouchScrollContainer` is the app content scroll foundation.
- Buttons use `_prepare_touch_button()` so scroll gestures can bubble through button surfaces.
- `battle_running` is the only route that currently declares landscape orientation.

Validation:

- `tools/validate.gd`: passed with `77/77` tests and `865` asserts.
- GUT client complete: passed with `77/77` tests and `865` asserts.
- `git diff --check`: passed.

## T07-C - Refugio/Home

Status: `PLANNED`.

- Make Refugio the first full-screen home.
- Render altar/ambient center with hotspot/menu actions for Battle, Base, Social, Competition, Shop, Profile/Account and dev Labs.
- Move login/register/guest dev into a focused account panel.
- Keep secondary actions such as sync/reset/update/save under account/config sections.
- Ensure Progression Lab appears when dev tools/editor are enabled.

Validation: Refugio/account/labs GUT, `smoke_session_shell.gd`, `validate.gd` and `git diff --check`.

## T07-D - App Screens

Status: `PLANNED`.

- Adapt Base, Social, Competition and Shop presenters to internal app screens opened from Refugio.
- Provide Back, portrait/landscape layout and comfortable scroll.
- Preserve existing actions, endpoints, schema, economy and contract messages.

Validation: `smoke_foundation_surfaces.gd`, focused GUT, `validate.gd` and `git diff --check`.

## T07-E - Battle Fullscreen

Status: `PLANNED`.

- Render battle/replay as full-screen landscape gameplay without app chrome.
- Place a large fixed `Pular` action in the lower-right corner.
- On finish/skip, render a full-screen summary with winner, duration, events, rewards/resources and return actions.
- Preserve `BattleLogPresenter`, `BattleVisualMockup`, `BattleStage2D`, battle endpoints and `battle_log_v1`.

Validation: `smoke_battle_replay.gd`, battle fullscreen/summary GUT, `validate.gd` and `git diff --check`.

## T07-F - PC/Web + Validation

Status: `PLANNED`.

- Add `tools/smoke_mobile_presentation.gd`.
- Cover portrait, landscape, PC/browser-compatible layout, route stack, Back, Refugio home, Progression Lab dev visibility, scroll over buttons, battle fullscreen and summary.
- Make only compatibility adjustments needed for the smoke to pass.

Validation: `smoke_mobile_presentation.gd`, `smoke_exports.gd`, `validate.gd`, GUT and `git diff --check`.

## T07-G - Integracao

Status: `PLANNED`.

- Integrate T07-B to T07-F in safe order.
- Resolve conflicts without hiding validation failures.
- Preserve Track 07 guardrails.
- Run the final validation matrix.
- Update `implementation/current-status.md`, Track 07 status and portfolio snapshots.

Final validation:

- `tools/validate.gd`
- GUT client complete
- `tools/smoke_session_shell.gd`
- `tools/smoke_battle_replay.gd`
- `tools/smoke_foundation_surfaces.gd`
- `tools/smoke_exports.gd`
- `tools/smoke_mobile_presentation.gd`
- `git diff --check`

## Assumptions

- The new track is Track 07.
- Refugio is the app home, not a tab.
- App routes outside gameplay support portrait and landscape.
- The first active gameplay mode is the autobattler and it is locked to landscape.
- Progression Lab remains dev/internal.
- PC executable and PC browser remain usable for testing and handoff.
