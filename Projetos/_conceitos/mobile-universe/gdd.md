# DraxosMobile — Game Design Document

- Ultima atualizacao: `2026-05-18`
- Status: `ARQUIVO_DESIGN` — promovido para `Projetos/draxos-mobile/` em 2026-05-18
- Substitui: `RPGMobile`, `BattleMobile`
- Projeto ativo: `Projetos/draxos-mobile/` — este arquivo e somente leitura e referencia de design

---

## 1. Visao Do Projeto

DraxosMobile e um projeto mobile multi-partes. Os modos serao implementados ao longo do tempo, mas ainda nao existe decisao de lancamento, ordem comercial, formato de temporadas, expansoes ou separacao por apps.

Todos os modos pertencem a um unico ecossistema com conta, personagem, base e progressao conectadas. O Base Manager e a fundacao que conecta os modos, mas cada modo pode ter intensidade diferente de ligacao com a base.

O primeiro slice nao e tratado como prototipo isolado. Ele deve conter Character Autobattler PVP, Base Manager, pet, lista de amigos e guilda, com infraestrutura seria desde o inicio: conta, persistencia, progressao compartilhada, backend para batalha assincrona, matchmaking por poder semelhante e base para recursos sociais.

---

## 2. Fantasia Central

O jogador e um Draxos — mago intergalactico malvado — que comeca fraco e cresce em poder ate se tornar uma ameaca cosmica.

O jogador nao e o heroi. O jogador e o vilao.

**Raca:** Draxos. O nome do personagem e definido pelo jogador.

Referencias de estetica e personalidade: Sauron, Palpatine, Darth Vader, Morgott.

**Estilo visual:** gore, sangue e violencia em estilo cartoon e animado. Sem realismo. Estilo artistico especifico ainda pendente de definicao.

### 2.1 Lore De Fundo

O personagem pertence a uma civilizacao hiper avancada, nada conectada com a realidade humana contemporanea. Esses seres vivem de pura energia. Eles nao precisam viajar fisicamente: basta conhecerem o lugar para onde querem ir.

O grupo ao redor do personagem pertence a uma tradicao de magos caidos ha muito tempo.

Os Draxos batalham entre si por ambicao e recursos — duelos sao a forma legitima de disputar poder, recursos e posicao dentro da sociedade Draxos.

Esse lore profundo existe como base de direcao, mas quase nada disso deve ser explicado ao jogador no inicio.

### 2.2 Hierarquia Draxos

Pendente de definicao. Nao faz parte do primeiro slice.

---

## 3. O Personagem

O Draxos e o personagem central em todos os modos. Nao existem classes — todos os jogadores tem acesso a todas as armas, spells, passivas e pets. A diferenciacao entre jogadores vem do que cada um escolheu upar.

### 3.1 Visual Base

- Silhueta: forma vultuosa, manto comprido, etereo e energetico
- Estilo artistico: pendente de definicao

### 3.2 Level e Experiencia

O personagem possui um Level Global que cresce via Experiencia. O Level afeta os stats base diretamente e e a referencia para desbloqueios gerais do jogo.

Fontes de Experiencia:
- Vencer batalhas PVP — recompensa completa
- Perder batalhas PVP — 1/5 da recompensa de vitoria
- Completar construcoes na base

### 3.3 Stats De Combate

| Stat | Funcao |
|---|---|
| Vida | Pool de HP — zerou, perdeu |
| Regeneracao de Vida | HP recuperado passivamente |
| Mana | Recurso consumido pelas spells |
| Regeneracao de Mana | Mana recuperada passivamente |
| Ataque | Base do dano magico da arma e das spells |
| Defesa | Base das resistencias gerais |
| Velocidade de Ataque | Frequencia dos ataques da arma |
| Aceleracao de Habilidade | Reduz cooldown das spells em X% |
| Amplificacao Global | Aumenta todo dano causado em X% |
| Amplificacao Magica | Aumenta dano Magico em X% |
| Amplificacao de Fogo | Aumenta dano de Fogo em X% |
| Amplificacao de Gelo | Aumenta dano de Gelo em X% |
| Amplificacao de Veneno | Aumenta dano de Veneno em X% |
| Amplificacao de Choque | Aumenta dano de Choque em X% |
| Amplificacao de Morte | Aumenta dano de Morte em X% |
| Amplificacao de Sangramento | Aumenta dano de Sangramento em X% |

### 3.4 Tipos De Dano

| Tipo | Cor | DoT | Ticks | Duracao | Dano/tick (nivel 1) | Dano total |
|---|---|---|---|---|---|---|
| Magico | Roxo | Nao | — | — | — | — |
| Fogo | Vermelho claro | Queimando | 3 | 3s | 6 | 18 |
| Gelo | Azul claro | Nao — causa Lento e Congelado | — | — | — | — |
| Veneno | Verde | Envenenado | 8 | 8s | 3 | 24 |
| Choque | Azul escuro | Chocado | 5 | 5s | 5 | 25 |
| Morte | Preto | Apodrecendo | 6 | 6s | 6 | 36 |
| Sangramento | Vermelho escuro | Sangrando | 4 | 4s | 5 | 20 |

Intervalo entre ticks: 1 segundo para todos os DoTs.
Apodrecendo e o DoT de maior dano total — faz jus ao tipo Morte.
Chocado combina com o sistema de marcadores do Raio.

**Regra de stacking de DoT:** DoTs do mesmo tipo acumulam — cada aplicacao tem seu proprio contador de ticks e duracao independente. Dois Queimandos ativos ao mesmo tempo causam dano em paralelo. Nao ha substituicao da instancia mais antiga pela nova.

> Valores de dano marcados como referencia inicial — revisao durante prototipagem.

### 3.5 Resistencias

| Resistencia | Cobre |
|---|---|
| Global | Reduz todo dano em X% |
| Magica | Dano Magico |
| Elemental | Fogo + Gelo + Veneno + Choque (todos juntos) |
| Fogo | So Fogo |
| Gelo | So Gelo |
| Veneno | So Veneno |
| Choque | So Choque |
| Morte | Dano de Morte |
| Sangramento | Dano de Sangramento |

### 3.6 Barreiras

| Barreira | Absorve |
|---|---|
| Barreira Magica | Dano Magico |
| Barreira Elemental | Fogo + Gelo + Veneno + Choque |
| Morte | Sem barreira |
| Sangramento | Sem barreira |

### 3.7 Mecanicas Especiais

**Drenar Vida:** recupera X% de todo dano causado como HP. Funciona com todos os tipos de dano.

### 3.8 Status Effects

*Crowd Control:*

| Status | Efeito | Origem |
|---|---|---|
| Lento | Reduz velocidade de ataque e recuperacao de cooldown em X% por X tempo | Gelo / spells / passivas |
| Congelado | Para ataque e recuperacao de cooldown completamente por X tempo breve | Gelo / spells / passivas |
| Silenciado | Impede uso de spells por X tempo | Spells / armas / passivas |
| Stun | Paralisa todas as acoes e pausa todos os cooldowns por X tempo | Spells / armas / passivas |
| Desarmado | Impede ataque da arma principal por X tempo | Spells / armas / passivas |

Silenciado, Stun e Desarmado nao sao causados automaticamente por tipos de dano — dependem de spells, armas ou passivas especificas.

*Dano ao Longo do Tempo (DoT):*

| Status | Origem |
|---|---|
| Queimando | Fogo |
| Envenenado | Veneno |
| Chocado | Choque |
| Apodrecendo | Morte |
| Sangrando | Sangramento |

### 3.9 Arma

A arma define o ataque basico e o ataque especial do personagem. Possui tres dimensoes independentes:

| Dimensao | Descricao | Recurso |
|---|---|---|
| Tipo | Classe da arma — define comportamento de ataque | Desbloqueio futuro |
| Qualidade | Item especifico dentro do tipo — craftado | Ossos |
| Level | Poder daquela qualidade — 40 levels por season | Almas |

