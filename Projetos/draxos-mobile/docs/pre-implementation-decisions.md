# DraxosMobile — Decisoes Pre-Implementacao

- Ultima atualizacao: `2026-05-19`
- Referencia: analise de design realizada antes do Track 00
- Status geral: **Blocos 1–3 e B4.1 resolvidos. B4.2 registrado. Blocos 5–6 registrados. Design considerado fechado para Track 00.**

---

## Bloco 1 — Bloqueadores do Simulador de Batalha `RESOLVIDO`

Todas as decisoes necessarias para implementar o simulador de batalha no servidor.

| Decisao | Definido |
|---|---|
| Targeting da varinha (basico e especial) | Direto |
| Targeting do pet | Direto (tipos especificos no futuro) |
| Targeting dos summons | Direto (tipos especificos no futuro) |
| HP base dos summons (nivel 1) | Esqueleto 60 · Morto-Vivo 40 · Demonio 50 |
| Duracao dos summons | ~8s (ligeiramente menor que recast de 10s) |
| Custo de Mana — Invocar Demonio | 20 |
| Custo de Mana — Animar Morto | 20 |
| Recast — Invocar Demonio | Sempre substitui ao disparar |
| Recast — Animar Morto | Prioriza slot vazio; substitui so se ambos ocupados |
| Anti-stall targeting | AoE total — mago + todos os summons simultaneamente |

---

## Bloco 2 — Arquitetura de Progressao `RESOLVIDO`

Afetam estrutura do banco de dados e como o servidor salva o estado do jogador.

| Decisao | Definido |
|---|---|
| Levels das estruturas da base entre seasons | Permanentes — a base nunca reseta |
| Levels de passivas entre seasons | Permanentes — igual ao Level Global e Maestria |
| Logica de desbloqueio de spells e slots | Order de unlock por level minimo; sem restricao de slot apos desbloqueado |
| Local e custo de unlock de spells e slots | Altar das Almas — custo em Almas |
| Upgrades de cada construcao | Cada construcao abriga upgrades que consomem seu proprio recurso |
| Papel do Nucleo de Energia | Apenas producao — sem menu de upgrades de personagem alem do self-upgrade |

### Detalhes

**B2.1 — Levels das estruturas:** permanentes entre seasons. A base sempre cresce. O termo "40 levels por season" nos documentos anteriores era impreciso — refere-se ao teto de 40 levels, nao a um reset. `base_structures` nunca tem dados apagados por season.

**B2.2 — Passivas:** permanentes. A base nunca reseta (B2.1), portanto os Cristais continuam acessiveis entre seasons. `passiva_levels[]` nao faz parte de nenhum reset de season.

**B2.3 — Unlock de spells:** nao e restricao de slot, e ordem de desbloqueio por level minimo:
- Level 1–3: Slot 1 disponivel → 1 spell disponivel para unlock (Raio Cosmico)
- Level 10–15: Slot 2 disponivel → +4 spells disponiveis para unlock (Raio, Acender, Envenenar, Congelar)
- Level 20–25: Slot 3 disponivel → +5 spells disponiveis para unlock (Odio, Dilacerar, Fortificar, Invocar Demonio, Animar Morto)

Uma vez desbloqueada, cada spell pode ser equipada em qualquer slot disponivel. O unlock do slot e o unlock de cada spell custam Almas e sao feitos no Altar das Almas.

**Logica das construcoes:** toda construcao pode evoluir a si mesma ate level 40 (custo: Energia + tempo). Alem disso, cada construcao abriga upgrades especificos que consomem seu proprio recurso:
- Altar das Almas → unlock e upgrade de arma, slots de spell e spells
- Pocos de Sangue → upgrade de pets
- Minas de Cristal → upgrade de passivas
- Ossario → crafting de arma (qualidade via Ossos)
- Nucleo de Energia → sem menu adicional (Energia e gasta na evolucao das proprias construcoes)
- Estrutura de Stats → upgrade de stats do personagem

---

## Bloco 3 — Mecanicas com Comportamento Indefinido `RESOLVIDO`

Precisam de resposta antes do codigo para evitar retrabalho.

### B3.1 — Congelar com targeting Area `RESOLVIDO`

**Decisao:** contadores de Lento sao independentes por alvo.

| Regra | Comportamento |
|---|---|
| Stacking | 1 stack por cast em cada alvo atingido |
| Contador | Cada alvo tem seu proprio contador independente |
| Burst | Dispara individualmente quando o alvo chega a 3 stacks |
| Alvo do burst | Apenas o alvo que atingiu 3 stacks — nao se propaga |

---

### B3.2 — Ossos no primeiro slice `RESOLVIDO`

**Decisao:** Ossario e crafting da varinha ficam no primeiro slice.

| Item | Decisao |
|---|---|
| Fonte de Ossos | Drops de batalha + producao do Ossario + pequena quantidade em quests iniciais |
| Crafting da varinha | Apenas upgrade de dano — sem dimensoes adicionais por enquanto |
| Ossario no primeiro slice | Incluido |

---

## Bloco 4 — Valores Necessarios para o Alpha `PARCIAL`

