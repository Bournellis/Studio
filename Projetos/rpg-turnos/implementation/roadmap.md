# RPG Turnos Roadmap

- Last Updated: `2026-05-03`
- Current Phase: `Fase 3 - Cardgame Core`
- Current Baseline: `first playable slice with menu, 2D map, NPC card reward, deck setup, scripted duel, result flow, and GUT validation`
- Current Product Focus: `prioritize the standalone cardgame combat loop before RPG progression, character stats, lore content, or campaign systems`

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

Status: `PASS_01_DONE`

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

Plano de implementacao atual:

- `Pass 02`: maquina de fases explicita
- `Pass 03`: experimento de prioridade
- `Pass 04`: experimento de resolucao de combate
- `Pass 05`: variante de fase principal continua sem fase de combate
- `Pass 06`: topologia de tabuleiro e atributos de posicao
- `Pass 07`: encontros de laboratorio para as cinco variacoes principais
- `Pass 08`: avaliacao e escolha de uma direcao principal

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

Estamos na `Fase 3 - Cardgame Core`, com o primeiro passe de combate implementado.

A `Fase 1` provou o loop completo, e a `Fase 2` deixou o slice mais confortavel para playtest. A prioridade agora e tratar o combate como o produto principal: reavaliar turno, testar formatos de tabuleiro, experimentar posicoes com atributos, ampliar cartas/encontros e balancear o cardgame antes de abrir progressao RPG, personagem, stats, lore ou conteudo narrativo.
