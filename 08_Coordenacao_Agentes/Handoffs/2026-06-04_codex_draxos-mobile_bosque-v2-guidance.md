# Handoff - DraxosMobile Bosque Mecanico Basico v2

- Date: `2026-06-04`
- Agent: `Codex`
- Branch: `codex/draxos-mobile/bosque-v2-guidance`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-v2-guidance`
- Base branch: `master`
- Remote mutation: executed with explicit user approval.
- Remote publication: published to official Internal Alpha URL.
- Status: Bosque Mecanico Basico v2 implemented, published and remotely
  validated; one out-of-scope local `ServerQuick` Arena contract failure remains
  noted below.

## Published Package

- Release root: `internal-alpha/v0-bosque-v2-guidance-20260604-7c2d981`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Cloudflare deployment evidence:
  `https://ae049df9.draxos-mobile-internal-alpha.pages.dev`
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-v2-guidance-20260604-7c2d981/downloads/draxos-mobile-alpha.apk`
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-v2-guidance-20260604-7c2d981/downloads/draxos-mobile-alpha.zip`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Preview Web smoke screenshot:
  `Projetos/draxos-mobile/build/diagnostics/web-launch-remote-20260604-194152/web-launch-remote.png`

## Commits

- `4d8d9d1 Register Bosque v2 integration work`
- `8af97b7 Implement Bosque v2 guidance and campfire client`
- `8b2aa61 Document Bosque v2 openworld scaffold`
- `f01461e Persist openworld guidance state`
- `7c2d981 Record Bosque v2 local validation status`
- Final publication/status commit: see branch HEAD after this file is committed.

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
- `supabase db push --linked --yes`: applied
  `202606040001_openworld_guidance_persistence_v1.sql`.
- `supabase functions deploy modes --project-ref armxgipvnbbshzqawklw`
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: passed with
  Android export mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan`, `Package`, `Upload` and
  `DeployManifest`: passed, with `-ConfirmRemoteMutation` for mutating stages.
- `build_cloudflare_pages_package.ps1`: passed.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name
  draxos-mobile-internal-alpha --branch main`: passed; preview
  `https://ae049df9.draxos-mobile-internal-alpha.pages.dev`.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot
  internal-alpha/v0-bosque-v2-guidance-20260604-7c2d981 -RemoteWebUrl
  https://ae049df9.draxos-mobile-internal-alpha.pages.dev/web/index.html
  -AllowCloudflareAccess`: passed. Preview Web smoke loaded the game in
  `3699 ms`; production fixed domain returned Cloudflare Access as expected.

Partial:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`
  - Openworld/modes backend tests passed, including `guidance_update`, guidance
    ACK patch and migration mirror coverage.
  - Overall profile failed only on existing out-of-scope Arena contract:
    `server/tests/arena_loop_unlock_friction_test.ts` expects literal
    `Proximo desafio\n`, while the current Arena presenter renders
    `Proximo desafio` as a separate label.

## Next Recommended Step

Human playtest of the published package:

- first visit shows guidance and does not block movement;
- collect/deposit/craft remain free-form;
- hide/reopen guidance through `Sessao`;
- `Voltar` exits and preserves the visit;
- `Encerrar visita` shows light summary;
- craft `fogueira_estavel_1` and verify visual/collision/resume.
