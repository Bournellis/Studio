# Mobile Universe — Game Design Document

- Ultima atualizacao: `2026-05-18`
- Status: `P1_CONCEITO`
- Substitui: `RPGMobile`, `BattleMobile`

---

## 1. Visao Do Projeto

Mobile Universe e um projeto mobile multi-partes. Os modos serao implementados ao longo do tempo, mas ainda nao existe decisao de lancamento, ordem comercial, formato de temporadas, expansoes ou separacao por apps.

Todos os modos pertencem a um unico ecossistema com conta, personagem, base e progressao conectadas. O Base Manager e a fundacao que conecta os modos, mas cada modo pode ter intensidade diferente de ligacao com a base.

O primeiro slice nao e tratado como prototipo isolado. Ele deve conter Character Autobattler PVP simples, Base Manager, lista de amigos e guilda. Tambem deve ser pensado com infraestrutura seria desde o inicio: conta, persistencia, progressao compartilhada, backend para batalha assincrona, matchmaking por poder semelhante e base para recursos sociais.

---

## 2. Fantasia Central

O jogador e um mago intergalatico maligno que comeca fraco e cresce em poder ate se tornar uma ameaca cosmica.

O jogador nao e o heroi. O jogador e o vilao.

Referencias de estetica e personalidade: Sauron, Palpatine, Darth Vader, Morgott.

**Estilo visual:** gore, sangue e violencia em estilo cartoon e animado. Sem realismo. O tema do mundo e os detalhes ficcionais ainda serao definidos.

### 2.1 Lore De Fundo

O personagem pertence a uma civilizacao hiper avancada, nada conectada com a realidade humana contemporanea. Esses seres vivem de pura energia. Eles nao precisam viajar fisicamente: basta conhecerem o lugar para onde querem ir.

O grupo ao redor do personagem pertence a uma tradicao de magos caidos ha muito tempo.

Esse lore profundo existe como base de direcao, mas quase nada disso deve ser explicado ao jogador no inicio.

---

## 3. O Personagem

O mago e o personagem central em todos os modos. Ele comeca iniciante em cada modo e cresce por meio da progressao propria daquele modo.

### 3.1 Estilo Inicial

No inicio, o projeto deve ignorar a possibilidade de classes e entregar apenas um estilo de mago jogavel.

Classes de mago podem existir no futuro, mas ainda nao estao definidas. Nao ha regras aprovadas para como elas funcionam, se alteram arma, itens, habilidades, cartas, base, visual ou matchmaking.

Para o primeiro marco, qualquer decisao de sistema deve assumir:

- um unico mago jogavel;
- uma identidade inicial clara;
- variedade por arma e spells;
- skins para o mago;
- 1 arma, 3 spells e 2 passivas com level up simples;
- itens, pocoes, pets e arvores de upgrade mais elaboradas apenas como possibilidades futuras;
- nenhum requisito de suportar Guerreiro, Assassino ou outros arquetipos nao magicos.

### 3.2 Possibilidades Futuras

Variacoes futuras de mago podem ser exploradas depois que o loop Base Manager + Character Autobattler PVP estiver claro. Essas variacoes nao devem guiar a arquitetura inicial alem de manter dados e conteudo organizados o suficiente para evoluir sem reescrever tudo.

---

## 4. Os Modos

### 4.1 Base Manager *(Primeiro Slice)*

**Tipo:** tela de cidade/base permanente, social
**Referencias:** Hero Wars, Clash of Clans, Whiteout Survival, Top Heroes

O jogador expande a base/cidade do mago por uma tela com botoes animados e pontos de upgrade, proxima da leitura de Hero Wars. Nao e um grid de construcao em que o jogador escolhe onde posicionar edificios.

A base produz recursos e upgrades. No primeiro slice, o foco e evoluir arma, spells e passivas. Itens, buffs, consumiveis, pocoes e pets ficam como possibilidades futuras.

