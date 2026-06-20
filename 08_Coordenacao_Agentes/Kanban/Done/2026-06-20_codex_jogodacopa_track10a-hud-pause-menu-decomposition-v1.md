# Track 10A - HUD Pause Menu Decomposition V1

- Projeto: `Projetos/JogoDaCopa/`
- Branch: `codex/jogodacopa/track10a-hud-pause-menu-decomposition-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track10a-hud-pause-menu-decomposition-v1`
- Responsavel: Codex
- Inicio: `2026-06-20`
- Fechamento: `2026-06-20`
- Commit local: `fc3c72bb`
- Publicacao: `Super Campeao v1.2.1+fc3c72bb`
- URL publica: `https://copa-arena-futebol.pages.dev/`
- Release root: `web/v1-copa-arena-futebol-20260620-fc3c72bb`

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

Track concluida, mergeada localmente em `main` e publicada no Cloudflare.

## Resultado

- Criado `Projetos/JogoDaCopa/presentation/hud/football_hud_pause_menu_controller.gd`.
- `football_hud.gd` reduziu de `1512` para `1148` linhas fisicas.
- Mantidos paths, sinais e wrappers publicos do `FootballHud`.
- Escopo quente de gameplay preservado: sem mudanca intencional em camera, fisica, bot, bola, chute/SUPER, scoring, field builder, assets ou tuning.

## Validacao

- Import headless do editor: PASS.
- `tools/validate.gd`: PASS, `107/107` testes, `1835` asserts, `62` fontes.
- Web export: PASS.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- Chrome local 90s Web smoke: PASS, `pageErrors=0`, `consoleErrorCount=0`, `stabilityPassed=true`, `firstMinuteHitches=0`.
- Screenshot evidence do HUD pause nas resolucoes `1920x1080`, `1366x768` e `1280x720`: PASS.
- `git diff --check`: PASS.
- `D:\Estudio\tools\check_doc_drift.ps1`: PASS.
- Cloudflare FullPublish: PASS.
- Remote menu: PASS.
- Remote first minute: PASS, `firstMinuteHitches=0`.
- Remote stability 5min: PASS, `js_heap_growth +8.34%`, pico `+13.88%`, `wasmSampleCount=0`, pior janela 5s `129.8 FPS`.
- Remote night luma: PASS, `luma_0_255=6.525 < 90`.

## Evidencias

- Relatorio local: `Projetos/JogoDaCopa/docs/playtest-reports/track-10a-hud-pause-menu-decomposition.md`
- Relatorio de publicacao: `Projetos/JogoDaCopa/docs/playtest-reports/track-10a-publication.md`
- Evidencias JSON/PNG: `Projetos/JogoDaCopa/docs/playtest-reports/track-10a-data/`
- Screenshots locais: `Projetos/JogoDaCopa/docs/screenshots/track-10a-hud-pause-menu-decomposition-v1/`

## Proximo Passo

Reteste humano aprovado por Fabio/tester em 2026-06-20. A 10A e o baseline publico aprovado atual; 09S permanece o fallback aprovado mais recente. Proximo passo: planejar a proxima etapa tecnica ou pausar para reavaliacao antes de nova reducao.

`PUSH FEITO`: Fabio - GitHub Desktop - Push origin antes desta aprovacao documental.
