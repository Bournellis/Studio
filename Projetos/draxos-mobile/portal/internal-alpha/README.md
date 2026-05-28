# DraxosMobile Internal Alpha Portal

Status: `PRIVATE_ALPHA_HUB_WITH_CLOUDFLARE_ACCESS`.

Este portal e o hub privado da Internal Alpha v0. Cloudflare Access protege o site antes de carregar para os emails autorizados. Registro/login de conta ficam apenas dentro do jogo por enquanto; o fluxo Supabase do site foi preservado escondido para reativacao futura.

- download do APK Android;
- download do ZIP PC;
- link da build Web;
- Grimorio privado estatico para usuarios que passaram pelo Cloudflare Access;
- changelog;
- checklist rapido do tester;
- problemas conhecidos.

## Arquivos

- `index.html`: hub alpha estatico com abas.
- `assets/draxos-arena.svg`: arte local privada do portal.
- `assets/grimoire-catalog.json`: copia estatica do catalogo gerado por `tools/generate_grimoire_catalog.ts`.
- `manifest.example.json`: exemplo do manifest de updates usado por `GET /release/manifest`.

## Como Usar

1. Em `T03-P17`, publique os artefatos exportados e atualize os links em `index.html`.
2. Depois de publicar os artefatos, substitua os placeholders:
   - `ANDROID_APK_URL_PENDING_T03_P17`;
   - `ANDROID_APK_SHA256_PENDING_T03_P17`;
   - `PC_ZIP_URL_PENDING_T03_P17`;
   - `PC_ZIP_SHA256_PENDING_T03_P17`;
   - `PORTAL_URL_PENDING_T03_P17`.
3. Publique esta pasta em um host estatico unlisted.
4. Envie o link apenas ao tester.

O manifest real da alpha v0 e servido pela Edge Function publica:

```text
https://<project-ref>.supabase.co/functions/v1/release/manifest
```

O arquivo `manifest.example.json` e a copia documental do schema esperado para atualizar links/notas em `T03-P17`. Os hashes locais de `T03-P16` ficam registrados em `../../docs/internal-alpha-v0-export-report.md`.

Em `T03-P17`, o portal publicado foi gerado em `build/internal-alpha/publish/portal/` por `tools/publish_internal_alpha.ps1`, com os placeholders substituidos por URLs reais. O source versionado continua como template.

O upgrade de 2026-05-27 adicionou abas, assets locais e Grimorio. O script de publicacao agora copia subpastas do portal. A build Web fica visivel no hub para usuarios que passaram pelo Cloudflare Access. O fluxo de login Supabase do site esta escondido/preservado para uso futuro.

## Guardrails

- Nao colocar `service_role`, `sb_secret_...`, senha de banco ou senha de keystore no portal.
- Nao tratar URL unlisted como privada; usar Cloudflare Access no dominio publicado.
- Se downloads voltarem a exigir Supabase Auth no site, reativar o fluxo preservado em `index.html` e o endpoint `GET /release/download`.
- Nao colocar dados pessoais reais no changelog.
- Nao prometer monetizacao real; loja alpha e proof-of-concept.

## Refinamento Futuro

Fabio vai trabalhar melhor no portal depois de `T03-P18`. Ate la, esta base e suficiente para release candidate.