**Maestria de Arma:**
- Contador global permanente na conta para cada tipo de arma
- Acumula por dano causado com aquele tipo
- Concede amplificacao passiva crescente do dano **daquele tipo de arma** especificamente
- Dificuldade de ganhar maestria cresce conforme o nivel de maestria sobe — igual ao sistema de skills do Tibia
- Permanece mesmo ao trocar de qualidade ou season
- **Modificador atual:** dano. **Futuro:** expandir para lifesteal, critico e outros modificadores separados

**Primeiro slice — Varinha Magica:**
- Tipo: Varinha
- Ataque basico: raios de dano magico direto no oponente
- Ataque especial: a cada 3 ataques normais, o 4o dispara um raio maior com 3x o dano
- Tipo de dano: Magico
- Qualidade inicial: Varinha Simples (craftada com Ossos)
- Exemplos de qualidades futuras: Varinha do Necromante, Varinha Dourada

**Jogo completo:** multiplos tipos de arma (ex: Cajado) com comportamentos de ataque proprios, cada tipo com suas qualidades craftaveis e seu proprio level e maestria independentes. Levels especiais podem pedir mais Almas e itens especificos, causando mudancas maiores. Arvore de upgrades com escolhas em certos levels.

### 3.10 Spells

Spells sao habilidades ativas usadas em combate. Consomem Mana para serem castadas. Na batalha assincrona automatica, spells castam automaticamente quando ha Mana suficiente.

Upgrades de spell custam **Almas**. Cada spell possui **40 levels por season** e sistema de **Maestria** identico ao da arma — acumula por dano causado com aquela spell, concede amplificacao passiva crescente **do dano daquela spell especificamente**, dificuldade crescente, permanente na conta. Futuro: expandir para lifesteal, critico e outros modificadores.

Futuro: levels especiais com mais Almas e itens especificos, arvore de upgrades com escolhas em certos levels.

**Progressao de slots — Primeiro Slice:**

O jogador comeca sem nenhum slot de spell e os desbloqueia progressivamente via level durante o onboarding:

| Slot | Momento de desbloqueio | Conteudo |
|---|---|---|
| Slot 1 | Early game — muito cedo (level 1–3) | Raio Cosmico (fixo) |
| Slot 2 | Final do early game (level 10–15) | Escolha entre Raio/Acender/Envenenar/Congelar |
| Slot 3 | Mid game (level 20–25) | Escolha livre da pool completa |

**Pool completa de spells:**

| Spell | Tipo | Efeito |
|---|---|---|
| Raio Cosmico | Magico | Dano magico direto |
| Raio | Choque | Dano de choque + 1 marcador. Com 5 marcadores: consome todos, causa dano e breve stun |
| Acender | Fogo | Dano de fogo + Queimando |
| Envenenar | Veneno | Envenenado |
| Congelar | Gelo | 1 stack de Lento. Com 3 stacks: grande dano + Congelado breve |
| Odio | Morte | Grande dano de Morte |
| Dilacerar | Sangramento | Dano + Sangrando |
| Fortificar | — | Barreira Magica (X de dano) + Resistencia Global (X% por X tempo) |

**Jogo completo:** pool expandida com novas spells.

### 3.11 Habilidades Passivas

Passivas sao habilidades constantes, sempre ativas, sem custo ou cooldown. O jogador escolhe quais passivas equipa dentro dos slots disponiveis.

Passivas sao **desbloqueadas e upadas pela base** — o jogador precisa construir a estrutura correspondente na base para ganhar acesso e evoluir cada passiva. Upgrades custam **Cristais**.

**Primeiro slice:** 1 slot de passiva, escolha livre entre as 5 desde o inicio. Cada passiva tem **10 levels** no primeiro slice (equivalente a 1/4 da progressao de arma/spell de 40 levels).

**Pool de passivas:**

| Passiva | Efeito |
|---|---|
| Forca | Amplificacao Global +X% |
| Resistencia | Resistencia Global +X% |
| Escudo | A cada X segundos invoca uma Barreira Magica de X de dano |
| Vampirismo | Drenar Vida — recupera X% de todo dano causado como HP |
| Velocidade | Aceleracao de Habilidade +X% |

**Jogo completo:** multiplos slots, pool expandida.

### 3.12 Pet

O pet acompanha o personagem em batalha, causando dano e efeitos adicionais. Age automaticamente e nao recebe dano. Existe 1 slot de pet.

Upgrades de pet custam **Sangue**. Cada pet possui **40 levels por season** — cada level aumenta dano e efeito. Futuro: escolhas e upgrades especiais em certos levels, arvore de evolucao.

**Primeiro slice:** 1 slot de pet, escolha livre entre todos os 7 desde o inicio.

**Pool de pets:**

| Pet | Tipo | Efeito |
|---|---|---|
| Pet Magico | Magico | Dano magico direto |
| Pet de Fogo | Fogo | Dano de fogo + Queimando |
| Pet de Veneno | Veneno | Envenenado |
| Pet de Gelo | Gelo | Stack de Lento — combina com Congelar |
| Pet de Choque | Choque | Dano de choque + stack de marcador — combina com Raio |
| Pet de Morte | Morte | Dano de Morte |
| Pet de Sangramento | Sangramento | Dano + stack de Sangrando |

### 3.13 Sistema De Crafting — Ossos

**Ossos** e o nome simplificado do sistema de crafting. Na pratica sera uma variedade de materiais de drop e coleta que servem para construir armas e itens. Simplificado como "Ossos" para facilitar a implementacao inicial.

**O que e craftado com Ossos:**
- Qualidades de arma (ex: Varinha Simples, Varinha do Necromante, Varinha Dourada)
- Itens futuros (fora do primeiro slice)

**Primeiro slice:** apenas a Varinha e suas qualidades fazem parte do sistema de crafting. Outros itens entram em updates futuros.

**Jogo completo:** variedade de materiais de crafting com drops em conteudos especificos. Ossos como placeholder ate o sistema de crafting ser totalmente definido.

### 3.14 Cosmeticos

Cosmeticos nao concedem vantagem de gameplay.

- **Skins:** alteram a aparencia do mago. Versoes alternativas desbloqueadas por uso da skin.
- **Finalizacoes:** animacoes brutais exibidas apos vitoria PVP. O jogador escolhe qual exibir entre as desbloqueadas.

---

## 4. Os Modos

### 4.1 Base Manager *(Primeiro Slice)*

**Tipo:** hub permanente de progressao
**Referencias:** Hero Wars, Clash of Clans

O jogador expande a base do mago por uma tela com botoes animados e pontos de upgrade. Nao e um grid de construcao — o jogador nao escolhe onde posicionar estruturas.

**Visual — Primeiro Slice:** Altar/Santuario pessoal — espaco de rituais e preparacao, sombrio, organico, cheio de artefatos e energia.

**Evolucao da base ao longo do jogo ao vivo:**
- Primeiro slice: Altar/Santuario pessoal — ligado apenas ao mago e suas batalhas
- Fase intermediaria: quartel dentro da hierarquia Draxos
- Fase comandante: nave propria, ainda sob o mestre supremo
- Fase rebeliao: nave ou planeta autonomo

A base produz recursos passivamente. O jogador coleta periodicamente. Cada recurso possui limite de armazenamento. A maioria dos upgrades segue uma fila de tempo estilo Clash of Clans.

**Energia** e o token geral de evolucao da base — gasta para iniciar upgrades de estruturas junto com o tempo.

A base nao pode ser atacada por outros jogadores.

#### 4.1.1 Estruturas Da Base

| Estrutura | Recurso produzido | Uso do recurso |
|---|---|---|
| Altar das Almas | Almas | Upgrade de arma e spells |
| Nucleo de Energia | Energia | Evolucao de estruturas da base |
| Pocos de Sangue | Sangue | Upgrade do pet |
| Minas de Cristal | Cristais | Upgrade de passivas |
| Estrutura de Stats | — | Upgrade de stats do personagem (consome tempo e Energia) |
| (Futuro) Ossario | Ossos | Crafting de itens |

#### 4.1.2 Recursos

| Recurso | Fonte principal | Fonte secundaria | Uso |
|---|---|---|---|
| Experiencia | Vitorias PVP, construcoes | Derrotas PVP (1/5) | Level do personagem |
| Almas | Batalhas PVP | Producao da base | Upgrade de arma e spells |
| Energia | Batalhas PVP | Producao da base | Evolucao de estruturas da base |
| Sangue | Batalhas PVP | Producao da base | Upgrade do pet |
| Cristais | Producao da base | — | Upgrade de passivas |
| Ossos | Encontros especificos (futuro) | — | Crafting de itens (futuro) |

