# Vinculador

- Last Updated: `2026-05-06`
- Status: `design completo`
- Índice: `README.md`

## Identidade

O Vinculador não traz um exército próprio — ele rouba o do inimigo. O deck de base é pequeno e frágil propositalmente: criaturas que enfraquecem sem matar, feitiços que ferem sem eliminar, e um poder de herói que executa alvos enfraquecidos e os converte em Formas Vinculadas que lutam pelo jogador. Quanto mais forte o inimigo que enfrenta, mais poderoso o Vinculador pode se tornar.

## Loop Central

**Turnos 1-2:** Batedor de Éter ocupa slots enquanto Ferida Astral reduz HP de ameaças específicas sem matá-las. O objetivo não é limpar o tabuleiro — é deixar criaturas valiosas em 1-2 HP prontas para captura.

**Turnos 3-4:** Laçador de Vínculo entra e começa a crescer com cada kill. O poder de herói executa criaturas enfraquecidas e spawna Formas Vinculadas. Espectro Coletor monitora o campo inteiro e gera tokens sempre que qualquer criatura inimiga é destruída.

**Turno 5+:** Com 2-3 Formas Vinculadas em campo, Fluxo de Vínculo compra múltiplas cartas de uma vez. Exodia Vinculada cresce exponencialmente. Dominação Forçada faz inimigos se destruírem mutuamente, gerando ainda mais capturas.

## Ponto de Virada

**Espectro Coletor em campo com energia para Dominação Forçada**. Forçar dois inimigos a se atacarem destrói pelo menos um, o Espectro gera um 1/1 vinculado, o Laçador ganha +1/+1, e Fluxo de Vínculo no mesmo turno compra 2 cartas. O tabuleiro do Vinculador explode enquanto o inimigo perdeu peças contra si mesmo.

## Ponto Fraco

Inimigos com **HP muito alto** levam muitos turnos para enfraquecer até o ponto de captura. Encontros com **estruturas** são difíceis: estruturas não morrem facilmente e o Vinculador tem pouca remoção bruta. Contra **swarms de criaturas baratas**, as capturas não valem o custo de setup.

## Poder do Herói

**Captura Forçada**
Custo: 2 | Normal | 1× no próprio turno

*Destrói um permanente inimigo com HP ≤ 3. Spawna uma Forma Vinculada com os stats originais do permanente destruído (máximo 4/4) em um slot vazio seu.*

Define o estilo inteiro. Você enfraquece com Ferida Astral ou dano de combate, depois executa com o poder e ganha uma cópia lutando pelo seu lado. Capturar um Guardião enfraquecido (que era 4/5, destruído com 2HP, capturado como 4/4) é completamente diferente de capturar um Elemental Menor (2/2). Qual alvo investir o setup define a direção de cada encontro.

## Deck Inicial — 20 Cartas

| Qtd | Nome | Tipo | Custo | Stats | Keywords | Efeito |
|---|---|---|---|---|---|---|
| ×3 | Batedor de Éter | criatura | 1 | 1/2 | — | — |
| ×3 | Ferida Astral | magia | 1 | — | instantâneo | 2 dano mágico a um permanente inimigo. Este dano não pode ser letal — se reduziria HP a 0 ou menos, HP fica em 1 |
| ×3 | Laçador de Vínculo | criatura | 2 | 2/3 | — | Quando destrói um permanente em combate: ganha +1/+1 permanentemente |
| ×2 | Lança de Captura | magia | 2 | — | — | Causa 4 dano mágico a um permanente inimigo. Se destruído: spawna uma Forma Vinculada 2/2 em um slot vazio seu |
| ×2 | Fluxo de Vínculo | magia | 2 | — | — | Compre 1 carta para cada Forma Vinculada que você controla (máximo 3) |
| ×2 | Espectro Coletor | criatura | 3 | 1/4 | — | Quando qualquer criatura inimiga é destruída enquanto este permanente está em jogo: spawna uma Forma Vinculada 1/1 em um slot vazio seu |
| ×2 | Dominação Forçada | magia | 3 | — | — | Escolha uma criatura inimiga. Ela ataca outra criatura inimiga à sua escolha neste turno |
| ×1 | Mestre Vinculador | criatura | 4 | 3/5 | — | Quando destrói um permanente em combate: spawna uma Forma Vinculada 2/2 em um slot vazio seu |
| ×1 | Ritual de Colheita | magia_de_tabuleiro | 3 | — | — | Causa 2 dano mágico a todos os permanentes inimigos. Para cada permanente destruído por este efeito: spawna uma Forma Vinculada 1/1 em um slot vazio seu |
| ×1 | Exodia Vinculada | criatura | 5 | 4/6 | — | Upkeep: ganha +1/+1 para cada Forma Vinculada que você controla |

