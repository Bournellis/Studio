# JogoDaCopa - Serie 06: Match Polish & Broadcast Identity (v1.1.0)

- Date: `2026-06-12`
- Author: Claude (decisoes de Fabio: visual Broadcast de Copa; ESC com tela cheia + volumes + qualidade real + sensibilidade; publicacao unica v1.1.0 ao final)
- Baseline: v1.0.3 publicada e estavel (freezes residuais inconstantes aceitos por Fabio)

## Direcao

Transformar a apresentacao de "prototipo funcional" em "transmissao de Copa": scorebug de TV, tipografia esportiva, dourado de trofeu sobre o neon noturno da arena. Zero mudanca de gameplay; bugs de inicio corrigidos; informacao de controles sai da tela de jogo e vive num ESC completo.

## Pre-requisito de assets (Fabio, antes da 06C/06D)

Baixar **Kenney Fonts** (kenney.nl/assets/kenney-fonts, CC0) e colocar em `assets/fonts/kenney/`. Sao as fontes da identidade broadcast (candidatas: Kenney Future / Future Narrow para numeros e titulos). Registrar em `docs/asset-licenses.md` na track que as usar. Sem download por agente.

## Track 06A - Match Start Fixes V1 (sequencial, primeira)

1. **Facing inicial**: ambos os avatares iniciam olhando para o oponente (player de costas para a camera). Aplicar yaw inicial correto no spawn/reset usando o sistema de visual facing existente. Teste: angulo entre o forward visual de cada avatar e a direcao ao oponente abaixo de tolerancia no primeiro frame jogavel - para player e bot, em kickoff inicial E pos-gol.
2. **Countdown duplo**: test-first obrigatorio - teste vermelho contando disparos do countdown por kickoff (esperado: exatamente 1). Root cause documentada antes do fix (suspeita: _restart_play disparado 2x no boot - ready + caminho de kickoff/capture; confirmar medindo, nao assumir).
3. **Hints fora da partida**: remover a faixa flutuante de explicacao de botoes do HUD em jogo. Conteudo migra para o painel Controles do ESC (06B); ate la, mantida em constante/recurso para a 06B consumir. Teste: HUD montado nao contem o nodo de hints.
4. **Remover o crosshair** (pedido de Fabio): o marcador de mira sai do HUD. A mira FUNCIONAL continua sendo o centro da camera + kick assist (zero mudanca de gameplay); apenas o desenho some, como em Rocket League. Teste: HUD montado nao contem o nodo de crosshair. Nota registrada: se a sensacao de mira piorar no playtest sem o marcador, reavaliar com um indicador sutil so durante carregamento de chute (decisao reversivel barata).
- Area: football_root/avatar (spawn), football_hud (hints/crosshair). Validate + build web + luminancia.

Resultado 06A (Codex, `2026-06-13`):

- Causa raiz do countdown duplo: `_ready_sync()` e `_ready_web_async()` chamavam `_restart_play(false)` no boot/warmup enquanto `intro_open == false`; isso iniciava o countdown antes do jogador apertar `Comecar`, e `_start_match()` iniciava outro countdown. O teste vermelho mediu `2` disparos no kickoff inicial e `1` no pos-gol antes do fix.
- Fix: boot e warmup agora usam `_restart_play(false, false)`, deixando `_start_match()` como unico disparo do countdown inicial; resets pos-gol continuam disparando countdown uma vez.
- Facing: o reset de kickoff aplica snap visual imediato para player e bot olharem para o oponente sem alterar yaw logico, camera, mira, kick assist, chute ou fisica.
- HUD: `HintLabel` e `FootballCrosshair` sairam da tela de jogo; a tabela de comandos ficou em `FootballHud.CONTROL_HINTS`/`get_control_hints()` para a Track 06B consumir no ESC.
- Nota reversivel mantida: se o playtest sentir falta de mira visual, reavaliar indicador sutil apenas durante carregamento de chute.
- Evidencia: `docs/playtest-reports/track-06a-match-start-fixes.md`, `docs/screenshots/track-06a/`, `docs/playtest-reports/track-06a-data/06a-web-boot.*`.

