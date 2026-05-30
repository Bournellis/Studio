# DraxosMobile - Foundation Closeout

- Data: 2026-05-30
- Agente: Codex
- Branch: `codex/draxos-mobile/foundation-expansion-readiness`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-expansion-readiness`
- Projeto: `Projetos/draxos-mobile`
- Objetivo: implementar o Foundation Closeout antes de base builder tuning, autobattler tuning, social expansion ou minigame real.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/foundation-expansion-readiness.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Ownership Inicial

- Backend/Data: migrations corretivas, ruleset registry, replay hashes, account/save bootstrap, admin RPCs.
- Backend/API: API version header, adapters v1, state context.
- Client Shell: request hash/retry, OperationState, ActionRouter.
- Client UI: SupabaseClient facade, SessionStore slices, presenters e minigame placeholder.
- Docs/QA: contratos vivos, validation runner, status/handoff.

## Arquivos Centrais

- `server/schema/migrations/`, `supabase/migrations/`
- `server/functions/_shared/`, `supabase/functions/_shared/`
- `server/functions/*`, `supabase/functions/*`
- `online/supabase_client.gd`, `online/session_store.gd`
- `modes/boot/boot.gd`, `modes/boot/surfaces/hub_surface_presenter.gd`
- `tools/validate_foundation.ps1`
- `docs/contracts/*`, `docs/documentation-index.md`
- `implementation/current-status.md`

## Validacao Planejada

- Deno checks server/supabase functions.
- Schema/contract tests para registry, API version, replay projection, admin e RLS.
- Live Supabase/Edge local quando stack local estiver disponivel.
- Godot validate, GUT client, responsive/export/foundation smokes.
- `validate_foundation.ps1 -Profile Full`.

## Handoff

Fechar quando a fundacao provar: registry imutavel, replay com hashes historicos, account/save desde bootstrap, state context explicito, API version, admin minimo auditavel, retry idempotente real no client, shell contracts integrados, docs alinhadas e Full gate verde.

## Atualizacao 2026-05-30

- Implementado: migration corretiva `202605300004_foundation_closeout.sql` espelhada, API version helper/header, ruleset publication id, hashes persistidos, admin RPCs internas, RPCs v1 restantes de build behavior/potion e social friend/chat.
- Implementado: client passa a enviar API version/request hash, `SessionStore` registra pending mutations, ActionRouter/OperationState entram no caminho real e minigame shell fica disabled/dev-only.
- Docs vivas/status alinhados para Foundation Closeout.
- Validado: Deno check server/supabase, static foundation tests, Godot validate e `validate_foundation.ps1 -Profile Quick`.
- Ajustado: checks Track 13/14 agora aceitam o card ativo de Foundation Closeout sem tratar a coordenacao atual como obsoleta.
- Aplicado localmente: `supabase migration up --local` para `202605300004_foundation_closeout.sql`.
- Validado: `validate_foundation.ps1 -Profile Full` PASS com Supabase RPC local e Edge HTTP local incluidos.
- Handoff: Foundation Closeout entregue. Proximo trabalho deve ser pacote explicito de base builder tuning, autobattler tuning, social expansion ou minigame contract, sem adicionar gameplay neste branch.
