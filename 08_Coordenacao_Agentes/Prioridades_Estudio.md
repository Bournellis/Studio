# Prioridades do Estudio

Este documento e a fonte de verdade de portfolio para agentes e para coordenacao do `D:\Estudio`.

## Foco Atual

- Foco operacional temporario unico: `Projetos/JogoDaCopa/` (`JOGO_DA_COPA_TRACK_01C_ARENA_STADIUM_VISUAL_REWORK_COMPLETE`)
- Pausa temporaria por poucos dias: `Projetos/draxos-roguelike-cardgame/`, `Projetos/draxos-mobile/`, `Projetos/FpsPlayground/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/` (preservado como referencia - nao e o projeto ativo)
- Projetos pausados: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## Portfolio

| Prioridade | Projeto | Caminho | Fase | Status | Trabalho permitido | Proximo passo | Restricao operacional |
|---|---|---|---|---|---|---|---|
| Pausa | Draxos Roguelike Cardgame | `Projetos/draxos-roguelike-cardgame/` | Implementacao pausada temporariamente | `PAUSADO_TEMPORARIO` | Consulta historica e retomada explicita apenas | Retomar em poucos dias quando o foco temporario do JogoDaCopa for encerrado | Agentes devem ignorar por padrao durante o foco temporario do JogoDaCopa |
| Pausa | DraxosMobile | `Projetos/draxos-mobile/` | Implementacao pausada temporariamente - `BOSQUE_OVERLAY_LAYER_READINESS_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA` | `PAUSADO_TEMPORARIO` | Consulta historica e retomada explicita apenas | Retomar em poucos dias quando o foco temporario do JogoDaCopa for encerrado | Agentes devem ignorar por padrao durante o foco temporario do JogoDaCopa; pacote publicado permanece preservado |
| Pausa | FpsPlayground | `Projetos/FpsPlayground/` | Implementacao pausada temporariamente - `FPS_PLAYGROUND_PROJECT_SPLIT_FOUNDATION_COMPLETE` | `PAUSADO_TEMPORARIO` | Consulta historica e retomada explicita apenas | Retomar em poucos dias quando o foco temporario do JogoDaCopa for encerrado | Agentes devem ignorar por padrao durante o foco temporario do JogoDaCopa |
| P0 TEMP | JogoDaCopa | `Projetos/JogoDaCopa/` | Implementacao - foco operacional temporario unico | `P2_IMPLEMENTACAO` | Codigo, design, validacao, playtest no editor e documentacao local | Playtest humano do `Futebol` com gols fechados, arena de vidro, estadio de Copa e tuning de bola/gol/chute | Enquanto o foco temporario estiver ativo, agentes devem escolher este projeto por padrao para implementacao/design/validacao/playtest |
| Arquivo | Mobile Universe (conceito) | `Projetos/_conceitos/mobile-universe/` | Arquivo de design | `ARQUIVO_DESIGN` | Leitura e referencia de design apenas | - | Nao criar codigo, cenas, assets ou projeto Godot a partir daqui |
| Pausado | RPG Isometrico | `Projetos/rpg-isometrico/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, expandir gates ou selecionar Next Gate sem pedido explicito |
| Pausado | RPG Turnos | `Projetos/rpg-turnos/` | Pausado | `PAUSADO_INDEFINIDO` | Consulta historica quando solicitado | Nenhum enquanto pausado | Nao implementar, selecionar track/gate, regenerar `.tres` ou alterar escopo sem pedido explicito |

Nota Draxos Roguelike Cardgame: `Design Lab V1 Foundation` foi concluido em 2026-06-06. O sample `design_lab_sample_v1` passou gate em `user://design_lab/design_lab_sample_v1_gate` com 36 candidatos, 3 recomendacoes, 0 mecanicas bloqueadas e sem alterar `data/definitions/slice_catalog.json`. O lab agora e a ponte recomendada entre ideia de carta/mecanica/encontro e numeros jogaveis. Regressao preservada: `validate.gd` 220/220, Card Impact V5 official before gate PASS, Run Lab smoke/quick gates PASS. A baseline anterior `Enemy Card Redesign Batch 02 Using V5 Terra` segue aceita com 30/30 assinaturas inimigas e 21/21 Card Flow Expectations.

Nota DraxosMobile: `Bosque Overlay Layer And Readiness Authority v1` foi publicado como Internal Alpha em `internal-alpha/v0-bosque-overlay-layer-readiness-authority-v1-20260610-181861c`, mantendo a URL principal como contrato player-facing. O pacote mantem o Bosque vivo e visivel atras de Arena/Base/Shop/Social/Profile em overlay, pausa input/coleta/movimento durante menus, coloca Arena active/replay em camada fullscreen acima do menu, usa modal global/topmost para confirmacoes, mostra prontidao de menus com servidor e preserva retorno via `Fechar`, `Voltar` e Esc sem rebootstrap. O proximo passo e playtest humano focado desse pacote publicado; bugs futuros voltam ao fluxo normal se aparecerem. Arena PVE segue como primeiro core aprovado; Bosque/Openworld e slice integrado de Internal Alpha, nao aprovacao automatica para expansao ampla. Bosque Arena Abandon Recovery Authority v1 fica preservado como pacote anterior de recuperacao de abandono; Bosque Overlay Interactive Controls Authority v1 fica preservado como pacote anterior de controles interativos; Bosque Overlay Menu Action Authority v1 fica preservado como pacote anterior de botoes internos; Bosque Overlay Navigation Hotfix v1 fica preservado como hotfix de interacao anterior; Bosque Persistent Overlay Shell v1 fica preservado como pacote overlay anterior; Bosque Diegetic Launcher Foundation v1 fica preservado como pacote launcher anterior; Bosque Bootstrap Authority v1 fica preservado como pacote bootstrap anterior, Arena PVE Bonus Visual v1 fica preservado como pacote Arena anterior e Bosque Node Cooldown ACK v1 segue como baseline anterior de Bosque. Track 13 release safety e Track 14 agent ops seguem como guardrails operacionais.

Nota FpsPlayground: criado pela separacao do antigo `Projetos/FpsShooter/` em 2026-06-10. O projeto agora e somente o laboratorio FPS/editor-first: menu com `Arena Shooter`, `Duel Pit V2`, rifle hitscan, RMB Plasma Bolt, pickups elevados, jump pads, HUD de combate/rota/LOS, bot vertical-aware, dodge de plasma, salto simples, rotas por jump pads e knockback aceito. O mapa shooter atual nao tem void/fall zones; void/queda ficam reservados para mapas futuros. Tema Draxos permitido apenas como visual leve; nao herda sistemas de DraxosMobile, Draxos Roguelike Cardgame, RPG Isometrico ou RPG Turnos.

Nota JogoDaCopa: criado pela separacao do antigo `FPS Playground` em 2026-06-10 como projeto proprio para futebol e minigames de copa. A baseline atual preserva o modo `Futebol`: 1x1 contra bot em terceira pessoa, sem armas, intro pausada `Como Jogar`/`Comecar`, LMB chute mais forte, RMB chute forte alto, bola `RigidBody3D` arcade solta sem possession lock, mais grip em rolamento no chao sem matar velocidade no ar, quique maior, campo 38x54, gols 20% mais estreitos e 50% mais altos fechados por teto de vidro, regra de gol com altura, paredes altas de vidro com molduras, teto com colisao e ribs visuais, estadio festivo por primitivas com arquibancadas, blocos de torcida, banners inspirados em paises, placares decorativos e torres de luz, placar ate 3 gols, boost em `Shift` com stamina no HUD, bot que ataca/defende dentro do campo maior, HUD/feedback de chute/gol, avatares humanoides procedurais para player/bot, selecao em memoria de tom de pele/camisa inspirada em paises, animacoes basicas, camera de perseguicao em terceira pessoa com foco de bola sutil e chute por direcao corporal.

## Status Aceitos

- `P0_IMPLEMENTACAO`: foco principal do trabalho de desenvolvimento, com permissao padrao para codigo, validacao e playtest.
- `P1_CONCEITO`: projeto em incubacao conceitual; permite documentos, pitch, design e referencias.
- `P2_IMPLEMENTACAO`: projeto ativo secundario; permite codigo, design, documentacao local e infraestrutura.
- `PAUSADO_TEMPORARIO`: projeto preservado e retomavel em poucos dias; agentes devem ignorar por padrao e so atuar com pedido explicito de retomada.
- `PAUSADO_INDEFINIDO`: projeto preservado, sem trabalho ativo por padrao.
- `AGUARDANDO_DECISAO`: projeto ou area sem proximo passo definido.
- `ARQUIVO_DESIGN`: material de conceito promovido - preservado apenas para leitura e referencia.
- `ARQUIVO_HISTORICO`: material preservado apenas para consulta historica.

## Regras Para Agentes

- Leia este arquivo antes de escolher projeto alvo.
- Enquanto o foco temporario do JogoDaCopa estiver ativo, se o pedido nao citar projeto, assuma `Projetos/JogoDaCopa/`.
- Enquanto o foco temporario do JogoDaCopa estiver ativo, ignore `draxos-roguelike-cardgame`, `draxos-mobile` e `FpsPlayground` por padrao, salvo pedido explicito de retomada ou consulta historica.
- Nao mova mecanicas, decisoes ou escopo entre projetos sem documento local adotando a regra.
- Em `_conceitos/mobile-universe/`, apenas leitura e referencia de design - o projeto ativo e `draxos-mobile/`.
- Em RPG Isometrico e RPG Turnos, nao implemente nem expanda escopo sem pedido explicito do usuario.
- Ao concluir tarefa que mude status observavel, atualize este arquivo, `Estado_Atual.md` e o registro relevante em `Projetos/README.md`.
