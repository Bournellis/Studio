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
| `map_environment` | 1120 × 600 px | 🟢 | Arte de fundo da área de exploração. Floresta com trilha de terra. Retângulo sem borda — borda adicionada pelo engine. |
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
| `portrait_npc_viajante` | 144 × 144 px | 🟡 | Retrato da NPC que entrega cartas. Mulher viajante, roupa neutra, expressão amigável. |
| `portrait_hero_aprendiz` | 144 × 144 px | 🟡 | Retrato do herói do jogador: Aprendiz do Limiar. Jovem guerreiro, postura determinada. |
| `portrait_hero_duelista_bandido` | 144 × 144 px | 🟡 | Retrato do inimigo do encontro duelo. Figura hostil com arma. |

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
| `card_art_escudeiro` | `escudeiro` | criatura | 🔴 | Jovem combatente com escudo e espada curta, postura neutra. |
| `card_art_guarda_vila` | `guarda_vila` | criatura | 🔴 | Guarda robusto com escudo erguido, expressão firme. |
| `card_art_lobo_faminto` | `lobo_faminto` | criatura | 🔴 | Lobo magro e veloz em corrida rasante, olhos famintos. |
| `card_art_soldado_linha` | `soldado_linha` | criatura | 🔴 | Soldado uniformizado em postura de combate na linha de frente. |
| `card_art_arqueira_penhasco` | `arqueira_penhasco` | criatura | 🔴 | Arqueira em borda de penhasco, arco tensionado, vista do vale abaixo. |
| `card_art_bruto_mercenario` | `bruto_mercenario` | criatura | 🟡 | Mercenário corpulento com arma pesada, expressão ameaçadora. |
| `card_art_javali_guerra` | `javali_guerra` | criatura | 🟡 | Javali enorme com armadura leve, em carga frontal. |
| `card_art_barricada` | `barricada` | estrutura | 🟡 | Barricada de troncos e sacos de terra bloqueando passagem. |
| `card_art_balista` | `balista` | estrutura | 🟡 | Balista de madeira maciça montada em plataforma elevada. |
| `card_art_raio_curto` | `raio_curto` | magia | 🟡 | Faísca elétrica curta, energia azul em forma de arco. |

### 5b. Cartas de Recompensa (11 designs únicos)

*Chuva de Brasas e Campeão da Guilda aparecem em duas fontes de recompensa mas são o mesmo card — um único asset para cada.*

| Asset ID | ID no catálogo | Tipo | Prioridade | Descrição da ilustração |
|---|---|---|---|---|
| `card_art_golpe_preciso` | `golpe_preciso` | magia | 🔴 | Espada brilhando com energia dourada, golpe certeiro em close. |
| `card_art_corvo_batedor` | `corvo_batedor` | criatura | 🟡 | Corvo grande em voo rasante, asas abertas, olhos brilhantes. |
| `card_art_chuva_brasas` | `chuva_brasas` | magia_de_tabuleiro | 🟡 | Brasas e fagulhas caindo do céu sobre campo de batalha. |
| `card_art_campeao_guilda` | `campeao_guilda` | criatura | 🟡 | Guerreiro veterano com armadura de guilda, postura imponente. |
| `card_art_lobo_alfa` | `lobo_alfa` | criatura | 🟡 | Lobo enorme liderando a matilha, cicatrizes de batalha. |
| `card_art_relampago` | `relampago` | magia | 🟡 | Raio massivo descendo do céu em trajeto reto, clarão cegante. |
| `card_art_flagelo` | `flagelo` | magia | 🟢 | Onda de energia escura varrendo tudo no caminho, escala épica. |
| `card_art_arqueira_voante` | `arqueira_voante` | criatura | 🟡 | Arqueira com asas de grifo em voo, arco apontado para baixo. |
| `card_art_torre_blindada` | `torre_blindada` | estrutura | 🟢 | Torre de pedra massiva com troneiras, inexpugnável. |
| `card_art_dragao_jovem` | `dragao_jovem` | criatura | 🟢 | Dragão jovem em mergulho de ataque, asas abertas, fogo contido. |
| `card_art_chamado_hostes` | `chamado_hostes` | magia_de_tabuleiro | 🟢 | Trompete soando, luz dourada ativando criaturas aliadas. |

**Pasta destino:** `res://assets/cards/art/`

---

## 6. Cartas Inimigas (sem arte necessária na fase atual)

Estas cartas existem no catálogo mas são usadas apenas pelo inimigo. Arte não é prioridade — o player não as vê no deck. Documentadas para planejamento futuro.

| ID no catálogo | Display name | Nota |
|---|---|---|
| `goblin_ponte` | Goblin da Ponte | Inimigo inicial: Emboscada na Ponte |
| `bruto_ponte` | Bruto da Ponte | Inimigo pesado: Emboscada na Ponte |
| `arqueiro_ponte` | Arqueiro da Ponte | Inimigo alcance alto: Emboscada na Ponte |
| `ladrao_rapido` | Ladrão Rápido | Deck do Duelista Bandido |
| `faca_arremessada` | Faca Arremessada | Deck do Duelista Bandido |
| `guardiao_portal` | Guardião do Portal | Deck do Duelista Bandido |
| `atirador_torre` | Atirador da Torre | Encontros futuros |
| `soldado_central` | Soldado Central | Encontros futuros |

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
`menu_background`, `map_environment`, `card_art_flagelo`, `card_art_torre_blindada`, `card_art_dragao_jovem`, `card_art_chamado_hostes`, VFX sheets
