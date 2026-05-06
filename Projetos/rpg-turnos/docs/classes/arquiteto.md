# Arquiteto de Éter

- Last Updated: `2026-05-06`
- Status: `design completo`
- Índice: `README.md`

## Identidade

O Arquiteto não elimina — ele instala. Cada turno é uma decisão permanente: onde essa estrutura fica, porque não vai se mover nunca mais. O deck inteiro é estruturas e magias de suporte, zero criaturas. O tabuleiro no turno 6 é uma fortaleza que gera valor passivo, bloqueia todas as rotas e o oponente não tem energia suficiente para desmantelar tudo.

## Loop Central

**Turnos 1-2:** Ocupar o slot mais importante com um bloqueador de rota. A escolha de posicionamento aqui é permanente e define o resto do encontro.

**Turnos 3-4:** Adicionar estruturas com valor passivo. O Bastião começa a gerar armadura a cada upkeep, o Núcleo começa a gerar energia. O oponente precisa decidir entre atacar o herói ou destruir as estruturas mais valiosas.

**Turno 5+:** Com 3-4 estruturas no campo e o Núcleo gerando energia extra, o Arquiteto tem mais recursos por turno do que qualquer outro estilo. Sobrecarga de Construto limpa o campo. Elo de Éter dá a todas as estruturas um segundo ataque no mesmo turno.

## Ponto de Virada

O **Núcleo de Éter** em campo sobrevivendo ao turno do oponente. A partir daí, cada turno o Arquiteto tem mais energia do que deveria. O oponente deve destruir o Núcleo ou perder o controle do recurso.

## Ponto Fraco

**Magia de tabuleiro** que danifica todos os permanentes pode destruir estruturas já enfraquecidas num único turno. **Criaturas voadora** passam por cima de todas as defesas terrestres. Em modos com **limite de turno apertado** (`quebra_cabeca`, início de `ondas`), construção lenta não entrega resultado a tempo.

## Poder do Herói

**Reparação de Éter**
Custo: 1 | Normal | 1× no próprio turno

*Regenera 4 HP de uma estrutura sua danificada.*

Uma estrutura que seria destruída no próximo ataque volta a ter margem. A decisão é sempre qual estrutura salvar — a mais valiosa nem sempre é a mais ameaçada.

## Deck Inicial — 20 Cartas

| Qtd | Nome | Tipo | Custo | Stats | Keywords | Efeito |
|---|---|---|---|---|---|---|
| ×3 | Muro de Éter | estrutura | 1 | 0/5 | defensor | — |
| ×3 | Reforço Estrutural | magia | 1 | — | — | Uma estrutura sua ganha +0/+3 de HP máximo permanentemente |
| ×3 | Torre de Vigilância | estrutura | 2 | 2/5 | alcance | — |
| ×2 | Bastião Arcano | estrutura | 2 | 1/7 | defensor | Upkeep: ganha 1 armadura |
| ×2 | Pulso de Éter | magia | 2 | — | — | 2 dano mágico a todos os permanentes inimigos |
| ×2 | Núcleo de Éter | estrutura | 3 | 0/8 | — | Upkeep: ganha 1 de energia |
| ×2 | Guardião de Cristal | estrutura | 3 | 3/7 | — | Quando destrói um permanente em combate: ganha 3 armadura |
| ×1 | Elo de Éter | comando | 3 | — | — | Todas as suas estruturas com ATK > 0 ficam prontas neste turno, mesmo que já tenham atacado |
| ×1 | Sobrecarga de Construto | magia | 3 | — | — | Causa X dano mágico distribuído como quiser entre permanentes inimigos, onde X = número de estruturas que você controla |
| ×1 | Colosso de Éter | estrutura | 5 | 6/12 | — | — |

## Por que cada carta existe

**Muro de Éter** é comprometimento puro com posicionamento. 0/5 defensor por 1 bloqueia uma rota completamente sem oferecer ataque. O oponente precisa de 5 de dano para remover, e o Reforço já pode estar na mão.

**Reforço Estrutural** muda a equação de "destrua essa estrutura." Por 1, uma estrutura ganha +3 HP máximo permanentemente. O Muro vira 0/8, o Bastião vira 1/10. As estruturas crescem.

**Torre de Vigilância** é o atacante principal. Alcance ataca criaturas em alto, ignora ocupantes intermediários e cobre rotas protegidas. As três cópias garantem sempre um atacante ativo.

**Bastião Arcano** exige resposta imediata. 1 armadura por upkeep parece pouco — depois de 4 turnos são 4 de armadura acumulada que precisam ser superadas antes de causar dano real. O bloqueador mais eficiente do deck.

**Pulso de Éter** existe para quando o oponente encheu o campo com criaturas pequenas. 2 de dano mágico em todas as inimigas. Timing crítico: cedo desperdiça em poucas criaturas, tarde demais pode custar o jogo.

**Núcleo de Éter** é o coração do plano. 0/8 sem ataque por 3 parece ruim até gerar 1 de energia extra a cada upkeep. No turno de entrada custa 3; no seguinte o custo efetivo já é 2. Se sobreviver, o jogo de recursos inclina completamente. O oponente deve destruí-lo.

**Guardião de Cristal** é a ponte entre defesa e vitória. 3/7 que ganha 3 armadura ao destruir em combate transforma cada ataque bem-sucedido em mais durabilidade. Em `limpar_mesa`, é a máquina de fechar o jogo.

**Elo de Éter** é o alpha strike. Com Torre ×3 e Guardião ×2 em campo, todas as 5 estruturas atacam duas vezes no mesmo turno. Existe como comando (máximo 4 no deck), tornando a decisão de quando usar pesada.

**Sobrecarga de Construto** escala com o estado do tabuleiro. Com 2 estruturas: 2 dano distribuídos — meh. Com 5 estruturas: 5 dano — destrói 2-3 criaturas de uma vez. Quanto mais construtos, mais devastadora.

**Colosso de Éter** chega quando o jogo já está ganho. 6/12 junto com 3-4 outras estruturas é mais permanência do que qualquer encontro consegue lidar. Absorve a magia de tabuleiro que tentaria limpar o campo.

## Requisitos de Engine Novos

**Upkeep triggers em permanentes** (Bastião, Núcleo): verificar no início do upkeep do controlador se cada permanente tem efeito de upkeep e aplicá-lo. Moderado. **Sistema compartilhado com o Dominador** — implementado uma vez, serve para ambos.

**HP máximo crescente permanentemente** (Reforço Estrutural): atualizar `max_health` de um permanente em jogo. Pequeno — o engine já rastreia dano separado de HP máximo.

**"Quando destrói em combate"** (Guardião de Cristal): mesmo hook já mapeado para Pilhador do Assaltante.

**Reset de estado para pronta em massa** (Elo de Éter): marcar todas as estruturas com ATK > 0 como `pronta` no turno de resolução. Pequeno.

**Escalar efeito pelo número de permanentes** (Sobrecarga): contar permanentes com condição no momento de resolução e usar como parâmetro. Moderado.

## Contraste com o Assaltante

O Assaltante pergunta "como limpo essa rota agora?". O Arquiteto pergunta "qual slot vale mais ocupar permanentemente?". Em `ondas`, o Assaltante recomeça do mesmo nível — o Arquiteto chega na wave 3 com o tabuleiro completo e o Núcleo já tendo gerado energia extra.
