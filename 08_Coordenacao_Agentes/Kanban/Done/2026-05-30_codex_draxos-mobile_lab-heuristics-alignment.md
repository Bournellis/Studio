# Multi-Agent Doing: DraxosMobile Lab Heuristics Alignment

## Metadata

- data: `2026-05-30`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/foundation-expansion-readiness`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-expansion-readiness`

## Objetivo

Continuar a Foundation Expansion Readiness alinhando ou documentando as heuristicas locais restantes de Progression Lab e Battle Lab antes de abrir tuning de base builder, autobattler, social ou minigame.

## Base Lida

- `C:\Users\Fabio\.codex\skills\estudio-workspace\SKILL.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-17-foundation-expansion-readiness/current-status.md`

## Multiagentes

- Explorer `Beauvoir`: mapear heuristicas locais de Progression Lab/Battle Lab e riscos.
- Explorer `Linnaeus`: mapear guardrails de teste/checker/documentacao para impedir que Labs virem tuning autoritativo silencioso.

## Escopo

- Incluir: inventario das heuristicas locais que permanecem em Labs.
- Incluir: declarar autoridade de cada heuristica como `lab-only`, `derived from ruleset/domain`, `client presentation` ou `blocked until product decision`.
- Incluir: guardrail estrutural em testes/checkers para manter essa documentacao sincronizada.
- Incluir: atualizar status/portfolio se o estado observavel mudar.
- Fora do escopo: tuning numerico, novas armas, novas spells, novos bots, novos thresholds, schema, RPCs, UX publicada, minigame real ou publicacao remota.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/docs/contracts/lab-heuristics.md`
- `Projetos/draxos-mobile/tools/check_foundation_expansion_readiness.ps1`
- `Projetos/draxos-mobile/tools/validate_foundation.ps1`, se houver teste novo.
- `Projetos/draxos-mobile/server/tests/README.md`, se houver teste Deno novo.
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-17-foundation-expansion-readiness/current-status.md`
- snapshots de portfolio, se aplicavel.

## Validacao Planejada

- `git diff --check`
- checker estrutural de Foundation Expansion Readiness.
- `validate_foundation.ps1 -Profile Quick`
- teste Deno/Godot especifico se o guardrail exigir leitura de contratos.

## Proximo Handoff

Se a fatia ficar verde, proximo owner seguro: escolher explicitamente entre base builder tuning, autobattler tuning, social expansion ou minigame shell/contract.

## Resultado

- Criado `docs/contracts/lab-heuristics.md` como contrato `LAB_HEURISTICS_CONTRACT_V1`.
- Battle Lab Godot agora usa os mesmos pesos de poder do runner TypeScript.
- Progression Lab ganhou guardrail de perfis/milestones contra o modelo versionado.
- `server/tests/lab_heuristics_contract_test.ts` agora cobre model IDs, ruleset hashing, formula de poder, selectors, geradores offline/adapter-free, seeder local-only e bloqueio de imports runtime de geradores/telas dev.
- Checkers e status foram atualizados para tratar Labs como evidencia lab-only ate decisao explicita de pacote.

## Validacao Executada

- `npx -y deno check server/tests/lab_heuristics_contract_test.ts`: PASS.
- `npx -y deno test --allow-read server/tests/lab_heuristics_contract_test.ts`: PASS, 7/7.
- `npx -y deno test tools/battle_lab tools/progression_lab`: PASS, 18/18.
- GUT client direcionado para Battle/Progression Lab: PASS, 129/129.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .`: PASS.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick`: PASS.