#### 4.1.3 Funcoes Sociais

- Lista de amigos (adicionar por username ou codigo de convite)
- Guilda com construcoes proprias, bônus passivos e chat
- Sistema de ajuda em construcoes da base — ver Secao 16 para detalhes completos

### 4.2 Character Autobattler — PVP *(Primeiro Slice)*

**Tipo:** Arena Mobile Assincrona PVP
**Referencia principal:** Hero Wars
**Referencia de apresentacao:** Mortal Kombat classico

O mago do jogador entra em um duelo contra o mago de outro jogador de poder semelhante. A batalha e totalmente automatica e assincrona.

A apresentacao e sidescroller classico, com os dois personagens em lados opostos da tela.

#### 4.2.1 Mecanica De Batalha

- Batalha totalmente automatica e assincrona
- Vence quem matar o oponente primeiro
- Spells castam automaticamente quando ha Mana suficiente
- Pet age automaticamente
- **Anti-stall:** dispara aos 30 segundos de batalha. Dano ignora resistencias e rampa agressivamente:

| Tempo | Dano por segundo |
|---|---|
| 30s | 10% do HP maximo |
| 32s | 20% do HP maximo |
| 34s | 40% do HP maximo |
| 36s+ | Letal |

Batalhas de early game (7–20s): anti-stall nunca dispara. Batalhas de jogador estabelecido (28–30s): dispara, forca conclusao por volta de 32–34s. Build defensiva extrema: forcada a terminar antes de 40s.

#### 4.2.2 Recompensas

| Resultado | Experiencia | Almas | Energia | Sangue |
|---|---|---|---|---|
| Vitoria | Completa | Completa | Completa | Completa |
| Derrota | 1/5 | 1/5 | 1/5 | 1/5 |

Recompensas reduzem conforme o jogador repete batalhas dentro de uma janela de tempo — chegando a zero, mas permitindo batalhar sem recompensa.

#### 4.2.3 Outras Funcoes

- Matchmaking por forca semelhante
- Defesa offline do mago do jogador
- Finalizacoes brutais desbloqueaveis e escolhidas pelo jogador apos vitoria

### 4.3 Character Autobattler — PVE *(Futuro)*

**Tipo:** batalha automatica PVE com ultimate/spells acionaveis
**Referencia principal:** Hero Wars

O mago enfrenta variedade de criaturas em batalhas automaticas PVE. O PVE pode ter botao de ultimate e 1 a 3 botoes de spell acionaveis pelo jogador.

#### 4.3.1 Primeira Temporada Narrativa

O jogador controla um jovem Draxos em inicio de carreira dentro de uma sociedade de magos organizada de forma hierarquica. Ao longo do primeiro grande arco, o jogador ascende nessa hierarquia ate atingir o posto de comandante, obedecendo apenas ao mestre supremo.

No fim do primeiro grande arco, o personagem se rebela contra o mestre supremo e comeca sua aventura solo pelo espaco.

**Papel estrategico:** constroi o sistema de combate e banco de criaturas que o Open World futuro vai reutilizar.
**Conexao:** alta com Base Manager.

### 4.4 PVP Cardgame Roguelike *(Futuro)*

**Tipo:** PVP cardgame roguelike
**Referencias:** The Bazaar (versao simplificada para mobile)

O jogador entra em uma run roguelike de cartas com componente PVP. Batalha perdida custa uma vida. X vitorias vencem a run.

**Progressao em dois layers:** temporaria dentro da run, permanente entre runs.
**Conexao:** progressao propria. Recebe apenas pequenos beneficios de Level Global e de uma base bem evoluida.

### 4.5 Hero Defense *(Futuro)*

**Tipo:** defesa contra hordas / tower defense com o mesmo personagem
**Referencias:** Evil Tower

**Dois sistemas de upgrade independentes:**
1. **Tokens de monstros:** ganhos por matar inimigos, gastos em upgrades de stats.
2. **Buff de escolha:** a cada X waves, o jogador escolhe 1 de 3 buffs permanentes para aquela run.

**Progressao em dois layers:** temporaria dentro da run, permanente entre runs.
**Conexao:** progressao propria. Recebe apenas pequenos beneficios de Level Global e de uma base bem evoluida.

### 4.6 Open World RPG *(Futuro / projeto maior)*

**Tipo:** RPG singleplayer de mundo aberto
**Referencias:** Butcher Hero e similares

Expande o personagem e o sistema de combate construido nos modos anteriores para um mundo aberto exploravel.

**Status atual:** sem capacidade de producao agora. Deve ser considerado na arquitetura desde o inicio.
**Conexao:** progressao propria. Recebe apenas pequenos beneficios de Level Global e de uma base bem evoluida.

---

## 5. Progressao

### 5.1 Level Global

Representa o proprio jogador como personagem. Cresce via Experiencia de todos os modos.

- Afeta os stats base diretamente
- E a referencia para desbloqueios gerais do jogo
- Concede bonus gerais e leves em todos os modos

### 5.2 Dentro Dos Modos Com Run

Modos futuros com estrutura de run possuem dois layers:

| Layer | Escopo | Comportamento |
|---|---|---|
| Progressao de run | Dentro da run | Temporaria — reseta ao fim da run |
| Meta-progressao | Entre runs | Permanente — acumula ao longo do tempo |

### 5.3 Base Manager

Progressao permanente e continua. A base nunca reseta. Cresce pelo recebimento de recursos das batalhas e pela producao passiva das estruturas.

---

## 6. Fluxo De Recursos E Conexao Entre Modos

```
PVP Autobattler ──► Almas + Energia + Sangue + XP ──► Base Manager
Base Manager    ──► Cristais (passivo) ──────────────► Upgrade de passivas
Base Manager    ──► arma + spells + passivas + stats ► PVP/PVE Autobattler
Guilda/Amigos   ──► ajudas sociais ─────────────────► Base Manager

PVP Cardgame Roguelike ──► progressao propria + pequenos beneficios de conta/base
Hero Defense            ──► progressao propria + pequenos beneficios de conta/base
Open World RPG          ──► progressao propria + pequenos beneficios de conta/base

Todos os modos ──► Experiencia ──► Level Global ──► stats base + desbloqueios
```

---

## 7. Plano De Producao — Primeiro Slice vs Jogo Completo

### 7.1 Primeiro Slice

| Sistema | Estado |
|---|---|
| Character Autobattler PVP assincrono | Incluido |
| Base Manager com todas as estruturas de producao | Incluido |
| Estrutura de upgrade de stats | Incluida |
| Fila de tempo para upgrades | Incluida |
| Varinha (tipo unico, qualidades craftadas com Ossos) | Incluida |
| Level de arma 1–40 com Almas | Incluido |
| Maestria de Varinha (amplificacao por dano causado) | Incluida |
| Progressao de 0 a 3 slots de spell com selecao | Incluida |
| Pool de 8 spells, level 1–40 por spell, maestria por spell | Incluida |
| 1 slot de passiva, 10 levels por passiva, desbloqueio pela base | Incluido |
| Pet (1 slot, escolha livre entre 7, level 1–40) | Incluido |
| Cosmeticos: skins e finalizacoes | Incluidos |
| Lista de amigos + guilda + ajudas | Incluidos |
| Recursos: Almas, Energia, Sangue, Cristais, Ossos | Incluidos |
| Multiplos slots de passiva | Fora do primeiro slice |
| Multiplos tipos de arma (ex: Cajado) | Fora do primeiro slice |
| Outros itens alem da arma | Fora do primeiro slice |
| Arvore de upgrades e levels especiais | Futuro |

### 7.2 Jogo Completo — Evolucao

| Marco | Conteudo |
|---|---|
| **Primeiro slice** | PVP + Base Manager + pet + social + 3 spells + 5 passivas + 7 pets |
| **Evolucao do slice** | Multiplos slots de passiva, variedade de armas, pool expandida de spells |
| **Futuro** | Character Autobattler PVE + campanha narrativa + evolucao da base |
| **Futuro** | Sistema de crafting com Ossos e outros materiais |
| **Futuro** | PVP Cardgame Roguelike |
| **Futuro** | Hero Defense |
| **Futuro maior** | Open World RPG |

