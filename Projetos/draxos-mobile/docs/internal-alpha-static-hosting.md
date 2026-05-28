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

## Cloudflare Pages E Web Build Godot

Nao publique a pasta `build/internal-alpha/publish/` inteira no Cloudflare Pages.

Motivo: o export Web do Godot gera `web/index.wasm` com cerca de 36 MB nesta alpha, enquanto Cloudflare Pages aceita no maximo 25 MiB por arquivo de asset. A solucao da Internal Alpha v0 e hibrida:

- Cloudflare Pages serve apenas o portal e os arquivos HTML pequenos.
- Supabase Storage continua servindo os assets grandes ja publicados do Web export (`index.wasm`, `index.js`, `index.pck`, imagens/worklets).
- O HTML publicado no Cloudflare aponta para os assets grandes no Supabase.
- APK e PC ZIP continuam baixando pelo Supabase Storage.

Essa estrategia mantem o portal abrindo como pagina real e evita bloquear a Web build no limite de tamanho do Cloudflare.

## Fonte Dos Artefatos

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

## Pacote A Publicar No Cloudflare

Checklist release-ready e validacao somente leitura: `release-ops-checklist.md`.

Gerar o pacote especifico para Cloudflare Pages:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_cloudflare_pages_package.ps1 -ProjectDir .
```

Saidas esperadas:

```text
build/internal-alpha/cloudflare-pages/
build/internal-alpha/draxos-mobile-cloudflare-pages.zip
```

Publicar no Cloudflare Pages a pasta `build/internal-alpha/cloudflare-pages/` ou o zip `build/internal-alpha/draxos-mobile-cloudflare-pages.zip`.

O pacote tambem inclui `index.html`, `web.html` e `_redirects` na raiz. Isso deixa o deploy mais tolerante ao upload direto do Cloudflare: mesmo que a interface nao preserve bem as pastas no primeiro envio, `/portal/index.html` redireciona para `/` e `/web/index.html` redireciona para `/web`, onde o Pages serve `web.html` via clean URL.

## Passo Manual Fabio

1. Na tela Workers/Pages, clicar em `Looking to deploy Pages? Get started`.
2. Escolher deploy por upload direto/drag and drop de arquivos estaticos.
3. Usar o nome de projeto sugerido `draxos-mobile-internal-alpha`.
4. Enviar `build/internal-alpha/cloudflare-pages/` ou `build/internal-alpha/draxos-mobile-cloudflare-pages.zip`.
5. Clicar em deploy/save and deploy.
6. Conferir no deploy:

```text
/ deve mostrar o portal completo.
/web deve conter/carregar a Web build do Godot.
/portal/index.html deve redirecionar para /.
/web/index.html deve redirecionar para /web.
```

7. Copiar a URL final, por exemplo:

```text
https://draxos-mobile-internal-alpha.pages.dev
```

8. Enviar essa URL ao Codex.

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

## Hardening Do Site

- O portal `pages.dev` e unlisted, nao privado de verdade.
- Para fechar o acesso do Portal/Web, proteger o dominio publicado com Cloudflare Access e allowlist de emails dos testadores.
- Estado atual do portal: downloads APK/PC usam links diretos do pacote publicado para usuarios que passaram pelo Cloudflare Access. O fluxo protegido por Supabase Auth (`GET /release/download?artifact=android|pc_windows`) permanece implementado e preservado para reativacao futura.
- Assets grandes do Web export (`index.wasm`, `index.js`, `index.pck`) continuam no bucket publico por causa do limite por arquivo do Cloudflare Pages. Eles nao devem conter secrets; o backend continua exigindo Auth/RLS/Edge Functions para qualquer progresso real.

## Cloudflare Access

Para tornar o site privado de verdade:

1. Usar dominio proprio para a alpha, por exemplo `alpha.draxos...`.
2. No Cloudflare Zero Trust, criar uma aplicacao Self-hosted apontando para esse hostname.
3. Criar policy `Allow` com os emails dos testadores.
4. Confirmar que `/`, `/portal/index.html`, `/web` e `/web/index.html` pedem login Cloudflare antes de abrir.
5. Manter o jogo exigindo Supabase Auth mesmo atras do Access.

Observacao: proteger apenas `pages.dev` depende das opcoes atuais da conta/projeto no Cloudflare. O caminho mais previsivel e usar um dominio proprio sob a zona Cloudflare.
