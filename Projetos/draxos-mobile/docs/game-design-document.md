# DraxosMobile — Game Design Document (Referencia De Implementacao)

- Ultima atualizacao: `2026-05-18`
- Fonte completa: `../../Projetos/_conceitos/mobile-universe/gdd.md`

> Este documento e uma referencia condensada para implementacao. Para o design completo com todas as formulas, tabelas e decisoes detalhadas, consulte o GDD completo no caminho acima.

---

## Personagem

- Raca: Draxos. Nome definido pelo jogador. Sem classes.
- Visual: silhueta vultuosa, manto comprido, etereo e energetico
- Level maximo Season 1: 40-50. Primeiro slice: level 10.
- Formula de XP: `XP_total(n) = 3 × (n³ - 6n² + 17n - 12)`

### Stats Base — Level 1

| Stat | Valor |
|---|---|
| Vida | 100 |
| Regen Vida | 1/s (cresce por level) |
| Mana | 20 |
| Regen Mana | 2/s (cresce por level) |
| Ataque | 15 |
| Defesa | 4 |
| Vel. Ataque | 1/s (nao cresce por level) |
| Acel. Habilidade | 0% (nao cresce por level) |

Curva de crescimento (~20%/level): ver GDD secao 8.3.

### Tipos De Dano

7 tipos: Magico, Fogo, Gelo, Veneno, Choque, Morte, Sangramento.
DoTs, resistencias, barreiras e status effects: ver GDD secao 3.4–3.8.

**Regra de stacking de DoT:** cada instancia tem duracao independente — sem substituicao.

### Arma — Varinha Magica (Primeiro Slice)

- Ataque basico: dano Magico direto
- Ataque especial: 4o ataque = 3x dano
- Tres dimensoes: Tipo / Qualidade (Ossos) / Level (Almas, 40/season)
- Maestria: acumula por dano causado, amplifica dano da varinha, permanente na conta

### Spells — Pool Completa

| Spell | Tipo | Efeito resumido |
|---|---|---|
| Raio Cosmico | Magico | Dano direto puro |
| Raio | Choque | Dano + marcadores (5 = burst + stun) |
| Acender | Fogo | Dano + Queimando |
| Envenenar | Veneno | Envenenado (DoT puro) |
| Congelar | Gelo | Stacks Lento (3 = burst + Congelado) |
| Odio | Morte | Grande dano direto |
| Dilacerar | Sangramento | Dano + Sangrando |
| Fortificar | — | Barreira Magica + Resistencia Global |

**Desbloqueio de slots por level:**
- Slot 1 (Raio Cosmico fixo): level 1-3
- Slot 2 (escolha Raio/Acender/Envenenar/Congelar): level 10-15
- Slot 3 (escolha livre): level 20-25

### Passivas (1 Slot, 5 Opcoes, 10 Levels)

Forca / Resistencia / Escudo / Vampirismo / Velocidade.
Desbloqueadas e upadas pela base. Recurso: Cristais.

### Pets (1 Slot, 7 Opcoes, 40 Levels/Season)

Um pet por tipo de dano. Recurso: Sangue.

---

## Base Manager

Visual: Altar/Santuario pessoal — sombrio, organico, energetico.

### Estruturas

| Estrutura | Recurso produzido |
|---|---|
| Altar das Almas | Almas |
| Nucleo de Energia | Energia |
| Pocos de Sangue | Sangue |
| Minas de Cristal | Cristais |
| Estrutura de Stats | — (evolui stats) |
| Crafting / Ossario | Ossos (craftado) |

- 40 levels por estrutura, limitados pelo level da conta
- Fila: 1 slot padrao, 2 com compra unica
- Custo por level: `max(20, round(0.5 × n²))` Energia — total ~15.000/estrutura
- Duracao: 2 min (level 1) ate 160h (level 40)
- Ajuda: botao "Pedir Ajuda" por construcao — 1,5%/ajuda, max 10 = 15% reducao

---

## Autobattler PVP

- Batalha 100% automatica e assincrona
- Simulada no servidor — cliente recebe log de eventos e anima
- Anti-stall: dispara aos 30s — dano 10%/20%/40% HP/s aos 30s/32s/34s, letal 36s+
- Recompensa vitoria: XP + Almas + Energia + Sangue completos
- Recompensa derrota: 1/5 de todos

---

## Economia

### Recursos Por Batalha (Base)

| Recurso | XP Dobrada | XP Normal | XP Reduzida |
|---|---|---|---|
| Almas | 6 | 3 | 1,5 |
| Sangue | 2 | 1 | 0,5 |
| Energia | 4 | 2 | 1 |

### Cotas Diarias De XP (Batalha)

- XP Dobrada: 380 XP — XP Normal: 190 — XP Reduzida: 285
- Total diario: 855 XP | Acumulado 3 dias: 2.565 | Semanal: 5.985

### Season

- Duracao: 4 meses, 2 Battle Passes por season
- Itens com reset por season: arma (level), spells (level), pet (level)
- Permanentes: Level Global, Maestria, Passivas

### Curvas De Upgrade

- Arma/Spell: `max(10, round(0.2 × n²))` Almas — total ~5.200/item
- Pet: `max(5, round(0.15 × n²))` Sangue — total ~4.000
- Passiva: total ~1.000 Cristais (10 levels)

---

## Sistema Social

- Amigos: por username ou codigo de convite
- Guilda: level 1-10 (10-50 membros), 4 construcoes com bonus passivos
- Bonus de guilda: velocidade construcao, producao recursos, XP leve, armazenamento
- Chat: guilda + direct/friends no primeiro slice. Global: Discord externo.

---

## Matchmaking E Ranking

- Poder: `(Level×50) + (Arma×30) + (Spells×20 cada) + (Pet×15) + (Passivas×10 cada) + (Qualidade×25)`
- Ranking: pontos de arena por season (vitoria=+pontos, derrota=-pontos, variavel por diferenca de poder)

---

## Referencias Completas

Para formulas detalhadas, tabelas de DoT, status effects, custos de guilda e todos os valores numericos:

**`../../Projetos/_conceitos/mobile-universe/gdd.md`** — secoes 3 a 17
