# DraxosMobile - Publicacao Foundation Final Polish

- Data: `2026-05-30`
- Agente: Codex
- Branch: `codex/draxos-mobile/foundation-final-polish`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-final-polish`
- Base: `8c658f6 chore: finish foundation final polish`
- Objetivo: publicar a ultima versao local validada de DraxosMobile Internal Alpha, sem schema remoto, sem Edge deploy e sem secrets no cliente.

## Escopo

- Exportar Android, PC Windows e Web a partir da branch Foundation Final Polish.
- Usar release root versionado novo.
- Rodar `publish_internal_alpha.ps1` em modos aprovados de publicacao com `-ConfirmRemoteMutation`.
- Gerar pacote Cloudflare Pages do mesmo worktree/export.
- Atualizar manifest remoto somente depois do upload e do pacote Web.
- Rodar smokes remotos read-only possiveis.
- Atualizar status vivo e handoff final.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`

## Validacao Planejada

- Reusar Full gate verde pos-commit do Foundation Final Polish como gate de fundacao.
- Rodar export/package/publicacao com artefatos frescos.
- Rodar smokes remotos read-only de manifest/artifacts quando URLs e chaves publicas estiverem disponiveis.
- Encerrar com `git diff --check`, status limpo e commit de documentacao de publicacao.

## Resultado

- Release root: `internal-alpha/v0-foundation-final-polish-20260530-8c658f6`
- Cloudflare preview: `https://721dc985.draxos-mobile-internal-alpha.pages.dev`
- Web: `https://721dc985.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Portal: `https://721dc985.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-final-polish-20260530-8c658f6/downloads/draxos-mobile-alpha.apk`
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-foundation-final-polish-20260530-8c658f6/downloads/draxos-mobile-alpha.zip`
- Android SHA256: `565d0483885e6a1b70805ef7402c77518bb9817d2fb321365f12cfe7db49da4e`
- PC SHA256: `aef2c9960974815335b83caca53c09a6bb188de6914c62ca9d91f536dd7074e0`
- Known issue: Android APK foi exportado com `debug_fallback` porque nao havia keystore release no env local.

## Validacao Executada

- PASS: `validate_foundation.ps1 -Profile Release`.
- PASS: `export_internal_alpha.ps1 -AllowAndroidDebugFallback`.
- PASS: `publish_internal_alpha.ps1 -Mode Plan`.
- PASS: `publish_internal_alpha.ps1 -Mode Package`.
- PASS: `publish_internal_alpha.ps1 -Mode Upload -PublicDownloads -ConfirmRemoteMutation`.
- PASS: `build_cloudflare_pages_package.ps1` contra o asset root versionado.
- PASS: `wrangler pages deploy`.
- PASS: `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`.
- PASS: `release_manifest_smoke.ts`.
- PASS: `release_artifacts_remote_smoke.ts`.
- PASS: `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1`.
- PASS: preview Web contem `GODOT_CONFIG`, asset root versionado e `index.pck` com tamanho remoto consistente.

## Handoff

- Registrar release root, URLs publicas, validacoes remotas, commit final e qualquer risco conhecido.
