# Code Review - Track 03 Arcade Series V1 (03A-03E)

- Date: `2026-06-10`
- Reviewer: Claude (Fable 5)
- Scope: commits `582101e..0ddf22b` mergeados em main (~2.1k linhas), revisao pos-merge.
- Method: revisao estatica do diff + validacao reportada (46 tests/426 asserts). Nota: este review ocorreu apos a merge; a serie nao passou por review pre-merge.

## Summary

Serie muito acima da media e claramente melhor que a Track 02 em disciplina de contrato: todas as regras da serie foram cumpridas - paridade de bot entregue e testada (dash defensivo, coleta de pad em rota, super proprio), regras de partida centralizadas em `football_match_rules.gd` puro, regressao do tap LMB/RMB protegida por teste, fireball com histerese em constantes, jump pad nao lanca a bola (teste explicito), toon experiment isolado com toggle OFF default + screenshots comparativos commitados, 16 testes novos (30->46). O manejo do `project.godot` regravado pelo editor (stash preservado antes da serie) foi exemplar. Dois issues reais, um deles de game feel na mecanica central da 03C.

## Issues

### Medium

| # | Arquivo | Issue | Detalhe |
|---|---|---|---|
| M1 | `modes/football/football_root.gd:716-722` | **Super e consumido em whiff** | `_on_player_strong_kick_requested` zera `player_super_meter` e marca `player_super_used_this_kickoff` ANTES de `_try_player_kick`, que tem varios early-returns - em especial `connected == false` (bola fora de alcance). RMB com super cheio longe da bola = barra inteira + cota do kickoff perdidas sem chute. O bot nao sofre disso (so chuta em range via windup), entao o bug pune apenas o jogador humano. Fix trivial: consumir o super dentro de `_try_player_kick` apenas quando `super_shot and connected` (ou checar `_can_reach_ball` antes de consumir). |
| M2 | `tools/performance_sample.gd` + Progress | **Metricas de perf nao comparaveis** | A serie reporta `1097-1275fps avg` vs `143-144fps` da serie 02 - salto implausivel com MAIS conteudo na cena; o sampler novo provavelmente rodou headless (sem rasterizacao) ou em janela minima. Como gate de 60fps os numeros ficam sem valor. Re-medir com janela real e resolucao fixa (1080p) registrando a resolucao junto do numero, e refazer a baseline para as proximas tracks. |

### Minor / Nits

| # | Arquivo | Issue |
|---|---|---|
| L1 | `fps_player_controller.gd` | Input duplicado em dois caminhos (`_input` por eventos + `_handle_shooting` por polling). Idempotente e seguro (cooldowns bloqueiam o segundo disparo), mas sao dois lugares para manter em sincronia. Consolidar num caminho quando conveniente. |
| L2 | `fps_player_controller.gd` | `begin_charged_shot` nao checa `arcade_stun_remaining` (o dash checa): da para iniciar carga durante stun e soltar depois. Funciona como input buffering - se for intencional, documentar; se nao, alinhar com o dash. |
| L3 | Design (03C) | O chute normal agora dispara no release do LMB (ate +150ms de latencia vs press). Previsto no plano, mas e o tipo de mudanca que so o playtest valida - atencao especifica nisso. |

## Conformidade com as regras da serie

- Paridade de bot: ENTREGUE (testes `test_football_bot_uses_arcade_dash_for_defense`, `test_football_bot_collects_route_boost_pad`, super do bot com ganho modulado por dificuldade).
- Caminho unico de forca: ENTREGUE (super/charged/slide passam por `_try_player_kick` -> `ball.kick()`; fisica base da bola intocada).
- Regressao tap LMB/RMB: ENTREGUE (`charge_fraction = 0` -> forca/lift identicos; teste de regressao presente).
- Regras em `football_match_rules.gd` puro: ENTREGUE (golden goal, vale-2, timer com dicionarios explicitos; modo `goals` intocado e testado).
- Tuning em constantes nomeadas: ENTREGUE em todos os arquivos revisados.
- Toon atras de toggle, OFF default, isolado: ENTREGUE com teste de isolamento e screenshots em `docs/screenshots/track-03e-toon/`.

## What Looks Good

- `match_rules.apply_goal_score_for_mode`/`resolve_timer_state` sao puros, com retorno explicito de `goal_value`/`double_goal`/`golden_goal` - facil de testar e de estender (ex.: melhor-de-N futuro).
- Stun do player implementado com early-return limpo no physics que ainda consome knockback (nao congela no ar).
- Flip reseta em todos os paths de pouso; `clear_movement_impulses`/`set_input_locked` limpam dash e carga.
- Stash `21cf0ba` preservou um `project.godot` regravado (provavelmente pelo editor Godot aberto durante a serie) sem perder as configs de sombra da 02A - main esta inteira.
- Cobertura de teste dos cenarios chatos: jump pad nao lanca bola, pad respawna, emote so pos-gol, golden goal encerra, vale-2 so na janela final.

## Verdict

**Aprovado.** M1 (super em whiff) merece hotfix antes do playtest serio - e a mecanica central da 03C sendo punida injustamente. M2 e correcao de metodologia de gate. Recomendacao: aguardar a thread 02C-bis/02D-bis fechar (esta tocando `football_root` em worktree paralela) e rodar uma track curta `03F Arcade Hotfix V1` com M1 + M2 + eventuais achados do review da 02C/02D-bis, tudo numa tacada. Processo: a serie 03 foi mergeada sem review previo - funcionou desta vez pela qualidade alta, mas o fluxo combinado (review antes de merge) pega M1 antes de virar baseline.