**Funcoes:**
- Upgrade de estruturas, botoes, sistemas ou edificios representados na tela
- Upgrade de arma, spells e passivas para o Character Autobattler
- Lista de amigos
- Guilda com ajuda coletiva
- Recebimento de ajudas vindas da guilda
- Recebimento de recursos bonus vindos das batalhas PVP
- Contribuicao para o Level Global da conta

**Progressao:** permanente e continua. A base nunca reseta.

**Papel no fluxo:** comeca como a expressao concreta do plano de progressao complexo do Character Autobattler PVP. Ao longo do tempo, vira a base economica do ecossistema inteiro.

**Conexao:** conexao alta com Character Autobattler PVP e Character Autobattler PVE. Conexao mais leve com PVP Cardgame Roguelike, Hero Defense e Open World RPG.

### 4.1.1 Economia Basica Do Primeiro Slice

O primeiro slice deve comecar simples e crescer aos poucos.

Recurso PVP inicial:

- **Almas:** recurso recebido ao vencer batalhas PVP.

Derrota PVP:

- nao existe perda de recursos;
- a perda principal e tempo;
- se o jogador perder, fica sem recompensa da batalha.

Controle anti-abuso:

- o jogador pode batalhar indefinidamente;
- nao ha custo de entrada definido para jogar PVP no primeiro desenho;
- as recompensas de Almas reduzem conforme o jogador repete batalhas dentro de uma janela de tempo;
- em algum ponto, a recompensa chega a zero;
- mesmo com recompensa zerada, o jogador ainda pode batalhar.

Upgrades iniciais:

- 1 arma com level up;
- 3 spells com level up;
- 2 passivas com level up.

Escopo futuro de progressao:

- outras armas;
- outras spells;
- outras passivas;
- pocoes;
- pets;
- outros recursos;
- arvore de upgrades mais elaborada do que level up simples.

Esses sistemas futuros devem ser considerados como possibilidades, mas nao precisam ser definidos agora.

Amigos e guilda:

- inicialmente ajudam dando uma forca leve na evolucao;
- essa ajuda e a "maozinha" social do primeiro slice;
- detalhes e limites ainda serao definidos.

---

### 4.2 Character Autobattler — PVP *(Primeiro Slice)*

**Tipo:** Arena Mobile Assincrona PVP
**Referencia principal:** Hero Wars
**Referencia de apresentacao:** Mortal Kombat classico

O mago do jogador, equipado com arma, spells, passivas e skins, entra em um duelo simples contra o mago de outro jogador de poder semelhante. E onde todo o trabalho do Base Manager se materializa em poder de combate real.

Ao contrario de Hero Wars, o jogador nao monta uma equipe. Existe apenas um personagem principal. A variedade inicial de combate vem da arma equipada, das spells escolhidas, das passivas e das skins. Itens e outros upgrades podem entrar no futuro.

A apresentacao da batalha deve lembrar um jogo de luta classico em sidescroller, com os dois personagens em lados opostos da tela.

Ao vencer, o jogador assiste a uma finalizacao brutal escolhida entre as finalizacoes desbloqueadas para o personagem.

**Funcoes:**
- Duelo assincrono PVP entre dois magos equipados
- Matchmaking por forca semelhante
- Defesa offline do mago do jogador
- Reflexo direto do nivel, equipamentos, spells e producao do Base Manager
- Finalizacoes brutais desbloqueaveis e escolhidas pelo jogador depois da vitoria

**Progressao:** comeca como o primeiro modo jogavel e possui um plano de progressao complexo. Esse plano deve evoluir para a primeira versao do Base Manager e da economia. No primeiro slice, o nivel da arma, das spells e das passivas vem da progressao da conta/base.

**Producao:** gera recursos bonus para o Base Manager.

**Recompensa inicial:** ao vencer PVP, o jogador ganha Almas. Ao perder, nao perde recursos, mas tambem nao recebe recompensa.

**Conexao:** conexao alta com Base Manager.

---

### 4.3 Character Autobattler — PVE *(Futuro)*

**Tipo:** batalha automatica PVE com ultimate/spells acionaveis
**Referencia principal:** Hero Wars

O mago enfrenta variedade de criaturas em batalhas automaticas PVE. Diferente do PVP simples, o PVE pode ter botao de ultimate e 1 a 3 botoes de spell acionaveis pelo jogador.

