# JogoDaCopa - Release Plan: Road to Web (Serie Track 04)

- Date: `2026-06-11`
- Author: Claude (objetivo definido por Fabio)
- **Objetivo**: publicar o Copa Arena Futebol como jogo COMPLETO e POLIDO em Web (itch.io e/ou site proprio), passando por: melhorias de gameplay, polimento, variedade de modos, menu/opcoes de verdade e robustez de app.
- **Modo de execucao**: multiagente - ate 2 threads Codex em paralelo (worktrees com areas de arquivo DISJUNTAS), Claude como orquestrador/revisor/integrador. Merges sempre um por vez com review entre eles.
- Baseline: pos-03L.1 + debugger-bugs (64 tests/773 asserts, debugger limpo, arena selada, avatar real com facing).

## Risco tecnico central (define a ordem do plano)

**Godot Web nao roda Forward+.** O export Web usa o renderer Compatibility (OpenGL/WebGL): glow/SSAO/fog se comportam diferente ou caem fora, shaders precisam ser GLES3-safe, performance e uma fracao do desktop, e threads exigem headers COOP/COEP (itch.io suporta via flag; site proprio precisa configurar). Por isso a **Fase 0 e o spike Web** - descobrir AGORA o que quebra, criar o perfil visual Compatibility com paridade aproximada, e dai em diante TODO fechamento de track inclui build web + screenshot web. Polir primeiro e portar depois seria retrabalho garantido.

## Fase 0R - Quality First (REORDENADA por decisao de Fabio 2026-06-11: qualidade do conteudo atual ANTES do spike web)

Lista de playtest de Fabio (7 itens) mapeada em 2 tracks paralelas disjuntas:

**Track 04B1 - Character Presentation & Animation** (thread 1: avatar/shaders/testes de avatar)
- Item 3 (spec de Fabio: personagem com CAMISA, SHORTS, PELE, CABELO, CHUTEIRA e MEIA): uniforme com separacao real das 6 regioes - camisa/shorts/meia/chuteira/pele via region mask por bone weights (vertex colors em runtime) + shader de uniforme (pele com tom correto so na regiao de pele; a textura base do UBC Standard e corpo sem roupa - o uniforme e nosso, procedural); CABELO via assets reais do pack (`quaternius_ubc/hair/`, variante Rigged to Head Bone, 8 penteados) anexado ao bone Head, com selecao de penteado + cor de cabelo na intro junto de pele/kit; bot com penteado proprio.
- Item 2: toon outline quebrado (segundo corpo em T-pose) - trocar inverted-hull por next_pass com grow (acompanha skinning).
- Item 4: re-autorar o chute com amplitude realista (pe na altura do joelho/quadril, nao da cabeca) + ease; revisar blends/timings das transicoes.

**Track 04B2 - Feel & UI Fixes** (thread 2: controller/root/HUD/menu)
- Item 5a: dash com curva de aceleracao (ease-out), nao velocity constante "teleporte"; mesma distancia total; juice leve (FOV/trail) - paridade bot.
- Item 5b: pulo e pulo duplo PURAMENTE verticais sem input direcional; com input, combinam vertical+horizontal. Remover fallback forward.
- Item 6: menu de fim de jogo inerte - liberar mouse (MOUSE_MODE_VISIBLE) ao abrir o result panel + teste de clique real nos botoes do result (TERCEIRA falha de UI: o teste da 03I cobriu so o menu principal; agora todo painel interativo ganha teste).
- Item 1: fundo preto da tela inicial - investigar camera do preview pos-03L (provavelmente dentro do vidro que agora sobe ate o teto); recompor enquadramento; teste anti-tela-preta (luminancia media do screenshot > threshold).
- Item 7 (registrado): modos de jogo aguardam SESSAO DE DESIGN de Fabio antes de qualquer implementacao - Fase 2 suspensa ate la.

## Fase 0 - Web Foundation (apos a 0R; 2 tracks em paralelo)

