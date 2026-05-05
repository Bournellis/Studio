# Open Gaps

- Last Updated: `2026-05-04`
- Purpose: rastrear lacunas de design e implementação que estão fora do escopo atual mas precisam ser resolvidas antes do jogo estar completo.

Cada gap tem um status: `aberto` (não iniciado), `em design` (sendo pensado), `especificado` (pronto para implementar), `implementado`.

Gaps marcados com ⚠️ têm inconsistências ativas em arquivos existentes.

---

## Categoria: Narrativa e Mundo

### G-N1 — Premissa e setting do jogo
**Status:** `aberto`
O projeto é "fantasia genérica". Não há setting nomeado, não há civilizações, conflitos, ou razão para o jogador estar no mapa. A premissa do herói "Aprendiz do Limiar" sugere algo mas não tem definição.
**Precisa:** nome do mundo, premissa de conflito, motivação do jogador, tom narrativo.

### G-N2 — Identidade do herói
**Status:** `aberto`
"Aprendiz do Limiar" tem nome mas zero desenvolvimento. Não há backstory, visual, personalidade, ou arco. O player não tem razão para se importar com ele.
**Precisa:** backstory curto, traço de personalidade, motivação inicial, conexão com o conflict central.

### G-N3 — NPCs com profundidade
**Status:** `aberto`
O único NPC é "a viajante" com duas linhas de diálogo funcional ("aqui está sua carta", "já pode ir"). Não tem nome, razão para estar ali, ou consequência na narrativa.
**Precisa:** nome, motivação, pelo menos 3-4 linhas de diálogo com variações por progresso.

### G-N4 — Estrutura de campanha e mapa
**Status:** `aberto`
O mapa atual tem 1 NPC e 1 encontro. O jogo tem 4 encontros definidos mas nenhuma estrutura narrativa os conectando. Não há noção de "onde estamos", "para onde vamos", ou "por que".
**Precisa:** layout de mapa com zonas, ordem de desbloqueio de encontros, transições com contexto narrativo.

### G-N5 — Título do jogo
**Status:** `aberto`
"RPG Turnos" é codename de desenvolvedor. O jogo não tem título, tagline, nem identidade de marca.
**Precisa:** título definitivo, tagline curta, logo (coordenar com asset-request.md `ui_logo`).

---

## Categoria: Progressão RPG

### G-R1 — Sistema de stats do herói
**Status:** `aberto`
O herói tem HP e um poder de herói. Não há stats, atributos, ou valores que cresçam.
**Precisa:** definição do que muda no herói à medida que o jogo avança (mesmo que seja apenas HP máximo e número de poderes).

### G-R2 — Sistema de progressão (XP/nível)
**Status:** `aberto`
O project-brief lista "level, stats, items, and progression" como pilares — nenhum foi projetado.
**Precisa:** decidir se há níveis, o que desbloqueia em cada nível, e como XP é obtido.

### G-R3 — Equipamento e itens
**Status:** `aberto`
O brief menciona "items" como pilar. Nenhuma decisão foi tomada sobre o que seriam itens no contexto do cardgame — afetariam HP, energia, poderes de herói, ou slots do deck?
**Precisa:** escopo mínimo de como itens/equipamento se encaixam no sistema de combate.

### G-R4 — Deck como progressão RPG
**Status:** `aberto`
O brief diz "The deck evolves with RPG progression". Atualmente o deck só cresce com as recompensas do slice. Não há conceito de carta rara, craft, compra, ou escolhas significativas de deckbuilding em escala de campanha.
**Precisa:** modelo de aquisição de cartas além das recompensas fixas do slice.

---

## Categoria: Sistemas Técnicos

### G-T1 — Save e load
**Status:** `aberto`
Não existe. O snapshot pré-combate está em memória e é perdido ao fechar o jogo. Qualquer progressão de campanha precisa de persistência.
**Precisa:** definição do que persiste (cartas desbloqueadas, encontros completos, estado do mapa, HP do herói entre encontros), escolha de formato (JSON local, Godot save files).

### G-T2 — Áudio (categoria completa)
**Status:** `aberto`
Zero trabalho de som. Nenhuma decisão sobre música, SFX, ou ferramentas.
**Precisa:** pelo menos: definição de mood de música por contexto (exploração, combate, vitória), lista de SFX essenciais (carta jogada, ataque, dano, morte), decisão de ferramenta (FMOD, Godot AudioStreamPlayer nativo, etc.).

### G-T3 — Transição entre cenas
**Status:** `aberto`
`get_tree().change_scene_to_file()` sem transição visual. Trocas abruptas entre mapa, deck setup, batalha e resultado.
**Precisa:** pelo menos fade in/out. Idealmente animação de transição contextual por destino.

