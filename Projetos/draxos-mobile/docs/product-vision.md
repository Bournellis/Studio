# DraxosMobile - Product Vision

- Ultima atualizacao: `2026-05-28`
- Status: `LOCAL_PRODUCT_VISION - fonte viva do produto DraxosMobile`
- Escopo: direcao de longo prazo, limites de produto, plataforma, economia, social, live ops, backend e monetizacao.

---

## Tese Do Produto

DraxosMobile e um jogo mobile-first de progressao persistente onde o jogador construi um Draxos de poder crescente, administra um refugio, participa de batalhas assincronas e se conecta a outros jogadores por sistemas sociais leves.

O produto deve funcionar como um jogo de longo prazo: facil de abrir todos os dias, claro para evoluir em sessoes curtas, rico o bastante para gerar objetivos semanais e robusto o bastante para crescer em seasons sem reescrever a fundacao.

O jogador nao e o heroi. O jogador e um Draxos em ascensao.

## Situacao Atual

Etapa atual: `FOUNDATION_AUDIT_ACTIVE`.

O projeto ja tem uma base implementada com substancia suficiente para nao parecer um app vazio. A prioridade agora nao e adicionar conteudo, balancear combate ou consolidar tema final. A prioridade e auditar e refinar a experiencia do loop interno pos-login:

`Base -> coletar recursos -> evoluir base -> batalhar -> receber recompensas -> verificar base novamente`

Nesta etapa, nomes, spells, armas, numeros de economia, Battle Pass, visual final e apresentacao atual de batalha sao tratados como mock/substancia. Eles ajudam a sentir o produto, mas nao definem a direcao final.

Ordem de foco:

1. Loop interno pos-login.
2. Social.
3. Visual geral.
4. Apresentacao da batalha.
5. Armas, spells, economia, balanceamento e conteudo detalhado.

## Pilares

1. **Progressao persistente e legivel**: o jogador sempre entende o que ficou mais forte: personagem, instrumentos, spells, doutrinas, familiares, base, ranking ou economia.
2. **Batalha assincrona server-authoritative**: o servidor resolve combate, recompensa, ranking e economia; o cliente Godot anima replay, explica eventos e facilita decisao.
3. **Base como centro de rotina**: o Refugio concentra recursos, upgrades, filas, coletas, atalhos e proximo objetivo.
4. **Social leve, persistente e util**: amigos, guilda, chat, ajudas e ranking aumentam retencao sem exigir partida realtime.
5. **Economia testavel e auditavel**: fontes e gastos importantes devem ser rastreaveis; premium deve ser calibrado por dados e Progression Lab.
6. **Multiplataforma pragmatica**: Android e o canal primario; PC executavel e PC browser existem para teste, acessibilidade e operacao do alpha.

## Anti-Pilares

- Nao fazer mobile browser no primeiro ciclo.
- Nao fazer iOS sem decisao explicita.
- Nao depender de realtime competitivo para o core loop.
- Nao mover combate, recompensa, recurso ou ranking para autoridade do cliente.
- Nao copiar mecanicas de RPG Isometrico, RPG Turnos ou Draxos Roguelike Cardgame sem adocao local documentada.
- Nao prometer Open World, Hero Defense, PVE expandido ou Cardgame Roguelike mobile como parte do alpha atual.
- Nao construir monetizacao que torne a experiencia free inutil ou socialmente humilhante.
- Nao aceitar secrets, service role ou chaves privadas no cliente/export.

## Publico

Publico alvo inicial:

- jogadores que gostam de progresso persistente, rotina diaria e metas de medio prazo;
- jogadores que aceitam PVP assincrono, ranking e guilda sem precisar de controle em tempo real;
- jogadores que gostam de fantasia sombria/arcana com leitura mobile clara;
- testers internos capazes de dar feedback sobre ergonomia, clareza e ritmo de progressao.

O produto deve ser compreensivel para jogador casual de mobile, mas com camadas suficientes para quem gosta de otimizar build, base e economia.

## Plataforma

| Plataforma | Papel |
|---|---|
| Android | Produto primario e alvo de UX principal |
| PC executavel | Canal de teste, conforto e fallback para alpha |
| PC browser | Canal rapido para handoff, review e teste sem instalacao |
| iOS | Futuro possivel, sem compromisso atual |
| Mobile browser | Fora do escopo ate decisao explicita |

Todo fluxo essencial deve ser validado em Android antes de ser considerado pronto para audiencia maior.

## Core Loop

1. Entrar na conta.
2. Ver estado da base/refugio.
3. Coletar recursos.
4. Evoluir base.
5. Batalhar.
6. Receber recompensas.
7. Verificar a base novamente e sair com um proximo objetivo claro.