## Por que cada carta existe

**Batedor de Éter** preenche slots nos turnos 1-2 sem comprometimento de design. 1/2 por 1 não é impressionante, mas o Vinculador precisa de presença no campo para não tomar dano livremente enquanto o setup começa.

**Ferida Astral** é a carta mais filosoficamente única do projeto. Um feitiço que deliberadamente *não pode matar* é estranho em qualquer deck — exceto aqui, onde deixar algo com 1 HP é o setup para o poder de herói. O instantâneo permite uso no turno inimigo: garante que uma criatura prestes a morrer de queimando sobreviva para ser capturada.

**Laçador de Vínculo** cresce com kills diretos — diferente do Extrator Astral do Dominador (que depende de enjoo). O jogador precisa garantir que o Laçador seja o responsável pela destruição, não um feitiço. Quando atacar com ele versus quando usar feitiços para remover é central ao estilo.

**Lança de Captura** é feitiço de captura direta. 4 de dano mata criaturas de custo 2-3 e gera um 2/2 vinculado. Se a Lança não matar, não gera token — sem recompensa. Decisão: usar agora em criatura fraca para garantir o token, ou esperar por criatura mais valiosa?

**Fluxo de Vínculo** é o motivo de querer muitas Formas Vinculadas em campo. No início não faz nada. Com 3 vinculadas: compra 3 cartas por 2 de energia — um dos efeitos de draw mais eficientes de qualquer deck. O ponto de inflexão onde o setup se torna ganho enorme de recursos.

**Espectro Coletor** é a peça central do combo com Dominação Forçada. 1/4 por 3 parece lento — mas com ele em campo, *qualquer* criatura inimiga que morrer gera um token. Quando Dominação Forçada faz dois inimigos se matarem, o Espectro pode capturar o que morreu. O oponente perdeu duas peças e o Vinculador ganhou uma.

**Dominação Forçada** é o feitiço mais único do projeto: força combate inimigo. Faz dois inimigos se atacarem, pelo menos um toma dano, possivelmente um morre acionando triggers do Espectro e do Laçador. Em `chefe_multiparte`, forçar uma criatura de suporte a atacar o próprio boss pode causar dano que o jogador não conseguiria causar diretamente. Requer verificação de rotas válidas entre os dois alvos.

**Mestre Vinculador** é a versão premium do Laçador. Mata e gera um 2/2 vinculado automaticamente — em vez de crescer num único permanente, fabrica peças novas. Distribuição de poder versus concentração.

**Ritual de Colheita** transforma o pior cenário do Vinculador (muitos inimigos fracos) num momento de captura em série. 2 de dano em todos mata criaturas de 1-2 HP e gera um 1/1 vinculado por cada uma.

**Exodia Vinculada** escala com o plano inteiro. Entra provavelmente com 2-3 vinculadas no campo — 4/6 e já crescendo. Com 4 vinculadas, ganha +4/+4 por upkeep. Não é ameaça imediata, mas depois de 2 turnos com board populado torna-se impossível de ignorar.

## Sobre as Formas Vinculadas

São criaturas token com a tag `vinculado`. Comportam-se como criaturas normais em combate — atacam, defendem, bloqueiam rotas. A tag existe para Fluxo de Vínculo e Exodia Vinculada contarem quantas estão em campo. Quando destruídas, não retornam ao deck — são removidas do jogo.

## Requisitos de Engine Novos

**Spawn de criatura token em runtime** (central para o Vinculador inteiro): criar uma criatura durante resolução de efeito e colocá-la num slot vazio. Moderado mas fundamental — sem isso o Vinculador não funciona. O sistema mais complexo das cinco classes.

**Criatura com stats copiados do alvo** (Captura Forçada): no momento da destruição, capturar ATK/HP do permanente destruído e passá-los para o token gerado, com cap. Adição pequena sobre o spawn básico.

**Dano não-letal condicional** (Ferida Astral): após calcular dano, se resultado ≤ 0, aplicar apenas (HP atual - 1). Pequeno.

**Forçar criatura inimiga a atacar outra inimiga** (Dominação Forçada): resolver combate entre dois permanentes inimigos sem criaturas do jogador. Moderado — precisa de caminho de resolução de combate entre dois permanentes do mesmo controlador, verificando rotas válidas.

**Contar Formas Vinculadas em campo** (Fluxo, Exodia): filtrar permanentes do jogador pela tag `vinculado` e retornar o count. Pequeno.

## Contraste com as outras classes

O Assaltante elimina. O Arquiteto fortifica. O Dominador paralisa. O Vinculador *converte*. A interação mais interessante seria o Vinculador contra um encontro pensado para o Arquiteto: estruturas difíceis de capturar, forçando o Vinculador a adaptar o plano.
