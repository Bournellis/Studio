# DraxosMobile - Publish Foundation Loop Build

- status: `Done`
- projeto: `draxos-mobile`
- agente: `Codex`
- branch: `codex/draxos-mobile/foundation-loop-ux-pass`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-app-v0-audit`
- base: `69c5426`
- data: `2026-05-28`

## Objetivo

Publicar o build atual do Foundation Loop UX Pass 01 para Internal Alpha: Web/site em Cloudflare Pages, artefatos Android/Windows/Web no Supabase Storage e manifest remoto alinhado.

## Resultado

- Export Internal Alpha gerado a partir do commit `69c5426`.
- Android APK publicado como `debug_fallback`.
- Supabase Storage atualizado com Web assets, APK e Windows ZIP.
- `release/manifest` atualizado e Edge Function `release` redeployada.
- Cloudflare Pages publicado inicialmente em `https://7cd67833.draxos-mobile-internal-alpha.pages.dev` e corrigido para downloads publicos em `https://ab1f2977.draxos-mobile-internal-alpha.pages.dev`.
- Dominio estavel permanece `https://draxos-mobile-internal-alpha.pages.dev`, protegido por Cloudflare Access.
- Manifest remoto aponta para downloads publicos nao indexados no Supabase Storage para permitir download direto no celular.

## Artefatos

| Artifact | Bytes | SHA256 |
|---|---:|---|
| Android APK | `31563411` | `8b5bb55f078a6bed24d53c9940e93ad118b13bee7b77bfbfb33d89a769742195` |
| PC Windows ZIP | `40030744` | `ec64c7234acea0bd0c2b02588ea23c451439c9e1349fb8027d7162196efed49d` |
| Web index | `5442` | `b263ceee49953df9ac67b5f784dcfc0e1b1df9b3457be92b603bfde386e22af1` |

## Validacao

- `git diff --check`: OK.
- `smoke_exports.gd`: OK.
- `check_release_safety.ps1`: OK.
- `npx -y deno task --cwd server/functions check`: OK.
- `npx -y deno task --cwd supabase/functions check`: OK.
- Deno check dos smokes de release: OK.
- `export_internal_alpha.ps1`: OK.
- `publish_internal_alpha.ps1 -Mode Package`: OK.
- `build_cloudflare_pages_package.ps1`: OK.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`: OK.
- `wrangler pages deploy`: OK, preview `https://7cd67833.draxos-mobile-internal-alpha.pages.dev`.
- Hotfix downloads publicos: `publish_internal_alpha.ps1 -Mode Upload -PublicDownloads`: OK.
- Hotfix Cloudflare Pages: OK, preview `https://ab1f2977.draxos-mobile-internal-alpha.pages.dev`.
- Hotfix manifest publico: `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads`: OK.
- HEAD direto do APK publico: OK, `200`, `application/vnd.android.package-archive`, `31563411` bytes.
- HEAD direto do ZIP publico: OK, `200`, `application/zip`, `40030744` bytes.
- `release_artifacts_remote_smoke.ts` apos hotfix: OK; Portal/Web reconhecidos como protegidos por Cloudflare Access.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`: OK.
- `release_manifest_smoke.ts`: OK.
- `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1`: OK.
- `release_download_smoke.ts` com `DRAXOS_RELEASE_DOWNLOAD_SMOKE_HEAD=1`: OK.
- Preview Cloudflare: `/portal/index.html` retornou `200` com `Draxos Alpha`; `/web/index.html` retornou `200` com `GODOT_CONFIG`.
- Dominio estavel: `/portal/index.html` e `/web/index.html` retornam `200` com Cloudflare Access, como esperado para validacao anonima.
- `check_agent_ops_foundation.ps1`: OK.
- `check_track13_readiness.ps1`: falhou apenas no drift SQL preexistente dos mirrors `server/schema/migrations` e `supabase/migrations` para `202605270003_internal_alpha_private_downloads.sql`; nao corrigido porque schema/backend esta fora deste pacote.

Observacao: o primeiro publish usou downloads protegidos e gerou `401` no celular sem Bearer token. O hotfix mudou APK/ZIP para URLs publicas nao indexadas no Storage, mantendo o site estavel atras de Cloudflare Access.

## Proximo Passo

Revisar manualmente o build publicado do Foundation Loop UX Pass 01 em Android/Windows/Web; aceitar ou ajustar o loop antes de decidir Social Basico.
