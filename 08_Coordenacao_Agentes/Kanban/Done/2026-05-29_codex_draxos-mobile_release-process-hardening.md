# Release Process Hardening

- Data: `2026-05-29`
- Projeto: `Projetos/draxos-mobile`
- Agente: Codex
- Branch: `codex/draxos-mobile/release-process-hardening`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--release-process-hardening`
- Base: `master` em `d5bc361`

## Objetivo

Corrigir e prevenir a classe de erro em que o Web publicado aponta para assets versionados corretos, mas o shell Cloudflare Pages e gerado a partir de `build/` local antigo.

## Entrega

- O preview final publicado e validado passou a ser `https://64d01322.draxos-mobile-internal-alpha.pages.dev`.
- `tools/build_cloudflare_pages_package.ps1` agora compara `GODOT_CONFIG.fileSizes` do shell Web com `Content-Length` remoto de `index.pck` e `index.wasm` quando `-StaticAssetBaseUrl` e HTTP/S.
- `docs/release-ops-checklist.md` agora proibe redeploy a partir de `build/` antigo e exige validar o tamanho do `index.pck` publicado contra o asset remoto.
- `implementation/current-status.md` registra que o shell stale com `index.pck = 415856` foi substituido pelo shell correto com `index.pck = 4227948`.

## Validacao

- Preview `/web`: `200`, `Cache-Control: no-store, no-store`, asset root `v0-battle-presentation-20260529/web`, `GODOT_CONFIG.fileSizes.index.pck = 4227948` e sem o tamanho stale `415856`.
- Preview `/portal/manifest.example.json`: `200`, `Cache-Control: no-store, no-store`, contendo `v0-battle-presentation-20260529`.
- `wrangler pages deployment list`: preview `64d01322` e a producao mais recente no branch `main`.
- PowerShell parser para `build_cloudflare_pages_package.ps1`: PASS.
- Guard novo contra publish stale: PASS esperado, bloqueando pacote com `publish/web/index.html` stale (`415856` vs remoto `4227948`).
- Guard novo com publish correspondente ao asset root: PASS, pacote Cloudflare gerado.
- `git diff --check`: PASS.
- `validate_foundation.ps1 -Profile Release`: PASS.

## Handoff

Proximo release Web deve sempre usar artefatos gerados no mesmo worktree/sessao da exportacao aprovada. Se o script bloquear por mismatch de `index.pck` ou `index.wasm`, nao publicar; reexportar/reempacotar primeiro.
