# 2026-06-13 - Codex - JogoDaCopa Track 06B ESC Menu Completo V1

## Status

- Estado: DONE_MERGED_LOCAL
- Branch: `codex/jogodacopa/track06b-esc-menu-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track06b`
- Base: `main` apos merge local da Track 06A (`b585b5d2`, fechamento `4f18f2fa`)
- Merge local em main: `0935529d`
- Push remoto: PENDENTE Fabio via GitHub Desktop

## Objetivo

Implementar o menu ESC completo de partida com persistencia de configuracoes, controles reais de audio/video/sensibilidade, integracao de qualidade `Alta`/`Leve` com `RenderProfile`, testes de clique reais e evidencias visuais em desktop.

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/project.godot`
- `Projetos/JogoDaCopa/autoloads/game_settings.gd`
- `Projetos/JogoDaCopa/autoloads/render_profile.gd`
- `Projetos/JogoDaCopa/autoloads/app_bootstrap.gd` se necessario para boot de configuracoes
- `Projetos/JogoDaCopa/presentation/hud/football_hud.gd`
- `Projetos/JogoDaCopa/modes/football/football_root.gd`
- `Projetos/JogoDaCopa/modes/menu/main_menu_root.gd`
- `Projetos/JogoDaCopa/tests/unit/*settings*.gd`
- `Projetos/JogoDaCopa/tests/unit/*pause_menu*.gd`
- `Projetos/JogoDaCopa/docs/screenshots/track-06b/*`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Handoffs/2026-06-13_codex_jogodacopa_track06b-esc-menu-v1.md`

## Documentos Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/documentation-index.md`
- `Projetos/JogoDaCopa/docs/series-06-broadcast-polish-plan.md`
- `Projetos/JogoDaCopa/docs/architecture-overview.md`
- Prompt anexo Track 06B

## Plano De Validacao

- Import headless inicial na worktree: `Godot --headless --editor --quit --path .`
- Suite local: `Godot --headless --path . -s res://tools/validate.gd`
- `git diff --check`
- `tools/check_doc_drift.ps1` na raiz
- Export Web single-threaded com preset Web existente
- Servir `builds/web` localmente e validar boot no Chrome/in-app browser com screenshot/luma quando aplicavel
- Capturar ESC em 1920x1080, 1366x768 e 1280x720 nas secoes Controles, Audio, Video e Sensibilidade

## Ponto De Handoff

Parar antes de merge/publicacao, deixando branch local validada, evidencia registrada, handoff completo e declaracao `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.

## Evidencia Final

- Implementacao: ESC menu completo com abas Controles/Audio/Video/Sensibilidade, persistencia via `GameSettings`, fullscreen, qualidade `Alta`/`Leve`, volumes e sensibilidade.
- Testes de clique real: `tests/unit/test_pause_menu.gd` cobre menu principal e ESC em `1920x1080`, `1366x768` e `1280x720`.
- Capturas: `Projetos/JogoDaCopa/docs/screenshots/track-06b/` contem 12 PNGs das abas do ESC nas 3 resolucoes.
- Validate completo: PASS, 95 testes, 1512 asserts, Web gzip `30.34 MiB / 50.00 MiB`.
- Export Web: PASS, `builds/web/index.html`.
- Boot Web local: PASS no navegador em `1280x720`; canvas carregou a tela inicial sem tela preta. Logs mostraram apenas warnings conhecidos do `RenderProfile`.
- Review Claude: `Projetos/JogoDaCopa/docs/code-review-track06b-esc-menu-v1.md`, veredito `APROVADO no code review`.

## Handoff

`08_Coordenacao_Agentes/Handoffs/2026-06-13_codex_jogodacopa_track06b-esc-menu-v1.md`
