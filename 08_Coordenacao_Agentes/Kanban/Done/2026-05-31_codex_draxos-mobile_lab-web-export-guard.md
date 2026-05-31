# Lab Web Export Guard

- Data: `2026-05-31`
- Agente: Codex
- Branch: `codex/draxos-mobile/lab-web-export-guard`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-consistency-pass`
- Status: `ENTREGUE_LOCAL`

## Objetivo

Corrigir o bug observado no build Web publicado em que Battle Lab Dev tenta
iniciar `npx/deno` via `OS.execute` e falha no navegador. O hotfix deve deixar
claro que geracao local de Labs depende de runtime desktop/local, sem quebrar
PC/Android nem os smokes existentes.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/dev/battle_lab/battle_lab_screen.gd`
- `Projetos/draxos-mobile/dev/progression_lab/progression_lab_screen.gd`
- `Projetos/draxos-mobile/tests/client/*lab*`
- `Projetos/draxos-mobile/tools/*lab*`
- docs/status se o hotfix for publicado

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Validacao Planejada

- `git diff --check`
- GUT client focado nos Labs
- `tools/validate.gd`
- `tools/smoke_dev_lab_ui.gd`
- `tools/smoke_responsive_layout.gd` se tocar layout visivel relevante

## Handoff

Hotfix local entregue. Battle Lab Dev e Progression Lab Dev agora detectam Web
export antes de chamar `OS.execute`, desabilitam acoes que dependem de
`npx/deno` local e mostram mensagem clara para usar PC/editor quando a geracao
depender de processo local.

Validacoes concluidas:

- `git diff --check`
- GUT client: `138/138`, `2364` asserts
- `tools/smoke_dev_lab_ui.gd`
- `tools/validate.gd`
- `tools/smoke_responsive_layout.gd`
- `tools/smoke_exports.gd`
- `tools/validate_foundation.ps1 -Profile Client`

Publicacao remota ainda nao executada neste hotfix; precisa de aprovacao
explicita para `Upload`/`DeployManifest` com `-ConfirmRemoteMutation`.
