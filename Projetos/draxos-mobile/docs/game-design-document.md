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

### Stats v0 - Primeiro Slice

Para o simulador real do primeiro slice, os stats usam uma curva linear e calibravel por level global. Bonus externos entram como multiplicadores depois da curva base.

Formulas:

- `vida_base = round(100 + 8 * (level - 1))`
- `multiplicador_pacing_alpha = 4.85 + 0.121 * (level - 1)`
- `vida_max = round(vida_base * multiplicador_pacing_alpha)`
- `mana_max = round(20 + 1.5 * (level - 1))`
- `regen_vida = 1.0 + 0.08 * (level - 1)` por segundo
- `regen_mana = 2.0 + 0.05 * (level - 1)` por segundo

Tuning alpha 2026-05-21: o multiplicador de pacing acima foi introduzido apos o
Battle Lab mostrar batalhas medias de `3.22s`. O objetivo nao e fechar
balanceamento final, mas alinhar a duracao media do replay com a janela
operacional `18s-28s` antes de mexer em dano, cooldowns, pet, DoT ou passivas.
Apos o ajuste, o baseline offline ficou em `18.19s` de duracao media, `2.38%`
de batalhas curtas e `0.12%` de anti-stall.

Fontes externas v0:

- Estrutura de Stats aplica bonus percentual em Vida, Ataque/dano base, Defesa, Mana e regen de mana.
- Passivas adicionam modificadores no simulador `FIRST_SLICE_SIM`: mana regen, dano, reducao de dano, barreira inicial, vampirismo e reducao de cooldown.
- Buffs temporarios de batalha, como Fortificar, entram apenas durante a simulacao da batalha.
- Equipamentos alem da Varinha nao entram no primeiro slice.

### Tipos De Dano

7 tipos: Magico, Fogo, Gelo, Veneno, Choque, Morte, Sangramento.
DoTs, resistencias, barreiras e status effects: ver GDD secao 3.4–3.8.

**Regra de stacking de DoT implementada em T00-P10:** reaplicar o mesmo DoT pelo mesmo lado aumenta stacks ate 5 e renova a duracao; cada stack aumenta o tick.

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

### Qualidades Da Varinha v0

A Varinha tem 5 qualidades no primeiro slice. Qualidade e permanente, custa Ossos, nao tem RNG e deve ser craftada em ordem no Ossario. O custo total ate a qualidade maxima da Season 1 e `30 * cap`, ou 1200 Ossos no cap 40.

| Qualidade | Tier | Custo incremental | Custo acumulado | Multiplicador de dano |
|---|---:|---:|---:|---:|
| Inicial | 0 | 0 | 0 | 1.00x |
| Reforcada | 1 | 120 | 120 | 1.08x |
| Ritual | 2 | 240 | 360 | 1.18x |
| Abissal | 3 | 360 | 720 | 1.30x |
| Cosmica | 4 | 480 | 1200 | 1.45x |

Regras:

- Qualidade de Varinha entra no calculo de poder como `WeaponQualityTier x 25`.
- Qualidade melhora apenas dano da Varinha; nao desbloqueia spell, pet ou passiva.
- Qualidade nao e vendida como conteudo premium exclusivo.

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

### Summons E Maestria v0

Summons escalam pelo level da spell invocadora, limitado pelo cap atual e pelo level do personagem.

Formula de escala:

- `summon_hp = round(base_hp * (1 + 0.10 * (spell_level - 1)))`
- `summon_dps = base_dps * (1 + 0.08 * (spell_level - 1))`
- Duracao base: 8s.
- Recast base da spell: 10s.
- Mana base: 20.

Valores base:

| Summon | HP base | DPS base | Tipo de dano |
|---|---:|---:|---|
| Esqueleto | 60 | 6 | Morte |
| Morto-Vivo | 40 | 5 | Morte |
| Demonio | 50 | 7 | Fogo |

Maestria:

- Dano causado por summon conta 100% para a maestria da spell invocadora.
- Kills feitas por summon sao creditadas a spell invocadora.
- Dano de summon tambem entra na telemetria de dano por tipo.
- Summon nao gera maestria de Varinha nem de pet.
- Maestria e permanente e nunca reseta por season.

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

