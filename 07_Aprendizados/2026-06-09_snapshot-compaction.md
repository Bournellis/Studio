# Aprendizado: Compactacao De Snapshots

- Data: `2026-06-09`
- Area: documentacao operacional

## Problema

Snapshots vivos ficam dificeis de usar quando acumulam todos os detalhes de implementacao e validacao. O agente precisa saber rapidamente o estado atual, o proximo passo e onde ler a historia.

## Regra

Um `implementation/current-status.md` deve responder:

- qual e a verdade atual;
- qual e o objetivo ativo;
- qual e o gate/proximo passo;
- qual validacao recente importa;
- o que ler em seguida.

Detalhes longos devem ir para:

- `implementation/tracks/`;
- Kanban Done;
- Handoffs;
- reports;
- arquivos de history.

## Beneficio

O snapshot vivo continua pequeno e decisivo, enquanto a historia completa permanece auditavel.
