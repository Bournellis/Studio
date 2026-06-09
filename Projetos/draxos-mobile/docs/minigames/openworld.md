# Openworld Bosque

- Status: `ACTIVE_INTERNAL_ALPHA`
- Mode id: `openworld`
- Slice id: `forest`
- Ruleset: `openworld_forest_ruleset_v1`, version `1`
- Snapshot schema: `openworld_forest_snapshot_v1`
- Shared definition: `data/definitions/openworld/forest_ruleset_v1.json`
- Launcher catalog: `data/definitions/openworld/forest_launcher_v1.json`
- Descriptor: `data/definitions/modes/openworld/metadata.json`
- Placeholder: `data/definitions/modes/openworld/placeholder.json`
- Decision pack: `docs/minigames/openworld-decision-pack.md`
- Entry action: `open_mode_shell:openworld`
- Route: `mode_shell`
- Client module: `modes/openworld/`

`Openworld Bosque` e o primeiro slice do modo `Openworld`. Ele nasceu do prototipo `Rpgsuave Bosque`, mas V1 renomeia o modo de verdade: novos payloads, rotas, settings, docs e testes usam `openworld`.

Oficial, neste documento, significa `mode_registry.status=active` dentro do canal `internal_alpha`. Pacote atual publicado: `Bosque Diegetic Launcher Foundation v1`, versao `0.0.16-alpha.0`, version code `16`, minimum supported version code `13`, release root `internal-alpha/v0-bosque-diegetic-launcher-foundation-v1-20260609-e55ed0c`, preview tecnico `https://56b58162.draxos-mobile-internal-alpha.pages.dev`, portal oficial `https://draxos-mobile-internal-alpha.pages.dev/`, Web direto `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, transformando o Bosque em launcher diegetico e impedindo que o Bosque integrado renderize um mundo jogavel full-spawn antes do bootstrap canonico remoto/cache. O proximo passo operacional e playtest humano focado do pacote publicado; bugs futuros voltam ao fluxo normal se aparecerem. `Bosque Bootstrap Authority v1` permanece como pacote bootstrap anterior: release root `internal-alpha/v0-bosque-bootstrap-authority-v1-20260609-ba99e70`, preview tecnico `https://0123894f.draxos-mobile-internal-alpha.pages.dev`, version code `15`. `Bosque Node Cooldown ACK v1` permanece como pacote Bosque anterior de cooldown/ACK: release root `internal-alpha/v0-bosque-node-cooldown-ack-v1-20260608-626b4ad`, preview tecnico `https://5cce952e.draxos-mobile-internal-alpha.pages.dev`, version code `13`. `Bosque Resume Exit Lifecycle v1` permanece como pacote remoto anterior de reentrada/saida: release root `internal-alpha/v0-bosque-resume-exit-lifecycle-v1-20260608-9a0f7c0`, preview tecnico `https://39128c59.draxos-mobile-internal-alpha.pages.dev`, version code `12`. `Bosque Feel & Spawn Authority v1` permanece como pacote remoto anterior de feel/spawn: release root `internal-alpha/v0-bosque-feel-spawn-authority-v1-20260608-70b79c3`, preview tecnico `https://16ac3cb7.draxos-mobile-internal-alpha.pages.dev`, version code `11`. `Bosque Persistence Rebase v1` permanece como pacote remoto anterior de persistencia: release root `internal-alpha/v0-bosque-persistence-rebase-v1-20260608-bc23f74`, preview tecnico `https://0c0a8dcf.draxos-mobile-internal-alpha.pages.dev`, version code `10`, substituindo o modelo de snapshot local como promessa de save por operacoes duraveis com ACK do servidor e cooldown por item.

## Visao

Openworld mira um mundo continuo no longo prazo. O Bosque nao e o teto conceitual; e o primeiro espaco jogavel para validar sensacao de movimento, coleta, bolso, bau, crafting local, uma ponte controlada de recompensa e, agora localmente, um launcher diegetico estreito para menus existentes. O pacote atual nao autoriza expansao ampla de mundo, combate, quests, NPCs, economia paralela, cidade ou hub amplo alem das entradas V1 descritas abaixo.

## Politica Operacional Atual

Politica viva do Openworld/Bosque: **client-owned active preview,
server-authoritative durable Bosque progress, station crafts and rewards**.

Durante uma visita ativa, o cliente e autoridade de runtime para movimento,
posicao, coleta ativa, preview visual, guidance local e feedback de HUD. O
cliente pode aplicar preview otimista para coleta, deposito e craft, mas esse
preview nao e progresso salvo. Save duravel so existe depois de ACK do
servidor em `/modes/session/checkpoint`.

