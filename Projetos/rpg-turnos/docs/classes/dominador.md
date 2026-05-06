# Dominador Astral

- Last Updated: `2026-05-06`
- Status: `design completo`
- Índice: `README.md`

## Identidade

O Dominador não destrói o que pode dominar. O tabuleiro dele no turno 5 não está limpo — está cheio de criaturas inimigas com enjoo, queimando nos slots, e duas criaturas próprias que crescem cada vez que uma nova supressão é aplicada. O inimigo tem peças no campo mas não consegue usá-las. O Assaltante esvazia o tabuleiro; o Dominador paralisa ele.

## Loop Central

**Turnos 1-2:** Sentinelas em slots estratégicos enquanto feitiços baratos aplicam enjoo nas ameaças mais imediatas. O Dominador não ataca — bloqueia rotas e compra tempo.

**Turnos 3-4:** Condutor de Domínio entra e começa a aplicar enjoo via combate. Extrator Astral cresce a cada upkeep onde algum inimigo está suprimido. O tabuleiro inimigo fica progressivamente paralizado enquanto o Extrator acumula ATK.

**Turno 5+:** Com Névoa Astral ou Supressão em Massa, todas as criaturas inimigas ficam com enjoo simultaneamente. O Extrator pode ter 5-6 de ATK. O Dominador ataca livremente enquanto o inimigo observa.

## Ponto de Virada

**Extrator Astral com 4+ de ATK e 2+ criaturas inimigas suprimidas**. Cada ação do Dominador é um ataque sem resposta — o inimigo tem peças mas estão paralisadas, o Extrator mata qualquer coisa que tente reagir, e o Condutor garante que novas ameaças também vão para enjoo.

## Ponto Fraco

**Estruturas** ignoram enjoo — ficam em campo gerando valor passivo. Muitas estruturas inimigas e o Dominador perde o controle. **Criaturas com rapido** que entram prontas num turno sem Pulso Disruptivo disponível atacam antes de qualquer resposta. **Oleada de criaturas baratas simultâneas** supera a capacidade de supressão por turno.

## Poder do Herói

**Dominância Astral**
Custo: 2 | Normal | 1× no próprio turno

*Aplica enjoo a um permanente inimigo.*

Dois de energia para travar qualquer atacante por um turno inteiro. No turno 3 (4 de energia), dá para usar o poder e ainda jogar uma carta de custo 2. Caro o suficiente para exigir planejamento, poderoso o suficiente para definir encontros.

## Deck Inicial — 20 Cartas

| Qtd | Nome | Tipo | Custo | Stats | Keywords | Efeito |
|---|---|---|---|---|---|---|
| ×3 | Sentinela de Supressão | criatura | 2 | 1/4 | defensor | Quando bloqueia um ataque: o atacante ganha enjoo após o combate |
| ×3 | Pulso Disruptivo | magia | 1 | — | instantâneo | Aplica enjoo a uma criatura inimiga pronta |
| ×3 | Correntes de Éter | magia | 2 | — | — | Aplica queimando ao slot de um permanente inimigo |
| ×2 | Extrator Astral | criatura | 2 | 2/3 | — | Upkeep: se pelo menos uma criatura inimiga tem enjoo, ganha +1/+0 permanentemente |
| ×2 | Condutor de Domínio | criatura | 3 | 2/5 | — | Quando causa dano em combate: o alvo ganha enjoo |
| ×2 | Drenagem de Força | magia | 2 | — | — | Causa 2 dano mágico a um permanente inimigo e aplica enjoo a ele |
| ×2 | Névoa Astral | magia_de_tabuleiro | 3 | — | — | Todas as criaturas inimigas prontas ganham enjoo |
| ×1 | Drenar Vitalidade | magia | 3 | — | — | Causa 4 dano mágico a um permanente inimigo. Você ganha armadura igual ao dano causado |
| ×1 | Senhor da Supressão | criatura | 5 | 4/7 | — | Upkeep: aplica enjoo a uma criatura inimiga pronta à sua escolha |
| ×1 | Supressão em Massa | magia_de_tabuleiro | 4 | — | — | Todas as criaturas inimigas ganham enjoo. Este enjoo persiste até o início do próximo upkeep delas |

## Por que cada carta existe

