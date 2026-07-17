# Historia consolidada - Draxos Roguelike Cardgame

## Metadata

- status: historical
- authority: historical_record
- last_verified: 2026-07-17
- review_when: cleanup manifest, recovery audit or historical authority changes
- supersedes: Track 00, Track 01, Track 02 and promoted-proposal history listed below
- superseded_by: none

Este registro preserva a linhagem tecnica e de produto necessaria para recuperar decisoes sem recolocar tracks, propostas e logs no caminho normal de leitura. Ele nao governa foco, estado tecnico, balance, promocao de conteudo ou retomada.

Autoridades vivas: `current-status.md` para estado local, `../docs/game-design-document.md` para produto, `../docs/architecture.md` para arquitetura, JSON/testes para conteudo e `../qa/QA_INDEX.md` para validacao.

## Linha do tempo das tracks

### Track 00 - bootstrap local

- Em 2026-05-07 o projeto nasceu de um fork tecnico estreito de RPG Turnos, sem adotar sua exploracao, progressao, deck, mana ou tabuleiro como mecanica local.
- O catalogo foi reduzido, o combate passou a usar contagem local de slots e surgiram Boot, ShipHub, RunMap e o primeiro Battle.
- O checkpoint evoluiu de 5/5 para 21/21 testes e fechou com 148 asserts.
- A primeira luta `limpar_mesa` e o boss summoner eram provas de fluxo, nao balance final.

### Track 01 - slice jogavel de 13 mapas

- Consolidou Arcano, Invocador e Necromante, decks iniciais, recompensas, upgrades, Souls shop, saves locais, drag-and-drop e seis tipos de encontro.
- O slice terminou em save v4, 13 mapas, 67/67 testes e 536 asserts.
- Descarte pre-combate, valores de cartas, recompensas e notas de encontro desta fase foram posteriormente alterados pela Track 02.
- A Track 01 e proveniencia; nao redefine o GDD atual nem o catalogo oficial.

### Track 02 - complete run evolution

- A direcao aprovada foi uma run linear fixa de 29 mapas em Terra, Gelo, Ar e Fogo, sem meta-progressao persistente e com derrota encerrando a run.
- P01-P09 entregaram save/snapshot v5, agenda de rewards, 18 relics declaradas, Souls shop expandida, keywords/status, oito reward cards por classe, 30 cartas inimigas, AI/intent, formatos, field effects e boss hooks.
- A validacao cresceu de 70/70 e 561 asserts em P01 para 93/93 e 1.119 asserts em P09.
- O smoke final percorreu 29/29 mapas: 217 turnos estimados, 116 HP loss, zero mortes, 362 Souls ganhos, 291 gastos, 71 restantes, deck final de 38 cartas, seis relics e 21 acoes de loja.
- Foundation Hardening 2-9 extraiu simulador, services, directors e presenters sem mudar APIs publicas. O fechamento chegou a 105/105 e 1.279 asserts, com duas execucoes verdes.

## Contratos promovidos e limites

| Origem | Promovido | Nao promovido |
|---|---|---|
| proposta de rota | 29 mapas, blocos elementais, modos, formatos, field effects e bosses | numeros antigos que divergem do JSON/GDD |
| proposta de keywords | vocabulario e timings cobertos pela Track 02 | prioridades e estimativas de implementacao da sessao |
| proposta de cartas | oito reward cards por classe e upgrades Lvl 2/Lvl 3 | observacoes de rebalance sem playtest |
| planos Track 02 | rewards, relics, AI/intent e criterios implementados | prompts, cursores e proximos passos encerrados |
| mockups Track 00/01 | objetivos que reaparecem no catalogo Track 02 | stats, rewards, posicao na rota e tuning antigos |

O contrato atual vive no GDD, no JSON, nos docs de classe e nos testes. Um detalhe historico so continua valido quando uma dessas autoridades o confirma.

## Linhagem de validacao e labs

