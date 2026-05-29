# Preparacao de Batalha v1

- Data: `2026-05-29`
- Projeto: `Projetos/draxos-mobile`
- Agente coordenador: Codex
- Branch integracao: `codex/draxos-mobile/battle-preparation-v1-integration`
- Worktree integracao: `D:\Estudio-worktrees\draxos-mobile--codex--battle-preparation-v1-integration`
- Branch UX: `codex/draxos-mobile/battle-preparation-v1-ux`
- Worktree UX: `D:\Estudio-worktrees\draxos-mobile--codex--battle-preparation-v1-ux`
- Branch comportamento: `codex/draxos-mobile/battle-preparation-v1-behavior`
- Worktree comportamento: `D:\Estudio-worktrees\draxos-mobile--codex--battle-preparation-v1-behavior`
- Base: `master` em `84ff844`
- Status: `DONE`

## Resultado

Preparacao de Batalha v1 foi implementado como pacote client-first sobre o comportamento existente do Track 16, sem backend, endpoint, schema, migration, simulador, tuning, armas, spells ou economia novos.

Entregue:

- Painel `Preparacao` no Refugio com resumo `Pronto para batalha`.
- Instrumento ritual, nivel/poder quando disponivel, pocao, estoque, comportamento, spells, familiar e doutrina com copy de jogador.
- Acoes existentes de equipar/remover pocao, usar/pausar pocao e usar/pausar spell preservadas.
- Mensagens publicas para sucesso/erro de preparacao.
- Testes client novos para estado equipado, vazio e pausado.
- Nota `Projetos/draxos-mobile/docs/battle-preparation-v1.md`.
- Publicacao Internal Alpha em `internal-alpha/v0-battle-preparation-v1-20260529`.

## Validacao

- GUT `tests/client`: PASS (`121/121`, `1926` asserts).
- `tools/smoke_foundation_loop.gd`: PASS.
- `tools/smoke_responsive_layout.gd`: PASS.
- `tools/validate.gd`: PASS.
- `validate_foundation.ps1 -Profile Client`: PASS.
- `git diff --check`: PASS.
- `tools/smoke_foundation_surfaces.gd`: BLOCKED em auth anonimo com `NETWORK_UNAVAILABLE`; depende de backend local/remoto disponivel.
- Export Internal Alpha: PASS; Android `debug_fallback`.
- Storage upload: PASS para 25 arquivos com Supabase CLI `2.98.0`.
- Cloudflare Pages: PASS, preview `https://e2a7393d.draxos-mobile-internal-alpha.pages.dev`.
- Manifest override remoto: BLOCKED antes de mutacao de secret porque `SUPABASE_ACCESS_TOKEN` nao estava disponivel.
- HTTP checks: PASS para Web preview, portal, `index.js`, `index.pck`, `index.wasm`, APK e ZIP.

## Publicacao

- Release root: `internal-alpha/v0-battle-preparation-v1-20260529`
- Preview: `https://e2a7393d.draxos-mobile-internal-alpha.pages.dev`
- Web asset root: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-preparation-v1-20260529/web`
- APK: `31637525` bytes, SHA256 `6160dd7cb6d8e7c9bf935e955dc2420b0eb7e253cb11e09fea02b7fa7b4e2d07`
- PC ZIP: `40104099` bytes, SHA256 `97e24d82c758a9889ffa6f5f96e0e88d0158c6eaa8ac1a6d1d74859c8fa42809`
- Web `index.pck`: `4230572` bytes, confere com `GODOT_CONFIG.fileSizes.index.pck`.

## Handoff

Revisar o pacote publicado em Android/Windows/Web. Proximo pacote deve ser escolhido depois de confirmar se a preparacao deixou claro o que o jogador leva para a batalha.
