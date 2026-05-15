# Encontro 02 - Ondas

- Last Updated: `2026-05-13`
- Status: `mockup validado na rota linear redesenhada`
- Tipo: `ondas`
- Diretor: `waves`

## Objetivo

Sobreviver e limpar 3 ondas de criaturas inimigas.

## Configuracao

- Slots do jogador: 3.
- Slots do inimigo: 3.
- Tier: `medium`.
- Almas: 7.
- Recompensa extra: +1 max mana quando aparece como mapa 5 da rota de 13 mapas.
- A proxima onda entra quando a onda atual for eliminada e ainda houver ondas pendentes.

## Combate

O encontro usa combate frontal por lane. Criaturas aliadas que sobrevivem continuam em campo entre ondas, preservando buffs e dano recebido.

## Ondas - Mockup

### Onda 1

| Criatura | ATK | HP |
|---|---:|---:|
| Elemental Menor | 1 | 2 |
| Elemental Menor | 1 | 2 |

### Onda 2

| Criatura | ATK | HP |
|---|---:|---:|
| Elemental Medio | 2 | 3 |
| Elemental Medio | 2 | 3 |

### Onda 3

| Criatura | ATK | HP |
|---|---:|---:|
| Elemental Pesado | 3 | 4 |
| Elemental Pesado | 2 | 4 |
| Elemental Pesado | 1 | 4 |

## O Que Validar

- Se a recompensa de +1 max mana no mapa 5 muda o ritmo sem quebrar o duelo do mapa 6.
- Se criaturas mantidas em campo entre ondas criam decisoes relevantes.
- Se a pressao das ondas combina com deck ja acrescido da carta custo 2 e mao base 3.