---

## 8. Numeros E Formulas

> **ATENCAO:** todos os valores desta secao sao referencia inicial de primeiro teste. Revisao obrigatoria durante prototipagem com animacoes rodando e combate real simulado.

### 8.1 Level e Progressao

- **Level maximo Season 1:** 40–50 (a definir no lancamento)
- **Level maximo primeiro slice:** 10
- **Filosofia:** levels iniciais muito rapidos — level 10 representa menos de 10% do conteudo total
- **Limite de level:** sempre temporario, expandido por updates e seasons

### 8.2 Stats Base — Nivel 1

| Stat | Valor |
|---|---|
| Vida | 100 |
| Regeneracao de Vida | 1 / segundo |
| Mana | 20 |
| Regeneracao de Mana | 2 / segundo |
| Ataque | 15 |
| Defesa | 4 |
| Velocidade de Ataque | 1 ataque / segundo |
| Aceleracao de Habilidade | 0% |

Velocidade de Ataque e Aceleracao de Habilidade nao crescem por Level — vem exclusivamente de upgrades e equipamentos.

Regeneracao de Vida e Regeneracao de Mana crescem por Level (curva a definir durante prototipagem) alem de outras fontes como upgrades de base, passivas e equipamentos futuros.

### 8.3 Curva De Crescimento Por Level (~20% por nivel)

| Level | Vida | Mana | Ataque | Defesa |
|---|---|---|---|---|
| 1 | 100 | 20 | 15 | 4 |
| 2 | 120 | 22 | 17 | 5 |
| 3 | 144 | 24 | 20 | 6 |
| 4 | 173 | 27 | 23 | 7 |
| 5 | 208 | 30 | 26 | 8 |
| 6 | 250 | 33 | 30 | 9 |
| 7 | 300 | 36 | 35 | 10 |
| 8 | 360 | 40 | 40 | 12 |
| 9 | 432 | 44 | 46 | 14 |
| 10 | 518 | 48 | 53 | 16 |

### 8.4 Formulas De Reducao De Dano

**Defesa e Resistencias:** `Stat / (Stat + 100) = % de reducao`

- Defesa: reduz todo dano recebido de todas as fontes
- Resistencia Global: reduz todo dano recebido (stat separado da Defesa — Defesa tera propriedades adicionais no futuro)
- Resistencias especificas: reduzem apenas seu tipo de dano correspondente
- **Stacking:** multiplas reducoes aplicam em camadas separadas, nao somam antes do calculo

Exemplo: dano de Fogo 15, Resistencia Global 10%, Resistencia de Fogo 10% → 15 × 0.90 × 0.90 ≈ 12.2 de dano final.

### 8.5 Referencia De Duracao De Batalha

| Fase | Duracao esperada |
|---|---|
| Early game (niveis 1–3) | 4–7 segundos |
| Mid game (niveis 4–30) | 10–20 segundos |
| Late game / builds defensivas | 20–30 segundos |

### 8.6 Spells — Custos De Mana E Dano Base (Nivel 1)

> Provisorio — revisao durante prototipagem com animacoes.

| Spell | Custo Mana | Dano base nivel 1 | Notas |
|---|---|---|---|
| Raio Cosmico | 8 | 25 direto | Dano puro sem efeito |
| Raio | 8 | 8 + burst 60 | Burst ao acumular 5 marcadores |
| Acender | 8 | 5 + 6/tick (3 ticks) | DoT rapido, 3s de duracao |
| Envenenar | 8 | 0 + 3/tick (8 ticks) | DoT muito lento, 8s de duracao |
| Congelar | 10 | 0 + burst 30 | Utility pura — stacks de Lento/Congelado |
| Odio | 16 | 40 direto | Dano puro alto, cadencia baixa |
| Dilacerar | 8 | 12 + 5/tick (4 ticks) | Dano medio + DoT medio, 4s de duracao |
| Fortificar | 12 | 0 | Defensiva pura — Barreira Magica + Resistencia Global |

Frequencia estimada no nivel 1 (Mana 20, Regen 2/s): spells de custo 8 a cada ~4s, Congelar a cada ~5s, Odio a cada ~8s, Fortificar a cada ~6s.

### 8.7 DoTs — Referencia Inicial

Intervalo entre ticks: **1 segundo** para todos os DoTs.

| DoT | Ticks | Duracao | Dano total nivel 1 |
|---|---|---|---|
| Queimando | 3 | 3 segundos | 18 |
| Envenenado | 8 | 8 segundos | 24 |
| Sangrando | 4 | 4 segundos | 20 |
| Chocado | 5 | 5 segundos | 25 |
| Apodrecendo | 6 | 6 segundos | 36 |

Tabela completa de DoTs — todos os tipos definidos. Ver secao 3.4 para dano por tick.

### 8.8 Status Effects — Duracao Inicial Da Primeira Habilidade

> Duracao e dependente da spell e do level — valores abaixo sao ponto de partida da primeira habilidade de cada tipo.

| Status | Duracao inicial |
|---|---|
| Lento | 3 segundos |
| Congelado | 1 segundo |
| Silenciado | 2 segundos |
| Stun | 1 segundo |
| Desarmado | 2 segundos |

---

## 9. Progressao De Conta E Monetizacao

### 9.0 Definicao De Season

Uma season tem **4 meses** de duracao. Cada season inclui **2 Battle Passes** — um por bimestre.

Ao fim da season o Level Global e a progressao de Maestria permanecem. Systems com "40 levels por season" (arma, spells, pet) reiniciam — o jogador recomeça a progressao desses sistemas na proxima season.

### 9.1 Tipos De XP

| Tipo | Fonte | Limite |
|---|---|---|
| XP Livre | Quests, eventos, recompensas gerais | Sem limite — creditada diretamente |
| XP de Gameplay | Modos de batalha (Autobattler, futuros) | Sujeita a cotas diarias e semanais |

### 9.2 Formula De Level

A XP necessaria para atingir o nivel n segue uma curva cubica adaptada do Tibia:

`XP_total(n) = 3 × (n³ - 6n² + 17n - 12)`

XP necessaria para subir cada level: `9 × (n² - 3n + 4)` onde n e o nivel atual.

**Tabela de progressao — referencia de primeiro teste:**

| Level | XP para subir | Dias acumulados (so batalha) |
|---|---|---|
| 1→2 | 18 | < 1 dia |
| 2→3 | 18 | < 1 dia |
| 3→4 | 36 | < 1 dia |
| 4→5 | 72 | < 1 dia |
| 5→6 | 126 | < 1 dia |
| 6→7 | 198 | ~1 dia |
| 7→8 | 288 | ~1.5 dias |
| 8→9 | 396 | ~2 dias |
| 9→10 | 522 | ~2 dias |
| 10→15 | 666 a 1.656 cada | ~8 dias total |
| 15→20 | 1.656 a 2.772 cada | ~3 semanas total |
| 20→25 | 3.096 a 4.986 cada | ~1.5 meses total |
| 25→30 | 4.986 a 7.326 cada | ~2.5 meses total |
| 30→35 | 7.326 a 10.116 cada | ~4 meses total |
| 35→40 | 10.116 a 12.672 cada | ~6.4 meses total |

**Level maximo Season 1:** 40–50. Level 40 sem progressao paga: ~193 dias (~6.4 meses). Com progressao paga (~50% mais rapido): ~4 meses. A formula continua funcionando para qualquer nivel futuro — basta estender a tabela.

**Importante:** os dias acumulados acima refletem apenas XP de batalha (cota diaria). Na pratica, especialmente no primeiro mes, o jogador tambem recebe XP livre de construcoes na base e de missoes/onboarding, acelerando a progressao inicial significativamente. O ritmo de 6.4 meses representa o cruzeiro de um jogador estabelecido sem compra.

### 9.4 Sistema De Cotas De XP De Gameplay

A XP de gameplay possui tres faixas de rendimento que o jogador percorre em sequencia a cada dia:

