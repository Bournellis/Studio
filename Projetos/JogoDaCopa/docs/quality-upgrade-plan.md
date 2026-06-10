# JogoDaCopa - Analise e Plano de Upgrade de Qualidade (Serie Track 02)

- Date: `2026-06-10`
- Author: Claude (analise solicitada por Fabio)
- Decision baseline: caminho **hibrido** aprovado por Fabio (arena/VFX procedural + assets CC0 apenas para personagem animado e bola), escopo **plano completo** (visual + game feel + bot + menu + identidade).
- Esta decisao autoriza explicitamente a primeira track de authored assets prevista em `architecture-overview.md`.

## Progress

- `2026-06-10` - `Track 02A Render & Lighting Foundation V1`: `COMPLETE` (`JOGO_DA_COPA_TRACK_02A_RENDER_LIGHTING_FOUNDATION_V1_COMPLETE`). `tools/validate.gd` PASS (24 tests, 219 asserts). Performance sample Windows/Forward+ after warmup: average `143.9fps`, min warmed instant `63.6fps`, `0/360` frames below 60.
- `2026-06-10` - `Track 02B Pitch & Arena Material Pass V1`: `COMPLETE` (`JOGO_DA_COPA_TRACK_02B_PITCH_ARENA_MATERIAL_PASS_V1_COMPLETE`). `tools/validate.gd` PASS (24 tests, 230 asserts).
- `2026-06-10` - `Track 02C Ball & Character Assets V1`: `COMPLETE` (`JOGO_DA_COPA_TRACK_02C_BALL_CHARACTER_ASSETS_V1_COMPLETE`). Asset import spike PASS. `tools/validate.gd` PASS (24 tests, 240 asserts). Licenses recorded in `docs/asset-licenses.md`.
- `Track 02D VFX & Game Feel V1`: next.

## 1. Analise do Estado Atual

### Pontos fortes (preservar)

- Arquitetura modular limpa: `modes/football/` (montagem/regras), `gameplay/football/` (bola/bot), `presentation/` (camera/HUD/feedback). Tudo testavel e coberto por GUT (24 tests, 198 asserts).
- `FootballFieldBuilder` e config-driven: dimensoes de campo/gol vem de dictionary, facil de re-tunar.
- Feel aprovado nas Tracks 01A-01C: bola arcade solta, kick assist, boost/stamina, camera chase, gols com teto e regra de altura.
- Bot funcional com state machine legivel (kickoff/chase/attack/defend/windup/recover/celebrate).

### Fraquezas visuais (causa do "mal acabado")

1. **Ambiente e luz** (`football_root.gd:_configure_world`): background e cor solida, ambient light flat de alta energia, apenas 1 DirectionalLight + 1 OmniLight. Sem sky, sem tonemap configurado, sem glow/bloom, sem SSAO, sem fog. E o maior responsavel pelo look "cru": qualquer primitiva parece placeholder sob luz flat.
2. **Pos-processamento ausente** (`project.godot`): so MSAA 2x + FXAA. O look Rocket League depende fortemente de bloom sobre superficies emissivas.
3. **Materiais flat**: tudo e `StandardMaterial3D` com albedo de cor unica. Grama sem textura, listras e linhas do campo sao caixas finas flutuando sobre o pitch (risco de z-fighting e leitura de "lego"). Vidro e albedo translucido sem fresnel/reflexo.
4. **Bola generica** (`football_ball.gd`): SphereMesh branca com emissao azul fraca. Sem padrao de futebol, sem trail, sem efeito de contato.
5. **Avatar caixote** (`player_avatar_3d.gd`): partes em caixas com animacao por pivot. Cumpriu o papel de prototipo, mas e o elemento que mais grita "inacabado" em terceira pessoa, ja que ocupa o centro da tela.
6. **Estadio decorativo estatico**: arquibancada/torcida sao blocos de cor, placares sao decorativos (nao mostram o placar real), banners sem texto legivel.
7. **Feedback sintetico**: `fps_feedback_controller.gd` usa primitivas transientes e audio gerado. Sem particulas de gol, sem stinger, sem crowd.
8. **HUD/menu utilitarios**: sem identidade visual.

### Fraquezas de game feel e conteudo

- Sem countdown de kickoff, sem slow-mo/replay de gol, sem camera shake ou FOV kick no boost.
- Bot nao antecipa a bola (mira posicao atual) e tem dificuldade unica.
- Sem tela de resultado pos-partida com rematch.
- Sem identidade de produto (nome final, icone, export).

## 2. Direcao Visual Alvo

"Arena de Copa festiva a noite": estadio noturno, luz de torres + bloom, arena de vidro com frames emissivos, grama saturada com listras via shader, cores de paises vibrantes. Estilizado e limpo (nao fotorrealista), com o juice de arena do Rocket League e o clima festivo de Copa que ja e a identidade do projeto.

## 3. Plano - Serie Track 02

Ordem pensada por impacto/custo: 02A muda a imagem inteira de uma vez; 02C e a track de maior risco (assets) e vem depois da fundacao de luz para que o asset ja caia bonito.

### Track 02A - Render & Lighting Foundation V1

Objetivo: transformar a imagem global sem tocar geometria.

- `WorldEnvironment` completo: sky procedural noturno (gradiente + estrelas), tonemap `ACES`, `glow` habilitado (HDR threshold tunado para emissivos), `SSAO` leve, fog sutil de profundidade, ambient via sky com energia reduzida.
- Rig de luz de estadio: key DirectionalLight fria + 4 SpotLight3D nas posicoes dos light rigs existentes (luz quente, sombras apenas na key para custo).
- `project.godot`: MSAA 4x, sombras com qualidade/distancia tunadas.
- Pass de materiais existentes: roughness/metallic coerentes, frames do vidro e da arena com `emission` (neon) para o glow trabalhar, vidro com fresnel via `rim` ou shader simples.
- Criterio de aceite: screenshot do campo central mostra profundidade (sombras direcionais, bloom nos frames, ceu visivel atraves do vidro); validate.gd PASS.
- Risco: custo de SSAO/glow no editor — manter toggles em constantes.

