# JogoDaCopa — história técnica e de produto

## Metadata

- status: `active`
- authority: `historical_record`
- last_verified: `2026-07-17`
- review_when: `uma fonte histórica for removida, uma decisão antiga for reinterpretada ou a linhagem técnica mudar`
- supersedes: `resumos dispersos em tracks, planos e reviews pré-cutover`
- superseded_by: `none`

Este registro preserva o conteúdo durável das fontes históricas do projeto. Ele não define estado, prioridade, próxima track ou aprovação nova.

Use `current-status.md` para estado técnico, os contratos em `../docs/` para comportamento vigente e `../docs/release-history.md` para publicações.

## Inventário curado

- 50 documentos em `implementation/tracks/`: 1.781 linhas.
- 23 reviews em `docs/code-review-*.md`: 674 linhas.
- 6 planos ou documentos de opções: 570 linhas.
- 46 relatórios Markdown em `docs/playtest-reports/`: 2.583 linhas, além de JSON, PNG e outros dados brutos preservados.
- Nenhuma fonte foi removida durante esta curadoria; o cutover depende de manifesto e receipt próprios.

## Fronteira de origem

O futebol nasceu como modo dentro do antigo `FpsShooter/FPS Playground`. Essa origem explica alguns documentos com nome ou marcador FPS nesta pasta, mas não transfere armas, arena shooter ou bot de combate ao JogoDaCopa.

O split de 2026-06-10 tornou este projeto a autoridade exclusiva de `Super Campeao`; o laboratório FPS vive em `../../FpsPlayground/`.

## Registro dos 50 documentos de track

### Antecedentes no antigo FPS Playground

| Fonte | Resultado durável | Autoridade retida |
|---|---|---|
| Track 00 Project Bootstrap | Primeiro protótipo editor-first que continha o modo FPS; antecedente, não contrato do JogoDaCopa. | Esta seção e `../../FpsPlayground/`. |
| Track 04A FPS Playground Menu & Futebol | Introduziu o protótipo Futebol 1x1, bola solta, bot, placar e menu dentro do antigo projeto. | `../docs/mode-contract.md` e esta seção. |
| Track 05 Foundation Hardening | Originou helpers, validadores e contratos reutilizados durante o split; Arena Shooter não foi herdado. | `../docs/architecture-overview.md` e `../docs/validation.md`. |
| Track 06A Avatar Visual Foundation | Criou a primeira interface de avatar e seleção visual procedural. | `../docs/avatar-visual-contract.md`. |
| Track 06B Third-Person Camera | Tornou o futebol terceira pessoa e manteve o FPS apenas no projeto de origem. | `../docs/mode-contract.md` e `../docs/architecture-overview.md`. |
| Track 06C Feel & Possession | Introduziu assist leve e controle próximo; o possession lock foi removido depois pela 01A. | `../docs/mode-contract.md` registra somente a regra vigente de bola solta. |

### Fundação independente e arena

| Fonte | Resultado durável | Autoridade retida |
|---|---|---|
| Track 00 Project Split Foundation | Criou `JogoDaCopa`, removeu a superfície shooter e roteou menu, geração e testes somente para futebol. | `../AGENTS.md`, `../README.md` e `../docs/architecture-overview.md`. |
| Track 01A Arcade Arena Boost | Removeu possession lock, ampliou arena, fechou paredes/teto e adotou boost/stamina com bola solta. | `../docs/mode-contract.md` e `../docs/tuning-guide.md`. |
| Track 01B Ball Goal Kick Tuning | Fixou grip de solo, preservação aérea, gol de meia largura 4,32 m e altura 3,45 m, LMB 20,5 e RMB pop alto. | `../docs/tuning-guide.md`. |
| Track 01C Arena Stadium Visual | Fechou caixas dos gols, tornou o gol sensível à altura e estabeleceu a arena festiva sem marcas oficiais. | `../docs/mode-contract.md`, `../docs/asset-licenses.md`. |

### Série 02 — qualidade e assets reais

