# RPG Turnos — contrato de retomada

## Metadata

- status: `frozen`
- authority: `runbook`
- last_verified: `2026-07-17`
- review_when: `Fabio autorizar a retomada do projeto ou uma autoridade local mudar`
- supersedes: `roadmaps e listas de gaps anteriores ao Documentation Lite v2`
- superseded_by: `none`

Este documento não retoma o projeto, não abre track e não aprova produto. Ao voltar ao RPG Turnos, leia primeiro `../implementation/current-status.md` e confirme a permissão no portfólio.

## Fronteiras preservadas

- RPG Turnos é o RPG de exploração 2D com batalhas de cartas e slots; não herda mecânicas do RPG Isométrico nem do Draxos Roguelike.
- C1 continua sendo o único modelo de turnos. A/B variants, stack, counterspell e janelas de resposta são apenas história.
- O conteúdo autoral vive em `../data/definitions/slice_catalog.json`; o `.tres` é gerado e nunca editado como origem.
- Invocador, Arcano e Necromante são as três classes implementadas, cada uma com deck inicial de 20 cartas.
- Save v2 é a baseline. A migração v1→v2 deve permanecer pura, determinística e compatível com os oito renames da cadeia principal.
- Os cinco IDs de encontros laterais preservados no P20 não podem ser renomeados sem decisão de lore e uma nova migração coberta por testes.

## Gates de retomada

Fabio precisa autorizar a retomada e escolher a superfície da nova track. A escolha não pode ser inferida de planos antigos, gaps históricos ou do estado de outro projeto.

Se a nova track tocar apresentação, lore, progressão, balanceamento, equipamento, economia ou conteúdo, registre primeiro a decisão local. Automação verde não aprova jogabilidade, sensação, texto final, direção visual ou balanceamento.

## Reentrada técnica mínima

1. Confirmar portfólio e abrir card local/worktree.
2. Rodar `DocsOnly` e o runner `rpg_turnos_contracts` do `qa_manifest.json`.
3. Rodar a validação integral duas vezes e confirmar árvore limpa nas duas execuções.
4. Fazer smoke humano de seleção de classe, exploração, deck, encontro, resultado, save e load antes de aceitar uma nova baseline jogável.
5. Reavaliar dívida apenas nos arquivos tocados; não iniciar refatoração em massa.

## Questões deliberadamente não decididas

- título final, direção visual final, áudio e apresentação de transições;
- profundidade futura de stats, equipamento, itens e progressão;
- destino narrativo dos cinco encontros laterais ainda com IDs preservados;
- conteúdo, economia, balanceamento ou próxima track.

Essas questões são opções de retomada, não backlog autorizado.
