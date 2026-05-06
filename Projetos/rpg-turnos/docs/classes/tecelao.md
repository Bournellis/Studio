# Tecelão Astral

- Last Updated: `2026-05-06`
- Status: `design completo`
- Índice: `README.md`

## Identidade

O Tecelão é o único mago que pensa em sequência, não em peças isoladas. Cada feitiço lançado neste turno deixa o próximo mais poderoso. Os primeiros turnos são frugais — feitiços pequenos, dano modesto, poucas criaturas em campo. No turno 6, com 7 de energia e Ressonância acumulando rapidamente, o Tecelão lança 4-5 feitiços em série onde o último entrega sozinho mais dano que o deck inteiro entregou nos turnos anteriores.

## Ressonância — Como Funciona

Um contador por turno que começa em 0 no início do turno do jogador. Cada feitiço lançado incrementa em 1. Alguns feitiços usam o valor atual de Ressonância como parâmetro do efeito. Ao final da fase de descarte, o contador volta a 0.

A **ordem importa**: lançar o feitiço de maior payoff como último da sequência entrega o valor máximo. Lançar fora de ordem ou perder a sequência por falta de energia desperdiça o potencial.

## Loop Central

**Turnos 1-3:** Custódio do Fio cobre um slot enquanto feitiços baratos constroem Ressonância e causam dano moderado. O Tecelão não está tentando vencer esses turnos — está aprendendo o tabuleiro e mantendo pressão enquanto a mão carrega cartas mais pesadas.

**Turnos 4-5:** Primeira cadeia real com 5-6 de energia. Ressonância chega a 3-4 num único turno. Pulso Ressonante entrega o dobro do dano habitual. Conduit Astral compra uma carta extra ao cruzar o limiar 3.

**Turno 6-7:** Energia máxima, mão cheia. Hero power gratuito inicia a sequência. Três feitiços de 1 de energia encadeados levam Ressonância a 4. Eco Arcano entrega 8-10 de dano num alvo específico. Tempestade de Ressonância varre o tabuleiro inteiro.

## Ponto de Virada

Encadear **4+ feitiços no mesmo turno com Ressonância chegando a 4 ou mais**. Não é um evento único — é um estado que, uma vez alcançado, se replica toda vez que a energia máxima for atingida. A partir daí, cada turno tem capacidade de limpar o tabuleiro e causar dano ao herói na mesma sequência.

## Ponto Fraco

**Criaturas rapido e voadora** que chegam antes de o Custódio estar em campo causam dano livre por vários turnos sem bloqueadores. **Criaturas de HP muito alto** absorvem os feitiços sem morrer, quebrando a eficiência da sequência. Qualquer turno **sem feitiços na mão mas com energia disponível** é um turno completamente desperdiçado — o deck não tem plano B sem spells.

## Poder do Herói

**Foco Astral**
Custo: 0 | Normal | 1× no próprio turno

*Adiciona 1 de Ressonância.*

O único poder de herói gratuito entre todas as classes — e o único que não faz nada por si só. Não causa dano, não gera armadura, não spawna nada. Usado antes do primeiro feitiço do turno, garante que todos os feitiços subsequentes partem de uma posição mais alta na escala de Ressonância. Num turno de 4 feitiços, pode ser a diferença entre Apoteose causando 13 ou 15 de dano. Totalmente inútil se o turno não tiver pelo menos dois feitiços encadeados depois.

## Deck Inicial — 20 Cartas

| Qtd | Nome | Tipo | Custo | Stats | Keywords | Efeito |
|---|---|---|---|---|---|---|
| ×3 | Centelha Astral | magia | 1 | — | instantâneo | Causa Ressonância dano mágico a um permanente inimigo (mínimo 1) |
| ×3 | Flecha de Vínculo | magia | 1 | — | instantâneo | Causa 2 dano mágico a um permanente inimigo. Compre 1 carta |
| ×3 | Pulso Ressonante | magia | 1 | — | — | Causa 2 dano mágico a um permanente. Se Ressonância ≥ 3: causa 4 dano em vez disso |
| ×2 | Custódio do Fio | criatura | 2 | 2/4 | — | Quando você lança um feitiço enquanto este permanente está em jogo: ganha 1 de armadura |
| ×2 | Eco Arcano | magia | 2 | — | — | Causa Ressonância × 2 dano mágico a um permanente inimigo |
| ×2 | Barreira Ressonante | magia | 2 | — | — | Você ganha Ressonância de armadura |
| ×2 | Conduit Astral | criatura | 3 | 1/5 | — | Quando Ressonância atinge 3 pela primeira vez no turno: compre 1 carta |
| ×1 | Onda de Éter | magia_de_tabuleiro | 2 | — | — | Causa 2 dano mágico a todos os permanentes inimigos. Se Ressonância ≥ 4: causa 3 dano em vez disso |
| ×1 | Tempestade de Ressonância | magia_de_tabuleiro | 4 | — | — | Causa dano mágico a todos os permanentes inimigos igual à Ressonância atual |
| ×1 | Apoteose Astral | magia | 5 | — | — | Causa 5 + (Ressonância × 2) dano mágico a um alvo |

## Por que cada carta existe

**Centelha Astral** é o primer perfeito porque resolve dois problemas ao mesmo tempo: adiciona Ressonância e escala com ela. Como primeiro feitiço (Res 1): 1 dano fraco mas aceitável. Como quinto feitiço (Res 5): 5 dano por 1 de energia — a melhor relação custo/dano do deck naquele momento. A decisão central: quando colocá-la na sequência?

