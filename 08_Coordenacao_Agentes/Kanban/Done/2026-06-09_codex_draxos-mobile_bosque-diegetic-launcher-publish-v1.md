# DraxosMobile - Bosque Diegetic Launcher Publish v1

## Resultado

Publicado Web+APK do pacote `Bosque Diegetic Launcher Foundation v1` como novo Internal Alpha remoto do DraxosMobile.

- Status: `BOSQUE_DIEGETIC_LAUNCHER_FOUNDATION_V1_PUBLISHED_INTERNAL_ALPHA`
- Branch/worktree: `codex/draxos-mobile/bosque-diegetic-launcher-publish-v1` em `D:\Estudio-worktrees\draxos-mobile--codex--bosque-diegetic-launcher-publish-v1`
- Release commit: `e55ed0c`
- Release root: `internal-alpha/v0-bosque-diegetic-launcher-foundation-v1-20260609-e55ed0c`
- Versao: `0.0.16-alpha.0`
- Version code: `16`
- Minimum supported version code: `13`
- Portal oficial: `https://draxos-mobile-internal-alpha.pages.dev/`
- Web direto: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Preview/evidencia Cloudflare Pages: `https://56b58162.draxos-mobile-internal-alpha.pages.dev`

## Artefatos

- Android APK: `32117734` bytes, SHA256 `610c3cbfecda3819e0d18ce107e18bf22ccadb99e7b5ab8b8888a6873f2780e7`
- PC Windows ZIP: `40534623` bytes, SHA256 `91317eccc56a921b49e602f7b4e8a054e7b7be100bbcb26e38f428684701d8b6`
- Web Index: `5442` bytes, SHA256 `6e199bebd93f12db42898340010d265e3e2665698a43b4f40248cea75649fef8`
- Cloudflare Pages package ZIP: `1625390` bytes
- Android export mode: `debug_fallback`; aceito somente para playtest Internal Alpha fechado enquanto keystore release dedicada segue pendente.

## Execucao Remota

- `export_internal_alpha.ps1` concluiu com sucesso e gerou APK/PC/Web.
- `publish_internal_alpha.ps1 -Mode FullPublish -ConfirmRemoteMutation` fez upload dos artefatos, atualizou o manifest override remoto e redeployou `release`.
- A checagem final anonima do portal estavel dentro do script encontrou Cloudflare Access em vez do HTML do portal; os passos remotos anteriores ja tinham sido aplicados. O estado foi validado com smokes Access-aware e preview hash.
- `build_cloudflare_pages_package.ps1` gerou o pacote hibrido Cloudflare Pages.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main` publicou o preview `https://56b58162.draxos-mobile-internal-alpha.pages.dev`.
- Depois da auditoria do endpoint protegido, `INTERNAL_ALPHA_RELEASE_ROOT` foi setado para o root atual e a funcao `release` foi redeployada para alinhar fallback e signed downloads ao pacote novo.

## Validacoes Executadas

- `smoke_web_launch_remote.ps1` no preview hash: PASS, `game_loaded`, release root esperado encontrado, sem runtime errors.
- `server/tests/release_manifest_smoke.ts`: PASS apos redeploy final de `release`.
- `server/tests/release_artifacts_remote_smoke.ts` com `DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS=1`: PASS; Portal/Web estaveis reconhecidos como protegidos por Cloudflare Access.
- `server/tests/internal_alpha_remote_smoke.ts` com release/CORS: PASS apos redeploy final de `release`.
- `git diff --check`: PASS no fechamento.
- `deno task --cwd server/functions check`: PASS no fechamento.
- `deno task --cwd supabase/functions check`: PASS no fechamento.
- `validate_foundation.ps1 -Profile ReleaseDryRun`: PASS no fechamento, incluindo live-doc guard, release safety, Track 13 readiness e agent ops foundation.
- `validate_foundation.ps1 -Profile ClientQuick`: PASS no fechamento; GUT client `262/262`, `3937` asserts, alem de smokes client/export/responsivo.
- `validate_foundation.ps1 -Profile ModePlatform`: PASS no fechamento; Deno mode platform `49/49` e smokes `smoke_bosque_entry.gd`, `smoke_openworld_forest.gd`, `smoke_modes_visual_layout.gd`, `smoke_modes_ops_panel.gd`.

## Docs E Contratos Atualizados

- Versionamento/release: `core/project_info.gd`, `tools/export_internal_alpha.ps1`, `tools/publish_internal_alpha.ps1`, `server/functions/release/index.ts`, `supabase/functions/release/index.ts`, smokes remotos.
- Portal/manifest: `portal/internal-alpha/index.html`, `portal/internal-alpha/manifest.example.json`.
- Docs vivos: `AGENTS.md`, `Projetos/draxos-mobile/AGENTS.md`, `README.md`, `implementation/current-status.md`, `docs/agent-operating-manual.md`, `docs/documentation-index.md`, `docs/multi-agent-workflow.md`, `docs/product-vision.md`, `docs/product-brief.md`, `docs/design-pending.md`, `docs/minigames/openworld.md`, `docs/minigames/autobattler.md`, `docs/pve-arena-v1.md`, `docs/contracts/update-manifest.md`, `docs/contracts/api-endpoints.md`.
- Portfolio/canon: `canon/canon-brief.md`, `Projetos/README.md`, `08_Coordenacao_Agentes/Prioridades_Estudio.md`, `08_Coordenacao_Agentes/Estado_Atual.md`, `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`.

## Handoff

O pacote atual publicado e `Bosque Diegetic Launcher Foundation v1`. Bosque Bootstrap Authority v1 passa a ser pacote bootstrap anterior. Proximo passo operacional: playtest humano focado do pacote publicado em Web/APK, validando prompts/landmarks do Bosque, abertura de Arena/Base/Shop/Social/Profile, retorno via `Voltar`, ausencia de entradas Tower/Card/dev tools e regressao rapida Arena/Bosque.
