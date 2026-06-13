# Handoff - JogoDaCopa Track 06C - Menu Broadcast V1

Data: 2026-06-13
Agente: Codex
Branch: `codex/jogodacopa/track06c-menu-broadcast-v1`
Worktree: `D:\Estudio-worktrees\jogodacopa-track06c`
Base: `c894dc0d chore(jogodacopa): add kenney cc0 fonts (serie 06 broadcast prereq)`

## Objetivo

Implementar o visual broadcast do menu principal usando fontes Kenney locais, preservando os caminhos existentes de testes e sem tocar HUD, autoloads, `project.godot`, `test_bootstrap` ou `presentation/hud/*`.

## Alteracoes

- `Projetos/JogoDaCopa/modes/menu/main_menu_root.gd`: card broadcast responsivo com header, hero shot, CTA alto, seletores de bot/modo/skin/camisa, sliders de audio/video e fonte Kenney carregada localmente.
- `Projetos/JogoDaCopa/tests/unit/test_menu_visual.gd`: cobertura dos viewports 1920x1080, 1280x720 e 960x540, caminhos legados, fonte broadcast, ciclos de aparencia e interacoes reais.
- `Projetos/JogoDaCopa/docs/asset-licenses.md`: registro local da familia Kenney Fonts CC0 1.0 para a Track 06C.
- `Projetos/JogoDaCopa/docs/screenshots/track-06c/`: evidencias PNG/JSON do menu em desktop e Web boot.

## Evidencias

- `docs/screenshots/track-06c/menu-broadcast-web-1920x1080.png`
- `docs/screenshots/track-06c/menu-broadcast-web-1366x768.png`
- `docs/screenshots/track-06c/menu-broadcast-web-1280x720.png`
- `docs/screenshots/track-06c/06c-web-menu-boot.png`
- `docs/screenshots/track-06c/06c-web-menu-boot.json`

## Validacao

- Godot import headless na worktree: OK.
- GUT focado `test_menu_visual.gd`: OK, suite completa carregada pela config, `98/98`, `1699` asserts.
- `tools/validate.gd`: OK, `98/98`, `1699` asserts, `[validate] success`.
- Export Web release: OK.
- Chrome Web boot smoke: OK, stage `menu.ready.end` visto, `pageErrors=0`, `consoleErrorCount=0`.
- `git diff --check`: OK.

Avisos conhecidos: warnings de UID/text path do GUT durante import/test/export; sem falha de validacao.

## Handoff

Parar pre-merge. Revisar visualmente os screenshots e, se aprovado, Fabio pode mergear a branch via fluxo local/GitHub Desktop.

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin
