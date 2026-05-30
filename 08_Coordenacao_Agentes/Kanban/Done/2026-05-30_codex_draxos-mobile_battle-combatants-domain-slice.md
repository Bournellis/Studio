# Multi-Agent Doing: DraxosMobile Battle Combatants Domain Slice

## Metadata

- data: `2026-05-30`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/foundation-expansion-readiness`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-expansion-readiness`

## Objetivo

Continuar a Foundation Expansion Readiness com o corte portavel `deeper battle combatant mapping`. O foco e separar mapeamento de combatentes, stats, builds/bots e summons do simulador quando for seguro, mantendo tuning, payload publico, replay, schema, RPCs e UX inalterados.

## Base Lida

- `C:\Users\Fabio\.codex\skills\estudio-workspace\SKILL.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-17-foundation-expansion-readiness/current-status.md`

## Multiagentes

- Explorer `Beauvoir`: mapear funcoes/tipos/constantes de combatants extraiveis de `battle_simulator.ts`.
- Explorer `Linnaeus`: mapear cobertura de testes/checkers para o novo dominio de combatants.

## Escopo

- Incluir: modulo espelhado `server/functions/_shared/battle_combatants.ts` e `supabase/functions/_shared/battle_combatants.ts`, se a extracao for segura.
- Incluir: adaptar `battle_simulator.ts` para consumir o modulo sem mudar resultado.
- Incluir: teste Deno de mirror/contrato para combatants, summons e helpers extraidos.
- Incluir: atualizar checker/readme/status se o estado observavel mudar.
- Fora do escopo: tuning numerico, novas regras de combate, novos bots, schema, migrations, RPCs, replay format, UX, publicacao remota.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/server/functions/_shared/battle_combatants.ts`
- `Projetos/draxos-mobile/supabase/functions/_shared/battle_combatants.ts`
- `Projetos/draxos-mobile/server/functions/_shared/battle_simulator.ts`
- `Projetos/draxos-mobile/supabase/functions/_shared/battle_simulator.ts`
- `Projetos/draxos-mobile/server/tests/battle_combatants_test.ts`
- `Projetos/draxos-mobile/tools/check_foundation_expansion_readiness.ps1`
- `Projetos/draxos-mobile/tools/validate_foundation.ps1`
- `Projetos/draxos-mobile/server/tests/README.md`
- status/docs de Track 17 e portfolio, se aplicavel.

## Validacao Planejada

- `npx -y deno fmt` nos arquivos TypeScript tocados.
- `npx -y deno check` nos modulos/testes tocados.
- `npx -y deno test --allow-read server/tests/battle_combatants_test.ts`.
- `npx -y deno test --allow-read server/tests/battle_log_projection_test.ts server/tests/progression_domain_test.ts server/tests/economy_domain_test.ts server/tests/foundation_ruleset_test.ts`.
- `npx -y deno task --cwd server/functions check`.
- `npx -y deno task --cwd supabase/functions check`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick`.
- `git diff --check`.

## Proximo Handoff

Se a fatia ficar verde, proximo owner seguro: alinhar/documentar heuristicas de Progression Lab/Battle Lab ou fechar demais cortes pequenos antes de tuning de base/autobattler.

## Entregue

- Criado dominio espelhado `battle_combatants.ts` para projecao de combatentes player/bot, potion slots e behaviors sem depender de adapter HTTP/Supabase.
- `battle_simulator.ts` passou a consumir/reexportar contratos de combatants sem alterar loop, tuning, eventos ou payload publico.
- `battle/index.ts` passou a usar mappers de dominio para player/bot, removendo duplicacao local de normalizacao de combatants.
- `foundation_ruleset_v0` passou a hashear `battle_combatants.ts` junto do simulator, preservando rastreabilidade de inputs efetivos da batalha.
- Checkers, validacao Quick, README de testes, status da Track 17 e portfolio foram atualizados para refletir o novo corte fundacional.

## Validacao Executada

- `npx -y deno check` nos modulos e testes tocados.
- `npx -y deno test --allow-read server/tests/battle_combatants_test.ts server/tests/foundation_ruleset_test.ts server/tests/first_slice_simulator_test.ts` - 11 passed.
- `npx -y deno task --cwd server/functions check`.
- `npx -y deno task --cwd supabase/functions check`.
- `npx -y deno test --allow-read server/tests/battle_combatants_test.ts server/tests/base_domain_test.ts server/tests/battle_log_projection_test.ts server/tests/progression_domain_test.ts server/tests/economy_domain_test.ts server/tests/foundation_ruleset_test.ts server/tests/first_slice_simulator_test.ts` - 25 passed.
- `npx -y deno test --allow-read server/tests/foundation_contracts_test.ts server/tests/foundation_expansion_schema_test.ts server/tests/transactional_domain_enforcement_schema_test.ts server/tests/remaining_transactional_domain_enforcement_schema_test.ts server/tests/integer_bones_contract_test.ts` - 19 passed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick` - 40 foundation contract/domain tests passed inside Quick.
- `git diff --check`.
