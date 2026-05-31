# Multi-Agent Doing: DraxosMobile Arena Backend

## Metadata

- data: `2026-05-31`
- agente: `Codex worker`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/arena-backend`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-backend`

## Objetivo

Implementar estado server-authoritative da Arena PVE e endpoints `arena/*` sem tocar ranking/PVP.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/docs/contracts/`

## Escopo

- Incluir: migrations/RPCs, Edge Functions `arena/*`, espelhos `server/` e `supabase/`, testes de idempotencia e PVE sem ranking.
- Fora do escopo: UI Godot, tuning visual e labs.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/server/schema/`
- `Projetos/draxos-mobile/server/functions/`
- `Projetos/draxos-mobile/supabase/migrations/`
- `Projetos/draxos-mobile/supabase/functions/`
- `Projetos/draxos-mobile/server/tests/`

## Plano De Commit

- `db: add pve arena transactional state`
- `backend: add pve arena edge functions`
- `test: cover pve arena mutations`

## Validacao

- `git diff --check`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`

## Proximo Handoff

Entregar endpoints estaveis para o cliente e logs/rewards para a validacao integrada.
