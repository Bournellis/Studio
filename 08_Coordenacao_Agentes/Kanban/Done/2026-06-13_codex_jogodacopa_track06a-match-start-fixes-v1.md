# Track 06A - Match Start Fixes V1

- Data: `2026-06-13`
- Agente: `Codex`
- Branch: `codex/jogodacopa/track06a-match-start-fixes-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track06a`
- Projeto: `Projetos/JogoDaCopa/`
- Objetivo: corrigir bugs de inicio de partida e remover hints/crosshair do HUD sem alterar gameplay, mira funcional, chute, fisica da bola ou movimento.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/docs/documentation-index.md`
- `Projetos/JogoDaCopa/docs/series-06-broadcast-polish-plan.md` (Track 06A)
- `Projetos/JogoDaCopa/docs/architecture-overview.md`

## Arquivos Pretendidos

- Match lifecycle/spawn/facing: `Projetos/JogoDaCopa/modes/football/football_root.gd`
- Avatar visual facing: `Projetos/JogoDaCopa/gameplay/avatar/`
- HUD/hints/crosshair: `Projetos/JogoDaCopa/presentation/hud/`
- Testes GUT: `Projetos/JogoDaCopa/tests/unit/`
- Evidencias: `Projetos/JogoDaCopa/docs/screenshots/track-06a/`
- Relatorio: `Projetos/JogoDaCopa/docs/playtest-reports/track-06a-match-start-fixes.md`
- Plano da serie: `Projetos/JogoDaCopa/docs/series-06-broadcast-polish-plan.md`

## Validacao Planejada

- Teste vermelho primeiro para countdown unico por kickoff inicial e pos-gol.
- Medir e documentar a causa raiz real do countdown duplo antes do fix.
- Testes de facing inicial para player e bot no kickoff inicial e pos-gol.
- Testes de ausencia dos nodos de hints e crosshair no HUD montado.
- Import headless da worktree nova antes de validar.
- `validate.gd` completo, mantendo e somando ao baseline de 86 testes / 1272 asserts.
- Export Web release single-threaded.
- Boot Web local em Chrome com screenshot.
- Capturas desktop em `docs/screenshots/track-06a/` e relatorio de playtest/evidencia.
- `git diff --check` e `git status --short`.

## Ponto De Handoff

- Parar pre-merge em branch para review da Claude e aprovacao visual de Fabio.
- Registrar handoff em `08_Coordenacao_Agentes/Handoffs/2026-06-13_codex_jogodacopa_track06a-match-start-fixes-v1.md`.
- Nao fazer push/fetch/pull; rede git permanece exclusiva do Fabio via GitHub Desktop.

## Resultado

- Aprovado em code review pela Claude e aprovado visualmente por Fabio.
- Merge local em `main`: `b585b5d2`.
- Countdown inicial corrigido para um unico disparo; pos-gol permanece um disparo.
- Facing inicial e pos-gol corrigido para player e bot olhando para o oponente.
- HUD em jogo sem `HintLabel` e sem `FootballCrosshair`; comandos preservados em `FootballHud.CONTROL_HINTS`.
- Evidencia: `Projetos/JogoDaCopa/docs/playtest-reports/track-06a-match-start-fixes.md`, `Projetos/JogoDaCopa/docs/screenshots/track-06a/`, `Projetos/JogoDaCopa/docs/playtest-reports/track-06a-data/`.
- Validate integrado pos-merge: PASS, `91` testes / `1298` asserts; export Web e boot Chrome local PASS na branch pre-merge.
- Proximo passo: Track 06B - ESC Menu Completo V1.
- Rede git proibida; `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
