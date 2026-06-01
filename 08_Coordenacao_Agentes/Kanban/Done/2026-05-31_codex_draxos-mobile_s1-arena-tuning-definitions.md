# Codex - DraxosMobile S1 Arena Tuning Definitions

- Data: `2026-05-31`
- Projeto: `Projetos/draxos-mobile/`
- Track/contexto: follow-up de tuning da Arena PVE inicial sobre `Remote Lab Runner`
- Status: `DONE_HANDOFF_CONSUMED_BY_TRACK_20`
- Branch: `codex/draxos-mobile/season1-arena-tuning-definitions`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--season1-arena-tuning-definitions`
- Base: `codex/draxos-mobile/remote-lab-runner`

## Objetivo

Transformar a matriz aprovada de Season 1 Arena PVE em definicoes de dados consumiveis, separando `pve_arenas.json` de uma nova definicao de dificuldades/tiers por arena.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/data/definitions/pve_arenas.json`
- `Projetos/draxos-mobile/data/definitions/pve_arena_difficulties.json`
- `Projetos/draxos-mobile/docs/contracts/content-definitions.md`
- `Projetos/draxos-mobile/docs/pve-arena-v1.md`
- `Projetos/draxos-mobile/tools/generate_foundation_ruleset.ts` ou testes de ruleset, se o registry exigir declaracao explicita

## Docs Lidos

- `AGENTS.md` raiz e local
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `docs/agent-operating-manual.md`
- `implementation/current-status.md`
- `docs/documentation-index.md`
- `docs/pve-arena-initial-direction.md`

## Validacao Planejada

- `git diff --check`
- Validacao JSON/estrutura por script local ou Deno rapido
- `npx -y deno test --allow-read server/tests/foundation_ruleset_test.ts`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick`, se o pacote tocar registry/contratos suficientes para justificar gate local

## Handoff

Entregar branch com worktree limpa, resumo dos arquivos alterados, validacoes rodadas e lacunas restantes para backend/labs consumirem os novos tiers.

## Resultado

- Nova definicao `pve_arena_difficulties.json` criada com matriz S1 de tiers por arena, sequencias, power final, perfil de recompensa e clear rate alvo.
- `pve_arenas.json` agora aponta para o catalogo de dificuldades sem remover os defaults runtime publicados.
- Ruleset Foundation regenerado e espelhado em server/supabase; migration de closeout local alinhada ao novo `content_hash`.
- Docs de contrato, GDD, brief, README de dados e status local atualizados para declarar o pacote como contrato de dados implementado.

## Validacao Rodada

- `git diff --check`
- `npx -y deno test --allow-read server/tests/foundation_ruleset_test.ts server/tests/pve_arena_difficulties_test.ts server/tests/foundation_closeout_schema_test.ts`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick`

## Proximo Handoff

Backend, cliente e labs ainda precisam adotar `pve_arena_difficulties.json` como fonte runtime/analitica. Este pacote apenas cria e valida o contrato de dados calibravel da Season 1.

## Fechamento

- Card arquivado em `Done` durante Track 20; o handoff foi consumido por
  `codex/draxos-mobile/s1-arena-calibration-integration`.
