# DraxosMobile Hardening Doing: data-labs-mode-decisions

## Metadata

- data: `2026-06-01`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `data-labs-mode-decisions` (`mode-scaffolds` + `platform-v1`)
- mode_scope: `multi-mode`
- branch: `codex/draxos-mobile/foundation-hardening-v2-data-labs-mode-decisions`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-data-labs-mode-decisions`

## Objetivo

Adicionar enforcement estrito para `data/definitions/modes/*`, scaffold/generator para futuros modos, decision packs para Openworld/Towerdefense/Cardgame e reconciliacao documental dos Labs Arena PVE como diagnostico, sem gameplay novo.

## Latest Context

- latest platform package: `Hardening Platform V1`
- latest Arena loop package: `Track 21 - Arena Loop Unlock And Friction Pass`
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`
- Labs diagnostic source: `docs/contracts/lab-heuristics.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/docs/foundation-app-v0-audit.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/contracts/minigame-integration.md`
- `Projetos/draxos-mobile/docs/contracts/minigame-platform-v1.md`
- `Projetos/draxos-mobile/docs/contracts/lab-heuristics.md`

## Escopo

- Incluir:
  - schema/validador estrito para descritores oficiais em `data/definitions/modes/*`;
  - scaffold/generator de modo futuro sem habilitar gameplay;
  - docs/decision packs para Openworld, Towerdefense e Cardgame;
  - notas vivas que tratem Battle Lab e Progression Lab como diagnostico de Arena PVE, nao tuning autoritativo;
  - testes locais de schema/contrato.
- Fora do escopo:
  - runtime de gameplay;
  - backend Edge, Supabase migrations e publicacao remota;
  - tuning, economia, PVP, novos rewards ou novo conteudo jogavel;
  - worktrees de outros agentes.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/data/definitions/modes/`
- `Projetos/draxos-mobile/docs/minigames/`
- `Projetos/draxos-mobile/docs/design-pending.md`
- `Projetos/draxos-mobile/docs/progression-lab/`
- `Projetos/draxos-mobile/docs/battle-lab/`
- `Projetos/draxos-mobile/tools/`
- `Projetos/draxos-mobile/server/tests/`

## Validation Plan

- `npx -y deno test --allow-read server/tests/mode_definitions_schema_test.ts`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_mode_definitions.ps1 -ProjectDir .`
- `git diff --check`
- `git status --short`

## Handoff Point

Entregar commit logico com schema/generator/docs/tests verdes. Se surgir necessidade de runtime, Edge Function, migration ou tuning, registrar em handoff para outra lane em vez de implementar aqui.

## Resultado

- Entregue schema estrito para descritores oficiais em `data/definitions/modes/*` com lista fixa dos cinco modos oficiais.
- Entregue scaffold/generator local para futuros modos, com dry-run por padrao e saida sempre `planned_disabled`, sem rewards, sem CTA publico e sem runtime.
- Entregue decision packs para `openworld`, `towerdefense` e `cardgame`, todos mantendo os modos futuros congelados ate package decision explicita.
- Reconciliados `Battle Lab` e `Progression Lab` como evidencias diagnosticas da Arena PVE, sem autoridade de tuning, economia, rewards ou runtime.
- Integrado o novo validador ao `validate_foundation.ps1` nos perfis `ModePlatform` e `ServerQuick`.

## Arquivos Alterados

- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-01_codex_draxos-mobile_data-labs-mode-decisions.md`
- `Projetos/draxos-mobile/data/definitions/modes/README.md`
- `Projetos/draxos-mobile/docs/battle-lab/README.md`
- `Projetos/draxos-mobile/docs/contracts/lab-heuristics.md`
- `Projetos/draxos-mobile/docs/contracts/minigame-integration.md`
- `Projetos/draxos-mobile/docs/design-pending.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/minigames/cardgame.md`
- `Projetos/draxos-mobile/docs/minigames/cardgame-decision-pack.md`
- `Projetos/draxos-mobile/docs/minigames/mode-catalog.md`
- `Projetos/draxos-mobile/docs/minigames/mode-template.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/docs/minigames/openworld-decision-pack.md`
- `Projetos/draxos-mobile/docs/minigames/towerdefense.md`
- `Projetos/draxos-mobile/docs/minigames/towerdefense-decision-pack.md`
- `Projetos/draxos-mobile/docs/progression-lab/README.md`
- `Projetos/draxos-mobile/server/tests/README.md`
- `Projetos/draxos-mobile/server/tests/lab_heuristics_contract_test.ts`
- `Projetos/draxos-mobile/server/tests/mode_definitions_schema_test.ts`
- `Projetos/draxos-mobile/tools/README.md`
- `Projetos/draxos-mobile/tools/mode_definitions/scaffold.ts`
- `Projetos/draxos-mobile/tools/mode_definitions/scaffold_mode.ts`
- `Projetos/draxos-mobile/tools/mode_definitions/schema.ts`
- `Projetos/draxos-mobile/tools/mode_definitions/validate.ts`
- `Projetos/draxos-mobile/tools/validate_foundation.ps1`
- `Projetos/draxos-mobile/tools/validate_mode_definitions.ps1`

## Validacoes Executadas

- `npx -y deno fmt tools/mode_definitions/schema.ts tools/mode_definitions/scaffold.ts tools/mode_definitions/scaffold_mode.ts tools/mode_definitions/validate.ts server/tests/mode_definitions_schema_test.ts server/tests/lab_heuristics_contract_test.ts`
- `npx -y deno lint tools/mode_definitions/schema.ts tools/mode_definitions/scaffold.ts tools/mode_definitions/scaffold_mode.ts tools/mode_definitions/validate.ts server/tests/mode_definitions_schema_test.ts server/tests/lab_heuristics_contract_test.ts`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_mode_definitions.ps1 -ProjectDir .`
- `npx -y deno test --allow-read server/tests/lab_heuristics_contract_test.ts server/tests/mode_definitions_schema_test.ts`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ModePlatform`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`
- `git diff --check`

Observacao: a primeira execucao do `ModePlatform` em worktree fresca exigiu um `Godot --headless --import --path .` para registrar classes globais locais. Depois do import, o perfil `ModePlatform` passou. Artefatos `.translation` gerados pelo import foram descartados antes do fechamento.
