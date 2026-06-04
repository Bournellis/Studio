# Keywords — Propostas de Design (Sessão A)

- Data: `2026-05-18`
- Status: `HISTORICO/PROMOVIDO - keywords listadas foram implementadas na Track 02`
- Sessão: Design Session A
- Referência de uso: `../design-proposals/sessao-b-cartas-novas.md`, `../design-proposals/rota-29-mapas.md`

> **Aviso:** Este documento registra a origem de design das keywords. A Track 02
> promoveu as keywords para o engine; o contrato atual vive no GDD, no JSON e nos
> testes. Use os numeros abaixo apenas como contexto historico.

## Keywords Existentes (Referência)

Já implementadas no engine — listadas aqui apenas para contexto:

`iniciativa` · `defensor` · `reviver` · `regeneracao X` · `carnica X` · `suicida X` · `enfraquecer X` · `prender` · `remover keywords` · `poder de habilidade`

---

## Keywords Propostas

### Categoria 1 — Dano e Pressão Ofensiva

**Atropelar**
O dano excedente desta criatura continua para o próximo alvo válido na lane — a
criatura atrás, depois o herói inimigo se aplicável no modo. Se não houver alvo,
o dano excedente se perde.
- Elemento temático: Terra (criaturas grandes), Fogo (futuro)
- Arquétipo: criatura grande que "vale a pena" mesmo com bloqueador fraco na frente
- Implementação: média — calcula excedente e retransmite na mesma fase de combate
- Prioridade: **1 (alta)**

**Brutal**
Quando esta criatura ataca e causa dano ao alvo frontal, também causa 1 de dano
a cada lane inimiga adjacente. Não causa dano ao herói inimigo diretamente.
- Elemento temático: Terra (Elemental de pedra chacoalhando o chão), Fogo
- Arquétipo: pressão lateral, inimigo que pune mesas cheias
- Implementação: média — dano lateral vai para criaturas nos slots adjacentes
- Prioridade: **1 (alta)**

**Drenar X**
Quando esta criatura causa dano em combate, o Comandante recupera X pontos de vida.
- Elemento temático: Água (vampírico, fluxo de energia)
- Arquétipo: sustain offensivo — atacar também é curar
- Implementação: baixa — hook na fase de dano existente
- Prioridade: **2 (média)**

**Espinhos X**
Quando esta criatura é atacada e sofre dano, a criatura atacante recebe X de dano
de volta imediatamente.
- Elemento temático: Terra (superfície afiada de pedra)
- Arquétipo: punição de ataques diretos; anti-Atropelar natural
- Implementação: baixa — hook na resolução de dano recebido
- Prioridade: **1 (alta)**

---

### Categoria 2 — Proteção e Resistência

**Escudo**
Esta criatura ignora completamente a primeira instância de dano que receber.
Após absorver uma vez, o marcador de Escudo é removido permanentemente.
- Elemento temático: Terra, Ar (barreira de vento)
- Arquétipo: criatura que requer dois ataques para matar; cria puzzles de remoção
- Implementação: baixa — flag booleana que intercepta o primeiro dano
- Prioridade: **1 (alta)**

**Resistência X**
O primeiro X de dano que esta criatura receberia em cada ciclo de combate é
ignorado. Reseta a cada novo ciclo de combate.
- Elemento temático: Terra (elementais de pedra)
- Arquétipo: tanque verdadeiro — aguenta criaturas pequenas indefinidamente,
  mas sangra para ataques grandes
- Implementação: baixa a média — threshold por ciclo, não por instância
- Prioridade: **1 (alta)**

**Imune**
Esta criatura não pode ser alvo de spells, habilidades ativas de classe, ou
efeitos negativos (Enfraquecer, Prender, Congelar). Pode ser atacada normalmente
em combate de lane.
- Elemento temático: chefes e inimigos de elite; raramente em cartas do jogador
- Arquétipo: ameaça que só pode ser resolvida por combate direto
- Implementação: média — filtra toda fonte de efeito negativo
- Prioridade: **3 (pode esperar)** — usada só no Lich (Necromante proposto)

---

### Categoria 3 — Crescimento e Tempo

**Crescer X**
No início de cada turno do jogador enquanto esta criatura estiver em campo,
ela ganha +X ATK permanentemente.
- Elemento temático: Terra (raiz que cresce), Gelo (gelo que se acumula)
- Arquétipo: ameaça crescente que obriga remoção imediata
- Implementação: baixa — trigger no início de turno já existente no engine
- Prioridade: **1 (alta)**

**Fúria**
Cada vez que esta criatura sofre dano e sobrevive ao ciclo de combate,
ganha +1 ATK permanentemente.
- Elemento temático: Fogo, inimigos berserker
- Arquétipo: criatura que cresce sendo punida — atacá-la é arriscado
- Implementação: baixa — hook no evento de dano recebido + sobrevivência
- Prioridade: **2 (média)**

**Ecoar**
Uma vez por batalha, quando esta criatura causa dano, o mesmo dano é causado
novamente ao mesmo alvo imediatamente após o primeiro impacto.
- Elemento temático: Ar (eco de vento), Arcano
- Arquétipo: burst oculto — parece normal até o Eco disparar no momento certo
- Implementação: média — flag de batalha + re-trigger do dano uma única vez
- Prioridade: **2 (média)**

---

### Categoria 4 — Controle e Debuff

**Veneno X**
Esta criatura aplica um marcador de Veneno X ao alvo ao causar dano. No fim
de cada turno do jogador, criaturas com Veneno perdem X HP. Uma segunda
aplicação de Veneno não substitui — acumula em +1 se o novo X for maior.
- Elemento temático: Gelo/Água (corrosão, veneno aquático)
- Arquétipo: dano ao longo do tempo; anti-tanque de HP alto; ignora Resistência
- Implementação: média-alta — sistema de marcadores com tick periódico
- Prioridade: **2 (média)**