O servidor e autoridade para sessao ativa, ruleset, progresso duravel aceito do
Bosque, cooldown de node, checkpoint aceito, craft de estacao que gera
consumivel global, limites, conclusao, recompensa, ledger e auditoria. A
recompensa real so existe depois de um checkpoint aceito e de `complete`
server-authoritative.

O Bosque pode virar a camada visual/navegavel do jogo no futuro, mas nao vira
um banco economico unico. A politica atual e separar os dominios:

- `Bosque duravel`: `Mochila do Bosque`, `Bau do Bosque`, upgrades e
  `structures` por save;
- `Conta/Ossario`: recursos globais como `ossos` e `po_osso`;
- `Pocoes globais`: `player_consumables` criados por craft de estacao;
- `Arena`: preparacao, slot de pocao e consumo server-authoritative em batalha;
- `Station Craft`: ponte transacional entre `Bau do Bosque` e `Conta/Ossario`.

Coletar no Bosque nunca aumenta diretamente `resources.ossos` nem
`resources.po_osso`. Materiais locais com tema ritual usam nomes proprios:
`resto_ritual` (`Resto ritual`) e `po_cinzento` (`Po cinzento`). Saves/caches
legados com `ossos_preview` ou `po_osso_preview` devem ser normalizados para
esses IDs locais.

`Bau`, `Mochila/Bolso`, upgrades de capacidade, estruturas craftadas, guidance
confirmado e `node_state` sao progresso duravel por save. Nodes nao resetam por
visita; cada node usa `next_spawn_at` proprio e reaparece somente quando o
cooldown do item vence. Posicao, coleta ativa e tempo de visita continuam sendo
estado de visita. `Fogueira Estavel I` e estrutura duravel local e tambem
estacao `fogueira_estavel_1` para receitas globais de pocao.

Sessao de visita expira em 2 horas. Uma sessao expirada nunca deve ser retomada
como `active_session`, mesmo que ainda exista em `mode_sessions` ou no cache
local. Depois da expiracao, entrar no Bosque inicia nova visita injetando o
progresso duravel aceito (`Bau`, `Mochila`, `upgrades`, `structures`,
`guidance`, `node_state`). Operacoes pendentes locais so podem ser reexecutadas
se a sessao original ainda estiver valida; se a sessao morreu, a fila e
descartada com mensagem clara de alteracoes nao confirmadas expiradas.

Regra de regressao para agentes: nao reintroduzir `move_heartbeat`,
`collect_start`, `collect_cancel`, `collect_complete`, `deposit_all` ou `craft`
como caminho principal de gameplay remoto revisionado sem uma decisao explicita
em `docs/minigames/openworld-decision-pack.md`. `collect_batch` e eventos
legados existem por compatibilidade com pacotes antigos; o cliente novo usa
fila `openworld_pending_ops_cache` + checkpoints de operacoes duraveis.

Snapshots remotos da mesma sessao so podem:

- inicializar/recuperar a visita antes do primeiro frame jogavel;
- confirmar metadados de checkpoint aceito;
- recuperar conflito real fora do controle ativo, com mensagem clara para o
  jogador;
- confirmar operacoes duraveis ACKed e limpar a fila local correspondente.

Eles nao podem transformar o mundo ja renderizado, reposicionar o jogador,
reiniciar coleta, reaparecer node em cooldown, reverter bolso/bau/craft ACKed
ou declarar save antes do servidor.

Contrato de feel/spawn v1:

- coleta ativa pertence ao cliente ate completar, falhar por distancia real ou
  sumir por conflito explicito; movimento dentro do raio de cancelamento nao
  reinicia a barra;
- node coletado some imediatamente como overlay local pendente, mas apenas a
  operacao ACKed limpa a pendencia e grava o cooldown duravel;
- `collected_nodes` legado nunca bloqueia um node quando o payload duravel ja
  contem `node_state`; no contrato v2, a autoridade visual de respawn e
  `node_state.next_spawn_at` comparado com `server_time`;
- o cliente guarda offset de `server_time` e aplica uma pequena grace visual no
  respawn para evitar o flicker de "aparece por 1s e some";
- ACK de checkpoint durante controle ativo aplica patch duravel e metadados,
  mas nao faz rebootstrap do mundo inteiro nem reinicia coleta;
- deposito e craft local podem entrar na fila enquanto outro checkpoint esta em
  voo; a UI pode mostrar preview/pendencia, mas sucesso duravel continua
  dependendo do ACK;
- busy de menu e por escopo. Uma requisicao em `app`, `base`, `mode`, `social`
  ou outro dominio nao deve congelar botoes de escopos independentes nem o
  `Voltar`, exceto durante replay ou update gate explicito.

## Bosque Diegetic Launcher Foundation v1

