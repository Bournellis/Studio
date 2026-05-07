# Arcano

- Last Updated: `2026-05-07`
- Status: `design completo — deck mockup registrado — aguarda validação de mecânica`
- Índice: `README.md`

## Identidade

O Arcano vence através de spells amplificadas, não de criaturas. Cada carta jogada em um turno carrega o próximo dano. Jogar rápido e em sequência é o plano — não para comprar mais cartas, mas para tornar cada fonte de dano desse turno mais letal.

Criaturas existem para proteger o Arcano enquanto ele cicla e para sustentar o ritmo de mana que permite sequências longas.

## Passiva Inicial — Fluxo Contínuo

Cada carta jogada pelo jogador neste turno gera **1 ponto de Fluxo Contínuo**.

Cada ponto de Fluxo Contínuo concede **+1 de dano** a toda fonte de dano direto do jogador neste turno: spells e habilidades ativas. Não afeta o ATK de criaturas.

Fluxo Contínuo **reseta no início do próximo turno do jogador**.

> Exemplo: o jogador joga 4 cartas antes de usar a habilidade ativa. Com 4 de Fluxo, a habilidade que causa 1 de dano causa 1+4 = **5 de dano**.

O Fluxo Contínuo é a mecânica central do Arcano. Cartas de custo zero existem para gerar Fluxo sem consumir mana, maximizando o dano das spells e da ativa no mesmo turno.

## Habilidade Ativa

**Nome:** TBD

**Custo:** 1 mana · Usável uma vez por turno

**Efeito:** Causa **1 de dano** a qualquer alvo (criatura ou herói inimigo). Amplificada pelo Fluxo Contínuo atual.

É o finisher natural do turno do Arcano. Cartas de custo zero ou baixo constroem Fluxo durante o turno; a ativa converte esse Fluxo em dano concentrado no momento ideal.

## Loop Central

**Turnos 1–2:** estabelecer uma criatura de suporte ou proteção. Jogar cartas de custo zero para sentir o ritmo do Fluxo. Spells de dano já chegam amplificadas mesmo com pouco Fluxo.

**Turnos 3–5:** com mais mana disponível — seja por mana natural ou por criaturas que geram mana — o jogador consegue jogar mais cartas antes da spell de classe. Fluxo de 4–6 transforma a spell de 1 de dano em 5–7.

**Turnos 6+:** com mana escalado por recompensas de run, sequências longas em um único turno são possíveis. A spell de classe com Fluxo alto pode eliminar criaturas grandes ou ameaçar o herói inimigo diretamente.

## Ponto de Virada

Ter mana suficiente para jogar várias cartas antes da spell de classe no mesmo turno. A partir desse ponto, o Arcano consegue concentrar dano alto em um único alvo sem precisar de múltiplas spells de alto custo.

## Ponto Fraco

Pressão de mesa rápida que força o Arcano a usar mana em respostas antes de construir Fluxo. Encontros com criaturas que chegam rapidamente no turno 1 ou 2 podem impedir qualquer sequência. Encontros `ondas` com pressão constante não permitem turnos dedicados a construir Fluxo alto.

## Direção das Criaturas

Criaturas do Arcano não são combatentes principais. Seus papéis:

- **Proteção:** criaturas com HP alto ou com Proteção (o inimigo precisa atacá-las primeiro) que existem para deixar o Arcano vivo enquanto cicla.
- **Geração de mana contínua:** enquanto em campo, concedem +1 de mana por turno ao jogador, sustentando sequências mais longas.
- **Geração de mana pontual:** ao entrar em campo, concedem 1 de mana extra naquele turno, permitindo jogar mais uma carta imediatamente.
- **Amplificação de spell:** enquanto em campo, concedem +1 de dano a todas as spells do jogador (empilha com Fluxo).

Nenhuma criatura do Arcano foca em compra de cartas — a mão já enche naturalmente. O foco é sempre em sustentar ou amplificar o dano das spells.

## Direção do Deck Inicial

- Cartas de custo zero: Fluxo puro sem custo de mana.
- Spells de dano de custo baixo (1–2 mana): amplificadas pelo Fluxo acumulado.
- Criaturas de proteção e geração de mana.
- Sem criaturas grandes ou ofensivas — o dano vem das spells.

## Deck de Teste — Mockup

> Cartas sem nome, arte ou lore definitivos. Existem para validar a mecânica de Fluxo Contínuo.
> Parâmetros de teste: mana inicial 3 · HP do Comandante 20 · deck 15 cartas.

| Papel | Custo | Qty | Stats | Efeito |
|---|---|---|---|---|
| Construtor de Fluxo | 0 | ×3 | — | Aplica Lentidão a uma criatura inimiga. |
| Spell de dano | 1 | ×5 | — | Causa 1 de dano a qualquer alvo (+Fluxo). |
| Criatura protetora | 1 | ×2 | 0/3 | Sem habilidade. |
| Criatura geradora (entrada) | 1 | ×1 | 1/2 | Ao entrar: ganhe 1 de mana neste turno. |
| Spell de dano maior | 2 | ×2 | — | Causa 2 de dano a qualquer alvo (+Fluxo). |
| Criatura geradora (contínua) | 2 | ×1 | 1/3 | Enquanto em campo: +1 de mana por turno. |
| Criatura amplificadora | 3 | ×1 | 1/4 | Enquanto em campo: spells causam +1 de dano adicional (empilha com Fluxo). |

Distribuição: 0-custo ×3 · 1-custo ×8 · 2-custo ×3 · 3-custo ×1

## Pendências de Design

- Nome da spell de classe.
- Efeitos secundários das cartas de custo zero além de gerar Fluxo.
- Definir se criaturas de amplificação de spell empilham com outras do mesmo tipo.
- Nomes e lore definitivos de todas as cartas após validação de mecânica.
