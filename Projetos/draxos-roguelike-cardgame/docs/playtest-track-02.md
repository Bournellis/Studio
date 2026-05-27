# Playtest Track 02

- Last Updated: `2026-05-27`
- Status: `READY_FOR_HUMAN_PLAYTEST`

## Preflight

- Rodar `tools/validate.gd` e confirmar GUT verde.
- Rodar `tools/run_lab.gd` para Arcano, Invocador e Necromante com seed `20260518`.
- Confirmar que o save antigo pode ser apagado ou sobrescrito pelo menu.
- Criar um save novo por classe quando possivel.
- Anotar seed, classe, mapa final, HP final, deck size, reliquias, acoes de loja e causa de morte/vitoria.

## Roteiro Por Classe

Rodar pelo menos uma tentativa por classe:

| Classe | Foco |
|---|---|
| Arcano | Fluxo, poder de habilidade, burst de spells, clareza de alvos e escalada de dano. |
| Invocador | Presenca de mesa, buffs permanentes, Escudo/Inspirar/Pacto e risco de mesa imortal. |
| Necromante | Cinzas, death triggers, reanimacao, Veneno/Ressurgir e plano quando criaturas morrem demais. |

## Checkpoints De Rota

- Mapas 1-3: tutorial, mao inicial, custo 1, descarte marcado.
- Mapas 4-8: primeiro boss, primeira passiva, primeiras relics/rewards reais.
- Mapas 9-15: Gelo, controle, boss intermediario, HP/max hand progression.
- Mapas 16-22: Ar, board formats maiores, intent legivel, boss de tempestade.
- Mapas 23-29: Fogo, field effects agressivos, shop final, boss final e vitoria.

## Template De Feedback

```text
Classe:
Seed:
Resultado: vitoria / morte / abandono
Mapa final:
HP final:
Deck size final:
Reliquias:
Acoes de loja usadas:
Turnos percebidos: curto / ok / longo
Pico de dificuldade:
Mapa mais confuso:
Carta/reliquia mais forte:
Carta/reliquia mais fraca:
Momento mais divertido:
Momento mais frustrante:
Notas:
```

## Bugs

```text
Titulo:
Classe/seed/mapa:
Passos:
Resultado esperado:
Resultado obtido:
Bloqueia run? sim / nao
Screenshot/video:
```

## Metricas Manuais

- Mapas concluidos.
- Mortes e causa percebida.
- HP antes/depois de boss.
- Deck size aproximado apos cada bloco elemental.
- Reliquias compradas/ganhas.
- Compra de cura, HP maximo, remocao, duplicacao, upgrade, carta e reliquia.
- Momentos de UI confusa: reward, shop, map, keyword, intent, board grande.

## Criterios De Sucesso

- O jogador entende para onde ir e o que mudou apos cada recompensa.
- Cada classe sente diferente antes e depois dos unlocks.
- A rota completa parece longa, mas nao repetitiva.
- Shop e relics geram decisoes reais sem esconder informacao importante.
- Enemy intent ajuda a explicar risco sem resolver o jogo pelo jogador.
- Pelo menos uma run por classe chega longe o bastante para avaliar Gelo, Ar e Fogo.

Run Lab e validacao servem para regressao e comparacao de tuning. Eles nao substituem este playtest humano.
