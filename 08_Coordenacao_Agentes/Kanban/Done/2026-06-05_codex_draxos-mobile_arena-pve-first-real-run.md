# Done - DraxosMobile Arena PVE First Real Run

## Metadata

- data: `2026-06-05`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/arena-pve-first-real-run`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-pve-first-real-run`
- base: `master` @ `fa59157`
- status: `PUBLISHED_INTERNAL_ALPHA`
- pacote: `Track 23 - Arena PVE First Real Run + Update Recovery`
- publicacao_remota: `APROVADA_PELO_USUARIO_NESTE_PEDIDO`

## Objetivo

Implementar a proxima fase da Arena PVE como primeira run real de 3 duelos, com fluxo de tentativa completo e recuperacao segura quando um update deixa uma arena aberta incompativel ou inacessivel.

## Entregue

- Contrato do shell com `arena_resume_attempt` e `arena_abandon_attempt`.
- Roteamento idempotente para `/arena/pve/abandon`.
- Dispatcher/facade/lifecycle com retomar tentativa, abandono e guarda local antes de iniciar nova arena.
- Selecao de Arena bloqueia nova tentativa quando existe `active_attempt` e oferece `Retomar tentativa`, `Abandonar tentativa` ou `Encerrar tentativa antiga`.
- Tentar resolver duelo em tentativa antiga/incompativel volta para recovery em vez de manter o jogador preso.
- Dev fixture simula abandono terminal sem recompensa de conclusao.
- Testes client/server cobrem recovery, abandono e primeira arena real de 3 duelos.

## Validacao Local

- `git diff --check`: PASS.
- `deno test --allow-read server/tests/arena_loop_unlock_friction_test.ts`: PASS, 6 tests.
- `Godot GUT client suite`: PASS, 229 tests.
- `validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ModePlatform -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: primeira tentativa BLOCKED somente por card Doing ativo; card movido para Done para repetir.

## Commit, Merge E Publicacao

- Commit de implementacao: `1cbfa66`.
- Merge em `master`: `852aa71` (`Merge Arena PVE update recovery`).
- Publicacao final executada a partir do `master` atual `b69108a`, preservando tambem o merge posterior de Scenario Fixtures V1 no trunk.
- Release root: `internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a`.
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`.
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`.
- Preview evidence: `https://2c020d09.draxos-mobile-internal-alpha.pages.dev`.
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`.
- Android APK SHA256: `ae886a7790c19213c44a728e56481126e20f47b4ddb588e2ffdfc99fd99fd7ce`.
- PC Windows ZIP SHA256: `09f3be25a8a5520876796fbe3ec7ab60281b773f4807e96c7b83422437e706ff`.
- Web Index SHA256: `fb549621d02bafc85cf1eece7ff69bd90c2daa445aa3f83de44e9bc8e8e31a2d`.

## Validacao Remota

- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- `wrangler pages deploy ... --branch main`: PASS.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a -RemoteWebUrl https://2c020d09.draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS.
- Remote Web launch smoke carregou o jogo em `3463 ms`, com release root e asset root corretos e sem runtime errors.
- Stable Portal/Web seguem Cloudflare Access protected. Android APK usa `debug_fallback`, aceito para closed Internal Alpha.

## Handoff

Publicado na URL principal e pronto para playtest humano do pacote Arena PVE First Real Run + Update Recovery.
