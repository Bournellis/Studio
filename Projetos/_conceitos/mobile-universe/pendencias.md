# DraxosMobile — Pendencias De Design

- Ultima atualizacao: `2026-05-18`
- Status: `ARQUIVO_DESIGN` — promovido para `Projetos/draxos-mobile/` em 2026-05-18
- Objetivo: registro historico das decisoes de design tomadas durante a fase de conceito. Somente leitura.

---

## Ordem Recomendada

1. ~~P01 — Identidade do primeiro mago~~ **RESOLVIDO**
2. ~~P06 — Tema ficcional e mundo~~ **RESOLVIDO**
3. P02 — Numeros e formulas (stats, custos, curvas)
4. P03 — Amigos, guilda e ajudas sociais
5. P04 — Infraestrutura do produto mobile
6. P05 — Character Autobattler PVE
7. P07 — PVP Cardgame Roguelike
8. P08 — Hero Defense
9. P09 — Level Global e beneficios leves
10. P10 — Hierarquia Draxos
11. P11 — Open World RPG como horizonte futuro
12. P12 — Lancamento e empacotamento
13. P13 — Transicao de conceito para producao

---

## P01 — Identidade Do Primeiro Mago `RESOLVIDO`

**Decisoes tomadas:**
- Nome do personagem: definido pelo jogador
- Raca: Draxos
- Visual: silhueta vultuosa, manto comprido, etereo e energetico
- Estilo artistico: pendente de definicao pelo usuario
- Sem classes — todos os jogadores tem acesso a todas as armas, spells, passivas e pets
- Arma (primeiro slice): Varinha Magica — raios magicos, 4o ataque causa 3x dano, dano Magico
- Spells (primeiro slice): progressao 0 a 3 slots via level
  - Slot 1: desbloqueado muito cedo (level 1–3) — Raio Cosmico fixo
  - Slot 2: desbloqueado no final do early game (level 10–15) — escolha Choque/Fogo/Veneno/Gelo
  - Slot 3: desbloqueado no mid game (level 20–25) — escolha livre da pool completa
- Pool de spells: Raio Cosmico, Raio, Acender, Envenenar, Congelar, Odio, Dilacerar, Fortificar
- DoTs acumulam (stacking) — cada aplicacao tem duracao independente, sem substituicao
- Maestria de arma amplifica dano daquele tipo de arma; maestria de spell amplifica dano daquela spell
- Modificador de maestria atual: dano. Futuro: lifesteal, critico e outros
- Passivas (primeiro slice): 1 slot, escolha livre entre Forca, Resistencia, Escudo, Vampirismo, Velocidade
- Pets (primeiro slice): 1 slot, escolha livre entre os 7 tipos de dano

---

## P02 — Numeros E Formulas

**Prioridade:** Alta antes de prototipar

**Por que importa:** sem numeros nao ha como balancear combate, economia ou progressao.

**Decisoes ja tomadas:**
- Level afeta stats base diretamente
- Arma e upgrades afetam stats
- Vitoria: recompensa completa de Experiencia, Almas, Energia e Sangue
- Derrota: 1/5 de todos os recursos acima
- Anti-stall: mapa causa dano crescente apos certo tempo de batalha
- Sistema de stats completo definido (ver gdd.md secao 3.3)

**Resolvido (referencia inicial — revisao obrigatoria durante prototipagem):**
- Stats base nivel 1: Vida 100, Mana 20, Ataque 15, Defesa 4, Regen Vida 1/s, Regen Mana 2/s, Vel. Ataque 1/s, Aceleracao 0%
- Curva de crescimento por Level: ~20% ao nivel para Vida, Mana, Ataque e Defesa (ver gdd.md secao 8.3)
- Formula de reducao de dano: Stat / (Stat + 100) — aplica em camadas
- Custos de Mana das 8 spells definidos (ver gdd.md secao 8.6)
- Dano base das 8 spells no nivel 1 definido (ver gdd.md secao 8.6)
- DoTs: intervalo de 1 segundo, duracoes e danos definidos para Queimando/Envenenado/Sangrando
- Status effects: duracoes iniciais definidas para Lento/Congelado/Stun/Silenciado/Desarmado

**Resolvido adicionalmente:**
- Formula de level: XP_total(n) = 3 × (n³ - 6n² + 17n - 12) — curva cubica, progressao infinita
- XP base por batalha: 10 (normal), 20 (dobrada), 5 (reduzida)
- Cotas diarias de XP de batalha: 855 XP/dia, 2.565 acumulado (3 dias), 5.985 semanal
- Level 40 sem progressao paga: ~6.4 meses de batalha regular
- XP livre (base, missoes, onboarding) sem limite — acelera especialmente o early game
- Sistema de cotas de XP de gameplay (XP Dobrada/Normal/Reduzida, acumulo de 3 dias, reset semanal)
- Recursos de batalha seguem faixa de XP como referencia — sem contador separado
- Battle Pass: tier Free e Premium definidos estruturalmente
- Sistema de recompensas diarias/semanais com anuncios removiveis por compra unica
- Moeda premium: Diamante — custo baixo para construcoes, alto para pular progressao de poder

