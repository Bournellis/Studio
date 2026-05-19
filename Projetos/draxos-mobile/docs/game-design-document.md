# DraxosMobile — Game Design Document (Referencia De Implementacao)

- Ultima atualizacao: `2026-05-19`
- Fonte completa: `../../_conceitos/mobile-universe/gdd.md`

> Este documento e uma referencia condensada para implementacao. Para o design completo com todas as formulas, tabelas e decisoes detalhadas, consulte o GDD completo no caminho acima.

---

## Personagem

- Raca: Draxos. Nome definido pelo jogador. Sem classes.
- Visual: silhueta vultuosa, manto comprido, etereo e energetico
- Level maximo Season 1: 40. Primeiro slice: level 10.
- Formula de XP: `XP_total(n) = 3 × (n³ - 6n² + 17n - 12)`
- **Cap universal:** Level Global e o teto de arma, spells e construcoes — nenhum sistema pode ser upado para um level maior que o personagem. Seasons futuras expandem o cap alem de 40.

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
- Tres dimensoes: Tipo / Qualidade (Ossos, craftado no Ossario) / Level (Almas, 40/season, reseta)
- **Tipo atual (primeiro slice):** Varinha — dano Magico. Outros tipos: desbloqueio futuro.
- Crafting (primeiro slice): upgrade de dano via Ossos — sem outras dimensoes por enquanto
- Ossos: drops de batalha + quests iniciais + producao do Ossario
- Maestria: acumula por dano causado, amplifica dano da varinha, permanente na conta

### Spells — Pool Completa

Tipos de alvo: **Direto** (primeiro da fila) · **Area** (primeiro + segundo da fila) · **Jogador** (mago diretamente, ignora summons) · **—** (buff ou invocacao)

Fila de alvos: Summon Frente → Summon Meio → Mago → Summon Tras.

| Spell | Tipo | Tipo de Alvo | Efeito resumido |
|---|---|---|---|
| Raio Cosmico | Magico | Direto | Dano magico no primeiro da fila |
| Raio | Choque | Jogador | Dano + marcadores no mago (5 = burst + stun) |
| Acender | Fogo | Area | Dano + Queimando no primeiro e no segundo da fila |
| Envenenar | Veneno | Jogador | Envenenado direto no mago |
| Congelar | Gelo | Area | 1 stack de Lento no primeiro e no segundo da fila. Cada alvo tem contador independente — burst (grande dano + Congelado breve) dispara por alvo ao atingir 3 stacks, sem se propagar. |
| Odio | Morte | Jogador | Grande dano de Morte direto no mago |
| Dilacerar | Sangramento | Direto | Dano + Sangrando no primeiro da fila |
| Fortificar | — | — | Barreira Magica + Resistencia Global (buff proprio) |
| Invocar Demonio | Fogo | — | Summon — Demonio (Tras, dano Fogo). Tempo de vida a calibrar. |
| Animar Morto | Morte | — | Summon — Esqueleto (Frente) ou Morto-Vivo (Meio), ambos dano Morte. Usa slot livre se ocupado. |

**Unlock de slots e spells:**

Nao e restricao de slot — e ordem de desbloqueio por level minimo. Uma vez desbloqueada, a spell pode ir em qualquer slot. Unlocks de slot e de spell custam Almas e sao feitos no Altar das Almas.

| Level minimo | O que fica disponivel para unlock |
|---|---|
| 1–3 | Slot 1 + Raio Cosmico |
| 10–15 | Slot 2 + Raio, Acender, Envenenar, Congelar |
| 20–25 | Slot 3 + Odio, Dilacerar, Fortificar, Invocar Demonio, Animar Morto |

### Summons

Criaturas invocadas por spells de summon que combatem ao lado do mago.

- Atacam e usam habilidades automaticamente (igual ao pet)
- **Tipo de alvo:** Direto — atacam o primeiro da fila inimiga
- Diferente do pet: podem receber dano e serem mortos
- Possuem HP proprio e tempo de vida
- Cada posicao (Frente / Meio / Tras) e um slot independente

**Posicoes:**

| Posicao | Comportamento |
|---|---|
| Frente | Absorve todo dano direto antes do mago |
| Meio | Divide dano 50/50 com o mago |
| Tras | Recebe apenas dano de area — protegido de ataques diretos |

**HP base de referencia (nivel 1):**

| Summon | Posicao | HP |
|---|---|---|
| Esqueleto | Frente | 60 |
| Morto-Vivo | Meio | 40 |
| Demonio | Tras | 50 |

**Duracao:** ~8s (ligeiramente menor que o recast de 10s — cria gap de ~2s sem summon). A calibrar.

**Recast:**
- Invocar Demonio: sempre substitui ao disparar
- Animar Morto: prioriza slot vazio (Frente → Meio). So substitui se ambos estiverem ocupados.

**Spells de summon do primeiro slice:**

| Spell | Summon | Posicao | Tipo de dano | Mana |
|---|---|---|---|---|
| Invocar Demonio | Demonio | Tras | Fogo | 20 |
| Animar Morto | Esqueleto | Frente | Morte | 20 |
| Animar Morto | Morto-Vivo | Meio | Morte | 20 |

Para valores completos: `../../_conceitos/mobile-universe/gdd.md` secao 3.15 e P14 em pendencias.md.

### Passivas (1 Slot, 5 Opcoes, 10 Levels)

Forca / Resistencia / Escudo / Vampirismo / Velocidade.
Desbloqueadas e upadas pelas Minas de Cristal. Recurso: Cristais. **Permanentes entre seasons.**

### Pets (1 Slot, 7 Opcoes, 40 Levels/Season)

Um pet por tipo de dano. Recurso: Sangue.

---

## Base Manager

Visual: Altar/Santuario pessoal — sombrio, organico, energetico.

### Estruturas

Toda construcao pode evoluir a si mesma ate level 40 (custo: Energia + tempo). Os levels das construcoes sao **permanentes entre seasons**. Alem do self-upgrade, cada construcao abriga upgrades especificos:

| Estrutura | Recurso produzido | Upgrades abrigados |
|---|---|---|
| Altar das Almas | Almas | Unlock e upgrade de arma, slots de spell e spells |
| Nucleo de Energia | Energia | Apenas self-upgrade (Energia e gasta nas outras construcoes) |
| Pocos de Sangue | Sangue | Upgrade de pets |
| Minas de Cristal | Cristais | Upgrade de passivas |
| Estrutura de Stats | — | Upgrade de stats do personagem |
| Ossario | Ossos (drops + quests + producao) | Crafting de arma (upgrade de dano) |

- 40 levels por estrutura, permanentes, limitados pelo level da conta
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

**`../../_conceitos/mobile-universe/gdd.md`** — secoes 3 a 17