| Faixa | Rendimento |
|---|---|
| XP Dobrada | 2x XP por batalha |
| XP Normal | 1x XP por batalha |
| XP Reduzida | Fracao da XP por batalha |

**Cotas diarias de referencia (jogador estabelecido, ~38 batalhas/hora):**

| Faixa | Batalhas | XP/batalha | XP total |
|---|---|---|---|
| XP Dobrada (30 min equiv.) | 19 | 20 | 380 |
| XP Normal (30 min equiv.) | 19 | 10 | 190 |
| XP Reduzida (1h30 equiv.) | 57 | 5 | 285 |
| **Total diario de batalha** | **95** | — | **855 XP** |

| Periodo | XP de batalha |
|---|---|
| Diario | 855 XP |
| Acumulado maximo (3 dias) | 2.565 XP |
| Semanal maximo | 5.985 XP |

**Acumulacao:** o jogador pode acumular ate o equivalente a 3 dias de cota sem jogar. Se nao jogar por 3 dias, os 3 dias ficam armazenados esperando.

**Reset semanal:** jogador que esgotou todas as cotas e ficou na faixa vermelha recebe os 3 dias de armazenamento de volta apos uma semana. Permite "jogar demais" ocasionalmente sem punir o jogador por muito tempo, mas sem permitir acumulo infinito ou nivelamento acelerado permanente.

**Recursos de batalha como reflexo da XP:** Almas, Energia e Sangue recebidos por batalha seguem a mesma faixa ativa de XP. XP Dobrada = recursos dobrados. XP Reduzida = recursos reduzidos. XP zerada = sem recursos de batalha. Nao existe um contador separado para cada recurso.

**XP livre (sem limite):** XP de construcoes na base, missoes, conquistas e eventos e creditada diretamente sem consumir cotas de gameplay. Jogadores novos recebem boosts de onboarding intencionais — XP extra, recursos e pequenas quantidades de Diamante para ensinar os sistemas.

**Outros modos futuros** (PVE, Cardgame Roguelike, Hero Defense) seguem a mesma referencia de faixa de XP ativa. Nao tem limitador proprio adicional.

**Comunicacao ao jogador:** simples e objetiva — o jogador ve sua faixa atual e quanto tem armazenado, sem expor a complexidade interna do sistema.

### 9.5 Battle Pass

Dois tiers permanentes:

| Tier | Conteudo |
|---|---|
| Free | Recursos + quantidade moderada de Diamantes |
| Premium | Mais recursos + mais Diamantes — assinatura de preco baixo |

O Battle Pass recompensa o jogador por jogar — quanto mais ele joga, mais recompensas do passe ele desbloqueia.

### 9.6 Sistema De Recompensas Diarias E Semanais

Recompensas diarias e semanais disponíveis para todos os jogadores. Por padrao, cada recompensa esta travada por um anuncio.

**Compra unica:** remove os anuncios de todas as recompensas diarias e semanais para sempre. Esse pacote pode conter beneficios adicionais no futuro.

O sistema segue logica de cotas semelhante ao XP — limites diarios e semanais para evitar que vire fonte infinita de recursos.

### 9.7 Moeda Premium — Diamante

**Nome:** Diamante

O Diamante pode ser usado para acelerar ou substituir qualquer tipo de progressao do jogo. O custo varia por categoria:

| Uso | Custo relativo |
|---|---|
| Acelerar construcoes da base | Baixo — acessivel para jogadores casuais |
| Comprar recursos (Almas, Energia, Sangue, Cristais) | Medio |
| Pular etapas de poder (XP direta, upgrades de arma/spell) | Alto — deve ser caro o suficiente para nao quebrar a progressao |

O valor do Diamante deve ser cuidadosamente calibrado para que a aceleracao de construcoes seja acessivel e frequente, enquanto pular progressao de poder seja uma decisao significativa de gasto.

Fontes de Diamante:
- Battle Pass Free (quantidade moderada)
- Battle Pass Premium (quantidade maior)
- Recompensas diarias e semanais
- Compra direta

---

## 10. Economia De Recursos E Curvas De Upgrade

> **ATENCAO:** todos os valores desta secao sao referencia inicial de primeiro teste. Revisao obrigatoria durante prototipagem e balanceamento real.

### 10.1 Recursos Por Batalha PVP

Recursos seguem a mesma faixa ativa de XP de gameplay do jogador.

| Recurso | Base por batalha | XP Dobrada | XP Normal | XP Reduzida |
|---|---|---|---|---|
| Almas | 3 | 6 | 3 | 1.5 |
| Sangue | 1 | 2 | 1 | 0.5 |
| Energia | 2 | 4 | 2 | 1 |

**Total diario estimado (jogador estabelecido, batalha + producao da base):**

| Recurso | Batalha/dia | Base/dia | Total/dia |
|---|---|---|---|
| Almas | ~257 | ~50 | **~307** |
| Sangue | ~86 | ~20 | **~106** |
| Energia | ~171 | ~30 | **~201** |

### 10.2 Curva De Upgrade — Arma E Spell (Almas)

**Formula:** `custo(n) = max(10, round(0.2 × n²))`
**Total level 1–40:** ~5.200 Almas por item

| Level | Custo | Custo acumulado |
|---|---|---|
| 1–7 | 10 cada | 70 |
| 8 | 15 | 85 |
| 10 | 20 | 125 |
| 15 | 45 | 390 |
| 20 | 80 | 935 |
| 25 | 125 | 1.870 |
| 30 | 180 | 3.270 |
| 35 | 245 | 5.100 |
| 40 | 320 | ~5.200 |

**Tempo estimado:**
- 1 item focado (307 Almas/dia): ~17 dias
- Arma + 3 spells simultaneamente (~77/dia cada): ~67 dias (~2.2 meses)

### 10.3 Curva De Upgrade — Pet (Sangue)

**Formula:** `custo(n) = max(5, round(0.15 × n²))`
**Total level 1–40:** ~4.000 Sangue

| Level | Custo | Custo acumulado |
|---|---|---|
| 1–8 | 5 cada | 40 |
| 10 | 15 | 75 |
| 20 | 60 | 680 |
| 30 | 135 | 2.400 |
| 40 | 240 | ~4.000 |

**Tempo estimado:** 4.000 / 106 Sangue/dia = **~38 dias (~1.3 meses)**

### 10.4 Curva De Upgrade — Passiva (Cristais)

Cristais vem exclusivamente da producao da base — sem recompensa de batalha.
**Total level 1–10:** ~1.000 Cristais por passiva

| Level | Custo | Custo acumulado |
|---|---|---|
| 1 | 20 | 20 |
| 3 | 40 | 100 |
| 5 | 80 | 260 |
| 7 | 140 | 540 |
| 10 | 220 | ~1.000 |

Tempo depende da taxa de producao da base (a definir).

### 10.5 Referencia De Tempo De Progressao

| Marco | Tempo estimado (sem compra) |
|---|---|
| Pet level 40 | ~1.3 meses |
| Arma + 3 spells level 40 | ~2.2 meses |
| Level 10 do personagem | ~2 dias |
| Level 40 do personagem | ~6.4 meses |
| Passivas level 10 | depende da producao da base |

---

## 11. Base Manager — Economia E Progressao

> **ATENCAO:** todos os valores desta secao sao referencia inicial de primeiro teste. Revisao obrigatoria quando o sistema de quests e recompensas for criado — quests entregam XP livre, recursos e Diamantes que impactam diretamente o ritmo de progressao de tudo aqui definido.

### 11.1 Fila De Construcao

- **1 slot** de construcao padrao
- **2 slots** com compra unica na loja
- Level da conta funciona como limitador maximo — estrutura nao pode estar em level superior ao level da conta
- **Meta de season:** jogador que atingiu level 40, completou quests e tem battle pass consegue terminar todas as construcoes antes do fim da season

### 11.2 Levels Das Estruturas

Cada estrutura possui **40 levels independentes** por season. Todas as estruturas do primeiro slice:

- Altar das Almas (produz Almas)
- Nucleo de Energia (produz Energia)
- Pocos de Sangue (produz Sangue)
- Minas de Cristal (produz Cristais)
- Estrutura de Stats (upgrade de stats do personagem)
- Crafting de Arma / Ossos — desbloqueado no final do early game (~level 10–15)