**Resolvido adicionalmente:**
- Arma: tres dimensoes — Tipo (comportamento), Qualidade (Ossos, craft), Level (Almas, 40/season)
- Maestria de arma e spell: acumula por dano causado, amplificacao passiva crescente, permanente na conta, dificuldade crescente (modelo Tibia skills)
- Spell: 40 levels por season, maestria identica a arma
- Passiva: desbloqueada e upada pela base, 10 levels, recurso Cristais
- Pet: 40 levels por season, recurso Sangue
- Ossos: nome simplificado do sistema de crafting — na pratica variedade de materiais; usado para qualidades de arma e itens futuros
- Futuro documentado: levels especiais, arvore de upgrades, tipos de arma adicionais

**Resolvido adicionalmente:**
- Recursos por batalha: Almas 3/base, Sangue 1/base, Energia 2/base — seguem faixa de XP
- Producao diaria estimada: Almas ~307/dia, Sangue ~106/dia, Energia ~201/dia
- Curva de upgrade arma/spell: custo(n) = max(10, round(0.2×n²)), total ~5.200 Almas
- Curva de upgrade pet: custo(n) = max(5, round(0.15×n²)), total ~4.000 Sangue
- Curva de upgrade passiva: 10 levels, total ~1.000 Cristais
- Tempo de progressao referenciado: pet ~1.3 meses, arma+spells ~2.2 meses, personagem level 40 ~6.4 meses

**Resolvido adicionalmente (Bloco 4 — Base):**
- Fila de construcao: 1 slot padrao, 2 com compra unica
- 40 levels por estrutura, limitados pelo level da conta
- Curva de duracao por level: 2 min (level 1) ate 160 horas (level 40)
- Custo de Energia por level: custo(n) = max(20, round(0.5×n²)), total ~15.000 por estrutura
- Taxas de producao nivel 1/20/40 para todas as estruturas definidas
- Limites de armazenamento nivel 1/20/40 para todas as estruturas definidos
- Nota: todos os valores serao revisados apos definicao de quests e recompensas

**Resolvido adicionalmente (Bloco 5 — Finalizacao P02):**
- DoTs de Choque (Chocado): 5 ticks, duracao 5s, 5 dano/tick, 25 total — referencia inicial
- DoTs de Morte (Apodrecendo): 6 ticks, duracao 6s, 6 dano/tick, 36 total — referencia inicial
- Anti-stall: ativa em 30s, ramp 10%→20%→40% do HP max/s nos momentos 30s/32s/34s; letal a partir de 36s; ignora resistencias
- Formula de poder para matchmaking: Poder = (Level × 50) + (Nivel_Arma × 30) + (Nivel_Spell × 20, soma todas) + (Nivel_Pet × 15) + (Nivel_Passiva × 10, soma todas) + (Qualidade_Arma × 25)
- Sistema de recompensas: 8 fontes com pesos relativos definidos (ver gdd.md secao 13); cota de batalha e compartilhada entre todos os modos; base e coleta de dados escalados conforme novas expansoes
- Coleta de dados: sistema de 3 camadas (combate, progressao, retencao/monetizacao) definido para orientar ajustes futuros

**Resolvido adicionalmente (Revisao P01/P02):**
- Stacking de DoT: acumula — cada instancia tem duracao independente, sem substituicao
- Maestria de arma: amplifica dano daquele tipo de arma (nao global); Maestria de spell: amplifica dano daquela spell. Modificador atual: dano. Futuro: lifesteal, critico e outros
- Desbloqueio de slots de spell por level: Slot 1 (level 1–3), Slot 2 (level 10–15), Slot 3 (level 20–25)
- Regen de Vida e Regen de Mana crescem por level + outras fontes (base, passivas, equipamentos)
- Season: 4 meses de duracao, 2 Battle Passes por season (um por bimestre)

**Pendencias restantes de P02:**
- Drops de Ossos: fontes e quantidades
- Curva de crescimento de Regen de Vida e Regen de Mana por level
- Revisao geral de valores numericos apos sistema de quests

**Pendencias de outros blocos:**
- Sistema de missoes e onboarding — pendencia separada (P novo)
- Detalhes do sistema de ajuda social (P03)
- Valor do Diamante calibrado por categoria de uso
- Conteudo do pacote de remocao de anuncios

