# DraxosMobile Done: Arena/Bosque Regression Hotfix Publish

## Metadata

- data: `2026-06-05`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch/trunk: `main`
- source commit: `a16ca4f`
- release root: `internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f`
- official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- deployment evidence: `https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev`

## Objetivo

Publicar na URL principal o hotfix que restaura:

- `Preparacao` antes de iniciar Arena PVE, durante tentativa ativa e na escolha de buff;
- deposito/criacao do Bosque integrado com feedback local, persistencia e flush de eventos antes de sair;
- APK Internal Alpha atualizado.

## Publicacao Executada

- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: PASS.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -ReleaseRoot internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl <versioned-web-asset-root>`: PASS.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: PASS, preview `https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation`: PASS.

## Validacao Remota

- `release_artifacts_remote_smoke.ts` com env local carregado: PASS.
- `smoke_web_launch_remote.ps1` no preview com timeout 120s: PASS, Web carregou em `3770 ms`, release root e asset root corretos, sem runtime errors.
- `internal_alpha_remote_smoke.ts` read-only release/CORS: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f -RemoteWebUrl https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS com env local carregado; docs/release guards, remote artifacts smoke, read-only release/CORS smoke e Web launch smoke passaram, Web carregou em `3494 ms`.

## Artefatos

- Android APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f/downloads/draxos-mobile-alpha.apk`
- Android APK SHA256: `82b5476504e559ec72b83caac1c6fd82beea7cf35562e4bb0ab49bf81bc89138`
- PC ZIP SHA256: `54263a71119e3d121ce668f343792da069e73ffc43aac24facfeb8e1da6f9417`
- Web Index SHA256: `6a1525cd66f95d1ab8f20a781c0c5039813af1ce8cb75a1081ff8f0c6b7dce8a`

## Proximo Passo Seguro

Playtest humano do pacote publicado focando Preparacao em todos os estados de Arena e Bosque deposit/craft/persistencia antes de abrir tuning amplo ou expansao de modo.
