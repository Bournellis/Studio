# JogoDaCopa - Post-09O Doc Cleanup V1

- Projeto: `Projetos/JogoDaCopa/`
- Agente: Codex
- Branch: `codex/jogodacopa/post09o-doc-cleanup-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--post09o-doc-cleanup-v1`
- Base: `main` em `0df722e4`
- Status: `CONCLUIDO_LOCAL_MERGE_PENDENTE`

## Objetivo

Limpar as duas sobras documentais encontradas na auditoria pos-push da Track 09O:

- corrigir o ponteiro vivo de `Projetos/README.md` que ainda tratava `quality-upgrade-plan.md` como plano ativo;
- encerrar o card antigo da Track 07 que ficou parado em `Kanban/Review/` apesar de ter sido superado por rollback/hotfixes posteriores.

## Arquivos Pretendidos

- `Projetos/README.md`
- `08_Coordenacao_Agentes/Kanban/Review/2026-06-14_codex_jogodacopa_track07-visual-polish-web-safe.md`
- `08_Coordenacao_Agentes/Kanban/Done/2026-06-14_codex_jogodacopa_track07-visual-polish-web-safe.md`

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/documentation-index.md`

## Validacao Planejada

- `D:\Estudio\tools\check_doc_drift.ps1`
- cobertura simples do indice documental do JogoDaCopa
- varredura de ponteiros antigos em `Projetos/README.md`
- `git diff --check`
- `git status --short`

## Fechamento

- `Projetos/README.md` deixou de apontar `quality-upgrade-plan.md` como plano ativo do JogoDaCopa e agora aponta para o indice documental, plano vivo e publication readiness.
- O card antigo da Track 07 saiu de `Kanban/Review/` e foi encerrado em `Kanban/Done/` como historico de rollback superado.
- Nenhum status vivo, baseline publico, codigo, asset, cena, pacote ou publicacao foi alterado.

## Handoff

Commitar esta track documental, fazer merge local em `main` e deixar o push remoto pendente para Fabio via GitHub Desktop.