**Resolvido quando:** existir uma planilha ou documento com valores suficientes para rodar uma simulacao basica de combate e progressao.

---

## P03 — Amigos, Guilda E Ajudas Sociais

**Prioridade:** Alta

**Por que importa:** amigos e guilda fazem parte do primeiro slice.

**Decisoes tomadas:**
- Adicionar amigo: por username ou codigo de convite
- Ajuda em construcao: 1,5% de reducao por ajuda, maximo 10 ajudas = 15% de reducao total
- Guilda tem level proprio (gate de membros E de bonus) e construcoes coletivas
- Escala de membros: level 1 = 10, crescendo ate level 10 = 50 (~+4/level)
- 4 construcoes de guilda com bonus passivos: velocidade de construcao, producao de recursos, XP de gameplay (leve), limite de armazenamento
- Jogadores contribuem recursos pessoais para evoluir level da guilda e cada construcao
- Chat de guilda e mensagens diretas (friends/direct) incluidos no primeiro slice
- Chat global: fora do primeiro slice — comunidade via Discord externo
- Builds inimigas simuladas (bots) enquanto nao ha jogadores reais suficientes
- Servidor privado tratado como produto real desde o alpha: VPS com SSL, convite por codigo, persistencia cloud
- Tester de segurança envolvido desde o alpha

**Pendencias restantes de P03:**
- Limite diario de ajudas que um jogador pode dar (evitar que guilds grandes zerem todos os tempos)
- Definir quais recursos sao aceitos como contribuicao de guilda (Almas, Energia, Sangue, proporcoes)
- Valores dos bonus passivos por level de construcao de guilda (calcular junto com revisao de economia)
- Custo de contribuicao para level de guilda e para cada construcao (calcular junto com revisao de economia)
- Definir se guilda participa de ranking ou objetivos coletivos (fora do primeiro slice por ora)

**Resolvido quando:** houver valores definidos para contribuicoes, custos e bonus de guilda integrados na economia geral.

---

## P04 — Infraestrutura Do Produto Mobile

**Prioridade:** Alta antes de implementar

**Por que importa:** o primeiro slice sera produto mobile com infraestrutura seria, nao um prototipo isolado.

**Decisoes tomadas:**
- Engine: Godot 4.x
- Plataformas: Android (app nativo) + PC executavel + PC browser (Godot web export) no primeiro slice. iOS futuro.
- Mobile browser: fora do escopo — mobile usa somente app nativo.
- Backend: Supabase (Auth, Postgres, Edge Functions, Realtime, Storage)
- Conta: guest automatico no primeiro boot + username/senha + Google Sign-In; migracao guest → registrada sem perda de progresso
- Alpha: acesso por codigo de convite; APK sideload + executavel PC; sem Play Store
- Dados autoritativos no servidor: recursos, level, build, resultados de batalha, guilda, ranking
- Batalha 100% simulada no servidor — cliente recebe log de eventos e anima
- Desconexao durante batalha: resultado ja registrado no servidor, cliente busca log na reconexao
- Matchmaking: servidor seleciona oponente por faixa de poder; pool misto (reais + bots simulados)
- Builds simuladas: contas-fantasma por faixa de poder para popular o matchmaking antes de ter jogadores
- Ranking no primeiro slice: pontos de arena (vitoria = +pontos, derrota = -pontos, variavel por diferenca de poder)
- Politica offline: base calcula producao no servidor na reconexao; batalha requer conexao; estado cacheado exibido offline
- Anti-cheat basico: batalha servidor-only, Edge Functions validam toda mutacao de recursos, RLS do Supabase isola dados por jogador, rate limiting em batalha
- Tester de seguranca envolvido desde o alpha (ver Secao 16.5.3 do gdd.md)
- Telemetria: via sistema de coleta de dados definido na Secao 14 do gdd.md

**Pendencias restantes de P04:**
- Formula de pontos de arena para ranking (ganho/perda por diferenca de poder) — calibrar durante prototipagem
- Faixa de poder aceita para matchmaking (±X) — calibrar com dados reais
- Politica de retencao e delecao de mensagens de chat (LGPD/GDPR) — antes do lancamento publico
- Estrategia de monetizacao para o canal PC browser — pagamentos web sao diferentes da Play Store
- Conta Apple Developer e processo de build iOS — quando iOS entrar no roadmap

**Resolvido quando:** houver uma lista de servicos obrigatorios para o primeiro slice e o que fica fora dele.

---

## P05 — Character Autobattler PVE

**Prioridade:** Media