Bosque Diegetic Launcher Foundation v1 nasceu como hardening/fundacao local e
foi publicado por DMOB-D077 como o pacote Internal Alpha atual. O Bosque passa a
ser o launcher diegetico estreito do app: construcoes procedurais no proprio
Bosque abrem menus player-facing existentes por contratos do app-shell.

Restricoes preservadas: sem backend novo, sem schema novo, sem economia nova,
sem recompensa nova, sem tuning novo, sem asset novo e sem aprovacao automatica
para expansao ampla do Bosque/Openworld.

Fonte de dados:

- catalogo local versionado:
  `data/definitions/openworld/forest_launcher_v1.json`;
- loader/validador client-side:
  `modes/openworld/openworld_forest_launcher_catalog.gd`;
- controller de proximidade/toque:
  `modes/openworld/openworld_forest_launcher_controller.gd`;
- separado do ruleset de coleta/craft
  `data/definitions/openworld/forest_ruleset_v1.json`.

Entradas V1:

| Entry id | Label | Action |
|---|---|---|
| `arena_pve_gate` | `Arena PVE` | `open_arena` |
| `refugio_workbench` | `Refugio` | `show_base` |
| `shop_stall` | `Loja` | `show_shop` |
| `social_totem` | `Social` | `show_social` |
| `profile_shrine` | `Perfil` | `show_account` |

Contrato de runtime:

- cada entrada precisa de `entry_id`, `label`, `action_id`, `visual_kind`,
  `position` e `interaction_radius`;
- o HUD mostra no maximo um prompt contextual para a construcao mais proxima;
- proximidade e tap/click em landmark resolvem o mesmo `action_id`;
- `OpenworldForestScreen` emite
  `shell_action_requested(action_id, entry_id)`;
- o Bosque nao chama Boot, Supabase, backend ou mutacao diretamente para abrir
  menus;
- `ModeShellLauncher` conecta o signal ao action router do shell;
- `Voltar` de Arena/Base/Loja/Social/Perfil deve retornar ao `mode_shell`
  quando a entrada veio do Bosque;
- antes de abrir menu com operacoes pendentes, o Bosque tenta flush/checkpoint;
  se falhar, preserva o estado local, mostra mensagem honesta e segue para o
  menu sem prometer salvamento final;
- em `integrated_alpha`, o retorno usa sessao/cache existentes do Bosque;
- em preview/local, o shell guarda snapshot minimo em memoria por `mode_id`
  durante a navegacao, incluindo posicao e snapshot do modelo, sem persistir em
  disco.

Fora de V1:

- Towerdefense, Cardgame e dev tools nao entram no catalogo;
- menus nao sao embutidos dentro do Bosque;
- nenhum novo predio com economia, recompensa, craft, ranking, social expansivo
  ou mutacao remota entra por implicacao;
- visual permanece procedural simples.

## Bosque Mecanico Basico v2

Bosque Mecanico Basico v2 redefine o slice `forest` como um minigame livre,
relaxante e sem obrigacao de conclusao: entrar, explorar sem pressa, coletar
recursos, depositar no bau, craftar melhorias pequenas e construir uma primeira
estrutura permanente.

A orientacao existe para ajudar o jogador a entender o espaco. Ela nao e uma
quest, nao e objetivo obrigatorio e nao bloqueia entrada, saida, coleta,
deposito, craft ou retorno posterior. O jogador pode entrar e sair quando quiser.

Contratos de produto para v2:

- `Voltar` preserva/pausa a visita em andamento quando houver sessao ativa;
- `Encerrar visita` finaliza a visita e mostra um resumo leve;
- nenhuma acao exige completar a orientacao;
- nenhuma recompensa nova, economia nova ou publicacao remota entra neste pacote;
- sem inimigos, NPCs, quests, combate, cidade, full open world, respawn,
  procedural generation ou expansao de mapa.

## Escopo Atual

- mobile portrait fullscreen;
- wrapper `Control` compativel com `ModeShellLauncher`, com runtime interno
  `SubViewportContainer`/`SubViewport` e mundo `Node2D`;
- camera `Camera2D` seguindo o personagem;
- controles PC/Web por WASD ou setas;
- joystick livre por toque/mouse em area vazia do viewport;
- HUD dentro do jogo;
- prompt contextual unico para o landmark diegetico mais proximo;
- cinco landmarks procedurais V1 para abrir Arena PVE, Refugio/Base, Loja,
  Social e Perfil por action router;
- suporte a tap/click em landmark com o mesmo contrato de action da proximidade;
- mochila funcional com `Mochila do Bosque`, `Bau do Bosque`, `Construcoes`,
  `Fogueira` e `Sessao`;
- aba `Fogueira` para receitas de pocao globais quando a estrutura existe;
- orientacao tutorial discreta de seis passos, persistida no save normal
  server-side e reabrivel pela aba `Sessao`;
