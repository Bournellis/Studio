# Track 09S - Camera Strafe Smoothing Hotfix V1

- Data: 2026-06-20
- Agente: Codex
- Branch: `codex/jogodacopa/track09s-camera-strafe-smoothing-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09s-camera-strafe-smoothing-hotfix-v1`
- Base: `main` local apos 09R publicada e FpsPlayground 14E aprovado
- Objetivo: corrigir a percepcao de tremor/puxao da chase camera em toques rapidos de A/D, sem alterar gameplay, fisica, movimento, bot, bola, scoring, HUD, assets ou tuning de partida.

## Escopo Pretendido

- Reproduzir em teste a transicao de camera durante strafe lateral curto.
- Suavizar o foco/peso visual usado pela camera para evitar salto angular em A/D.
- Preservar o comportamento de W/S e o foco de bola em strafe sustentado.
- Publicar no Cloudflare Pages apos merge local e gates.

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/presentation/camera/football_chase_camera.gd`
- `Projetos/JogoDaCopa/tests/unit/test_bootstrap.gd`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09s-camera-strafe-smoothing-hotfix.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09s-data/`
- Docs vivos de status/publicacao no fechamento.

## Validacao Planejada

- Import headless editor inicial da worktree.
- Teste vermelho focado antes do fix.
- `tools/validate.gd`.
- Web export/package.
- Chrome Web smoke local 90s.
- `git diff --check`.
- `D:\Estudio\tools\check_doc_drift.ps1`.
- Merge local no `main`.
- Publicacao Cloudflare com `tools/publish_web.ps1 -Mode FullPublish -ConfirmRemoteMutation`.
- Remote menu, first-minute, stability 5min e luma gates.

## Handoff

- Se a correcao exigir mexer em fisica/movimento ou tuning de jogador, parar e registrar handoff.
