# DraxosMobile - Publish Social Guild v1 Builds

- Data: 2026-05-29
- Agente: Codex
- Branch: `codex/draxos-mobile/publish-social-guild-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--publish-social-guild-v1`
- Base: `master` em `c9df086`
- Status: `CONCLUIDO`

## Objetivo

Subir novas builds Internal Alpha do DraxosMobile para o site, incluindo o pacote Social Basico Guilda v1 ja integrado em `master`.

## Escopo

- Rodar validacao de release/client suficiente antes da publicacao.
- Exportar Android, PC Windows e Web com `tools/export_internal_alpha.ps1`.
- Gerar plano/pacote Internal Alpha.
- Publicar artefatos aprovados com mutacao remota explicitamente autorizada pelo usuario.
- Gerar pacote Cloudflare Pages para Portal/Web.
- Atualizar status/docs com hashes, preview/site e validacoes reais.

## Restricoes

- Publicacao remota autorizada pelo usuario nesta tarefa.
- Nao alterar backend/schema/migrations.
- Nao expor secrets em docs, cliente, manifest ou logs finais.
- Nao publicar nada alem dos artefatos Internal Alpha/site.

## Docs Lidos

- `AGENTS.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `Projetos/draxos-mobile/implementation/tracks/track-13-validation-release-safety/release-safety-contract.md`
- `Projetos/draxos-mobile/implementation/tracks/track-13-validation-release-safety/validation-matrix.md`
- `Projetos/draxos-mobile/tools/README.md`

## Publicacao Realizada

- Cloudflare Pages deploy: `https://483a73f3.draxos-mobile-internal-alpha.pages.dev`.
- Manifest remoto: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`.
- Stable portal/Web: `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html` e `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`.
- Observacao: dominio estavel do Pages segue protegido por Cloudflare Access para requests anonimos; preview publico foi verificado.
- Supabase Storage: `25` arquivos enviados, com APK/ZIP em bucket protegido e site/manifest no bucket publico.
- Supabase release: override de manifest atualizado e funcao `release` redeployada.

## Artefatos

| Artifact | Bytes | SHA256 |
|---|---:|---|
| Android APK | `31625237` | `8d8a88fbbc8f887fcb434c42f508f4bdf161556b0d9b70a93a31cd64544a938a` |
| PC Windows ZIP | `40091415` | `3d0e8b04a6f338e51ce1d782a32cadeeb3889013f241d59c20bd7fe7f78c5339` |
| Web index | `5442` | `34b9ad875b8cafa2b6e510224dc45bff21745d9c0d688c5bd738e2988d11c6c4` |

Android export mode: `debug_fallback`.

## Validacao Executada

- `validate_foundation.ps1 -Profile Full`: PASS.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Plan`: PASS.
- `publish_internal_alpha.ps1 -Mode Package`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- `wrangler pages deploy`: PASS.
- Supabase CLI `2.101.0`: bloqueado por erro local de parse JSON no binario cacheado.
- Supabase CLI `2.98.0`: usado para upload Storage, secrets set e functions deploy.
- `server/tests/release_manifest_smoke.ts`: PASS remoto.
- `server/tests/release_download_smoke.ts`: PASS remoto com signed HEAD para Android/PC.
- `server/tests/internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1`: PASS remoto.
- Preview GET `/portal/index.html` e `/web/index.html`: PASS.
- `git diff --check`: PASS.

## Handoff

`master` deve ser atualizado com este registro de publicacao. Artefatos remotos renovados; proximo passo e validacao humana de duas contas no build publicado.