- detalhes operacionais escondidos em `Sessao > Detalhes da operacao`;
- colisao local em bau, arvores grandes, rochas grandes e paredes de borda;
- recursos pequenos como `Area2D` coletaveis e sem bloqueio de movimento;
- ordenacao visual por profundidade no mundo 2D, com HUD sempre acima;
- assets procedurais em Godot, sem raster externo novo;
- backend em `integrated_alpha` por `/modes/state`, `/modes/session/start`, `/modes/session/checkpoint`, `/modes/session/complete` e `/modes/session/abandon`;
- snapshot remoto retomavel por ate 2 horas, mas aplicado como bootstrap/recuperacao e nao como rollback visual durante controle ativo;
- sessao remota/local expirada, antiga demais ou sem `expires_at` valido e
  descartada como visita ativa; a proxima entrada cria nova visita com
  progresso duravel preservado e node cooldown vindo de `node_state`;
- cache local de fila `openworld_pending_ops_cache` por
  `account_id/save_id/session_id/ruleset_id` para retry de operacoes ainda sem
  ACK;
- cache local separado entre `openworld_active_session_cache` e
  `openworld_durable_progress_cache`;
- progresso duravel por save para `Bau`, `Mochila/Bolso`, upgrades de mochila e
  estruturas craftadas, guidance e `node_state`;
- craft de estacao em `/crafting/station-craft`, server-authoritative, com
  checkpoint aceito antes de consumir materiais do Bau e `po_osso` da conta;
- checkpoints de operacoes duraveis substituem microeventos revisionados durante gameplay normal;
- nenhum ACK/resync remoto da mesma sessao deve reposicionar o jogador, reiniciar coleta, reverter bolso/bau/craft ou transformar nodes enquanto o jogador esta no Bosque;
- coleta ativa e sticky dentro do raio de cancelamento, sem reset por movimento
  pequeno ou por ACK de checkpoint;
- node cooldown renderiza por `server_time`/offset e ignora caches legados de
  nodes coletados quando `node_state` v2 esta presente;
- saida para menu pelo launcher tenta checkpoint pendente antes de navegar,
  preserva pendencia local se falhar e retorna ao Bosque via stack do shell
  quando possivel;
- Reward Bridge limitado, server-authoritative, idempotente e com ledger.

## Nao Escopo

- inimigos, NPCs, quests, combate, moral system ou gore;
- cidade, campanha, mapa continuo ou full open world;
- mundo aberto completo;
- procedural generation ampla de recursos;
- escrita direta do cliente em Conta/Base;
- ranking, guilda, battle pass, economia ampla ou premium economy do Openworld;
- recompensa nova;
- promessa publica de release.
- expansao do placeholder futuro sem pacote explicito.
- Towerdefense, Cardgame ou ferramentas dev no launcher diegetico V1.
- menus embutidos dentro do Bosque em vez de action router.
- inimigos, NPCs, quests, combate, cidade, mapa novo, recompensa nova, economia
  nova ou mundo continuo neste hardening.

## Orientacao Tutorial v2

A orientacao e um banner discreto com seis passos aprovados:

1. Explore o Bosque sem pressa.
2. Pare perto de um recurso para coletar.
3. Seu bolso guarda o que voce encontra. Quando pesar, volte ao bau.
4. Perto do bau, use Depositar para guardar tudo.
5. Com materiais no bau, crie melhorias e pequenas estruturas.
6. Quando quiser, encerre a visita e volte depois.

Persistencia e reabertura:

- progresso/dispensa da orientacao usa o save normal server-side do modo;
- retomar sessao deve preservar a etapa vista ou o estado de orientacao fechada;
- `Sessao` deve oferecer acao para reabrir a orientacao;
- fechar o banner nao encerra visita, nao completa sessao e nao concede premio.

## Recursos, Craft E Estrutura v2

Bosque v2 deve usar recursos fixos, autorados no ruleset, em quantidade
suficiente para craftar `Bolsa Simples I` e `Fogueira Estavel I` numa unica
visita, com pequena sobra para o jogador nao precisar seguir uma ordem perfeita.

Quantidade minima contratada para os dois crafts:

- `galho`: 6;
- `folha`: 3;
- `resina`: 1;
- `folha_seca`: 2;
- `pedra_pequena`: 1.

A distribuicao v2 deve ter pequenos excedentes fixos, por exemplo ao menos mais
1 `galho`, 1 `folha` e 1 recurso leve adicional. Esses excedentes nao sao nova
economia; sao folga de aprendizagem para o minigame.

`Fogueira Estavel I`:

