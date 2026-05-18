# Mobile Universe — Pendencias De Design

- Ultima atualizacao: `2026-05-18`
- Status: `P1_CONCEITO`
- Objetivo: organizar as decisoes abertas para resolver uma por uma antes de transformar o conceito em producao.

---

## Ordem Recomendada

1. P01 — Character Autobattler PVP
2. P03 — Base Manager e economia
3. P04 — Amigos, guilda e ajudas sociais
4. P02 — Identidade do primeiro mago
5. P05 — Infraestrutura do produto mobile
6. P06 — Tema ficcional e mundo
7. P07 — Character Autobattler PVE
8. P08 — PVP Cardgame Roguelike
9. P09 — Hero Defense
10. P10 — Level Global e beneficios leves
11. P11 — Classes futuras de mago
12. P12 — Open World RPG como horizonte futuro
13. P13 — Lancamento e empacotamento
14. P14 — Transicao de conceito para producao

---

## P01 — Character Autobattler PVP

**Prioridade:** Alta

**Por que importa:** e o primeiro modo jogavel de combate e o lugar onde o poder gerado pela base vira resultado visivel.

**Decisoes ja tomadas:**
- o PVP faz parte do primeiro slice junto com Base Manager, amigos e guilda;
- o formato alvo e Arena Mobile Assincrona, usando Hero Wars como referencia principal;
- nao ha equipe de personagens: o jogador usa apenas um mago principal;
- a variedade inicial vem de arma, spells, passivas e skins;
- o PVP e um duelo simples contra outro jogador de poder semelhante;
- a apresentacao da batalha e sidescroller, inspirada em Mortal Kombat classico;
- deve haver defesa offline e matchmaking por poder semelhante;
- todo personagem tem finalizacoes brutais desbloqueaveis;
- ao vencer, o jogador assiste a finalizacao brutal escolhida;
- finalizacoes comecam como cosmeticos simples e podem evoluir depois para progressao e outras mecanicas;
- o PVP gera recursos bonus para o Base Manager;
- ao vencer PVP, o jogador ganha Almas;
- ao perder PVP, nao perde recursos, mas tambem nao recebe recompensa;
- a perda principal ao perder e tempo;
- o jogador pode batalhar indefinidamente;
- as recompensas reduzem conforme o jogador repete batalhas dentro de uma janela de tempo;
- em algum ponto, a recompensa chega a zero;
- mesmo com recompensa zerada, o jogador ainda pode batalhar.

**Pendencias:**
- definir a estrutura interna da batalha: turnos, tempo simulado, rodadas automaticas ou outra solucao;
- definir atributos principais do mago;
- definir como level up de arma, spells e passivas afeta a batalha;
- definir como arma e spells afetam ataques e habilidades;
- definir se skins sao cosmeticas ou tambem podem afetar gameplay;
- definir se finalizacoes sao apenas cosmeticas ou se tem alguma progressao associada;
- definir como o jogador escolhe a finalizacao antes/depois da batalha;
- definir duracao media de uma batalha;
- definir condicao de vitoria e derrota;
- definir se a simulacao roda no servidor, no cliente com validacao, ou em modelo hibrido;
- definir formula de poder para matchmaking;
- definir curva de reducao de recompensa ate zerar;
- definir janela de tempo para recuperar/resetar recompensas;
- definir quantidade e ritmo de ganho de Almas;
- definir como a progressao complexa do PVP se transforma na primeira versao do Base Manager/economia.

**Resolvido quando:** houver uma regra simples de batalha que possa ser simulada em papel ou prototipo, com entrada, processamento e resultado claros.

---

## P02 — Identidade Do Primeiro Mago

**Prioridade:** Alta

**Por que importa:** o escopo inicial ignora classes; entao o primeiro mago precisa carregar a fantasia, o visual e o gameplay do primeiro slice.

