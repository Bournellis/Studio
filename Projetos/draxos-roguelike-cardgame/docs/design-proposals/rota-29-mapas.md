# Rota de 29 Mapas — Proposta de Design (Sessão A+B)

- Data: `2026-05-18`
- Status: `PROPOSTA — expande a rota atual de 13 mapas; não implementada`
- Sessão: Design Sessions A e B
- Referência: `../game-design-document.md` (rota atual de 13 mapas)
- Referência: `../design-proposals/sessao-a-keywords.md`
- Referência: `../design-proposals/sessao-b-cartas-novas.md`

> **Aviso:** Este documento descreve uma expansão completa do jogo que ainda
> não existe no engine. A rota atual implementada e validada é de 13 mapas.
> Este design é uma proposta de campanha completa — todos os números, inimigos,
> efeitos e formatos de tabuleiro são provisórios e dependem de validação em
> playtest antes de qualquer implementação.

---

## Estrutura Elemental

O jogo é dividido em 4 elementos, cada um com identidade mecânica própria:

| Elemento | Mapas | Tema mecânico |
|---|---|---|
| Terra | 1–8 | Resistência, crescimento lento, punição de ataques |
| Gelo | 9–15 | Congelamento, veneno, obstáculos, mão comprimida |
| Ar | 16–22 | Velocidade, caos posicional, ataques múltiplos |
| Fogo | 23–29 | Dano em área, crescimento explosivo, mortes em cascata |

---

## Princípios de Scaling

### Mana

| Mapa | Evento | Mana máxima |
|---|---|---|
| início | — | 1 |
| 1 | +1 mana (recompensa) | 2 |
| 5 | +1 mana (recompensa) | 3 |
| 16 | +1 mana (recompensa, início do Ar) | 4 |
| 23 | +1 mana (recompensa, início do Fogo) | 5 |

### Limite de Mão

| Mapa | Evento | Limite |
|---|---|---|
| início | — | 3 |
| 6 | +1 limite (recompensa) | 4 |
| 22 | +1 limite (recompensa, boss do Ar) | 5 |

### Slots por Lado

Tutorial: 1/1 → 2/2. Early Terra: 3/3. Mid Terra/Gelo: 4/4. Gelo boss: 5/5.
Ar: 5/5 → 6/6 (boss). Fogo: 5/5 → 6/6 → 7/7 (boss final).

---

## Novos Tipos de Encontro

Além dos 6 tipos existentes (`limpar_mesa`, `ondas`, `duelo`, `defesa_posicao`,
`sobreviver_turnos`, `chefe_summoner`), esta proposta adiciona 3 novos:

### Emboscada

O jogador inicia o combate com a mão cheia mas com 0 mana no turno 1 — não pode
jogar nenhuma carta. O inimigo tem iniciativa total no turno 1 com o campo já
preenchido. A partir do turno 2, o fluxo retorna ao normal. Força o jogador a
absorver pressão com o campo vazio e reagir sob desvantagem.

Introduzido no mapa 20 (Ar, combinado com Tabuleiro de Flanco).

### Escolta

Existe um Cargo (0/6, sem ataque, sem keywords) no slot 1 aliado. A cada turno
que o Cargo sobrevive, ele tenta avançar um slot em direção ao campo inimigo. Se
o slot à frente estiver ocupado, o Cargo não avança. Quando o Cargo alcança o
slot mais avançado do campo inimigo, vitória. O inimigo prioriza atacar o Cargo.
O jogador deve limpar um caminho slot a slot enquanto protege o Cargo de dano.

Introduzido no mapa 25 (Fogo, com Tabuleiro Frente e Retaguarda).

### Invasão

Tabuleiro 6/6 com dois grupos inimigos independentes: Grupo A ocupa slots 1–3,
Grupo B ocupa slots 4–6. Os grupos não se reforçam entre si. No turno 3 e no
turno 5, um portal invoca 2 criaturas adicionais no grupo com menor presença no
campo. O jogador deve decidir qual flanco priorizar sabendo que o outro vai crescer.

Introduzido no mapa 28 (Fogo, penúltimo antes do boss final).

---

## Novos Formatos de Tabuleiro

### Formato Padrão (atual)
N×N simétrico. Lanes retas. Combate frontal simples.
Usado em: a maioria dos mapas.

### Formato Assimétrico
Jogador tem N slots, inimigo tem N+1. A lane extra do inimigo não tem oponente
frontal: a criatura ali causa dano direto ao jogador por turno se não houver
Defensor aliado cobrindo. Força uso estratégico de Defensor como cobertura
lateral, não só frontal.
Introduzido no mapa 13 (Gelo, `defesa_posicao`).

