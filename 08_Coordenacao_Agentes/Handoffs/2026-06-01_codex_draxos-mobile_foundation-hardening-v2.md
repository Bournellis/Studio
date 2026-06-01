# DraxosMobile Hardening Handoff: integrator - Foundation Hardening V2

## Metadata

- data: `2026-06-01`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `integrator`
- mode_scope: `multi-mode`
- branch: `codex/draxos-mobile/foundation-hardening-v2`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2`

## Objetivo

Executar Foundation Hardening V2 como pacote de enforcement puro para preparar DraxosMobile para expansao pesada multi-modo e multiagente, com nova Internal Alpha publicada somente se Android release keystore e gates locais/remotos permitirem.

## Latest Context

- current platform baseline: `Foundation Hardening V2`
- current release root: `internal-alpha/v0-foundation-hardening-v2-20260601-aa07388`
- current Cloudflare preview: `https://2cba1ff3.draxos-mobile-internal-alpha.pages.dev`
- latest Arena loop package: `Track 21 - Arena Loop Unlock And Friction Pass`
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/hardening-platform-v1-readiness-report.md`

## Lanes Registradas

| Lane | Branch | Worktree |
|---|---|---|
| `coord-canon-docs` | `codex/draxos-mobile/foundation-hardening-v2-coord-canon-docs` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-coord-canon-docs` |
| `backend-mode-enforcement` | `codex/draxos-mobile/foundation-hardening-v2-backend-mode-enforcement` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-backend-mode-enforcement` |
| `client-session-enforcement` | `codex/draxos-mobile/foundation-hardening-v2-client-session-enforcement` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-client-session-enforcement` |
| `validation-security-gates` | `codex/draxos-mobile/foundation-hardening-v2-validation-security-gates` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-validation-security-gates` |
| `data-labs-mode-decisions` | `codex/draxos-mobile/foundation-hardening-v2-data-labs-mode-decisions` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-data-labs-mode-decisions` |
| `release-ops-keystore` | `codex/draxos-mobile/foundation-hardening-v2-release-ops-keystore` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-release-ops-keystore` |

## Escopo

- Incluir:
  - canon/live-doc drift enforcement;
  - `/modes` backend modularity and mutating endpoint idempotency;
  - session/client mutation boundaries;
  - strict mode data schemas and decision packs;
  - validation/security gates;
  - read-only ops CLI;
  - backend proprio boundary inventory;
  - Android release keystore gate and release readiness report.
- Fora do escopo:
  - gameplay novo;
  - conteudo jogavel novo;
  - tuning numerico;
  - PVP/social expansion;
  - visual redesign;
  - remote publish before FullLocal and ReleaseDryRun pass.

## Arquivos Pretendidos

- `canon/canon-brief.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/`

## Validation Plan

- `git diff --check`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile FullLocal`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`

## Handoff Point

## Resultado Final

- Status: `PUBLISHED_INTERNAL_ALPHA`.
- V2 foi implementado como pacote de enforcement puro, sem gameplay/conteudo novo.
- Android release keystore foi configurada localmente fora do Git.
- `FullLocal` passou em `2026-06-01` com a keystore release configurada.
- `ReleaseDryRun` passou em `2026-06-01` com a keystore release configurada.
- Export Android/PC/Web passou; Android saiu em modo `release`, sem `debug_fallback`.
- Release root publicado: `internal-alpha/v0-foundation-hardening-v2-20260601-aa07388`.
- Mutacoes remotas executadas:
  - migrations `202606010003_foundation_hardening_v2.sql` e `202606010004_resource_reconciliation_stability.sql` aplicadas;
  - Edge Function `modes` publicada;
  - artefatos V2 enviados ao Supabase Storage via `Mode Upload`.
- Cloudflare Pages package foi gerado, validado contra `index.pck`/`index.wasm` remotos e publicado em `https://2cba1ff3.draxos-mobile-internal-alpha.pages.dev`.
- Release manifest foi promovido para V2 via `DeployManifest`.
- `RemoteReadOnly` passou contra o manifest, Portal/Web e artefatos V2.
- `master` pode ser promovido para baseline V2 apos commit final e validacao da arvore principal.