**Pendencias:**
- definir nome ou titulo provisorio do mago;
- definir aparencia e silhueta;
- definir tipo de magia principal;
- definir personalidade do personagem;
- definir arma, foco, artefato ou canalizador magico inicial;
- definir spells iniciais;
- definir ataques e habilidades iniciais ligados a arma e spells;
- definir direcao das skins;
- definir quais itens/pocoes/pets podem fazer sentido no futuro;
- definir progressao visual ou de poder.

**Resolvido quando:** o primeiro mago puder ser descrito em uma pagina com fantasia, gameplay, visual e progressao.

---

## P03 — Base Manager E Economia

**Prioridade:** Alta

**Por que importa:** a base e o hub permanente, a fonte de upgrades para o Character Autobattler e o centro de retencao do produto.

**Decisoes ja tomadas:**
- o Base Manager faz parte do primeiro slice;
- a referencia de entrega de upgrades e Hero Wars;
- a base/cidade deve ser uma tela com botoes animados, nao um grid onde o jogador escolhe onde construir.
- o plano de progressao complexo do PVP deve se transformar na primeira versao do Base Manager e da economia;
- o Base Manager tem recursos proprios;
- recebe Almas vindas das vitorias PVP;
- recebe ajudas vindas da guilda.
- o primeiro slice deve ter upgrades de 1 arma, 3 spells e 2 passivas;
- cada arma, spell e passiva inicial usa level up simples;
- no futuro podem existir outras armas, spells, passivas, recursos, pocoes, pets e arvore de upgrades mais elaborada.

**Pendencias:**
- definir quais estruturas, botoes ou edificios aparecem na tela inicial;
- definir recursos proprios do Base Manager alem de Almas, mas apenas depois de colocar os sistemas principais no lugar;
- definir timers, producao e upgrades;
- adiar itens, buffs, consumiveis, pocoes e pets ate os sistemas principais estarem no lugar;
- definir como a base cresce sem virar rotina vazia;
- definir limite diario ou ritmo de sessao;
- definir relacao entre base, jogador novo e jogador veterano;
- definir contribuicao da base para Level Global;
- definir custos de level up para 1 arma, 3 spells e 2 passivas;
- definir onde os upgrades de arma, spells e passivas aparecem na tela/base;
- definir como a progressao do PVP vira economia/base sem parecer dois sistemas separados.

**Resolvido quando:** existir um loop de base claro: construir, esperar/produzir, coletar, melhorar, equipar e voltar para batalha.

---

## P04 — Amigos, Guilda E Ajudas Sociais

**Prioridade:** Alta

**Por que importa:** amigos e guilda fazem parte do primeiro slice e criam a conexao social do ecossistema.

**Decisoes ja tomadas:**
- primeiro slice precisa ter lista de amigos e guilda;
- guilda pode enviar ajudas para o Base Manager;
- amigos/guilda inicialmente ajudam dando uma forca leve na evolucao, a "maozinha" social.

**Pendencias:**
- definir o que significa adicionar amigo;
- definir o que um amigo pode ajudar;
- definir o que e uma guilda no primeiro slice;
- definir tipos de ajuda da guilda;
- definir limites diarios/semanais de ajuda;
- definir se guilda gera recurso proprio;
- definir se guilda participa de ranking, missoes ou objetivos coletivos;
- definir como evitar que ajuda social quebre a economia.

**Resolvido quando:** houver uma regra simples para amigos, guilda e ajudas sociais dentro da economia da base.

## P05 — Infraestrutura Do Produto Mobile

**Prioridade:** Alta

**Por que importa:** o primeiro slice sera produto mobile com infraestrutura seria, nao um prototipo isolado.

**Pendencias:**
- definir requisitos de conta;
- definir persistencia local e cloud;
- definir backend minimo;
- definir dados que precisam ser autoritativos no servidor;
- definir matchmaking;
- definir ranking ou historico de batalhas, se houver;
- definir guilda, amigos e ajuda coletiva no primeiro slice;
- definir anti-cheat basico;
- definir telemetria minima;
- definir politica de falha offline/conexao ruim.

**Resolvido quando:** houver uma lista de servicos obrigatorios para o primeiro slice e o que fica fora dele.

---

## P06 — Tema Ficcional E Mundo

**Prioridade:** Media

