# Track 03L.1 - Facing Evidence V1

- Data: `2026-06-11`
- Agente: `Codex`
- Branch: `codex/jogodacopa/track03l1-facing-evidence-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03l1-facing-evidence-v1`
- Projeto: `Projetos/JogoDaCopa`
- Status: `DOING`

## Objetivo

Complementar a evidencia da Track 03L sem tocar em codigo de gameplay:

- registrar o code review da Claude que estava untracked;
- adicionar teste automatizado de facing visual do avatar;
- capturar evidencia visual complementar de corrida em curva, parada apos andar para frente e rebote acima da parede antiga;
- criar o playtest report da 03L no protocolo local;
- validar, atualizar progresso e fechar a branch com main limpo.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/implementation/tracks/track-03l-arena-seal-facing-v2/current-status.md`
- `Projetos/JogoDaCopa/docs/code-review-track03l-arena-seal-facing-v2.md`

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/docs/code-review-track03l-arena-seal-facing-v2.md`
- `Projetos/JogoDaCopa/tests/unit/test_avatar_system.gd`
- `Projetos/JogoDaCopa/tools/capture_track03l_arena.gd`
- `Projetos/JogoDaCopa/docs/screenshots/track-03l-arena/*`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-03l-arena.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`

## Plano De Validacao

- Rodar `validate.gd` e exigir PASS.
- Rodar `git diff --check`.
- Conferir `git status --short`.
- Rodar `tools/check_doc_drift.ps1`.
- Conferir `git worktree list` e `git worktree prune`.

## Handoff

Ao fechar: mover este card para `Kanban/Done`, registrar evidencias e deixar a branch integrada em `main` com `WORKTREE_VERIFIED`.