### Base v0 - Producao, Storage E Fila

A Base v0 e server-authoritative. O cliente envia intencoes e exibe estado; inicio/conclusao de construcao, coleta offline e gasto de recursos sempre passam por Edge Functions com `request_id` idempotente e ledger em `resource_transactions`.

Producao diaria no level 40:

| Estrutura | Producao diaria level 40 |
|---|---:|
| Altar das Almas | 10 Almas |
| Nucleo de Energia | 80 Energia |
| Pocos de Sangue | 8 Sangue |
| Minas de Cristal | 5 Cristais |
| Ossario | 2 Ossos |
| Estrutura de Stats | Nao produz recurso |

Regra de producao por level:

- Estruturas produtoras usam `max(1, round(producao_level_40 * level / 40))` por dia.
- Estruturas level 0 ou ainda nao construidas produzem 0.
- Producao offline acumula continuamente ate o limite de armazenamento.
- Storage por recurso da estrutura: `max(8, ceil(producao_diaria_atual * 2))`.
- Coleta calcula o valor no servidor a partir de `last_collected_at`, respeita storage e grava ledger.

### Estrutura de Stats

A Estrutura de Stats nao produz recurso. Ela abriga um pacote unico de melhoria permanente por level, limitado pelo level do personagem e custando Energia + tempo como as demais estruturas.

Bonus acumulado por level da Estrutura de Stats:

| Stat | Bonus por level | Bonus level 40 |
|---|---:|---:|
| Vida maxima | +0.8% | +32% |
| Ataque / dano base | +0.5% | +20% |
| Defesa | +0.4% | +16% |
| Mana e regen de mana | +0.3% | +12% |

Esses bonus devem entrar no calculo server-side de combate e poder, mas nao substituem progresso de arma, spells, pet ou passiva.

### Ossario

Ossos continuam raros. Batalhas, quests e Battle Pass seguem como fontes principais; o Ossario fornece renda constante para crafting de qualidade da Varinha. A meta inicial da Season 1 continua `30 * cap` Ossos para qualidade principal da Varinha.

### Segundo Slot De Construcao

- O jogador comeca com 1 slot de construcao.
- O segundo slot e uma compra unica e permanente da conta.
- Preco inicial: 500 Diamantes.
- No alpha, o segundo slot pode ser liberado por test flag ou compra simulada.
- O segundo slot permite duas construcoes simultaneas, mas nao permite dois jobs simultaneos da mesma estrutura.
- O segundo slot nao reduz custo, tempo ou requisito de level.
- Cada construcao tem ajuda social propria.

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

### Missoes E Onboarding v0

O primeiro slice usa missoes fixas e previsiveis. Missoes diarias variadas ficam adiadas para pos-alpha; a prioridade do alpha e clareza de rotina, balanceamento simples e implementacao server-authoritative.

Missoes diarias fixas:

| Missao | Regra | Recompensa |
|---|---|---|
| Primeira vitoria do dia | vencer 1 batalha PvP assincrona | XP + recursos calibraveis |
| Segunda vitoria do dia | vencer 2 batalhas PvP assincronas no dia | XP + recursos calibraveis |
| Terceira vitoria do dia | vencer 3 batalhas PvP assincronas no dia | XP + recursos calibraveis |
| Coletar base | coletar qualquer producao da base 1 vez no dia | recursos calibraveis |
| Construir ou evoluir | iniciar ou concluir 1 construcao no dia | XP + Energia calibraveis |

Missoes semanais fixas:

| Missao | Regra | Recompensa |
|---|---|---|
| Participacao de arena | jogar X batalhas na semana | XP + recursos calibraveis |
| Dominio de arena | vencer X batalhas na semana | XP + Almas calibraveis |
| Rotina do refugio | coletar base em 5 dias diferentes da semana | Energia + recursos calibraveis |

Regras:

