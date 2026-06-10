# Active Games Hardening Program

- Data: `2026-06-09`
- Agente: Codex
- Branch: `codex/estudio/active-games-hardening-program`
- Worktree: `D:\Estudio-worktrees\estudio--codex--active-games-hardening-program`
- Base: `main` em `da52457`

## Objetivo

Implementar o programa de hardening/refactor dos dois jogos ativos:

- `Projetos/draxos-roguelike-cardgame/`
- `Projetos/draxos-mobile/`

O foco e preparar ambos para crescimento de longo prazo sem mudar gameplay, economia, tuning, schema, publicacao remota ou contratos externos como efeito colateral.

## Arquivos Pretendidos

- Coordenacao e handoff:
  - `08_Coordenacao_Agentes/Kanban/Doing/2026-06-09_codex_active-games-hardening-program.md`
  - `08_Coordenacao_Agentes/Handoffs/2026-06-09_codex_active-games-hardening-program.md`
- Roguelike:
  - `Projetos/draxos-roguelike-cardgame/docs/`
  - `Projetos/draxos-roguelike-cardgame/tools/`
  - `Projetos/draxos-roguelike-cardgame/tests/unit/`
  - hotspots de baixo risco em `battle/`, `core/` e `modes/battle/` somente quando houver teste de paridade claro
- DraxosMobile:
  - `Projetos/draxos-mobile/docs/`
  - `Projetos/draxos-mobile/tools/`
  - `Projetos/draxos-mobile/server/`
  - `Projetos/draxos-mobile/supabase/`
  - hotspots de baixo risco em `online/`, `modes/openworld/`, `modes/boot/` e `ui/` somente quando houver gate direcionado

## Base Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-roguelike-cardgame/AGENTS.md`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Validacao Prevista

- Global:
  - `git diff --check`
  - `git status --short`
- Roguelike:
  - `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`
  - gates direcionados de Run Lab, Scenario Fixtures, Battle Lab, Card Impact e Design Lab quando os arquivos tocados exigirem
- DraxosMobile:
  - `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile DocsOnly`
  - `ClientQuick`, `ServerQuick`, `ReleaseDryRun` ou `FullLocal -RequireClean` conforme escopo tocado
  - Deno checks para `server/functions` e `supabase/functions` quando backend/contratos forem tocados

## Ponto De Handoff

Entregar commits por etapa com:

- matrizes de hardening e validacao;
- refactors pequenos com paridade;
- validacoes executadas;
- riscos residuais;
- decisao explicita sobre qualquer etapa grande demais para concluir sem quebrar escopo.

## Atualizacao De Handoff

- Entrega consolidada em `08_Coordenacao_Agentes/Handoffs/2026-06-09_codex_active-games-hardening-program.md`.
- Escopo entregue: primeira onda executavel de hardening dos dois jogos ativos, com guardas de promocao/contrato e validacao antes de refactors maiores.
- Status: pronto para commits por projeto e coordenacao.
