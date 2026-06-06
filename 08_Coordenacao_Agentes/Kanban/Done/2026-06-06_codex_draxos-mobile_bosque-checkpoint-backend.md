# DraxosMobile - Bosque Checkpoint Backend

- Data: `2026-06-06`
- Agente: `Codex Backend/Contracts`
- Branch: `codex/draxos-mobile/bosque-checkpoint-backend`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--backend--bosque-checkpoint-v1`
- Status: `DONE`

## Objetivo

Implementar autoridade backend/contracts para Bosque Offline-First Checkpoint v1, migrando gameplay normal para checkpoints compactos client-owned e recompensas/conclusao server-owned.

## Escopo Entregue

- Contrato Openworld atualizado para checkpoint validation.
- Migration espelhada `202606060001_openworld_bosque_checkpoint_v1.sql` em `server/schema/migrations/` e `supabase/migrations/`.
- RPC SQL `mode_session_checkpoint_v1` e validadores auxiliares para checkpoint idempotente, ruleset correto, sessao ativa, nodes validos/unicos, capacidade e craft derivavel.
- Complete do Bosque protegido por checkpoint aceito antes de reward.
- Edge Function `modes` com rota `/modes/session/checkpoint`.
- Dominio TS, contratos e testes remotos atualizados para `0.0.4-alpha.0` / version code `4`.

## Resultado

- Trabalho integrado em `main`.
- Publicacao final registrada em `internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22`.
- Preview final: `https://fa84e109.draxos-mobile-internal-alpha.pages.dev`.
- Branch/worktree sem commits pendentes em relacao a `main`.

## Validacao

- `deno test --allow-read server/tests/modes_platform_schema_test.ts server/tests/modes_domain_test.ts server/tests/openworld_ruleset_definition_test.ts`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- `supabase db push --linked --yes`: PASS.
- `supabase functions deploy modes`: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22 -RemoteWebUrl https://fa84e109.draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS.