### Track 02B - Pitch & Arena Material Pass V1

Objetivo: acabar com a leitura "lego" do campo e da arena.

- Grama: um unico mesh de pitch com ShaderMaterial (listras + variacao de noise + linhas do campo desenhadas no shader ou via `Decal`). Remove as ~40 caixas de stripes/linhas do `FootballFieldBuilder`.
- Gols: rede via shader translucido com grid (substitui o NetTint solido), frames emissivos.
- Torcida: blocos de arquibancada com shader de variacao de cor por celula + flutuacao senoidal sutil (impressao de movimento), bandeiras com Label3D para nomes de paises.
- Placares funcionais: SubViewport com o placar real da partida nas posicoes dos scoreboards decorativos.
- Criterio de aceite: zero z-fighting nas linhas; placar do estadio reflete `score_state`; testes de builder atualizados.

### Track 02C - Ball & Character Assets V1 (track de authored assets - APROVADA)

Objetivo: substituir os dois elementos onde primitiva nao convence.

- Bola: modelo/textura de futebol CC0 (ou textura de gomos gerada por script para evitar binario), trail (GPUParticles3D ou MeshInstance ribbon) ativado acima de velocidade X, squash sutil no impacto.
- Personagem: 1 modelo humanoide low-poly CC0 (Quaternius/Kenney, licenca registrada em `docs/asset-licenses.md`) com esqueleto + animacoes idle/run/kick/celebrate via `AnimationTree`.
- Preservar contrato atual: `apply_appearance` continua aplicando skin tone + kit por material override; `play_kick/play_celebrate/set_move_state` mantem assinatura para nao quebrar `football_root` nem testes de avatar.
- Bot usa o mesmo modelo com kit diferente.
- Criterio de aceite: avatar anda/corre/chuta com blend de animacao; selecao de pais continua funcionando; testes de avatar adaptados PASS.
- Risco: retargeting/escala do asset e o maior risco da serie — fazer spike de 1 asset antes de comprometer a track.

### Track 02D - VFX & Game Feel V1

Objetivo: o "juice" Rocket League.

- Particulas: explosao de gol (burst colorido com cores do kit), faisca no chute forte, trail de boost no jogador, poeira de freada.
- Camera: shake curto em chute forte/gol, FOV kick durante boost, leve tilt em curva.
- Fluxo de gol: slow-mo de 0.4s no momento do gol + zoom da camera na bola, stinger de audio, buzina de torcida.
- Kickoff: countdown 3-2-1 com HUD e travamento de input.
- Audio: substituir feedback sintetico por SFX (chute, quique, vidro, crowd loop ambiente, apito) — CC0, mesmos creditos em `asset-licenses.md`.
- Criterio de aceite: gol e inconfundivel de olhos fechados (audio) e de longe (VFX); sem regressao de feel nos contratos de chute.

### Track 02E - HUD & Menu Polish V1

Objetivo: identidade visual de produto nas superficies 2D.

- HUD: placar estilo broadcast (bandeiras/cores dos kits), timer/best-of, stamina integrada ao tema, indicador off-screen da bola.
- Menu: titulo com a arena 3D ao fundo (camera orbitando), botao Play, seletor visual de kit/skin (preview do avatar), settings minimos (volume, qualidade).
- Tela de fim de partida: resultado, placar final, rematch/menu.
- Criterio de aceite: fluxo menu -> partida -> resultado -> rematch sem tela utilitaria.

### Track 02F - Bot & Match Flow V1

Objetivo: partida mais inteligente e completa.

- Bot: predicao simples da posicao futura da bola (velocity * t), recuo defensivo posicionado entre bola e gol, uso de boost, 3 dificuldades (velocidade/erro de mira/cooldown).
- Regras: melhor-de-N opcional, overtime golden goal em empate de tempo (se timer for adotado), kickoff alternado.
- Criterio de aceite: bot dificil vence jogador casual; bot facil perde; contratos de bot atualizados PASS.

### Track 02G - Identidade de Produto V1

Objetivo: primeiro export apresentavel.

- Nome final do modulo, icone, splash, export preset Windows, smoke test do build.
- `publication-readiness.md` atualizado.

## 4. Sequencia e Dependencias

- `02A -> 02B -> 02C` (fundacao de imagem antes dos assets).
- `02D` depende de 02A (particulas precisam do glow). Pode rodar em paralelo com 02C se em worktrees separadas.
- `02E` e `02F` independentes entre si, apos 02D.
- `02G` por ultimo.
- Cada track: worktree dedicada `D:\Estudio-worktrees\JogoDaCopa--codex--track02x-...`, branch `codex/jogodacopa/track02x-<slug>`, registro em Kanban/Doing, validate.gd PASS antes de handoff.

## 5. Riscos Gerais

- **Assets (02C)**: licenca deve ser CC0/CC-BY documentada; fazer spike de import antes da track inteira.
- **Performance**: glow + SSAO + particulas no Forward+ devem manter 60fps em editor; medir apos 02A e 02D.
- **Scene generator**: assets entram via instanciacao em runtime (mesmo padrao atual), sem hand-edit de .tscn gerado — regra do AGENTS.md preservada.
- **Escopo**: nada de multiplayer/backend/mobile nesta serie.