**Flecha de Vínculo** é o cantrip que mantém a cadeia viva. Um deck que joga 4-5 feitiços por turno esgota a mão; a Flecha repõe uma carta enquanto causa dano e adiciona Ressonância. O instantâneo permite uso no turno inimigo — às vezes vale comprar uma carta fora do turno para ter mais opções na próxima sequência.

**Pulso Ressonante** ensina a mecânica de forma visceral. Dois de dano é medíocre por 1. Quatro de dano é eficiente. A diferença é simplesmente jogar dois outros feitiços antes. Aprendizado imediato do ritmo: *construir primeiro, pagar depois*.

**Custódio do Fio** é o guardião do plano. 2/4 acumula 1 de armadura por feitiço lançado no mesmo turno. Numa sequência de 5 feitiços, ganha 5 de armadura naquele único turno. Em campo há 3 turnos pode ter 12-15 de armadura acumulada. O oponente deve decidir: matar o Custódio antes de ficar invulnerável, ou ignorá-lo e focar no herói?

**Eco Arcano** é o feitiço de payoff. Por 2 de energia, dano igual a Ressonância × 2. No turno 2 como segunda carta (Res 2): 4 de dano. No turno 6 como quarta carta (Res 4): 8 de dano. Como quinta carta depois do Foco Astral (Res 5): 10 de dano por 2 de energia. Sistematicamente mais eficiente que qualquer outro feitiço de remoção quando a sequência está aquecida.

**Barreira Ressonante** existe para turnos onde o tabuleiro inimigo é muito duro para matar eficientemente. Em vez de desperdiçar feitiços em alvos que não morrerão, o Tecelão usa a sequência para construir armadura. Num turno de 4 feitiços onde a Barreira é o quarto (Res 4), ganha 4 de armadura.

**Conduit Astral** é a recompensa por jogar certo. 1/5 que só faz uma coisa: quando Ressonância chega a 3 no turno, compra 1 carta. Cria ciclo de reforço — mais feitiços geram mais cards geram mais feitiços no próximo turno. Com dois Conduits em campo, cruzar o limiar 3 compra 2 cartas de uma vez.

**Onda de Éter** é a resposta ao swarm. Sem ela, o Tecelão não tem forma eficiente de lidar com múltiplos inimigos. Versão básica (2 dano a todos) limpa criaturas fracas. Versão turbinada a Ressonância 4+ (3 dano a todos) limpa criaturas médias. A decisão: consegue chegar a Res 4 antes de lançá-la, ou o turno exige usá-la mais cedo?

**Tempestade de Ressonância** é o feitiço definitivo de controle de área. Custa 4 e causa dano a **todos** os inimigos baseado na Ressonância atual. Deve ser última ou penúltima carta da sequência. Com Foco Astral + três feitiços baratos (Res 5) + Tempestade: 5 dano em todos. Se os inimigos tinham até 5 HP, campo limpo.

**Apoteose Astral** é o closing statement. Em qualquer outro deck 5 de energia seria desperdício. Aqui é o ponto final de uma oração longa: Foco Astral (Res 1) + três feitiços baratos (Res 4) + Apoteose = 5 + 8 = 13 de dano mágico num único alvo por 5+3 = 8 de energia. Com Res 5: 15 de dano. Resposta definitiva contra boss, guardião de alto HP, ou herói inimigo no `duelo`.

## A Sequência Ideal — Exemplo de Turno 7

*8 de energia disponível, Ressonância começa em 0:*

1. **Foco Astral** (0 energia, Res → 1)
2. **Centelha Astral** (1 energia, Res → 2, causa 2 dano a um alvo)
3. **Flecha de Vínculo** (1 energia, Res → 3, 2 dano + compra 1 carta; Conduit Astral aciona: compra mais 1)
4. **Pulso Ressonante** (1 energia, Res → 4, ≥3 ativado: 4 dano ao alvo mais forte)
5. **Onda de Éter** (2 energia, Res → 5, ≥4 ativado: 3 dano a todos inimigos restantes)
6. **Eco Arcano** (2 energia, Res → 6, 12 dano ao alvo sobrevivente)

*Total: 7 de energia gasta, 2 alvos diferentes danificados, tabuleiro provavelmente limpo, Custódio ganhou 5 de armadura, Conduit comprou 2 cartas extras.*

## Requisitos de Engine Novos

**Contador de Ressonância por turno** (central para a classe): inteiro inicializado a 0 no início de cada turno do jogador, incrementado por cada feitiço resolvido, zerado na fase de descarte. O sistema mais simples de todos os propostos — é apenas uma variável de estado de turno.

**Leitura do contador em tempo de resolução** (Centelha, Eco, Barreira, Tempestade, Apoteose): ler o valor atual do contador no momento de resolver o efeito. Trivial.

**Efeitos com limiar de Ressonância** (Pulso ≥3, Onda ≥4): condicional binário na resolução. Pequeno.

**Trigger de feitiço em permanente** (Custódio do Fio): quando qualquer feitiço do controlador resolve, verificar se existe permanente com esse trigger e aplicar o efeito. Moderado — requer hook no pipeline de resolução de feitiços.

**Trigger de milestone** (Conduit Astral): quando Ressonância incrementa para exatamente 3 (ou de 2 para 3+), disparar o efeito uma única vez por turno. Moderado — requer flag "milestone já acionado este turno" para evitar repetição.

## Contraste com as outras classes

O Assaltante causa dano turno a turno de forma linear. O Tecelão causa pouco nos primeiros turnos e uma quantidade desproporcional num único turno explosivo. São as duas respostas opostas à pergunta "quando aplicar pressão?" — o Assaltante sempre, o Tecelão quando o momento é certo. Em `quebra_cabeca`, o Tecelão é provavelmente a melhor classe: limite de turnos favorece quem resolve slots específicos numa única ação concentrada.
