# Coordenacao local - Draxos Roguelike Cardgame

## Metadata

- status: living
- authority: operational_contract
- last_verified: 2026-07-16
- review_when: o ciclo operacional local mudar
- supersedes: none
- superseded_by: none

Esta pasta governa cards e handoffs novos de escopo exclusivo do Draxos Roguelike Cardgame. A historia global anterior ao cutover de 2026-07-16 permanece em `../../../08_Coordenacao_Agentes/` e nao sera copiada.

## Ciclo

`Backlog -> Doing -> Done` e o fluxo tecnico normal. `Review` e reservado a uma decisao humana realmente pendente. Um gate humano pendente nao impede integracao tecnica verde, mas o card permanece em `Review` ate a decisao.

Todo card usa metadados v3, registra validacao e encerra com `global_sync_needed`.
Trabalho local nao edita `Prioridades_Estudio.md`, `Estado_Atual.md` ou dashboards; solicita a projecao em `../../../08_Coordenacao_Agentes/PortfolioSync_QUEUE.md`.

## Autoridades

- foco e trabalho permitido: `../../../08_Coordenacao_Agentes/Prioridades_Estudio.md`
- estado tecnico local: `../implementation/current-status.md`
- QA executavel: `../qa/qa_manifest.json`
- QA e gates humanos: `../qa/QA_INDEX.md`
- documentacao local: `documentation-index.md`
- triagem: `TRIAGE.md`

Nenhum arquivo desta pasta aprova promocao de conteudo, balanceamento, sensacao da run, publicacao ou retomada do projeto.
