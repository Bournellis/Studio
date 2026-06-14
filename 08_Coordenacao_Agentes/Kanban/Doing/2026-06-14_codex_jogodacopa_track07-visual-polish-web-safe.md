# Track 07 - Visual Polish & Web-Safe Broadcast Pass

- Projeto: `Projetos/JogoDaCopa/`
- Agente: Codex
- Branch: `codex/jogodacopa/track07-visual-polish-web-safe`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track07-visual-polish-web-safe`
- Base: `main` em `b2bb7a7a`
- Status: `EM_ANDAMENTO`

## Objetivo

Executar uma track visual grande para melhorar leitura e impacto do `Copa Arena Futebol` sem alterar gameplay e sem pesar o Web.

## Escopo

- Readability: vidro, bloom, gramado, bola, jogador, sombras e contraste.
- HUD/UI: scorebug mais compacto, barras mais discretas, pause/result com hierarquia melhor.
- Menu: hero shot e card broadcast com apresentacao mais forte.
- Broadcast moments: kickoff, gol, vitoria/rematch e feedback visual leve.
- Web-safe: evitar assets grandes, particulas caras, pos-processamento pesado e qualquer regressao de hitches.

## Arquivos Provaveis

- `Projetos/JogoDaCopa/modes/football/`
- `Projetos/JogoDaCopa/modes/menu/`
- `Projetos/JogoDaCopa/presentation/hud/`
- `Projetos/JogoDaCopa/presentation/feedback/`
- `Projetos/JogoDaCopa/presentation/camera/`
- `Projetos/JogoDaCopa/docs/screenshots/track-07-visual-polish-web-safe/`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-07-visual-polish-web-safe.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/release-history.md`

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`
- `AGENTS.md`
- `canon/canon-brief.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`

## Validacao Planejada

- Import headless da worktree nova.
- `tools/validate.gd`
- Export Web release local.
- Capturas desktop/Web: menu, gameplay, pause, gol, resultado e luma noturna.
- Probe local curto contra Web.
- Antes de publicar: `publish_web.ps1 -Mode Plan`, `Package`, `FullPublish -ConfirmRemoteMutation`.
- Gates remotos: primeiro minuto, estabilidade 5 min, luma noturna.

## Handoff

Encerrar com merge local em `main`, publicacao Cloudflare Pages se gates locais passarem, docs atualizados, card movido para Done e `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
