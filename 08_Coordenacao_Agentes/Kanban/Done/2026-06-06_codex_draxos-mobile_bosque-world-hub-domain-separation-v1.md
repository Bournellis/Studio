# DraxosMobile - Bosque World Hub Domain Separation v1

- Data: `2026-06-06`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/bosque-world-hub-domain-separation-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-world-hub-domain-separation-v1`
- Base: `main` em `21827ed`

## Objetivo

Corrigir a separacao entre materiais locais do Bosque e recursos globais da conta, endurecer a persistencia da Fogueira como estrutura/estacao duravel e publicar novo pacote Web/APK `0.0.8-alpha.0`.

## Escopo Entregue

- Migrations espelhadas `server/schema` e `supabase/migrations`.
- Ruleset Openworld com materiais locais separados de recursos globais.
- Cliente Godot com `BosqueWorldContext`, labels por dominio, cache legado normalizado e Fogueira pendente/confirmada.
- Persistencia de `fogueira_estavel_1` em `upgrades` e `structures`.
- Versao de pacote preparada para `0.0.8-alpha.0` / version code `8`.

## Validacao

- `validate_foundation.ps1 -Profile ServerQuick`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun`: PASS.
- Remote Supabase migration `202606060004_bosque_world_hub_domain_separation_v1.sql`: aplicada.
- Export/package/upload/deploy manifest/Web/APK: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly`: PASS.
- Preview publicado: `https://d1872010.draxos-mobile-internal-alpha.pages.dev`.
- Release root: `internal-alpha/v0-bosque-world-hub-domain-separation-v1-20260606-81ecf05`.

## Proximo Handoff

Branch final mergeada em `main`, Web/APK publicados, manifest remoto atualizado para `0.0.8-alpha.0`/version code `8` e smokes remotos read-only verdes. Proximo trabalho deve partir de `main` limpo.
