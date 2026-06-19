# Track 09N - Football Render Settings Controller V1

- Data: 2026-06-19
- Agente: Codex
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/jogodacopa/track09n-render-settings-controller-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09n-render-settings-controller-v1`
- Base: `47425adf` (`track09m-web-heap-gate-semantics-v1`)

## Objetivo

Reduzir o tamanho do `FootballRoot` com uma extracao local e conservadora do bloco de render/settings, mantendo producao publica na 09I e preservando gameplay, input, bot, fisica, contato de bola, HUD, assets e tuning.

## Escopo

- Criar um controller/helper pequeno em `Projetos/JogoDaCopa/modes/football/` para orquestrar integracao com `GameSettings`, qualidade/render profile e resize dos viewports do placar.
- Manter `FootballRoot` como facade de lifecycle e compatibilidade dos call sites existentes.
- Nao tocar nos caminhos quentes de contato/posse da bola nem na ordem de `_physics_process`.

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/modes/football/football_root.gd`
- `Projetos/JogoDaCopa/modes/football/football_render_settings_controller.gd`
- `Projetos/JogoDaCopa/docs/documentation-index.md`
- `Projetos/JogoDaCopa/docs/architecture-overview.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09n-render-settings-controller.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- Este cartao, movido para `Kanban/Done/` no fechamento.

## Documentos Lidos

- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/documentation-index.md`
- `Projetos/JogoDaCopa/docs/architecture-overview.md`
- `Projetos/JogoDaCopa/docs/work-plan.md`

## Plano De Validacao

- Import headless do editor na worktree nova.
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`
- Export Web release para `builds/web/index.html`.
- Probe Chrome local curto usando a semantica 09M (`js_heap_growth` primario e alias legado preservado), com screenshot e relatorio em `docs/playtest-reports/track-09n-data/`.
- `D:\Estudio\tools\check_doc_drift.ps1`
- `git diff --check`
- `git status --short`

## Handoff Esperado

Track local pronta para review/merge; sem push remoto por agente. Antes de qualquer publicacao, comparar a candidata contra o baseline publico 09I usando o probe 09M.

## Resultado

- Status: `LOCAL_VALIDATED_NO_PUBLICATION`.
- `FootballRoot`: `1079 -> 1051` linhas.
- Novo helper: `Projetos/JogoDaCopa/modes/football/football_render_settings_controller.gd` (`50` linhas).
- Sem mudanca intencional de gameplay, input, bot, fisica, contato/posse da bola, scoring, HUD visual, assets ou tuning.
- Import headless PASS.
- `tools/validate.gd` PASS: `104` testes, `1826` asserts, `58` fontes checadas.
- Web export release PASS.
- `tools/validate.gd` pos-export PASS: Web gzip `30.60 MiB / 50.00 MiB`.
- Chrome local Web probe 90s PASS: `event.visible_match_start`, page errors `0`, console errors `0`, first-minute hitches `0`, `js_heap_growth -7.48%`, `wasmSampleCount=0`.
- Evidencia: `Projetos/JogoDaCopa/docs/playtest-reports/track-09n-render-settings-controller.md` e `Projetos/JogoDaCopa/docs/playtest-reports/track-09n-data/`.
- Proximo passo: review/merge local; antes de publicacao, A/B contra 09I usando o probe 09M.
