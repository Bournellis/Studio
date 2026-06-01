# DraxosMobile V2 Login CORS Hotfix

- data: `2026-06-01`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/v2-login-cors-hotfix`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--v2-login-cors-hotfix`

## Objetivo

Corrigir `http_error: request failed` / Supabase indisponivel ao entrar na V2
publicada, investigando CORS dos previews Cloudflare, cache de Web export e a
publishable key embutida nos artefatos Internal Alpha.

## Escopo

- Ajustar allowlist/default CORS dos helpers espelhados.
- Trocar a publishable key publica antiga pela publishable key registrada no
  projeto Supabase remoto.
- Reexportar Android/PC/Web em modo release e republicar em release root cache-bust
  `internal-alpha/v0-foundation-hardening-v2-hotfix1-20260601-f8ff795`.
- Publicar novo Cloudflare Pages preview
  `https://4315dd54.draxos-mobile-internal-alpha.pages.dev`.
- Promover o manifest remoto para o novo preview.
- Validar Deno/function checks.
- Redeployar Edge Functions necessarias para a alpha publicada.
- Nao alterar gameplay, schema ou dados.

## Validacao Planejada

- Prova remota de headers CORS antes/depois.
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- Deploy das Edge Functions com helper CORS atualizado.
- Smoke remoto de manifest/account com Origin do preview V2.

## Resultado

- Causa 1 confirmada: respostas reais das Edge Functions usavam o origin default
  antigo, bloqueando o preview publicado no navegador.
- Causa 2 confirmada: a publishable key publica embutida no export nao
  correspondia a nenhuma chave publica registrada no projeto Supabase; Auth
  retornava `401`. A chave publica registrada valida `auth/v1/signup` com `200`.
- Edge Functions redeployadas com CORS para
  `https://4315dd54.draxos-mobile-internal-alpha.pages.dev`.
- Android/PC/Web reexportados com Android `release`, sem debug fallback.
- Storage, Cloudflare Pages e manifest remoto republicados.
- Preview atual:
  `https://4315dd54.draxos-mobile-internal-alpha.pages.dev`.
- Portal:
  `https://4315dd54.draxos-mobile-internal-alpha.pages.dev/portal/index.html`.
- Web:
  `https://4315dd54.draxos-mobile-internal-alpha.pages.dev/web/index.html`.

## Validacao Executada

- `git diff --check`: PASS.
- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- `tools/export_internal_alpha.ps1 -ProjectDir .`: PASS, Android `release`.
- `tools/publish_internal_alpha.ps1 -Mode Upload -PublicDownloads
  -ConfirmRemoteMutation`: PASS.
- `tools/build_cloudflare_pages_package.ps1`: PASS.
- `wrangler pages deploy`: PASS, preview `4315dd54`.
- Browser CDP clean-profile Web click on `Guest`: PASS, reached `Refugio` with
  200 responses for runtime config, manifest, Auth signup, `account/guest`,
  `account/state`, `base/state` and telemetry.
- `tools/publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads
  -ConfirmRemoteMutation`: PASS.
- `server/tests/internal_alpha_remote_smoke.ts` com
  `DRAXOS_REMOTE_ANON_AUTH_SMOKE=1` e `DRAXOS_REMOTE_ACCOUNT_SMOKE=1`: PASS.
- `tools/validate_foundation.ps1 -Profile DocsOnly`: PASS.
- `tools/validate_foundation.ps1 -Profile RemoteReadOnly`: PASS.