Slots de upgrade desbloqueados progressivamente: começa em 0, maioria entregue como tutorial nos primeiros levels, todos ativos antes de level 15.

### 11.3 Curva De Duracao Por Level De Estrutura

| Level | Duracao |
|---|---|
| 1 | 2 minutos |
| 2–3 | 10–30 minutos |
| 4–5 | 1 hora |
| 6–10 | 2–6 horas |
| 11–15 | 8–18 horas |
| 16–20 | 20–36 horas |
| 21–25 | 40–60 horas |
| 26–30 | 65–90 horas |
| 31–35 | 96–120 horas |
| 36–40 | 130–160 horas |

**Total por estrutura:** ~47 dias
**5 estruturas com 1 fila:** ~235 dias
**5 estruturas com 2 filas (compra unica):** ~118 dias — dentro de 180 dias de season com battle pass

### 11.4 Custo De Energia Por Level De Estrutura

**Formula:** `custo(n) = max(20, round(0.5 × n²))`

| Level | Custo (Energia) | Custo acumulado |
|---|---|---|
| 1–6 | 20 cada | 120 |
| 10 | 50 | 350 |
| 15 | 113 | 900 |
| 20 | 200 | 2.100 |
| 25 | 313 | 4.000 |
| 30 | 450 | 6.800 |
| 35 | 613 | 10.500 |
| 40 | 800 | ~15.000 |

**Total para 5 estruturas:** ~75.000 Energia na season
**Energia disponivel:** ~201/dia × 180 dias = ~36.180 de batalha + base

Energia e o recurso mais apertado da base — o jogador precisa priorizar quais estruturas upa primeiro, criando decisao estrategica real.

### 11.5 Taxas De Producao Por Estrutura

| Estrutura | Recurso | Nivel 1 | Nivel 20 | Nivel 40 |
|---|---|---|---|---|
| Altar das Almas | Almas | 2/hora | 8/hora | 20/hora |
| Nucleo de Energia | Energia | 1/hora | 5/hora | 12/hora |
| Pocos de Sangue | Sangue | 1/hora | 3/hora | 8/hora |
| Minas de Cristal | Cristais | 2/hora | 8/hora | 20/hora |

Cristais ao nivel 20: 8/hora × 24h = ~192/dia → passiva level 10 (~1.000 Cristais) em ~5 dias focado.

### 11.6 Limites De Armazenamento Por Estrutura

| Estrutura | Nivel 1 | Nivel 20 | Nivel 40 |
|---|---|---|---|
| Altar das Almas | 100 Almas | 500 Almas | 1.500 Almas |
| Nucleo de Energia | 50 Energia | 250 Energia | 800 Energia |
| Pocos de Sangue | 50 Sangue | 200 Sangue | 600 Sangue |
| Minas de Cristal | 100 Cristais | 500 Cristais | 1.500 Cristais |

Nivel 1 enche em ~50 horas — jogador que nao coleta por 2 dias perde producao. Incentiva sessoes regulares sem punir ausencias curtas.

---

## 12. Matchmaking E Valor De Poder

O matchmaking emparelha jogadores com poder semelhante. O poder e um valor unico calculado a partir de todos os upgrades do personagem.

**Formula de poder (referencia inicial — pesos a calibrar com dados reais):**

`Poder = (Level × 50) + (Level Arma × 30) + (Soma Levels Spells × 20 cada) + (Level Pet × 15) + (Soma Levels Passivas × 10 cada) + (Qualidade Arma × 25)`

Os pesos exatos dependem de calibracao via dados de combate coletados ao vivo. A formula e um ponto de partida — o objetivo e que jogadores com builds diferentes mas poder equivalente tenham batalhas equilibradas.

---

## 13. Sistema De Recompensas

### 13.1 Fontes De Recompensa — Visao Geral

O sistema e fechado: a cota de batalha e fixa independente de quantos modos existem. Mais modos = mais variedade de conteudo, nao mais recursos totais.

| Fonte | Recorrencia | Peso na Economia | Tipo | Comportamento com expansoes |
|---|---|---|---|---|
| Recompensas de Batalha | Diaria (com cota) | **Principal** | Free | Cota compartilhada entre todos os modos |
| Producao da Base | Passiva continua | **Principal** | Free | Escala com novos levels de estrutura por season |
| Battle Pass | Por season | **Significativo** | Free + Pago | Novo passe a cada season |
| Quests Mainline | Uma vez por quest | **Alto pontual** | Free | Cresce com novos modos e narrativa |
| Missoes Diarias | Diaria por modo | **Complementar** | Free | Cada novo modo adiciona seus proprios desafios |
| Conquistas | Uma vez por marco | **Medio pontual** | Free | Acumula com o crescimento do jogo |
| Recompensas de Guilda | Diaria/semanal | **Leve** | Free | Social — nao quebra a economia |
| Ranking / Fim de Season | Por season (1–2x) | **Grande pontual** | Free + Pago | A partir da segunda season |

**Como as fontes se complementam:**

```
Sustento diario:    Batalha + Base
Engajamento:        Missoes Diarias + Guilda
Progressao guiada:  Quests Mainline + Conquistas
Retencao de season: Battle Pass + Ranking fim de season
```

### 13.2 Recompensas De Batalha

Cota diaria compartilhada entre todos os modos de batalha. Segue o sistema de faixas de XP (Dobrada / Normal / Reduzida). Detalhes em secao 9.4 e 10.1.

**Primeiro slice:** apenas Autobattler PVP consome a cota.
**Jogo completo:** PVE, Cardgame Roguelike e outros modos disputam a mesma cota.

### 13.3 Quests Mainline

Sequencia de quests de historia que comeca com o tutorial e segue a narrativa principal do jogo. Recompensas unicas, front-loaded — maior concentracao de recursos e Diamantes no early game para acelerar o onboarding.

Lore das quests pendente de definicao. Apenas os valores de recompensa serao definidos nesta fase conceitual.

**Primeiro slice / Season 1:** quests do tutorial + primeiras quests do Autobattler PVP.
**Jogo completo:** cada novo modo e season traz novas quests mainline.

### 13.4 Missoes Diarias

Desafios diarios por modo que recompensam engajamento consistente.

**Primeiro slice — Autobattler:**
- Bonus pelas **3 primeiras vitorias** do dia

**Jogo completo:** cada modo tem seus proprios desafios diarios independentes.

### 13.5 Conquistas

Marcos unicos que o jogador atinge uma vez durante sua conta. Nao se repetem. Sem narrativa — sao reconhecimentos de progresso.

Exemplos: primeira vitoria PVP, primeira arma level 10, primeira estrutura level 20, primeiro pet level 40.

Valores de recompensa a definir quando o sistema for implementado.

### 13.6 Recompensas De Guilda

Ajudas entre membros da guilda — forca leve na evolucao da base. Detalhes do sistema pendentes (P03 em pendencias.md). Peso leve intencional para nao quebrar a economia.

### 13.7 Ranking E Fim De Season

Recompensa jogadores que se destacaram no ranking ao fim de cada season. Inclui recursos, cosmeticos e possivelmente Diamantes.

Disponivel a partir da segunda season. Detalhes a definir.

---

## 14. Coleta De Dados — Nota Ao Projeto

> Esta secao documenta os dados que o jogo precisa coletar para sustentar balanceamento, entender o meta e tomar decisoes de roadmap. Deve ser considerada desde a arquitetura do primeiro slice.

### 14.1 Dados De Combate

- Dano causado por fonte (arma, cada spell, pet) por batalha
- Duracao real das batalhas
- Win rate por combinacao de build (spell slot 2, passiva, pet)
- Frequencia de ativacao do anti-stall
- Distribuicao de maestria acumulada por tipo de arma/spell vs resultado
- Builds mais comuns por faixa de poder

### 14.2 Dados De Progressao E Economia

- Curva de level dos jogadores ao longo do tempo
- Recursos acumulados vs gastos por categoria (Almas, Sangue, Cristais, Energia)
- Taxa de upgrade por estrutura de base por semana
- Quais upgrades sao priorizados pelos jogadores
- Tempo medio para atingir cada level de personagem

