# Handoff - JogoDaCopa FootballRoot Extraction V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/footballroot-extraction-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--footballroot-extraction-v1`
- Base: `codex/jogodacopa/documentacao-limpeza` (`b21a0da5`)
- Status: `LOCAL_VALIDADO_AGUARDANDO_REVIEW`

## O Que Foi Feito

- Reduzi `Projetos/JogoDaCopa/modes/football/football_root.gd` de `2280` para `1862` linhas.
- Extraidos quatro helpers de baixo risco:
  - `football_world_environment.gd`
  - `football_capture_director.gd`
  - `football_scoreboard_controller.gd`
  - `football_perf_scenario.gd`
- Mantida a API debug/publica do `FootballRoot`; os testes seguem chamando os mesmos wrappers.
- Nenhum tuning de fisica, chute, bot, regra de partida, input ou gameplay foi alterado.
- Publicacao publica permanece `Super Campeao v1.2.1+6ef3074c`; esta track nao publicou build remoto.

## Validacao

- Import headless inicial: PASS.
- Import headless apos scripts novos: PASS.
- `tools/validate.gd`: PASS, `104` tests, `1825` asserts.
- Web export release: PASS.
- `tools/validate.gd` apos Web export: PASS, `104` tests, `1825` asserts.
- Web gzip transfer: `30.58 MiB / 50.00 MiB`.
- Web boot smoke via Chrome headless: PASS.
- Screenshot: `Projetos/JogoDaCopa/docs/screenshots/track-09a-footballroot-extraction-v1/web-smoke.png`
- Report: `Projetos/JogoDaCopa/docs/screenshots/track-09a-footballroot-extraction-v1/web-smoke.json`

## Riscos E Observacoes

- A branch esta empilhada em `codex/jogodacopa/documentacao-limpeza`; o `main` local tem commits posteriores de DraxosMobile. Integrar a limpeza documental antes desta track ou fazer merge local controlado.
- O primeiro Web export falhou porque `builds/web` nao existia na worktree nova; criada a pasta local e o export passou.
- O smoke final usou Chrome headless; Playwright local estava indisponivel por falta de `playwright-core`.
- Warnings de GUT UID/text-path permaneceram como ruido conhecido.

## Proximo Passo

- Review/merge local da branch `codex/jogodacopa/footballroot-extraction-v1`.
- Depois da merge, Fabio faz o push via GitHub Desktop.

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin
