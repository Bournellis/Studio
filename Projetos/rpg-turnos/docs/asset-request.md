# Asset Request — Pedido para o Artista

- Last Updated: `2026-05-05`
- Status: `placeholder phase — sem arte importada ainda`

Este documento lista todos os assets visuais que o jogo precisa. Cada entrada tem um ID codificado que é o nome do arquivo final, as dimensões, a descrição funcional e o estilo esperado. Quando um asset estiver pronto, ele entra em `res://assets/` e o caminho é registrado em `core/asset_ids.gd` — nenhum outro código precisa mudar.

Prioridades: 🔴 necessário para sensação de jogo · 🟡 importante para primeira impressão · 🟢 polish

---

## Como entregar

1. Salve o arquivo com o nome exato da coluna **Asset ID** + extensão `.png` (salvo onde indicado).
2. Registre o caminho em `core/asset_ids.gd` na entrada correspondente.
3. O jogo carrega automaticamente na próxima execução.

Formato padrão: PNG, fundo transparente salvo onde indicado. Paleta de cores de referência no final deste documento.

---

## 1. UI e Menus

| Asset ID | Dimensões | Prioridade | Descrição |
|---|---|---|---|
| `ui_logo` | 720 × 180 px | 🟡 | Logo / título do jogo. Tipografia tratada ou ilustração. Fundo transparente. Deve funcionar sobre fundo escuro (`#0B0D0F`). |
| `menu_background` | 1280 × 720 px | 🟢 | Arte de fundo da tela de menu principal. Cena de ambiente. Sem foco central — funciona com painel sobreposto. |
| `result_bg_victory` | 1280 × 720 px | 🟡 | Fundo da tela de resultado — vitória. Tom quente, luz dourada ou amanhecer. |
| `result_bg_defeat` | 1280 × 720 px | 🟡 | Fundo da tela de resultado — derrota. Tom frio, sombrio, chuva ou névoa. |
| `icon_victory` | 64 × 64 px | 🟡 | Ícone de vitória. Escudo, coroa ou espada erguida. Cor dominante: verde (`#4A7A5A`). |
| `icon_defeat` | 64 × 64 px | 🟡 | Ícone de derrota. Espada quebrada ou caveira. Cor dominante: vermelho (`#7A4A4A`). |

**Pasta destino:** `res://assets/ui/`

---

## 2. Mapa-Mundi

| Asset ID | Dimensões | Prioridade | Descrição |
|---|---|---|---|
| `map_environment` | 1120 x 600 px | baixa | Arte de fundo da area de exploracao. Zona elemental com base de ether, terreno mineral e sinais de energia astral. Retangulo sem borda; borda adicionada pelo engine. |
| `marker_npc` | 56 × 56 px | 🟡 | Marcador de NPC no mapa. Silhueta de personagem, tom azul (`#4A6A78`). Fundo transparente. |
| `marker_encounter_active` | 68 × 68 px | 🟡 | Marcador de encontro ativo. Ícone de espada cruzada ou bandeira. Tom laranja (`#B86A47`). |
| `marker_encounter_done` | 68 × 68 px | 🟡 | Marcador de encontro concluído. Mesmo shape, tom verde (`#47A06A`). |
| `player_token` | 44 × 44 px | 🟡 | Token do jogador no mapa. Seta ou figura com direção. Cor creme (`#DCDC9E`). |

**Pasta destino:** `res://assets/world/`

---

## 3. Retratos (Portraits)

Retratos aparecem em painéis de diálogo (72 × 72 px) e na HUD da batalha (48 × 48 px). Entregar em 144 × 144 px — o engine escala conforme necessário.

| Asset ID | Dimensões | Prioridade | Descrição |
|---|---|---|---|
| `portrait_npc_viajante` | 144 x 144 px | media | ID tecnico legado. Direcao ativa: funcao de comando/mentor Draxos na base de ether; renomear asset depois que identidade estabilizar. |
| `portrait_hero_aprendiz` | 144 × 144 px | 🟡 | Placeholder tecnico para o heroi. Direcao ativa: comandante Draxos da expedicao; renomear asset depois que o nome/player-facing identity estabilizar. |
| `portrait_hero_duelista_bandido` | 144 x 144 px | media | ID tecnico legado. Direcao ativa: guardiao elemental hostil usado no encontro de duelo. |

**Pasta destino:** `res://assets/portraits/`

---

## 4. Frames de Carta

Frames são a moldura visual de cada carta. Um frame por tipo. Interior transparente — a ilustração fica atrás.

