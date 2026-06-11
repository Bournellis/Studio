# Track 03J - Process & Git Policy V1

- Data: 2026-06-11
- Agente: Codex
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/jogodacopa/track03j-process-git-policy-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03j-process-git-policy-v1`
- Base: `main` em `1f7b2072` (`docs(jogodacopa): approve remote push ritual`)
- Status: `DONE - validado e pronto para merge local`

## Objetivo

Registrar a decisao vigente de Fabio para git local vs rede, propagar a politica operacional no guia do JogoDaCopa e fechar a track docs-only com main limpo.

## Escopo Permitido

- `Projetos/JogoDaCopa/docs/process-hardening-agents-addendum.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/docs/documentation-index.md`
- `08_Coordenacao_Agentes/Decisoes/2026-06-11_estudio_git_remote_github_desktop.md`
- `08_Coordenacao_Agentes/Decisoes/2026-06-11_estudio_github-backup-desktop.md`
- Este card Kanban

Fora de escopo: codigo/runtime, assets, fetch/pull/push, GitHub Desktop, `git clean` e credenciais/tokens.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/process-hardening-agents-addendum.md`

## Plano De Validacao

- FASE 0: processos Git/GCM, locks `.git` e `git status --short`
- `git diff --check`
- `powershell -ExecutionPolicy Bypass -File tools/check_doc_drift.ps1`
- Validacao estrutural do projeto JogoDaCopa, sem rede
- `git status --short`

## Proximo Handoff

Fechar com merge local em `main`, card movido para Done, worktree removida/pruned, status limpo, linha `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin` e `WORKTREE_VERIFIED`.

## Fechamento Codex

- FASE 0: processos Git/GCM de rede encerrados; locks orfaos removidos; `main` limpo antes da worktree.
- Politica vigente registrada em `08_Coordenacao_Agentes/Decisoes/2026-06-11_estudio_git_remote_github_desktop.md`.
- `Quality Gates` completo inserido em `Projetos/JogoDaCopa/AGENTS.md`.
- Docs untracked de Claude em `Projetos/JogoDaCopa/docs/`: nenhum encontrado.
- Validacao documental: `git diff --check` PASS; `tools/check_doc_drift.ps1` PASS.
- Import headless de worktree nova: PASS com warnings esperados de cache/import do GUT.
- Validacao Godot: PASS, `74/74` tests, `995` asserts, source integrity `29` arquivos.
- Rede git: nenhum `fetch`, `pull` ou `push` executado nesta track.