| Fonte | Resultado durável | Autoridade retida |
|---|---|---|
| Track 02A Render & Lighting | Estabeleceu noite, ACES, glow, SSAO, fog, key light e refletores com orçamento controlado. | `../docs/architecture-overview.md`, `../docs/validation.md`. |
| Track 02B Pitch & Materials | Substituiu caixas visuais por shaders de pitch, rede e torcida; placares passaram a refletir a partida. | `../docs/architecture-overview.md`. |
| Track 02C Ball & Character Assets | Adotou shader/trail/squash da bola e testou uma abstração de avatar, ainda sem personagem skinned real. | `../docs/asset-licenses.md` e histórico 02H/02C-bis abaixo. |
| Track 02C-bis Real Character | Integrou Quaternius UBC/UAL, player e bot skinned, biblioteca real de animações e chute autoral. | `../docs/avatar-visual-contract.md`, `../docs/asset-licenses.md`. |
| Track 02D-bis Real Audio | Criou buses SFX/UI/Ambience, pools 2D/3D e áudio real; apito sintético permaneceu exceção deliberada. | `../docs/asset-licenses.md` e contratos de feedback no runtime. |
| Track 02D VFX & Game Feel | Adotou countdown, lock de input, slow motion de gol, shake, FOV kick, boost trail e skid. | `../docs/mode-contract.md`. |
| Track 02E HUD & Menu | Criou preview 3D, seleção visual, HUD broadcast, indicador da bola e resultado/rematch. | `../docs/architecture-overview.md`. |
| Track 02F Bot & Match Flow | Adotou previsão simples, defesa, boost, três dificuldades e kickoff alternado. | `../docs/bot-contract.md`. |
| Track 02G Product Identity | Estabeleceu `Copa Arena Futebol`, branding autoral e primeiro smoke Windows; o nome público posterior virou `Super Campeao`. | `../README.md`, `../docs/asset-licenses.md`, `../docs/release-history.md`. |
| Track 02H Quality Hotfix | Removeu o rig decorativo sem skinning, corrigiu HUD/pads e adiou personagem real até a 02C-bis. | Este registro e `../docs/avatar-visual-contract.md`. |

### Série 03 — identidade arcade, playtest e integridade visual

| Fonte | Resultado durável | Autoridade retida |
|---|---|---|
| Track 03A Movement & Actions | Adotou dash, slide/ombrada, stun curto, double jump/flip e paridade de bot. | `../docs/mode-contract.md`, `../docs/bot-contract.md`. |
| Track 03B Arcade Field | Adotou boost pads e jump pads; as rampas foram removidas pela 03L por decisão de quina simples. | `../docs/mode-contract.md` e reversão 03L abaixo. |
| Track 03C Super Shot & Fireball | Adotou carga LMB, barra SUPER, limite por kickoff, uso equivalente do bot e fireball cosmética. | `../docs/mode-contract.md`, `../docs/bot-contract.md`. |
| Track 03D Match Flavor | Tornou 3 minutos o default, preservou 3 gols, adicionou vale-2 final, golden goal, announcer e emote. | `../docs/mode-contract.md`. |
| Track 03E Toon Experiment | Criou toon isolado e reversível; a decisão durável é toggle OFF por padrão, sem direção de arte aprovada. | Contrato de render e evidência em `../docs/screenshots/track-03e-toon/`. |
| Track 03F Quality Hotfix | Impediu consumo de SUPER em whiff, preservou PBR no tint e tornou medição 1920x1080/vsync off a baseline válida. | Testes, `../docs/validation.md` e este registro. |
| Track 03G Playtest Findings | Corrigiu seis achados humanos: menu, seleção na intro, dash, kickoff/defesa, câmera e teleport seguro da bola. | Contratos vivos e testes atuais. |
| Track 03H Avatar Parity & Drift | Escondeu corpo primitivo do bot e adicionou diagnósticos; o strip manual de root/pelvis causou regressão e foi supersedido. | Diagnósticos vigentes e correção 03K abaixo. |
| Track 03I Menu Interaction | Reproduziu o hit-test 0x0 e estabeleceu clique real em 1920x1080, 1366x768 e 1280x720. | `../docs/architecture-overview.md`. |
| Track 03K Pose Restore V2 | Substituiu reescrita frágil de keyframes pela remoção integral das tracks do bone `root`, preservando pelvis e pose. | `../docs/avatar-visual-contract.md` e testes atuais. |
| Track 03L.1 Facing Evidence | Acrescentou teste e capturas para facing e rebote sem alterar gameplay. | `../docs/screenshots/track-03l-arena/` e testes atuais. |
| Track 03L Arena Seal & Facing | Fechou o vão parede-teto e face alta do gol, ativou CCD, removeu rampas e alinhou facing do player. | `../docs/mode-contract.md`; arena e facing foram aprovados no review 03L/03L.1. |

