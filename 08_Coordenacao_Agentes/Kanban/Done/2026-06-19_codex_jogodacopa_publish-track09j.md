# Done: JogoDaCopa Publish Track 09J Attempt

- Data: `2026-06-19`
- Agente: `Codex`
- Branch: `codex/jogodacopa/publish-track09j`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--publish-track09j`
- Objetivo: publicar a Track 09J Ball Contact Controller V1 na Cloudflare Pages para teste humano.
- Arquivos pretendidos: evidencias em `Projetos/JogoDaCopa/docs/playtest-reports/track-09j-data/`, `release-history.md`, `publication-readiness.md`, `documentation-index.md`, `implementation/current-status.md`, snapshots de coordenacao e card Kanban.
- Base lida: `Prioridades_Estudio.md`, `AGENTS.md` raiz, `Projetos/README.md`, `Estado_Atual.md`, `Projetos/JogoDaCopa/AGENTS.md`, `implementation/current-status.md`, `docs/publication-readiness.md`, `docs/release-history.md`, `tools/publish_web.ps1`.
- Validacao executada: import headless PASS; `tools/validate.gd` PASS `104/104`, `1826` asserts; package/export Web PASS; Web gzip `30.60 MiB / 50.00 MiB`.
- Publicacao tentada: `v1.2.1+4678fbea`, release root `web/v1-copa-arena-futebol-20260619-4678fbea`, preview `https://ff5e2d51.copa-arena-futebol.pages.dev`.
- Gates remotos 09J: menu PASS; first-minute PASS com `firstMinuteHitches=0`; stability 5min FAIL duas vezes apenas em heap JS/WASM (`+15.96%`, depois `+15.22%`, limite `<10%`); counters/caches Godot e FPS PASS.
- Rollback: production restaurada para 09I aprovado (`v1.2.1+7995b06c`, `web/v1-copa-arena-futebol-20260616-7995b06c`) via novo deploy `https://0bed6091.copa-arena-futebol.pages.dev`.
- Confirmacao rollback: URL estavel `https://copa-arena-futebol.pages.dev/` voltou a servir `web/v1-copa-arena-futebol-20260616-7995b06c`; menu PASS, `pageErrors=0`, `consoleErrorCount=0`.
- Evidencias: `Projetos/JogoDaCopa/docs/playtest-reports/track-09j-publication.md` e `Projetos/JogoDaCopa/docs/playtest-reports/track-09j-data/`.
- Proximo handoff: abrir track curta de investigacao/hotfix do heap remoto da 09J antes de republicar ou continuar reducao. `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
