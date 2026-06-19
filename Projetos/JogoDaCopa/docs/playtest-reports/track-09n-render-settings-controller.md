# Track 09N - Football Render Settings Controller V1

- Data: 2026-06-19
- Branch: `codex/jogodacopa/track09n-render-settings-controller-v1`
- Base: `47425adf` (`track09m-web-heap-gate-semantics-v1`)
- Publicacao: nao realizada; producao publica continua em `Super Campeao v1.2.1+7995b06c` / Track 09I.

## Objetivo

Continuar a reducao local do `FootballRoot` com uma fatia conservadora e fora do caminho quente de gameplay. A Track 09N extraiu a integracao de render/settings para `football_render_settings_controller.gd`, preservando comportamento de menu, pause, sensibilidade, qualidade, render profile e placares.

## Alteracoes

- Criado `modes/football/football_render_settings_controller.gd`.
- Movidas para o controller:
  - leitura de metas vindas do menu principal (`bot_difficulty` e `match_mode`);
  - acesso ao autoload `GameSettings`;
  - conexao do sinal `quality_changed`;
  - refresh runtime de `WorldEnvironment`, resize dos SubViewports dos placares e refresh HUD/scoreboard;
  - aplicacao de sensibilidade do pause menu para player, `GameSettings` e HUD.
- `FootballRoot` manteve wrappers minimos para os sinais ja conectados e continuou como facade de lifecycle/debug.

## Fora Do Escopo

- Sem mudanca de gameplay, input, bot, fisica, contato/posse da bola, chute, scoring, HUD visual, assets ou tuning.
- Sem mudanca na ordem de `_physics_process`.
- Sem publicacao remota e sem alterar o baseline publico.

## Reducao

- `FootballRoot`: `1079 -> 1051` linhas (`-28`).
- Novo controller: `50` linhas.

## Validacao

- Import headless do editor: PASS.
- `tools/validate.gd`: PASS, `104` testes, `1826` asserts, `58` fontes checadas.
- Web export release: PASS.
- `tools/validate.gd` pos-export: PASS, Web gzip `30.60 MiB / 50.00 MiB`, raw `63.07 MiB`, `9` files.
- Chrome local Web probe 90s: PASS.
  - Evidencia: `track-09n-data/09n-local-web-boot.json`
  - Screenshot: `track-09n-data/09n-local-web-boot.png`
  - `event.visible_match_start`: true
  - `pageErrors`: `0`
  - `consoleErrorCount`: `0`
  - `firstMinuteHitches`: `0`
  - `stabilityPassed`: true
  - `js_heap_growth`: `-7.48%`
  - pico de `js_heap_growth`: `+1.29%`
  - `total_js_heap_growth`: `-12.19%`
  - alias legado `js_wasm_heap_growth`: `-7.48%`
  - `wasmSampleCount`: `0`

## Observacoes

- O probe local usou a semantica 09M: o check primario e `js_heap_growth`; `js_wasm_heap_growth` permanece como alias legado.
- Antes de qualquer publicacao desta candidata, repetir a comparacao A/B contra o baseline publico 09I usando o probe 09M.