### Série 04/05 — apresentação, Web e primeira publicação

| Fonte | Resultado durável | Autoridade retida |
|---|---|---|
| Track 04B1 Character Presentation | Criou regiões de uniforme, cabelo no Head bone, toon via next-pass e chute autoral de amplitude humana. | `../docs/avatar-visual-contract.md`, `../docs/asset-licenses.md`. |
| Track 04B2 Feel & UI Fixes | Curva de dash, flip vertical, painéis clicáveis e preview não preto foram aprovados e integrados. | Testes e contratos vivos. |
| Track 04B3 Kick Arms Polish | Limitou abdução a 25 graus e mãos abaixo da cabeça; Fabio aprovou visualmente a nova silhueta. | Testes de avatar e evidência `../docs/screenshots/track-04b3-kick-arms/`. |
| Track 04C Stadium Visual | Adotou arquibancadas config-driven, crowd excitement, telões e skyline; blend de uniforme sem ganho foi revertido. | `../docs/architecture-overview.md` e evidência 04C. |
| Track 04D Match Completeness | Adotou pause completo, resultado com stats, fades, fluxo ESC e restart limpo. | `../docs/mode-contract.md` e arquitetura de HUD. |
| Track 04E Web Spike | Estabeleceu Web single-threaded e `RenderProfile`; a captura lavada foi rejeitada até o hotfix 04E.1 restaurar noite e rejeitar BOM. | `../docs/validation.md`, `../docs/publication-readiness.md`. |
| Track 04F.2 First-Render Stall | Retidos sharing B1 e warmup incremental C7; tentativas sem ganho foram revertidas e o residual de primeiro uso seguiu para 05B/05B.1. | Evidência 04F/04F.2 e gates de Web atuais. |
| Track 05 Web Publication | Criou pacote Brotli abaixo de 25 MiB por asset, probe remoto e a primeira linhagem pública em Cloudflare Pages. | `../docs/publication-readiness.md`, `../docs/release-history.md`. |

### Série 09 — decomposição conservadora do FootballRoot

| Fonte | Resultado durável | Autoridade retida |
|---|---|---|
| Track 09A FootballRoot Extraction | Extraiu ambiente, captura, placares e perf sem mudar gameplay. | `../docs/architecture-overview.md`. |
| Track 09B Web Loading Controller | Extraiu overlay, warmup, settle e buckets do loading Web. | `../docs/architecture-overview.md`. |
| Track 09C Runtime Spawner | Extraiu criação e wiring de player, bot, bola, câmera, HUD e feedback. | `../docs/architecture-overview.md`. |
| Track 09D Match Flow Controller | Extraiu kickoff, reset, countdown, lock de input e primeiro toque. | `../docs/architecture-overview.md`. |
| Track 09E Match Presentation Controller | Extraiu snapshots, cadência de HUD/placares, resultado e códigos de kit. | `../docs/architecture-overview.md`. |
| Track 09F Arcade Field Controller | Extraiu boost/jump pads; publicação 09F passou com margem de heap apertada. | `../docs/architecture-overview.md`, `../docs/release-history.md`. |
| Track 09G Match Resolution Controller | Extraiu gol, placar, timer, golden goal, fim e stats; primeira publicação falhou heap e fez rollback. | `../docs/architecture-overview.md`, `../docs/release-history.md`. |
| Track 09H Web Heap Hotfix | Removeu alocação de Dictionary por frame; publicação passou no limite e recebeu reteste humano aprovado. | `../docs/release-history.md`. |
| Track 09I Kick Super Controller | Extraiu kick/SUPER sem delta de gameplay; publicação e reteste humano foram aprovados. | `../docs/architecture-overview.md`, `../docs/release-history.md`. |
| Track 09J Ball Contact Controller | Extraiu contato/controle da bola; local verde, publicação falhou heap duas vezes e voltou à 09I. | `../docs/architecture-overview.md`, `../docs/release-history.md`. |