- aparece depois do craft como objeto procedural permanente da sessao/save;
- fica perto de `x=305 y=330`;
- e bloqueante para movimento como estrutura pequena;
- registra `station_id = fogueira_estavel_1`;
- abre painel de Fogueira quando o jogador se aproxima;
- permite preparar `pocao_vida`, `pocao_foco` e `pocao_resguardo` atraves de
  `POST /crafting/station-craft`;
- consome materiais do Bau do Bosque e `po_osso` da conta; nao consome a
  mochila/bolso;
- exige checkpoint aceito antes da mutacao de estacao;
- deve persistir em `upgrades.fogueira_estavel_1` e
  `structures.fogueira_estavel_1`;
- enquanto estiver local e pendente, pode aparecer como estrutura `salvando`,
  mas receitas globais so liberam depois do checkpoint aceito;
- mensagens de estado devem ser honestas: `Salvando Fogueira...` antes do ACK,
  `Fogueira salva.` apos checkpoint aceito e `Fogueira pendente de salvamento.`
  em falha/rede;
- nao cria combate, NPC, quest, economia ampla, respawn ou recompensa nova;
- pode aparecer no resumo leve como estrutura construida.

## Entrada, Saida E Resumo

- Entrar no Bosque inicia ou retoma visita conforme sessao ativa disponivel.
- Entrar sem visita ativa cria uma nova sessao com o progresso duravel aceito do
  save: bau, mochila, upgrades, estruturas e node cooldown permanecem.
- `Voltar` deve retornar ao shell/refugio preservando a visita quando a sessao
  ainda estiver ativa.
- Se houver operacao duravel pendente, `Voltar` tenta flush e aguarda o ACK.
  Se falhar, preserva o estado local, mostra mensagem clara e sai sabendo que
  ha alteracoes nao confirmadas. O texto nao pode prometer "continua salvando"
  quando o browser/app pode encerrar a requisicao.
- Ao abrir um menu pelo launcher diegetico, o Bosque segue a mesma politica de
  flush/preservacao: tenta salvar, preserva pendencias se falhar e emite a
  action do shell para abrir o menu.
- `Encerrar visita` e a acao explicita de finalizacao, com resumo leve de
  materiais depositados, crafts feitos e estruturas construidas.
- `Encerrar visita` segue bloqueado ate existir checkpoint final aceito, pois a
  recompensa real depende do snapshot validado pelo servidor.
- Nao ha requisito de completar todos os recursos, todos os crafts ou todos os
  passos de orientacao.

## Persistencia Duravel Do Bosque

O Bosque usa caches locais somente para bootstrap visual/retry e um progresso
duravel server-owned:

- `openworld_active_session_cache`: visita ativa, `started_at`, `expires_at`,
  posicao e estado visual da visita;
- `openworld_durable_progress_cache`: cache visual do ultimo progresso aceito;
  ele nunca vence `/modes/state` depois de login online;
- `openworld_pending_ops_cache`: fila local de operacoes sem ACK, por
  `account_id/save_id/session_id/ruleset_id`;
- `mode_progress.progress_payload` com schema
  `openworld_forest_progress_v2`: fonte server-owned para `pocket`, `chest`,
  `upgrades`, `structures`, `guidance`, `node_state`, `progress_revision` e
  `applied_ops`.

Cada operacao recebe `op_id` estavel no formato `owop_<uuid>`. Operacoes v1:

- `collect_node`: coleta um node disponivel, valida item/capacidade/cooldown e
  grava `node_state[node_id].next_spawn_at`;
- `deposit_all`: move todo `pocket` para `chest`;
- `craft_recipe`: consome custo do `chest` e cria upgrade/structure/output;
- `guidance_update`: normaliza e persiste orientacao;
- `position_update`: atualiza somente snapshot de visita, nao progresso duravel.

Status visual permitido:

- `Salvando...` quando ha checkpoint em voo;
- `Salvo no servidor` somente apos ACK;
- `Falha ao salvar` quando o flush falhou;
- `Alteracoes locais pendentes` quando existe fila aguardando retry.

`complete_session` limpa somente o cache da visita ativa. Ele nao apaga `Bau`,
`Mochila/Bolso`, upgrades, estruturas, guidance nem `node_state`. Reset
explicito de save/account ainda limpa o progresso do Bosque, como parte da
limpeza de gameplay do save.

Checkpoints aceitos aplicam operacoes atomica e idempotentemente e retornam o
progresso duravel aceito. A conclusao usa o ultimo checkpoint aceito, faz merge
do progresso duravel e atualiza o ledger para que recompensa real nao seja
duplicada por itens persistentes no bau.

`structures` e campo top-level canonico do progresso duravel. Para
compatibilidade, `upgrades.fogueira_estavel_1 = true` tambem implica
`structures.fogueira_estavel_1 = true`, e qualquer checkpoint/snapshot aceito
deve retornar os dois quando a Fogueira existe. Checkpoint e complete nao podem
remover `structures`.

