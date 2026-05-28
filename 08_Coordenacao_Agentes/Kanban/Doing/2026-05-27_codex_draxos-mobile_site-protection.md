# DraxosMobile - Site Protection

- Data: `2026-05-27`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/site-protection`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--site-protection`
- Projeto: `Projetos/draxos-mobile/`
- Objetivo: preparar e aplicar, quando houver credencial local, protecao do Portal/Web/downloads da Internal Alpha v0.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/portal/internal-alpha/`
- `Projetos/draxos-mobile/tools/`
- `Projetos/draxos-mobile/docs/`
- `Projetos/draxos-mobile/supabase/`
- `Projetos/draxos-mobile/server/`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/internal-alpha-static-hosting.md`
- `Projetos/draxos-mobile/docs/internal-alpha-remote-setup.md`

## Plano De Validacao

- Checar HTML/manifest gerado sem placeholders.
- Validar scripts adicionados em modo dry-run quando aplicavel.
- Rodar checks Deno das funcoes alteradas se houver mudanca server-side.
- Registrar qualquer passo remoto bloqueado por credenciais ausentes.

## Handoff

- Entregar protecoes versionadas e comandos exatos para ativacao remota.
- Se a Cloudflare/Supabase remota exigir token/painel ausente, deixar lacuna objetiva e proximo passo operacional.

## Resultado Parcial

- Portal preparado com login Supabase para downloads protegidos.
- `release/download` preparado para validar conta alpha registrada e emitir URL assinada temporaria.
- Migration adicionada para bucket privado `draxos-internal-alpha-private`.
- `publish_internal_alpha.ps1` atualizado para publicar APK/ZIP no bucket privado por padrao e gerar manifest com `auth_required`.
- Cloudflare Access nao foi aplicado porque `wrangler` nao esta autenticado nesta maquina.
- Supabase remoto recebeu a parte segura: migration do bucket privado, redeploy de `release` e upload de APK/ZIP no bucket privado.
- Manifest remoto foi virado para downloads protegidos apos `wrangler login`.
- Cloudflare Pages foi redeployado com portal de login em `https://b0c1da39.draxos-mobile-internal-alpha.pages.dev` e dominio estavel.
- Cloudflare Access ainda depende de configuracao no painel/dominio para bloquear a abertura publica do Portal/Web.

## Validacao Executada

- `deno check` em `supabase/functions/release/index.ts` e `server/functions/release/index.ts`: passou.
- `deno task check` e `deno task lint` em `supabase/functions`: passaram.
- `deno task check` e `deno task lint` em `server/functions`: passaram.
- Parser PowerShell de `publish_internal_alpha.ps1` e `build_cloudflare_pages_package.ps1`: passou.
- `publish_internal_alpha.ps1 -SkipUpload -SkipDeploy`: passou usando artefatos locais copiados.
- `supabase db push`: passou aplicando `202605270003_internal_alpha_private_downloads.sql` no remoto.
- `supabase functions deploy release --project-ref armxgipvnbbshzqawklw --no-verify-jwt`: passou.
- `publish_internal_alpha.ps1 -SkipDeploy -SkipManifestSecret`: passou e publicou APK/ZIP no bucket privado.
- `supabase storage ls ...draxos-internal-alpha-private/internal-alpha/v0/downloads/`: encontrou APK e PC ZIP.
- HEAD no URL publico do bucket privado: retornou `400`, confirmando que nao abre como objeto publico.
- `/release/download?artifact=android` sem JWT: retornou `401 UNAUTHENTICATED`.
- Manifest remoto: `android` e `pc_windows` apontam para `/functions/v1/release/download` com `auth_required=true`.
- `wrangler pages deploy .\build\internal-alpha\cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: passou, deploy `https://b0c1da39.draxos-mobile-internal-alpha.pages.dev`.
- Portal estavel: contem `downloadAuthForm`, link protegido e nao contem URL publica do APK.
- Web estavel: `200 text/html` com `GODOT_CONFIG`.
- `release_manifest_smoke.ts` remoto: passou.
- `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1`: passou.
- `build_cloudflare_pages_package.ps1`: passou e gerou pacote Cloudflare local.
- `git diff --check`: passou.
