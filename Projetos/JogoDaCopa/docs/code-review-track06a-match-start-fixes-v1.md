# Code Review - JogoDaCopa Track 06A - Match Start Fixes V1

- Data: `2026-06-13`
- Revisor: Claude (review pre-merge de UI/visual)
- Branch: `codex/jogodacopa/track06a-match-start-fixes-v1` (commits `e442a05e` fix, `83233058` evidencia)
- Base: `main` em `e5186ec9`
- Veredito: `APROVADO no code review` - correcao, testes, evidencia e gates conferem. Falta apenas o veredito visual subjetivo de Fabio (feel/leitura do kickoff noturno) antes do merge.

## Escopo verificado

Arquivos de codigo tocados (apenas o escopo previsto, nada de fisica/chute/input):
- `modes/football/football_root.gd` - flag de countdown, snap de facing no kickoff, remocao do campo `hint` do snapshot.
- `gameplay/avatar/player_avatar_3d.gd` - novo `snap_visual_facing_direction()`.
- `presentation/hud/football_hud.gd` - remocao de `HintLabel` e `FootballCrosshair`; migracao dos comandos para `CONTROL_HINTS` + `get_control_hints()`.
- Novos: `tests/unit/test_track06a_match_start.gd`, `tools/capture_track06a_match_start.gd`.

## Countdown - causa raiz e fix (OK)

Causa raiz correta e confirmada no codigo: no boot, `_ready_sync()` e `_ready_web_async()` chamavam `_restart_play(false)` enquanto `intro_open` ainda era `false` (o `_set_intro_open(true)` vem depois), entao o countdown era iniciado antes mesmo do intro; ao apertar `Comecar`, `_start_match()` iniciava o countdown de novo - dois disparos para o mesmo kickoff inicial.

Fix conferido:
- `_restart_play(after_goal, start_countdown := true)` com flag explicita.
- Caminhos de boot/warmup passam `_restart_play(false, false)` (linhas ~230, ~255, ~261) - nao iniciam countdown.
- Inicio real (`_start_match()` apos intro fechado) continua sendo o disparo unico do countdown inicial.
- Pos-gol segue em `_restart_play(true)` e dispara exatamente uma vez.

Bonus: o fix tambem corrige um comportamento errado de origem (countdown rodando antes do intro), nao so o sintoma.

## Testes (comportamento, nao presenca) (OK)

`test_track06a_match_start.gd` cobre:
- `test_initial_kickoff_starts_countdown_once`: pos-boot conta `0` e apos start conta `1` - este assert e exatamente o que falha no codigo antigo (boot disparava), confirmando teste-primeiro. O report registra a medicao vermelha (inicial `2`, pos-gol `1`).
- `test_post_goal_kickoff_starts_countdown_once`: forca a bola ao gol e roda physics frames; conta `1`.
- Facing inicial e pos-gol, para player E bot, via angulo entre `debug_get_model_front_direction()` e a direcao ao oponente, tolerancia `< 12 deg`. E teste geometrico de comportamento, nao de presenca.
- `test_hud_omits_in_game_hints_and_crosshair_but_keeps_controls_data`: ausencia de `HintLabel`/`FootballCrosshair` + presenca dos dados migrados em `get_control_hints()`.

Paridade de bot atendida (facing aplica a player e bot pelo `_snap_kickoff_avatar_facing()`).

## Zero mudanca de gameplay (OK)

Nenhum arquivo de bola, kick handler, movimento, camera ou input actions foi tocado. A remocao do crosshair e puramente visual no HUD; a mira funcional continua sendo o centro da camera + kick assist. O diff confirma.

## Evidencia visual (analisada)

- `kickoff-facing-hud-clean.png`: player de costas para a camera olhando para o campo do oponente ("SAIDA PLAYER"); HUD sem faixa de hints e sem crosshair central. PASS.
- `run-frame-01/03`: facing acompanha o movimento na corrida; bot a frente; sem reticle central. PASS.
- `kick-moment.png`: pose de chute coerente, bola a frente. PASS.
- `goal.png`: camera broadcast alta no gol (`BRA 1 0 FRA`); usada para passar o gate de luma noturna (`64.9 < 90`). PASS.
- `menu.png`: menu intacto (fora do escopo de mudanca da 06A).

Gates: validate PASS `91` testes / `1298` asserts (era `86`/`1272`; +5 testes), export Web release PASS single-threaded, Chrome boot local PASS com `pageErrors=0`/`consoleErrorCount=0`, luma `kickoff=46.6`, `hud=46.6`, `goal=64.9` (`< 90`).

## Observacoes (nao bloqueantes)

1. `kickoff-facing-hud-clean.png` e `hud-no-hints-no-crosshair.png` sao byte-identicos (mesmo md5). O report lista as duas como evidencias distintas, mas e o mesmo frame. Cosmetico; sugiro deduplicar ou capturar um segundo frame real de HUD limpo.
2. O teste de HUD usa `get_node_or_null("HudRoot/HintLabel")`/`FootballCrosshair`. Se o caminho do root estiver errado, `assert_null` passa falsamente (falso verde). Recomendo (opcional) assertar tambem que um nodo conhecido EXISTE sob esse root, para provar que o caminho resolve. Mitigado pela screenshot.
3. `snap_visual_facing_direction()` retorna em silencio se `part_root == null` ou direcao ~zero. No kickoff as posicoes sao distintas, entao nao dispara; ainda assim, por "falha silenciosa proibida", um `push_warning` no caso degenerado seria mais consistente. Opcional.
4. O rodape do menu mostra `v1.0.1+local` (label pre-existente, fora do escopo). Sera corrigido no bump da 06E; so registrando.
5. O frame de kickoff e bem escuro (luma `46.6`): o facing do bot fica pouco legivel a olho nu nesse frame (coberto por teste + frames de corrida). Veredito de leitura/feel e do Fabio.

## Proximo passo

1. Fabio da o OK visual (feel + leitura do kickoff noturno). Se algo de feel incomodar, abrir ajuste na propria branch antes do merge.
2. Apos OK: Codex executa a FASE 9 do prompt - merge em `main`, card para `Done/`, atualizar `implementation/current-status.md` (novo marker) e `Estado_Atual.md`, e commitar os docs untracked de `docs/` (incluindo este review). Sem publicacao (so na 06E).
3. So entao liberar a Track 06B (consome `CONTROL_HINTS` e assume HUD limpo).
