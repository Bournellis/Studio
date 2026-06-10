# Multi-Agent Doing: FpsShooter Bootstrap

## Metadata

- data: `2026-06-09`
- agente: `Codex`
- projeto: `FpsShooter`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/fpsshooter/bootstrap`
- worktree: `D:\Estudio-worktrees\FpsShooter--codex--bootstrap`

## Objetivo

Criar o projeto oficial implementavel `Projetos/FpsShooter` como tech probe independente de FPS 3D em Godot, com tema Draxos leve, bootstrap editor-first e plano inicial de arena shooter 1x1 contra bot.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/rpg-isometrico/AGENTS.md`
- `Projetos/rpg-isometrico/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-roguelike-cardgame/docs/design-lab.md`
- `Projetos/draxos-roguelike-cardgame/docs/autorun-lab.md`

## Escopo

- Incluir: bootstrap Godot 4.6.2, docs locais, status local, input bootstrap, cena inicial jogavel no editor, jogador FPS basico, bot V1 que anda e atira, arena simples, HUD basico, validacao headless e testes GUT iniciais.
- Fora do escopo: export/publicacao, Web/mobile, multiplayer, matchmaking, networking, void/queda, jump pads, plataformas suspensas, ricochet, arsenal amplo, IA duelista avancada e sistemas herdados dos projetos Draxos.

## Arquivos Pretendidos

- `Projetos/FpsShooter/`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `AGENTS.md`

## Plano De Commit

- `docs: register FpsShooter in studio portfolio`
- `client: bootstrap FpsShooter Godot editor probe`
- `test: add FpsShooter validation harness`

## Validacao

- `git diff --check`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\FpsShooter--codex--bootstrap\Projetos\FpsShooter -s res://tools/validate.gd`

## Resultado Da Rodada

- Projeto oficial `Projetos/FpsShooter/` criado no worktree dedicado.
- Cena principal bootstrap gerada em `modes/arena/arena.tscn`.
- Movimento FPS, tiro hitscan, bot V1, HUD, arena simples, knockback e reinicio de rodada implementados.
- Docs locais, AGENTS local, status de implementacao e tracks iniciais criados.
- Portfolio do estudio atualizado em `AGENTS.md`, `Prioridades_Estudio.md`, `Estado_Atual.md`, `Projetos/README.md` e painel visual.
- Validacao executada com sucesso: `tools/validate.gd`, GUT `4/4 passed`, `37` asserts.

## Proximo Handoff

Fabio deve assumir para abrir no editor, testar a primeira arena e decidir a prioridade da Track 01: ajuste de feel FPS, bot V1 ou mapa/obstaculos.