### 14.3 Dados De Retencao E Monetizacao

- Retencao por dia 1, dia 7, dia 30, dia 90
- Funnel de onboarding — onde jogadores abandonam nas quests mainline
- Taxa de conversao para battle pass premium
- Uso de Diamantes por categoria (construcoes, recursos, pular progressao)
- Comparacao de progressao free vs pago

### 14.4 Uso

Esses dados informam:
- Balanceamento de combate (nerf/buff de spells, pets, passivas)
- Definicao e monitoramento do meta PVP
- Ajuste de economia (producao da base, custos de upgrade)
- Decisoes de roadmap (quais modos e conteudos priorizar)
- Calibracao dos pesos da formula de poder para matchmaking

---

## 17. Infraestrutura Do Produto

> Esta secao documenta as decisoes de infraestrutura do primeiro slice. Tecnologia, arquitetura de conta, batalha no servidor, matchmaking, ranking e politica offline.

### 17.1 Engine E Plataformas

| Plataforma | Status | Formato |
|---|---|---|
| Android | Primeiro slice | APK nativo — app instalado |
| PC (Windows/Linux) | Primeiro slice | Executavel nativo (.zip) |
| PC Browser | Primeiro slice | Godot web export (HTML5/WebAssembly) |
| Mobile browser | Fora do escopo | App nativo e o unico canal mobile |
| iOS | Futuro | Requer Mac para build e conta Apple Developer ($99/ano) |

**Estrategia de exportacao:** mesmo projeto Godot, tres targets. Input adaptado por plataforma (toque no Android, mouse no PC/browser). UI escala via CanvasLayer e viewport scaling.

**PC Browser:** Godot web export entrega o jogo diretamente no browser sem instalacao. Esforco marginal — e um export a mais no mesmo projeto. Util para jogadores PC que preferem nao instalar e para distribuicao de alpha via link. Performance no PC browser com WebGL2 e adequada para este tipo de jogo.

**Monetizacao no browser:** pagamentos web sao mais complexos que in-app (Play Store). Para o alpha isso nao e relevante. Quando o jogo for ao vivo, a estrategia de monetizacao para o canal browser precisa ser definida separadamente.

### 17.2 Backend — Supabase

Servico gerenciado. Free tier cobre o alpha inteiro.

| Servico Supabase | Uso |
|---|---|
| Auth (JWT) | Login, sessoes, tokens — suporta Google OAuth nativamente |
| Postgres | Todos os dados de jogo (builds, recursos, guilda, batalhas, ranking) |
| Edge Functions | Logica de servidor: simulacao de batalha, matchmaking, mutacoes de recursos, validacoes |
| Realtime | Chat de guilda (substitui polling quando base de jogadores crescer) |
| Storage | Assets futuros |

Comunicacao Godot → Supabase via HTTPRequest nativo (REST API). Sem SDK intermediario obrigatorio.

### 17.3 Sistema De Conta

#### 17.3.1 Tipos De Conta

| Tipo | Descricao |
|---|---|
| Guest | Conta anonima criada automaticamente no primeiro boot. Progresso salvo no servidor. Sem email/senha. |
| Registrada (email+senha) | Jogador cria conta com username e senha. |
| Google Sign-In | OAuth2 via Google. Fluxo nativo no Android; disponivel tambem no PC. |

O jogador pode comecar como guest e migrar para conta registrada ou Google em qualquer momento — todo o progresso e preservado na migracao.

#### 17.3.2 Alpha — Acesso Controlado

Durante o servidor privado, criacao de conta (inclusive guest) exige um **codigo de convite**. O codigo e distribuido pelo desenvolvedor. Sem codigo, o jogo nao conecta ao servidor.

#### 17.3.3 Seguranca De Conta

- Tokens JWT com expiracao
- Refresh token para renovacao silenciosa
- Rate limiting em endpoints de autenticacao
- Senhas hasheadas no servidor (nunca trafegam em texto)

### 17.4 Arquitetura De Batalha

A batalha e **totalmente simulada no servidor**. O cliente nao executa logica de combate — apenas anima o resultado recebido.

#### 17.4.1 Fluxo

```
1. Cliente envia "solicitar batalha"
2. Servidor seleciona oponente (matchmaking por poder)
3. Servidor simula a batalha completa (deterministica)
4. Servidor registra resultado, atualiza recursos e ranking
5. Servidor retorna ao cliente: resultado + log de eventos
6. Cliente anima a batalha a partir do log — sem modificar nenhum dado
```

#### 17.4.2 Log De Eventos

O servidor retorna uma sequencia de eventos timestampados que o cliente usa para animar:

```
{ t: 0.0,   tipo: "ataque_arma",  origem: "jogador", dano: 15 }
{ t: 0.8,   tipo: "spell",        spell: "Raio Cosmico", dano: 25 }
{ t: 1.6,   tipo: "dot_tick",     status: "Queimando", dano: 6 }
{ t: 4.2,   tipo: "anti_stall",   dano: 103 }
{ t: 4.5,   tipo: "resultado",    vencedor: "jogador" }
```

O cliente interpola os eventos na linha do tempo da animacao. A duracao visual da batalha pode ser ajustada (velocidade 1x/2x/skip) sem afetar o resultado.

#### 17.4.3 Desconexao Durante Batalha

Como a batalha ja foi simulada e registrada no servidor antes de chegar ao cliente, desconexao nao afeta o resultado. O cliente pode rever o log da ultima batalha a qualquer momento.

### 17.5 Dados Autoritativos No Servidor

O cliente **nunca** envia dados que alteram diretamente o estado de jogo. Toda mutacao passa por Edge Function que valida e grava.

| Dado | Autoritativo no servidor |
|---|---|
| Recursos (Almas, Energia, Sangue, Cristais, Diamante) | Sim — nunca aceitos do cliente |
| Level, XP, build (arma/spells/passiva/pet) | Sim |
| Resultado de batalhas e ranking | Sim — simulados no servidor |
| Dados de guilda (contribuicoes, level, membros) | Sim |
| Pool de oponentes para matchmaking | Sim |
| Preferencias de UI, cache de animacao | Local — sem impacto em progressao |
| Producao da base | Calculada no servidor na reconexao (delta de tempo × taxa) |

### 17.6 Matchmaking

O servidor mantem um pool de builds validas — combinacao de builds de jogadores reais e builds simuladas (bots). A cada requisicao de batalha:

1. Calcula o poder do jogador solicitante
2. Filtra o pool dentro de uma faixa de poder (±X — a calibrar)
3. Sorteia um oponente da faixa
4. Se nao houver oponente real disponivel, usa build simulada

**Builds simuladas:** contas-fantasma geradas com combinacoes aleatorias de build dentro de faixas de poder. Marcadas internamente como simuladas — nao aparecem em rankings. Serao populadas antes do alpha para garantir que mesmo com 2 jogadores o loop de batalha funcione.

### 17.7 Ranking

Incluido no primeiro slice. Modelo de pontos de arena (simples, sem ELO completo inicialmente):

- Vitoria: +pontos (variavel por diferenca de poder — vencer mais forte = mais pontos)
- Derrota: -pontos (variavel — perder para mais fraco = mais pontos perdidos)
- Ranking exibido dentro da season atual
- Ao fim da season: snapshot do ranking salvo, pontos resetam

> Formula exata de ganho/perda de pontos: a definir durante prototipagem com dados reais.

### 17.8 Politica Offline

| Situacao | Comportamento |
|---|---|
| Sem internet ao abrir o app | Exibe estado cacheado, desativa batalha e chat, mostra "sem conexao" |
| Producao da base offline | Calculada pelo servidor na proxima conexao — jogador nao perde producao |
| Desconexao durante batalha | Resultado ja foi simulado — cliente busca o log na reconexao |
| Coleta de recursos offline | Servidor calcula acumulo, entrega na reconexao (respeitando limite de armazenamento) |

### 17.9 Anti-Cheat Basico

Prioridades para o tester de seguranca desde o alpha:

