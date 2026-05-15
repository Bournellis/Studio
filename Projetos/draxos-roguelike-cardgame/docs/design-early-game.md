# Early Game Update - Rev 3

- Status: `Implementado com placeholders de design`
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
- Carta nova adiciona 3 copias ao deck.
- Cada carta pode receber 2 upgrades por campanha.
- O primeiro upgrade representa escolha futura entre dois ramos.
- O segundo upgrade e opcao unica, porque aplica o ramo restante.
- Cada classe tera 6-8 cartas de recompensa custo 1-3; o conteudo final fica A definir.

## Rota De Recompensas

| Mapa | Encontro | Recompensa |
|---|---|---|
| 1 | Primeiro Contato | +1 mana maxima |
| 2 | Dois Fronts | 3 copias da carta custo 2 atual da classe |
| 3 | Primeira Onda | upgrade de carta, escolha 1 em 3 |
| 4 | Limpar Mesa atual | upgrade de carta, escolha 1 em 3 |
| 5 | Ondas atuais | +1 mana maxima |
| 6 | Duelo atual | +1 limite de mao e upgrade de carta, escolha 1 em 3 |
| 7 | Defesa atual | carta nova, escolha 1 em 3 |
| 8 | Chefe Invocador atual | passiva; Necromante tambem ganha Ritual nivel 1 |
| 9 | Sobreviver atual | upgrade de carta, escolha 1 em 3 |
| 10 | Limpeza Elite atual | ativa; Necromante ganha Ritual nivel 2 |
| 11 | Ondas Avancadas atuais | carta nova, escolha 1 em 3 |
| 12 | Duelo Elite atual | upgrade de carta, escolha 1 em 3 |
| 13 | Chefe Final atual | vitoria da run |

## Mudancas De Classes E Cartas

- Barreira Arcana: custo 1, 1/3, `defensor`, +1 Poder de Habilidade.
- Invocador: `Comandante de Campo` dispara uma vez por turno e concede +2/+1 permanente.
- Necromante: `Ritual das Sombras` ganha `Raio das Cinzas` no nivel 1 e `Raio das Cinzas Maior` no nivel 2.
- Defesa de Posicao: objetivo com 7 HP e ondas com pressao inicial por `elemental_assaltante_veloz`.

## Placeholders Atuais

O sistema de recompensa esta implementado, mas os conteudos finais ainda nao.

- Upgrades registram progresso por carta, mas nao alteram mecanica.
- Cartas novas usam cards placeholder por classe.
- Cada classe tem 6 placeholders no pool de recompensa.
- Arte, nome final, efeito final e balanceamento dessas cartas ficam para sessao de design.

## Proxima Sessao De Design

Definir para cada classe:

- 6-8 cartas de recompensa custo 1-3.
- 2 ramos de upgrade para cada carta inicial e cada carta de recompensa.
- Quais upgrades devem ser ofensivos, defensivos ou utilitarios.
- Se a loja de Almas compra upgrade, remove carta ou compra carta avulsa nesta mesma fase.
