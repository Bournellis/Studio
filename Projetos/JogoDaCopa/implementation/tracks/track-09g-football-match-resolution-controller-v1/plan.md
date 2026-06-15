# Track 09G - Football Match Resolution Controller V1

- Data: `2026-06-15`
- Agente: `Codex`
- Status: `LOCAL_VALIDADO`
- Baseline publico aprovado: `Super Campeao v1.2.1+a75cfe57`

## Objetivo

Continuar a reducao do `FootballRoot` com uma extracao estreita e verificavel: mover a orquestracao de resolucao da partida para um helper dedicado, sem alterar gameplay, fisica, input, bot, scoring, tuning, assets, HUD visual ou publicacao.

## Motivacao

Depois da 09F, `football_root.gd` ainda concentra responsabilidades de partida que ja possuem limites claros:

- detectar gol;
- aplicar placar e vale-2;
- administrar `goal_reset_timer`;
- atualizar relogio, fim do tempo e golden goal;
- finalizar partida;
- reiniciar estado de partida;
- registrar estatisticas de gol/chute/toque.

Essas responsabilidades sao orquestracao de estado, nao apresentacao nem regra pura. Elas podem sair do root sem mexer nos sistemas ja aprovados.

## Escopo

- Criar `modes/football/football_match_resolution_controller.gd`.
- Preloadar o helper em `football_root.gd`.
- Converter `FootballRoot.restart_match`, `_process_goal_detection`, `_register_goal`, `_update_match_clock` e `_finish_match` para fachadas/delegacoes.
- Mover para o helper o bloco que manipula `player_score`, `bot_score`, `match_over`, `match_time_remaining`, `golden_goal_active`, `goal_reset_timer`, `last_goal_value`, `last_goal_player_scored` e `match_stats`.
- Preservar os nomes publicos usados por testes/debug API enquanto os call sites internos migram de forma segura.
- Medir `FootballRoot` antes/depois e registrar o resultado.

## Limites

- Nao mudar regras de pontuacao, duracao de partida, golden goal, limite de gols ou vale-2.
- Nao mudar fisica da bola, input, camera, bot, boost/jump pads, SUPER ou tuning.
- Nao alterar layout/visual de HUD, resultado ou menu.
- Nao publicar em Cloudflare Pages por padrao; a 09F segue como baseline publico aprovado ate decisao explicita.

## Contrato Tecnico Sugerido

- `FootballMatchResolutionController.restart_match(root, capture_mouse := true) -> void`
- `FootballMatchResolutionController.update_goal_reset(root, delta) -> void`
- `FootballMatchResolutionController.process_goal_detection(root) -> void`
- `FootballMatchResolutionController.register_goal(root, player_scored) -> void`
- `FootballMatchResolutionController.update_match_clock(root, delta) -> void`
- `FootballMatchResolutionController.finish_match(root, player_won) -> void`
- `FootballMatchResolutionController.record_goal_stat(root, player_scored, goal_value) -> void`
- `FootballMatchResolutionController.record_shot_stat(root, team, super_used) -> void`

O helper pode receber o `root` como contexto nesta etapa para minimizar risco. Uma etapa futura pode reduzir esse acoplamento se houver ganho real.

## Plano De Execucao

1. Criar worktree/branch dedicada para 09G e registrar handoff.
2. Rodar inventario inicial de `football_root.gd` e dos testes que cobrem placar, timer, golden goal, resultado, restart e estatisticas.
3. Criar helper vazio com API delegada e sem mudanca comportamental.
4. Mover `restart_match`/reset de estado primeiro, mantendo `FootballRoot` como fachada.
5. Mover timer/golden goal em seguida e validar.
6. Mover goal detection/register/finish match por ultimo, por ser o bloco mais sensivel.
7. Mover wrappers de estatisticas somente se nao aumentar risco ou churn.
8. Rodar validacao completa, Web export e smoke local.
9. Atualizar track docs, handoff e estado com resultado real.
10. Entregar para review humano antes de qualquer publicacao remota.

## Validacao Obrigatoria

- Import Godot headless.
- `tools/validate.gd`.
- Web export release.
- `tools/validate.gd` com build Web presente para gzip gate.
- Smoke local Chrome/CDP com `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0` e `firstMinuteHitches=0`.
- Confirmar cobertura existente de:
  - gol atualiza placar e encerra no modo 3 gols;
  - timer entra em golden goal;
  - gol vale 2 no trecho final;
  - restart limpa countdown/golden goal/slowmo;
  - result screen recebe estatisticas.
- Se a track for publicada depois, exigir menu remoto, first-minute remoto, estabilidade remota 5min e luma remota porque a margem de heap da 09F ficou apertada no rerun.

## Riscos

- Medio: o escopo toca placar, fim de partida e restart, que sao fluxos centrais.
- Mitigacao: mover por fases, manter fachadas no root, preservar pure rules/presentation/flow controllers e validar apos a extracao.
- Risco Web: baixo para bundle/tamanho, mas estabilidade continua obrigatoria antes de publicacao por causa do historico de margem de heap.

## Criterio De Aceite

- `FootballRoot` menor e ainda legivel como orquestrador de alto nivel.
- Nenhum teste de gameplay/regra regressa.
- Build Web continua exportando e inicializando.
- Nenhuma mudanca intencional percebida pelo jogador.
- Documentacao registra linhas antes/depois, validacoes e qualquer risco residual.

## Resultado

- Criado `modes/football/football_match_resolution_controller.gd`.
- `FootballRoot` manteve fachadas publicas/testaveis e delega restart, modo de partida, goal reset, deteccao/registro de gol, timer/golden goal, fim de partida e stats de chute/gol.
- `FootballRoot`: `1295 -> 1178` linhas nesta base.
- Novo helper: `174` linhas.
- Sem mudanca intencional de gameplay, input, bot, fisica, scoring, tuning, assets, HUD visual ou publicacao.

## Validacao Executada

- Import Godot headless: PASS.
- `tools/validate.gd`: PASS, `104` testes, `1826` asserts, `55` fontes `.gd/.gdshader` verificadas.
- Web export release: PASS.
- `tools/validate.gd` com build Web presente: PASS, Web gzip `30.60 MiB / 50.00 MiB`, raw `63.06 MiB`, `9` arquivos.
- Chrome boot local: PASS, `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Evidencia: `docs/playtest-reports/track-09g-data/09g-local-web-boot.json` e `.png`.

## Risco Residual

- A 09G mexe em fluxo central de partida, mas ficou coberta pelos testes existentes de gol, placar, timer, golden goal, vale-2, restart, result screen, stats e kickoff pos-gol.
- Publicacao remota nao foi executada nesta track; a baseline publica aprovada continua `Super Campeao v1.2.1+a75cfe57`.
