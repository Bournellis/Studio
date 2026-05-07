# Encontro 01 — Limpar o Board

- Last Updated: `2026-05-07`
- Status: `mockup de teste`
- Tipo: `limpar_mesa`
- Diretor: `prefilled_board`

## Objetivo

Eliminar as 3 criaturas inimigas em campo. Todas começam em campo desde o turno 1.

## Configuração

- Slots do jogador: **3**
- Slots do inimigo: **3**
- Criaturas inimigas: pré-posicionadas no início do encontro

## Criaturas Inimigas — Mockup

> Sem nome, arte ou lore definitivos. Existem para validar os números dos decks de classe.

| Criatura | ATK | HP | Perfil |
|---|---|---|---|
| Elemental Ágil | 2 | 2 | Alta prioridade: pouco HP mas dói. Fácil de matar, urgente remover. |
| Elemental Bruto | 3 | 3 | Maior ameaça de dano. Lentidão resolve por um turno. |
| Elemental Sólido | 1 | 5 | Difícil de matar, baixo dano. Pode ser deixado por último. |

## Resumo Numérico

- HP total inimigo: **10**
- Dano inimigo por turno (sem resposta): **6**
- HP do Comandante: 20 → situação crítica em ~3 turnos sem resposta

## Decisão Central

Priorizar o Bruto (maior ATK, para reduzir dano recebido) ou o Ágil (menor HP, para limpar o board mais rápido)? Ambas as escolhas têm custo.

## Comportamento Esperado por Classe

**Arcano:** usar Construtor de Fluxo (Lentidão) no Bruto no turno 1. Spells eliminam o Ágil rapidamente. Bruto e Sólido são gerenciados nos turnos seguintes com Fluxo acumulado.

**Invocador:** estabelecer Criatura Proteção para absorver ataques do Bruto. Criatura Voadora voa sobre o Sólido para acumular dano direto. Buffs permanentes tornam as criaturas resistentes a trocas.

**Necromante:** criaturas sacrificiais trocam com o Ágil gerando Cinzas. Lentidão trava o Bruto. Podridão enfraquece o Sólido antes de mandá-lo para o descarte. Cinzas acumuladas habilitam Degrau I ou II.

## Duração Esperada

2–4 turnos dependendo da classe e das cartas na mão inicial.

## O Que Validar

- O Arcano consegue causar dano suficiente para limpar antes de morrer de pressão?
- O Invocador consegue estabelecer criaturas resilientes a tempo?
- O Necromante acumula Cinzas suficientes para usar a ativa antes do fim do encontro?
- O encontro é difícil o suficiente para ser interessante mas não punitivo para um primeiro encontro?
