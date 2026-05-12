# Necromante

- Last Updated: `2026-05-12`
- Status: `design completo — deck inicial pendente de sessão dedicada`
- Índice: `README.md`
- Autoridade de Lore: `Projetos/draxos-roguelike-cardgame/docs/classes/necromante.md`

## Identidade

O Necromante transforma morte em recurso. Toda criatura destruída em campo — aliada ou inimiga, em qualquer turno — gera Cinzas. Cinzas acumulam ao longo do encontro e financiam o Ritual das Sombras, um hero power de três degraus de poder crescente.

Criaturas do Necromante são baratas e frágeis por design. Elas existem para gerar Cinzas ao morrer e aplicar debuffs antes de cair. O campo inimigo trabalha a favor do Necromante: criaturas inimigas mortas por `queimando`, `enjoo` ou combate também geram Cinzas.

## Passiva — Colheita Sombria

Sempre que qualquer criatura for destruída em campo — aliada ou inimiga, no turno do jogador ou do inimigo — o Necromante gera **1 Cinza**.

Cinzas acumulam entre turnos e não resetam durante o encontro. São o segundo recurso da classe, paralelo à energia.

> Criaturas com efeito especial ao morrer podem gerar **2 Cinzas** em vez de 1. Apenas criaturas efetivamente destruídas geram Cinzas.

## Hero Power — Ritual das Sombras

**Custo:** 0 energia + Cinzas · Normal · 1× no próprio turno

Três degraus fixos. O jogador escolhe qual ativar:

| Degrau | Custo em Cinzas | Efeito |
|---|---|---|
| I | 2 | Aplica debuff à escolha em criatura inimiga: `enjoo_estendido`, `queimando`, ou −2/−0 permanente. |
| II | 4 | Invoca em slot aliado vazio uma criatura do **Memorial de Batalha** com stats **1/1**, mantendo as keywords originais. |
| III | 6 | Invoca do Memorial de Batalha com os **stats originais** e todas as keywords. |

A criatura invocada pelo Ritual ao ser destruída novamente gera 1 Cinza normalmente, realimentando o ciclo.

## Memorial de Batalha

O Memorial de Batalha é a lista de todas as criaturas destruídas durante o encontro atual — aliadas e inimigas. É o recurso de reanimação do Necromante no RPG Turnos, substituindo o pile de descarte do roguelike de forma mais clara: o Memorial é local ao encontro, não ao deck.

Ao usar o Ritual no Degrau II ou III, o jogador escolhe qualquer criatura do Memorial. A cópia invocada é um token independente — não é removida do Memorial ao ser invocada, pode ser invocada múltiplas vezes se Cinzas suficientes acumularem. Ao ser destruída, vai para o descarte de tokens e gera 1 Cinza normalmente.

## `enjoo_estendido`

Variante do estado `enjoo` normal, exclusiva do Necromante:

- A criatura não ataca no turno em que recebe o debuff.
- Não ataca no próximo turno inimigo completo.
- Após dois ciclos de ataque inimigo, o estado volta ao normal.

O RPG Turnos já tem `enjoo` como estado de permanente. `enjoo_estendido` adiciona apenas um contador de duração de 2 turnos a esse estado. A UI deve diferenciar visualmente os dois estados.

## Loop Central

**Turnos 1–2:** inundar o campo com criaturas de custo 0–1. Cada morte imediata — causada pelo inimigo ou por criaturas atacando e morrendo — começa a gerar Cinzas. Debuffs de entrada bloqueiam as ameaças mais imediatas.

**Turnos 3–5:** Cinzas suficientes para Degrau I ou II aparecem. `enjoo_estendido` constante impede o inimigo de executar o plano. Criaturas reanimadas pelo Degrau II entram, possivelmente morrem de novo, gerando mais Cinzas.

**Turnos 6+:** com Cinzas acumuladas e energia máxima, o Necromante combina debuffs de carta com o Ritual no Degrau III no mesmo turno. Criaturas grandes do Memorial voltam com stats completos — e ao morrer realimentam o ciclo.

## Ponto de Virada

`queimando` em slots inimigos gera mortes automáticas no upkeep sem ação do jogador. Quando o campo inimigo começa a gerar Cinzas passivamente, o Necromante acumula recursos sem gastar energia.

## Ponto Fraco

Encontros `duelo` com herói inimigo de HP alto e poucas criaturas reduzem significativamente a geração de Cinzas. `quebra_cabeca` com limite de turnos curto não deixa o Necromante acumular Cinzas para o Degrau III. Permanentes com `defensor` e HP muito alto que o inimigo mantém vivos bloqueam a geração passiva.

## Direção de Cartas

**Criaturas do Necromante** são projetadas para morrer e gerar valor:
- **Custo 0–1, stats fracos (1/1 ou 2/1):** entram, cobrem uma rota brevemente, morrem, geram Cinzas.
- **Efeito ao morrer:** o valor real da criatura. Exemplos: causa 1 de dano mágico a qualquer alvo, aplica `enjoo` em criatura inimiga, gera 2 Cinzas em vez de 1.
- **Efeito ao entrar:** aplica debuff imediatamente antes de morrer.
- **Criaturas de alto custo e stats bons:** alvo ideal de reanimação pelo Ritual Degrau III, não invocadas diretamente no deck inicial.

**Magias do Necromante:**
- `enjoo` ou `enjoo_estendido` em criatura inimiga.
- `queimando` em criatura ou slot inimigo.
- Dano mágico em criatura danificada para finalizar e gerar Cinza.
- Sem magias de buff de campo ou criatura. O Necromante não escala aliados.

## Deck Inicial

Composição aproximada (design final em sessão dedicada):

| Papel | Tipo | Custo | Qtd |
|---|---|---|---|
| Criatura sacrificial A (efeito ao morrer: dano) | criatura | 1 | ×3 |
| Criatura sacrificial B (efeito ao morrer: enjoo) | criatura | 1 | ×3 |
| Criatura sacrificial zero (gera 2 Cinzas ao morrer) | criatura | 0 | ×2 |
| Criatura alvo de reanimação (stats bons, sem habilidade) | criatura | 3 | ×2 |
| Magia — enjoo em criatura inimiga | magia | 1 | ×3 |
| Magia — queimando em slot inimigo | magia | 1–2 | ×3 |
| Magia — dano mágico finalizador | magia | 2 | ×2 |
| Magia de tabuleiro — debuff amplo | magia_de_tabuleiro | 3–4 | ×2 |

Total: 20 cartas. Nomes e stats definitivos pendentes.

## Requisitos de Engine Novos

| Sistema | Complexidade |
|---|---|
| Contador de Cinzas por encontro (persistente entre turnos) | Baixa |
| Memorial de Batalha (lista de criaturas destruídas no encontro) | Média |
| Hero power condicional com 3 degraus de custo em Cinzas | Média |
| Spawn de criatura-token a partir do Memorial (com stats opcionais) | Média |
| `enjoo_estendido` com contador de duração de 2 turnos | Baixa |
| Trigger "ao morrer" em criaturas | Média — compartilhável com outras classes futuras |
