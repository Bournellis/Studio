# Web Cache Bust Battle Presentation v1

- Data: `2026-05-29`
- Projeto: `Projetos/draxos-mobile`
- Agente: Codex
- Branch: `codex/draxos-mobile/web-cache-bust-battle-presentation-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--web-cache-bust-battle-presentation-v1`
- Base: `master` em `175ce61`

## Objetivo

Corrigir a percepcao de Web app sem mudancas apos a publicacao de Battle Presentation v1, adicionando headers anti-cache no pacote Cloudflare Pages e republicando o Web/site.

## Entrega

- `tools/build_cloudflare_pages_package.ps1` agora gera `_headers` no pacote Cloudflare Pages.
- O pacote publicado inclui `Cache-Control: no-store` para o site interno, portal e web app.
- Cloudflare Pages foi republicado em producao.
- Preview publicado: `https://e80987bc.draxos-mobile-internal-alpha.pages.dev`

## Validacao

- `export_internal_alpha.ps1`: OK, Android em `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Package`: OK.
- `build_cloudflare_pages_package.ps1`: OK, pacote com 18 arquivos incluindo `_headers`.
- `wrangler pages deploy`: OK.
- Preview `/web`: `200`, `Cache-Control: no-store, no-store`, contendo `v0-battle-presentation-20260529/web`.
- Preview `/portal/manifest.example.json`: `200`, `Cache-Control: no-store, no-store`, contendo `v0-battle-presentation-20260529`.
- Stable anonimo ainda redireciona para Cloudflare Access, como esperado.

## Fora De Escopo Mantido

- Sem backend, schema, migration, simulador, economia ou mudanca de batalha.
- Sem novo contrato de API.
