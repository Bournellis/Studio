# Estado tecnico atual - Draxos Roguelike Cardgame

## Metadata

- status: living
- authority: local_state
- last_verified: 2026-07-16
- review_when: baseline, gate, risco, validacao ou trabalho permitido mudar
- supersedes: current-status.md before Governance v2
- superseded_by: none

## Portifolio

- estado autorizado: `PAUSADO_TEMPORARIO`;
- trabalho atual: governanca e integridade solicitadas, sem retomada de produto;
- track preservada: `Track 02 - Complete Run Evolution`, marco `T02-P09_COMPLETE`;
- nova track: nenhuma enquanto a pausa nao for encerrada por Fabio.

## Baseline preservada

- Godot 4.6.2, rota fixa de 29 mapas e save/snapshot v5;
- classes Arcano, Invocador e Necromante;
- recompensas, reliquias, Souls shop, keywords, AI/intent, encontros, field effects e boss hooks da Track 02;
- Design Lab Content Wave 01 permanece lab-only; nenhum candidato foi promovido por esta migracao;
- Card Impact V4.2/V5 e Run Lab smoke/quick permanecem os guardrails oficiais.

## Gates humanos pendentes

- escolher candidatos Wave 01 para promocao manual;
- avaliar balanceamento e pacing;
- validar sensacao da run completa em playtest humano.

Os cards vivem em `../08_Coordenacao/Kanban/Review/`. Automacao verde nao resolve esses gates.

## Validacao e riscos

- baseline integral: `226/226` testes GUT e `1.975` asserts;
- rota automatizada: `29/29`; tres classes, save e labs preservados;
- warnings opcionais de arte, recursos GUT e alpha da nave continuam nao fatais;
- divida grande registrada em `engineering-health-baseline.md`; nao ampliar responsabilidades ao tocar esses arquivos.

## Leitura

- QA: `../qa/QA_INDEX.md`
- historia detalhada: `tracks/track-02-complete-run-evolution/`
- snapshot pre-cutover: `tracks/track-02-complete-run-evolution/history/2026-06-25_design-lab-content-wave01-status.md`