| Etapa | Sinal preservado | Papel |
|---|---|---|
| Run Lab golden | Arcano seed 20260518 exato; Invocador e Necromante 29/29 sem morte | regressao macro da rota |
| AutoRun V1 | 108/108, 1.304 asserts; matriz quick de 30 casos | comparacao de seeds, classes e politicas |
| AutoRun Gate Pack | 111/111, 1.313 asserts | baselines smoke/quick e scorecard |
| Scenario Fixtures | 9 PASS, 3 WARN, 0 FAIL; 120/120, 1.343 asserts | sinais nomeados de rota, economia, deck e boss |
| Battle Lab | baseline recorrente 9 PASS, 3 WARN, 0 FAIL | comportamento isolado de combate real |
| Card Impact V1-V3 | 84 casos ativos e captura isolada; V3 chegou a 164/164 e 1.651 asserts | impacto de cartas e assinaturas de efeito |
| Card Impact V4 | 108 cartas do jogador, 30 inimigas report-only e 15 legadas auditadas; 175/175 e 1.704 asserts | matriz completa do jogador |
| Card Impact V4.1 | tres casos Colheita observaveis; 187/187 e 1.785 asserts apos o redesign | fluxo de carta, mao, deck e descarte |
| Card Impact V4.2 | 21/21 expectativas de card flow; 199/199 e 1.827 asserts | contrato de Colheita promovido |
| Card Impact V5 | 30/30 inimigos jogados, 30 assinaturas limpas; 211/211 e 1.906 asserts | causalidade de cartas inimigas |
| Design Lab V1 | proposta -> overlay -> contextos -> scoring -> promotion manifest, sem mutar catalogo | exploracao numerica consultiva |
| Content Wave 01 | 226/226, 1.975 asserts; gates oficiais Card Impact e Run Lab verdes | baseline preservada antes de promocao humana |

Labs escrevem em `user://`, produzem evidencia e protegem regressao. Eles nao aprovam conteudo, balance, pacing, sensacao ou publicacao.

## Mudancas aceitas, probes rejeitados e divida

- Card Impact sustentou redesigns aceitos de player/reward cards, card flow e duas batches de inimigos. As autoridades atuais contêm os valores finais.
- O probe isolado de `arcano_choque` de 2 para 3 de dano falhou Battle Lab e testes derivados; foi apenas calibracao e nao foi promovido como balance final.
- Uma primeira tentativa de batch Terra foi removida quando Battle Lab detectou regressao em duelos/bosses de Arcano. A batch aceita alterou apenas Tita 3->2 ATK e Granito 7->8 HP.
- As recomendacoes antigas para Fagulha, Golem, Barreira e Promover eram hipoteses sem playtest, nao decisoes.
- Cinco hooks de relics foram historicamente declarados como pendentes em P03; o estado efetivo deve ser consultado no JSON, no codigo e nos testes, nunca inferido deste registro.
- Divida de `BattleEngine`, `BattleRoot`, Card Impact e RunSession permanece no `engineering-health-baseline.md`; esta curadoria nao autoriza refatoracao em massa.

## Design Lab Content Wave 01

- Os packs de Arcano, Invocador e Necromante produziram 48 candidatos e oito recomendacoes por classe no explore; seus subsets promocionaveis passaram em gate.
- O pack inimigo explorou 72 candidatos, reteve oito recomendacoes e rejeitou 24 variantes arriscadas/quebradas; o subset promocionavel passou sem elas.
- O backlog registrou seis cartas e cinco mecanicas bloqueadas: `steal_mana`, `copy_last_spell`, `lane_shift`, `summon_from_discard` e `life_payment`.
- Nenhuma mecanica bloqueada recebeu tuning falso ou entrou no catalogo oficial.
- Promotion manifests preservam vizinhos oficiais, riscos, falhas de contexto e perguntas de review. `manual_approval_required` continua verdadeiro.

## Gates humanos preservados

- promocao manual de candidatos Design Lab Content Wave 01;
- balanceamento e pacing da Track 02;
- sensacao da run completa em playtest humano.

Os tres cards correspondentes permanecem em `../08_Coordenacao/Kanban/Review/` com `human_gate_status: pending`. Pausa, publicacao e remoto continuam fora de escopo.

## Inventario absorvido - 18 arquivos de track

| Fonte pre-cutover | Conteudo retido aqui |
|---|---|
| `tracks/README.md` | ordem e marcadores das tracks |
| `tracks/track-00-project-bootstrap/current-status.md` | resultado do bootstrap |
| `tracks/track-00-project-bootstrap/linear-execution-plan.md` | P00-P07 e limites locais |
| `tracks/track-00-project-bootstrap/validation-record.md` | 21/21 e 148 asserts |
| `tracks/track-01-playable-run-loop/current-status.md` | baseline final do slice de 13 mapas |
| `tracks/track-01-playable-run-loop/linear-execution-plan.md` | P01-P05 e transicao para Track 02 |
| `tracks/track-02-complete-run-evolution/card-tuning-lab-probe-v1.md` | probe Choque rejeitado |
| `tracks/track-02-complete-run-evolution/current-status.md` | baseline T02-P09_COMPLETE e batches aceitas |
| `tracks/track-02-complete-run-evolution/design-brief.md` | direcao da run de 29 mapas |
| `tracks/track-02-complete-run-evolution/enemy-ai-and-difficulty.md` | perfis elementais, intent e veto ao +20% global |
| `tracks/track-02-complete-run-evolution/handoff-log.md` | sequencia de entregas, validacoes e reversoes |
| `tracks/track-02-complete-run-evolution/history/2026-06-25_design-lab-content-wave01-status.md` | snapshot Wave 01 |
| `tracks/track-02-complete-run-evolution/implementation-prompts.md` | escopo e aceite de P01-P09 |
| `tracks/track-02-complete-run-evolution/linear-execution-plan.md` | fechamento linear da Track 02 |
| `tracks/track-02-complete-run-evolution/relics.md` | pool inicial e hooks planejados |
| `tracks/track-02-complete-run-evolution/reward-system.md` | agenda, raridades e Souls shop |
| `tracks/track-02-complete-run-evolution/status-history-2026-06-06-design-lab-v1.md` | ponte Card Impact/Design Lab |
| `tracks/track-02-complete-run-evolution/validation-and-tuning-notes.md` | linhagem de gates, screenshots e divida |

## Inventario absorvido - 9 documentos historicos

| Fonte pre-cutover | Conteudo retido aqui ou em autoridade viva |
|---|---|
| `../docs/reuse-map.md` | proveniencia do fork e fronteira com RPG Turnos |
| `../docs/foundation-closeout.md` | ownership, hardening e divida residual |
| `../docs/design-early-game.md` | decisoes precursoras da Track 01 |
| `../docs/encounters/README.md` | resumo de modos, formatos e validacao de rota |
| `../docs/encounters/encontro-02-ondas.md` | persistencia entre waves como proveniencia |
| `../docs/encounters/encontro-01-limpar-board.md` | objetivo e combate frontal inicial |
| `../docs/design-proposals/sessao-b-cartas-novas.md` | origem das reward cards; tuning nao aprovado excluido |
| `../docs/design-proposals/sessao-a-keywords.md` | origem do vocabulario; prioridades antigas excluidas |
| `../docs/design-proposals/rota-29-mapas.md` | origem da rota; divergencias numericas excluidas |

As 27 fontes continuam presentes nesta etapa. Uma remocao futura depende de manifesto literal aprovado, hashes exatos, autoridade retida e receipt recuperavel; esta classificacao nao autoriza delecao.

## Recuperacao

Antes do cutover, use os caminhos literais acima. Depois de uma remocao aprovada, use o baseline/tag e o receipt do programa Documentation Lite v2. O Git permanece a camada final de recuperacao; nao recrie stubs nos caminhos antigos.
