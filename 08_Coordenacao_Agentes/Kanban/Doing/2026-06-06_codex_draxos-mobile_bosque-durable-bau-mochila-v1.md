# DraxosMobile - Bosque Durable Bau Mochila v1

- Data: `2026-06-06`
- Agente: `codex`
- Branch: `codex/draxos-mobile/bosque-durable-bau-mochila-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-durable-bau-mochila-v1`
- Base: `main` em `ee5b7ce`

## Objetivo

Implementar persistencia duravel de Bau, Mochila/Bolso, upgrades e estruturas do Bosque por save, preservando runtime offline-first e reward server-authoritative.

## Escopo Pretendido

- Backend/contratos: migracao espelhada em `server/schema` e `supabase/migrations`, RPCs de start/checkpoint/complete com progresso duravel em `mode_progress.progress_payload`.
- Client Godot: cache local separado para sessao ativa e progresso duravel; entrada, checkpoint, conclusao e mensagens do Bosque ajustadas.
- Docs/status/coordenacao: Openworld, contratos, current-status e registros do Estudio.
- Release: merge em `main`, aplicar migration remota, publicar Web/APK e registrar evidencia.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Validacao Planejada

- Deno schema/domain tests de Openworld/Mode Platform.
- Deno checks em `server/functions` e `supabase/functions`.
- GUT focado em Openworld e `tools/validate.gd`.
- `validate_foundation.ps1` em perfis relevantes antes do release.
- Export/package/upload/deploy/manifest remoto e smoke Web/APK conforme runbook.

## Handoff

Handoff esperado apos commits logicos, merge em `main`, publicacao remota e worktree limpa.
