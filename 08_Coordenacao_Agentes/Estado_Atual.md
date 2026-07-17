# Estado Atual - Estudio

## Metadata

- status: `active`
- authority: `portfolio_snapshot`
- last_verified: `2026-07-17`
- review_when: `PortfolioSync_QUEUE has a pending local baseline change`
- supersedes: `none`
- superseded_by: `none`

- Ultima atualizacao: `2026-07-16`
- Autoridade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Natureza: projecao curta; estados tecnicos locais vivem em `implementation/current-status.md`.
- Painel Fabio local: `08_Coordenacao_Agentes/FABIO_DASHBOARD.html`
- Indice global de documentacao: `08_Coordenacao_Agentes/documentation-index.md`
- Regra de tamanho: maximo ~12 linhas por projeto. Historia vai para `implementation/history.md`, history ledgers e, para pacotes, `docs/release-history.md`; nunca para este snapshot.

## Prioridade Do Estudio

- Ativo: `Projetos/JogoDaCopa/` — Track 10D aprovada; Track 10A preservada como fallback.
- Ativo: `Projetos/draxos-mobile/` — Web Static Assets Hotfix v1 aprovada; Arena core ainda sem prova humana.
- Ativo: `Projetos/FpsPlayground/` — Track 14I aprovada; movimento atual preservado.
- Pausa temporaria: `Projetos/draxos-roguelike-cardgame/`.
- Pausa indefinida: `Projetos/rpg-isometrico/` e `Projetos/rpg-turnos/`.
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`.

## JogoDaCopa

- Status: `P2_IMPLEMENTACAO - TRACK10D_HUMAN_APPROVED`
- Marker: `JOGO_DA_COPA_TRACK10D_HUMAN_APPROVED`
- Release aprovada: Track 10D; linhagem e fallbacks vivem somente em `Projetos/JogoDaCopa/docs/release-history.md`.
- Baseline local: governanca local-first e QA tipada; Runtime `108/108`, `1.844 asserts`, sem side effects.
- Gates humanos preservados: feel, camera, audio, visual e publicacao.
- Trabalho permitido: codigo, design, validacao, playtest no editor e documentacao local.
- Proximo passo: decidir a proxima etapa de `JogoDaCopa`: continuar reducoes locais conservadoras ou abrir nova melhoria de feel/polish.

## draxos-roguelike-cardgame

- Status: `PAUSADO_TEMPORARIO`; governanca e QA nao retomam produto.
- Baseline: Track 02 `T02-P09_COMPLETE`, rota `29/29`, save v5 e tres classes.
- Validacao local: `226/226`, `1.975 asserts`; labs continuam evidencias, nao autoridade de produto.
- Gates em Review: promocao Design Lab, balance e sensacao da run.
- Trabalho permitido: consulta historica e retomada somente por pedido explicito.
- Proximo passo: escolher candidatos Wave 01 para promocao manual e priorizar suporte real para mecanicas bloqueadas.

## DraxosMobile

- Status: `P2_IMPLEMENTACAO`; Web Static Assets Hotfix v1 aprovada; Arena core ainda sem prova humana.
- Marker: `ARENA_WEB_STATIC_ASSETS_HOTFIX_V1_HUMAN_APPROVED`
- Release aprovada: `0.0.27-alpha.0` / vc `27`; linhagem vive somente em `Projetos/draxos-mobile/docs/release-history.md`.
- Resultado Arena PVE preservado: `ARENA_CORE_NEEDS_UX_FIX` + `ARENA_CORE_NOT_PROVEN`.
- Baseline local: cliente `287/287` e `4.208 asserts`; server `128 + 23`; modos `49`; `ReleaseDryRun` verde.
- Guardrails: autoridade server-side, idempotencia, RLS, Track 13 e Track 14; nenhum remoto ou publicacao automatica.
- Proximo passo: Fabio/tester executar a prova humana do roteiro Arena seguindo `docs/arena-pve-product-proof.md`; registrar veredito antes de tuning, economia, PVP, conteudo novo, visual final ou expansao Openworld.

## FpsPlayground

- Status: `P2_IMPLEMENTACAO - TRACK14I_HUMAN_APPROVED`
- Marker: `FPS_PLAYGROUND_TRACK14I_HUMAN_APPROVED`
- Baseline: Track 14I aprovada; gameplay Track 14H, movimento, jump pads, mapas e bot route-control preservados.
- Validacao local: governanca local-first e QA tipada; Runtime `67/67`, `599 asserts`, sem side effects.
- Gates humanos preservados: movimento, armas, fairness do bot, mapas e tuning.
- Trabalho permitido: codigo, design, validacao, playtest no editor e documentacao local.
- Proximo passo: executar `Multi-Arena Balance Baseline V1` antes de novas armas, buffs, mapas, tuning ou bot intelligence.

## rpg-isometrico

- Status: `PAUSADO_INDEFINIDO`; sem track ou gate humano ativo.
- Canon de produto local: `Projetos/rpg-isometrico/docs/canon/`.
- Baseline preservada: B0 interno; Runtime `63/63`, `1.310 asserts`; geracao de cenas byte-estavel.
- Trabalho permitido: consulta historica com pedido explicito; nao implementar nem expandir escopo.
- Proximo passo: nenhum enquanto pausado.

## rpg-turnos

- Status: `PAUSADO_INDEFINIDO`; sem proxima track.
- Baseline reparada: P20 completo, tres classes, 13 encontros e save v1→v2 puro e deterministico.
- Validacao local: `249/249`, `954 asserts`; automacao verde, playabilidade humana nao revalidada.
- Trabalho permitido: consulta historica com pedido explicito; nao implementar, nao regenerar `.tres`.
- Proximo passo: nenhum enquanto pausado.

## Kanban Rapido

- Backlog / Doing / Review / Done: `08_Coordenacao_Agentes/Kanban/`
- Handoffs: `08_Coordenacao_Agentes/Handoffs/`
- Decisoes: `08_Coordenacao_Agentes/Decisoes/`

## Canon

- Fonte compartilhada estavel: `canon/` (brief rapido: `canon/canon-brief.md`)
