# FpsShooter - Track 04A FPS Playground Football V1

- Data: `2026-06-10`
- Agente: `codex`
- Branch: `codex/fpsshooter/track04a-fps-playground-football-v1`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--track04a-fps-playground-football-v1`
- Projeto alvo: `Projetos/FpsShooter`
- Status: `DONE`
- Portfolio marker: `FPS_PLAYGROUND_TRACK_04A_MENU_FOOTBALL_V1_COMPLETE`

## Objetivo

Implementar `Track 04A - FPS Playground Menu & Futebol V1`: transformar a identidade local em `FPS Playground`, criar menu inicial com selecao de modos, preservar `Arena Shooter` e adicionar o modo `Futebol` em primeira pessoa, 1x1 contra bot, sem armas, com bola fisica arcade solta, placar ate 3 gols e visual festivo inspirado na Copa do Mundo.

## Entregue

- `project.godot` agora usa nome `FPS Playground` e main scene `res://modes/menu/main_menu.tscn`.
- Menu principal com `Arena Shooter`, `Futebol` e `Sair`.
- Gerador de cenas cria menu, arena e football scenes.
- Arena Shooter preservada e com botao `Menu inicial` no pause.
- Novo modo `Futebol` com campo, gols, bola `RigidBody3D`, player FPS, bot futebol, placar ate 3 gols, HUD proprio e pause.
- LMB vira chute, RMB vira chute forte no Futebol; nao aplica dano/arma no bot.
- Feedback sintetico/primitivo de chute e gol.
- Testes adicionados para menu, Futebol, chute, chute forte, gol/match end e bot kick handoff.
- Documentacao local e portfolio atualizados.

## Validacao

PASS:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path Projetos\FpsShooter -s res://tools/validate.gd
```

Resultado:

- GUT `42/42`.
- `341` asserts.

PASS:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --editor --quit --path Projetos\FpsShooter
```

Observacao:

- Headless/editor ainda emite warnings conhecidos de UID/text path do plugin GUT.
- Sem erro novo nos scripts tocados.

## Proximo Handoff

Rodar smoke humano de 5 minutos: menu inicial, Arena Shooter preservado, retorno ao menu, Futebol, LMB/RMB chute, gols ate 3, bot atacando/defendendo, restart, pause, sensibilidade e retorno ao menu.
