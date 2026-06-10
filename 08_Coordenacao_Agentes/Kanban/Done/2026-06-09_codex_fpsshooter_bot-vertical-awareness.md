# FpsShooter Bot Vertical Awareness - Codex

- Data: `2026-06-09`
- Agente: `Codex`
- Branch: `codex/fpsshooter/bot-vertical-awareness`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--bot-vertical-awareness`
- Projeto: `Projetos/FpsShooter/`
- Objetivo: fazer o bot reconhecer exposicao vertical do jogador, especialmente quando a camera/cabeca fica visivel acima de cover baixo, preservando a leitura justa da Track 01B.

## Arquivos Pretendidos

- `Projetos/FpsShooter/gameplay/bot/basic_duel_bot.gd`
- `Projetos/FpsShooter/tests/unit/test_bootstrap.gd`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/implementation/tracks/track-01b-bot-duelist-v1/current-status.md`
- `Projetos/FpsShooter/docs/work-plan.md`
- `Projetos/FpsShooter/docs/validation.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/FpsShooter/AGENTS.md`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/implementation/tracks/track-01b-bot-duelist-v1/current-status.md`

## Validacao Planejada

- `res://tools/validate.gd`
- Godot editor headless filtrado para warnings GDScript relevantes.
- `git diff --check`
- Smoke humano documentado em `docs/validation.md`.

## Handoff

- Implementado upgrade de percepcao vertical do bot na Track 01B.
- `BasicDuelBot` agora escaneia pontos expostos do jogador: camera/shot origin, cabeca, tronco alto, centro e corpo baixo.
- O bot usa o ponto visivel para windup e mira deterministica; cover baixo pode esconder o centro do corpo sem apagar a leitura da cabeca/camera.
- Parede alta/tall blocker segue bloqueando o windup normal e empurrando o bot para reposicionamento.
- `force_fire()` continua imediato e direto para testes.
- Testes adicionados/ajustados para cover baixo visivel e blocker alto bloqueante.
- Portfolio, `Estado_Atual`, README, painel visual, status local, work plan e validacao atualizados para `FPS_SHOOTER_TRACK_01B_VERTICAL_AWARENESS_COMPLETE`.
- `tools/validate.gd`: PASS, GUT `17/17`, `132` asserts.
- Godot editor headless filtrado para scripts alvo: `NO_TARGET_SCRIPT_WARNINGS_FOUND`.
- `git diff --check`: PASS.
- Proximo passo: commit, merge em `main` e playtest humano de 3 minutos com foco em cover baixo/parede alta.