### Formato Núcleo Central
5×5 com slot 3 marcado como Núcleo. Criaturas no Núcleo ganham +1 ATK enquanto
ali. A criatura inimiga no Núcleo também causa +1 de dano direto ao jogador por
turno. Ambos os lados competem pelo controle do slot central.
Introduzido no mapa 18 (Ar, `limpar_mesa`).

### Formato de Flanco
4×4 base mais 1 slot de flanco em cada extremidade (6 posições inimigas, 4 do
jogador). Criaturas nos flancos inimigos atacam a lane mais lateral. Se a borda
aliada estiver vazia, o dano vai direto ao jogador, bypassando Defensores centrais.
Introduzido no mapa 20 (Ar, `emboscada`).

### Formato Frente e Retaguarda
Dois rows por lado: frente (3 slots) e retaguarda (2 slots). Criaturas na
retaguarda só atacam se a lane à sua frente estiver vazia. Criaturas na
retaguarda são protegidas de dano frontal enquanto houver frente. Auras passivas
(Inspirar, Pacto) funcionam normalmente na retaguarda.
Introduzido no mapa 25 (Fogo, `escolta`).

### Formato do Abismo
7×7. O maior tabuleiro do jogo. Reservado para o boss final (mapa 29). O boss
começa com criaturas em todos os 7 slots; o jogador tem acesso a 7 slots pela
primeira vez na run.

---

## Novos Efeitos de Campo

### Terra

**Terreno Rochoso** *(mapa 7)*
Criaturas com HP ≤ 2 invocadas nos slots laterais (1 e N) recebem -1 ATK
enquanto o efeito estiver ativo. Pune enxames nas bordas.

**Chão Vivo** *(mapa 8, boss)*
No início do turno inimigo, uma criatura inimiga aleatória em campo ganha +0/+1
permanente. O boss fica progressivamente mais difícil de matar.

### Gelo

**Geada** *(mapa 11)*
No início de cada turno do jogador, 1 criatura aliada aleatória em campo fica
Congelada (não ataca nesse ciclo). Criaturas com Imune não são afetadas.

**Corrente Submersa** *(mapa 12)*
Criaturas aliadas não podem ser movidas nem trocadas de slot durante o combate.
Bloqueia movimento e swap inteiramente.

**Tabuleiro Instável** *(mapa 13)*
A cada 2 turnos, 1 slot aleatório em campo (aliado ou inimigo) fica "congelado":
a criatura nele não ataca e não recebe dano frontal naquele turno. Descongela
no turno seguinte.

**Frio Intenso** *(mapa 14)*
Criaturas que morrem em campo não disparam efeitos ao morrer (Suicida, Enfraquecer
ao morrer, deathrattles de Flagelo). Counter direto do Necromante e de todos os
efeitos de morte do jogador.

**Nevasca** *(mapa 15, boss)*
O limite de mão do jogador é reduzido em 1 enquanto o efeito estiver ativo.
Menos opções por turno, menos cartas para responder ao boss.

### Ar

**Ventania** *(mapa 17)*
No início do turno inimigo, 1 criatura inimiga aleatória troca de slot com a
adjacente. As lanes inimigas se reorganizam constantemente.

**Slot Central Amplificado** *(mapa 18, Formato Núcleo Central)*
Criaturas no slot 3 ganham +1 ATK. A criatura inimiga no slot 3 causa +1 de
dano direto ao jogador por turno.

**Relâmpago** *(mapa 19)*
No início de cada turno, 1 criatura em campo (aliada ou inimiga, aleatória) é
atingida por um relâmpago e recebe 2 de dano imediato antes de qualquer jogada.

**Turbulência** *(mapa 21)*
Criaturas invocadas durante o encontro entram com -1 HP (mínimo 1). Criaturas
frágeis chegam quase mortas; favorece criaturas grandes com Escudo ou Resistência.

**Olho da Tempestade** *(mapa 22, boss)*
Fase 1 (turnos 1–3): sem efeito de campo. Fase 2 (turno 4+): Ventania e
Relâmpago ativam simultaneamente.

### Fogo

**Brasa Viva** *(mapa 23)*
No fim de cada ciclo de combate, todas as criaturas com HP ≤ 1 em campo recebem
1 de dano automático. Encerra atrito prolongado.

**Inferno** *(mapa 24)*
No início do turno inimigo, 1 criatura aliada aleatória recebe Veneno 1. O
Veneno acumula ao longo das ondas.

**Piso de Lava** *(mapa 25, Escolta)*
Criaturas na retaguarda aliada recebem 1 de dano por turno passivo. Força uso
eficiente da retaguarda.