## Decisões duráveis extraídas de planos e reviews

- Direção visual: arena de Copa festiva à noite, estilizada e sem marcas oficiais; não há aprovação automática de qualidade visual futura.
- Estratégia de assets: arena/VFX procedurais e assets externos licenciados apenas quando registrados em `../docs/asset-licenses.md`.
- Power-ups clássicos de party game ficaram fora; boost pads, jump pads e SUPER foram adotados localmente pelo JogoDaCopa.
- Toda ação nova do player exige resposta ou uso equivalente do bot; toda força na bola passa por `FootballBall3D.kick()`.
- O toon permanece experimento OFF por padrão. Review técnico e screenshot não substituem decisão humana de direção de arte.
- UI interativa exige clique real nas três resoluções contratuais. Visibilidade ou presença de node não prova interação.
- Captura de cena noturna deve montar o ambiente aprovado e medir luma; a falha 04E originou o gate permanente e a rejeição de BOM.
- Otimização é retida somente com medição. Crowd MultiMesh, threaded load, full pre-overlay warmup e outros experimentos 04F sem ganho foram revertidos.
- O Web público permanece single-threaded. Feedback de áudio Web espera ativação do navegador; PC preserva o pacote completo.
- Extrações 09A–09Q mantêm `FootballRoot` como fachada e não autorizam mudança de gameplay, input, física, bot, scoring, tuning ou assets.
- A métrica histórica `js_wasm_heap_growth` passou a significar `js_heap_growth`; evidências antigas mantêm o alias, sem amostra real de WASM.
- Nenhum plano histórico define o próximo passo atual. A migração documental não abre track de produto.

## Aprovações e reversões que não podem ser inferidas novamente

- A correção 03H de root/pelvis foi tecnicamente verde, mas visualmente regressiva; 03K a supersede integralmente.
- Arena e facing 03L/03L.1 foram aprovados; a histerese da defesa aérea permaneceu como observação histórica, não gate ativo.
- Tracks 04B1/04B2 tiveram review técnico aprovado; 04B3 teve também aprovação visual explícita de Fabio.
- Track 04E foi inicialmente rejeitada por evidência inválida e só aprovada tecnicamente depois do hotfix 04E.1.
- Tracks 09J, 09K, 09G, 10B e releases 07/07B/08 tiveram rollback; verde local nunca foi tratado como aprovação pública.
- A sequência humana aprovada de fallbacks públicos é 09H → 09I → 09N → 09P → 09Q → 09S → 10A → 10D.
- 09R e 10C passaram gates remotos, mas foram supersedidas antes de aprovação humana. 10B falhou o gate remoto antes de qualquer aprovação.
- Track 10D é a aprovação humana vigente; Track 10A é o fallback aprovado anterior. O estado atual permanece em `current-status.md`.

## Mapa de evidência preservada

- Reviews: `../docs/code-review-*.md` enquanto aguardam o cutover autorizado.
- Relatórios narrativos: `../docs/playtest-reports/*.md` enquanto aguardam o cutover autorizado.
- Evidência bruta: subdiretórios de `../docs/playtest-reports/`; não são substituídos por este resumo.
- Evidência visual: `../docs/screenshots/`; aprovação técnica de integração não implica aprovação visual.
- Licenças e origem: `../docs/asset-licenses.md`; nunca dependem somente do Git histórico.
- Release roots, tentativas, rollbacks e aprovações: `../docs/release-history.md`.
