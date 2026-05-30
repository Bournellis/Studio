# Multi-Agent Doing: DraxosMobile Economy Domain Slice

## Metadata

- data: `2026-05-30`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/foundation-expansion-readiness`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-expansion-readiness`

## Objetivo

Continuar a Foundation Expansion Readiness com o corte portavel `economy application/source-sink projection`. O foco e tirar normalizacao/projecao de deltas, produtos, rewards e receitas dos adapters onde for seguro, sem mudar payload publico, RPCs, schema, tuning, UX ou publicacao remota.

## Base Lida

- `C:\Users\Fabio\.codex\skills\estudio-workspace\SKILL.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Multiagentes

- Explorer `Beauvoir`: mapear funcoes/constantes seguras para `_shared/economy_domain.ts`.
- Explorer `Linnaeus`: mapear cobertura de testes/checkers para dominio economico puro.

## Escopo

- Incluir: modulo espelhado `server/functions/_shared/economy_domain.ts` e `supabase/functions/_shared/economy_domain.ts`.
- Incluir: teste Deno de mirror/contrato para deltas, produtos, rewards e receitas extraidas.
- Incluir: adaptar `monetization/index.ts`, `crafting/index.ts` e leituras simples de `battle/index.ts` quando o modulo ja cobrir sem cruzar aplicacao SQL.
- Incluir: atualizar checker/readme/status se o estado observavel mudar.
- Fora do escopo: tuning, novos produtos, novas receitas, schema, migracoes, publicacao remota, aplicacao SQL real, mudanca visual.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/server/functions/_shared/economy_domain.ts`
- `Projetos/draxos-mobile/supabase/functions/_shared/economy_domain.ts`
- `Projetos/draxos-mobile/server/functions/monetization/index.ts`
- `Projetos/draxos-mobile/supabase/functions/monetization/index.ts`
- `Projetos/draxos-mobile/server/functions/crafting/index.ts`
- `Projetos/draxos-mobile/supabase/functions/crafting/index.ts`
- `Projetos/draxos-mobile/server/functions/battle/index.ts`
- `Projetos/draxos-mobile/supabase/functions/battle/index.ts`
- `Projetos/draxos-mobile/server/tests/economy_domain_test.ts`
- `Projetos/draxos-mobile/tools/check_foundation_expansion_readiness.ps1`
- `Projetos/draxos-mobile/tools/validate_foundation.ps1`
- `Projetos/draxos-mobile/server/tests/README.md`
- status/docs de Track 17 e portfolio, se aplicavel.

## Validacao Planejada

- `npx -y deno fmt` nos arquivos TypeScript tocados.
- `npx -y deno check` nos adapters/modulos/testes tocados.
- `npx -y deno test --allow-read server/tests/economy_domain_test.ts`.
- `npx -y deno task --cwd server/functions check`.
- `npx -y deno task --cwd supabase/functions check`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick`.
- `git diff --check`.

## Proximo Handoff

Se a fatia ficar verde, proximo owner seguro: battle combatant mapping mais profundo; depois alinhar/documentar heuristicas de Progression Lab/Battle Lab.

## Entregue

- Criado `_shared/economy_domain.ts` espelhado em `server/functions` e `supabase/functions`.
- `monetization/index.ts` passou a usar o dominio portavel para rewards, produtos alpha, `request_hash`, payloads de purchase e state payload.
- `crafting/index.ts` passou a usar o dominio portavel para receitas, conversao de Ossos, payloads de craft e state payload.
- `server/tests/economy_domain_test.ts` cobre mirror adapter-free, reward periods, alpha source/sink, lock reasons, crafting payload e craft/crush projections.
- Checkers/status foram atualizados para registrar economy domain como corte concluido e apontar o proximo slice para battle combatant mapping.
- Battle direct legacy cleanup ficou fora deste slice para evitar misturar o proximo dominio.

## Validacao Executada

- `npx -y deno fmt ...` passou nos arquivos tocados.
- `npx -y deno check server/functions/monetization/index.ts supabase/functions/monetization/index.ts server/functions/crafting/index.ts supabase/functions/crafting/index.ts server/tests/economy_domain_test.ts` passou.
- `npx -y deno test --allow-read server/tests/economy_domain_test.ts` passou: `4/4`.
- `npx -y deno task --cwd server/functions check` passou.
- `npx -y deno task --cwd supabase/functions check` passou.
- `npx -y deno test --allow-read server/tests/base_domain_test.ts server/tests/battle_log_projection_test.ts server/tests/progression_domain_test.ts server/tests/economy_domain_test.ts server/tests/foundation_ruleset_test.ts` passou: `16/16`.
- `npx -y deno test --allow-read server/tests/foundation_contracts_test.ts server/tests/foundation_expansion_schema_test.ts server/tests/transactional_domain_enforcement_schema_test.ts server/tests/remaining_transactional_domain_enforcement_schema_test.ts server/tests/integer_bones_contract_test.ts` passou: `19/19`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .` passou.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick` passou.
- `git diff --check` passou.
