# Track 09A - FootballRoot Extraction V1

- Data: `2026-06-15`
- Branch: `codex/jogodacopa/footballroot-extraction-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--footballroot-extraction-v1`
- Base: `codex/jogodacopa/documentacao-limpeza` (`b21a0da5`)
- Status: `LOCAL_VALIDADO_AGUARDANDO_REVIEW`

## Objetivo

Reduzir o tamanho e responsabilidade de `modes/football/football_root.gd` sem mudar gameplay, tuning, fisica, input contracts, regra de partida, API debug ou publicacao Web.

## Resultado

- `FootballRoot` caiu de `2280` para `1862` linhas (`-418`).
- `FootballRoot` permanece como fachada/orquestrador de cena, loop e debug API.
- Gameplay de chute, contato, bola, bot, regras e arcade field ficou no root nesta etapa.
- Nenhum valor de tuning, fisica ou regra de partida foi alterado.
- Publicacao publica continua sendo `Super Campeao v1.2.1+6ef3074c`; esta track e local-only.

## Extracoes

- `modes/football/football_world_environment.gd`
  - Ambiente noturno, textura procedural do ceu e luz direcional principal do estadio.
- `modes/football/football_capture_director.gd`
  - Meta de capture scene, preparacao de kickoff/goal/result/play e camera de evidencia.
- `modes/football/football_scoreboard_controller.gd`
  - Cache de labels/viewports dos placares do estadio, cadencia de update e resize por render profile.
- `modes/football/football_perf_scenario.gd`
  - Quit-after, amostras extras de estabilidade, passos do perf scenario e filtro Web de feedback.

## Validacao

- Import headless inicial da worktree: PASS.
- Import headless apos scripts novos: PASS.
- `tools/validate.gd`: PASS, `104` tests, `1825` asserts.
- Web export release: PASS.
- `tools/validate.gd` apos Web export: PASS, `104` tests, `1825` asserts.
- Web gzip transfer gate: `30.58 MiB / 50.00 MiB`.
- Web boot smoke via Chrome headless: PASS; screenshot em `docs/screenshots/track-09a-footballroot-extraction-v1/web-smoke.png`; relatorio em `docs/screenshots/track-09a-footballroot-extraction-v1/web-smoke.json`.

## Observacoes

- O primeiro Web export falhou porque `builds/web` ainda nao existia na worktree nova; a pasta local de build foi criada e o export repetido com sucesso.
- O primeiro script de smoke tentou usar Playwright, mas o runtime local tinha `playwright` sem `playwright-core`; a evidencia final foi gerada com Chrome headless instalado localmente.
- Warnings de UID/text path do GUT seguem o ruido conhecido de worktree/import e nao bloquearam os testes.
- A branch esta empilhada sobre `codex/jogodacopa/documentacao-limpeza`; o `main` local avancou depois em commits de DraxosMobile. Recomenda-se integrar na ordem: limpeza documental, depois Track 09A, ou fazer merge local controlado antes de integrar.

## Proximos Cortes Recomendados

1. Track 09B: extrair Web loading/warmup apenas se houver tempo para boot smoke Web com screenshot.
2. Track 09C: extrair arcade field/boost/jump pads em controller dedicado, com foco maior em regressao de gameplay.
3. Track 09D: avaliar se kick/match presenter ainda compensam apos a reducao inicial.
