# Doing: JogoDaCopa Track 09K Web Heap Hotfix V1

- Data: `2026-06-19`
- Agente: `Codex`
- Branch: `codex/jogodacopa/track09k-web-heap-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09k-web-heap-hotfix-v1`
- Objetivo: investigar e corrigir a falha de heap JS/WASM remoto da 09J sem mudar gameplay, input, bot, fisica, scoring, HUD, tuning ou assets.
- Arquivos pretendidos: `Projetos/JogoDaCopa/modes/football/football_ball_contact_controller.gd`, possiveis testes em `Projetos/JogoDaCopa/tests/`, evidencias em `Projetos/JogoDaCopa/docs/playtest-reports/track-09k-data/`, relatorio `track-09k-web-heap-hotfix.md`, status locais e snapshots de coordenacao.
- Base lida: `Prioridades_Estudio.md`, `AGENTS.md` raiz, `Projetos/README.md`, `Estado_Atual.md`, `Projetos/JogoDaCopa/AGENTS.md`, `implementation/current-status.md`, `docs/documentation-index.md`, `docs/playtest-reports/track-09j-publication.md`.
- Plano de validacao: import headless da worktree nova, comparar evidencias 09I/09J, reproduzir com gate local curto quando possivel, `tools/validate.gd`, export Web, Chrome local boot/stability, publicacao controlada se verde, gates remotos menu/first-minute/stability/luma, `tools/check_doc_drift.ps1`, `git diff --check`, `git status --short`.
- Proximo handoff: fechar 09K com causa raiz, evidencias, merge local em `main` e `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`; se heap nao ficar verde apos iteracoes razoaveis, registrar bloqueio tecnico e manter production na 09I.