**Fúria do Abismo** *(mapa 26)*
Cada vez que uma criatura inimiga morre, o herói inimigo invoca criaturas com
+1 ATK extra naquele turno. Matar inimigos rápido é bom mas empodera os próximos.

**Cinzas Vivas** *(mapa 27)*
Ao morrer, qualquer criatura (aliada ou inimiga) com HP base ≥ 3 deixa uma Brasa
(token 1/1 sem keywords) no slot. O campo nunca fica realmente vazio.

**Portal Aberto** *(mapa 28, Invasão)*
No turno 3 e no turno 5, o portal invoca 2 criaturas inimigas adicionais no
grupo com menor presença no campo.

**Inferno Total** *(mapa 29, boss final)*
Todos os efeitos do Fogo em versão reduzida simultaneamente: Brasa Viva (HP ≤ 2),
Veneno 1 aleatório por turno, criaturas mortas com HP base ≥ 4 deixam Brasa 1/1.

---

## Tabela dos 29 Mapas

### Terra (1–8)

| # | Nome | Modo | Slots | Mana | Efeito de Campo | Criaturas Inimigas (proposta) | Recompensa |
|---|---|---|---|---|---|---|---|
| 1 | Primeira Queda | limpar_mesa | 1/1 | 1 | — | Elemental de Areia 2/2 | +1 mana máx |
| 2 | Dois Fronts | limpar_mesa | 2/2 | 2 | — | Areia 2/2 · Pedra 1/4 | 3× carta custo 2 |
| 3 | Primeira Onda | ondas | 2/2 | 2 | — | O1: 2× Areia 1/2 · O2: 2× Pedra 2/3 · O3: Tita 3/4 + Bruto 2/4 | upgrade 1/3 |
| 4 | Pouso Elemental | limpar_mesa | 3/3 | 2 | — | Ágil 2/2 · Bruto 3/3 · **Golem Espinhos 1** 1/5 | upgrade 1/3 |
| 5 | Ondas da Terra | ondas | 3/3 | 2 | — | O1: 2× Areia · O2: Pedra + Ágil · O3: Tita + **Verme Atropelar 2/3** + Bruto | +1 mana máx |
| 6 | Senhor da Terra | duelo | 3/3 | 3 | — | Herói **Senhor da Terra** 15HP · Muro 0/5 Defensor · Pedra 2/4 | +1 limite mão |
| 7 | Fortim de Pedra | defesa_posicao | 3/3 | 3 | **Terreno Rochoso** | Ágil 2/2 · **Verme Atropelar 2/3** · **Rocha Viva Crescer+1 1/3** | carta nova 1/2 |
| 8 | Primordial de Terra | chefe_summoner | 5/5 | 3 | **Chão Vivo** | Boss 30HP · Guerreiro I 3/3 · Golem E2 1/5 · Rocha Viva C1/3 · summons: Tita 3/5 · Granito R2 2/7 | passiva da classe |

### Gelo (9–15)

| # | Nome | Modo | Slots | Mana | Efeito de Campo | Criaturas Inimigas (proposta) | Recompensa |
|---|---|---|---|---|---|---|---|
| 9 | Tundra | limpar_mesa | 4/4 | 3 | — | **Cristal de Gelo** 1/4 Escudo · Gelo 2/3 · Gelo 2/3 · **Golem de Gelo** R1 2/5 | upgrade 1/3 |
| 10 | Câmara Glacial | limpar_mesa | 4/4 | 3 | — | Gelo 2/3 Congelar-ao-atacar · **Djinn do Frio** C+1 2/3 · Golem R1 2/5 · Cristal Escudo 1/4 | habilidade ativa |
| 11 | Blizzard | ondas | 4/4 | 3 | **Geada** | O1: 3× Gelo Congelar · O2: Cristal + Djinn · O3: **Espírito da Geada** 1/2 V1 + Golem R1 + Gelo | carta nova restante |
| 12 | Duelo do Djinn | duelo | 4/4 | 3 | **Corrente Submersa** | Herói **Djinn de Gelo** 20HP · invoca Cristais · usa Veneno Gélido | upgrade 1/3 |
| 13 | Labirinto de Gelo | defesa_posicao | **4/5 assim.** | 3 | **Tabuleiro Instável** | **Coluna de Gelo** 0/8 R3 · Cristal Escudo · Djinn C+1 · Gelo Congelar · Golem R1 | carta nova 1/2 |
| 14 | Vanguarda Glacial | sobreviver_turnos | 4/4 | 3 | **Frio Intenso** | 5 turnos · **Fênix de Gelo** 3/3 Ressurgir · Djinn C+1 · Gelo Congelar · turno 3: Golem R2 2/7 | upgrade 1/3 |
| 15 | Ancião do Gelo | chefe_summoner | 5/5 | 3 | **Nevasca** | Boss 35HP · 2× Cristal Escudo · Golem R1 · summons: Coluna R3 · turno 4: Veneno Global · turno 5: Fênix Ressurgir 3/3 | +1 slot permanente |

