# JogoDaCopa - FootballRoot Extraction V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/footballroot-extraction-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--footballroot-extraction-v1`
- Status: `LOCAL_VALIDADO_AGUARDANDO_REVIEW`

## Resultado

- `FootballRoot` reduzido de `2280` para `1862` linhas.
- Novos helpers:
  - `football_world_environment.gd`
  - `football_capture_director.gd`
  - `football_scoreboard_controller.gd`
  - `football_perf_scenario.gd`
- Nenhuma mudanca de gameplay, fisica, input, bot, regras de partida ou publicacao remota.

## Validacao

- Import headless: PASS.
- `tools/validate.gd`: PASS, `104` tests, `1825` asserts.
- Web export release: PASS.
- `tools/validate.gd` com build Web presente: PASS, `104` tests, `1825` asserts.
- Web gzip transfer: `30.58 MiB / 50.00 MiB`.
- Web boot smoke via Chrome headless: PASS, screenshot em `Projetos/JogoDaCopa/docs/screenshots/track-09a-footballroot-extraction-v1/web-smoke.png`.

## Handoff

- `08_Coordenacao_Agentes/Handoffs/2026-06-15_codex_jogodacopa_footballroot-extraction-v1.md`
