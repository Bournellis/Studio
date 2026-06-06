# DraxosMobile - Arena PVE Menu Flow Simplification v1

- Status: `IMPLEMENTED_LOCAL`
- Data: `2026-06-06`
- Decisao-base: `ARENA_PVE_MENU_FLOW_SIMPLIFICATION_V1`
- Escopo: simplificar o fluxo visual/operacional dos menus de Arena PVE mantendo as funcoes existentes, sem abrir tuning, novas arenas, novos buffs, PVP, economia final ou battle presentation.

## Objetivo

Arena PVE Menu Flow Simplification v1 corrige a leitura do menu apos o playtest de Bosque Offline-First Checkpoint v1:

- reduz CTAs redundantes na selecao de Arena;
- coloca a informacao na ordem de decisao do jogador;
- preserva Preparacao antes de iniciar e comportamento entre duelos;
- deixa tentativa ativa e escolha de buff com acao principal visivel antes de controles secundarios;
- mantem Season 1 Loop v1, Duel Flow Hotfix e todas as garantias de recompensa server-authoritative.

## Hierarquia De Menu

### Selecao normal

Ordem esperada:

1. texto curto de contexto;
2. progresso da Temporada 1;
3. desafio recomendado com CTA unico `Iniciar desafio recomendado`;
4. painel de Preparacao;
5. `Outras arenas` agrupadas por arena/dificuldade;
6. `Voltar ao Refugio`.

O desafio recomendado nao aparece de novo como botao dentro do grupo de dificuldades. O grupo mostra a linha `recomendado acima`, preservando informacao sem duplicar a acao.

### Tentativa ativa ou travada

Ordem esperada:

1. aviso de tentativa aberta;
2. painel de retomada/recuperacao da tentativa;
3. Preparacao em modo comportamento;
4. acoes de retomar/encerrar/voltar conforme o estado.

Nao ha lista de novas arenas enquanto existe tentativa aberta.

### Menu ativo entre duelos

Ordem esperada:

1. progresso da tentativa e resumo;
2. CTA principal `Resolver duelo` ou `Escolher buff`;
3. Preparacao em modo comportamento;
4. detalhes do loadout travado;
5. abandonar/voltar.

O loadout continua travado apos iniciar a tentativa. Preparacao dentro do fluxo ativo serve para comportamento simples entre duelos.

### Escolha de buff

Ordem esperada:

1. cards comparaveis de buff;
2. Preparacao em modo comportamento;
3. abandonar tentativa.

Se nao houver buff pendente, o menu mostra `Retomar tentativa` antes dos controles secundarios.

## Guards

Atualizados em `tests/client/test_boot_mobile_ui.gd`:

- selecao por arenas continua data-driven;
- o botao duplicado `Iniciar proximo desta arena` nao aparece;
- Season progress aparece antes do recomendado;
- recomendado aparece antes de Preparacao;
- Preparacao aparece antes dos grupos de outras arenas;
- tentativa ativa/recuperacao aparecem antes de comportamento;
- `Resolver duelo` e `Escolher buff` aparecem antes de `Carregar comportamento`;
- escolha de buff mostra os cards antes de comportamento.

## Fora De Escopo

- Novo conteudo de Arena.
- Tuning numerico, drop, economia ou recompensas.
- Novos buffs ou comportamento avancado.
- Refatoracao de backend da Arena.
- Mudancas em Bosque/Openworld alem de regressao preservada.

## Validacao

Validacao local inicial:

- GUT client suite: PASS, 236 tests and 3741 asserts. GUT ainda reporta warnings conhecidos de teardown orphan/ObjectDB.

Publicacao remota:

- Pendente ate merge em `main` e publicacao Web/APK autorizada.