O modo expande o sistema de batalha do Character Autobattler com conteudo PVE progressivo, estrutura de missoes e a historia/tema descritos na primeira temporada narrativa.

### 4.3.1 Primeira Temporada Narrativa

No Character Autobattler PVE, o jogador controla um jovem mago em inicio de carreira dentro de uma sociedade de magos organizada de forma hierarquica, disciplinada e operacional. A intencao e parecida com uma carreira militar, mas os termos "guerreiro" e "militar" ainda nao definem bem o tema de magia e precisam de nomenclatura melhor.

O comeco do PVE sera dividido em missoes entregues ao personagem como iniciante dessa carreira. Ao longo do primeiro grande arco, o jogador ascende nessa hierarquia ate se tornar equivalente a um general, obedecendo apenas ao mestre supremo.

No fim do primeiro grande arco, o personagem se rebela contra o mestre supremo e comeca sua aventura solo pelo espaco.

Essa estrutura e tratada como a primeira temporada narrativa do PVE, mesmo que a duracao exata ainda esteja indefinida.

**Papel estrategico:** constroi o sistema de combate e banco de criaturas que o Open World futuro vai reutilizar.

**Producao:** gera recursos para o Base Manager.

**Conexao:** conexao alta com Base Manager. E um modo que o jogador upa junto com a base de verdade.

---

### 4.4 PVP Cardgame Roguelike *(Futuro)*

**Tipo:** PVP cardgame roguelike
**Referências:** The Bazaar (versao simplificada para mobile)

O jogador entra em uma run roguelike de cartas com componente PVP. Escolhe cartas para comprar na loja. Decide quais cartas ficam na **mesa** (ativas nas batalhas) e quais ficam na **mao** (disponiveis para uso futuro). Batalha perdida custa uma vida. X vitorias vencem a run.

**Progressao em dois layers:**
- *Dentro da run:* temporaria — cartas, upgrades e poder resetam ao fim da run.
- *Entre runs:* permanente — meta-progressao que acumula entre runs (desbloquear novas cartas no pool, melhorar condicoes iniciais, bônus passivos, etc.).

**Conexao:** possui progressao propria. Recebe apenas pequenos beneficios de Level Global e de uma base bem evoluida.

---

### 4.5 Hero Defense *(Futuro)*

**Tipo:** defesa contra hordas / tower defense com o mesmo personagem
**Referências:** Evil Tower

O mesmo mago principal enfrenta hordas em um modo de defesa/tower defense. Hordas atacam e o jogador usa upgrades e botoes com cooldown para sobreviver.

**Dois sistemas de upgrade independentes:**

1. **Tokens de monstros:** ganhos continuamente por matar inimigos. Gastos livremente a qualquer momento em upgrades de stats (granular, decisao tatical rapida).
2. **Buff de escolha:** a cada X waves ou X tempo, o jogador escolhe 1 de 3 buffs permanentes mais fortes para aquela run (decisao estrategica de peso maior).

**Progressao em dois layers:**
- *Dentro da run:* temporaria — tokens, upgrades e buffs escolhidos resetam ao fim da run.
- *Entre runs:* permanente — meta-progressao que acumula entre runs.

**Conexao:** possui progressao propria. Recebe apenas pequenos beneficios de Level Global e de uma base bem evoluida.

---

### 4.6 Open World RPG *(Futuro / projeto maior)*

**Tipo:** RPG singleplayer de mundo aberto
**Referências:** Butcher Hero e similares

Expande o personagem e o sistema de combate construido nos modos anteriores para um mundo aberto exploravel. O jogador coleta recursos, mata monstros e participa de um mundo vivo.

**Status atual:** sem capacidade de producao agora. Deve ser considerado na arquitetura desde o inicio pois e extremamente importante caso o projeto tenha sucesso.

**Fluxo de recompensas:** a ser definido quando o projeto se aproximar desta etapa.

**Conexao:** possui progressao propria. Recebe apenas pequenos beneficios de Level Global e de uma base bem evoluida.

