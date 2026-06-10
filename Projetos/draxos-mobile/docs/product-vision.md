# DraxosMobile - Product Vision

- Ultima atualizacao: `2026-06-09`
- Status: `LOCAL_PRODUCT_VISION - fonte viva do produto DraxosMobile`
- Escopo: direcao de longo prazo, limites de produto, plataforma, economia, social, live ops, backend e monetizacao.

---

## Tese Do Produto

DraxosMobile e um jogo mobile-first de progressao persistente onde o jogador construi um Draxos de poder crescente, administra um Refugio, vence Arenas PVE de duelos assincronos e, depois de entender build/poder/progresso, entra em PVP assincrono e sistemas sociais leves.

O produto deve funcionar como um jogo de longo prazo: facil de abrir todos os dias, claro para evoluir em sessoes curtas, rico o bastante para gerar objetivos semanais e robusto o bastante para crescer em seasons sem reescrever a fundacao.

O jogador nao e o heroi. O jogador e um Draxos em ascensao.

## Situacao Atual

Etapa operacional atual: `BOSQUE_ARENA_ABANDON_RECOVERY_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`.

Pacote remoto Internal Alpha atual: `Bosque Arena Abandon Recovery Authority v1`, release root `internal-alpha/v0-bosque-arena-abandon-recovery-authority-v1-20260610-a252241`, evidencia `https://b149da8f.draxos-mobile-internal-alpha.pages.dev`, portal oficial `https://draxos-mobile-internal-alpha.pages.dev/`, Web direto `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, versao `0.0.22-alpha.0`, version code `22`, minimum supported version code `13`.

Playtest humano inicial do pacote anterior, Bosque Bootstrap Authority v1, foi reportado OK por Fabio em 2026-06-09: tudo testado ate aquele momento parecia funcionar. `DMOB-D076` escolheu o launcher diegetico como etapa local, `DMOB-D077` foi resolvido pela publicacao Web/APK, `DMOB-D078` publicou o overlay persistente, `DMOB-D079` publicou o primeiro hotfix de navegacao, `Bosque Overlay Menu Action Authority v1` preservou botoes internos basicos, e o foco atual e playtest humano estreito do pacote publicado Bosque Arena Abandon Recovery Authority v1; bugs futuros voltam ao fluxo normal se aparecerem.

Direcao viva de produto: `PVE_ARENA_INITIAL_DIRECTION_APPROVED`, com Arena PVE
como core inicial do `Autobattler`. O estado operacional atual nao muda essa
direcao: Bosque Arena Abandon Recovery Authority v1 e o pacote publicado atual; Arena PVE segue
primeiro core; Bosque/Openworld e slice integrado de Internal Alpha, nao
autorizacao para expansao ampla de mundo, economia, conteudo ou visual final.

Atualizacao V1 de plataforma: DraxosMobile agora organiza sua visao jogavel em cinco modos oficiais governados por um registry unico: `Basebuilder`, `Autobattler`, `Towerdefense`, `Cardgame` e `Openworld`. A Arena PVE atual pertence ao `Autobattler`; Refugio/Base atuais pertencem ao `Basebuilder`; o antigo prototipo Rpgsuave foi renomeado de verdade para `Openworld`, com `forest` como primeiro slice e `Bosque` como entrada player-facing direta.

O projeto ja tem uma base implementada com substancia suficiente para nao parecer um app vazio. Foundation Closeout e Lab Track 16 Alignment anteciparam a fundacao de producao futura: `account_profiles/game_saves`, registry imutavel de ruleset, idempotencia com `request_hash`, admin minimo auditavel, shell/retry client e labs alinhados ao estado de pocoes/comportamento/crafting. Foundation Final Polish, Hardening Platform V1, Foundation Hardening V2, Openworld Main Menu Sync, Technical Hardening, Bosque v3 UX/Feel, Arena PVE First Real Run + Update Recovery, Arena Duel Flow Hotfix, Arena PVE Season 1 Loop v1, Arena/Bosque Regression Hotfix, Bosque Sync Responsiveness v1, Bosque Offline-First Checkpoint v1, Bosque Durable Bau Mochila v1, Bosque Fogueira Potion Crafting v1, Bosque World Hub Domain Separation v1, Bosque Session Lifecycle & Durable Structures Hotfix v1, Bosque Persistence Rebase v1, Bosque Feel & Spawn Authority v1, Bosque Resume Exit Lifecycle v1, Bosque Node Cooldown ACK v1, Arena PVE Bonus Visual v1, Bosque Bootstrap Authority v1, Bosque Overlay Navigation Hotfix v1 e Bosque Overlay Menu Action Authority v1 ficam como baselines historicas/tecnicas/conteudo preservadas; Bosque Arena Abandon Recovery Authority v1 e o pacote operacional publicado atual.

A decisao de produto seguinte foi escolhida em nivel de direcao: o early game deve ser uma Arena PVE inicial, sem cooldown de combate, com tutorial de 1 luta, primeiras arenas de 3 lutas, dificuldade escalavel, loadout travado antes da arena, vida resetada a 100% em cada duelo, buffs temporarios leves de stat entre lutas e comportamento ajustavel antes do proximo inimigo. A direcao viva esta em `docs/pve-arena-initial-direction.md`, e Track 23 publicou o primeiro pacote operacional para validar esse fluxo e o recovery de updates.

PVP deixa de ser o core inicial. Ele permanece planejado como modo posterior/competitivo, com bots apenas como fallback ou simulacao controlada enquanto nao houver playerbase suficiente.

O loop interno pos-login aceito continua como fundacao historica de app:

`Base -> coletar recursos -> evoluir base -> batalhar -> receber recompensas -> verificar base novamente`

Nesta etapa, nomes, spells, armas, numeros de economia, Battle Pass, visual final e apresentacao atual de batalha sao tratados como mock/substancia. Eles ajudam a sentir o produto, mas nao definem a direcao final.

Ordem de foco operacional:

1. Playtestar o pacote publicado `Bosque Arena Abandon Recovery Authority v1` em Web/APK, focando prompts/landmarks do Bosque, abertura de Arena/Base/Shop/Social/Profile, Social digitavel, Shop confirmavel, Arena retomar/abandonar e retorno via `Fechar`, `Voltar` e Esc.
2. Manter bugs futuros no fluxo normal de bugfix, sem reabrir regressao preventiva se nada novo aparecer.
3. Nao abrir tuning amplo, PVP, economia, conteudo, novas armas/spells, visual final, mutacoes remotas ou expansao de Openworld antes de uma nova decisao propria.
4. Depois do playtest do launcher, escolher explicitamente qualquer proximo pacote: bugfix, polish do launcher, Arena PVE, Openworld/Bosque estreito ou outro hardening.
5. PVP assincrono posterior, social, competicao, Towerdefense e Cardgame somente quando seus contratos proprios existirem.

## Pilares

1. **Progressao persistente e legivel**: o jogador sempre entende o que ficou mais forte: personagem, instrumentos, spells, doutrinas, familiares, base, Arena PVE, ranking ou economia.
2. **Modos oficiais em registry unico**: Basebuilder, Autobattler, Towerdefense, Cardgame e Openworld sao pilares de produto, nao atalhos de Labs.
3. **Arena PVE como core inicial do Autobattler**: o early game funciona sem playerbase, com listas curtas de inimigos, dificuldade escalavel, loadout travado, buffs temporarios de stat e duelos claros.
4. **Batalha assincrona server-authoritative**: o servidor resolve combate, recompensa, ranking e economia; o cliente Godot anima replay, explica eventos e facilita decisao.
5. **Basebuilder como centro de rotina**: o Refugio concentra recursos, upgrades, filas, coletas, atalhos e proximo objetivo.
6. **PVP como expansao competitiva**: PVP entra depois que Arena PVE, build e poder estiverem compreensiveis; bots sao fallback/simulacao, nao fundacao escondida.
7. **Social leve, persistente e util**: amigos, guilda, chat, ajudas e ranking aumentam retencao sem exigir partida realtime.
8. **Economia testavel e auditavel**: fontes e gastos importantes devem ser rastreaveis; premium deve ser calibrado por dados e Progression Lab.
9. **Multiplataforma pragmatica**: Android e o canal primario; PC executavel e PC browser existem para teste, acessibilidade e operacao do alpha.

## Anti-Pilares

- Nao fazer mobile browser no primeiro ciclo.
- Nao fazer iOS sem decisao explicita.
- Nao depender de realtime competitivo para o core loop.
- Nao depender de playerbase PVP para o early game funcionar.
- Nao usar cooldown de combate como controle principal da Arena PVE inicial.
- Nao mover combate, recompensa, recurso ou ranking para autoridade do cliente.
- Nao copiar mecanicas de RPG Isometrico, RPG Turnos ou Draxos Roguelike Cardgame sem adocao local documentada.
- Nao prometer Open World, Hero Defense, PVE expandido ou Cardgame Roguelike mobile como parte do alpha atual.
- Nao construir monetizacao que torne a experiencia free inutil ou socialmente humilhante.
- Nao aceitar secrets, service role ou chaves privadas no cliente/export.

## Publico

Publico alvo inicial:

- jogadores que gostam de progresso persistente, rotina diaria e metas de medio prazo;
- jogadores que gostam de listas de duelos PVE, dificuldade escalavel e preparacao de build;
- jogadores que aceitam PVP assincrono, ranking e guilda como expansao competitiva sem precisar de controle em tempo real;
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
3. Entrar na Arena PVE inicial.
4. Travar loadout.
5. Vencer uma lista curta de duelos.
6. Escolher buffs temporarios leves de stat entre lutas.
7. Ajustar comportamento antes do proximo inimigo.
8. Receber recompensas.
9. Evoluir base/build.
10. Voltar para uma arena mais dificil ou maior.

O loop deve funcionar em sessoes curtas. A Arena PVE inicial deve permitir jogar sem cooldown de combate; a economia deve controlar recompensa por primeira vitoria, recorde, conclusao, dificuldade, bonus diario/semanal e repeticao reduzida.

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
- Arena PVE deve ser a primeira fonte calibrada de XP, recursos, poder esperado e progresso de base.
- Premium gap deve ser medido por Progression Lab e rodada humana, cobrindo perfis free, freemium, light spender e max test.
- O free precisa continuar jogavel e socialmente valido.
- O max premium pode acelerar e revelar atrito, mas nao deve destruir matchmaking, ranking ou objetivo de medio prazo.

## Social E Competicao

Social deve comecar simples e confiavel, mas a proxima expansao social vem depois da Arena PVE inicial ter rotina e tuning compreensiveis:

- identidade por conta;
- amigos por username;
- guilda;
- chat de guilda por polling;
- ranking visivel com top e posicao propria quando PVP/competicao voltar ao foco;
- bots fora de leaderboard publica por padrao, salvo se forem marcados claramente como inimigos/simulacoes PVE;
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
- tratar `account_profiles` + `game_saves` como fundacao ja antecipada pela Foundation Expansion Readiness/Closeout; `players.save_type` fica apenas como compatibilidade alpha;
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
- campanha PVE tradicional com mapa/cutscenes/assets pesados;
- Cardgame Roguelike mobile;
- pagamentos reais;
- social realtime;
- guild wars;
- backend proprio em producao.

Esses itens podem virar projeto ou fase futura, mas nao devem ser tratados como divida do alpha atual.

## Gates De Proxima Decisao

1. Rodar playtest humano do pacote publicado `Bosque Arena Abandon Recovery Authority v1`, incluindo Social typing/actions, Shop cancel/confirm e Arena retomar/abandonar.
2. Confirmar se bugs novos apareceram no launcher diegetico publicado; se aparecerem, tratar por bugfix estreito.
3. Se o pacote escolhido for Arena PVE, confirmar que `docs/pve-arena-initial-direction.md` e `docs/pve-arena-v1.md` continuam suficientes para tutorial, primeiras arenas, inimigos, buffs, recovery e recompensas.
4. Rodar Progression Lab e Battle Lab orientados a Arena PVE antes de mexer em valores calibraveis, se Arena PVE for o pacote escolhido.
5. Implementar pacote pequeno de tuning/UX somente depois da decisao explicita do proximo pacote.
6. Reintroduzir PVP como modo posterior/competitivo depois que o core PVE estiver claro.
