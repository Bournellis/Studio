# Track 10A - HUD Pause Menu Decomposition V1

- Projeto: `Projetos/JogoDaCopa/`
- Branch: `codex/jogodacopa/track10a-hud-pause-menu-decomposition-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track10a-hud-pause-menu-decomposition-v1`
- Responsavel: Codex
- Inicio: `2026-06-20`

## Objetivo

Reduzir o `football_hud.gd` extraindo a construcao e sincronizacao do menu de pause/settings para um controlador dedicado, preservando comportamento visual, sinais, callbacks e fluxos de clique.

## Escopo

- Criar `presentation/hud/football_hud_pause_menu_controller.gd`.
- Mover a construcao do pause menu, tabs, secoes de controles/video/sensibilidade/volume e restart confirmation.
- Manter wrappers finos no `FootballHud` para assinaturas existentes.
- Preservar a cobertura de clique real existente e gerar evidencia visual nas resolucoes exigidas.

## Fora Do Escopo

- Gameplay, fisica, camera, bola, bot, chute/SUPER, scoring, field builder, tuning e layout visual intencional.

## Documentos Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/work-plan.md`
- `Projetos/JogoDaCopa/docs/architecture-overview.md`

## Validacao Planejada

- Import headless do editor.
- `tools/validate.gd`.
- Testes de clique real existentes do HUD pause.
- Screenshot evidence do HUD pause nas resolucoes `1920x1080`, `1366x768` e `1280x720`.
- Web export.
- `node --check tools/track04f_chrome_probe.mjs`.
- `git diff --check`.
- `D:\Estudio\tools\check_doc_drift.ps1`.
- Smoke Web local quando o export estiver pronto.

## Handoff

Fechar com relatorio em `Projetos/JogoDaCopa/docs/playtest-reports/track-10a-hud-pause-menu-decomposition.md`, mover este card para `Kanban/Done`, commit local, merge local em `main` e publicar no Cloudflare se os gates locais passarem.