Dimensões completas do card token (deck setup): 148 × 180 px.

| Asset ID | Dimensões | Prioridade | Cor dominante | Descrição |
|---|---|---|---|---|
| `card_frame_criatura` | 148 × 180 px | 🔴 | `#4A7A5A` verde | Frame orgânico. Folhas ou galhos nas bordas. |
| `card_frame_magia` | 148 × 180 px | 🔴 | `#6A4A7A` violeta | Frame arcano. Runas, estrelas, ondas de energia. |
| `card_frame_magia_de_tabuleiro` | 148 × 180 px | 🟡 | `#8A5A9A` violeta claro | Frame de magia global. Variação do frame magia, mais expansivo. |
| `card_frame_estrutura` | 148 × 180 px | 🟡 | `#5A6A7A` ardósia | Frame sólido. Pedra, tijolos ou metal. |
| `card_frame_permanente` | 148 × 180 px | 🟡 | `#7A6A3A` âmbar | Frame envelhecido. Madeira, couro ou pergaminho. |
| `card_frame_comando` | 148 × 180 px | 🟡 | `#7A4A4A` vermelho | Frame de comando. Pergaminho selado, tinta vermelha. |
| `card_back` | 148 × 180 px | 🟡 | `#181C1F` | Costas da carta. Padrão simétrico ou emblema. Sem informação de jogo. |

**Pasta destino:** `res://assets/cards/frames/`

---

## 5. Arte das Cartas do Jogador

Uma ilustração por carta. Área central do card token: 148 × 80 px. Entregar nessa proporção ou maior.
Estilo: flat com sombras suaves, ou pintura digital simplificada. Sem borda própria — o frame envolve por cima.

### 5a. Deck Inicial (10 cartas únicas)

| Asset ID | ID no catálogo | Tipo | Prioridade | Descrição da ilustração |
|---|---|---|---|---|
| `card_art_escudeiro` | `escudeiro` | criatura | 🔴 | Adepto Draxos em postura de treinamento astral, foco em disciplina e leitura clara. |
| `card_art_guarda_vila` | `guarda_vila` | criatura | 🔴 | Custodio de ether sustentando uma barreira astral defensiva. |
| `card_art_lobo_faminto` | `lobo_faminto` | criatura | 🔴 | Fera subjugada por energia astral, veloz e agressiva. |
| `card_art_soldado_linha` | `soldado_linha` | criatura | 🔴 | Operador Draxos de linha avancando em formacao. |
| `card_art_arqueira_penhasco` | `arqueira_penhasco` | criatura | 🔴 | Atiradora astral em ponto alto, disparo de energia sobre terreno elemental. |
| `card_art_bruto_mercenario` | `bruto_mercenario` | criatura | 🟡 | Executor Draxos pesado, silhueta imponente e energia astral concentrada. |
| `card_art_javali_guerra` | `javali_guerra` | criatura | 🟡 | Besta de impacto subjugada, corpo mineral ou etherizado em carga frontal. |
| `card_art_barricada` | `barricada` | estrutura | 🟡 | Barreira de ether bloqueando passagem em terreno elemental. |
| `card_art_balista` | `balista` | estrutura | 🟡 | Condutor astral fixo, estrutura de energia usada para disparos de alcance. |
| `card_art_raio_curto` | `raio_curto` | magia | 🟡 | Pulso astral curto, energia violeta-azulada em arco de impacto. |

### 5b. Cartas de Recompensa (11 designs únicos)

*Chuva de Brasas e Campeão da Guilda aparecem em duas fontes de recompensa mas são o mesmo card — um único asset para cada.*

| Asset ID | ID no catálogo | Tipo | Prioridade | Descrição da ilustração |
|---|---|---|---|---|
| `card_art_golpe_preciso` | `golpe_preciso` | magia | 🔴 | Ordem de supressao Draxos marcada por linha de energia precisa no alvo. |
| `card_art_corvo_batedor` | `corvo_batedor` | criatura | 🟡 | Batedor de ether em voo rasante, forma semi-astral e olhos brilhantes. |
| `card_art_chuva_brasas` | `chuva_brasas` | magia_de_tabuleiro | 🟡 | Fragmentos vulcanicos e astralizados caindo sobre campo elemental. |
| `card_art_campeao_guilda` | `campeao_guilda` | criatura | 🟡 | Executor veterano Draxos, postura de autoridade e armadura arcana. |
| `card_art_lobo_alfa` | `lobo_alfa` | criatura | 🟡 | Fera alfa subjugada, maior e marcada por energia de controle astral. |
| `card_art_relampago` | `relampago` | magia | 🟡 | Descarga astral vertical rasgando o campo com brilho intenso. |
| `card_art_flagelo` | `flagelo` | magia | 🟢 | Onda de energia astral destrutiva varrendo o alvo. |
| `card_art_arqueira_voante` | `arqueira_voante` | criatura | 🟡 | Sentinela alada ou forma elemental voadora atacando de cima. |
| `card_art_torre_blindada` | `torre_blindada` | estrutura | 🟢 | Torre de cristal elemental, massiva e defensiva. |
| `card_art_dragao_jovem` (ID tecnico legado; Manifestacao Vulcanica) | `dragao_jovem` | criatura | 🟢 | Manifestacao vulcanica alada emergindo de calor, cinzas e cristal. |
| `card_art_chamado_hostes` | `chamado_hostes` | magia_de_tabuleiro | 🟢 | Comando de dominio Draxos ativando unidades com sigilos astrais. |

**Pasta destino:** `res://assets/cards/art/`

---

## 6. Cartas Inimigas (sem arte necessária na fase atual)

Estas cartas existem no catálogo mas são usadas apenas pelo inimigo. Arte não é prioridade — o player não as vê no deck. Documentadas para planejamento futuro.

| ID no catálogo | Display name | Nota |
|---|---|---|
| `goblin_ponte` | Elemental Menor | ID tecnico legado; resistencia elemental inicial |
| `bruto_ponte` | Guardiao de Basalto | ID tecnico legado; defensor pesado elemental |
| `arqueiro_ponte` | Lanceiro de Cinzas | ID tecnico legado; alcance em ponto alto |
| `ladrao_rapido` | Centelha Predadora | ID tecnico legado; unidade elemental rapida |
| `faca_arremessada` | Estilhaco Vulcanico | ID tecnico legado; dano de fragmento |
| `guardiao_portal` | Guardiao do Nexo | Defensor elemental |
| `atirador_torre` | Sentinela de Cristal | Alcance em posicao elevada |
| `soldado_central` | Defensor Elemental | Presenca robusta no centro |

---

## 7. Efeitos Visuais (deferred — sem prioridade atual)

| Asset ID | Tipo | Descrição |
|---|---|---|
| `vfx_attack_melee` | SpriteSheet 6–8 frames | Impacto físico corpo-a-corpo |
| `vfx_attack_ranged` | SpriteSheet 6–8 frames | Projétil físico de alcance |
| `vfx_attack_magic` | SpriteSheet 6–8 frames | Explosão mágica, brilho violeta |
| `vfx_destroy` | SpriteSheet 6–8 frames | Carta destruída — desintegra |
| `vfx_heal` | SpriteSheet 4–6 frames | Pulso verde de cura |
| `particle_menu_ambient` | Textura 16 × 16 px | Partícula para GPUParticles2D do menu |

**Pasta destino (futuro):** `res://assets/vfx/`

---

## 8. Paleta de Referência

| Token | Hex | Uso |
|---|---|---|
| `BG_DEEP` | `#0B0D0F` | Fundo de tela |
| `BG_PANEL` | `#181C1F` | Painéis |
| `BORDER_DEFAULT` | `#3D484F` | Bordas inativas |
| `BORDER_ACTIVE` | `#5A7080` | Bordas ativas |
| `TEXT_PRIMARY` | `#E0E0D8` | Texto principal |
| `TYPE_CRIATURA` | `#4A7A5A` | Verde floresta |
| `TYPE_ESTRUTURA` | `#5A6A7A` | Azul ardósia |
| `TYPE_PERMANENTE` | `#7A6A3A` | Âmbar |
| `TYPE_MAGIA` | `#6A4A7A` | Violeta |
| `TYPE_COMANDO` | `#7A4A4A` | Vermelho |

---

## Resumo por prioridade

**🔴 Primeiro:**
`card_frame_criatura`, `card_frame_magia`, artes das 5 primeiras cartas do deck inicial, `card_art_golpe_preciso`, `icon_victory`, `icon_defeat`

**🟡 Segunda rodada:**
Frames restantes, todos os retratos, marcadores de mapa, `ui_logo`, `result_bg_*`, artes das 5 últimas cartas do deck inicial, artes das rewards

**🟢 Polish:**
`menu_background`, `map_environment`, `card_art_flagelo`, `card_art_torre_blindada`, `card_art_dragao_jovem` (ID tecnico legado; Manifestacao Vulcanica), `card_art_chamado_hostes`,