## Fogueira E Pocao Global

A Fogueira e a primeira ponte intencional entre Openworld e Arena:

- o Bosque continua dono local da rotina relaxante: mover, coletar, depositar,
  construir e salvar checkpoint;
- a conta continua dona global de `resources`, `player_consumables` e
  `player_potion_slots`;
- `POST /crafting/station-craft` e a ponte transacional entre os dois dominios;
- materiais de estacao saem do Bau duravel aceito;
- `po_osso` sai de `resources`;
- a saida entra em `player_consumables` e pode ser equipada na Preparacao da
  Arena;
- se houver checkpoint pendente, o cliente salva o Bosque antes de preparar a
  pocao;
- se o checkpoint falhar, a pocao nao e criada e o estado local do Bosque deve
  permanecer recuperavel.

Receitas v1:

- `craft_pocao_vida`: `folha x2`, `cogumelo x1` + `po_osso x25`;
- `craft_pocao_foco`: `fungo x1`, `inseto x1` + `po_osso x15`;
- `craft_pocao_resguardo`: `resina x1`, `pedra_pequena x1` + `po_osso x20`.

## Descriptor Scaffold

O descriptor declarativo de `Openworld` registra apenas o slice atual
`forest`, o ruleset v1 e o Reward Bridge limitado. O
placeholder em `data/definitions/modes/openworld/placeholder.json` e
explicitamente nao jogavel e reserva futuros slices sem abrir mapa, combate,
recompensa ou backend novo.

`openworld_forest_ruleset_v0` permanece documentado como historico de prototipo local. O ruleset ativo do Bosque oficial tecnico e `openworld_forest_ruleset_v1`.

## Decision Pack V1

`docs/minigames/openworld-decision-pack.md` registra que Bosque continua o unico
slice aprovado. Expansao de mapa, combate, risco, progressao propria ampla,
Reward Bridge novo ou fronteira nova com Basebuilder precisa de pacote proprio.

## Componentes

- `OpenworldForestRuleset`: loader da definition versionada `forest_ruleset_v1.json`.
- `OpenworldForestModel`: regras locais/preview, inventario, coleta, bau, crafting, snapshot e payload.
- `OpenworldForestScreen`: wrapper `Control`, sessao, HUD, sheet, joystick livre,
  foco/input global, fallback Web para WASD/setas, `SubViewport` e integracao
  opcional com snapshot/revision.
- `OpenworldForestWorld2D`: mundo `Node2D`, camera, player, objetos, bordas,
  blockers fisicos dedicados, recursos e estado visual.
- `OpenworldPlayerController`: `CharacterBody2D`, movimento por vetor combinado e
  colisao do jogador.
- `OpenworldWorldCatalog`: catalogo local do Bosque para bau, obstaculos grandes
  e recursos derivados da definition versionada.
- `OpenworldWorldObject`: instancia visual procedural y-sorted e `Area2D` quando
  coletavel/interativo; colisao bloqueante fica no corpo fisico dedicado do
  mundo para nao depender do node visual.
- `OpenworldForestWorldView`: legado Control preservado como referencia removivel,
  sem uso runtime no fluxo novo.
- `OpenworldVirtualJoystick`: input touch/mouse livre, analogico e resetavel.
- `OpenworldInventorySheet`: bolso, bau, craft, sessao e detalhes tecnicos.

## Controles E Mundo

- Movimento final combina teclado, joystick livre e vetor de debug dos smokes,
  limitado a magnitude `1.0`.
- WASD/setas usam `InputMap` e fallback manual por `keycode`/`physical_keycode`
  para Web/PC quando o canvas nao entrega action strength de forma confiavel.
- A velocidade continua vindo de `OpenworldForestModel.current_speed()`, mantendo
  a penalidade de peso existente.
- Joystick fica invisivel quando inativo; toque/click/drag em area livre cria o
  joystick no ponto usado, arrasto atualiza vetor e release zera/oculta.
- Toque/click no HUD, botoes ou sheet nao ativa joystick.
- O bau tem colisao fisica central menor que a area de deposito.
- Arvores e rochas grandes bloqueiam o jogador; recursos pequenos continuam
  atravessaveis e coletam quando o jogador para dentro do raio.
- Bordas invisiveis impedem saida acidental do mapa `960x1400`, com borda visual
  discreta no fundo.

## Backend

- State/resume: `GET /modes/state?mode_id=openworld`
- Start: `POST /modes/session/start`
- Checkpoint: `POST /modes/session/checkpoint`
- Event: `POST /modes/session/event`
- Complete: `POST /modes/session/complete`
- Abandon: `POST /modes/session/abandon`
- Ruleset ativo: `openworld_forest_ruleset_v1`

