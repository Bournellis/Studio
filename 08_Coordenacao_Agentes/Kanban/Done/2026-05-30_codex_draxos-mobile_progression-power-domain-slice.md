# Multi-Agent Doing: DraxosMobile Progression Power Domain Slice

## Metadata

- data: `2026-05-30`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/foundation-expansion-readiness`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-expansion-readiness`

## Objetivo

Continuar a Foundation Expansion Readiness com o proximo corte portavel: `progression/power projection`. O foco e tirar calculo de poder, slots/unlocks, opcoes de equipamento e projecao de build dos adapters sem mudar UX, tuning, schema, payload publico ou publicacao remota.

## Base Lida

- `C:\Users\Fabio\.codex\skills\estudio-workspace\SKILL.md`
- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/foundation-expansion-readiness.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-17-foundation-expansion-readiness/current-status.md`

## Multiagentes

- Explorer `Harvey`: mapear level, XP, unlocks e power atuais.
- Explorer `Singer`: mapear economia/source-sink como proximo corte alternativo.

## Escopo

- Incluir: modulo espelhado `server/functions/_shared/progression_domain.ts` e `supabase/functions/_shared/progression_domain.ts`.
- Incluir: teste Deno de mirror/contrato para poder, slots, unlocks, opcoes e payload de build.
- Incluir: adaptar `build/index.ts` para usar o modulo sem mudar contrato de resposta.
- Incluir: adaptar leituras simples de `battle/index.ts` quando o modulo ja cobrir poder/qualidade sem cruzar simulador.
- Incluir: atualizar checker/readme/status se o estado observavel mudar.
- Fora do escopo: tuning, novas armas, novas spells, nova economia, migration, publicacao remota, alteracao visual.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/server/functions/_shared/progression_domain.ts`
- `Projetos/draxos-mobile/supabase/functions/_shared/progression_domain.ts`
- `Projetos/draxos-mobile/server/functions/build/index.ts`
- `Projetos/draxos-mobile/supabase/functions/build/index.ts`
- `Projetos/draxos-mobile/server/functions/battle/index.ts`
- `Projetos/draxos-mobile/supabase/functions/battle/index.ts`
- `Projetos/draxos-mobile/server/tests/progression_domain_test.ts`
- `Projetos/draxos-mobile/tools/check_foundation_expansion_readiness.ps1`
- `Projetos/draxos-mobile/server/tests/README.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-17-foundation-expansion-readiness/current-status.md`

## Validacao Planejada

- `npx -y deno fmt` nos arquivos TypeScript tocados.
- `npx -y deno check` nos adapters/modulos/testes tocados.
- `npx -y deno test --allow-read server/tests/progression_domain_test.ts`.
- `npx -y deno task --cwd server/functions check`.
- `npx -y deno task --cwd supabase/functions check`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick`.
- `git diff --check`.

## Proximo Handoff

Fatia verde. Proximo owner seguro: economy application/source-sink projection, depois battle combatant mapping mais profundo.

## Entrega

- Criado `_shared/progression_domain.ts` espelhado em `server/functions` e `supabase/functions`.
- Movidos para o dominio portavel: payload de build, slots/unlocks, opcoes de equipamento, validacao de equip, power runtime, `effectivePower`, spell level map e quality tier usados por battle.
- Adaptados `build/index.ts` e `battle/index.ts` para manter auth/idempotencia/RPC/HTTP como adapter.
- Adicionado `server/tests/progression_domain_test.ts` cobrindo mirror, adapter-free, payload, unlocks, equip validation e power/helper values.
- Atualizados README de testes, checker estrutural, validate foundation, status do projeto, track e portfolio.

## Validacao Executada

- `npx -y deno fmt ...` nos arquivos TypeScript tocados.
- `npx -y deno check server/functions/build/index.ts supabase/functions/build/index.ts server/functions/battle/index.ts supabase/functions/battle/index.ts server/tests/progression_domain_test.ts` passou.
- `npx -y deno task --cwd server/functions check` passou.
- `npx -y deno task --cwd supabase/functions check` passou.
- `npx -y deno test --allow-read server/tests/base_domain_test.ts server/tests/battle_log_projection_test.ts server/tests/progression_domain_test.ts server/tests/foundation_ruleset_test.ts` passou com `12/12`.
- `npx -y deno test --allow-read server/tests/foundation_contracts_test.ts server/tests/foundation_expansion_schema_test.ts server/tests/transactional_domain_enforcement_schema_test.ts server/tests/remaining_transactional_domain_enforcement_schema_test.ts server/tests/integer_bones_contract_test.ts` passou com `19/19`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .` passou.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick` passou.

## Observacoes

- Sem schema, tuning, UX ou publicacao remota.
- Progression Lab e Battle Lab ainda possuem heuristicas locais de power; alinhar ou documentar em pacote proprio posterior.
