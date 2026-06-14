# Track 08 - Super Campeao Rebrand & UI Cleanup

## Agente
- Codex

## Branch / Worktree
- Branch: `codex/jogodacopa/track08-super-campeao-ui`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track08-super-campeao-ui`

## Objetivo
- Rebrand visual publico de JogoDaCopa para `Super Campeao`.
- Remover textos redundantes de menu e intro.
- Remover Toon da UI/runtime/testes ativos.
- Manter gameplay intacto.

## Arquivos previstos
- `Projetos/JogoDaCopa/project.godot`
- `Projetos/JogoDaCopa/assets/branding/*`
- `Projetos/JogoDaCopa/modes/menu/main_menu_root.gd`
- `Projetos/JogoDaCopa/modes/football/football_root.gd`
- `Projetos/JogoDaCopa/presentation/hud/football_hud.gd`
- `Projetos/JogoDaCopa/gameplay/avatar/*`
- `Projetos/JogoDaCopa/gameplay/football/*`
- `Projetos/JogoDaCopa/tests/unit/*`
- `Projetos/JogoDaCopa/tools/*`
- `Projetos/JogoDaCopa/docs/*`
- `08_Coordenacao_Agentes/Estado_Atual.md`

## Validacao planejada
- Import headless na worktree.
- `tools/validate.gd`.
- `git diff --check`.
- Export Web local.
- Chrome/local probe: menu + primeiro minuto.
- Se publicar: Plan, Package, FullPublish, gates remotos e rollback para `web/v1-copa-arena-futebol-20260614-fa82cb7d` se qualquer gate remoto falhar.

## Evidencia local
- Import headless da worktree: PASS.
- `tools/validate.gd`: PASS (`104` testes / `1825` asserts).
- Export Web local: PASS.
- Chrome local menu/loading/intro/primeiro minuto: PASS; evidencias em `Projetos/JogoDaCopa/docs/playtest-reports/track-08-data/`.

## Proximo handoff
- Apos validacao local e antes/depois de publicar, registrar evidencias e baseline.
