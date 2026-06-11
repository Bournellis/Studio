# JogoDaCopa - Plano Arcade (Serie Track 03)

- Date: `2026-06-10`
- Author: Claude (aprovado por Fabio)
- Decisao: pacotes A (movimento), C (super shot), B (campo), D (tempero de partida) aprovados; E (toon look) aprovado como experimento atras de toggle. Power-ups classicos de campo ficam explicitamente fora (mudariam a identidade para party game; possivel modo separado futuro).
- Baseline: serie Track 02 + hotfix 02H completa (`JOGO_DA_COPA_TRACK_02H_QUALITY_HOTFIX_V1_COMPLETE`, 30 tests/289 asserts). 02C-bis (personagem) e 02D-bis (audio) seguem pendentes de download manual de assets por Fabio e nao bloqueiam esta serie.

## Progress

- `2026-06-10` - `Track 03A Arcade Movement & Actions V1`: `COMPLETE` (`JOGO_DA_COPA_TRACK_03A_ARCADE_MOVEMENT_ACTIONS_V1_COMPLETE`). `tools/validate.gd` PASS (33 tests, 316 asserts). Performance sample Windows/Forward+: average `1275.8fps`, min warmed instant `787.4fps`, `0/360` frames below 60.
- `2026-06-10` - `Track 03C Super Shot & Fireball V1`: `COMPLETE` (`JOGO_DA_COPA_TRACK_03C_SUPER_SHOT_FIREBALL_V1_COMPLETE`). `tools/validate.gd` PASS (36 tests, 333 asserts).
- `2026-06-10` - `Track 03B Arcade Field V1`: `COMPLETE` (`JOGO_DA_COPA_TRACK_03B_ARCADE_FIELD_V1_COMPLETE`). `tools/validate.gd` PASS (39 tests, 358 asserts). Performance sample Windows/Forward+: average `1097.6fps`, min warmed instant `607.2fps`, `0/360` frames below 60.
- `2026-06-10` - `Track 03D Arcade Match Flavor V1`: `COMPLETE` (`JOGO_DA_COPA_TRACK_03D_ARCADE_MATCH_FLAVOR_V1_COMPLETE`). `tools/validate.gd` PASS (45 tests, 403 asserts).
- `2026-06-10` - `Track 03E Toon Look Experiment V1`: `COMPLETE` (`JOGO_DA_COPA_TRACK_03E_TOON_LOOK_EXPERIMENT_V1_COMPLETE`). Toggle `RENDER_TOON_ENABLED` default OFF. `tools/validate.gd` PASS (46 tests, 426 asserts). Screenshots comparativos: `docs/screenshots/track-03e-toon/track-03e-toon-off.png` e `docs/screenshots/track-03e-toon/track-03e-toon-on.png`.
- `2026-06-10` - `Track 03F Quality Hotfix V1`: `COMPLETE` (`JOGO_DA_COPA_TRACK_03F_QUALITY_HOTFIX_V1_COMPLETE`). SUPER nao e mais consumido em whiff, avatar real preserva texturas PBR ao receber tint, sampler registra janela/resolucao/modo e `validate.gd` checa integridade de fontes. `tools/validate.gd` PASS (50 tests, 466 asserts). Performance sample windowed 1920x1080/vsync off: average `730.8fps`, min warmed instant `488.8fps`, `0/360` frames below 60. As medicoes 03A/03B (`1097-1275fps`) ficam como sanity checks sem baseline representativa.
- `2026-06-10` - `Track 03G Playtest Findings V1`: `COMPLETE` (`JOGO_DA_COPA_TRACK_03G_PLAYTEST_FINDINGS_V1_COMPLETE`). Seis achados do primeiro playtest humano corrigidos: menu responsivo, aparencia somente na intro, dash tunado/paridade bot, kickoff defensivo + defesa aerea, camera segura no kickoff do bot e reset seguro/marcador de kickoff. `tools/validate.gd` PASS (56 tests, 505 asserts). Performance sample windowed 1920x1080/vsync off: average `719.3fps`, min warmed instant `462.3fps`, `0/360` frames below 60.

## Direcao

Transformar o "futebol 1x1 com fisica" em "futebol de arena arcade": acoes de personagem com risco/recompensa (dash, flip, super), campo que convida a jogadas (pads, rampas) e partida com climax garantido (timer curto, golden goal, anunciador). Referencias: Rocket League (movimento/arena), Mario Strikers (super shot/provocacao). Tudo procedural - nenhum asset externo nesta serie.

## Regras da serie

- Paridade de bot obrigatoria: toda acao nova do player tem resposta ou uso equivalente pelo bot na mesma track. Mecanica sem paridade nao e aceita.
- Caminho de forca unico: qualquer impulso novo na bola passa por `FootballBall3D.kick()`; fisica base da bola (massa/bounce/drag/limites) intocada.
- Contratos preservados: tap LMB e RMB atuais continuam com a mesma forca/lift (testes de regressao explicitos).
- Novas input actions registradas via `autoloads/app_bootstrap.gd` (regra de ownership existente).
- Tuning em constantes nomeadas no topo dos arquivos; nada de numero magico inline.
- Jump pads: mecanica generica de arcade adotada localmente por este documento (nao e import do FpsPlayground; implementacao propria).

## Track 03A - Arcade Movement & Actions V1

Nucleo do feel. Implementar primeiro: todo o resto fica mais divertido em cima.