## Bloqueio De Publicacao

Bloqueios resolvidos nesta retomada:

- Android release keystore configurada localmente.
- Gate estrito passou:
  `tools/check_android_release_keystore.ps1 -Mode ReleaseCandidate -RequireReleaseKeystore`.
- Artefatos locais gerados:
  - `build/android/draxos-mobile-alpha.apk`;
  - `build/pc/draxos-mobile-alpha.zip`;
  - `build/web/index.html`.
- Supabase URL/projeto configurados em `.env.internal-alpha.local`.
- Worktree linkada ao Supabase project `armxgipvnbbshzqawklw`.
- Wrangler/Cloudflare autenticado novamente.
- Cloudflare Pages publicado.
- Manifest remoto promovido.
- Remote read-only smokes passaram.

Bloqueio restante: nenhum para a publicacao V2.

## Validacoes Executadas

- `npx -y deno test --allow-read server/tests/foundation_closeout_schema_test.ts`
- `npx -y deno check server/tests/foundation_admin_rls_live_smoke.ts`
- `npx -y deno run --allow-net --allow-env server/tests/foundation_admin_rls_live_smoke.ts`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile FullLocal`
- `tools/check_android_release_keystore.ps1 -ProjectDir . -Mode ReleaseCandidate -RequireReleaseKeystore`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`
- `tools/export_internal_alpha.ps1 -ProjectDir . -GodotExe D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe`
- `tools/publish_internal_alpha.ps1 -ProjectDir . -Mode Plan -ReleaseRoot internal-alpha/v0-foundation-hardening-v2-20260601-aa07388 -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -PublicDownloads`
- `tools/publish_internal_alpha.ps1 -ProjectDir . -Mode Package -ReleaseRoot internal-alpha/v0-foundation-hardening-v2-20260601-aa07388 -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -PublicDownloads`
- `npx -y supabase@2.98.0 db push --linked --dry-run`
- `npx -y supabase@2.98.0 db push --linked --yes`
- `npx -y supabase@2.98.0 functions deploy modes --project-ref armxgipvnbbshzqawklw`
- `tools/publish_internal_alpha.ps1 -ProjectDir . -Mode Upload -ReleaseRoot internal-alpha/v0-foundation-hardening-v2-20260601-aa07388 -StaticSiteBaseUrl https://draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation`
- `tools/build_cloudflare_pages_package.ps1 -ProjectDir . -StaticAssetBaseUrl https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-hardening-v2-20260601-aa07388/web`
- Public HEAD checks para Android APK, PC ZIP, Web `index.pck` e Web `index.wasm`.
- `npx -y wrangler whoami`
- `npx -y wrangler pages deploy .\build\internal-alpha\cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`
- `tools/publish_internal_alpha.ps1 -ProjectDir . -Mode DeployManifest -ReleaseRoot internal-alpha/v0-foundation-hardening-v2-20260601-aa07388 -StaticSiteBaseUrl https://2cba1ff3.draxos-mobile-internal-alpha.pages.dev -PublicDownloads -ConfirmRemoteMutation`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly`

## Relatorio

- `Projetos/draxos-mobile/docs/foundation-hardening-v2-readiness-report.md`
- `Projetos/draxos-mobile/build/validation/foundation-validation-latest.md`
- `Projetos/draxos-mobile/build/internal-alpha/release-plan.md`

## Proximo Handoff Seguro

1. Commitar o fechamento de docs/checks que promovem V2 a baseline atual.
2. Rodar `DocsOnly` e, se necessario, `FullLocal` apos os docs vivos.
3. Promover o branch integrador para `master` se a arvore principal estiver limpa.
4. Abrir as proximas threads de modo somente a partir do `master` atualizado.

Handoff final deve registrar commits, validacoes, publicacao, release root,
worktrees limpas/pendentes e proximos checks humanos.