- Recompensas numericas usam o simulador de economia antes de virar contrato final.
- Missoes sao calculadas no servidor e reivindicadas com `request_id` idempotente.
- Missao diaria reseta por dia de servidor; missao semanal reseta por semana de servidor.
- O bonus das 3 primeiras vitorias do dia e a espinha dorsal da rotina diaria.
- Randomizacao, reroll e missoes tematicas ficam fora do primeiro alpha.

Onboarding da primeira sessao:

| Passo | Objetivo |
|---|---|
| 1 | Criar conta guest e entrar no Refugio |
| 2 | Mostrar recursos, poder e fila de construcao |
| 3 | Coletar producao inicial da base |
| 4 | Iniciar upgrade do Nucleo de Energia |
| 5 | Fazer a primeira batalha |
| 6 | Ver replay, skip e recompensa |
| 7 | Voltar ao Refugio e abrir a Base |
| 8 | Apresentar missoes diarias e bonus das primeiras vitorias |
| 9 | Apresentar Loja/Passe como fluxo alpha/teste apos a primeira batalha |
| 10 | Explicar o primeiro unlock de spell ao chegar no level 3 |

Desbloqueios de telas e sistemas:

| Tela/Sistema | Desbloqueio |
|---|---|
| Refugio | imediato |
| Batalha | imediato |
| Base | apos primeira coleta/tutorial |
| Missoes | apos primeira batalha |
| Loja/Passe | apos primeira batalha |
| Social/Amigos | level 5 |
| Guilda/Chat | level 10 |
| Pet | level 15 |
| Conteudo avancado/summons | level 25 |

### Monetizacao E Recompensas v0

O primeiro slice usa monetizacao funcional de alpha. Compras reais podem ser simuladas no alpha, mas as regras de preco, limite e recompensa ja devem seguir o contrato v0.

Regras gerais:

- Premium vende tempo, conforto, amplitude e previsibilidade.
- Premium nao vende spell, pet, passiva, varinha exclusiva, poder acima do cap ou bypass permanente de matchmaking.
- Todas as recompensas com efeito economico sao server-authoritative, idempotentes por `request_id` e registradas em `resource_transactions`.
- Battle Pass, ranking/eventos de arena, missoes sazonais e ofertas temporarias resetam por season.

Battle Pass:

- Season 1 tem 2 Battle Passes de 60 dias.
- Cada passe tem 30 tiers.
- Cada tier pode ter recompensa Free e recompensa Premium.
- Premium adiciona recursos, cosmeticos e conveniencia; a trilha Free continua suficiente para progredir ate o cap dentro da meta do simulador.

Diamante:

| Uso | Preco v0 |
|---|---:|
| Segundo slot de construcao | 500 |
| Acelerar construcao | 1 por 10 min restantes |
| Pacote pequeno de Energia | 80 |
| Pacote pequeno de recursos mistos | 120 |
| Cosmetico simples | 150-300 |
| Cosmetico premium | 500-800 |

Cosmeticos do primeiro slice:

- Moldura de perfil.
- Titulo.
- Banner do Refugio.
- Skin visual da Varinha.
- Badge de chat.

Rewarded ads:

- Alpha nao usa anuncios reais.
- Beta pode ativar rewarded ads opcionais, com limite de 3 por dia.
- Nao ha anuncio forcado.
- Nao ha pacote de remover anuncios no alpha.
- Rewarded ads podem conceder apenas Energia leve, bau leve de recurso comum ou pequena aceleracao.

Conquistas:

- Marcos unicos e permanentes.
- Recompensas: titulos, molduras, pequenos Diamantes e recursos leves.
- Marcos v0: primeira batalha, primeira vitoria, 10/50/100 vitorias, levels 3/7/10/15/25/40, primeira construcao, primeira estrutura level 10, entrar em guilda e enviar primeira ajuda.

Valores numericos detalhados de recompensas diarias, semanais e Battle Pass vivem em `docs/economy/README.md` e continuam `CALIBRAVEL_ALPHA` ate o playtest.

## Sistema Social

- Amigos: por username ou codigo de convite
- Guilda: level 1-10 (10-50 membros), 4 construcoes com bonus passivos
- Bonus de guilda: velocidade construcao, producao recursos, XP leve, armazenamento
- Chat: guilda + direct/friends no primeiro slice. Global: Discord externo.

