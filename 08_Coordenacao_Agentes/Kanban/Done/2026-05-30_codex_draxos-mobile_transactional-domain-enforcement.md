# Multi-Agent Done: DraxosMobile Transactional Domain Enforcement

## Metadata

- data: `2026-05-30`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/foundation-expansion-readiness`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-expansion-readiness`

## Objetivo

Continuar a Foundation Expansion Readiness transformando os contratos de account/save, ruleset e idempotencia v1 em enforcement exercitado por mutations reais e testes.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/foundation-expansion-readiness.md`
- `Projetos/draxos-mobile/docs/contracts/account-save.md`
- `Projetos/draxos-mobile/docs/contracts/api-endpoints.md`
- `Projetos/draxos-mobile/docs/contracts/database-schema.md`
- `Projetos/draxos-mobile/docs/contracts/ruleset-registry.md`

## Escopo

- Incluir: RPCs transacionais v1 com domain effects para primeira fatia backend, testes Deno/static, docs/status e gates de validacao.
- Fora do escopo: tuning numerico, nova UX, novo minigame, social expandido, nova economia/conteudo, publicacao remota e secrets.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/supabase/migrations/`
- `Projetos/draxos-mobile/server/schema/migrations/`
- `Projetos/draxos-mobile/server/tests/`
- `Projetos/draxos-mobile/docs/contracts/`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-17-foundation-expansion-readiness/`
- `08_Coordenacao_Agentes/`

## Validacao

- `git diff --check`
- `npx -y deno test --allow-read server/tests/foundation_expansion_schema_test.ts`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Full`

## Proximo Handoff

Entregue: Base `state`, `collect` e `upgrade` foram ligados ao caminho RPC v1. `collect_base_v1` e `start_base_upgrade_v1` agora fazem lock do save, reserva idempotente com `request_hash`, completam jobs vencidos, escrevem ledger/saldo/job e salvam resposta com metadata de ruleset na mesma transacao. O adapter HTTP preserva o payload de UI atual e calcula hash canonico quando o cliente alpha ainda nao envia `request_hash`.

Validacao concluida:

- `git diff --check`
- `npx -y deno test --allow-read server/tests/transactional_domain_enforcement_schema_test.ts`
- `npx -y deno test --allow-read server/tests/foundation_expansion_schema_test.ts`
- `npx -y deno test --allow-read server/tests/foundation_contracts_test.ts`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Full`

Observacao: ao acoplar os testes Deno ao `validate_foundation.ps1`, o contrato de Ossos detectou um risco real de resetar timer do Ossario sem ganho visivel. O SQL foi corrigido para atualizar `last_collected_at` apenas quando `collectable.amount > 0`.

Proximo handoff: repetir a mesma promocao transacional para battle reward application, rewards/alpha purchase, build/crafting e guild create/join.
