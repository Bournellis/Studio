# DraxosMobile - Bosque Sync Responsiveness v1 Release

## Status

Concluido em `main` e publicado na Internal Alpha em 2026-06-05.

## Release

- Pacote: `Bosque Sync Responsiveness v1`
- Status: `BOSQUE_SYNC_RESPONSIVENESS_V1_PUBLISHED_INTERNAL_ALPHA`
- Release root: `internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Deployment evidence: `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`
- Version: `0.0.3-alpha.0`
- Version code: `3`

## Entregas

- Todos os worktrees/branches abertos de DraxosMobile estavam limpos e contidos em `main`.
- Migration remota `202606050003_openworld_bosque_collect_batch_v1.sql` aplicada e alinhada com `supabase migration list --linked`.
- Web e APK publicados em novo release root.
- Manifest remoto atualizado para o pacote novo.
- Edge Function `release` redeployada.
- Cloudflare Pages production branch `main` atualizada.

## Evidencia

- APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95/downloads/draxos-mobile-alpha.apk`
- APK SHA256: `b6924a295e5a46df7f09f50ca5fa17292b9fc6b24792bfe28055e02ca03c41b5`
- PC ZIP SHA256: `bee30a683fa3f895ef0e9012f0499d0d521d9395899fa5dc513c411c57a56294`
- Web Index SHA256: `4c4b9f208d3b7645a810e62439aa3ec62d7db2f88e8c7c8ecafa7ec69d72d1df`

## Validacao

- `validate_foundation.ps1 -Profile ReleaseDryRun -RequireClean -NoProjectWrites`: PASS.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Package`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- `wrangler pages deploy ... --branch main`: PASS.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly ...`: PASS, Web loaded in `4246 ms`.

## Proximo Passo

Playtest humano do pacote publicado: coletar 10+ recursos rapidamente, depositar durante sync pendente, craftar, sair/reabrir e confirmar persistencia de bolso/bau/nodes, alem de revalidar Arena Preparacao e buff -> Resolver duelo.