### Social, Guilda E Ajudas v0

O primeiro slice usa um social funcional e leve. Guilda deve aumentar rotina e cooperacao, mas nao pode virar obrigatoria para competitividade.

Regras de guilda:

- Guilda desbloqueia no level 10.
- Guilda tem level 1-10.
- Capacidade de membros: 10 no level 1, +5 membros por level de guilda, max 50.
- Criacao de guilda no alpha usa fluxo de teste sem pagamento real.
- Jogador pode participar de 1 guilda por vez.
- Sair de guilda aplica cooldown de 24h antes de entrar em outra.

Construcoes de guilda:

Na Season 1, cada bonus de guilda chega a **ate 5%** quando a guilda e a construcao correspondente estiverem maximizadas. Seasons futuras podem aumentar o teto do bonus pelo plano economico.

| Construcao | Bonus | Bonus level 1 | Bonus level 10 na S1 |
|---|---|---:|---:|
| Oficina Ritual | Velocidade de construcao pessoal | 0,5% | 5% |
| Condensador Astral | Producao de recursos da base | 0,5% | 5% |
| Arquivo De Dominio | XP de missoes e batalha | 0,5% | 5% |
| Cofre Abissal | Armazenamento offline da base | 0,5% | 5% |

Contribuicoes:

- Contribuicoes usam Energia, Almas, Sangue, Cristais e Ossos.
- Cada jogador tem limite diario de contribuicao por guilda.
- Cada recurso contribui para pontos de guilda conforme valor economico calibravel.
- Diamante nao entra como contribuicao obrigatoria de guilda.
- Contribuicoes geram progresso de construcao de guilda e ledger server-side.
- Bonus de guilda so considera construcoes concluidas no servidor.

Ajudas:

- Cada construcao pessoal pode pedir ajuda.
- Cada ajuda reduz 1,5% do tempo restante.
- Cada construcao pode receber ate 10 ajudas, max 15% de reducao.
- Jogador pode enviar ate 30 ajudas por dia.
- Jogador pode receber ate 10 ajudas por construcao.
- Enviar ajuda concede progresso social leve ou conquista, mas nao concede recurso direto no v0.
- Ajuda e idempotente por par `helper_id + construction_job_id`.

---

## Matchmaking E Ranking

- Poder inicial: `(Level x 50) + (ArmaLevel x 30) + (SpellLevelsTotal x 20) + (PetLevel x 15) + (PassiveLevelsTotal x 10) + (WeaponQualityTier x 25)`.
- Componentes bloqueados por level contam como 0 ate o unlock.
- Poder e recalculado no servidor em toda mudanca autoritativa de build, upgrade ou level.
- Matchmaking tenta parear por diferenca maxima de poder, expandindo a tolerancia por tempo de busca.
- Faixas iniciais: ate 10% de diferenca nos primeiros 5s; ate 20% ate 15s; ate 35% depois disso; se nao houver jogador real, usar bot da faixa.
- Bots simulados cobrem faixas de poder com builds legais para o level correspondente.
- Ranking: pontos de arena por season (vitoria=+pontos, derrota=-pontos, variavel por diferenca de poder)

### Ranking v0

Ranking usa pontos de arena por season. Bots nao entram no ranking e nao concedem/retiram pontos como participante ranqueado.

Formula v0:

- Vitoria base: `+20` pontos.
- Derrota base: `-10` pontos.
- Empate ou erro de simulacao: `0` pontos e batalha marcada para auditoria.
- Contra oponente mais forte: bonus de vitoria ate `+10`, proporcional a diferenca de poder, limitado a 35%.
- Contra oponente mais fraco: reducao de vitoria ate `-8`, proporcional a diferenca de poder, limitado a 35%.
- Derrota contra oponente mais forte: perda reduzida ate `-5`.
- Derrota contra oponente mais fraco: perda aumentada ate `-15`.
- Pontos nunca ficam abaixo de 0.
- Ranking reseta por season e gera snapshot ao encerrar.
- Match contra bot pode conceder recompensa economica normal, mas nao deve conceder pontos de ranking no alpha.

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
