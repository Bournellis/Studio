# Índice da coordenação — JogoDaCopa

## Metadata

- status: living
- authority: router
- last_verified: 2026-07-17
- review_when: a estrutura de coordenação local mudar
- supersedes: none
- superseded_by: none

## Entrada

1. `README.md`
2. `../implementation/current-status.md`
3. `../qa/QA_INDEX.md`
4. `TRIAGE.md`
5. `../implementation/history.md` quando a tarefa exigir história curada

## Trabalho

- fila: `Kanban/Backlog/`
- execução: `Kanban/Doing/`
- decisão humana: `Kanban/Review/`
- encerramento transitório antes da absorção: `Kanban/Done/`
- transferência ativa e transitória: `Handoffs/`

História técnica curada vive em `../implementation/history.md`; releases em `../docs/release-history.md`; evidência bruta em `../docs/playtest-reports/` e `../docs/screenshots/`.

Fontes removidas no cutover não são procuradas no `HEAD`.
Use a história/ledger, `../../../08_Coordenacao_Agentes/Receipts/DocumentationLite/local_jogodacopa.json` e o baseline Git registrado.
Novas narrativas encerradas seguem o mesmo lifecycle mediante manifesto aprovado.
