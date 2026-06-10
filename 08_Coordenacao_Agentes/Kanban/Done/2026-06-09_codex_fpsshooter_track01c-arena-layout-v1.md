# FpsShooter Track 01C Arena Layout V1 - Codex

- Data: `2026-06-09`
- Agente: `Codex`
- Branch: `codex/fpsshooter/track01c-arena-layout-v1`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--track01c-arena-layout-v1`
- Projeto: `Projetos/FpsShooter/`
- Objetivo: implementar o primeiro mapa de duelo 1x1 de verdade para o FpsShooter, com spawns melhores, cover baixo/alto, plataformas baixas com rampas, linhas de visao mais claras e pontos de reposicionamento do bot ligados ao layout.

## Arquivos Pretendidos

- `Projetos/FpsShooter/modes/arena/arena_root.gd`
- `Projetos/FpsShooter/tests/unit/test_bootstrap.gd`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/implementation/tracks/track-01-arena-1x1-v1/current-status.md`
- `Projetos/FpsShooter/implementation/tracks/track-01c-arena-layout-v1/current-status.md`
- `Projetos/FpsShooter/docs/work-plan.md`
- `Projetos/FpsShooter/docs/validation.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- `Projetos/README.md`
- `AGENTS.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/FpsShooter/AGENTS.md`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/docs/work-plan.md`
- `Projetos/FpsShooter/docs/validation.md`
- `Projetos/FpsShooter/modes/arena/arena_root.gd`
- `Projetos/FpsShooter/tests/unit/test_bootstrap.gd`

## Validacao Planejada

- `res://tools/validate.gd`
- Godot editor headless filtrado para warnings GDScript relevantes.
- `git diff --check`
- Smoke humano documentado em `docs/validation.md`.

## Handoff

- Implementado `Track 01C - Arena Layout V1`.
- `Duel Pit V1` substitui o retangulo bootstrap por mapa runtime `30x30`.
- Spawns diagonais protegidos bloqueiam o primeiro tiro direto.
- Mapa ganhou bloqueador central, covers baixos/altos, covers de spawn, plataformas laterais, rampas primitivas e marcacoes visuais de rota sem colisao.
- Pontos de reposicionamento do bot foram reconstruidos ao redor do layout e expostos por debug helpers.
- Testes cobrem estrutura do mapa, bloqueio de sightline dos spawns, route markers, pontos do bot e preservam os contratos de tiro/feedback/bot da Track 01A/01B.
- Documentacao local, portfolio, Estado Atual, README e painel visual atualizados para `FPS_SHOOTER_TRACK_01C_ARENA_LAYOUT_COMPLETE`.
- `tools/validate.gd`: PASS, GUT `19/19`, `186` asserts.
- Godot editor headless filtrado para scripts alvo: `NO_TARGET_SCRIPT_WARNINGS_FOUND`.
- `git diff --check`: PASS.
- Proximo passo: commit, merge em `main` e playtest humano de 3-5 minutos do `Duel Pit V1`.
