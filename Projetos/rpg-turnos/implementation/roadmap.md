# RPG Turnos Roadmap

- Last Updated: `2026-05-03`
- Current Phase: `Fase 3 - Cardgame Core`
- Current Baseline: `first playable slice with menu, 2D map, NPC card reward, deck setup, scripted duel, explicit phase state machine, and GUT validation`
- Current Product Focus: `prototype the C1 combat variant (continuous main phase, shared priority, attacks as actions) as the active cardgame direction, before expanding RPG progression, character stats, lore content, or campaign systems`

## Roadmap Formal

### Fase 0 - Fundacao Do Projeto

Status: `DONE`

Objetivo: criar um projeto Godot limpo, separado do RPG Isometrico em mecanicas, mas preparado para compartilhar lore de estudio.

Entregas concluidas:

- projeto `rpg-turnos`
- estrutura de diretorios por sistemas
- documentos iniciais
- GDD inicial
- regras locais para agentes

### Fase 1 - Primeiro Slice Jogavel

Status: `DONE`

Objetivo: provar o loop completo mais simples do jogo.

Entregas concluidas:

- menu com `Novo jogo` e `Sair`
- mapa 2D top-down placeholder
- movimento com `WASD`
- interacao com `E`
- NPC com recompensa de carta
- setup de deck de 10 cartas
- batalha por turnos com 3 rotas
- duelo contra heroi inimigo roteirizado
- tela de resultado
- derrota voltando ao snapshot pre-combate
- validacao Godot/GUT

### Fase 2 - Polimento Do Slice Atual

Status: `PASS_03_DONE`

Objetivo: transformar o slice funcional em uma base confortavel para playtest, antes de expandir regras ou conteudo.

Entregas desta fase:

- melhorar legibilidade do setup de deck
- oferecer acoes por botao alem de drag-and-drop
- mostrar feedback claro de acoes validas/invalidas
- reduzir travamentos ou rebuilds inseguros de UI
- cobrir fluxos de UI com testes

Entregas ja implementadas no primeiro passe:

- contadores de cartas disponiveis e cartas selecionadas no setup
- botoes `Limpar deck` e `Auto preencher`
- acoes por botao para jogar cartas da mao em slots/hero
- feedback textual para acoes de batalha
- testes de UI para setup e primeira jogada de batalha

Entregas ja implementadas no segundo passe:

- tela de combate reorganizada em status, tabuleiro, log e mao
- botao `Resolver turno` fixo no topo para passar o turno e resolver ataques
- tabuleiro com areas separadas para campo inimigo, rotas e campo do jogador
- log de turno em painel proprio
- cartas da mao mais compactas para preservar espaco de acoes
- teste garantindo que o botao de turno continua visivel/usavel apos gastar energia

Entregas ja implementadas no terceiro passe:

- area central do combate deixou de empurrar a mao para fora da tela
- mao permanece em painel inferior visivel com scroll
- correcao validada no mesmo fluxo de boot e testes do combate

Nao faz parte desta fase:

- novas regras profundas de combate
- progressao RPG completa
- save/load real
- conteudo narrativo final
- decisao definitiva 2D/3D

### Fase 3 - Cardgame Core

Status: `PASS_02_DONE`

Objetivo: evoluir o prototipo de batalha como um cardgame primeiro, testando profundidade, clareza e variacao antes de investir em RPG, personagem, stats, lore ou campanha.

Gates esperados:

- reavaliar toda a regra de turno
- testar turnos mais elaborados, com fases, janelas de decisao ou resolucoes separadas se isso melhorar o jogo
- implementar um laboratorio de combate para comparar variacoes antes de travar regras finais
- testar prioridade estilo jogador ativo mais respostas
- testar prioridade por iniciativa compartilhada
- testar combate automatizado
- testar combate interativo com prioridade durante ataques
- testar uma variante sem fase de combate, com ataques como acoes da fase principal
- testar magias instantaneas que nao gastam prioridade
- testar tabuleiros diferentes e mais complexos
- testar posicoes com atributos proprios
- definir como atributos de posicao afetam cartas, alvos, rotas, defesa, ataque ou efeitos
- palavras-chave com regras formais
- alvos e validacao de alvo melhores
- hero power
- mais cartas e tipos
- mais encontros
- IA inimiga menos rigida
- balanceamento inicial

Entregas ja implementadas no primeiro passe:

- poder heroico basico `Preparar`
- `Preparar` compra 1 carta
- uso limitado a 1 vez por rodada
- botao `Poder heroico` no topo do combate
- feedback textual e testes de motor/UI para o poder heroico

