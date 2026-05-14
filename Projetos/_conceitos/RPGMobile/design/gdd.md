# RPGMobile - Game Design Document

- Last Updated: `2026-05-14`
- Status: `P1_CONCEITO - core gameplay definido`

---

## 1. Estado Atual

RPGMobile esta em incubacao conceitual.

O projeto agora sera definido primeiro por gameplay, game feel, progressao, exploracao e loot. Lore, historia principal e mundo ficcional detalhado devem vir depois, quando o core jogavel estiver mais claro.

O lore anterior do RPGMobile foi removido e nao deve ser tratado como base. O canon geral do Estudio permanece preservado fora deste projeto e nao e importado automaticamente.

---

## 2. Fantasia De Jogo

RPGMobile e um RPG mobile de acao em tempo real sobre entrar em um mundo aberto, explorar muito, lutar muito, se mover com velocidade, coletar loot no campo e sentir que o mapa cresce conforme o personagem fica mais forte.

O jogo nao e sobre escolher uma classe antes de jogar e ficar preso a essa decisao. Tambem nao e sobre passar tempo em menus, timers, construcao de base, upgrades irrelevantes ou gerenciamento complexo de inventario.

O prazer central deve ser:

```text
explorar -> encontrar inimigos e recursos -> lutar -> pegar loot -> ficar mais forte -> abrir areas novas
```

---

## 3. Principios Centrais

- Nao existe classe inicial.
- Nao existe pre-selecao que bloqueie opcoes futuras de arma, spell ou estilo de jogo.
- O jogador deve poder usar qualquer arma e qualquer spell, salvo excecoes especificas de design futuro.
- A progressao deve incentivar investimento sem impedir experimentacao.
- Trocar para uma arma ou spell pouco treinada reduz poder temporariamente, porque a maestria daquele item e menor.
- O jogo deve tirar o jogador dos menus e coloca-lo em acao.
- Ganhar coisas significa explorar, lutar, matar criaturas, abrir bau, coletar recursos e vencer desafios no mundo.
- Missoes existem, algumas com historias proprias, mas a historia mainline nao e o foco.
- O mundo deve parecer expansivo: quanto mais o jogador explora e progride, mais areas ficam disponiveis.

---

## 4. Mundo Aberto E Exploracao

O jogo deve dar sensacao de mundo aberto em crescimento continuo.

O mapa nao precisa estar todo disponivel desde o inicio. Areas novas sao liberadas por progressao, grind, forca do personagem, descoberta, chaves, recursos, bosses ou requisitos similares.

Cada area nova deve trazer:

- criaturas novas;
- criaturas mais fortes;
- mecanicas ou perigos novos;
- recursos mais raros;
- loot melhor;
- quests locais;
- pequenas historias ou conflitos proprios;
- motivos para voltar depois, quando o personagem estiver mais forte.

Exploracao e luta devem andar juntas. O jogador anda rapido, encontra inimigos com frequencia, luta, pega recompensas e continua se movendo.

---

## 5. Foco Narrativo

Baixo foco em historia mainline.

O jogo pode ter missoes, personagens, eventos e pequenas narrativas por area, mas eles servem para enriquecer o mundo, nao para transformar o jogo em campanha linear.

Regra de direcao:

- lore vem depois do core;
- historia deve apoiar exploracao e combate;
- quests devem mandar o jogador para o mundo, nao prende-lo em dialogos longos;
- cada area pode ter sua propria pequena historia;
- nenhuma historia deve bloquear a fantasia principal de explorar, lutar e crescer.

---

## 6. Setup Mobile

### Camera

- Tela travada com o personagem no centro.
- Camera fixa/top-down ou levemente inclinada.
- O mundo se move ao redor do jogador.

### Lado Esquerdo

- Joystick virtual de movimentacao.

### Lado Direito

O lado direito concentra todas as acoes de combate:

- ataque basico;
- spell de movimentacao;
- 3 spells de combate;
- pocao, se nao for automatica.

Direcao preferida atual:

```text
Ataque basico + Movimento da arma + 3 spells de combate
```

A pocao esta em investigacao. Pode ser automatica para reduzir carga de botao e manter o foco em movimento e combate.

---

## 7. Loadout De Acao

O jogador equipa:

```text
1 arma + 3 spells
```

A arma define:

- ataque basico;
- spell de movimentacao;
- ritmo de combate;
- alcance;
- identidade de gameplay;
- parte importante do game feel.

As 3 spells de combate definem o complemento do estilo de jogo. Elas podem causar dano, controlar inimigos, proteger, aplicar status, invocar, curar, agrupar, explodir area ou ate incluir movimento secundario.

Nao existe uma divisao fundamental como classe. A build nasce da combinacao entre arma, movimento da arma e spells escolhidas.

---

## 8. Armas E Movimento

Movimentacao especial deve ser presa a arma.

Isso faz cada arma ter gameplay caracteristica. Trocar de arma nao troca apenas numeros: troca tambem como o jogador atravessa o combate.

Exemplos de identidade possivel:

- espada rapida: dash curto agressivo;
- martelo pesado: salto ou investida com impacto;
- arco: recuo ou reposicionamento evasivo;
- cajado: teleporte curto ou blink;
- adagas: avanco duplo entre inimigos;
- rifle: rolamento tatico.

Esses exemplos nao sao conteudo aprovado; apenas demonstram o principio.

---

## 9. Maestria Por Uso

Armas e spells devem ter progressao propria por uso.

Usar uma arma aumenta a maestria dessa arma. Usar uma spell aumenta a maestria dessa spell.

Maestria pode influenciar:

- dano;
- cooldown;
- custo;
- alcance;
- tamanho de area;
- efeitos adicionais;
- chance de efeitos especiais;
- desbloqueio de modificadores simples.

O jogador pode trocar para qualquer arma ou spell disponivel, mas se ela estiver pouco treinada, ficara temporariamente mais fraco com ela. Isso cria compromisso sem bloquear liberdade.

Regra de intencao:

- escolha livre;
- investimento recompensado;
- troca possivel;
- poder recuperado jogando, nao pagando menu.

---

## 10. Level, Stats, Itens E Loot

O jogo pode ter:

- level de personagem;
- stats;
- armas;
- spells;
- equipamentos;
- itens consumiveis;
- recursos;
- raridade de loot;
- upgrades simples;
- craft ou melhoria, se nao roubar foco da acao.

Mas a regra e manter tudo legivel.

O jogador nao deve precisar ficar comparando dezenas de atributos complexos para decidir se pode continuar jogando. As escolhas devem ser rapidas, claras e com bom default.

Direcao de UX:

- loot aparece no campo;
- recompensas vem de combate e exploracao;
- menus existem para equipar, ver progresso e ajustar build;
- menus nao devem virar o jogo;
- evitar upgrades inuteis criados so para clique, timer ou rotina.

---

## 11. O Que O Jogo Nao Deve Ser

RPGMobile nao deve ser:

- jogo de classe fixa;
- jogo em que a primeira escolha trava o futuro do personagem;
- jogo de menu e timer;
- jogo de cuidar de base/casinha como obrigacao central;
- auto-battle;
- campanha linear disfarcada de mundo aberto;
- RPG onde o jogador passa mais tempo comparando item do que lutando;
- sistema de upgrade cheio de passos irrelevantes;
- progressao baseada em esperar tempo real para clicar de novo.

---

## 12. Loop Principal

Loop atual:

```text
Entrar no mundo
-> mover rapido pela area
-> encontrar inimigos, recursos e eventos
-> lutar usando ataque basico, movimento da arma e 3 spells
-> pegar loot no campo
-> ganhar XP, recursos, itens e maestria
-> melhorar personagem e build
-> desbloquear area nova
-> repetir com inimigos, mecanicas e recompensas mais fortes
```

O loop precisa funcionar mesmo quando a quest atual nao importa. A luta e a exploracao devem sustentar a sessao por si mesmas.

---

## 13. Missoes E Areas

Missoes existem para dar direcao, recompensas e pequenas historias.

Tipos possiveis:

- matar criatura especifica;
- limpar ninho ou acampamento;
- explorar area perigosa;
- derrotar chefe local;
- coletar recurso raro;
- proteger NPC em deslocamento;
- ativar ponto de mapa;
- investigar evento;
- liberar passagem para area nova.

As missoes devem levar o jogador para combate e exploracao. Dialogo, cutscene e texto devem ser curtos no core mobile.

---

## 14. Progressao De Mundo

O mundo cresce conforme o jogador joga.

Formas possiveis de liberar areas:

- level minimo recomendado;
- derrotar chefe de area;
- encontrar chave ou item de acesso;
- acumular recurso raro;
- completar conjunto curto de quests locais;
- sobreviver a evento de fronteira;
- melhorar ferramenta de travessia;
- atingir poder suficiente para atravessar zona perigosa.

O grind deve existir, mas precisa gerar jogo: matar monstros, explorar, dominar area, coletar materiais e melhorar build.

---

## 15. Questoes Em Aberto

- O jogo tera 3 ou 4 spells de combate alem do ataque basico e movimento?
- A pocao sera automatica, semi-automatica ou botao manual?
- Como o loot sera coletado: auto-pickup, toque, magnetismo ou mistura?
- Quantas armas iniciais sao necessarias para provar o core?
- Quantas spells iniciais dao variedade sem explodir escopo?
- Como evitar que troca de build seja punitiva demais?
- Como apresentar item melhor sem exigir comparacao complexa?
- O mundo principal sera cidade gigante, regiao selvagem, submundo, arquipelago, torre, planeta fechado ou outra estrutura?

---

## 16. Proximos Passos

- [ ] Definir 3 armas iniciais e o movimento unico de cada uma.
- [ ] Definir 8 a 12 spells iniciais.
- [ ] Escolher entre 3 ou 4 spells de combate no layout final.
- [ ] Decidir regra inicial de pocao automatica/manual.
- [ ] Definir modelo simples de maestria por uso.
- [ ] Definir modelo simples de loot no campo.
- [ ] Definir primeira area jogavel conceitual com criaturas, recursos e desbloqueio de proxima area.