**Sentinela de Supressão** cria uma armadilha de posicionamento. O oponente pode atacar — mas a criatura atacante ganha enjoo e perde o turno seguinte. Atacar a Sentinela tem custo, ignorá-la bloqueia a rota.

**Pulso Disruptivo** é o único instantâneo do deck. Quando o inimigo joga criatura com rapido e passa prioridade antes de atacar, o Dominador usa o Pulso durante a janela de prioridade. É a resposta direta ao principal ponto fraco. Guardar o Pulso para essa situação ou usá-lo imediatamente — decisão constante.

**Correntes de Éter** atinge o slot, não a criatura. Uma estrutura no slot queimando recebe 1 dano por upkeep sem poder sair. Uma criatura pode mover para fugir — mas perde o slot e o posicionamento. Dilema para o inimigo: queimar devagar ou se reposicionar e perder terreno.

**Extrator Astral** é o motivo de tudo mais existir. Começa como 2/3 sem keywords — sem impressão. Mas cada upkeep onde algum inimigo tem enjoo, ganha +1/+0 permanentemente. Com poder de herói, Névoa Astral e as demais cartas, o Extrator chega ao turno 7 com 6-7 de ATK sem resposta clara do inimigo para o crescimento.

**Condutor de Domínio** torna o combate seguro. 2/5 que aplica enjoo no alvo ao causar dano: atacar criaturas mais fortes não é suicídio — mesmo sem matar, o resultado é "aquela criatura não ataca no próximo turno." Ataque de risco vira investimento de controle.

**Drenagem de Força** combina remoção parcial com supressão. 2 dano mais enjoo por 2 de energia faz dois trabalhos: enfraquece para um kill posterior e garante que não ataca nesse intervalo.

**Névoa Astral** é a resposta ao swarm. Aplica enjoo em todas as criaturas inimigas **prontas** simultaneamente. Timing crítico: cedo desperdiça em criaturas que ainda não atacaram, tarde e já tomou o dano.

**Drenar Vitalidade** é a única carta de dano significativo num alvo específico. 4 de dano mágico com armadura bônus: mata criatura de alto HP que não pode ser suprimida indefinidamente, ou vai no herói no `duelo` recuperando 4 de armadura ao mesmo tempo.

**Senhor da Supressão** é a vitória inevitável. 4/7 que suprime automaticamente uma criatura inimiga todo upkeep — o Dominador nunca gasta energia de controle enquanto ele está em campo. Qual criatura suprimir a cada turno é a única decisão restante.

**Supressão em Massa** difere da Névoa em dois pontos cruciais: afeta **todas** as criaturas inimigas independente do estado atual, e o enjoo persiste até o início do próximo upkeep delas — cobre o turno inteiro do inimigo, não só o resto do seu. Custa 4, existe em cópia única. Resposta de emergência.

## Requisitos de Engine Novos

**Upkeep triggers em permanentes** (Extrator, Senhor): mesmo sistema necessário para o Arquiteto. **Implementar uma vez, compartilhado entre as duas classes.**

**Enjoo aplicado via efeito de feitiço**: o engine já tem enjoo como estado. Adicionar método de aplicar esse estado através de resolução de feitiço (não apenas por entrada em campo).

**Enjoo com duração estendida** (Supressão em Massa): enjoo normal se remove no upkeep do controlador da criatura. Versão estendida precisa de parâmetro de duração — "remove somente no segundo upkeep após aplicação." Moderado.

**Armadura proporcional ao dano causado** (Drenar Vitalidade): após resolução do dano, capturar o valor efetivo causado e aplicar como armadura. Pequeno.

**ATK crescente por upkeep condicional** (Extrator): mesmo sistema do Arquiteto para Bastião/Núcleo, mas com condicional e modificação de stat.

## Contraste com as outras classes

O Assaltante pergunta "como mato isso?". O Dominador pergunta "preciso matar isso ou posso só paralisar?". O Arquiteto ignora as ameaças com HP alto; o Dominador as neutraliza e as usa como obstáculos para o próprio inimigo. Em `ondas`, o Dominador tem a resposta mais elegante: criaturas da onda anterior ficam com enjoo enquanto as novas chegam, e o Extrator fica maior a cada ciclo.
