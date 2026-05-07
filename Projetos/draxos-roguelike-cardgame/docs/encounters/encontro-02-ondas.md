# Encontro 02 — Ondas

- Last Updated: `2026-05-07`
- Status: `mockup de teste`
- Tipo: `ondas`
- Diretor: `waves`

## Objetivo

Sobreviver e limpar as 3 ondas de criaturas inimigas.

## Configuração

- Slots do jogador: **3**
- Slots do inimigo: **3**
- Avanço de onda: quando a onda atual é completamente eliminada, a próxima chega no início do próximo turno inimigo
- Criaturas aliadas **sobrevivem entre ondas** — criaturas mantidas em campo chegam bufadas ou intactas para ondas seguintes

## Criaturas Inimigas — Mockup

> Sem nome, arte ou lore definitivos. Existem para validar os números dos decks de classe.

### Onda 1 — 2 criaturas

| Criatura | ATK | HP |
|---|---|---|
| Elemental Menor | 1 | 2 |
| Elemental Menor | 1 | 2 |

HP total: **4** · ATK por turno: **2**

Introdução ao ritmo. Deve ser eliminada em 1–2 turnos sem grande custo de recursos.

### Onda 2 — 2 criaturas

| Criatura | ATK | HP |
|---|---|---|
| Elemental Médio | 2 | 3 |
| Elemental Médio | 2 | 3 |

HP total: **6** · ATK por turno: **4**

Escalada de pressão. Jogadores que esgotaram recursos na onda 1 começam a sentir.

### Onda 3 — 3 criaturas

| Criatura | ATK | HP |
|---|---|---|
| Elemental Pesado | 3 | 4 |
| Elemental Pesado | 2 | 4 |
| Elemental Pesado | 1 | 4 |

HP total: **12** · ATK por turno: **6**

Pressão real. Preenche os 3 slots inimigos. Exige o melhor da classe para limpar.

## Resumo Numérico

| Onda | HP Total | ATK/Turno |
|---|---|---|
| 1 | 4 | 2 |
| 2 | 6 | 4 |
| 3 | 12 | 6 |
| **Total** | **22** | — |

## Decisão Central

Gastar recursos agora (limpar onda 1 e 2 rapidamente) ou conservar (deixar criaturas aliadas vivas para onda 3)?

Criaturas aliadas que sobrevivem são um investimento — mas cada turno extra que o inimigo fica em campo é dano recebido.

## Comportamento Esperado por Classe

**Arcano:** ondas 1 e 2 são para construir Fluxo com custo baixo. Onda 3 é o momento da explosão de dano acumulado com Fluxo alto.

**Invocador:** criaturas com Proteção e buffs permanentes acumulados nas ondas 1 e 2 chegam à onda 3 muito mais fortes do que saíram do deck. Recompensa fortemente jogar criaturas resistentes cedo.

**Necromante:** 4 mortes na onda 1 + 4 na onda 2 = ~8 Cinzas antes da onda 3. Degrau III fica acessível exatamente quando a onda mais difícil chega. Reanimação de uma criatura forte pode ser decisiva.

## Principal Risco de Balanceamento

A onda 3 causa 6 de dano por turno. Se o jogador chegar com HP baixo do acúmulo de dano das ondas anteriores, pode não ter turnos suficientes para limpar 12 HP. Monitorar durante o teste e ajustar HP da onda 3 se necessário.

## O Que Validar

- A escalada de pressão entre ondas parece natural?
- O Invocador tem vantagem real por manter criaturas entre ondas?
- O Necromante acumula Cinzas suficientes para Degrau III antes ou durante a onda 3?
- O jogador tem escolhas significativas sobre quando gastar recursos vs conservar?
