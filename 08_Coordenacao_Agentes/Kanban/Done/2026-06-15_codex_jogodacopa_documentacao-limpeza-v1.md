# JogoDaCopa - Documentacao Limpeza V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/documentacao-limpeza`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--documentacao-limpeza`
- Projeto alvo: `Projetos/JogoDaCopa/`

## Objetivo

Alinhar a documentacao local do `JogoDaCopa` ao baseline publico atual `Super Campeao v1.2.1+6ef3074c`, removendo instrucoes antigas de Track 05/07B/3 gols como padrao, registrando o estado correto de Web publicado e mantendo o proximo passo operacional como retest humano.

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/README.md`
- `Projetos/JogoDaCopa/docs/documentation-index.md`
- `Projetos/JogoDaCopa/docs/publication-readiness.md`
- `Projetos/JogoDaCopa/docs/work-plan.md`
- `Projetos/JogoDaCopa/docs/mode-contract.md`
- `Projetos/JogoDaCopa/docs/validation.md`
- `Projetos/JogoDaCopa/docs/codebase-audit-track05.md` se ainda carregar status operacional antigo
- `Projetos/JogoDaCopa/implementation/current-status.md` apenas para compactar/ajustar referencias da track documental
- `08_Coordenacao_Agentes/Estado_Atual.md` apenas se o snapshot precisar refletir a track documental
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-14_codex_jogodacopa_track07b-web-heap-margin-hotfix.md` para fechar o card obsoleto

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- Lista atual de `08_Coordenacao_Agentes/Kanban/Doing/`

## Validacao Planejada

- Revisao textual por busca de termos antigos que nao devem aparecer como estado atual.
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`
- `D:\Estudio\tools\check_doc_drift.ps1`
- `git diff --check`
- `git status --short`

## Handoff Esperado

Track documental local pronta para review/merge, sem mudanca de gameplay, codigo, assets ou publicacao remota. Se aprovada, Fabio ainda precisa fazer `Push origin` pelo GitHub Desktop apos merge local.

## Resultado

- Status: `CONCLUIDO_EM_BRANCH_PRONTO_PARA_REVIEW_MERGE_LOCAL`.
- Handoff: `08_Coordenacao_Agentes/Handoffs/2026-06-15_codex_jogodacopa_documentacao-limpeza-v1.md`.
- Documentos de entrada alinhados ao baseline publico `Super Campeao v1.2.1+6ef3074c`.
- Card 07B obsoleto movido para Done como `SUPERADO`.
- Sem mudanca de gameplay, runtime, assets ou publicacao remota.

## Validacao Final

- Import headless: PASS.
- Web export release: PASS.
- `tools/validate.gd`: PASS, `104` testes, `1825` asserts, Web gzip transfer `30.57 MiB / 50.00 MiB`.
- `tools/check_doc_drift.ps1`: PASS.
- `git diff --check`: PASS.
- `git status --short`: PASS com apenas arquivos da track modificados/adicionados/removidos antes do commit.

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin apos merge local aprovado.
