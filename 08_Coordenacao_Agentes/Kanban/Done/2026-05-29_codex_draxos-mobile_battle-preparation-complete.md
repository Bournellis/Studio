# DraxosMobile - Battle Preparation Complete v1

- Data: 2026-05-29
- Agente coordenador: Codex
- Status: DONE - implementado, mergeado em `master` e publicado na Internal Alpha
- Branch integracao: `codex/draxos-mobile/battle-preparation-complete-integration`
- Worktree integracao: `D:\Estudio-worktrees\draxos-mobile--codex--battle-preparation-complete-integration`
- Merge final: `master` em 2026-05-29

## Entrega

Preparacao de Batalha Completa v1 transforma o hotspot `Preparacao` do Refugio em editor real de loadout antes da batalha.

Entregue:

- `POST /build/equip` no servidor e mirror Supabase.
- `GET /build/state` enriquecido com opcoes humanizadas, equipado/disponivel/bloqueado e motivos publicos.
- Validacoes server-side de catalogo, unlock por nivel, slots 1/2/3, doutrina, familiar, duplicidade de habilidade e recalculo de `players.power`.
- Cliente com `equip_build(...)`, actions de instrumento/habilidades/doutrina/familiar, cache/session update e mensagens publicas.
- Painel de Preparacao completo no Refugio: resumo `Pronto para batalha`, Instrumento, Habilidades, Doutrina, Familiar e Pocao.
- Export presets ajustados para excluir `assets/referenciaimagens/**`, que e moodboard e nao runtime.
- Docs/status/contratos atualizados.

## Validacao

- `npx -y deno check server/functions/build/index.ts supabase/functions/build/index.ts server/tests/build_equip_smoke.ts`: PASS.
- `npx -y deno test --allow-read server/tests/foundation_contracts_test.ts`: PASS.
- `tools/validate.gd`: PASS, 121 testes client.
- `tools/smoke_foundation_loop.gd`: PASS.
- `tools/smoke_responsive_layout.gd`: PASS.
- `validate_foundation.ps1 -Profile Client`: PASS.
- `supabase functions deploy build`: PASS remoto.
- `server/tests/build_equip_smoke.ts`: PASS remoto contra Supabase Internal Alpha.
- `tools/smoke_foundation_surfaces.gd`: BLOQUEADO localmente sem Supabase local em `127.0.0.1:54321`.
- `git diff --check`: PASS.

## Publicacao

- Release root: `internal-alpha/v0-battle-preparation-complete-v1-20260529`.
- Supabase Storage upload: PASS para Web assets, APK e PC ZIP.
- Cloudflare Pages deploy: PASS.
- Preview publico verificado: `https://17ea0fa1.draxos-mobile-internal-alpha.pages.dev/web`.
- Stable Pages: `https://draxos-mobile-internal-alpha.pages.dev` permanece atras de Cloudflare Access em checagem anonima.
- Remote HEAD: PASS para `index.pck`, `index.wasm`, APK e ZIP.
- `publish_internal_alpha.ps1 -Mode DeployManifest`: BLOQUEADO por falta de `SUPABASE_ACCESS_TOKEN`; portal publicado usa `manifest.example.json` embutido com links/hashes corretos.

## Observacao De Release

O erro `Payload too large` no upload foi resolvido removendo moodboard dos exports (`assets/referenciaimagens/**`) e ajustando o limite remoto dos buckets Internal Alpha para `209715200` bytes. Os artefatos finais ficaram abaixo do limite pratico atual: APK `31649813`, PC ZIP `40118021`, Web PCK `4247020`.

