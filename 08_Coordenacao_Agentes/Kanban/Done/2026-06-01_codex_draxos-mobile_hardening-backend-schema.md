# DraxosMobile - Hardening Backend Schema

- Agente: Codex
- Lane: backend-schema
- Branch: `codex/draxos-mobile/hardening-backend-schema`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--hardening-backend-schema`
- Base commit: `ceedd20`
- Data: `2026-06-01`

## Objetivo

Entregar a lane backend-schema do hardening completo DraxosMobile em freeze total, cobrindo Tracks 6, 7, 8, 9, 10, 13 e 14 sem publicacao remota.

## Escopo Pretendido

- Modularizar `/modes` mantendo `server/` e `supabase/` espelhados.
- Criar `ModeHandler` interno para roteamento compartilhado da Edge Function.
- Adicionar RPCs auditadas:
  - `admin_set_mode_status_v1`
  - `admin_expire_mode_session_v1`
  - `admin_invalidate_mode_session_v1`
- Fazer `/modes/admin/*` chamar RPC auditada em vez de `PATCH` direto.
- Criar/atualizar `docs/contracts/reward-bridge-v1.md`.
- Expandir testes RLS/admin/reward/idempotencia.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/architecture.md`
- `Projetos/draxos-mobile/docs/contracts/minigame-platform-v1.md`
- `Projetos/draxos-mobile/docs/contracts/admin-ops.md`

## Validacao Planejada

- `git diff --check`
- `npx -y deno fmt --check` ou `npx -y deno fmt` nos arquivos tocados
- `npx -y deno lint` nos arquivos/testes tocados
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- testes Deno focados em `/modes`, RLS/admin, reward bridge e idempotencia
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick`

## Proximo Handoff

Entregar commits coerentes por contrato/docs, schema/RPC, Edge modularization e testes/validacao. Se algum teste depender de Supabase local indisponivel, registrar comando, erro e risco residual.

## Resultado

- `31ad9d0` - coordination: register DraxosMobile backend hardening lane
- `bdb5557` - docs: define DraxosMobile reward bridge v1
- `c0f8d22` - backend: harden modes admin mutations
- `b5a096a` - tests: expand modes admin and reward coverage

## Validacao Executada

- `npx -y deno fmt ...`: PASS nos arquivos TypeScript tocados.
- `npx -y deno lint ...`: PASS nos arquivos TypeScript tocados.
- `npx -y deno test --allow-read server/tests/modes_platform_schema_test.ts server/tests/modes_admin_ops_test.ts server/tests/modes_disable_rollback_test.ts server/tests/modes_analytics_test.ts server/tests/openworld_reward_bridge_test.ts`: PASS, 12 tests.
- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- Migration `202606010002_modes_admin_audit_hardening.sql` executada em transacao local e revertida via rollback: PASS.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick`: PASS, 74 tests de contrato/readiness.
- `git diff --check`: PASS.
- Espelhos confirmados com `fc.exe /B` para `modes/index.ts`, `modes/mode_handler.ts` e a migration nova.

## Blockers / Risco Residual

- Sem blocker local.
- Nao houve publicacao remota nem mutation remota.
- Perfil Quick nao executa smokes locais `IncludeLocalAdminRls`, `IncludeLocalEdgeRpc` ou Full; esses continuam disponiveis para uma gate posterior se o fundador pedir.
