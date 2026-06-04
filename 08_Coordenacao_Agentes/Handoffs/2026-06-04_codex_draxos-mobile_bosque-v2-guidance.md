# Handoff - DraxosMobile Bosque Mecanico Basico v2

- Date: `2026-06-04`
- Agent: `Codex`
- Branch: `codex/draxos-mobile/bosque-v2-guidance`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-v2-guidance`
- Base branch: `master`
- Remote mutation: not executed
- Remote publication: not executed
- Status: local integration package implemented and validated, with one
  out-of-scope `ServerQuick` Arena contract failure noted below.

## Commits

- `4d8d9d1 Register Bosque v2 integration work`
- `8af97b7 Implement Bosque v2 guidance and campfire client`
- `8b2aa61 Document Bosque v2 openworld scaffold`
- `f01461e Persist openworld guidance state`
- Final status/handoff commit: see branch HEAD after this file is committed.

## Scope Delivered

- Bosque direction documented as a free, relaxing minigame: collect, deposit,
  craft and small visual builds.
- No mandatory objective, no `goal_completed`, no completion/failure language.
- Optional six-step guidance appears as a discreet HUD banner, does not block
  input, can be advanced/hidden and can be reopened from the `Sessao` sheet.
- Guidance state is persisted server-side in the normal save under
  `game_saves.snapshot.openworld.forest.guidance`.
- New idempotent mode event: `guidance_update`.
- Bosque snapshots/ACK patches can include `guidance`.
- Fixed resource nodes now cover `bolsa_simples_1` and `fogueira_estavel_1`
  with small slack.
- `fogueira_estavel_1` is a procedural Godot object at approximately
  `x=305, y=330`, appears after the upgrade, persists via snapshot/upgrades,
  respects y-sort and has small blocking collision.
- `Completar` is now `Encerrar visita`; local summary reports time, deposited
  items and creations.
- `Voltar` preserves the online visit for resume.

## Validation

Passed:

- `git diff --check`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --import`
- GUT client suite: `214/214` tests passed, including `30/30` Openworld tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ModePlatform`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_openworld_forest.gd`

Partial:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`
  - Openworld/modes backend tests passed, including `guidance_update`, guidance
    ACK patch and migration mirror coverage.
  - Overall profile failed only on existing out-of-scope Arena contract:
    `server/tests/arena_loop_unlock_friction_test.ts` expects literal
    `Proximo desafio\n`, while the current Arena presenter renders
    `Proximo desafio` as a separate label.

## Next Recommended Step

Human playtest of the local branch:

- first visit shows guidance and does not block movement;
- collect/deposit/craft remain free-form;
- hide/reopen guidance through `Sessao`;
- `Voltar` exits and preserves the visit;
- `Encerrar visita` shows light summary;
- craft `fogueira_estavel_1` and verify visual/collision/resume.
