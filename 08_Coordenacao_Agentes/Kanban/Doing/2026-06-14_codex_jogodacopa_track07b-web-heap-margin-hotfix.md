# Track 07B - Web Heap Margin Hotfix

- Data: 2026-06-14
- Agente: Codex
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/jogodacopa/track07b-web-heap-margin-hotfix`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track07b-web-heap-margin-hotfix`
- Base: `main` em `917e64ee`

## Objetivo

Recuperar margem real no gate remoto de heap JS/WASM da Track 07 sem mudar gameplay, permitindo nova tentativa de publicacao Web `v1.2.0`.

## Hipotese

O patch final de export Web Audio da Track 07 resolveu os erros remotos, mas forçou fallback sem AudioWorklet e provavelmente elevou levemente o heap retido. A falha foi marginal (`+10.34%` contra limite `<10%`), com nodes, caches, video memory, FPS e erros estaveis.

## Escopo Pretendido

- `Projetos/JogoDaCopa/tools/publish_web.ps1`
- `Projetos/JogoDaCopa/gameplay/football/football_ball.gd`
- `Projetos/JogoDaCopa/presentation/hud/football_hud.gd`
- Evidencias em `Projetos/JogoDaCopa/docs/playtest-reports/track-07b-data/`
- Historico/status local do projeto e coordenacao apos validacao

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`

## Plano De Validacao

1. Import headless do editor na worktree nova.
2. `tools/validate.gd`.
3. Export/Package Web e probe local curto para confirmar runtime sem erros.
4. Gate remoto menu, primeiro minuto, estabilidade 5min e luminancia apos publicacao.
5. Rollback imediato para `v1.1.0+be453dc3` se qualquer gate remoto falhar.

## Handoff

Fechar com merge local em `main`, publicacao apenas se gates remotos passarem, docs/status atualizados e `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