Entregas ja implementadas no segundo passe:

- maquina de fases explicita no motor de batalha
- sequencia padrao `round_start -> draw -> main_1 -> combat -> main_2 -> turn_end`
- fases automaticas resolvem sem input do jogador
- fases interativas avancam por acao do jogador
- UI de combate exibe a fase atual
- botao principal muda entre ir para combate, resolver combate e encerrar turno
- cartas e poder heroico ficam bloqueados fora das fases principais
- testes de motor e UI cobrem ordem de fases, transicoes automaticas e bloqueio de acoes

Decisao de direcao (2026-05-03):

- A direcao de combate ativa e `C1 - Continuous Main Phase With Shared Priority And Attack Actions`.
- As variantes A1/A2/B1/B2 e a estrutura phase-based com Combat dedicado ficam preservadas como ideias de design em `../docs/cardgame-core-experiments.md`, mas nao sao alvos de implementacao.
- O lab de variantes foi colapsado para focar esforco em uma unica direcao coerente.

Plano de implementacao atual:

- `Pass 02`: maquina de fases explicita `DONE`
- `Pass 03`: implementar variante C1 (continuous main phase, prioridade compartilhada, ataques como acoes) `NEXT`
- `Pass 04`: experimento de resolucao de combate (B1 vs B2) `PRESERVED_AS_DESIGN_IDEA`
- `Pass 05`: variante phase-based alternativa `PRESERVED_AS_DESIGN_IDEA`
- `Pass 06`: topologia de tabuleiro e atributos de posicao `PLANNED`
- `Pass 07`: encontros de laboratorio focados em C1 `PLANNED`
- `Pass 08`: avaliacao e decisao de promover C1 a canon ou voltar para fallback `PLANNED`

Documentos de referencia:

- `../docs/cardgame-core-experiments.md`
- `tracks/track-01-foundation-first-prototype/cardgame-core-implementation-plan.md`

### Fase 4 - Progressao RPG

Status: `DEFERRED_AFTER_CARDGAME_CORE`

Objetivo: fazer o personagem crescer fora do combate e alterar as opcoes de combate.

Gates esperados:

- level
- stats
- inventario
- equipamentos
- recompensas permanentes
- evolucao de deck
- recompensas por quest

### Fase 5 - Conteudo De Campanha E Narrativa

Status: `DEFERRED_AFTER_CARDGAME_CORE`

Objetivo: trocar placeholders por conteudo jogavel com intencao narrativa.

Gates esperados:

- NPCs com linhas e escolhas reais
- sidequests
- rotas
- encontros com contexto
- primeiro arco curto
- integracao com lore compartilhado do estudio

### Fase 6 - Persistencia

Status: `NOT_STARTED`

Objetivo: salvar e carregar progresso real.

Gates esperados:

- save/load local
- estado de mapa
- deck e cartas desbloqueadas
- inventario
- flags narrativas
- estado de encontros concluidos

### Fase 7 - Decisao Visual Maior

Status: `DECISION_SESSION_REQUIRED`

Objetivo: decidir a direcao visual definitiva depois que o loop e a batalha estiverem mais claros.

Opcoes ainda abertas:

- 2D top-down
- 3D isometrico
- hibrido

Regra: a decisao visual nao deve contaminar as regras de combate, progressao ou dados.

### Fase 8 - Vertical Slice De Produto

Status: `FUTURE`

Objetivo: montar um trecho pequeno com qualidade mais proxima de produto.

Gates esperados:

- visual mais definido
- conteudo real
- combate mais profundo
- progressao basica
- save/load
- smoke manual completo
- validacao automatizada ampliada

## Onde Estamos

Estamos na `Fase 3 - Cardgame Core`, com a maquina de fases da Pass 02 implementada e a direcao C1 escolhida como foco principal de prototipo.

A `Fase 1` provou o loop completo, e a `Fase 2` deixou o slice mais confortavel para playtest. A `Fase 3 Pass 02` adicionou a maquina de fases configuravel que permite plugar variantes diferentes na mesma engine de batalha. A decisao de 2026-05-03 e perseguir C1 (sem fase de combate dedicada, prioridade compartilhada, ataques como acoes de Main Phase) como a direcao principal a ser prototipada e playtestada antes de abrir progressao RPG, personagem, stats, lore ou conteudo narrativo. As demais variantes seguem documentadas como ideias de design preservadas, prontas para servir de fallback.