`GET /modes/state?mode_id=openworld` retorna `active_session` somente quando
existe sessao `started` nao expirada, incluindo `snapshot_payload`,
`snapshot_revision`, `started_at`, `expires_at` e `last_event_at`. Sessoes
`started` expiradas podem existir para historico/auditoria, mas devem ser
projetadas como `expired` ou ignoradas como candidatas de retomada.

Contrato operations-first:

- start/resume buscam `/modes/state?mode_id=openworld` antes do primeiro frame
  jogavel online;
- a base canonica vem de `mode_progress.progress_payload`;
- cache local so completa preview/retry quando a sessao ainda e valida;
- snapshot remoto atrasado da mesma sessao atualiza apenas metadata de
  confirmacao, nunca posicao, coleta ativa, bolso, bau, upgrades, guidance ou
  nodes locais durante controle ativo;
- se a entrada/recuperacao detectar sessao remota diferente ou conflito real, o
  servidor pode vencer antes de devolver controle ao jogador;
- movimento, coleta ativa, nodes visuais e posicao sao runtime client-owned
  durante a visita;
- coleta, deposito, craft e guidance podem ter preview local, mas a versao
  duravel depende de operacao ACKed;
- servidor valida somente sessao ativa, ruleset, checkpoint aceito, caps,
  cooldown, progresso duravel, conclusao, reward, ledger e auditoria;
- stale revision de eventos legados nao deve bloquear deposito/coleta/craft no
  cliente novo; conflito de checkpoint vira recuperacao fora do controle ativo.

`POST /modes/session/checkpoint` retorna `type=mode_checkpoint_ack` dentro do
envelope comum de modos. Esse ACK confirma o checkpoint aceito, a revisao e o
resumo de progresso duravel aceito, mas nao e snapshot visual para rollback
durante gameplay ativo.

Payload principal de checkpoint:

```json
{
  "request_id": "<uuid>",
  "session_id": "<uuid>",
  "mode_id": "openworld",
  "slice_id": "forest",
  "client_sequence": 12,
  "ruleset_id": "openworld_forest_ruleset_v1",
  "ruleset_version": 1,
  "operations": [
    {"op_id": "owop_<uuid>", "type": "collect_node", "node_id": "node_galho_01"},
    {"op_id": "owop_<uuid>", "type": "deposit_all"},
    {"op_id": "owop_<uuid>", "type": "craft_recipe", "recipe_id": "fogueira_estavel_1"}
  ],
  "visit_snapshot": {
    "player_position": {"x": 220, "y": 250},
    "session_seconds": 43
  }
}
```

O SQL aplica o checkpoint atomica e idempotentemente por `op_id`: ruleset
correto, sessao ativa, node existente, item esperado pelo ruleset, cooldown
vencido, capacidade de bolso, custos de craft disponiveis no `chest`, guidance
normalizado e ausencia de mutacao parcial. A resposta informa
`accepted_checkpoint_id`, `snapshot_revision`, `accepted_snapshot_summary`,
`durable_progress`, `complete_ready` e `server_time`.

`collect_node` grava `last_collected_at`, `next_spawn_at` e
`collected_count` em `node_state[node_id]`. Cooldowns v1 por item:

- `galho`, `folha`, `folha_seca`: 300s;
- `pedra_pequena`, `cogumelo`, `inseto`, `resina`: 600s;
- `madeira`, `pedra`, `fungo`: 900s;
- `cinzas_preview`, `resto_ritual`, `po_cinzento`: 1800s.

`POST /modes/session/event` permanece compativel para builds antigas. O cliente
novo nao envia microeventos de gameplay normal (`move_heartbeat`,
`collect_start`, `collect_cancel`, `collect_complete`, `deposit_all`, `craft`)
como caminho principal; ele usa checkpoint com `operations`.

Contrato legado de posicao e resync:

- este contrato existe para pacotes antigos e para recuperacao controlada;
- o cliente operations-first nao usa resync ativo como loop normal de gameplay;
- start/resume podem aplicar `player_position` persistida somente antes de
  devolver controle ao jogador;
- resync da mesma sessao durante controle ativo nao aplica `player_position`,
  `active_collection`, bolso, bau, craft, guidance ou nodes locais;
- se o resync detectar outra sessao ativa ou conflito real, o cliente deve sair
  do controle ativo e tratar como recuperacao explicita;
- no caminho legado SQL, somente `move_heartbeat` atualiza `player_position`;
  eventos de coleta, deposito, craft e guidance preservam a posicao persistida;
- ACK de evento e patch/sanitizado: `snapshot_patch` e
  `session.snapshot_payload` nao expoem `player_position` nem
  `active_collection`.