**Por que importa:** "mago intergalatico maligno" e forte, mas ainda precisa de mundo, alvo, base e conflito.

**Decisoes ja tomadas:**
- o personagem e um mago intergalatico de uma civilizacao hiper avancada sem conexao direta com a realidade humana contemporanea;
- esses seres vivem de pura energia;
- eles nao precisam viajar fisicamente, apenas conhecer o lugar de destino;
- o grupo do personagem pertence a uma tradicao de magos caidos ha muito tempo;
- quase nada desse lore profundo sera explicado ao jogador no inicio;
- o primeiro arco narrativo pertence ao Character Autobattler PVE posterior;
- no PVE, o primeiro arco acompanha a ascensao do personagem em uma carreira hierarquica de magos, ate uma posicao equivalente a general, antes da rebeliao contra o mestre supremo e da aventura solo pelo espaco.

**Pendencias:**
- definir nome do projeto;
- definir nome do universo ou plano principal;
- definir o que e a base do mago;
- definir quem sao os inimigos ou rivais;
- definir por que magos batalham entre si;
- definir palavras melhores para a estrutura de carreira magica, evitando "guerreiro" e "militar" como termos finais;
- definir como as missoes iniciais sao entregues ao personagem;
- definir quem e o mestre supremo em termos funcionais, sem precisar detalhar toda a lore;
- definir que tipo de criatura, servo ou recurso existe;
- definir como o cartoon gore aparece sem depender de realismo;
- definir relacao com o canon Draxos, se houver.

**Resolvido quando:** o projeto tiver uma premissa ficcional curta que explique personagem, base, rivais e objetivo.

## P07 — Character Autobattler PVE

**Prioridade:** Media

**Por que importa:** e o modo futuro com conexao alta com Base Manager, missoes e primeira temporada narrativa.

**Decisoes ja tomadas:**
- o arco de missoes, carreira magica hierarquica, ascensao ate posicao equivalente a general, rebeliao contra o mestre supremo e aventura solo pelo espaco pertencem ao Character Autobattler PVE posterior, nao ao PVP do primeiro marco.
- o PVE e batalha automatica com botao de ultimate e 1 a 3 botoes de spell;
- e parecido com Hero Wars, mas com apenas um personagem.

**Pendencias:**
- decidir se e campanha/progressao linear, mapa de missoes, ou outro formato;
- decidir se usa o mesmo sistema do PVP ou uma variante;
- definir quais recompensas gera para a base;
- definir como o jogador aciona ultimate/spells;
- definir se serve como ponte para o Open World;
- definir quando o PVE passa a ser um modo upado junto com a base.

**Resolvido quando:** o Character Autobattler PVE tiver uma categoria unica, estrutura de missao e conexao clara com Base Manager.

---

## P08 — PVP Cardgame Roguelike

**Prioridade:** Media

**Por que importa:** e um modo futuro com progressao propria, mas ainda conectado levemente a conta/base.

**Decisoes ja tomadas:**
- e PVP cardgame roguelike;
- deve ter progressao propria;
- recebe apenas pequenos beneficios de Level Global e de uma base bem evoluida.

**Pendencias:**
- definir formato competitivo;
- definir o que significa a run roguelike;
- definir progressao propria do modo;
- definir quais pequenos beneficios recebe da conta/base;
- definir se entrega algum recurso de volta para a conta.

**Resolvido quando:** houver um loop proprio do cardgame e uma regra curta para sua conexao leve com conta/base.

---

## P09 — Hero Defense

**Prioridade:** Media

**Por que importa:** continua no roadmap como modo futuro com o mesmo mago em defesa contra hordas/tower defense.

**Decisoes ja tomadas:**
- usa o mesmo personagem principal;
- e um modo tower defense/defesa contra hordas;
- hordas atacam o mago;
- o jogador usa upgrades e botoes com cooldown;
- tem progressao propria;
- recebe apenas pequenos beneficios de Level Global e de uma base bem evoluida.

