# Coordenação local — JogoDaCopa

## Metadata

- status: living
- authority: operational_contract
- last_verified: 2026-07-16
- review_when: o ciclo operacional local mudar
- supersedes: none
- superseded_by: none

Esta pasta governa cards e handoffs novos de escopo exclusivo do JogoDaCopa. História global anterior ao cutover de 2026-07-16 permanece em `../../../08_Coordenacao_Agentes/` e não será copiada.

## Ciclo

`Backlog -> Doing -> Done` é o fluxo técnico normal. `Review` é reservado a uma decisão humana realmente pendente. Um gate humano pendente não impede integração técnica verde, mas o card permanece em `Review` até a decisão.

Todo card usa metadados v3, registra validação e encerra com `global_sync_needed`. Trabalho local não edita `Prioridades_Estudio.md`, `Estado_Atual.md` ou dashboards; solicita a projeção em `../../../08_Coordenacao_Agentes/PortfolioSync_QUEUE.md`.

## Autoridades

- foco e trabalho permitido: `../../../08_Coordenacao_Agentes/Prioridades_Estudio.md`
- estado técnico local: `../implementation/current-status.md`
- QA executável: `../qa/qa_manifest.json`
- QA e gates humanos: `../qa/QA_INDEX.md`
- documentação local: `documentation-index.md`
- triagem: `TRIAGE.md`

Nenhum arquivo desta pasta aprova feel, câmera, áudio, visual, publicação ou mudança de produto.
