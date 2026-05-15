# Early Game Update - Rev 4

- Status: `Implementado com tuning P05, raridades, loja e descarte pre-combate`
- Last Updated: `2026-05-15`
- Referencia: `game-design-document.md`

## Decisoes Fechadas

- A rota aumenta de 10 para 13 mapas.
- Os mapas 1-3 sao novos tutoriais.
- O deck inicial comeca com 9 cartas, todas de custo 1.
- O mapa 1 comeca com 1 mana e 1 slot por lado.
- O mapa 1 recompensa +1 mana maxima.
- O mapa 2 usa 2 manas, 2 slots por lado e ainda nao tem carta custo 2 no deck inicial.
- O mapa 2 adiciona automaticamente 3 copias da carta custo 2 atual da classe; nao ha escolha.
- O mapa 3 introduz recompensa de upgrade: escolha 1 em 3.
- Upgrade de carta e carta nova nunca misturam na mesma recompensa.
- Carta nova adiciona 3, 4 ou 5 copias ao deck conforme raridade comum/rara/ultra rara.
- Recompensas escolhiveis rolam `70% comum`, `25% rara`, `5% ultra rara`.
- A loja de Almas oferece 3 upgrades de cartas do deck abaixo do Lvl 3, por 20 Almas, com limite de 1 compra por combate.
- Antes do combate, o jogador pode marcar cartas da mao inicial com botao direito para descartar e recomprar ate o limite.
- Cada carta pode receber 2 upgrades por campanha.
- O primeiro upgrade transforma a carta em Lvl 2.
- O segundo upgrade transforma a carta em Lvl 3.
- Cada classe tem 2 cartas novas reais no pool atual; uma sessao futura pode decidir se o kit expande para 6-8 cartas.
- Save version atual e 4; saves v3 ou anteriores ficam antigos/invalidos, deletaveis e sobrescreviveis.

## Rota De Recompensas

| Mapa | Encontro | Recompensa |
|---|---|---|
| 1 | Primeiro Contato | +1 mana maxima |
| 2 | Dois Fronts | 3 copias da carta custo 2 atual da classe |
| 3 | Primeira Onda | upgrade de carta, escolha 1 em 3 |
| 4 | Limpar Mesa atual | upgrade de carta, escolha 1 em 3 |
| 5 | Ondas atuais | +1 mana maxima |
| 6 | Duelo atual | +1 limite de mao |
| 7 | Defesa atual | carta nova, escolha 1 entre 2 |
| 8 | Chefe Invocador atual | passiva; Necromante tambem ganha Ritual nivel 1 |
| 9 | Sobreviver atual | upgrade de carta, escolha 1 em 3 |
| 10 | Limpeza Elite atual | ativa; Necromante ganha Ritual nivel 2 |
| 11 | Ondas Avancadas atuais | carta nova restante |
| 12 | Duelo Elite atual | upgrade de carta, escolha 1 em 3 |
| 13 | Chefe Final atual | vitoria da run |

## Mudancas De Classes E Cartas

- Barreira Arcana: custo 1, 0/3, `defensor`, +1 Poder de Habilidade.
- Invocador: `Comandante de Campo` dispara uma vez por turno e concede +2/+1 permanente; `Ordem de Guerra` custa 0 mana e mira a mesa aliada.
- Necromante: `Ritual das Sombras` ganha `Raio das Cinzas` no nivel 1 e `Raio das Cinzas Maior` no nivel 2.
- Defesa de Posicao: objetivo com 8 HP, 5 turnos, pressao deslocada para side lanes e sem aumentar a punicao do slot central.
- Todos os encontros receberam reforco aproximado de 20% nos stats inimigos, com arredondamento cuidadoso para manter tutoriais jogaveis.
- Menus de Necromante, escolhas pendentes e recompensa de vitoria usam transparencia alpha `0.72`.
- Escolhas automaticas pos-morte, como `Enfraquecer`, so aparecem depois que as etapas visuais de combate terminam.

## Upgrades E Cartas Reais

### Arcano

- `Choque`: Lvl 2 causa 3 dano; Lvl 3 custa 0.
- `Fagulha Arcana`: Lvl 2 vira 2/4; Lvl 3 concede +4 Poder de habilidade.
- `Barreira Arcana`: Lvl 2 vira 1/6; Lvl 3 vira 2/9 e concede +2 Poder de habilidade total.
- `Tempestade Arcana`: Lvl 2 causa 6 dano aleatorio; Lvl 3 custa 1.
- Novas: `Bola de Fogo` e `Acelerar`; `Acelerar` mira mesa aliada e concede +1/+3/+3 Poder de habilidade temporario nos niveis 1/2/3, com +1 mana no Lvl 3.

### Invocador

- `Soldado Arcano`: Lvl 2 vira 3/4; Lvl 3 vira 4/5 com Regeneracao 2.
- `Batedor Arcano`: Lvl 2 vira 3/2; Lvl 3 vira 6/2.
- `Promover`: Lvl 2 escolhe 2 opcoes; Lvl 3 recebe todas.
- `Guardiao Arcano`: Lvl 2 vira 3/6; Lvl 3 vira 4/8 com Regeneracao 3.
- Novas: `Atacar` e `Golem`; `Atacar` mira mesa aliada.

### Necromante

- `Esqueleto`: Lvl 2 vira 2/2; Lvl 3 vira 4/4.
- `Morto vivo`: Lvl 2 aplica Enfraquecer 2 ao morrer; Lvl 3 vira 2/2 e aplica Enfraquecer 3.
- `Prender`: Lvl 2 tambem aplica Enfraquecer 1; Lvl 3 tambem remove keywords.
- `Zumbi`: Lvl 2 vira 3/3 e aplica Enfraquecer 2; Lvl 3 vira 4/4 e aplica Enfraquecer 4.
- Novas: `Carniceiro` e `Diabrete`. `Carniceiro` custa 2; `Diabrete` e 2/1, 4/1, 6/1 com `Suicida 1/2/4`.

## Proxima Sessao De Design

Definir para cada classe:

- Ajustes finos de custo/stats/dano dos Lvl 2 e Lvl 3 depois de playtest.
- Se o pool de recompensa expande alem das 2 cartas novas atuais.
- Se a loja de Almas tambem deve remover carta ou comprar carta avulsa numa fase futura.
