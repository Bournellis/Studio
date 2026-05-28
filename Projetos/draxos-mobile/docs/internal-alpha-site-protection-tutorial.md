# DraxosMobile - Tutorial De Protecao Do Site Alpha

- Data: `2026-05-27`
- Escopo: proteger Portal/Web e downloads da Internal Alpha v0.
- Objetivo: trocar "link unlisted" por camadas reais de acesso.

## Resultado Esperado

- Portal/Web pedem Cloudflare Access antes de abrir.
- APK/PC ZIP deixam de depender de link publico direto.
- Downloads usam login Supabase da conta alpha e URL assinada temporaria.
- O jogo continua exigindo email/senha, convite/alpha gate e backend server-authoritative.

## O Que O Codex Ja Preparou

- Portal com formulario de email/senha para liberar downloads.
- Endpoint `GET /release/download?artifact=android|pc_windows`.
- Bucket privado `draxos-internal-alpha-private`.
- Script de publicacao com downloads protegidos por padrao.
- Docs/contratos atualizados.

## O Que Fabio Precisa Fazer

### 1. Autenticar Cloudflare No Terminal

No terminal:

```powershell
cd D:\Estudio-worktrees\draxos-mobile--codex--site-protection\Projetos\draxos-mobile
npx -y wrangler login
```

O navegador vai abrir. Entre na conta Cloudflare correta e autorize o Wrangler.

Depois valide:

```powershell
npx -y wrangler whoami
```

### 2. Configurar Cloudflare Access

No painel Cloudflare:

1. Abrir Zero Trust.
2. Ir em Access -> Applications.
3. Criar uma aplicacao Self-hosted.
4. Usar um dominio da alpha, idealmente um dominio proprio, por exemplo `alpha.draxos...`.
5. Apontar esse hostname para o Pages project `draxos-mobile-internal-alpha`.
6. Criar policy `Allow` para os emails dos testadores.
7. Confirmar que `/`, `/portal/index.html`, `/web` e `/web/index.html` pedem login.

Observacao: `pages.dev` unlisted nao e privado de verdade. Cloudflare Access fica mais previsivel usando dominio proprio sob uma zona Cloudflare.

### 3. Publicar Protecao Supabase + Portal

Depois que `wrangler login` estiver ok:

```powershell
cd D:\Estudio-worktrees\draxos-mobile--codex--site-protection\Projetos\draxos-mobile

npx -y supabase db push
npx -y supabase functions deploy release --project-ref armxgipvnbbshzqawklw --no-verify-jwt

powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 `
  -ProjectDir . `
  -EnvFile D:\Estudio\Projetos\draxos-mobile\.env.internal-alpha.local `
  -StaticSiteBaseUrl "https://draxos-mobile-internal-alpha.pages.dev" `
  -UseManifestSecret

powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_cloudflare_pages_package.ps1 -ProjectDir .

npx -y wrangler pages deploy .\build\internal-alpha\cloudflare-pages `
  --project-name draxos-mobile-internal-alpha `
  --branch main
```

### 4. Validar

Sem login Cloudflare:

- Portal/Web devem bloquear no Access.

Com login Cloudflare:

- Portal abre.
- Web abre.
- Botao APK/PC pede login Supabase.
- Login com conta alpha registrada libera download.
- Link retornado pelo download deve expirar em poucos minutos.

Valide manifest:

```powershell
Invoke-RestMethod -Uri "https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest" |
  ConvertTo-Json -Depth 8
```

O manifest deve mostrar:

- `artifacts.android.url` apontando para `/functions/v1/release/download?artifact=android`
- `artifacts.pc_windows.url` apontando para `/functions/v1/release/download?artifact=pc_windows`
- `auth_required: true` nos dois artefatos baixaveis

## O Que Nao E Segredo

- Supabase URL publica.
- Supabase publishable key.
- Web build e APK podem ser inspecionados por usuarios com acesso.

## O Que Nunca Deve Ir Para Cliente Ou Git

- `SUPABASE_SERVICE_ROLE_KEY`
- senha de banco
- senha de keystore Android
- `.env.internal-alpha.local`
- token Cloudflare

## Plano De Rollback

Se algo bloquear o teste:

```powershell
cd D:\Estudio-worktrees\draxos-mobile--codex--site-protection\Projetos\draxos-mobile
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 `
  -ProjectDir . `
  -EnvFile D:\Estudio\Projetos\draxos-mobile\.env.internal-alpha.local `
  -StaticSiteBaseUrl "https://draxos-mobile-internal-alpha.pages.dev" `
  -UseManifestSecret `
  -PublicDownloads
```

Esse rollback volta o manifest para links publicos unlisted de APK/PC, sem desfazer Cloudflare Access.
