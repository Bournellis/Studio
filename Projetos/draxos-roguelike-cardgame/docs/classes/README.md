# Classes — Índice

- Last Updated: `2026-05-07`
- Status: `design completo — passivas, ativas e decks mockup registrados — aguarda validação de mecânica`
- Referência: `../lore-campaign.md`, `../game-design-document.md`

## Decisão de Design

O jogador escolhe uma classe antes de cada run e carrega essa identidade até o fim da expedição ou até a derrota. Recompensas do mapa podem ser adquiridas por qualquer classe — o que muda é o que cada classe faz de melhor com elas.

Cada classe tem:

- um **deck inicial próprio** alinhado à sua filosofia
- uma **spell de classe** usável uma vez por turno (custo 1 mana para Arcano; custo em Cinzas para Necromante; custo 1 mana para Invocador)
- uma **habilidade passiva inicial** que define a mecânica central da classe

Durante a run, recompensas de boss permitem ao jogador escolher 1 em 3 **passivas adicionais**, escalando o poder da classe a cada etapa da campanha.

## As Três Classes

| Classe | Passiva Inicial | Habilidade Ativa | Mecânica Central |
|---|---|---|---|
| [Arcano](arcano.md) | **Fluxo Contínuo:** cada carta jogada gera 1 Fluxo; cada ponto de Fluxo dá +1 de dano a spells e habilidades neste turno; reseta no início do próximo turno | **1 mana:** causa 1 de dano (+Fluxo) a qualquer alvo; uma vez por turno | Ciclar cartas para amplificar dano; criaturas de proteção e geração de mana |
| [Invocador](invocador.md) | **Comandante de Campo:** ao invocar qualquer criatura, a aliada de maior ATK ganha +1/+0 permanente (empate: jogador escolhe) | **1 mana:** criatura aliada escolhida ganha +2/+0 permanente; uma vez por turno | Criaturas com habilidades únicas; buffs permanentes que acumulam ao longo da batalha |
| [Necromante](necromante.md) | **Colheita Sombria:** qualquer criatura que morre em campo (aliada ou inimiga, qualquer turno) gera 1 Cinza; acumula entre turnos | **0 mana + Cinzas:** Degrau I (2) debuff à escolha · Degrau II (4) reanima 1/1 · Degrau III (6) reanima com stats originais; uma vez por turno | Ciclo de mortes; Cinzas como segundo recurso paralelo ao mana; debuffs de disrupção |

## Mecânicas Exclusivas por Classe

- **Fluxo Contínuo (Arcano):** contador que reseta a cada turno. Afeta apenas dano direto de spells e habilidades — não afeta ataque de criaturas.
- **Buffs permanentes (Invocador):** buffs aplicados durante a batalha ficam na criatura até o fim do encontro. A passiva e a spell de classe são sempre permanentes. Algumas spells do deck têm buffs temporários para situações pontuais.
- **Cinzas (Necromante):** acumulam entre turnos. Geradas por qualquer morte em campo, aliada ou inimiga. A spell de classe tem 3 degraus fixos: 2 Cinzas (debuff), 4 Cinzas (reanimação 1/1), 6 Cinzas (reanimação com stats originais).

## Princípios Compartilhados

- O jogador é sempre um **Comandante Draxos** — a classe define o estilo de combate, não a raça.
- Toda spell de classe é usável **uma vez por turno**.
- Toda passiva inicial é **permanente desde o início** e molda como o deck inicial deve ser jogado.
- O catálogo de cartas atual no projeto é **placeholder**. Os decks iniciais requerem sessão de design dedicada.

## Próximo Passo de Design

1. Validar mecânicas com os decks mockup em encontros reais.
2. Definir os nomes definitivos das habilidades ativas de cada classe.
3. Criar `class-catalog-schema.md` para padronizar fichas de cartas.
4. Definir keywords oficiais (Proteção, Voadora, Regeneração, Confusão, etc.) com nomes temáticos Draxos.
5. Substituir decks mockup por decks definitivos após validação.