**Pendencias:**
- definir se o mago fica parado, se move, ou se protege uma posicao;
- definir tipos de hordas;
- definir upgrades durante a partida;
- definir botoes com cooldown;
- definir progressao propria;
- definir quais pequenos beneficios recebe da conta/base.

**Resolvido quando:** houver um loop claro de defesa contra hordas e uma regra curta para sua conexao leve com conta/base.

---

## P10 — Level Global E Beneficios Leves

**Prioridade:** Media

**Por que importa:** ele conecta tudo, mas precisa continuar leve para nao quebrar modos com progressao propria.

**Decisoes ja tomadas:**
- todos os modos contribuem para Level Global;
- PVP Cardgame Roguelike, Hero Defense e Open World RPG recebem apenas pequenos beneficios de Level Global/base.

**Pendencias:**
- definir como ganha XP global;
- definir quais bonus leves concede;
- definir limite de impacto em PVP;
- definir limite de impacto em modos com progressao propria;
- definir apresentacao visual ao jogador;
- definir se Level Global desbloqueia sistemas, cosmeticos ou apenas bonus.

**Resolvido quando:** Level Global tiver funcao clara e nao competir com base, itens ou meta-progressao dos modos.

---

## P11 — Classes Futuras De Mago

**Prioridade:** Baixa

**Por que importa:** classes podem existir no futuro, mas nao devem orientar o escopo inicial.

**Pendencias:**
- decidir se classes sao estilos, subclasses, escolas de magia ou especializacoes;
- decidir se alteram visual, itens, habilidades, cartas, base ou matchmaking;
- decidir se a troca de classe e livre, permanente ou desbloqueavel;
- decidir quando esse assunto volta para o roadmap.

**Resolvido quando:** houver uma regra curta dizendo o que uma classe de mago e, ou uma decisao formal de adiar.

---

## P12 — Open World RPG Como Horizonte Futuro

**Prioridade:** Baixa

**Por que importa:** e uma ambicao importante, mas pode distorcer a arquitetura cedo demais.

**Pendencias:**
- definir o minimo que precisa ser preservado para nao bloquear Open World futuro;
- definir o que nao deve ser construido agora;
- definir quais sistemas do Character Autobattler ou PVE podem ser reaproveitados;
- definir se personagem, criaturas e itens precisam de taxonomia comum.
- definir quais pequenos beneficios recebe de Level Global/base.

**Resolvido quando:** houver guardrails claros: preparar para evoluir, sem construir mundo aberto no primeiro marco.

---

## P13 — Lancamento E Empacotamento

**Prioridade:** Baixa agora

**Por que importa:** ainda nao existe decisao ou plano de lancamento, entao o documento nao deve assumir um formato falso.

**Decisoes ja tomadas:**
- ainda nao ha decisao de lancamento;
- ainda nao ha plano de temporada, expansao, apps separados ou formato comercial.

**Pendencias:**
- definir se sera um unico app com modos adicionados por updates;
- definir se "partes" significa temporadas, expansoes ou apps separados;
- definir como um jogador novo entende o produto se entrar depois de varios modos;
- definir se todos os modos aparecem no menu desde o inicio ou sao desbloqueados;
- definir como comunicar que a progressao e compartilhada.

**Resolvido quando:** houver uma frase operacional clara sobre como o produto sera lancado e expandido.

---

## P14 — Transicao De Conceito Para Producao

**Prioridade:** Alta antes de implementar

**Por que importa:** o projeto ainda e `P1_CONCEITO`, mas o primeiro marco exige infraestrutura, backend e produto mobile real.

**Pendencias:**
- definir criterio para sair de conceito;
- definir escopo do primeiro slice de producao: Character Autobattler PVP + Base Manager + amigos + guilda;
- definir tecnologia alvo;
- definir backend candidato;
- definir repositorio/local oficial fora de `_conceitos`, se aprovado;
- definir `AGENTS.md` local e `implementation/current-status.md`;
- atualizar `Prioridades_Estudio.md`, `Estado_Atual.md` e `Projetos/README.md` quando virar implementavel.

**Resolvido quando:** houver decisao formal de manter em conceito ou promover para projeto implementavel.