### Ar (16–22)

| # | Nome | Modo | Slots | Mana | Efeito de Campo | Criaturas Inimigas (proposta) | Recompensa |
|---|---|---|---|---|---|---|---|
| 16 | Planícies do Vento | limpar_mesa | 4/4 | **4** | — | **Elemental de Vento** 3/2 I+mobile · **Silfo Ecoar** 2/2 I · **Brisa Mortal** 1/1 Frenesi | +1 mana máx |
| 17 | Rajadas | ondas | 4/4 | 4 | **Ventania** | O1: 3× Brisa Frenesi · O2: Silfo Ecoar + Vento I · O3: **Tempestade Vivente** Brutal 3/3 + Silfo + Vento | carta nova Ar (1/2) |
| 18 | Núcleo do Ciclone | limpar_mesa | **5/5 Núcleo** | 4 | **Slot Central Amplif.** | 4× Corvo 1/1 Frenesi · **Tempestade Brutal** 3/3 no slot 3 | upgrade 1/3 |
| 19 | Câmara do Trovão | duelo | 5/5 | 4 | **Relâmpago** | Herói **Senhor dos Ventos** 22HP · Ventania · **Elemental do Raio** 4/2 I Atropelar | +1 mana máx |
| 20 | Emboscada das Nuvens | **emboscada** | **4/4+Flancos** | 4 | **Tabuleiro de Flanco** | Turno 1: player sem mana · Flancos: Rajada 4/2 I Atropelar · Centro: 4× Brisa Frenesi | carta nova Ar restante |
| 21 | Tempestade Eterna | sobreviver_turnos | 5/5 | 4 | **Turbulência** | 6 turnos · Silfo Ecoar · Tempestade Brutal · Raio I Atropelar · turno 3: +2 reforços | upgrade 1/3 |
| 22 | Soberano das Tempestades | chefe_summoner | **6/6** | 4 | **Olho da Tempestade** | Boss 40HP · 3× Vento I mobile · summons: Silfo + Tempestade · turno 4: Fase 2 · turno 6: Forma Final 5/10 Ecoar | +1 limite mão |

### Fogo (23–29)

| # | Nome | Modo | Slots | Mana | Efeito de Campo | Criaturas Inimigas (proposta) | Recompensa |
|---|---|---|---|---|---|---|---|
| 23 | Campos em Chamas | limpar_mesa | 5/5 | **5** | **Brasa Viva** | **Salamandra** 2/2 E2+C+1 · **Chama** Brutal 3/3 · **Golem de Lava** R2 2/6 | +1 mana máx |
| 24 | A Fornalha | ondas | 5/5 | 5 | **Inferno** | O1: 3× Chama Brutal · O2: Salamandra+Golem R2 · O3: **Demônio** 5/3 Fúria [ao morrer: 2× Fragmento 2/1] | carta nova Fogo (1/2) |
| 25 | Rio de Lava | **escolta** | **5/5 Fr+Ret** | 5 | **Piso de Lava** | Frente: 3× Chama Brutal · Retaguarda: 2× Salamandra E2+C+1 · Cargo 0/6 aliado | upgrade 1/3 |
| 26 | Duelo do Demônio | duelo | 5/5 | 5 | **Fúria do Abismo** | Herói **Demônio Primordial** 25HP · invoca Fragmento ao levar dano · usa Explosão (3+1 adjacentes) | carta nova Fogo restante |
| 27 | Renascimento | ondas | 5/5 | 5 | **Cinzas Vivas** | O1: 2× Chama + Salamandra · O2: Golem Lava + Demônio Fúria · O3: **Fênix** 4/4 Ressurgir+Fúria + Demônio [ao morrer: Fragmentos] | upgrade 1/3 |
| 28 | Portal do Caos | **invasão** | **6/6** | 5 | **Portal Aberto** | Grupo A (1–3): Golem R2 + 2× Chama · Grupo B (4–6): Fênix Ressurgir + Salamandra + Demônio Fúria · portais no turno 3 e 5 | upgrade de classe |
| 29 | Dragão Primordial | chefe_summoner | **7/7** | 5 | **Inferno Total** | Boss **Dragão** 50HP · Fase 1: Golem R2 + Fênix + Demônio Fúria · Fase 2 (HP≤35): Brutal+Atropelar pessoalmente · Fase 3 (turno 8+): todas inimigas ganham Fúria | VITÓRIA |

