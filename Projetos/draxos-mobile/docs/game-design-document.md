# DraxosMobile — Game Design Document (Referencia De Implementacao)

- Ultima atualizacao: `2026-05-20`
- Fonte historica completa: `../../_conceitos/mobile-universe/gdd.md`

> Este documento e uma referencia condensada para implementacao. Para o design completo com todas as formulas, tabelas e decisoes detalhadas, consulte o GDD completo no caminho acima.

---

## Personagem

- Raca: Draxos. Nome definido pelo jogador. Sem classes.
- Visual: silhueta vultuosa, manto comprido, etereo e energetico
- Level maximo do primeiro slice e da Season 1: 40. O MVP tecnico usa fixture level 1.
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
- Tres dimensoes: Tipo / Qualidade (Ossos, craftado no Ossario) / Level (Almas, permanente, limitado pelo cap atual)
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

**Unlock de slots, spells, passiva e pet:**

O personagem comeca com 0 slots de spell. A Varinha Magica sustenta o combate inicial ate o primeiro unlock. Levels liberam disponibilidade; compra/equipamento continuam passando pelo Altar das Almas ou estrutura correspondente quando houver custo.

| Level | Unlock |
|---|---|
| 1 | Varinha Magica inicial, sem spell equipada |
| 3 | Slot de spell 1 e Raio Cosmico |
| 7 | Slot de spell 2 e primeiro pacote elemental: Raio, Acender, Envenenar, Congelar |
| 10 | Slot de passiva |
| 15 | Slot de pet |
| 25 | Slot de spell 3 e pacote avancado: Odio, Dilacerar, Fortificar, Invocar Demonio, Animar Morto |

Regras:

- Uma spell desbloqueada pode ser equipada em qualquer slot de spell disponivel.
- Slots bloqueados nao aceitam spell equipada nem placeholder autoritativo no servidor.
- O servidor valida unlock por level antes de aceitar `build/equip`.
- Passiva e pet podem existir como conteudo no catalogo antes do level minimo, mas nao podem ser equipados ate o unlock.

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

### Passivas (1 Slot, 5 Opcoes, 40 Levels)

Forca / Resistencia / Escudo / Vampirismo / Velocidade.
Desbloqueadas e upadas pelas Minas de Cristal. Recurso: Cristais. **Permanentes entre seasons.**

### Pets (1 Slot, 7 Opcoes, 40 Levels)

Um pet por tipo de dano. Recurso: Sangue. **Permanentes entre seasons.**

---

## Base Manager

Visual: Refugio pessoal — sombrio, organico, energetico.

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

### Dados De Combate Para Balanceamento

Toda batalha real e toda batalha simulada entre bots deve gravar dados suficientes para balancear combate, bots e matchmaking sem depender de log visual completo no cliente.

Eventos minimos de telemetria por batalha:

- `battle_requested`: power do jogador, faixa de matchmaking, modo, origem do oponente real/bot.
- `match_selected`: power do jogador, power do oponente, diferenca absoluta e percentual, tempo de busca, motivo de fallback.
- `battle_simulated`: seed, duracao, vencedor, motivo de fim, dano total por participante, dano por tipo, cura, barreira absorvida, mana gasta, summons criados, anti-stall acionado.
- `reward_applied`: reward table, deltas economicos, vitoria/derrota, idempotency key.
- `build_snapshot`: build compacta dos dois lados no momento da batalha.

Batalhas bot-vs-bot podem ser executadas como jobs de simulacao para gerar dados de balanceamento. Elas nao concedem recompensa, nao entram em ranking e devem ser marcadas com `simulation_type = "bot_balance"`.

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
- Cap da Season 1: 40 para level global, arma, spells, pet, passivas e construcoes
- Caps futuros sao configuraveis por season no simulador economico
- Permanentes entre seasons: Level Global, arma, spells, pet, passivas, construcoes, qualidade da varinha e maestrias
- Resetam por season: Battle Pass, ranking/eventos de arena, missoes sazonais e ofertas temporarias
- Catch-up futuro: multiplicador suave de XP/recursos para jogadores abaixo do cap anterior, sem pular toda a jornada

### Curvas De Upgrade

- Arma/Spell: `max(10, round(0.2 × n²))` Almas — total ~5.200/item
- Pet: `max(5, round(0.15 × n²))` Sangue — total ~4.000
- Passiva: 40 levels, custo em Cristais calibravel no simulador economico

---

## Sistema Social

- Amigos: por username ou codigo de convite
- Guilda: level 1-10 (10-50 membros), 4 construcoes com bonus passivos
- Bonus de guilda: velocidade construcao, producao recursos, XP leve, armazenamento
- Chat: guilda + direct/friends no primeiro slice. Global: Discord externo.

---

## Matchmaking E Ranking

- Poder inicial: `(Level x 50) + (ArmaLevel x 30) + (SpellLevelsTotal x 20) + (PetLevel x 15) + (PassiveLevelsTotal x 10) + (WeaponQualityTier x 25)`.
- Componentes bloqueados por level contam como 0 ate o unlock.
- Poder e recalculado no servidor em toda mudanca autoritativa de build, upgrade ou level.
- Matchmaking tenta parear por diferenca maxima de poder, expandindo a tolerancia por tempo de busca.
- Faixas iniciais: ate 10% de diferenca nos primeiros 5s; ate 20% ate 15s; ate 35% depois disso; se nao houver jogador real, usar bot da faixa.
- Bots simulados cobrem faixas de poder com builds legais para o level correspondente.
- Ranking: pontos de arena por season (vitoria=+pontos, derrota=-pontos, variavel por diferenca de poder)

### Bots Iniciais

O primeiro slice precisa popular testes com bots gerados por faixas de poder. Cada bot deve ter:

- level, power, faixa de poder e archetype estavel;
- build legal para os unlocks do level;
- seed de variacao para dano/status sem criar build impossivel;
- flag `is_ranked = false`.

Archetypes iniciais sugeridos:

- `starter_wand`: level 1-2, varinha pura, sem spells.
- `cosmic_apprentice`: level 3-6, Raio Cosmico.
- `elemental_mixer`: level 7-14, duas spells elementais.
- `pet_handler`: level 15-24, duas spells + pet.
- `summoner`: level 25-40, tres spells com summon.
- `defensive_caster`: level 25-40, Fortificar + dano sustentado.

### UX/Layout Do Primeiro Slice

Primeira versao jogavel deve priorizar clareza operacional em vez de visual final. Layout base:

- `Refugio`: hub principal com personagem, poder, recursos, fila de construcao e acessos para Batalha, Base, Social e Loja.
- `Batalha`: preview de faixa de matchmaking, botao de iniciar, replay com velocidade/skip e resumo de dano/recompensa.
- `Base`: seis estruturas em grade, estado de upgrade/coleta, pedido de ajuda e custos claros.
- `Social`: abas Amigos, Guilda e Chat; polling simples no primeiro slice.
- `Loja/Passe`: Battle Pass, Diamante e recompensas, com compras reais substituidas por fluxo de teste no alpha.

---

## Referencias Completas

Para formulas detalhadas, tabelas de DoT, status effects, custos de guilda e todos os valores numericos:

**`../../_conceitos/mobile-universe/gdd.md`** — secoes 3 a 17
