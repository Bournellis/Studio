# Open Gaps

- Last Updated: `2026-05-05`
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
As cartas ativas têm stats que parecem razoáveis mas nunca foram testadas. Não há critério de avaliação (ex: "criatura de 1 custo deve ter ATK+HP entre 3 e 5"), não há baseline de referência, não há dados de playtest.
**Precisa:** pelo menos uma sessão de playtest do deck inicial contra emboscada_na_ponte com registro do resultado.

### G-B2 — Carta `manter_linha` não catalogada no GDD
**Status:** `decidido, pendente implementação`
Decisão do usuário em 2026-05-05: `manter_linha` deve ser deletada. Ela ainda existe no `slice_catalog.json` e em referencias de teste/asset, mas nao faz parte do deck inicial, rewards, enemy-only cards, nem plano futuro.
**Precisa:** remover do catálogo, recursos gerados, testes e asset planning ativo na proxima implementação.

### G-B3 — Contagem de cartas no GDD
**Status:** `resolvido nos docs, pendente validação após limpeza`
O GDD agora separa copias de deck, designs únicos, reward unique cards, reward entries e enemy-only cards. `golpe_preciso` é recompensa introdutória da NPC e `manter_linha` foi marcada para remoção.
**Precisa:** apos deletar `manter_linha`, validar a contagem real do catálogo gerado.

### G-B4 — Encontros sem cards reward
**Status:** `dados parciais, engine pendente`
O catálogo JSON já possui `reward_cards` em encontros e `npc_reward_choices`, mas `GameSession`, `ContentLibrary`, result screen e mundo ainda usam o modelo legado de uma recompensa NPC global.
**Precisa:** implementar `first_npc_reward_card`, `reward_cards`, `completed_encounter_ids`, `claimed_encounter_reward_ids` e retorno `Array[String]` em `claim_encounter_reward`.

---

## Categoria: Documentação

### G-D1 — `project-brief.md` desatualizado
**Status:** `resolvido nos docs`
O brief tem banner histórico no topo e aviso na seção Status. O corpo permanece como registro histórico.
**Precisa:** nao usar o brief para regra ativa.

### G-D2 — `architecture.md` não lista `descarte` como fase
**Status:** `resolvido nos docs, engine pendente`
`architecture.md` já lista `descarte` como fase importante. O runtime ainda nao implementa essa fase.
**Precisa:** implementar fase `descarte` no engine/UI na proxima rodada de regras.

### G-D3 — GDD versão desatualizada
**Status:** `resolvido`
GDD está em `Version: 0.6`.
**Precisa:** proxima mudança substancial deve atualizar data e versão.

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
- implementar remoção de `manter_linha`
- corrigir teste obsoleto de `size_limit`
- separar runtime de design pendente em qualquer novo status
- implementar ou manter explicitamente pendentes as regras de recursos: energia, mão, deck cíclico e `descarte`

**Resolver antes de expandir para campanha:**
- G-T1 (save/load), G-N4 (campanha e mapa), G-R1 (stats), G-R2 (progressão)

**Resolver quando o jogo tiver conteúdo estável:**
- G-B1 (balanceamento), G-T2 (áudio), G-P1 (2D decision), G-P2 (transição)

**Resolver quando a narrativa for prioridade:**
- G-N1 (setting), G-N2 (herói), G-N3 (NPCs), G-N5 (título), G-R3 (itens), G-R4 (deck como RPG)