**Decisoes ja tomadas:**
- Batalha automatica com botao de ultimate e 1 a 3 botoes de spell acionaveis
- Primeiro arco: ascensao hierarquica, rebeliao contra mestre supremo, aventura solo
- Conexao alta com Base Manager
- A evolucao da base acompanha a narrativa (santuario > quartel > nave > planeta)

**Pendencias:**
- Decidir formato: campanha linear, mapa de missoes ou outro
- Decidir se usa o mesmo sistema do PVP ou variante
- Definir quais recompensas gera para a base
- Definir quando o PVE passa a ser upado junto com a base

---

## P06 — Tema Ficcional E Mundo `RESOLVIDO`

**Decisoes tomadas:**
- Nome do jogo: DraxosMobile
- Nome da raca: Draxos
- Base (primeiro slice): Altar/Santuario pessoal — sombrio, organico, cheio de artefatos e energia
- Evolucao da base: santuario > quartel > nave > nave/planeta autonomo
- Por que batalham: ambicao e recursos — duelos sao a forma legitima de disputar poder e posicao
- Hierarquia Draxos: pendente (P10), fora do primeiro slice

---

## P07 — PVP Cardgame Roguelike

**Prioridade:** Media

**Decisoes ja tomadas:**
- PVP cardgame roguelike com progressao propria
- Recebe apenas pequenos beneficios de Level Global e base bem evoluida

**Pendencias:**
- Definir formato competitivo
- Definir o que significa a run roguelike
- Definir progressao propria do modo
- Definir quais pequenos beneficios recebe da conta/base

---

## P08 — Hero Defense

**Prioridade:** Media

**Decisoes ja tomadas:**
- Mesmo personagem, tower defense/hordas
- Dois sistemas de upgrade: tokens de monstros e buff de escolha por wave
- Progressao propria, beneficios leves de Level Global e base

**Pendencias:**
- Definir se o mago fica parado, se move, ou se protege uma posicao
- Definir tipos de hordas
- Definir progressao propria detalhada
- Definir quais beneficios recebe da conta/base

---

## P09 — Level Global E Beneficios Leves

**Prioridade:** Bloqueada — resolver junto com cada modo

**Decisoes ja tomadas:**
- Todos os modos contribuem para Level Global via Experiencia
- Level afeta stats base diretamente — curva definida em P02 (ver gdd.md secao 8.3)
- Modos com progressao propria (Cardgame Roguelike, Hero Defense, Open World) recebem apenas beneficios leves de Level Global
- O beneficio leve de cada modo sera definido quando aquele modo for detalhado em P05/P07/P08

**Pendencias — bloqueadas por outros pendencias:**
- Beneficios leves do Cardgame Roguelike — pendente de P07
- Beneficios leves do Hero Defense — pendente de P08
- Beneficios leves do Character Autobattler PVE — pendente de P05
- Apresentacao visual do Level Global ao jogador — pendente de definicao de UX geral

---

## P10 — Hierarquia Draxos

**Prioridade:** Baixa — fora do primeiro slice

**Pendencias:**
- Definir nomes dos postos da hierarquia Draxos (sem termos militares humanos)
- Definir quantos postos existem no primeiro arco narrativo
- Definir quando esse assunto volta para o roadmap

---

## P11 — Open World RPG Como Horizonte Futuro

**Prioridade:** Baixa

**Pendencias:**
- Definir o minimo que precisa ser preservado para nao bloquear Open World futuro
- Definir quais sistemas do Autobattler ou PVE podem ser reaproveitados
- Definir se personagem, criaturas e itens precisam de taxonomia comum

---

## P12 — Lancamento E Empacotamento

**Prioridade:** Baixa agora

**Decisoes ja tomadas:**
- Ainda nao ha decisao de lancamento, temporada, expansoes ou apps separados

**Pendencias:**
- Definir se sera um unico app com modos adicionados por updates
- Definir como um jogador novo entende o produto se entrar depois de varios modos
- Definir como comunicar que a progressao e compartilhada

---

## P13 — Transicao De Conceito Para Producao `RESOLVIDO`

**Decisoes tomadas:**
- Criterio de transicao: P01, P02, P03, P04 resolvidos com valores suficientes para prototipagem do primeiro slice — criterio atingido em 2026-05-18
- Tecnologia: Godot 4.x
- Backend: Supabase
- Repositorio oficial: `Projetos/draxos-mobile/` (promovido em 2026-05-18)
- `AGENTS.md` criado em `Projetos/draxos-mobile/AGENTS.md`
- `implementation/current-status.md` criado em `Projetos/draxos-mobile/implementation/current-status.md`
- `Estado_Atual.md`, `Projetos/README.md` atualizados
- Este arquivo (`_conceitos/mobile-universe/`) preservado como arquivo de design

**Status:** projeto promovido. Trabalho de implementacao em `Projetos/draxos-mobile/`.