| Vetor | Mitigacao |
|---|---|
| Forjar resultado de batalha | Batalha e 100% servidor — cliente nao envia resultado |
| Injetar recursos via requisicao adulterada | Edge Functions validam toda mutacao; cliente nao tem endpoint de "adicionar recursos" |
| Bypass de matchmaking (escolher oponente facil) | Servidor controla selecao de oponente; cliente so solicita batalha |
| Farm abusivo de batalhas | Rate limiting no endpoint de batalha |
| Acesso a dados de outros jogadores | Row Level Security (RLS) do Supabase — cada jogador ve apenas seus proprios dados |
| Engenharia reversa do build do oponente antes da batalha | Servidor retorna apenas o log animavel, nao o build completo do oponente |

### 17.10 Distribuicao Alpha

| Canal | Formato |
|---|---|
| PC (Windows) | Executavel .zip distribuido diretamente |
| Android | APK sideload (sem Play Store no alpha) |
| Acesso | Codigo de convite obrigatorio para criar conta |
| Tamanho do grupo inicial | 2–20 jogadores |

Sem necessidade de conta Google Play Developer ou Apple Developer para o alpha privado.

---

## 15. Em Aberto

- Estilo artistico do jogo
- Hierarquia Draxos (nomes dos postos) — fora do primeiro slice
- Drops de Ossos: fontes e quantidades
- Curva de crescimento de Regen de Vida e Regen de Mana por level
- Sistema de missoes e onboarding — pendencia separada (P novo)
- Valor do Diamante calibrado por categoria de uso
- Conteudo do pacote de remocao de anuncios
- Revisao geral de todos os valores numericos apos definir quests e recompensas — incluindo impacto da guilda na economia
- Escala detalhada de recursos para contribuicoes da guilda e valores dos bonus passivos
- Limite diario de ajudas que um jogador pode dar por dia
- Formula de pontos de arena para ranking (ganho/perda por diferenca de poder)
- Faixa de poder para matchmaking (±X pontos de poder)
- Plano de lancamento, quando houver decisao

---

## 16. Sistema Social

### 16.1 Lista De Amigos

O jogador adiciona amigos por username ou por codigo de convite. Amigos aparecem em uma lista dedicada, podem enviar ajuda em construcoes da base e iniciar conversas diretas via chat.

### 16.2 Sistema De Ajuda Em Construcoes

Toda construcao em andamento exibe um botao **"Pedir Ajuda"**. O jogador pode receber ajuda de membros da guilda e de amigos.

| Parametro | Valor |
|---|---|
| Reducao por ajuda | 1,5% do tempo total da construcao |
| Maximo de ajudas por construcao | 10 |
| Reducao maxima por construcao | 15% do tempo total |

Exemplo: construcao de 100 horas → cada ajuda = -1,5h → maximo -15h = encerra em 85h.

> Limite diario de ajudas que um jogador pode dar por dia: a definir. Deve evitar que um jogador com muitos amigos/guild zere os tempos completamente.

**Impacto na economia:** a reducao de 15% no tempo de construcao alivia levemente o gargalo de Energia. Nao elimina a restricao estrategica — apenas recompensa jogadores socialmente ativos. Incluir na revisao geral de economia apos quests.

### 16.3 Guilda

#### 16.3.1 Estrutura Da Guilda

A guilda e uma organizacao de jogadores com nivel proprio, construcoes coletivas e bônus passivos compartilhados.

**Level da guilda:**
- Avanca por contribuicao coletiva de recursos dos membros
- Funciona como gate duplo: determina o nivel maximo das construcoes da guilda E o limite de membros

**Escala de membros por level:**

| Level da guilda | Membros maximos |
|---|---|
| 1 | 10 |
| 2 | 14 |
| 3 | 18 |
| 4 | 22 |
| 5 | 26 |
| 6 | 30 |
| 7 | 34 |
| 8 | 38 |
| 9 | 44 |
| 10 | 50 |

#### 16.3.2 Construcoes Da Guilda

A guilda possui 4 construcoes proprias, cada uma responsavel por um bônus passivo. Os jogadores contribuem com recursos pessoais para evoluir cada construcao.

| Construcao | Bônus concedido |
|---|---|
| Sala de Rituais | Velocidade de construcao da base pessoal -X% |
| Nucleo Coletivo | Producao de todos os recursos da base pessoal +X% |
| Altar da Batalha | XP de gameplay +X% (bônus leve — nao amplia cota, apenas o rendimento dentro dela) |
| Deposito Ampliado | Limite de armazenamento da base pessoal +X% |

Cada construcao tem **10 levels** (equivalente as passivas pessoais). O level maximo disponivel e limitado pelo level da guilda.

> Valores dos bônus por level (X%) e custos de contribuicao: a calcular na revisao geral de economia apos quests. O impacto precisa ser leve o suficiente para nao tornar a guilda obrigatoria, mas valioso o suficiente para ser um motivador real de engajamento social.

#### 16.3.3 Contribuicao

Os membros da guilda doam recursos pessoais (Almas, Energia, Sangue — a definir quais e em que proporcao) para evoluir tanto o level da guilda quanto cada construcao individualmente. Essa doacão e um sumidouro de recursos intencional que retorna valor coletivo.

### 16.4 Chat

#### 16.4.1 Canais Do Primeiro Slice

| Canal | Incluido no primeiro slice | Notas |
|---|---|---|
| Chat de guilda | Sim | Historico limitado, sem tempo real obrigatorio — polling simples |
| Mensagem direta | Sim | Async — notificacao + mensagem armazenada |
| Chat de amigos | Sim | Equivalente ao direct, filtrado por lista de amigos |
| Chat global | Nao | Externo via Discord enquanto base de jogadores for pequena |

#### 16.4.2 Chat Global — Decisao

Chat global em jogo nao entra no primeiro slice. Os motivos sao operacionais, nao tecnicos:

- Toxicidade e spam exigem moderacao humana em tempo real — custo operacional alto
- Menores jogando criam risco legal em chat publico sem moderacao robusta
- Com base de jogadores pequena o canal seria quase vazio e sem valor
- Discord externo entrega o mesmo valor sem custo de desenvolvimento ou operacao

Reavaliar quando a base de jogadores justificar o investimento em moderacao.

#### 16.4.3 Infraestrutura De Chat

Chat de guilda e direct podem rodar como polling simples para o primeiro slice (cliente pergunta ao servidor a cada 30 segundos se ha mensagens novas). Sem necessidade de WebSocket ate a base de jogadores crescer. Mensagens sao dados pessoais — politica de retencao e deleção necessaria para LGPD/GDPR antes do lancamento publico.

### 16.5 Teste Com Servidor Privado

#### 16.5.1 Builds Inimigas Simuladas

Enquanto nao ha jogadores reais suficientes para matchmaking organico, o sistema gera **builds simuladas** — contas-fantasma com builds aleatorias dentro de faixas de poder. O jogador usa sua propria progressao real; apenas o oponente e simulado.

A geracao de builds simuladas deve:
- Distribuir builds por faixas de poder (early/mid/late)
- Cobrir variedade de combinacoes (spell slot 2, passiva, pet)
- Ser marcadas internamente como simuladas para nao aparecer em rankings

#### 16.5.2 Servidor Privado — Modelo

O servidor privado e tratado como produto real desde o inicio:

| Aspecto | Decisao |
|---|---|
| Criacao de conta | Por codigo de convite — sem registro publico |
| Hosting | VPS dedicado com SSL — nao localhost |
| Persistencia | Cloud desde o primeiro dia — sem save local exclusivo |
| Segurança | Tester de segurança envolvido desde o alpha — ver 16.5.3 |
| Escala inicial | 5–20 jogadores — qualquer VPS de entrada resolve |

#### 16.5.3 Testes De Segurança

Um tester de segurança dedicado participa desde o alpha. Areas prioritarias para o primeiro slice:

- Autenticacao: bypass de conta, forca bruta
- Integridade de dados: pode o cliente enviar um build falso para o servidor?
- Manipulacao de recursos: injecao de Almas/Energia/Sangue via requisicoes adulteradas
- Exposicao de dados: builds e progressao de outros jogadores acessiveis indevidamente
- Rate limiting basico: prevencao de spam de batalhas para farm de recursos

Este trabalho informa diretamente as decisoes de P04 (infraestrutura).
