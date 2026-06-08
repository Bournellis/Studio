# Handoff: DraxosMobile Bosque Persistence Rebase v1

- Data: `2026-06-08`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/bosque-persistence-rebase-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-persistence-rebase-v1`
- Projeto: `Projetos/draxos-mobile`
- Status: implementacao e validacoes locais principais concluidas; release/publish ainda em execucao neste mesmo turno.

## Entregue Ate Aqui

- Backend Openworld aceita `operations` em `/modes/session/checkpoint` e canoniza progresso em `openworld_forest_progress_v2`.
- Migração espelhada `202606080001_openworld_bosque_persistence_rebase_v1.sql` adiciona `node_state`, `applied_ops`, cooldown por item, operacoes idempotentes e compatibilidade v1 -> v2.
- Client Bosque usa fila `openworld_pending_ops_cache`, estados ACK/retry e bloqueio honesto de saida com operacao duravel pendente.
- Nodes do Bosque usam `next_spawn_at` por item em vez de full reset por visita.
- Versionamento local atualizado para `0.0.10-alpha.0` / version code `10`.
- Docs de Openworld e decision pack documentam ACK + retry, cooldown por item e abandono do full-spawn-reset como modelo principal.

## Validacoes Ja Verdes

- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `npx -y deno test --allow-read server/tests/modes_domain_test.ts server/tests/modes_platform_schema_test.ts server/tests/openworld_ruleset_definition_test.ts server/tests/ops_readonly_cli_test.ts`
- GUT client completo: 242 testes / 3794 asserts.
- `validate_foundation.ps1 -Profile ClientQuick`
- `validate_foundation.ps1 -Profile ServerQuick`

## Proximos Passos

- Repetir `validate_foundation.ps1 -Profile ReleaseDryRun` apos esta handoff/Done limpar a Doing ativa.
- Rodar gates finais (`check_release_safety`, keystore, expansion readiness, `git diff --check`).
- Commitar em etapas logicas, rebase/merge em `main`, publicar Web/APK e registrar release root/preview/APK/PC ZIP/smokes.
