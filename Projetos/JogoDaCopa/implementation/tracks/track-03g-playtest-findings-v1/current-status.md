# Track 03G - Playtest Findings V1

- Date: `2026-06-10`
- Branch: `codex/jogodacopa/track03g-playtest-findings-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03g-playtest-findings-v1`
- Status: `COMPLETE`
- Source: primeiro playtest humano completo de Fabio

## Goal

Corrigir os 6 achados fechados do primeiro playtest humano completo, sem reabrir decisoes de design e preservando fisica base da bola, contratos de tap/RMB e paridade de bot.

## Findings Fixed

- Finding 1: menu principal deixou o painel fixo `560x720`; agora usa safe area, `ScrollContainer`, `CenterContainer` e painel sem altura fixa. Teste estrutural cobre fit dos controles principais em 1920x1080, 1366x768 e 1280x720.
- Finding 2: selecao de pele/camisa foi removida do menu principal. Aparencia fica somente no painel de intro pre-kickoff e persiste entre rematches da mesma sessao.
- Finding 3: dash ficou claramente acima do boost. Player `ARCADE_DASH_SPEED` `14.0 -> 20.75`, `ARCADE_DASH_DURATION` `0.22 -> 0.28`; bot `13.4 -> 20.75`, `0.22 -> 0.28`. Custo de stamina/cooldown preservados. O valor final fica >= 1.5x a corrida boostada do player (`8.8 * 1.56`).
- Finding 4: kickoff do player ativa hold defensivo do bot na linha bola->gol a 65% da distancia, sem perseguir ate o primeiro toque. Apos toque, hold libera. Defesa aerea detecta bola >2m indo ao gol, usa delay por dificuldade (`easy` 0.5s, `normal` 0.18s, `hard` 0.03s), recua para linha do gol e tenta jump/flip.
- Finding 5: camera ganhou raycast clamp de colisao entre foco e posicao desejada; spawn do player em kickoff do bot saiu do fundo do gol para nascer com camera livre.
- Finding 6: reset da bola agora usa teleport seguro em `RigidBody3D` com `freeze`, estados do `PhysicsServer3D`, velocidades zeradas e unfreeze deferred. O kickoff tambem mostra marcador circular/glow no ponto real da bola e anunciador `SAIDA PLAYER/BOT`.

## Finding 6 Root Cause

A investigacao confirmou dois fatores contribuintes no codigo:

- `FootballBall3D.configure()` chamava `reset_to_center()` diretamente em um `RigidBody3D` ativo durante `_restart_play`, alterando `global_position`/velocidades no mesmo fluxo em que a fisica podia ainda ter estado pendente. Isso podia deixar um frame visual/fisico incoerente apos reset.
- A bola nao volta ao centro absoluto durante kickoff: por design ela alterna entre `z = +9m` e `z = -9m` conforme a posse. Sem marcador/anuncio, essa alternancia podia parecer um reset fora de lugar.

Fix aplicado: teleport seguro do rigidbody e marcador/anunciador de kickoff. A fisica base da bola (massa, bounce, drag, limites) nao foi alterada.

## Validation Log

- `tools/validate.gd`: PASS, 56 tests, 505 asserts.
- Source integrity: PASS, 26 `.gd/.gdshader` files loaded outside `addons/`.
- Performance sample: PASS, windowed 1920x1080, vsync off, display `Windows`, average `719.3fps`, min warmed instant `462.3fps`, `0/360` frames below 60.
- Known validation noise: GUT UID/text-path warnings ao carregar testes.

## Delivery

- Register commit: `51e3e08 docs: register track 03g playtest findings`
- Fix commit: `b3ea16a fix: address track 03g playtest findings`
- Next step: playtest de confirmacao dos 6 fixes.
