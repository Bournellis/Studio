# DraxosMobile Handoff: validation-release - Publish Master Main URL

## Metadata

- data: `2026-06-04`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `validation-release`
- mode_scope: `openworld`
- branch: `codex/draxos-mobile/publish-master-main-url`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--publish-master-main-url`

## Objetivo

Publicar a versao ja mergeada em `master` como nova Internal Alpha usando a URL principal `https://draxos-mobile-internal-alpha.pages.dev/` como Portal/Web oficial.

## Latest Context

- latest Arena loop package: `Track 21 - Arena Loop Unlock And Friction Pass`
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`
- latest local integration in `master`: `Openworld Collection Sync Local Fix` + `Main Menu Refactor`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `Projetos/draxos-mobile/implementation/tracks/track-13-validation-release-safety/release-safety-contract.md`
- `Projetos/draxos-mobile/implementation/tracks/track-13-validation-release-safety/validation-matrix.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Escopo

- Incluir:
  - release plan/package/upload/manifest para um release root fresco;
  - Cloudflare Pages production deploy na branch `main`;
  - validacao remota read-only e smoke Web no hash de evidencia;
  - atualizacao dos snapshots vivos com release root, URL oficial e evidencia.
- Fora do escopo:
  - novas features, tuning, economia, PVP, novas migracoes nao existentes no `master`;
  - alteracoes de gameplay alem do que ja esta mergeado;
  - uso de hash Pages como URL player-facing.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- esta nota de handoff

## Validation Plan

- `git diff --check`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Plan -ReleaseRoot <root> -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Package -ReleaseRoot <root> -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Upload -ReleaseRoot <root> -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -ConfirmRemoteMutation`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_cloudflare_pages_package.ps1 -ProjectDir . -StaticAssetBaseUrl <versioned-web-root>`
- `npx -y wrangler@latest pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode DeployManifest -ReleaseRoot <root> -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -ConfirmRemoteMutation`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly -ExpectedReleaseRoot <root> -RemoteWebUrl <preview>/web/index.html -AllowCloudflareAccess`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\smoke_web_launch_remote.ps1 -WebUrl <preview>/web/index.html -ExpectedReleaseRoot <root> -NoProjectWrites`

## Handoff Point

Handoff concluido quando a nova publicacao ficou acessivel pela URL principal, com hash Pages registrado apenas como evidencia tecnica, manifest remoto alinhado e snapshots vivos atualizados.

## Resultado

- Publicado: `Openworld Main Menu Sync`
- Release root: `internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`
- Portal oficial: `https://draxos-mobile-internal-alpha.pages.dev/`
- Web direto: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Evidencia tecnica Cloudflare Pages: `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`
- Android APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8/downloads/draxos-mobile-alpha.apk`
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8/downloads/draxos-mobile-alpha.zip`

## Validacao Executada

- `validate_foundation.ps1 -Profile ReleaseDryRun`: PASS.
- `supabase db push --linked --yes`: PASS; aplicou `202606040002_openworld_bosque_collection_sync_v1.sql`.
- `supabase functions deploy modes --project-ref armxgipvnbbshzqawklw`: PASS.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan`, `Package`, `Upload`, `DeployManifest`: PASS com `-PublicDownloads`, URL principal e `-ConfirmRemoteMutation` nos modos mutantes.
- `build_cloudflare_pages_package.ps1`: PASS.
- `wrangler@4.98.0 pages deploy ... --branch main`: PASS, preview `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8 -RemoteWebUrl https://aeec7403.draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS.
- Remote Web launch smoke: PASS, `game_loaded` em `4639 ms`, release root correto, sem runtime errors.

## Observacoes

- `server/tests/release_manifest_smoke.ts` foi corrigido para bloquear roots Openworld antigos explicitos em vez de rejeitar qualquer novo root que comece com `internal-alpha/v0-openworld`.
- Production domain anonimo pode retornar Cloudflare Access; o hash Pages foi usado como evidencia tecnica liberada.
- Proximo passo recomendado: playtest humano de coleta/deposito/resync no Bosque e conferida do menu principal simplificado.
