# Code Review - JogoDaCopa Track 06D - HUD Broadcast V1

- Data: `2026-06-13`
- Revisor: Claude (review pre-merge de UI/visual)
- Branch: `codex/jogodacopa/track06d-hud-broadcast-v1` (commits `3152036a` feat, `544d6348` handoff)
- Base: `main` em `c894dc0d`
- Veredito: `APROVADO`. Ajuste `264a7a93` (scorebug limpo + gate de luma noturna) verificado; Observacoes 1 e 2 RESOLVIDAS. Fabio deu OK final e autorizou merge local da 06D.

## Disciplina de paralelismo e contrato do ESC (OK)

- Tocou SOMENTE: `presentation/hud/football_hud.gd`, `tests/unit/test_hud_visual.gd` (novo), `docs/screenshots/track-06d/`.
- NAO tocou `modes/menu/*`, `modes/football/football_root.gd`, `autoloads/*`, `docs/asset-licenses.md`, `project.godot` nem `test_pause_menu.gd`. Areas disjuntas da 06C respeitadas.
- Contrato do ESC da 06B preservado: todos os nodos-chave presentes (`PauseMenuPanel`, `ResumeButton`, `RestartMatchButton`, `MainMenuButton`, `PauseSectionTabs`, `ControlsSection`, `VideoSection`, `QualityOption`, `SensitivitySection`, `FullscreenToggle`). `test_pause_menu.gd` rodou como REGRESSAO e passou (suite `98/98`).
- Countdown unico da 06A intacto: `football_root.gd` nao foi tocado e ha teste de regressao dedicado (`debug_get_kickoff_countdown_start_count` 0 -> 1 com o HUD novo).

## Fonte e licenca (OK)

Carrega `Kenney Future` + `Kenney Future Narrow` por caminho, com `push_error`/`push_warning` em ausencia. NAO editou `asset-licenses.md` (a 06C registra a mesma fonte), exatamente como combinado.

## Scorebug / HUD broadcast (OK)

- Scorebug com placar grande em Kenney, swatches de kit, relogio e `StateBadgeLabel` com estados `3 GOLS` / `TIMER` / `VALE 2` / `GOLDEN GOAL` (cores por estado via `_build_badge_style`).
- Barra de STAMINA (boost) e **SUPER meter** com `SuperReadyBadge` "PRONTO" dourado visivel quando `super_fraction >= 0.999`.
- Pulso/escala no scorebug em gol/countdown (apenas desktop; no Web fica `scale = 1` para respeitar budget).
- Anunciador maior (Kenney 48 + outline preto), punch `1.55` no countdown e cor por evento (countdown dourado; gol amarelo/vermelho pelo autor; golden goal/ultimo minuto ciano).
- Reaproveita o snapshot existente do HUD; nao muda a fonte de dados nem regras. Apresentacao pura.

## Testes (estado/comportamento, nao presenca) (OK)

- `test_hud_visual.gd`: dirige `update_snapshot` por estados (goals -> `3 GOLS`, super 0.5 -> barra 50 e PRONTO oculto; timer 25s -> `VALE 2`, super 1.0 PRONTO visivel, relogio `00:25`; golden goal -> `GOLDEN GOAL`). Punch de gol/countdown (escala do scorebug e do event label > 1). Regressao do kickoff countdown unico com o HUD broadcast.

## Zero mudanca de gameplay (OK)

So apresentacao do HUD. Nenhuma regra/fisica/valor de stamina-SUPER ou logica de countdown tocada.

## Gates (handoff)

validate PASS `98/98` / `1538` asserts; `test_hud_visual` + `test_pause_menu` PASS; export Web release PASS; Chrome Web boot smoke PASS (`event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`); `git diff --check` OK.

## Evidencia visual (analisada)

`docs/screenshots/track-06d/hud-broadcast-{1920x1080,1280x720,960x540}.png` + web kickoff boot. Conferido: scorebug estilizado no canto, placar Kenney, badges, barras stamina/super, anunciador `SAIDA PLAYER` em Kenney. HUD legivel nas resolucoes.

## Observacoes

1. Brilho/luminancia noturna: as capturas de jogo da 06D aparecem nitidamente mais CLARAS que a baseline noturna (na 06A o kickoff tinha luma de ceu ~`46`). O handoff lista validate/export/Chrome boot, mas NAO traz o numero do gate de luminancia noturna (`< 90`) para estas capturas. Confirmar que o gate noturno rodou/passou nas capturas de jogo da 06D e se esse brilho e o pretendido (a serie e "noite de final"). Possivel ponto de ajuste de captura/feel.
2. Densidade do scorebug: alem de placar/relogio/badge/barras, o scorebug ainda mostra as linhas de telemetria `flow_label` e `control_label` ("Futebol: ... | Bot: ..." e "Bola: solta X% | Boost Y%"). Para um look de transmissao limpo, vale decidir (feel do Fabio) se essas linhas de dev continuam no scorebug ou ficam ocultas/minimizadas.
3. Resolucoes: testes/capturas em `1920x1080`/`1280x720`/`960x540`; falta o `1366x768` do gate padrao (mesmo ponto da 06C). Recomendacao, nao bloqueante.

## Ajuste 264a7a93 - Verificado (re-review)

Commit `fix(jogodacopa): clean 06d scorebug evidence gate` na branch da 06D. Conferido:

- Observacao 2 (telemetria) RESOLVIDA: `telemetry_visible = false` por padrao + `debug_set_telemetry_visible()` para reativar em debug; `flow_label`/`control_label` seguem a flag e ficam ocultos no scorebug. Visualmente o scorebug ficou limpo (placar/relogio/badge/STAMINA/SUPER). Teste atualizado assertando os dois ocultos.
- Observacao 1 (brilho) RESOLVIDA: nova `tools/capture_track06d_hud_broadcast.gd` monta o `WorldEnvironment` noturno (ACES/BG_SKY/sky escuro) e aplica o gate de luma de ceu `< 90`. Tabela em `docs/playtest-reports/track-06d-hud-broadcast.md` e `hud-broadcast-luma.json`: Kickoff `58.5/60.5/59.7`, Gol `61.0/61.7/61.2`, Super `58.5/60.5/59.7`, Result `75.1/74.9/71.7` (`1920x1080`/`1366x768`/`1280x720`) - todos `< 90`. Renders noturnos confirmados (fundo escuro, arena neon).
- Observacao 3 (resolucoes): RESOLVIDA - capturas por estado agora cobrem `1920x1080`, `1366x768` e `1280x720`.
- Gates: validate PASS `98/98` / `1548` asserts, `test_pause_menu.gd` verde (regressao do ESC), source integrity `43`, export Web PASS, Chrome boot smoke PASS (`pageErrors=0`/`consoleErrorCount=0`). Contrato do ESC e countdown unico da 06A preservados.

## Proximo passo

1. Track 06D mergeada localmente em `main` como `d7d207ea`.
2. Card movido para `Kanban/Done/` e este review registrado no commit de fechamento.
3. Com 06A-06D em `main`, segue a 06E (bump `v1.1.0`, publicacao unica, gates longos de primeiro minuto/5min + luma, retest Fabio + amigo).
