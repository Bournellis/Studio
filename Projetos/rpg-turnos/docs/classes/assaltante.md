# Assaltante de Vazio

- Last Updated: `2026-05-06`
- Status: `design completo`
- Índice: `README.md`

## Identidade

O Assaltante é o mago que vence antes do inimigo conseguir montar um plano. Cada turno sem dano é um turno perdido. O deck inteiro é calibrado para pressão imediata — criaturas que atacam no mesmo turno que entram, feitiços que abrem rotas ou fecham jogos, sem estruturas, sem defensores.

## Loop Central

**Turnos 1-2:** Deploy de criaturas rapido em rotas abertas. Dano começa antes de o inimigo ter energia para responder.

**Turnos 3-4:** O inimigo colocou bloqueadores. Decisão real: usar remoção para abrir rota, usar voadora/alcance para contornar, ou atacar o bloqueador para removê-lo. Manter pelo menos uma rota aberta é a prioridade.

**Turnos 5-6:** Com energia em 6-7, feitiços de maior custo fecham o jogo com o herói já desgastado. Se precisar do turno 8, o plano falhou.

## Ponto de Virada

Duas criaturas com rotas abertas ao herói simultaneamente. A maioria dos decks não tem energia para bloquear os dois flancos e ainda responder. O Assaltante vence quando o inimigo está na defensiva — não quando o tabuleiro está limpo.

## Ponto Fraco

Um único **defensor com HP alto** bloqueia a rota principal por vários turnos. Encontros com **armadura passiva** tornam o dano acumulado irrelevante. Qualquer magia de tabuleiro que aplique **queimando em todos os slots do jogador** força esvaziar o próprio campo — o pior cenário possível.

## Poder do Herói

**Disparo de Choque**
Custo: 1 | Normal | 1× no próprio turno

*Causa 2 de dano mágico a qualquer permanente inimigo.*

Sempre relevante: destrói criatura fraca bloqueando rota, finaliza criatura danificada, remove estrutura obstáculo. Dá destino para energia sobrando no fim da fase principal.

## Deck Inicial — 20 Cartas

| Qtd | Nome | Tipo | Custo | Stats | Keywords | Efeito |
|---|---|---|---|---|---|---|
| ×3 | Incursor de Vazio | criatura | 1 | 2/1 | rapido | — |
| ×3 | Lâmina de Choque | criatura | 1 | 3/1 | rapido | — |
| ×3 | Fenda Astral | magia | 1 | — | instantâneo | 2 dano mágico a qualquer permanente inimigo |
| ×2 | Pilhador Implacável | criatura | 2 | 2/2 | rapido | Quando destrói um permanente inimigo em combate: compre 1 carta |
| ×2 | Caçador Alado | criatura | 2 | 3/2 | voadora, rapido | — |
| ×2 | Atirador de Frente | criatura | 2 | 2/3 | alcance | — |
| ×2 | Garra do Vazio | magia | 2 | — | — | 3 dano mágico a um permanente. Se destruído por este efeito: causa 2 dano mágico a um segundo permanente inimigo à escolha |
| ×1 | Devastador de Linha | criatura | 3 | 5/2 | rapido, atropelar | — |
| ×1 | Interceptor Alado | criatura | 3 | 3/4 | voadora | — |
| ×1 | Descarga de Impacto | magia | 3 | — | — | 5 dano mágico a qualquer permanente ou herói |

## Por que cada carta existe

**Incursor e Lâmina** são os dois 1-drops com perfis diferentes. O Incursor (2/1) sobrevive a um contra-ataque de 1/X. A Lâmina (3/1) morre para qualquer resposta mas ameaça 3 de dano imediato. O jogador escolhe qual jogar dependendo do estado do tabuleiro.

**Fenda Astral** é o instantâneo de 1 de energia que remove qualquer criatura pequena bloqueando uma rota. Decisão: usar agora para abrir caminho ou guardar?

**Pilhador Implacável** recompensa manter rotas abertas. O draw-on-destroy não é garantido — o oponente vai bloquear exatamente esse slot. Cria tensão em ambos os lados.

**Caçador Alado** (3/2 voadora rapido) é a carta mais ameaçadora. Voa sobre bloqueadores terrestres e ataca imediatamente. Exige alcance ou outra voadora para resposta.

**Atirador de Frente** (2/3 alcance) é a única criatura sem rapido. Mais resiliente, atira por cima de bloqueadores, sustenta pressão quando os rapidos foram bloqueados.

**Garra do Vazio** cria uma decisão de alvo: use em criatura fraca (2 dano bônus garantido) ou em criatura forte (bônus incerto). Se matar o alvo, causa dano extra num segundo alvo à escolha.

**Devastador de Linha** (5/2 rapido atropelar) é máximo risco. Pode fechar jogos sozinho — morre para qualquer 2 de ATK em resposta. Existe para criar o momento de "ou funciona e o jogo acaba, ou perco a carta."

**Interceptor Alado** (3/4 voadora) é o oposto: resiliente, sem rapido. Exige resposta específica do inimigo — alcance ou magia — e fica em campo por muitos turnos.

**Descarga de Impacto** é o finisher flexível. Cinco de dano por 3 de energia: mata criatura grande bloqueando, elimina parte de chefe, ou vai no herói no `duelo`. Substituiu o Surto de Vácuo original que só atingia herói.

## Requisitos de Engine Novos

**"Quando destrói permanente em combate"** (Pilhador): hook no ponto de resolução de combate onde a criatura alvo é destruída. Moderado. Compartilhado com Arquiteto (Guardião de Cristal), Dominador (implícito), Vinculador (Laçador).

**"Se destruído por este efeito"** (Garra do Vazio): verificação após resolução do dano do feitiço — a criatura foi destruída? Se sim, aplica efeito secundário. Pequeno.

Rapido, voadora, alcance, atropelar, instantâneo: já implementados.

## Encontros que Testam este Deck

Um **defensor 0/7 no slot central** bloqueia a rota principal, forçando voadora ou alcance. Um encontro `ondas` onde a segunda onda chega com **queimando pré-aplicado em todos os slots** — o Assaltante precisa limpar o próprio campo antes de atacar.
