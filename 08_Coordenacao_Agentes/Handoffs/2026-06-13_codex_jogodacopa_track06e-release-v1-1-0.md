# Handoff - JogoDaCopa Track 06E Release v1.1.0

- Data: `2026-06-13`
- Agente: `Codex`
- Branch: `codex/jogodacopa/track06e-release-v1-1-0`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track06e`
- Projeto: `Projetos/JogoDaCopa`
- Status: `STOP_PRE_MERGE_REVIEW`

## Escopo Executado

FASES 0-4 executadas ate o ponto de review pre-merge. Nao houve merge em `main`, publicacao remota, `push`, `fetch`, `pull`, `git clean` ou mudanca de gameplay.

## Versao Bumpada

- `Projetos/JogoDaCopa/modes/menu/main_menu_root.gd`: `VISIBLE_VERSION` atualizado para `v1.1.0`; rodape local passa a exibir `Copa Arena Futebol v1.1.0+local | sem logos oficiais`.
- `Projetos/JogoDaCopa/tools/publish_web.ps1`: `$VisibleVersion` atualizado para `v1.1.0`; evidencias do script passam a sair em `docs/playtest-reports/track-06e-data/`; mensagem de deploy alinhada para Track 06E.
- `Projetos/JogoDaCopa/export_presets.cfg`: metadata Windows `application/file_version` e `application/product_version` alinhadas para `1.1.0.0`.
- `Projetos/JogoDaCopa/tests/unit/test_bootstrap.gd`: teste do rodape atualizado para exigir `Copa Arena Futebol v1.1.0+`.
- `Projetos/JogoDaCopa/docs/release-history.md`: entrada `v1.1.0` adicionada com baseline anterior `v1.0.3+ef9c5baa` / `web/v1-copa-arena-futebol-20260612-ef9c5baa` e resumo da Serie 06.

## Changelog v1.1.0

- 06A Match Start Fixes: countdown unico, facing inicial/pos-gol e HUD sem hints/crosshair.
- 06B ESC Menu Completo: settings persistentes, abas Controles/Audio/Video/Sensibilidade, tela cheia, volumes, qualidade e sensibilidade.
- 06C Menu Broadcast: menu principal em identidade broadcast com fontes Kenney, card de transmissao, CTA dominante e seletores visuais.
- 06D HUD Broadcast: scorebug/HUD broadcast, timer, badges, STAMINA/SUPER e anuncios visuais.
- 06E: bump de versao, changelog e evidencias locais pre-merge; publicacao unica continua pendente.

## Evidencia Local

- Prereq main: `git status --short` vazio; 06A-06D presentes no log de `main`; `tools/validate.gd` na main PASS com `101` testes / `1735` asserts.
- Import headless da worktree nova: executado uma vez com Godot `4.6.2-stable` (exit code `0`; warnings de cache/import do GUT observados).
- `tools/validate.gd` na branch: PASS com `101` testes / `1735` asserts.
- Export Web release: PASS apos criar a pasta gerada `builds/web`; single-threaded Web preset preservado.
- Export Windows debug: PASS para `builds/windows/CopaArenaFutebol.exe`.
- Revalidacao pos-export: PASS com `101` testes / `1735` asserts e Web gzip transfer `30.43 MiB / 50.00 MiB`.
- Boot Web local em Chrome: PASS, `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`, screenshot com rodape `v1.1.0+local`.
- Primeiro minuto local: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Luminancia noturna local: PASS, `luma_0_255=10.3` contra limite `< 90`.
- `git diff --check`: PASS.

## Arquivos De Evidencia

- `Projetos/JogoDaCopa/docs/playtest-reports/track-06e-data/06e-local-web-menu-version.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-06e-data/06e-local-web-menu-version.png`
- `Projetos/JogoDaCopa/docs/screenshots/track-06e/menu-footer-v1-1-0-web-1280x720.png`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-06e-data/06e-local-first-minute-gate.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-06e-data/06e-local-first-minute-gate.png`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-06e-data/06e-local-night-luma-gate.json`

## Pausa Obrigatoria

Aguardar review da Claude sobre consistencia de versao/changelog/evidencias e OK do Fabio antes de qualquer FASE 5 (merge em `main`) ou FASE 6 (publicacao remota via `tools/publish_web.ps1 -Mode FullPublish -ConfirmRemoteMutation`).
