# Track 03L - Arena Seal & Character Facing V2

- Data: `2026-06-11`
- Status: `FIX_VALIDATED`
- Branch: `codex/jogodacopa/track03l-arena-seal-facing-v2`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03l-arena-seal-facing-v2`
- Marker alvo: `JOGO_DA_COPA_TRACK_03L_ARENA_SEAL_FACING_V2_COMPLETE`

## Objetivo

Executar a Track 03L V2, substituindo a 03L anterior nao executada, com quatro entregas fechadas: arena estanque, remocao do rodape/rampas 03B, CCD da bola e facing visual do player pela direcao de movimento.

## Causa Raiz

- O vao perimetral superior vinha desde a 01A: as paredes de vidro usavam `wall_height = 7.2`, mas o teto ficava em `ceiling_height = 8.8`, deixando abertura continua entre `y=7.2` e `y=8.8`.
- O caixote dos gols tinha teto, paredes laterais e vidro de fundo, mas nao tinha painel frontal no plano da linha do gol acima da travessa. Bola alta podia cruzar a linha do gol fora da area valida de gol.
- As rampas de parede/fundo/canto da 03B criavam o rodape lateral. Fabio decidiu voltar a quina chao-parede simples; as funcoes `_add_corner_ramps` e `_add_ramp_box` foram removidas.

## Antes / Depois

Antes:

- `WestGlassWall`, `EastGlassWall`, end walls, goal side walls and back glass paravam em `wall_height`.
- Linha do gol acima da travessa ficava aberta entre as paredes laterais.
- Rodape/rampas de parede, fundo e canto ainda eram gerados pelo builder.
- Bola nao usava CCD.

Depois:

- Paredes de vidro do perimetro e goal shells usam `ceiling_height` como altura efetiva de colisao.
- Frames visuais acompanham a nova altura ate o teto.
- `NorthGoalFrontTopGlass` e `SouthGoalFrontTopGlass` fecham o plano da linha do gol da travessa ate o teto, com frame visual.
- A abertura baixa do gol foi preservada para gol valido; acima da travessa, a bola rebate.
- `FootballBall3D` ativa `continuous_cd = true`, sem alterar massa, bounce, drag ou velocidades.
- Player usa `AvatarParts` para yaw visual por velocidade horizontal; o yaw logico do `CharacterBody3D` segue controlado pelo mouse/camera.
- O glTF Quaternius recebe compensacao fixa de `PI` em `model_instance.rotation.y` no build para alinhar frente visual com `-Z`.
- Bot permanece com face-ball no corpo e o avatar acompanha como antes.

## Teste Primeiro

RED confirmado antes do fix com os testes novos:

- `test_football_arena_raycast_seal_closes_upper_perimeter_and_goal_faces`: `7014` raycasts escaparam. Amostras iniciavam em `y=7.25`, capturando o vao `7.2 -> 8.8`.
- `test_football_ball_uses_ccd_and_does_not_tunnel_at_max_speed`: CCD ainda desligado e a bola a `34 m/s` atravessava `north-goal-front-top` e `south-goal-front-top`, parando em torno de `z=+-29.1`.

## Guardas Permanentes

- Grade de raycasts com passo `0.25m` cobre paredes laterais, end walls, vidros de fundo dos gols, teto e linha do gol acima da travessa.
- Tunneling da bola cobre `20` lancamentos a `34 m/s` contra paredes, teto e paineis altos dos gols.
- Facing do player cobre movimento para `+X`, movimento para `-Z`, parada mantendo heading, yaw logico preservado e compensacao base do modelo.
- Regressao de chute pela camera permanece coberta pelos testes existentes de direcao/assist/chute/super.

## Screenshots

- `docs/screenshots/track-03l-arena/upper-perimeter-sealed.png`
- `docs/screenshots/track-03l-arena/goal-front-top-panel.png`
- `docs/screenshots/track-03l-arena/simple-corner-no-ramp.png`

## Validacao

- RED pre-fix: FAIL esperado, `59/61` tests passavam, `747/757` asserts, com `2` testes falhando.
- GREEN quick apos arena/facing: PASS, `63/63` tests, `765` asserts.
- Validacao completa final: PASS, `63/63` tests, `765` asserts, source integrity `28` `.gd/.gdshader` files outside `addons/`.

## Proximo Passo

Playtest de confirmacao geral por Fabio: verificar bola sem fuga, gol alto rebatendo, quina simples sem rodape e avatar do player mostrando costas para a chase camera ao andar para frente.