**Track 04A - Web Export Spike & Render Profile** (thread Codex 1)
- Exportar o jogo ATUAL para Web (preset Web, templates 4.6.2), rodar em Chrome e Firefox local.
- Inventario do que quebra/diverge: glow, SSAO, fog, shaders inline (pitch/net/crowd/bola), SubViewports (placares/preview), audio (autoplay policy - exigir interacao), save user:// (IndexedDB), threads OFF por padrao.
- Criar perfil de render por plataforma: `RenderProfile` (desktop=Forward+ atual; web=Compatibility com fallbacks tunados - emissivos mais fortes no lugar de glow fraco, AO fake se SSAO indisponivel). Toggles centralizados, zero fork de codigo de gameplay.
- Gate de fechamento permanente novo: build web + boot smoke + screenshot web em toda track a partir daqui.
- Aceite: jogo roda 60fps em 1080p no Chrome local com visual "reconhecivelmente o mesmo"; relatorio de paridade visual desktop vs web com screenshots lado a lado para decisao de Fabio.

**Track 04B - Process & Polish Zero** (thread Codex 2, arquivos disjuntos da 04A)
- Aplicar a 03J (Quality Gates no AGENTS) - ja especificada no addendum.
- Fixes registrados: histerese da defesa aerea (L1), tint do kit legivel no torso (decisao de cor com screenshot antes/depois), enquadramento do preview do menu.
- + LISTA DE PLAYTEST DE FABIO (a fornecer): itens objetivos entram aqui; subjetivos viram decisoes registradas.

## Fase 1 - Gameplay Power-Up (2 trilhos paralelos)

**Track 04C - Game Feel Pass** (thread 1: gameplay/)
- Itens de feel da lista de Fabio + candidatos: peso/inercia do personagem, kick assist refinado, camera (distancia/FOV/lag tunaveis), juice adicional de gol/defesa, tuning de dash/stun com os valores do playtest.
- Tudo em constantes; antes->depois registrado; paridade de bot; palavra final de Fabio por playtest.

**Track 04D - Bot Inteligente V2** (thread 2: gameplay/football/football_bot.gd + testes)
- Posicionamento com nocao de "minha metade" (recuo quando perde a bola), antecipacao de rebote nas paredes selees, uso tatico de super (guardar para chance clara), erros humanizados no easy (nao so mira - hesitacao), e dificuldade `lenda` para veteranos.
- Aceite por cenarios de teste deterministicos + sessao de playtest dedicada.

## Fase 2 - Copa & Modos (espinha de conteudo; 3 tracks, paralelismo parcial)

**Track 04E - Tournament Core** (thread 1: gameplay/tournament/ NOVO - puro, testavel)
- Estado do torneio de 8 selecoes (bracket, seeds, avanco, campeao), save/load JSON v1 (`user://copa_save.json`), regras de fase (quartas=3min, semi=3min, final=5min golden goal?). Zero UI nesta track.

**Track 04F - Tournament Flow & UI** (thread 1 apos 04E; REGIME DE UI completo)
- Tela de chaveamento (bracket visual com kits/bandeiras), fluxo menu->copa->partida->resultado->proxima fase->campeao, continuar campanha salva, celebracao final.
- Review PRE-merge (Claude + screenshots para Fabio) em todas as telas novas.

**Track 04G - Modos & Variedade** (thread 2: paralela a 04E/04F, arquivos disjuntos)
- Menu de modos: `Copa` (principal), `Amistoso` (1x1 atual configuravel: gols/tempo/dificuldade), `Treino` (sem bot ou bot passivo, reset rapido de bola), `Golden Goal` (mata-mata instantaneo).
- Mutators opt-in no Amistoso (bola rapida, gravidade baixa, partida relampago) - toggles isolados, default OFF, modo padrao intocado.

## Fase 3 - App Shell (o "app robusto"; 2 tracks)