---

## Galeria de Criaturas Inimigas Propostas

### Terra

| Criatura | Stats | Keywords | Identidade |
|---|---|---|---|
| Elemental de Areia | 2/2 | — | Fodder básico |
| Elemental de Pedra | 1/4 | — | Tanque passivo |
| Elemental Ágil | 2/2 | — | Pressão de dano |
| Elemental Bruto | 3/3 | — | Ameaça frontal |
| Golem de Terra | 1/5 | Espinhos 1 | Pune ataques diretos |
| Guerreiro de Terra | 3/3 | Iniciativa | Pressão rápida |
| Verme da Terra | 2/3 | Atropelar | Dano que atravessa |
| Elemental Tita | 3/4–3/5 | — | Elite resistente |
| Elemental de Rocha Viva | 1/3 | Crescer +1 | Ameaça crescente por turno |
| Elemental de Granito | 2/7 | Resistência 2 | Tanque verdadeiro |

### Gelo

| Criatura | Stats | Keywords | Identidade |
|---|---|---|---|
| Cristal de Gelo | 1/4 | Escudo | Requer dois ataques para matar |
| Elemental de Gelo | 2/3 | Congelar ao atacar | Trava aliados que o atacam |
| Golem de Gelo | 2/5 | Resistência 1 + Congelar ao morrer | Tank que pune quem o mata |
| Djinn do Frio | 2/3 | Crescer +1 | Ameaça que piora se ignorada |
| Espírito da Geada | 1/2 | Veneno 1 | Dano ao longo do tempo |
| Fênix de Gelo | 3/3 | Ressurgir (1/1) | Precisa ser morta duas vezes |
| Coluna de Gelo | 0/8 | Resistência 3 | Bloqueador imóvel, obstrói lane |

### Ar

| Criatura | Stats | Keywords | Identidade |
|---|---|---|---|
| Elemental de Vento | 3/2 | Iniciativa + mobile (troca lane/turno) | Alvo escorregadio |
| Silfo | 2/2 | Iniciativa + Ecoar | Dano que repete uma vez |
| Brisa Mortal | 1/1 | Frenesi | Ataca duas vezes; morre fácil |
| Tempestade Vivente | 3/3 | Brutal | Dano lateral constante |
| Corvo da Tormenta | 1/1 | Frenesi | Em grupo: caos de ataques rápidos |
| Elemental do Raio | 4/2 | Iniciativa + Atropelar | Perfura com velocidade |
| Rajada | 4/2 | Iniciativa + Atropelar | Versão agressiva de flanco |

### Fogo

| Criatura | Stats | Keywords | Identidade |
|---|---|---|---|
| Elemental de Chama | 3/3 | Brutal | Pressão lateral constante |
| Salamandra | 2/2 | Espinhos 2 + Crescer +1 | Pune ataques e cresce |
| Golem de Lava | 2/6 | Resistência 2 + ao morrer: Explosão (2 adj.) | Explode ao ser removido |
| Demônio de Chama | 5/3 | Fúria + ao morrer: 2× Fragmento 2/1 | Cresce ao ser atacado; deixa rastro |
| Fragmento de Chama | 2/1 | — | Token; pressão de números |
| Fênix | 4/4 | Ressurgir (2/2) + Fúria | Persiste e cresce após ressurgir |

---

## Requisitos de Implementação

### Mecânicas que o engine já suporta (só precisam de dados novos)
Espinhos · Crescer · Resistência · Escudo · Atropelar (modelo de excesso de dano)
Frenesi · Ecoar · Ressurgir · Inspirar

### Mecânicas que precisam de sistema novo localizado
Congelar como keyword de criatura (variante do Prender existente) · Veneno com
marcador e tick periódico · Brutal com dano lateral · `on_enter` para criaturas
com Entrar · mobile (swap de lane por trigger de turno)

### Mecânicas que precisam de mudanças no board/encontro
Tabuleiro Assimétrico (slot counts diferentes por lado) · Núcleo Central (slot com
propriedade especial) · Tabuleiro de Flanco (slots extras fora do eixo) · Tabuleiro
Instável (estado de slot por turno) · Frente e Retaguarda (segunda row com lógica
de combate distinta)

### Novos tipos de encontro
Emboscada (mana 0 no turno 1) · Escolta (objetivo que move e deve cruzar o campo)
Invasão (dois grupos independentes + portal de reforço)