Nao bloqueiam o Track 00 mas precisam existir antes do primeiro playtest.

### B4.1 — XP de construcoes da base `RESOLVIDO`

**Decisao:** XP de construcoes e quests e XP livre (sem cota). O valor e fixo de acordo com o tipo e level da construcao, ou com o tipo de quest.

- XP por level de construcao completada: fixo por tipo de estrutura e level (tabela a definir durante producao)
- XP de quests: fixo por quest, definido na quest em si
- Nao existe formula generica — cada entrada e configurada individualmente

**Pendencia:** definir os valores numericos reais durante producao do primeiro slice.

---

### B4.2 — Progressao esperada de Energia por perfil de jogador `REGISTRADO`

**Situacao:** gap de ~2× e intencional. Disponivel ~36.000 Energia/season (batalha + base), necessario ~75.000 para maxar 5 estruturas.

**Pendencia a documentar antes do playtest:**
- Jogador free hardcore (limite de conta, sem gasto): quais estruturas consegue maxar em uma season?
- Jogador com battle pass hardcore: consegue maxar todas? Em quanto tempo?
- Jogadores com diferentes niveis de gasto em Diamante: curva de progressao esperada
- Papel do Diamante no gap restante — quanto do gap ele deve cobrir por faixa de gasto?

Esses valores nao bloqueiam o Track 00 mas devem existir antes do primeiro playtest real.

---

## Bloco 5 — Calibravel no Alpha `REGISTRADO`

Importante, mas pode ser ajustado com dados reais do alpha.

- Formula de poder do matchmaking ajustada para summons
- Custo e bonus das construcoes de guilda
- Calibracao de valores absolutos do Diamante por acao (escala relativa ja definida)
- Lista completa de usos do Diamante na loja
- Conteudo exato das recompensas diarias e semanais (recursos, quantidades, limites)
- Conteudo do Battle Pass por tier
- Formula de pontos de arena (ganho/perda por diferenca de poder)
- Faixa de poder aceita para matchmaking (plusminus X)
- Sistema de onboarding e missoes
- Escala de HP e dano dos summons por level de spell
- Summons participam do sistema de maestria?
- Valores numericos de XP por construcao e por tipo de quest (B4.1)

---

## Bloco 6 — Design Incompleto `REGISTRADO`

Sistemas existentes com lacunas que precisam ser preenchidas antes ou durante o primeiro slice.

### Critico — bloqueia playtest

- Valores numericos de XP por tipo de construcao e por quest (sem isso o loop de progressao nao pode ser testado)
- Curva de progressao de Energia por perfil de jogador (free / battle pass / diferentes niveis de gasto) — metas explicitas antes do playtest
- Conteudo exato das recompensas diarias e semanais (recursos, quantidades, limites de cota)

### Design incompleto — nao bloqueia Track 00 mas precisa de resolucao

- **Estrutura de Stats:** nenhuma descricao de quais stats afeta, em quanto por level, nem custo de recurso — unico predio sem mecanica definida
- **Slot extra de fila de construcao:** "compra unica" confirmada mas sem preco nem detalhes do que muda apos a compra
- **Escala de summons por level de spell:** HP base e dano nivel 1 definidos, mas sem curva de crescimento por level
- **Maestria de spells sem dano:** Barreira definida (mitiga dano), demais spells de utilidade futura a definir caso a caso
- **Conteudo completo da loja de Diamante:** lista parcial, faltam todos os itens e valores absolutos
- **Guilda — construcoes e bonus:** nivel de guilda, custos, bonus passivos sem valores definidos
- **Cosmeticos:** categorias listadas mas sem conteudo definido
- **Ossario — taxa de producao de Ossos:** estrutura incluida no primeiro slice mas sem taxa de Ossos/hora por level definida (falta das tabelas 11.5 e 11.6 do GDD)
- **Desbloqueio do slot de passiva:** quando e como o jogador acessa o primeiro slot? (level especifico? construcao das Minas de Cristal? tutorial?)
- **Desbloqueio do slot de pet:** idem — "escolha livre desde o inicio" mas o gatilho de desbloqueio nao esta definido
- **Missoes diarias vs win bonus:** sistema definido apenas como "bonus pelas 3 primeiras vitorias do dia" — nao e um sistema de missoes variadas. Decidir: expandir para objetivos variados ou renomear para "bonus de vitorias diarias"
- **Schema da tabela builds — spells:** como registrar quais spells foram desbloqueadas vs quais estao equipadas e em qual slot. Ha multiplas abordagens (colunas separadas vs tabela propria de unlocks) com implicacoes de performance diferentes
- **Documento autoritativo:** quando game-design-document.md e gdd.md divergirem, qual prevalece para implementacao? (sugestao: game-design-document.md — mas requer decisao explicita do owner)

---

## Ordem Recomendada

Resolver nesta ordem antes de iniciar o Track 00:

1. ~~**B2.1**, **B2.2**, **B2.3**~~ — **RESOLVIDO**
2. ~~**B3.2**~~ — **RESOLVIDO**
3. ~~**B3.1**~~ — **RESOLVIDO**
4. **B4.1** e **B4.2** — antes do primeiro playtest