**Congelar (como keyword de criatura)**
Distinto do `prender` existente (spell de controle do jogador). Congelar como
keyword inimiga: quando esta criatura ataca e causa dano, a criatura atingida
fica Congelada e não ataca no próximo ciclo de combate. Como debuff aplicado
por cartas do jogador: a criatura alvo não ataca no próximo ciclo.
- Elemento temático: Gelo (principal)
- Arquétipo: controle de timing; inimigo que imobiliza criaturas específicas
- Implementação: média — aplicação de debuff "pular próximo ataque" no alvo
- Prioridade: **2 (média)**

**Profanar**
Quando esta criatura morre, remove todas as keywords de uma criatura inimiga
aleatória em campo.
- Elemento temático: Necromante, elite de Água (corrupção)
- Arquétipo: carta sacrificável com efeito de controle; usa o sistema de
  Remover Keywords já existente
- Implementação: baixa a média — trigger ao morrer + Remover Keywords existente
- Prioridade: **3 (pode esperar)**

---

### Categoria 5 — Recursos e Economia

**Entrar: [efeito]**
Esta criatura dispara um efeito fixo no momento em que é invocada, antes de
qualquer fase de combate. O efeito é definido na descrição da carta.
Exemplos: `Entrar: cause 1 dano a criatura inimiga aleatória` /
`Entrar: aliada de menor HP ganha +1/+1`.
- Elemento temático: universal — abre design space para todas as classes e inimigos
- Arquétipo: criaturas com valor imediato; reduz a assimetria entre "jogar
  criatura" e "jogar spell"
- Implementação: média — campo `on_enter` no sistema de carta + dispatcher
  no momento de invocar
- Prioridade: **1 (alta)** — já usada nas cartas propostas de Sessão B

**Proliferar**
Se esta criatura estiver viva no fim do ciclo de combate completo, cria um
token 1/1 sem keywords em um slot aliado vazio aleatório.
- Elemento temático: Terra (reprodução orgânica), Invocador
- Arquétipo: pressão de presença passiva; incentiva manter esta criatura viva
- Implementação: média — trigger no evento "fim de combate" + verificação de slot
- Prioridade: **3 (pode esperar)**

**Sacrifício X**
O custo de mana desta carta é reduzido em X se você sacrificar uma criatura
aliada ao jogá-la. O sacrifício é confirmado no mesmo gesto de invocar.
- Elemento temático: Necromante (morte como moeda)
- Arquétipo: big play com custo alternativo; sinergia com deathrattles
- Implementação: média-alta — exige fluxo de confirmação de sacrifício antes
  de deduzir mana
- Prioridade: **3 (pode esperar)**

---

### Categoria 6 — Sinergias e Identidade

**Inspirar X**
Enquanto esta criatura estiver em campo, criaturas aliadas adjacentes ganham
+X ATK de bônus por ciclo de combate.
- Elemento temático: Invocador (aura de liderança), inimigos de chefe com suporte
- Arquétipo: multiplicador de posicionamento — alvo prioritário de remoção
- Implementação: baixa a média — aura calculada na fase de combate para
  slots adjacentes
- Prioridade: **1 (alta)** — já usada no Capitão de Campo (Invocador proposto)

**Pacto**
Quando duas criaturas com Pacto estão no campo aliado simultaneamente, ambas
ganham +2/+2 enquanto a outra existir. O bônus desaparece se uma morrer.
- Elemento temático: par de guardiões, dupla de mortos-vivos
- Arquétipo: sinergia de par; incentiva proteger ambas
- Implementação: média — detecção de par no campo e buff condicional
- Prioridade: **2 (média)** — usado no Titã Geminal (Invocador proposto)

**Drenar Almas**
Quando esta criatura mata uma criatura inimiga, gera Almas bônus igual ao
ATK da criatura morta.
- Elemento temático: Necromante (colheita), inimigos de elite
- Arquétipo: meta-economia; incentiva kills calculados para gerar recurso de run
- Implementação: baixa — hook no evento de morte inimiga + incremento de Almas
- Prioridade: **3 (pode esperar)**

**Ressurgir**
Quando esta criatura morre, retorna uma vez com metade do ATK e HP originais
(arredondado para baixo), sem keywords. Diferente de `reviver` que retorna
com stats e keywords completas.
- Elemento temático: Gelo (criatura que se reconstitui parcialmente)
- Arquétipo: criatura que requer 1,5x o esforço para remover; menos cara que
  `reviver` no retorno
- Implementação: baixa — variante do sistema de reviver com cálculo de metade
  dos stats base
- Prioridade: **1 (alta)** — usado no Revenant (Necromante proposto)

---

## Resumo de Prioridade

**Prioridade 1 — Alta payoff, implementar primeiro:**
Atropelar · Espinhos · Escudo · Resistência · Crescer · Entrar · Inspirar · Ressurgir · Brutal

**Prioridade 2 — Interessante, avaliar após P1:**
Drenar · Fúria · Ecoar · Veneno · Congelar · Pacto

**Prioridade 3 — Pode esperar ou ser cortado:**
Imune · Profanar · Proliferar · Sacrifício · Drenar Almas

---

## Nota sobre Efeitos de Campo

Efeitos de campo de tabuleiro (Geada, Terreno Rochoso, Ventania, etc.) são
documentados separadamente em `../design-proposals/rota-29-mapas.md`, pois
estão ligados diretamente aos encontros específicos da rota de 29 mapas.
