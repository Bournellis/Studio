# Necromante

- Last Updated: `2026-05-07`
- Status: `design completo — deck mockup registrado — aguarda validação de mecânica`
- Índice: `README.md`

## Identidade

O Necromante transforma morte em recurso. Toda criatura que morre em campo — aliada ou inimiga, no turno do jogador ou no turno do inimigo — gera **Cinzas**. Cinzas acumulam entre turnos e financiam a spell de classe, que escala em três degraus de poder.

Criaturas do Necromante são baratas e frágeis por design. Elas existem para gerar Cinzas ao morrer e para aplicar debuffs antes de cair. Spells atrasam e enfraquecem o campo inimigo enquanto o acúmulo de Cinzas prepara os momentos decisivos.

## Passiva Inicial — Colheita Sombria

Sempre que qualquer criatura morrer em campo — aliada ou inimiga, no turno do jogador ou do inimigo — o Necromante gera **1 Cinza**. Cinzas acumulam entre turnos e não resetam. São o segundo recurso da classe, paralelo ao mana.

O Necromante se beneficia de todas as mortes: criaturas aliadas que morrem por ataque inimigo, criaturas inimigas removidas por spells, criaturas que se matam entre si por Confusão — todas geram 1 Cinza.

> Exceção: criaturas sacrificiais zero do deck mockup geram 2 Cinzas ao morrer por efeito de carta próprio.

## Habilidade Ativa — Ritual das Sombras *(nome provisório)*

**Custo:** 0 mana · Usável uma vez por turno · Custa **Cinzas**

Três degraus fixos. O jogador escolhe qual ativar:

| Degrau | Custo em Cinzas | Efeito |
|---|---|---|
| I | 2 | Aplique um debuff à escolha a uma criatura inimiga: **Lentidão** (não ataca este turno), **Podridão** (perde 1/1 permanente) ou **Maldição** (recebe 1 de dano no início de cada turno inimigo). |
| II | 4 | Traga uma criatura do descarte ao campo com stats **1/1**. Mantém habilidades de morte. |
| III | 6 | Traga uma criatura do descarte ao campo com os **stats originais**. Mantém todas as habilidades. |

A criatura trazida pelo Degrau II ou III ao morrer novamente gera 1 Cinza normalmente, podendo realimentar o ciclo.

## Loop Central

**Turnos 1–2:** inundar o campo com criaturas de custo 0–1. Cada morte imediata — causada pelo inimigo ou por criaturas atacando e morrendo — começa a gerar Cinzas. Spells de debuff lento chegam para comprar tempo.

**Turnos 3–5:** Cinzas suficientes para Degrau I ou II começam a aparecer. Debuffs constantes impedem o inimigo de executar o plano. Uma criatura reanimada por Degrau II entra e possivelmente morre de novo, gerando mais Cinzas.

**Turnos 6+:** com Cinzas acumuladas e mana escalado por recompensas, o Necromante pode combinar spells de debuff com Ritual das Sombras no Degrau III no mesmo turno. Criaturas com habilidades de morte voltam ao campo com stats completos e podem morrer novamente, realimentando o ciclo.

## Ponto de Virada

Ter Cinzas suficientes para escolher o degrau certo no momento certo, enquanto debuffs de Confusão fazem criaturas inimigas se atacarem entre si — gerando ainda mais Cinzas. O inimigo começa a trabalhar contra si mesmo.

## Ponto Fraco

Inimigos que ganham buffs ao destruir criaturas alimentam o Necromante de Cinzas, mas também crescem enquanto isso. Encontros `duelo` contra um herói inimigo com HP alto e poucas criaturas reduzem a geração de Cinzas significativamente. Encontros `ondas` com criaturas que chegam em grupo antes do Necromante acumular Cinzas podem sobrecarregar o campo.

## Vocabulário de Debuffs

| Debuff | Efeito |
|---|---|
| **Lentidão** | A criatura não ataca neste turno. |
| **Podridão** | A criatura perde X/X permanentemente (valor definido pela carta ou degrau). |
| **Maldição** | A criatura recebe 1 de dano no início de cada turno inimigo. |
| **Confusão** | A criatura ataca um alvo aleatório naquele turno (pode atingir criaturas aliadas do inimigo). |

O Degrau I do Ritual das Sombras aplica um debuff à escolha do jogador entre Lentidão, Podridão e Maldição. Confusão é exclusiva de spells específicas do deck.

## Direção das Criaturas

Criaturas do Necromante são projetadas para morrer e gerar valor ao fazer isso:

- **Custo 0–1, stats fracos (1/1 ou 2/1):** querem entrar, gerar pressão mínima, e morrer para gerar Cinzas.
- **Efeito ao morrer:** o valor real da criatura. Exemplos: causa 1 de dano a qualquer alvo, aplica Lentidão a uma criatura inimiga, gera 2 Cinzas em vez de 1.
- **Efeito ao entrar:** algumas criaturas aplicam um debuff imediatamente ao entrar, antes mesmo de morrer.
- Sem criaturas grandes ou de late-game — o Ritual das Sombras no Degrau III cumpre esse papel trazendo criaturas do descarte.

## Direção do Deck Inicial

- Maioria de criaturas de custo 0–1 com efeitos de morte.
- Algumas cartas de custo zero que existem só para gerar Cinzas rápido no turno 1.
- Spells de debuff: Lentidão, Podridão, Maldição, Confusão em proporções variadas.
- Sem criaturas grandes — o Ritual das Sombras é o "late-game" do Necromante.

## Deck de Teste — Mockup

> Cartas sem nome, arte ou lore definitivos. Existem para validar a mecânica de Colheita Sombria e geração de Cinzas.
> Parâmetros de teste: mana inicial 3 · HP do Comandante 20 · deck 15 cartas.

| Papel | Custo | Qty | Stats | Efeito |
|---|---|---|---|---|
| Criatura sacrificial zero | 0 | ×2 | 1/1 | Ao morrer: gera **2 Cinzas** em vez de 1. |
| Criatura sacrificial A | 1 | ×3 | 2/1 | Ao morrer: causa 1 de dano a qualquer alvo. |
| Criatura sacrificial B | 1 | ×3 | 1/2 | Ao morrer: aplica Lentidão a uma criatura inimiga. |
| Spell — Lentidão | 1 | ×2 | — | Uma criatura inimiga não ataca neste turno. |
| Spell — Podridão | 1 | ×2 | — | Uma criatura inimiga perde 1/1 permanente. |
| Criatura alvo de reanimação | 2 | ×2 | 3/3 | Sem habilidade. Alvo ideal para Ritual Degrau III. |
| Spell — Confusão | 2 | ×1 | — | Uma criatura inimiga ataca um alvo aleatório neste turno. |

Distribuição: 0-custo ×2 · 1-custo ×10 · 2-custo ×3 · 3-custo ×0

Geração esperada de Cinzas por turno (early game): 2–4. Degrau I disponível ~turno 2. Degrau III disponível ~turno 6.

## Pendências de Design

- Nome definitivo do Ritual das Sombras.
- Verificar interação de Confusão com o sistema de ataque automático do engine.
- Nomes e lore definitivos de todas as cartas após validação de mecânica.