---

## 5. Progressao

### 5.1 Dentro dos modos roguelite

Modos futuros com estrutura de run ou progressao propria podem ter dois layers:

| Layer | Escopo | Comportamento |
|---|---|---|
| Progressao de run | Dentro da run | Temporaria — reseta ao fim da run |
| Meta-progressao | Entre runs | Permanente — acumula ao longo do tempo |

O mago comeca iniciante em cada modo e cresce pela meta-progressao propria daquele modo.

### 5.2 Base Manager

Progressao permanente e continua. A base nunca reseta. Cresce pelo recebimento de recursos dos modos roguelite.

### 5.3 Level Global

Representa o proprio jogador como personagem. Cresce lentamente com contribuicoes de todos os modos.

- Nao e o foco de nenhum modo especifico.
- Concede bônos gerais e leves em todos os modos.
- E mais um indicador de progressao de conta do que uma fonte de poder.

---

## 6. Fluxo De Recursos E Conexao Entre Modos

```
PVP Autobattler ──► Almas ──► Base Manager ──► arma, spells, passivas ──► PVP/PVE Autobattler
Guilda/Amigos   ──► ajudas sociais ──► Base Manager
PVE Autobattler ──► recursos fortes ─► Base Manager

PVP Cardgame Roguelike ──► progressao propria + pequenos beneficios de conta/base
Hero Defense            ──► progressao propria + pequenos beneficios de conta/base
Open World RPG          ──► progressao propria + pequenos beneficios de conta/base

Todos os modos ──► Level Global ──► bonus leves em tudo
```

**Regras do fluxo:**
- Character Autobattler PVP e Character Autobattler PVE tem conexao alta com Base Manager.
- O Base Manager original tem recursos proprios, ajudas vindas da guilda e recursos bonus vindos das batalhas PVP.
- PVP Cardgame Roguelike, Hero Defense e Open World RPG tem progressao propria.
- PVP Cardgame Roguelike, Hero Defense e Open World RPG recebem apenas pequenos beneficios de Level Global e de uma base bem evoluida.
- O Level Global recebe contribuicoes de todos e distribui apenas bonus leves.

---

## 7. Plano De Producao E Lancamento

Nao existe decisao de lancamento, ordem comercial, formato de temporada, expansao ou separacao por app.

O que existe e um plano conceitual de producao:

| Marco | Conteudo | Observacao |
|---|---|---|
| **Primeiro slice** | Character Autobattler PVP + Base Manager + amigos + guilda | Slice inicial com duelo PVP simples, economia/base e conexao social |
| **Evolucao do slice** | Progressao complexa do PVP virando economia/base mais robusta | O plano de progressao do PVP se transforma na primeira versao real do Base Manager |
| **Futuro** | Character Autobattler PVE | Batalha automatica com ultimate/spells, missoes e primeira temporada narrativa |
| **Futuro** | PVP Cardgame Roguelike | Progressao propria com beneficios leves de conta/base |
| **Futuro** | Hero Defense | Tower defense/hordas com o mesmo mago, upgrades e botoes com cooldown |
| **Futuro maior** | Open World RPG | Progressao propria com beneficios leves de conta/base |

Essa tabela nao e uma promessa de lancamento. E apenas a ordem conceitual atual para pensar o desenvolvimento.

---

## 8. Em Aberto

- Nome do projeto e dos modos
- Nomenclatura da carreira magica inicial, substituindo os termos aproximados "guerreiro" e "militar"
- Identidade do primeiro estilo de mago jogavel
- Possibilidade futura de classes de mago e como elas funcionariam
- Detalhamento das regras de batalha do Character Autobattler (mecanica de combate, matchmaking)
- Como o plano de progressao do PVP vira Base Manager e economia
- Curva de reducao de recompensa PVP ate zerar
- Janela de tempo para resetar ou recuperar recompensas PVP
- Quais ajudas sociais vem de amigos e guilda
- Quais pequenos beneficios Level Global/base concedem aos modos com progressao propria
- Fluxo de recompensas do Open World
- Plano de lancamento, quando houver decisao