**Track 04H - Menu & Options de verdade** (REGIME DE UI)
- Title screen com identidade (logo Copa Arena, animacao de entrada), navegacao completa (Jogar/Modos/Opcoes/Creditos/Sair), Opcoes: video (qualidade/resolucao/fullscreen/vsync), audio (4 sliders existentes + mute), controles (remapeamento de teclas via InputMap), acessibilidade basica (tamanho de HUD, daltonismo nos kits?), idioma PT/EN se Fabio quiser.
- Persistencia de settings (`user://settings.cfg`), aplicada no boot.
- Creditos OBRIGATORIOS: atribuicoes Quaternius/Kenney/Pixabay (CC-BY do crowd exige; CC0 por cortesia).

**Track 04I - Robustez de App**
- Pause solido em qualquer estado, foco/perda de foco do browser (auto-pause), resize/fullscreen web, loading screen com progresso, tratamento de erro de save corrompido, versao visivel (vX.Y.Z + build), boot rapido.

## Fase 4 - Release (2 tracks + voce)

**Track 04J - Web Release Candidate**
- Otimizacao do build web (tamanho do pck, compressao, texturas), QA cross-browser (Chrome/Firefox/Edge; Safari best-effort), checklist de release, RC numerado.
- Playtest RC de Fabio + 2-3 pessoas externas (primeiro feedback de fora!).

**Track 04K - Publicacao**
- itch.io: pagina (capsule images dos nossos screenshots, texto, devlog inicial), upload do build web com COOP/COEP flag, link publico ou restrito (decisao de Fabio).
- Site proprio (opcional, em paralelo): Cloudflare Pages (o estudio ja usa no draxos-mobile) com o build web embarcado + pagina simples.
- Pos-publicacao: changelog, processo de hotfix-release (track curta -> build -> re-upload).

## Regras de paralelismo multiagente

1. Maximo 2 threads Codex simultaneas, SEMPRE em worktrees distintas com conjuntos de arquivos DISJUNTOS (declarados no card de cada track; sobreposicao detectada = uma thread espera).
2. Merge em main e SEQUENCIAL: thread termina -> Claude verifica worktree (ritual) -> review -> merge -> proxima. Nunca dois merges sem review entre eles.
3. Claude orquestra: prompts prontos para as duas threads, reviews (pre-merge em UI/visual), integracao e atualizacao deste plano (Progress por track).
4. Rituais valem dobrado em paralelo: WORKTREE_VERIFIED, sem git clean, espera 15-30s, import headless em worktree nova.
5. Gate web: da 04A em diante, toda track fecha com build web smoke + screenshot web junto da evidencia desktop.

## Sequencia e dependencias

```
Fase 0:  04A (web spike) ║ 04B (process+polish zero)     <- paralelas
Fase 1:  04C (feel)      ║ 04D (bot v2)                  <- paralelas
Fase 2:  04E -> 04F (copa core -> copa UI) ║ 04G (modos) <- 04G paralela a ambas
Fase 3:  04H (menu/options) -> 04I (robustez)            <- 04I depois (toca o shell)
Fase 4:  04J (RC) -> 04K (publicacao)                    <- sequenciais
```

Estimativa: 11 tracks. No ritmo atual do estudio (series 02+03 = 19 tracks em ~2 dias), com paralelismo: **3-5 dias de trabalho focado** ate o RC, mais o ciclo de feedback externo.

## Gates humanos (Fabio)

- Fim da Fase 0: aprovar paridade visual web (screenshots lado a lado).
- Fim da Fase 1: playtest de feel - "o jogo esta gostoso?" e o gate; sem ele nao adianta conteudo.
- Fim da Fase 2: jogar uma Copa inteira do inicio ao campeao.
- Fase 4: aprovar a pagina/site e apertar o botao de publicar.

## Fora de escopo (registrado)

- Multiplayer online/local, mobile/touch, monetizacao, backend/contas, leaderboards online. Qualquer um destes e serie propria futura, pos-release.