O loop deve funcionar em sessoes curtas. A Foundation Audit deve medir se as telas, icones, botoes, retornos e feedbacks tornam esse caminho obvio antes de qualquer expansao de conteudo.

## Economia E Progressao

Direcao longa, nao foco imediato:

- seasons podem subir caps e introduzir novos objetivos;
- levels permanentes sao preferidos para personagem, spells, base e sistemas centrais;
- Battle Pass, ranking, eventos e ofertas temporarias podem resetar por season;
- Diamante e a moeda premium alpha, mas sem pagamento real no alpha interno;
- redeems alpha existem para testar estados premium, nao para simular uma loja final;
- fila dupla, Battle Pass premium e pacotes de recurso sao instrumentos de calibragem.

Regras de maturidade:

- Toda mutacao economica importante deve passar por Edge Function, ledger e idempotencia.
- Premium gap deve ser medido por Progression Lab e rodada humana, cobrindo perfis free, freemium, light spender e max test.
- O free precisa continuar jogavel e socialmente valido.
- O max premium pode acelerar e revelar atrito, mas nao deve destruir matchmaking, ranking ou objetivo de medio prazo.

## Social E Competicao

Social deve comecar simples e confiavel, mas a proxima discussao social vem depois da auditoria do loop interno:

- identidade por conta;
- amigos por username;
- guilda;
- chat de guilda por polling;
- ranking visivel com top e posicao propria;
- bots fora de leaderboard publica por padrao;
- save `progression_lab` fora de ranking.

Evolucoes sociais devem nascer de feedback real. Ajudas, contribuicoes, moderacao, convites e administracao de guilda so avancam quando a rotina basica provar valor.

## Live Ops

Live ops deve ser uma capacidade gradual, nao uma promessa prematura.

Direcao possivel:

- seasons longas o suficiente para progressao real;
- dois Battle Passes por season como baseline inicial;
- eventos curtos para testar economia e retorno;
- manifest de update para cadencia controlada;
- conteudo versionado e contratos claros para evitar quebrar saves.

Antes de qualquer live ops mais ambicioso, o projeto precisa de telemetria, runbooks de publicacao, rollback pratico e criterio claro de reset/save migration.

## Backend E Infra

Supabase continua adequado para alpha porque entrega Auth, Postgres, Edge Functions, Storage e operacao simples.

Direcao de maturidade:

- manter contratos logicos do jogo independentes do vendor;
- preservar Backend Proprio + Postgres como plano de saida preferido;
- considerar Nakama apenas se realtime/lobbies/social competitivo virarem pilares reais;
- migrar `players.save_type` para `account_profiles` + `game_saves` apenas quando playtest ou escala justificarem;
- manter service role e secrets fora de cliente, export e repositorio.

## Monetizacao - Limites

Permitido explorar:

- Battle Pass premium;
- pacotes de recurso claros;
- conveniencias transparentes;
- fila extra;
- cosmeticos ou personalizacao futura;
- bundles alpha/future com preco e valor legiveis.

Evitar:

- loot boxes pagas com poder;
- paywall duro bloqueando o core loop free;
- venda direta que invalide matchmaking;
- vantagem social impossivel de responder;
- timers agressivos que punem ausencia curta;
- ofertas opacas ou manipulativas.

## Canon Local

Este documento e canon local de produto para DraxosMobile. Ele informa `docs/product-brief.md`, `docs/game-design-document.md`, `docs/architecture.md`, `docs/contracts/` e as tracks de implementacao.

O canon compartilhado em `../../canon/` informa lore, identidade Draxos e limites gerais do estudio. Ele ainda e majoritariamente orientado ao RPG Isometrico em produto/gameplay/plataforma; portanto, regras de RPG Isometrico nao sao aplicadas automaticamente aqui.

## Preservado Para Calibragem Futura

Os itens abaixo existem como substancia/mock e nao sao foco da Foundation Audit:

- ritmo de recursos e XP;
- premium gap;
- tamanho das janelas 15h/20h;
- poder de bots;
- pontos de ranking;
- clareza de onboarding fora do loop imediato;
- densidade do Hub no Android;
- frequencia de updates.

## Futuro Nao Prometido

- iOS;
- mobile browser;
- Open World;
- Hero Defense;
- PVE expandido;
- Cardgame Roguelike mobile;
- pagamentos reais;
- social realtime;
- guild wars;
- backend proprio em producao.

Esses itens podem virar projeto ou fase futura, mas nao devem ser tratados como divida do alpha atual.

## Gates De Proxima Decisao

1. Foundation Audit documental completa.
2. Auditoria do loop interno pos-login.
3. Decisao de hardening do loop.
4. Discussao social.
5. Discussao visual geral.
6. Discussao de apresentacao da batalha.
7. Somente depois, discussao de armas, spells, economia, premium gap, poder e bots.
