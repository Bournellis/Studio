# DraxosMobile - Internal Alpha Static Hosting

- Data: `2026-05-27`
- Status: `REQUIRED_FOR_PORTAL_WEB_SIGNOFF`
- Escopo: Portal e Web build da Internal Alpha v0.

## Decisao

Supabase continua sendo o backend da alpha e o host dos downloads binarios APK/ZIP. Portal e Web build nao devem ser hospedados no Supabase, porque:

- Supabase Storage retorna arquivos HTML como texto puro por seguranca.
- Supabase Edge Functions reescrevem respostas `text/html` para `text/plain`.
- O resultado no navegador e o codigo do portal aparecendo na tela, exatamente como observado no teste manual.

Portanto, a Internal Alpha precisa de um host estatico externo para `build/internal-alpha/publish/`.

## Recomendacao

Usar Cloudflare Pages para a Internal Alpha v0.

Motivos:

- plano gratuito suficiente para dois testadores;
- deploy simples de pasta estatica;
- URL unlisted funciona para alpha fechada;
- permite trocar o conteudo rapidamente sem mexer no backend;
- combina bem com o plano futuro de separar backend de hosting.

Alternativas aceitaveis:

- Netlify Drop/Sites;
- Vercel static deploy;
- GitHub Pages, se o projeto ganhar remoto privado/publico adequado.

## Pasta A Publicar

Depois de exportar e publicar os artefatos:

```powershell
D:\Estudio\Projetos\draxos-mobile\build\internal-alpha\publish\
```

Estrutura esperada:

```text
publish/
  portal/
    index.html
    manifest.example.json
    README.md
  web/
    index.html
    index.js
    index.wasm
    index.pck
    index.png
    ...
  downloads/
    draxos-mobile-alpha.apk
    draxos-mobile-alpha.zip
```

APK/ZIP podem continuar apontando para Supabase Storage; a pasta `downloads/` existe como copia conveniente, nao como fonte obrigatoria.

## Passo Manual Fabio

1. Criar um projeto em Cloudflare Pages.
2. Escolher deploy por upload direto da pasta estatica.
3. Enviar a pasta `build/internal-alpha/publish/`.
4. Copiar a URL final, por exemplo:

```text
https://draxos-mobile-internal-alpha.pages.dev
```

5. Enviar essa URL ao Codex.

## Passo Codex Depois Da URL

Com a URL final em maos:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -StaticSiteBaseUrl "https://draxos-mobile-internal-alpha.pages.dev" -SkipUpload -UseManifestSecret
```

Esse comando:

- atualiza o manifest remoto com `portal/index.html` e `web/index.html`;
- preserva os links APK/PC ZIP no Supabase Storage;
- valida a URL do portal e da Web;
- redeploya `release/manifest`.

## URL Final Esperada

Se a base for:

```text
https://draxos-mobile-internal-alpha.pages.dev
```

Os links finais serao:

```text
Portal: https://draxos-mobile-internal-alpha.pages.dev/portal/index.html
Web:    https://draxos-mobile-internal-alpha.pages.dev/web/index.html
```

## Segurança

- O portal e unlisted, nao privado de verdade.
- O jogo continua exigindo email/senha e acesso alpha.
- Nunca publicar service role, senha de banco, senha de keystore ou `.env.internal-alpha.local`.
- Publishable key pode estar no cliente/export, mas RLS e Edge Functions continuam sendo a barreira real.
