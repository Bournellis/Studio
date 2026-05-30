# Done: DraxosMobile Live RPC Idempotency Proof

## Metadata

- data: `2026-05-30`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/foundation-expansion-readiness`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-expansion-readiness`

## Objetivo

Provar rollback/retry/idempotencia das RPCs transacionais v1 contra uma stack Supabase real/local antes de liberar expansao de base builder, autobattler, social ou minigame.

## Entregue

- Criado `server/tests/transactional_rpc_live_test.ts`, teste live contra Supabase/Postgres local que cobre falha parcial, retry, replay idempotente e rejeicao de `request_hash` divergente.
- Cobertura live incluida para `request_battle_v1`, `equip_build_v1`, `craft_item_v1`, `alpha_purchase_v1`, `guild_create_v1` e `guild_join_v1`.
- `validate_foundation.ps1` ganhou `-IncludeLocalSupabaseRpc` para integrar a prova live ao gate Quick quando a stack local estiver ativa.
- `check_foundation_expansion_readiness.ps1`, docs de testes, status local, Track 17 e portfolio foram atualizados com a nova evidencia.
- Nao houve publicacao remota nem migracao remota.

## Validacao

- `Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe" -WindowStyle Hidden` para iniciar o Docker Desktop local.
- `npx -y supabase@2.98.0 start` passou e deixou a stack local acessivel.
- `npx -y supabase@2.98.0 db reset` passou e aplicou todas as migracoes locais.
- `deno check server/tests/transactional_rpc_live_test.ts` passou.
- `deno run --allow-net --allow-env server/tests/transactional_rpc_live_test.ts` passou.
- `npx -y deno fmt --check server/tests/transactional_rpc_live_test.ts` passou.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .` passou.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick -IncludeLocalSupabaseRpc` passou.
- `git diff --check` passou.

## Limites / Proximo Handoff

- A prova atual chama RPCs diretamente no Postgres local, o que confirma transacao real, rollback real e idempotencia real no banco.
- O `supabase status` indicou Edge Runtime local parado durante a sessao; o proximo passo vivo e rodar smokes HTTP locais das Edge Functions sobre os adapters RPC v1 quando o runtime local estiver disponivel.
- Depois dos smokes HTTP, continuar o split de servicos de dominio de battle/base/economia antes de tuning ou features novas.
