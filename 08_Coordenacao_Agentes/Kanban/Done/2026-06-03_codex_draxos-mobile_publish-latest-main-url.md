# DraxosMobile Done: Publish Latest Main URL

## Metadata

- data: `2026-06-03`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `validation-release`
- mode_scope: `multi-mode`
- branch: `codex/draxos-mobile/publish-latest-main-url`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--publish-latest-main-url`

## Objetivo

Publicar a versao mais recente integrada no `master` de DraxosMobile na URL
principal `https://draxos-mobile-internal-alpha.pages.dev/`.

## Resultado

- Status entregue: `LATEST_MAIN_URL_PUBLISHED_INTERNAL_ALPHA`.
- Status historico em `master`: preservado como publicacao superseded; o baseline
  remoto atual continua `Bosque Mecanico Basico v2`
  (`internal-alpha/v0-bosque-v2-guidance-20260604-7c2d981`).
- Release root:
  `internal-alpha/v0-latest-main-url-20260603-a056445`.
- Source `master` no inicio do worktree: `a056445`.
- Cloudflare Pages production/main: publicado.
- Cloudflare deployment evidence:
  `https://d63aa165.draxos-mobile-internal-alpha.pages.dev`.
- Cloudflare production deployment id:
  `d63aa165-7468-4645-8290-7580297a1431`.
- Portal oficial:
  `https://draxos-mobile-internal-alpha.pages.dev/`.
- Web direto:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`.
- Manifest remoto:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`.
- APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-latest-main-url-20260603-a056445/downloads/draxos-mobile-alpha.apk`.
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-latest-main-url-20260603-a056445/downloads/draxos-mobile-alpha.zip`.

## Publicacao

- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: passou.
- `publish_internal_alpha.ps1 -Mode Plan`: passou.
- `publish_internal_alpha.ps1 -Mode Package`: passou.
- `supabase db push --linked --yes`: passou; remote DB estava up to date.
- `supabase functions deploy --project-ref armxgipvnbbshzqawklw`: passou.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`: passou.
- `build_cloudflare_pages_package.ps1`: passou.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: passou.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`: passou.

## Validacao

- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: passou.
- `npx -y deno test --allow-read server/tests/arena_loop_unlock_friction_test.ts`:
  passou depois de alinhar uma assercao de texto obsoleta.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`: passou.
- Godot `--headless --import`: passou no worktree novo.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: passou
  com 208/208 GUT tests e 3422 asserts.
- `release_manifest_smoke.ts`: passou.
- `release_artifacts_remote_smoke.ts`: passou com
  `DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS=1`.
- `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1`:
  passou.
- `tools/smoke_web_launch_remote.ps1` no preview `d63aa165`: passou como
  `game_loaded`.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly
  -AllowCloudflareAccess -RemoteWebUrl
  https://d63aa165.draxos-mobile-internal-alpha.pages.dev/web/index.html
  -ExpectedReleaseRoot internal-alpha/v0-latest-main-url-20260603-a056445`:
  passou.

## Caveats

- O dominio fixo production retorna Cloudflare Access para GET anonimo, como
  esperado para Internal Alpha protegido. O preview hash `d63aa165` foi usado
  como evidencia publica de carga real do Web build.
- Android APK continua em `debug_fallback`, aceito para playtest funcional ate
  keystore release dedicada.

## Arquivos Atualizados

- `Projetos/draxos-mobile/server/tests/arena_loop_unlock_friction_test.ts`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Handoffs/2026-06-03_codex_draxos-mobile_publish-latest-main-url.md`

## Proximo Passo

Historico preservado para auditoria de publicacao. Proximo passo vivo foi
substituido pelo playtest/revisao de Bosque Mecanico Basico v2 e pela decisao de
publicacao/hotfix da integracao `Openworld Collection Sync Local Fix` + `Main
Menu Refactor`.
