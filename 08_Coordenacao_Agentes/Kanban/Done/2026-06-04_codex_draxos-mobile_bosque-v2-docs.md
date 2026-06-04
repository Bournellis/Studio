# DraxosMobile Hardening Done: coord-docs/mode-scaffolds - Bosque v2 docs

## Metadata

- data: `2026-06-04`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `coord-docs` + `mode-scaffolds`
- mode_scope: `openworld`
- branch: `codex/draxos-mobile/bosque-v2-docs`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-v2-docs`
- cleanup: worktree e branch removidas em `2026-06-04` apos integracao seletiva/superseded.

## Objetivo

Documentar o contrato de Bosque Mecanico Basico v2 como minigame livre e relaxante de coletar, depositar, craftar e construir, sem transformar orientacao em objetivo obrigatorio.

## Latest Context

- latest Arena loop package: `Track 21 - Arena Loop Unlock And Friction Pass`
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`

## Base Lida

- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- referencia historica somente leitura: `D:\Estudio-worktrees\draxos-mobile--codex--openworld-objectives-docs\Projetos\draxos-mobile\docs\minigames\openworld-objectives.md`

## Escopo

- Incluir:
  - contrato documental de Bosque Mecanico Basico v2;
  - orientacao tutorial discreta de seis passos, persistida no save normal server-side e reabrivel pela aba `Sessao`;
  - semantica de entrada/saida livre: `Voltar` preserva/pausa visita, `Encerrar visita` finaliza e mostra resumo leve;
  - recursos fixos suficientes para `Bolsa Simples I` + `Fogueira Estavel I` com pequena sobra;
  - `Fogueira Estavel I` como objeto procedural permanente e bloqueante perto de `x=305 y=330` apos craft.
- Fora do escopo:
  - runtime fora da lane;
  - worktrees de outros agentes;
  - remote mutation/publicacao;
  - backend functions, migrations, Godot client, ruleset JSON ou testes;
  - inimigos, NPCs, quests, combate, cidade, open world completo, respawn/procedural generation, economia ampla, reward novo, PVP ou conteudo novo sem decisao explicita.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/docs/minigames/openworld-objectives.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-04_codex_draxos-mobile_bosque-v2-docs.md`

## Validation Plan

- `git diff --check`
- `rg -n "objetivo obrigatorio|mandatory objective|quest|NPC|inimigo|combate|cidade|procedural|respawn|reward novo|publicacao remota" Projetos/draxos-mobile/docs/minigames/openworld.md Projetos/draxos-mobile/docs/minigames/openworld-objectives.md Projetos/draxos-mobile/docs/documentation-index.md`
- `git status --short`

## Handoff Point

Entregar commit documental isolado para que backend/client/ruleset lanes possam alinhar implementacao futura ao contrato v2 sem reabrir escopo de publicacao ou runtime nesta branch.
