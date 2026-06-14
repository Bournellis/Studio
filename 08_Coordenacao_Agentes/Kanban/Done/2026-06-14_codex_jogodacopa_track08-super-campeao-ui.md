# Track 08 - Super Campeao Rebrand & UI Cleanup

## Agente
- Codex

## Branch / Worktree
- Branch: `codex/jogodacopa/track08-super-campeao-ui`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track08-super-campeao-ui`
- Merge local em `main`: `2f537628`

## Resultado
- Rebrand local para `Super Campeao` concluido.
- Novo splash leve: `Projetos/JogoDaCopa/assets/branding/super_campeao_splash.png`.
- Menu principal limpo: titulo `Super Campeao`, botao `Jogar`, status dinamico por selecao, uniformes sem `inspirado`, sem opcao Toon.
- Intro da partida limpo: sem resumo e sem troca de pele/camisa.
- Toon removido de UI/runtime/testes ativos.
- Gameplay preservado.

## Validacao Local
- Import headless da worktree: PASS.
- `tools/validate.gd`: PASS (`104` testes / `1825` asserts).
- `git diff --check`: PASS antes do merge e sera repetido no fechamento.
- Export Web local: PASS.
- Chrome local: menu `1920x1080`, `1366x768`, `1280x720`, loading opaco, intro e primeiro minuto PASS.
- Evidencias: `Projetos/JogoDaCopa/docs/playtest-reports/track-08-data/08-local-*.json|png`.

## Publicacao
- Tentativa: `v1.2.1+2f537628`, release root `web/v1-copa-arena-futebol-20260614-2f537628`.
- URL publica sanity/menu: PASS, rodape `Super Campeao v1.2.1+2f537628`, `pageErrors=0`, `consoleErrorCount=0`.
- Gate primeiro minuto remoto: FAIL (`firstMinuteHitches=1`, hitch `333.5ms`, evento proximo `feedback.play_sfx_3d.begin key=ball_glass`).
- Rollback remoto executado imediatamente para `web/v1-copa-arena-futebol-20260614-fa82cb7d`.
- Confirmacao rollback: PASS; URL publica voltou para `v1.2.0+fa82cb7d`.

## Handoff
- Handoff criado em `08_Coordenacao_Agentes/Handoffs/2026-06-14_codex_jogodacopa_track08-super-campeao-ui-rollback.md`.
- Proximo passo: nova hotfix/diagnostico do hitch remoto perto de `ball_glass` antes de republicar `Super Campeao`.
