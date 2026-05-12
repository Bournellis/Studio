# Encontro 01 - Limpar Mesa

- Last Updated: `2026-05-12`
- Status: `mockup validado na rota linear`
- Tipo: `limpar_mesa`
- Diretor: `prefilled_board`

## Objetivo

Eliminar as criaturas inimigas em campo. Todas comecam posicionadas desde o turno 1.

## Configuracao

- Slots do jogador: 3.
- Slots do inimigo: 3.
- Tier: `small`.
- Almas: 4.
- Recompensa extra: nenhuma.

## Combate

Este encontro usa o combate frontal padrao:

- cada criatura ataca apenas a lane diretamente a frente;
- dano entre duas criaturas opostas e simultaneo;
- inimigo sem defensor na frente causa dano direto ao Comandante;
- heroi inimigo nao e alvo direto neste modo.

## Criaturas Inimigas - Mockup

| Criatura | ATK | HP | Perfil |
|---|---:|---:|---|
| Elemental Agil | 2 | 2 | Baixo HP e pressao imediata. |
| Elemental Bruto | 3 | 3 | Maior ameaca de dano. |
| Elemental Solido | 1 | 5 | Baixo dano, mais dificil de remover. |

## O Que Validar

- Se a primeira luta apresenta bem o ritmo de lanes frontais.
- Se o dano direto pune lanes vazias sem encerrar a run cedo demais.
- Se Arcano, Invocador e Necromante conseguem estabilizar com mana inicial 2.
