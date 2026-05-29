# DraxosMobile - Visual Direction v1 Publish

- Data: `2026-05-29`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/visual-direction-v1-publish`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--visual-direction-v1-publish`
- Projeto: `Projetos/draxos-mobile/`
- Status: `DONE`

## Objetivo

Exportar artefatos frescos Android/Windows/Web de DraxosMobile com Visual Direction v1 e publicar no canal Internal Alpha site/artifacts, conforme autorizacao explicita do usuario.

## Contexto Lido

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `Projetos/draxos-mobile/docs/internal-alpha-static-hosting.md`
- `Projetos/draxos-mobile/tools/export_internal_alpha.ps1`
- `Projetos/draxos-mobile/tools/publish_internal_alpha.ps1`
- `Projetos/draxos-mobile/tools/build_cloudflare_pages_package.ps1`

## Arquivos Previstos

- `Projetos/draxos-mobile/build/**` como artefato local nao versionado.
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- Este card, movido para `Kanban/Done/` ao final.

## Plano De Validacao E Publicacao

- `validate_foundation.ps1 -Profile Client`
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`
- `publish_internal_alpha.ps1 -Mode Plan`
- `publish_internal_alpha.ps1 -Mode Package`
- `build_cloudflare_pages_package.ps1`
- Cloudflare Pages deploy do pacote hibrido.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`
- Smokes remotos: manifest, downloads assinados, health/release e checks de Portal/Web.
- `git diff --check`

## Handoff

Publicacao remota validada e status/documentos atualizados para `VISUAL_DIRECTION_V1_PUBLISHED`.

## Resultado

- `validate_foundation.ps1 -Profile Client`: PASS apos import inicial da worktree.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS, Android mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan`: PASS.
- `publish_internal_alpha.ps1 -Mode Package`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- Cloudflare Pages deploy: PASS, preview `https://6a6ae522.draxos-mobile-internal-alpha.pages.dev`.
- Supabase Storage upload: PASS com downloads protegidos.
- Supabase release manifest override + function deploy: PASS.
- `release_manifest_smoke.ts`: PASS.
- `release_download_smoke.ts`: PASS com signed HEAD Android/PC.
- `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS.
- Preview GET `/portal/index.html` e `/web/index.html`: PASS.
- `check_agent_ops_foundation.ps1`: PASS apos atualizacao de status.
- `validate_foundation.ps1 -Profile Quick`: PASS apos atualizacao de status.
- `git diff --check`: PASS.

## Artefatos

- Android APK: `31629333` bytes, SHA256 `2a6bff4f927dbb835c667347fa9f3b54d0c947f95b3454c65b8a561d57678200`.
- PC Windows ZIP: `40096068` bytes, SHA256 `a29f7341c676866fda421d3ee9cf13cdf26a216644b0ce98ba3614964e9b8875`.
- Web index: `5442` bytes, SHA256 `ac43ff4352f206822b54f199ff6eddabe0b72a6d4d1b41622e4f6e70148be40c`.

## Proximo Passo

Revisar Visual Direction v1 publicado em Android/Windows/Web e decidir Battle Presentation v1 ou outro pacote explicito.
