# DraxosMobile - Web Cache-Bust Publish Hotfix

- Data: `2026-05-29`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/web-cache-bust-publish`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--web-cache-bust-publish`
- Base: `master` em `7979263`
- Status: `DONE`

## Objetivo

Corrigir a publicacao Web de Visual Direction v1 quando o navegador ainda carregava assets antigos por cache em caminhos estaveis como `index.pck`, `index.wasm` e `index.js`.

## Resultado

- Web assets republicados em `internal-alpha/v0-web-20260529-visual-direction-v1/web`.
- Cloudflare Pages redeployado com o Web HTML apontando para o asset root versionado.
- Novo preview verificado: `https://5477aaf9.draxos-mobile-internal-alpha.pages.dev`.
- Manifest/download endpoint estavel nao foi redeployado nesta correcao; APK/PC protegidos permanecem pelo contrato existente de `release/download`.

## Validacao Executada

- Godot `--headless --import`: PASS na worktree fresca.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS, Android mode `debug_fallback`.
- Supabase CLI `2.98.0`: confirmado.
- `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-web-20260529-visual-direction-v1 -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1 -StaticAssetBaseUrl https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-web-20260529-visual-direction-v1/web`: PASS.
- `npx -y wrangler pages deploy .\build\internal-alpha\cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: PASS.
- Preview GET `/portal/index.html`: PASS, `Draxos Alpha`.
- Preview GET `/web/index.html`: PASS, `GODOT_CONFIG` e asset root versionado.
- Remote HEAD versionado: PASS para `index.js`, `index.pck` e `index.wasm`.
- `git diff --check`: PASS.
- `check_agent_ops_foundation.ps1`: PASS.
- `validate_foundation.ps1 -Profile Quick`: PASS.

## Arquivos Atualizados

- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/internal-alpha-v0-publication-report.md`
- `Projetos/draxos-mobile/README.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Handoff

Usar `https://5477aaf9.draxos-mobile-internal-alpha.pages.dev/web/index.html` para validacao anonima imediata. No dominio estavel protegido por Cloudflare Access, fazer hard refresh ou abrir com query string nova caso o navegador tenha mantido HTML antigo em memoria.