- **Dash**: nova action (sugestao: `Ctrl`/`E`). Impulso horizontal forte (~14 m/s) por ~0.22s, cooldown ~1.6s, custo de stamina (~20). Indicador de cooldown no HUD.
- **Carrinho**: dash no chao com bola a alcance vira slide - rouba a bola (kick fraco na direcao do movimento via `kick()`) e aplica knockback + stun (~0.5s) no bot em contato (reusar knockback da base combat; sem dano de vida).
- **Ombrada**: dash em contato com o bot sem bola = empurrao mutuo com knockback menor, sem stun.
- **Double jump/flip**: segundo `Space` no ar = impulso vertical reduzido + horizontal na direcao do input; 1 por airtime, reset ao pousar. Abre jogo aereo com as paredes/teto existentes.
- **Bot**: dash defensivo quando a bola ameaca o gol fora de alcance; flip em bolas altas; sofre e aplica stun pelos mesmos caminhos. Dificuldade modula cooldown/uso.
- Avatar: poses de slide/flip via sistema de pivos atual.
- Aceite: regressao de chutes PASS; testes novos de cooldown/stun/reset de flip/uso de dash pelo bot; validate PASS.
- Risco: stun frustrante - manter curto e em constante; knockback exagerado - clamp.

## Track 03C - Super Shot & Fireball V1

- **Chute carregado**: segurar LMB carrega (~0.8s, medidor no HUD), soltar chuta com forca lerp 1.0x->1.55x e lift proporcional leve. Tap (<0.15s) = chute normal identico ao atual (regressao garantida).
- **Barra de SUPER**: enche por toque na bola (+pequeno) e gol sofrido (+grande, mecanica de comeback). Cheia: proximo RMB = Super Shot (forca/lift maximos + trail de fogo + shake 0.2 + zoom curto), zera a barra, maximo 1 por kickoff (reset em `_restart_play`).
- **Fireball cosmetica**: bola acima de ~24 m/s ganha particulas laranja + boost de emission no shader de gomos (uniform ja existe), com histerese (liga >24, desliga <21).
- **Bot**: acumula e usa super pelos mesmos criterios; `hard` enche mais rapido.
- Aceite: tap LMB inalterado (teste compara forca), super 1x/kickoff, fireball com histerese testada, validate PASS.
- Risco: charged kick mudar o timing do jogador veterano - tap continua sendo o caminho rapido default.

## Track 03B - Arcade Field V1

- **Boost pads**: 6 pequenos (+25 stamina) no meio-campo + 2 grandes (full) nos cantos. `Area3D` + disco neon emissivo (cilindro achatado), respawn 4s com visual apagado, tom sintetico curto na coleta. Posicoes derivadas da config de campo no `FootballFieldBuilder`.
- **Rampas de canto**: quarter-pipe simplificado (2-3 segmentos de caixa inclinada) nas juncoes chao-parede laterais e nos 4 cantos - bola e jogador sobem em vez de bater na quina. Bounce reduzido nas rampas para rolagem.
- **Jump pads** (2, atras de cada gol): aplicam impulso vertical a player/bot (nao a bola), anel pulsante emissivo.
- **Bot**: coleta boost pad ativo quando estiver a raio curto da rota atual (desvio maximo ~2m); sem pathfinding novo.
- Aceite: pads respawnam e aplicam stamina; bola nao prende nas rampas (teste de rebote em cantos); jump pad nao lanca a bola; validate PASS.
- Risco: bola presa em geometria de rampa - colisao por segmento unico convexo, testar os 4 cantos.

## Track 03D - Arcade Match Flavor V1

- **Anunciador visual**: label gigante no HUD com squash/stretch + fade, fila de eventos sem sobreposicao ("GOOOL!", "ULTIMO MINUTO!", "GOLDEN GOAL!", "VALE 2!").
- **Modo timer**: menu escolhe `3 gols` ou `3 minutos` (novo default). Empate no fim do tempo => golden goal (proximo gol vence). Timer MM:SS no HUD piscando nos ultimos 30s.
- **Vale 2**: no modo timer, gol nos ultimos 30s vale 2 pontos; placar pisca dourado.
- **Emote**: tecla `T` pos-gol dispara celebrate + burst de confete procedural + anunciador; bot provoca quando marca.
- Regras de pontuacao/fim estendidas em `football_match_rules.gd` (puro, testavel) - nada de logica de regra solta no root.
- Aceite: golden goal encerra corretamente; vale-2 so nos 30s finais do modo timer; modo 3 gols permanece identico ao atual; testes de regra puros; validate PASS.
- Risco: dois modos de fim - centralizar em match_rules para nao duplicar condicao de match_over.

## Track 03E - Toon Look Experiment V1 (toggle)

- Outline via inverted hull (segundo mesh com cull front) em avatar e bola apenas; cel-shading leve (ramp) nos materiais de avatar/bola; estadio intocado.
- Toggle `RENDER_TOON_ENABLED` (constante) + opcao no menu settings; default OFF.
- Aceite: com toggle OFF o render e identico ao atual; screenshot comparativo ON/OFF gerado para decisao de Fabio no playtest; validate PASS.
- Risco: conflito estetico com o neon noturno - e exatamente o que o experimento decide; descartar e barato (toggle + arquivos isolados).

## Sequencia

`03A -> 03C -> 03B -> 03D -> 03E`. 03A e a fundacao; 03C usa o input/feel de 03A; 03B e 03D sao independentes entre si; 03E por ultimo, descartavel.

## Fora de escopo da serie

- Power-ups de campo (ima, chute gigante etc.) - decisao explicita de identidade.
- Assets externos (personagem/audio reais ficam em 02C-bis/02D-bis quando Fabio baixar os packs).
- Multiplayer/backend/export alem do preset existente; novos modos alem do timer.
