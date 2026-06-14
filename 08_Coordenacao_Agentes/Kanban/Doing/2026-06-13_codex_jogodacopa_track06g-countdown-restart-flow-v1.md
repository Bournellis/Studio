# Track 06G - Countdown Directo E Restart Confirmado V1

- Data: `2026-06-13`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/JogoDaCopa/track06g-countdown-restart-flow-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track06g-countdown-restart-flow-v1`
- Base: `main` em `4902ff95`
- Status: `DOING`

## Objetivo

Fazer duas correcoes cirurgicas pos-publicacao:

- countdown de kickoff deve ser direto, sem sequencia confusa `3` e depois `4 3 2 1`;
- remover restart direto pelo teclado `R`; reiniciar deve passar por menu/painel com confirmacao.

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/modes/football/football_root.gd`
- `Projetos/JogoDaCopa/presentation/hud/football_hud.gd`
- testes em `Projetos/JogoDaCopa/tests/unit/`
- docs/evidencias da track

## Validacao Planejada

- Import headless do editor na worktree nova.
- `tools/validate.gd`.
- Export Web release.
- Chrome local smoke/captura Web.
- Merge local em `main`, publicacao via `tools/publish_web.ps1 ... -ConfirmRemoteMutation`, gates remotos curtos suficientes para hotfix.

## Handoff

Fechar com commit local, merge em `main`, publicacao Cloudflare e `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
