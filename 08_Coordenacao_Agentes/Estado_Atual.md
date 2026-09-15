# Estado Atual - Estudio

## Metadata

- status: `active`
- authority: `portfolio_snapshot`
- last_verified: `2026-09-15`
- review_when: `PortfolioSync_QUEUE has a pending local baseline change`
- supersedes: `none`
- superseded_by: `none`

- Ultima atualizacao: `2026-09-15`
- Autoridade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Natureza: projecao curta; estados tecnicos locais vivem em `implementation/current-status.md`.
- Painel Fabio local: `08_Coordenacao_Agentes/FABIO_DASHBOARD.html`
- Indice global de documentacao: `08_Coordenacao_Agentes/documentation-index.md`
- Regra de tamanho: maximo ~12 linhas por projeto. Historia vai para `implementation/history.md`, history ledgers e, para pacotes, `docs/release-history.md`; nunca para este snapshot.

## Prioridade Do Estudio

Todos os seis jogos estão PAUSADO_INDEFINIDO por decisão de Fabio em 2026-09-15.
Somente MMORPG, no repositório D:/Studio/Projetos/MMORPG, permanece ativo.
Resultados, baselines e gates abaixo são preservados; não são novos testes.

## JogoDaCopa

- Status: `PAUSADO_INDEFINIDO`; trabalhos e gates anteriores preservados, sem execução.
- Marker: `JOGO_DA_COPA_TRACK10D_HUMAN_APPROVED`
- Release aprovada: Track 10D; linhagem e fallbacks vivem somente em `Projetos/JogoDaCopa/docs/release-history.md`.
- Baseline local: governanca local-first e QA tipada; Runtime `108/108`, `1.844 asserts`, sem side effects.
- Gates humanos preservados: feel, camera, audio, visual e publicacao.
- Trabalho permitido: preservação e consulta seletiva para objetivo MMORPG autorizado.
- Proximo passo: nenhum; retomada somente por pedido explícito de Fabio.

## draxos-roguelike-cardgame

- Status: `PAUSADO_INDEFINIDO`; trabalhos e gates anteriores preservados, sem execução.
- Baseline: Track 02 `T02-P09_COMPLETE`, rota `29/29`, save v5 e tres classes.
- Validacao local: `226/226`, `1.975 asserts`; labs continuam evidencias, nao autoridade de produto.
- Gates em Review: promocao Design Lab, balance e sensacao da run.
- Trabalho permitido: preservação e consulta seletiva para objetivo MMORPG autorizado.
- Proximo passo: nenhum; retomada somente por pedido explícito de Fabio.

## DraxosMobile

- Status: `PAUSADO_INDEFINIDO`; trabalhos e gates anteriores preservados, sem execução.
- Marker: `ARENA_WEB_STATIC_ASSETS_HOTFIX_V1_HUMAN_APPROVED`
- Release aprovada: `0.0.27-alpha.0` / vc `27`; linhagem vive somente em `Projetos/draxos-mobile/docs/release-history.md`.
- Resultado Arena PVE preservado: `ARENA_CORE_NEEDS_UX_FIX` + `ARENA_CORE_NOT_PROVEN`.
- Baseline local: cliente `287/287` e `4.208 asserts`; server `128 + 23`; modos `49`; `ReleaseDryRun` verde.
- Guardrails: autoridade server-side, idempotencia, RLS, Track 13 e Track 14; nenhum remoto ou publicacao automatica.
- Proximo passo: nenhum; retomada somente por pedido explícito de Fabio.

## FpsPlayground

- Status: `PAUSADO_INDEFINIDO`; trabalhos e gates anteriores preservados, sem execução.
- Marker: `FPS_PLAYGROUND_TRACK14I_HUMAN_APPROVED`
- Baseline: Track 14I aprovada; gameplay Track 14H, movimento, jump pads, mapas e bot route-control preservados.
- Validacao local: governanca local-first e QA tipada; Runtime `67/67`, `599 asserts`, sem side effects.
- Gates humanos preservados: movimento, armas, fairness do bot, mapas e tuning.
- Trabalho permitido: preservação e consulta seletiva para objetivo MMORPG autorizado.
- Proximo passo: nenhum; retomada somente por pedido explícito de Fabio.

## rpg-isometrico

- Status: `PAUSADO_INDEFINIDO`; trabalhos e gates anteriores preservados, sem execução.
- Canon de produto local: `Projetos/rpg-isometrico/docs/canon/`.
- Baseline preservada: B0 interno; Runtime `63/63`, `1.310 asserts`; geracao de cenas byte-estavel.
- Trabalho permitido: preservação e consulta seletiva para objetivo MMORPG autorizado.
- Proximo passo: nenhum; retomada somente por pedido explícito de Fabio.

## rpg-turnos

- Status: `PAUSADO_INDEFINIDO`; trabalhos e gates anteriores preservados, sem execução.
- Baseline reparada: P20 completo, tres classes, 13 encontros e save v1→v2 puro e deterministico.
- Validacao local: `249/249`, `954 asserts`; automacao verde, playabilidade humana nao revalidada.
- Trabalho permitido: preservação e consulta seletiva para objetivo MMORPG autorizado.
- Proximo passo: nenhum; retomada somente por pedido explícito de Fabio.

## Kanban Rapido

- Backlog / Doing / Review / Done: `08_Coordenacao_Agentes/Kanban/`
- Handoffs: `08_Coordenacao_Agentes/Handoffs/`
- Decisoes: `08_Coordenacao_Agentes/Decisoes/`

## Canon

- Ponte para a autoridade compartilhada externa: `../STUDIO_CORE.md`; cada projeto declara seu vínculo em `STUDIO_CORE.md` local.