---

## Categoria: Balanceamento

### G-B1 — Framework de balanceamento de cartas
**Status:** `aberto`
As 30 cartas têm stats que parecem razoáveis mas nunca foram testados. Não há critério de avaliação (ex: "criatura de 1 custo deve ter ATK+HP entre 3 e 5"), não há baseline de referência, não há dados de playtest.
**Precisa:** pelo menos uma sessão de playtest do deck inicial contra emboscada_na_ponte com registro do resultado.

### G-B2 — Carta `manter_linha` não catalogada no GDD
**Status:** ⚠️ `inconsistência ativa`
`manter_linha` (comando, custo 1, instantânea, +0/+2 HP em aliado) existe no `slice_catalog.json` mas não aparece em nenhuma tabela do GDD. Não está no deck inicial nem nas recompensas documentadas.
**Precisa:** decidir se é reward card (qual fonte?), enemy-only, ou removida. Atualizar GDD e catálogo conforme decisão.

### G-B3 — Contagem de cartas no GDD
**Status:** ⚠️ `inconsistência ativa`
GDD Section 7 diz "30 cards total: 20 in the starter deck and 11 obtainable through progression". Mas 20 + 11 = 31. E como 2 rewards aparecem em duas fontes (mesmo card), o pool único de rewards é 9, não 11. Total de cards únicos jogáveis = 10 tipos no starter + 9 rewards únicos + `manter_linha` = 20.
**Precisa:** corrigir a contagem no GDD e decidir o status de `manter_linha`.

### G-B4 — Encontros sem cards reward
**Status:** `em design`
O GDD lista rewards para 4 encontros. Mas `emboscada_no_cruzamento` e `fortaleza_desfiladeiro` existem no catálogo — o reward está especificado no GDD mas não está refletido no `slice_catalog.json` (que só tem `"reward_card": "golpe_preciso"` como entrada única). A cadeia progressiva de rewards NPC + encontros não está implementada além do primeiro reward.

---

## Categoria: Documentação

### G-D1 — `project-brief.md` desatualizado
**Status:** ⚠️ `inconsistência ativa`
O corpo do brief ainda menciona "energy starts at 1", "10-card deck" como dados correntes. Tem nota de rodapé dizendo que o GDD governa, mas confunde leitura rápida.
**Precisa:** ou reescrever o brief para refletir o estado atual, ou adicionar banner no topo marcando-o como documento histórico.

### G-D2 — `architecture.md` não lista `descarte` como fase
**Status:** ⚠️ `inconsistência ativa`
`architecture.md` lista fases: `manutencao`, `compra`, `fase_principal`, `encerrada`. A fase `descarte` foi adicionada ao GDD e ao current-status.md mas não foi propagada para architecture.md.
**Precisa:** adicionar `descarte` à lista de fases em architecture.md.

### G-D3 — GDD versão desatualizada
**Status:** ⚠️ `inconsistência ativa`
GDD diz `Version: 0.5` mas recebeu alterações substanciais nesta sessão (descarte, hand mechanics, reescrita da seção 7).
**Precisa:** atualizar para `Version: 0.6`.

---

## Categoria: Apresentação

### G-P1 — Modo 2D/3D indefinido
**Status:** `aberto`
O project-brief lista "2D, 3D, or hybrid presentation" como decisão em aberto. Na prática o projeto está lockado em 2D pelo código atual, mas nenhuma decisão foi formalizada.
**Precisa:** declarar formalmente no GDD ou architecture.md que a decisão é 2D para o slice e permanece em aberto para o produto final.

### G-P2 — Transição de encontro
**Status:** `aberto`
Como o player entra em um encontro? O projeto-brief menciona "encounter transition style" como aberto. Atualmente é `change_scene_to_file()` direto. Não há animação, cinemática, ou contextualização.
**Precisa:** pelo menos uma decisão de direção (fade simples, tela de loading temática, animação de chegada ao local).

---

## Prioridade de resolução

**Resolver antes de qualquer conteúdo novo:**
- G-B2 (`manter_linha`), G-B3 (contagem GDD), G-D1 (brief), G-D2 (architecture fases), G-D3 (GDD version)

**Resolver antes de expandir para campanha:**
- G-T1 (save/load), G-N4 (campanha e mapa), G-R1 (stats), G-R2 (progressão)

**Resolver quando o jogo tiver conteúdo estável:**
- G-B1 (balanceamento), G-T2 (áudio), G-P1 (2D decision), G-P2 (transição)

**Resolver quando a narrativa for prioridade:**
- G-N1 (setting), G-N2 (herói), G-N3 (NPCs), G-N5 (título), G-R3 (itens), G-R4 (deck como RPG)