## Track 06B - ESC Menu Completo V1 (sequencial, apos 06A)

Estrutura do ESC (pause):

- `Continuar`
- `Reiniciar partida`
- `Controles` - tabela completa dos comandos (conteudo migrado da 06A), legivel, 2 colunas acao/tecla
- `Audio` - sliders Master / SFX / UI / Ambiente (reorganiza os existentes; persistencia em user://)
- `Video` - **Tela cheia** (toggle; web via canvas fullscreen do Godot, desktop via window mode; estado persiste) e **Qualidade real** `Alta`/`Leve` ligada ao RenderProfile (Leve = base das constantes WEB_* com menos particulas/glow reduzido/viewports menores; disponivel tambem no desktop; troca aplica na hora quando seguro ou com aviso de reinicio de partida - decidir tecnicamente e documentar)
- `Sensibilidade do mouse` - slider persistido aplicado a camera/mira
- `Sair para o menu`

Extras: o dropdown `Qualidade` decorativo do menu principal passa a funcionar de verdade (mesma fonte de config); ESC abre/fecha com o proprio ESC; mouse liberado; foco inicial em Continuar.
REGIME DE UI COMPLETO: teste de clique real em TODOS os controles em 1920x1080/1366x768/1280x720 + screenshots; persistencia testada (salvar -> recarregar cena -> valores mantidos).
- Area: football_hud/pause + autoload de settings (novo, pequeno, com testes proprios).

## Track 06C - Menu Principal Broadcast V1 (paralela com 06D apos 06B)

- Painel do menu vira **match card de transmissao**: header com faixa de Copa (gradiente + detalhe dourado), tipografia Kenney para titulo/numeros, secoes claras (partida/aparencia/audio-video), botao `Jogar Futebol 1x1` como CTA dominante, bandeiras/kits com mais presenca, rodape com versao (mantido).
- Hero shot 3D aprovado permanece; o upgrade e moldura/painel/tipografia/hierarquia.
- Tudo Control nodes + fonte CC0; zero luz nova; budget web respeitado.
- AREA EXCLUSIVA: modes/menu/* + tests/unit/test_menu_visual.gd (NOVO - nao tocar test_bootstrap).
- Evidencia: screenshots 3 resolucoes + clique real de todos os controles.

## Track 06D - HUD Broadcast V1 (paralela com 06C)

- **Scorebug de TV** no canto superior: codigos/bandeiras dos paises, placar grande, timer - substitui o placar atual; pulso/escala no gol; estados timer/golden goal/vale-2 com selos proprios.
- **Anunciador** central retrabalhado com a tipografia esportiva (GOOOL!, ULTIMO MINUTO!, GOLDEN GOAL!).
- Barras de **stamina/SUPER** com molduras e iconografia do tema; indicador de super pronto com brilho dourado.
- **Countdown visual** novo (3-2-1 com punch/escala) - integra com o fix do countdown unico da 06A.
- Tudo procedural/Control nodes/fonte CC0.
- AREA EXCLUSIVA: presentation/hud/* + tests/unit/test_hud_visual.gd (NOVO).
- Evidencia: screenshots em jogo (kickoff/gol/super/result) 3 resolucoes + clique real onde houver botao.

## Track 06E - Release v1.1.0 (sequencial, final)

- Bump `v1.1.0`, changelog no release-history, FullPublish `-ConfirmRemoteMutation`, gates remotos completos (primeiro minuto + estabilidade 5min + luminancia), smoke humano de Fabio + tester externo.

## Regras da serie

- Ordem: 06A -> 06B -> (06C ║ 06D) -> 06E. Paralelas com areas e arquivos de teste DISJUNTOS (licao 04C/04D).
- Todos os gates permanentes valem em toda track: validate, build web + boot smoke + screenshot, luminancia; gates longos (primeiro minuto/5min) na 06E.
- Iteracao com gate curto; gates longos so em validacao final; checkpoint a cada 10 iteracoes sem verde.
- Sem republicacao antes da 06E (decisao de Fabio).
- Fontes: somente CC0/OFL com registro em asset-licenses.md.