`POST /modes/session/event` retorna `type=mode_event_ack` dentro do envelope
comum de modos. Esse ACK confirma o evento e a revisao, mas nao deve ser tratado
como snapshot completo de retomada pelo client. Durante gameplay ativo em pacote
legado:

- `snapshot_patch` e a unica parte aplicada ao inventario/estado economico;
- `player_position` continua client-authoritative e nao entra no patch;
- `active_collection` continua client-authoritative ate sair, retomar ou
  resync stale explicito;
- `collect_start` e `collect_cancel` sao lifecycle local/client telemetry no
  cliente novo e nao sao enviados como mutacoes remotas durante gameplay normal;
- `collect_complete` permanece compativel para pacotes antigos;
- o cliente novo prefere `collect_batch`, confirmando varios nodes coletados em
  uma unica revisao;
- `deposit_all` confirma bolso/bau, mas a UI aplica localmente e enfileira depois
  do lote de coleta pendente;
- `craft` confirma bau/upgrades, mas a UI aplica localmente e enfileira depois
  de deposito/coleta pendentes;
- se houver deposito/craft local ja enfileirado, ACK intermediario nao pode
  reverter bolso/bau/upgrades locais ate o ACK final ou resync;
- stale revision bloqueia `Completar`, mostra mensagem discreta e aciona resync
  por `/modes/state`.

Eventos aceitos:

- `checkpoint`
- `move_heartbeat`
- `collect_start`
- `collect_cancel`
- `collect_complete`
- `collect_batch`
- `deposit_all`
- `craft`
- `guidance_update`
- `complete_requested`
- `abandon_requested`

Payload legado de coleta em lote:

```json
{
  "request_id": "<uuid>",
  "session_id": "<uuid>",
  "mode_id": "openworld",
  "slice_id": "forest",
  "event_type": "collect_batch",
  "expected_revision": 3,
  "event_payload": {
    "nodes": [
      {"node_id": "node_galho_01", "item_id": "galho", "session_seconds": 42},
      {"node_id": "node_folha_01", "item_id": "folha", "session_seconds": 43}
    ],
    "position": {"x": 220, "y": 250},
    "session_seconds": 43
  }
}
```

O SQL valida todos os nodes do lote antes de persistir a revisao final: node
existente, item esperado pelo ruleset, node ainda nao coletado, duplicata dentro
do proprio lote e capacidade do bolso. Qualquer falha rejeita o batch sem
mutacao parcial.

Payload legado de evento unitario:

```json
{
  "request_id": "<uuid>",
  "session_id": "<uuid>",
  "mode_id": "openworld",
  "slice_id": "forest",
  "event_type": "collect_complete",
  "expected_revision": 3,
  "event_payload": {
    "node_id": "node_galho_01",
    "item_id": "galho",
    "position": {"x": 330, "y": 420},
    "session_seconds": 42
  }
}
```

Resposta de evento:

```json
{
  "ok": true,
  "type": "mode_event_ack",
  "mode_id": "openworld",
  "slice_id": "forest",
  "session_id": "<uuid>",
  "event_type": "collect_complete",
  "request_id": "<uuid>",
  "expected_revision": 3,
  "revision_after": 4,
  "applied": true,
  "resync_required": false,
  "snapshot_patch": {
    "pocket": {"galho": 1},
    "collected_nodes": {"node_galho_01": true},
    "last_message": "+1 Galho no bolso."
  },
  "authoritative_fields": ["collected_nodes", "last_message", "pocket"],
  "visual_authority": {
    "player_position": "client_during_active_play",
    "active_collection": "client_until_resume_or_resync"
  }
}
```

Payload de complete:

```json
{
  "request_id": "<uuid>",
  "session_id": "<uuid>",
  "mode_id": "openworld",
  "slice_id": "forest",
  "ruleset_id": "openworld_forest_ruleset_v1",
  "ruleset_version": 1,
  "expected_revision": 9
}
```

O servidor valida limites, rejeita stale write, bloqueia reward real em `progression_lab`, calcula recompensa exclusivamente de `snapshot_payload`, aplica deltas por RPC/ledger e retorna resposta idempotente. `deposited_items` enviado pelo cliente nao e autoridade de recompensa.

Fallback offline/sem auth entra em preview sem recompensa. A tela pode continuar jogavel localmente, mas `Completar` fica bloqueado enquanto a sessao integrada estiver sem sync.

## Validacao

- `tests/client/test_openworld_mode_dev.gd`
- `tools/smoke_openworld_forest.gd`
- `tools/smoke_modes_visual_layout.gd`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`
- `server/tests/openworld_reward_bridge_test.ts`
- `server/tests/openworld_ruleset_definition_test.ts`
- `server/tests/modes_platform_schema_test.ts`
