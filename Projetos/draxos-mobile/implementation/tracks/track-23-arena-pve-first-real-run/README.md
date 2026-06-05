# Track 23 - Arena PVE First Real Run + Update Recovery

- Status: `PUBLISHED_INTERNAL_ALPHA`
- Data: `2026-06-05`
- Projeto: `draxos-mobile`
- Branch: `codex/draxos-mobile/arena-pve-first-real-run`
- Escopo: client Arena PVE, recovery de tentativa ativa antiga, primeira arena real de 3 duelos, docs e publicacao Internal Alpha.

## Objetivo

Fechar a proxima fase da Arena PVE sem expandir PVP ou Openworld:

- manter o tutorial como 1 duelo;
- preservar a primeira arena real como 3 duelos com buff entre vitorias;
- impedir que uma tentativa ativa antiga bloqueie o jogador depois de updates;
- oferecer caminhos explicitos de `Retomar tentativa`, `Abandonar tentativa` e `Encerrar tentativa antiga`;
- manter recompensas server-authoritative e sem economia no abandono.

## Entrega Local

- `ACTION_ARENA_RESUME_ATTEMPT` e `ACTION_ARENA_ABANDON_ATTEMPT` entram no contrato de shell.
- `arena/pve/abandon` entra no roteador de mutacoes idempotentes.
- Dispatcher/facade chamam `resume_attempt` e `abandon_attempt`.
- Lifecycle:
  - roteia tentativa ativa para active/buff/summary conforme estado;
  - detecta tentativa incompatavel ou sem proximo passo valido;
  - barra start local quando existe tentativa ativa;
  - chama `SupabaseClient.abandon_arena_attempt` com `request_id/request_hash`.
- Presenter:
  - selecao bloqueia nova arena quando existe tentativa ativa;
  - mostra painel `ArenaActiveAttemptPanel` para retomar/abandonar;
  - mostra painel `ArenaAttemptRecoveryPanel` para encerrar tentativa antiga;
  - adiciona abandono nas telas active e buff.
- Dev fixture passa a simular abandono terminal sem recompensa.

## Validacao Local

- `deno test --allow-read server/tests/arena_loop_unlock_friction_test.ts`: PASS, 6 tests.
- `Godot GUT client suite`: PASS, 229 tests.
- `validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ModePlatform -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: PASS after moving the active Doing card to Done, as required by release safety.

## Publicacao

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

Validacao de publicacao:

- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- `wrangler pages deploy ... --branch main`: PASS.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a -RemoteWebUrl https://2c020d09.draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS.
- Remote Web launch smoke carregou o jogo em `3463 ms`, com release root e asset root corretos e sem runtime errors.

Notas:

- Android APK usa `debug_fallback`, aceito para closed Internal Alpha.
- Stable Portal/Web seguem Cloudflare Access protected; preview hash e evidencia tecnica.
