# 2026-05-31 - Codex - DraxosMobile Rpgsuave Visual Upgrade v1

## Objetivo

Implementar o upgrade visual do Rpgsuave Bosque como minigame fullscreen mobile portrait: camera presa no personagem, movimento apenas por joystick, HUD dentro do jogo, mochila funcional com detalhes dev escondidos, assets procedurais Godot e publicacao de novo pacote Internal Alpha.

## Branch e worktree

- Branch: `codex/draxos-mobile/rpgsuave-visual-upgrade-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--rpgsuave-visual-upgrade-v1`
- Base: `29be99f` (`codex/draxos-mobile/rpgsuave-integrated-alpha`)

## Escopo planejado

- `Projetos/draxos-mobile/modes/boot/boot_runtime.gd`
- `Projetos/draxos-mobile/modes/boot/ui/app_shell_route_contract.gd`
- `Projetos/draxos-mobile/dev/minigames/rpgsuave/*`
- `Projetos/draxos-mobile/tests/client/test_rpgsuave_minigame_dev.gd`
- `Projetos/draxos-mobile/tools/smoke_rpgsuave_forest.gd`
- `Projetos/draxos-mobile/tools/smoke_rpgsuave_visual_layout.gd`
- `Projetos/draxos-mobile/tools/validate.gd`
- `Projetos/draxos-mobile/docs/minigames/rpgsuave.md`
- `Projetos/draxos-mobile/docs/contracts/minigame-integration.md`
- status/handoff/publicacao apos validacao

## Contexto lido

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/minigames/rpgsuave.md`
- `Projetos/draxos-mobile/docs/contracts/minigame-integration.md`

## Validacao planejada

- `git diff --check`
- Godot headless em `tools/validate.gd`
- GUT client focado em Rpgsuave
- `tools/smoke_rpgsuave_forest.gd`
- novo `tools/smoke_rpgsuave_visual_layout.gd`
- `tools/smoke_responsive_layout.gd`
- `tools/smoke_mobile_presentation.gd`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile Client`
- antes de publicar: validacao Full/remote conforme Track 13, se os scripts e credenciais locais estiverem disponiveis

## Handoff esperado

Entregar branch com commits logicos, pacote Internal Alpha publicado se a validacao permitir, release root registrado e instrucoes objetivas para playtest humano mobile portrait.
