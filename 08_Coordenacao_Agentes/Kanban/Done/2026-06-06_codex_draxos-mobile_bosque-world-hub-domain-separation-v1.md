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
- `ReleaseDryRun`: pendente de rerun apos mover este cartao para `Done`.

## Proximo Handoff

Branch final mergeada em `main`, publicacao Web/APK concluida ou bloqueio remoto documentado com evidencias.
